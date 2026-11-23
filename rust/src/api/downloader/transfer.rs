//! HTTP download loop and audio metadata writing.

use std::fs::{self, File, OpenOptions};
use std::io::{Cursor, Write};
use std::path::Path;
use std::sync::atomic::Ordering;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use lofty::config::{ParseOptions, WriteOptions};
use lofty::file::{AudioFile, FileType};
use lofty::picture::{Picture, PictureType};
use lofty::prelude::{Accessor, TaggedFileExt};
use lofty::probe::Probe;
use lofty::tag::{ItemKey, Tag};
use reqwest::header::{ACCEPT_RANGES, RANGE};

use crate::api::downloader::types::{DownloadTaskState, ManagedTask, TransferOutcome};
use crate::api::downloader::utils::{
    build_download_file_name, extract_total_bytes, guess_extension_from_url,
};
use crate::api::plugin::models::{StreamSource, Track};
use crate::utils::http;

const PROGRESS_EMIT_INTERVAL: Duration = Duration::from_millis(250);
const FILE_WRITE_BUFFER_SIZE: usize = 512 * 1024;

/// Progress update emitted from the download loop back to the caller.
pub struct ProgressUpdate {
    pub state: DownloadTaskState,
    pub bytes_downloaded: u64,
    pub total_bytes: Option<u64>,
    pub message: String,
    /// Non-empty only when a non-fatal warning occurred (e.g. metadata failure).
    pub warning: Option<String>,
}

