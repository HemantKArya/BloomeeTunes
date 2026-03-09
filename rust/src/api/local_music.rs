use flutter_rust_bridge::frb;
use lofty::config::ParseOptions;
use lofty::file::AudioFile;
use lofty::picture::PictureType;
use lofty::prelude::{Accessor, TaggedFileExt};
use lofty::probe::Probe;
use lofty::tag::ItemKey;
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

const AUDIO_EXTENSIONS: &[&str] = &[
    "mp3", "flac", "m4a", "ogg", "opus", "wav", "aac", "aiff", "wv", "ape", "mpc", "oga", "spx",
    "wma", "webm",
];

#[frb]
pub struct LocalTrackMeta {
    pub file_path: String,
    pub title: Option<String>,
    pub artists: Vec<String>,
    pub album: Option<String>,
    pub album_artist: Option<String>,
    pub year: Option<u32>,
    pub genre: Option<String>,
    pub duration_ms: Option<u64>,
    pub cover_art_path: Option<String>,
    pub file_size: u64,
}

#[frb]
pub fn read_audio_metadata(
    file_path: String,
    cover_cache_dir: String,
) -> Result<LocalTrackMeta, String> {
    let tagged_file = Probe::open(&file_path)
        .map_err(|e| format!("Cannot open '{}': {}", file_path, e))?
        .options(ParseOptions::new())
        .guess_file_type()
        .map_err(|e| format!("Cannot detect format for '{}': {}", file_path, e))?
        .read()
        .map_err(|e| format!("Cannot read tags for '{}': {}", file_path, e))?;

    let properties = tagged_file.properties();
    let duration_ms = properties.duration().as_millis() as u64;

    let tag = tagged_file.primary_tag().or_else(|| tagged_file.first_tag());

    let (title, artists, album, album_artist, year, genre) = if let Some(t) = tag {
        let artist_list: Vec<String> = t
            .get_strings(&ItemKey::TrackArtist)
            .map(|s| s.to_string())
            .collect();
        let artist_list = if artist_list.is_empty() {
            t.artist()
                .map(|a| vec![a.to_string()])
                .unwrap_or_default()
        } else {
            artist_list
        };

        (
            t.title().map(|s| s.to_string()),
            artist_list,
            t.album().map(|s| s.to_string()),
            t.get_string(&ItemKey::AlbumArtist)
                .map(|s| s.to_string()),
            t.year(),
            t.genre().map(|s| s.to_string()),
        )
    } else {
        (None, vec![], None, None, None, None)
    };

    let cover_art_path = extract_cover_art(tag, &cover_cache_dir, &file_path);

    let file_size = fs::metadata(&file_path).map(|m| m.len()).unwrap_or(0);

    let title = title.or_else(|| {
        Path::new(&file_path)
            .file_stem()
            .map(|s| s.to_string_lossy().to_string())
    });

    Ok(LocalTrackMeta {
        file_path,
        title,
        artists,
        album,
        album_artist,
        year,
        genre,
        duration_ms: if duration_ms > 0 {
            Some(duration_ms)
        } else {
            None
        },
        cover_art_path,
        file_size,
    })
}

#[frb]
pub fn scan_audio_files(
    directories: Vec<String>,
    cover_cache_dir: String,
) -> Vec<LocalTrackMeta> {
    let mut results = Vec::new();

    for dir in &directories {
        let dir_path = Path::new(dir);
        if !dir_path.is_dir() {
            continue;
        }
        walk_directory(dir_path, &cover_cache_dir, &mut results);
    }

    results
}

fn walk_directory(dir: &Path, cover_cache_dir: &str, results: &mut Vec<LocalTrackMeta>) {
    let entries = match fs::read_dir(dir) {
        Ok(e) => e,
        Err(_) => return,
    };

    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            walk_directory(&path, cover_cache_dir, results);
        } else if is_audio_file(&path) {
            let path_str = path.to_string_lossy().to_string();
            match read_audio_metadata(path_str, cover_cache_dir.to_string()) {
                Ok(meta) => results.push(meta),
                Err(_) => {}
            }
        }
    }
}

fn is_audio_file(path: &Path) -> bool {
    path.extension()
        .and_then(|ext| ext.to_str())
        .map(|ext| AUDIO_EXTENSIONS.contains(&ext.to_ascii_lowercase().as_str()))
        .unwrap_or(false)
}

fn extract_cover_art(
    tag: Option<&lofty::tag::Tag>,
    cover_cache_dir: &str,
    _file_path: &str,
) -> Option<String> {
    let tag = tag?;

    let picture = tag
        .pictures()
        .iter()
        .find(|p| p.pic_type() == PictureType::CoverFront)
        .or_else(|| tag.pictures().first())?;

    let data = picture.data();
    if data.is_empty() {
        return None;
    }

    // SHA-256 of the raw bytes → stable cache key regardless of resize.
    let mut hasher = Sha256::new();
    hasher.update(data);
    let hash = format!("{:x}", hasher.finalize());

    // Always save as JPEG after resize so the extension is deterministic.
    let dest = Path::new(cover_cache_dir).join(format!("{}.jpg", hash));
    if dest.exists() {
        return Some(dest.to_string_lossy().to_string());
    }

    if let Err(_) = fs::create_dir_all(cover_cache_dir) {
        return None;
    }

    // Decode → resize to 512 × 512 max (preserves aspect ratio) → encode JPEG.
    match image::load_from_memory(data) {
        Ok(img) => {
            let resized = img.thumbnail(512, 512);
            let mut buf = Vec::new();
            if resized
                .write_to(
                    &mut std::io::Cursor::new(&mut buf),
                    image::ImageFormat::Jpeg,
                )
                .is_ok()
            {
                if fs::write(&dest, &buf).is_ok() {
                    return Some(dest.to_string_lossy().to_string());
                }
            }
            // Fallback: write the raw bytes if resize/encode failed.
            if fs::write(&dest, data).is_ok() {
                return Some(dest.to_string_lossy().to_string());
            }
        }
        Err(_) => {
            // Unsupported image format: store raw bytes as-is.
            if fs::write(&dest, data).is_ok() {
                return Some(dest.to_string_lossy().to_string());
            }
        }
    }

    None
}
