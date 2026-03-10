/// HTTP download loop and audio metadata writing.
///
/// Both functions are free functions that accept only what they need, so they
/// can run inside `tokio::task::spawn_blocking` without holding a reference to
/// the async runtime.
use std::fs::{self, File, OpenOptions};
use std::io::{BufWriter, Cursor, Read, Write};
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
use reqwest::blocking::Client;
use reqwest::header::{ACCEPT_RANGES, RANGE};

use crate::api::downloader::types::{DownloadTaskState, ManagedTask, TransferOutcome};
use crate::api::downloader::utils::{
    build_download_file_name, extract_total_bytes, guess_extension_from_url,
};
use crate::api::plugin::models::{StreamSource, Track};

/// Minimum interval between emitted progress updates during the download loop.
const PROGRESS_EMIT_INTERVAL: Duration = Duration::from_millis(250);
const NETWORK_READ_BUFFER_SIZE: usize = 256 * 1024;
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

/// Download the stream at `stream.url` into the task's temp file, then rename
/// to the final target path and write audio metadata.
///
/// Progress callbacks are sent via `on_progress`. The function does not hold
/// the task mutex while doing I/O; it only acquires it briefly to check the
/// pause/cancel flags and to read needed fields.
///
/// # Errors
/// Returns `Err` for non-recoverable failures (bad HTTP status, I/O errors,
/// etc.) that should trigger a retry in the caller.
/// Returns `Ok(TransferOutcome::*)` for user-driven outcomes (pause/cancel)
/// and successful completion.
pub fn download_task_blocking(
    task: &Arc<Mutex<ManagedTask>>,
    stream: &StreamSource,
    http_client: &Client,
    mut on_progress: impl FnMut(ProgressUpdate),
) -> Result<TransferOutcome, String> {
    // Read necessary paths from the task under a short lock.
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

    // Validate target_path — if resolution never ran this would be empty.
    if target_path.is_empty() {
        return Err(format!(
            "Task {task_id}: target path was not set (stream resolution may have been skipped)"
        ));
    }

    // Determine how many bytes we already have in the .part file.
    let existing_size = File::open(&temp_path)
        .ok()
        .and_then(|f| f.metadata().ok())
        .map(|m| m.len())
        .unwrap_or(0);

    on_progress(ProgressUpdate {
        state: DownloadTaskState::Downloading,
        bytes_downloaded: existing_size,
        total_bytes: None,
        message: "Downloading".to_string(),
        warning: None,
    });

    // Build the HTTP request, appending Range header if we have partial data.
    let mut req = http_client.get(&stream.url);
    if let Some(headers) = &extra_headers {
        for (k, v) in headers {
            req = req.header(k, v);
        }
    }
    // Always prefer a range request, even for a fresh download. Some backends
    // serve the initial 200 response through a slower path but handle ranged
    // responses efficiently. If the server ignores it and returns 200, we
    // transparently fall back below.
    req = req.header(RANGE, format!("bytes={existing_size}-"));

    let mut response = req.send().map_err(|e| format!("Request failed: {e}"))?;

    let status = response.status();
    if !status.is_success() && status.as_u16() != 206 {
        return Err(format!("Server responded with {status}"));
    }

    // Decide if the server actually supports resuming this request.
    let range_supported = response
        .headers()
        .get(ACCEPT_RANGES)
        .and_then(|v| v.to_str().ok())
        .map(|v| v.eq_ignore_ascii_case("bytes"))
        .unwrap_or(status.as_u16() == 206);

    // If we sent a Range header but got 200 back, start from the beginning.
    let resume_from = if existing_size > 0 && status.as_u16() != 206 { 0 } else { existing_size };

    let total_bytes = extract_total_bytes(response.headers(), resume_from);

    // Open or create the .part file.
    let append = resume_from > 0 && status.as_u16() == 206;
    let file = if append {
        OpenOptions::new().create(true).append(true).open(&temp_path)
    } else {
        OpenOptions::new().create(true).truncate(true).write(true).open(&temp_path)
    }
    .map_err(|e| format!("Failed to open part file: {e}"))?;
    let mut output = BufWriter::with_capacity(FILE_WRITE_BUFFER_SIZE, file);

    let mut downloaded = resume_from;
    let mut buf = [0u8; NETWORK_READ_BUFFER_SIZE];
    let mut last_emit = Instant::now();

    // ── Read loop ────────────────────────────────────────────────────────────

    loop {
        // Sample flags once per chunk — acquire semantics so we see the latest write.
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
            let _ = output.flush();
            drop(output);
            if delete_partial {
                let _ = fs::remove_file(&temp_path);
                let _ = remove_file_if_exists(&target_path);
            }
            return Ok(TransferOutcome::Cancelled);
        }

        if pause {
            output.flush().map_err(|e| format!("Flush error: {e}"))?;
            drop(output);
            let msg = if range_supported {
                "Paused".to_string()
            } else {
                "Paused (server does not support resume)".to_string()
            };
            on_progress(ProgressUpdate {
                state: DownloadTaskState::Paused,
                bytes_downloaded: downloaded,
                total_bytes,
                message: msg,
                warning: None,
            });
            return Ok(TransferOutcome::Paused);
        }

        let n = response.read(&mut buf).map_err(|e| format!("Read error: {e}"))?;
        if n == 0 {
            break;
        }
        output.write_all(&buf[..n]).map_err(|e| format!("Write error: {e}"))?;
        downloaded += n as u64;

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

    output.flush().map_err(|e| format!("Flush error: {e}"))?;
    drop(output);

    // ── Rename .part → final file using detected container format ────────────

    let (final_target_path, path_warning) = finalize_output_path(task, &temp_path, stream)
        .map_err(|e| format!("Failed to finalize download output path: {e}"))?;

    on_progress(ProgressUpdate {
        state: DownloadTaskState::WritingMetadata,
        bytes_downloaded: downloaded,
        total_bytes: total_bytes.or(Some(downloaded)),
        message: "Writing metadata".to_string(),
        warning: None,
    });

    // ── Write audio metadata (non-fatal) ──────────────────────────────────────

    let track = task
        .lock()
        .map(|g| g.persisted.track.clone())
        .map_err(|_| "Task mutex poisoned during metadata read".to_string())?;

    let metadata_warning = match write_audio_metadata(http_client, &final_target_path, &track) {
        Ok(warning) => warning,
        Err(error) => Some(error),
    };
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
    client: &Client,
    file_path: &str,
    track: &Track,
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
    let artwork_warning = match fetch_cover_picture(client, track) {
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

fn fetch_cover_picture(client: &Client, track: &Track) -> Result<Option<Picture>, String> {
    let artwork_url = track
        .thumbnail
        .url_high
        .clone()
        .or_else(|| track.thumbnail.url_low.clone())
        .unwrap_or_else(|| track.thumbnail.url.clone());

    if artwork_url.trim().is_empty() {
        return Ok(None);
    }

    let response = client
        .get(&artwork_url)
        .send()
        .map_err(|e| format!("Failed to fetch artwork: {e}"))?;
    if !response.status().is_success() {
        return Err(format!("Artwork request failed with {}", response.status()));
    }

    let bytes = response
        .bytes()
        .map_err(|e| format!("Failed to read artwork bytes: {e}"))?;
    let mut cursor = Cursor::new(bytes.to_vec());
    let mut picture = Picture::from_reader(&mut cursor)
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

fn remove_file_if_exists(path: &str) {
    if !path.is_empty() && Path::new(path).exists() {
        let _ = fs::remove_file(path);
    }
}