/// Downloads the stream into the task's `.part` file, renames it to the final
/// target and tags it. Network reads are async; file writes go through a
/// buffered writer on a blocking thread, so no async worker ever waits on
/// the disk.
///
/// Returns `Err` for failures that should be retried, and `Ok` for the user
/// driven outcomes (pause, cancel) and completion.
pub async fn download_task(
    task: Arc<Mutex<ManagedTask>>,
    stream: StreamSource,
    on_progress: impl Fn(ProgressUpdate) + Send + Sync + 'static,
) -> Result<TransferOutcome, String> {
    let (task_id, temp_path, target_path, extra_headers) = {
        let guard = task.lock().map_err(|_| "Task mutex poisoned".to_string())?;
        let headers = guard
            .persisted
            .selected_stream
            .as_ref()
            .and_then(|s| s.headers.clone());
        (
            guard.persisted.task_id.clone(),
            guard.persisted.temp_path.clone(),
            guard.persisted.target_path.clone(),
            headers,
        )
    };

    if target_path.is_empty() {
        return Err(format!(
            "Task {task_id}: target path was not set (stream resolution may have been skipped)"
        ));
    }

    let existing_size = tokio::fs::metadata(&temp_path)
        .await
        .map(|m| m.len())
        .unwrap_or(0);

    on_progress(ProgressUpdate {
        state: DownloadTaskState::Downloading,
        bytes_downloaded: existing_size,
        total_bytes: None,
        message: "Downloading".to_string(),
        warning: None,
    });

    let mut req = http::client().get(&stream.url);
    if let Some(headers) = &extra_headers {
        for (k, v) in headers {
            req = req.header(k, v);
        }
    }
    // Always ask for a range, even from zero: some backends serve ranged
    // responses on a faster path. A plain 200 falls back below.
    req = req.header(RANGE, format!("bytes={existing_size}-"));

    let mut response = req.send().await.map_err(|e| format!("Request failed: {e}"))?;

    let status = response.status();
    if !status.is_success() && status.as_u16() != 206 {
        // A signed URL can be revoked before its advertised expiry. Retry
        // through the provider rather than reusing the rejected URL.
        if matches!(status.as_u16(), 401 | 403 | 410) {
            if let Ok(mut guard) = task.lock() {
                guard.persisted.selected_stream = None;
            }
        }
        return Err(format!("Server responded with {status}"));
    }

    let range_supported = response
        .headers()
        .get(ACCEPT_RANGES)
        .and_then(|v| v.to_str().ok())
        .map(|v| v.eq_ignore_ascii_case("bytes"))
        .unwrap_or(status.as_u16() == 206);
    let resume_from = if existing_size > 0 && status.as_u16() != 206 { 0 } else { existing_size };
    let total_bytes = extract_total_bytes(response.headers(), resume_from);

    let append = resume_from > 0 && status.as_u16() == 206;
    let mut output = PartFile::open(temp_path.clone(), append).await?;
    let mut downloaded = resume_from;
    let mut last_emit = Instant::now();

    loop {
        let (pause, cancel, delete_partial) = task
            .lock()
            .map(|g| {
                (
                    g.pause_requested.load(Ordering::Acquire),
                    g.cancel_requested.load(Ordering::Acquire),
                    g.delete_partial_on_cancel.load(Ordering::Acquire),
                )
            })
            .unwrap_or((false, false, false));

        if cancel {
            let _ = output.finish().await;
            if delete_partial {
                let _ = tokio::fs::remove_file(&temp_path).await;
                remove_file_if_exists(&target_path);
            }
            return Ok(TransferOutcome::Cancelled);
        }

        if pause {
            output.finish().await?;
            on_progress(ProgressUpdate {
                state: DownloadTaskState::Paused,
                bytes_downloaded: downloaded,
                total_bytes,
                message: if range_supported {
                    "Paused".to_string()
                } else {
                    "Paused (server does not support resume)".to_string()
                },
                warning: None,
            });
            return Ok(TransferOutcome::Paused);
        }

        let Some(chunk) = response.chunk().await.map_err(|e| format!("Read error: {e}"))? else {
            break;
        };
        downloaded += chunk.len() as u64;
        output.write(&chunk).await?;

        if last_emit.elapsed() >= PROGRESS_EMIT_INTERVAL {
            on_progress(ProgressUpdate {
                state: DownloadTaskState::Downloading,
                bytes_downloaded: downloaded,
                total_bytes,
                message: "Downloading".to_string(),
                warning: None,
            });
            last_emit = Instant::now();
        }
    }
    output.finish().await?;

    let finalize_task = task.clone();
    let finalize_stream = stream.clone();
    let (final_target_path, path_warning) = tokio::task::spawn_blocking(move || {
        finalize_output_path(&finalize_task, &temp_path, &finalize_stream)
    })
    .await
    .map_err(|e| format!("Finalize worker failed: {e}"))?
    .map_err(|e| format!("Failed to finalize download output path: {e}"))?;

    on_progress(ProgressUpdate {
        state: DownloadTaskState::WritingMetadata,
        bytes_downloaded: downloaded,
        total_bytes: total_bytes.or(Some(downloaded)),
        message: "Writing metadata".to_string(),
        warning: None,
    });

    let track = task
        .lock()
        .map(|g| g.persisted.track.clone())
        .map_err(|_| "Task mutex poisoned during metadata read".to_string())?;
    let cover = fetch_cover_picture(&track).await;
    let metadata_warning = tokio::task::spawn_blocking(move || {
        match write_audio_metadata(&final_target_path, &track, cover) {
            Ok(warning) => warning,
            Err(error) => Some(error),
        }
    })
    .await
    .unwrap_or_else(|e| Some(format!("Metadata worker failed: {e}")));
    let warning = combine_warnings(path_warning, metadata_warning);

    on_progress(ProgressUpdate {
        state: DownloadTaskState::CompletedPendingAck,
        bytes_downloaded: downloaded,
        total_bytes: total_bytes.or(Some(downloaded)),
        message: if warning.is_some() {
            "Downloaded (metadata tagging failed)".to_string()
        } else {
            "Downloaded".to_string()
        },
        warning,
    });

    Ok(TransferOutcome::Completed)
}

/// The `.part` file. Chunks collect in one buffer that is handed to a
/// blocking thread when full, so the disk never stalls an async worker.
struct PartFile {
    file: Option<File>,
    buffer: Vec<u8>,
}

impl PartFile {
    async fn open(path: String, append: bool) -> Result<Self, String> {
        let file = tokio::task::spawn_blocking(move || {
            if append {
                OpenOptions::new().create(true).append(true).open(&path)
            } else {
                OpenOptions::new().create(true).truncate(true).write(true).open(&path)
            }
        })
        .await
        .map_err(|e| format!("Failed to open part file: {e}"))?
        .map_err(|e| format!("Failed to open part file: {e}"))?;
        Ok(Self {
            file: Some(file),
            buffer: Vec::with_capacity(FILE_WRITE_BUFFER_SIZE),
        })
    }

    async fn write(&mut self, chunk: &[u8]) -> Result<(), String> {
        self.buffer.extend_from_slice(chunk);
        if self.buffer.len() >= FILE_WRITE_BUFFER_SIZE {
            self.flush(false).await?;
        }
        Ok(())
    }

    async fn finish(&mut self) -> Result<(), String> {
        self.flush(true).await
    }

    async fn flush(&mut self, close: bool) -> Result<(), String> {
        let Some(mut file) = self.file.take() else {
            return Ok(());
        };
        let mut buffer = std::mem::take(&mut self.buffer);
        let (file, buffer) = tokio::task::spawn_blocking(move || {
            file.write_all(&buffer)?;
            buffer.clear();
            if close {
                file.flush()?;
            }
            Ok::<_, std::io::Error>((file, buffer))
        })
        .await
        .map_err(|e| format!("Write worker failed: {e}"))?
        .map_err(|e| format!("Write error: {e}"))?;
        if !close {
            self.file = Some(file);
            self.buffer = buffer;
        }
        Ok(())
    }
}

/// Write title, artist, album, and cover art to the audio file at `file_path`
/// using the `lofty` crate.
///
/// This is a best-effort operation. Text tags should still be written even
/// when artwork fetching/parsing fails, because broken cover art should not
/// discard title/artist/album metadata entirely.
///
/// Returns an optional warning string for non-fatal issues such as artwork
/// download/parse failures.
pub fn write_audio_metadata(
    file_path: &str,
    track: &Track,
    cover: Result<Option<Picture>, String>,
) -> Result<Option<String>, String> {
    let probe = Probe::open(file_path)
        .map_err(|e| format!("Cannot open '{file_path}' for tagging: {e}"))?
        .options(ParseOptions::new().read_properties(false))
        .guess_file_type()
        .map_err(|e| format!("Cannot detect audio format for '{file_path}': {e}"))?;

    let file_type = probe
        .file_type()
        .ok_or_else(|| format!("Cannot determine audio format for '{file_path}'"))?;

    let mut tagged_file = probe
        .read()
        .map_err(|e| format!("Cannot parse audio file for tagging: {e}"))?;

    // Prefer the primary tag type; fall back to the first available tag;
    // create a new tag of the primary type if none exist.
    let tag: &mut Tag = if tagged_file.primary_tag().is_some() {
        tagged_file.primary_tag_mut().unwrap()
    } else if tagged_file.first_tag().is_some() {
        tagged_file.first_tag_mut().unwrap()
    } else {
        let tag_type = tagged_file.primary_tag_type();
        tagged_file.insert_tag(Tag::new(tag_type));
        tagged_file
            .primary_tag_mut()
            .ok_or("Failed to create metadata tag")?
    };

    tag.set_title(track.title.clone());

    let artist = track.artists.iter().map(|a| a.name.clone()).collect::<Vec<_>>().join(", ");
    if !artist.is_empty() {
        tag.set_artist(artist);
    }

    if let Some(album) = &track.album {
        tag.set_album(album.title.clone());
        if let Some(year) = album.year {
            tag.insert_text(ItemKey::Year, year.to_string());
        }
    }

    if let Some(lyrics) = &track.lyrics {
        if let Some(plain) = lyrics.plain.as_ref().filter(|text| !text.trim().is_empty()) {
            tag.insert_text(ItemKey::Lyrics, plain.clone());
        } else if let Some(synced) = lyrics.synced.as_ref().filter(|text| !text.trim().is_empty()) {
            tag.insert_text(ItemKey::Lyrics, synced.clone());
        }
        if let Some(copyright) = lyrics
            .copyright
            .as_ref()
            .filter(|text| !text.trim().is_empty())
        {
            tag.set_comment(copyright.clone());
        }
    }

    // Embed cover art when available.
    let artwork_warning = match cover {
        Ok(Some(picture)) => {
            tag.remove_picture_type(PictureType::CoverFront);
            tag.push_picture(picture);
            None
        }
        Ok(None) => None,
        Err(error) => Some(error),
    };

    let _ = file_type;
    tagged_file
        .save_to_path(file_path, WriteOptions::default())
        .map_err(|e| format!("Failed to save metadata to '{file_path}': {e}"))?;

    Ok(artwork_warning)
}

fn finalize_output_path(
    task: &Arc<Mutex<ManagedTask>>,
    temp_path: &str,
    stream: &StreamSource,
) -> Result<(String, Option<String>), String> {
    let detected_extension = detect_audio_extension(temp_path).ok();

    let (track, download_dir, current_target_path) = {
        let guard = task.lock().map_err(|_| "Task mutex poisoned while finalizing path".to_string())?;
        (
            guard.persisted.track.clone(),
            guard.persisted.download_dir.clone(),
            guard.persisted.target_path.clone(),
        )
    };

    let fallback_extension = Path::new(&current_target_path)
        .extension()
        .and_then(|ext| ext.to_str())
        .map(|ext| ext.to_ascii_lowercase())
        .filter(|ext| !ext.is_empty())
        .unwrap_or_else(|| guess_extension_from_url(Some(&stream.format), &stream.url));

    let final_extension = detected_extension.clone().unwrap_or(fallback_extension);
    let file_name = build_download_file_name(&track, &final_extension);
    let final_target_path = Path::new(&download_dir)
        .join(&file_name)
        .to_string_lossy()
        .into_owned();

    if Path::new(&final_target_path).exists() {
        fs::remove_file(&final_target_path)
            .map_err(|e| format!("Could not remove stale target: {e}"))?;
    }

    // Try rename first (same filesystem), fall back to copy+delete for
    // cross-device moves (common on Android where temp and download dirs
    // live on different mount points).
    if let Err(_rename_err) = fs::rename(temp_path, &final_target_path) {
        fs::copy(temp_path, &final_target_path)
            .map_err(|e| format!("Failed to copy part file to target: {e}"))?;
        let _ = fs::remove_file(temp_path);
    }

    if let Ok(mut guard) = task.lock() {
        guard.persisted.file_name = file_name;
        guard.persisted.target_path = final_target_path.clone();
    }

    let warning = match detected_extension {
        Some(_) => None,
        None => Some(format!(
            "Downloaded file format could not be verified from content; kept '{}' extension hint",
            Path::new(&current_target_path)
                .extension()
                .and_then(|ext| ext.to_str())
                .unwrap_or(&final_extension)
        )),
    };

    Ok((final_target_path, warning))
}

fn detect_audio_extension(path: &str) -> Result<String, String> {
    let probe = Probe::open(path)
        .map_err(|e| format!("Cannot open '{path}' for format detection: {e}"))?
        .options(ParseOptions::new().read_properties(false))
        .guess_file_type()
        .map_err(|e| format!("Cannot inspect downloaded audio bytes: {e}"))?;

    let file_type = probe
        .file_type()
        .ok_or_else(|| "Downloaded bytes do not match a supported audio container".to_string())?;

    Ok(extension_for_file_type(file_type).to_string())
}

fn extension_for_file_type(file_type: FileType) -> &'static str {
    match file_type {
        FileType::Aac => "aac",
        FileType::Aiff => "aiff",
        FileType::Ape => "ape",
        FileType::Flac => "flac",
        FileType::Mpeg => "mp3",
        FileType::Mp4 => "m4a",
        FileType::Mpc => "mpc",
        FileType::Opus => "opus",
        FileType::Vorbis => "ogg",
        FileType::Speex => "spx",
        FileType::Wav => "wav",
        FileType::WavPack => "wv",
        _ => "m4a",
    }
}

async fn fetch_cover_picture(track: &Track) -> Result<Option<Picture>, String> {
    let artwork_url = track
        .thumbnail
        .url_high
        .clone()
        .or_else(|| track.thumbnail.url_low.clone())
        .unwrap_or_else(|| track.thumbnail.url.clone());

    if artwork_url.trim().is_empty() {
        return Ok(None);
    }

    let response = http::client()
        .get(&artwork_url)
        .send()
        .await
        .map_err(|e| format!("Failed to fetch artwork: {e}"))?;
    if !response.status().is_success() {
        return Err(format!("Artwork request failed with {}", response.status()));
    }

    let bytes = response
        .bytes()
        .await
        .map_err(|e| format!("Failed to read artwork bytes: {e}"))?;
    let mut picture = Picture::from_reader(&mut Cursor::new(bytes.as_ref()))
        .map_err(|e| format!("Artwork is not in a supported image format: {e}"))?;
    picture.set_pic_type(PictureType::CoverFront);
    picture.set_description(Some("Cover".to_string()));
    Ok(Some(picture))
}

fn combine_warnings(first: Option<String>, second: Option<String>) -> Option<String> {
    match (first, second) {
        (None, None) => None,
        (Some(warning), None) | (None, Some(warning)) => Some(warning),
        (Some(first), Some(second)) => Some(format!("{first}; {second}")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::downloader::types::PersistedDownloadTask;
    use std::io::Read;
    use std::net::TcpListener;

    #[tokio::test(flavor = "multi_thread")]
    async fn rejected_signed_urls_are_invalidated_but_server_errors_keep_the_stream() {
        for status in [401, 403, 410, 500] {
            let listener = TcpListener::bind("127.0.0.1:0").unwrap();
            let url = format!("http://{}/audio", listener.local_addr().unwrap());
            let server = std::thread::spawn(move || {
                let (mut socket, _) = listener.accept().unwrap();
                socket.set_read_timeout(Some(Duration::from_secs(5))).unwrap();
                let mut request = [0u8; 4096];
                socket.read(&mut request).unwrap();
                write!(socket, "HTTP/1.1 {status} Rejected\r\nContent-Length: 0\r\nConnection: close\r\n\r\n").unwrap();
            });
            let persisted: PersistedDownloadTask = serde_json::from_value(serde_json::json!({
                "task_id": "test", "track": {
                    "id": "provider::track", "title": "Track", "artists": [],
                    "thumbnail": {"url": "", "layout": "Square"}, "is_explicit": false
                },
                "download_dir": "", "preferred_quality": "Medium",
                "file_name": "test.mp3", "target_path": "test.mp3", "temp_path": "",
                "state": "Downloading", "progress": 0.0, "bytes_downloaded": 0,
                "total_bytes": null, "message": null, "last_error": null,
                "retry_attempt": 0, "selected_stream": {
                    "url": url, "quality": "Medium", "format": "mp3",
                    "headers": null, "expires_at": null
                }
            })).unwrap();
            let stream = persisted.selected_stream.clone().unwrap();
            let task = Arc::new(Mutex::new(ManagedTask::from_persisted(persisted)));
            let result = download_task(task.clone(), stream, |_| {}).await;
            assert!(result.err().unwrap().contains(&status.to_string()));
            assert_eq!(task.lock().unwrap().persisted.selected_stream.is_none(), status != 500);
            server.join().unwrap();
        }
    }
}

fn remove_file_if_exists(path: &str) {
    if !path.is_empty() && Path::new(path).exists() {
        let _ = fs::remove_file(path);
    }
}
