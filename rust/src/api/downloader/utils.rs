/// Pure utility functions: ID generation, file-name sanitization,
/// HTTP header parsing, URL/format guessing, atomic file writes.
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};
use std::{fs, io};

use reqwest::header::{CONTENT_LENGTH, CONTENT_RANGE};

use crate::api::plugin::models::Track;

// ── Time helpers ──────────────────────────────────────────────────────────────

pub fn current_unix_epoch_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

pub fn current_unix_epoch_millis() -> u128 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis()
}

// ── ID generation ─────────────────────────────────────────────────────────────

pub fn generate_task_id() -> String {
    let mut rng = rand::thread_rng();
    use rand::Rng;
    format!("dl-{}-{:08x}", current_unix_epoch_millis(), rng.gen::<u32>())
}

// ── File name helpers ─────────────────────────────────────────────────────────

/// Replace characters that are illegal on Windows/macOS/Linux file systems.
pub fn sanitize_file_component(value: &str, max_len: usize) -> String {
    let cleaned: String = value
        .chars()
        .map(|c| match c {
            '<' | '>' | ':' | '"' | '/' | '\\' | '|' | '?' | '*' => '_',
            c if c.is_control() => '_',
            c => c,
        })
        .collect();
    let trimmed = cleaned.trim().trim_end_matches(['.', ' ']);
    if trimmed.is_empty() {
        return "unknown".to_string();
    }
    trimmed.chars().take(max_len).collect()
}

/// Build a deterministic download file name from track metadata.
/// The 8-hex suffix is derived from the track ID so the same track always
/// produces the same file name suffix in the same process run (stored in
/// manifest at enqueue time, so stability across Rust versions is irrelevant).
pub fn build_download_file_name(track: &Track, extension: &str) -> String {
    let safe_title = sanitize_file_component(&track.title, 70);
    let artist_text = if track.artists.is_empty() {
        "Unknown Artist".to_string()
    } else {
        track.artists.iter().map(|a| a.name.clone()).collect::<Vec<_>>().join(", ")
    };
    let safe_artist = sanitize_file_component(&artist_text, 50);

    let mut hasher = DefaultHasher::new();
    track.id.hash(&mut hasher);
    let suffix = format!("{:08x}", hasher.finish() as u32);

    format!("{safe_title} - {safe_artist} [{suffix}].{}", extension.trim_start_matches('.'))
}

/// Infer an audio file extension from the optional format string or the URL path.
pub fn guess_extension_from_url(format: Option<&str>, url: &str) -> String {
    if let Some(fmt) = format.and_then(normalize_audio_extension_hint) {
        return fmt;
    }

    let path = url.split('?').next().unwrap_or(url).to_ascii_lowercase();
    for ext in [
        "m4a", "mp3", "ogg", "opus", "webm", "mp4", "flac", "wav", "aac", "ape",
        "aiff", "wv", "mpc", "oga", "spx",
    ] {
        if path.ends_with(&format!(".{ext}")) {
            return normalize_audio_extension_hint(ext).unwrap_or_else(|| ext.to_string());
        }
    }
    "m4a".to_string()
}

/// Normalize common codec / MIME hints to a filesystem extension.
pub fn normalize_audio_extension_hint(value: &str) -> Option<String> {
    let cleaned = value
        .trim()
        .trim_start_matches('.')
        .split(';')
        .next()
        .unwrap_or_default()
        .trim()
        .to_ascii_lowercase();
    if cleaned.is_empty() {
        return None;
    }

    let normalized = match cleaned.as_str() {
        "audio/mpeg" | "audio/mp3" | "audio/x-mp3" | "mpeg" | "mp3" | "mpga" => "mp3",
        "audio/mp4" | "audio/m4a" | "audio/x-m4a" | "m4a" | "mp4a" | "alac" => "m4a",
        "mp4" => "mp4",
        "audio/aac" | "audio/aacp" | "aac" | "adts" => "aac",
        "audio/flac" | "audio/x-flac" | "flac" => "flac",
        "audio/wav" | "audio/wave" | "audio/x-wav" | "wav" | "wave" => "wav",
        "audio/aiff" | "audio/x-aiff" | "aiff" | "aif" | "aifc" => "aiff",
        "audio/ogg" | "application/ogg" | "ogg" | "oga" | "vorbis" => "ogg",
        "audio/opus" | "opus" => "opus",
        "audio/webm" | "webm" => "webm",
        "audio/ape" | "ape" => "ape",
        "audio/wavpack" | "wavpack" | "wv" => "wv",
        "audio/musepack" | "musepack" | "mpc" => "mpc",
        "audio/speex" | "speex" | "spx" => "spx",
        other => other,
    };

    if normalized
        .chars()
        .all(|c| c.is_ascii_alphanumeric() || c == '+' || c == '-')
    {
        Some(normalized.to_string())
    } else {
        None
    }
}

// ── Media-ID helpers ──────────────────────────────────────────────────────────

/// Split a media ID of the form `"pluginId::localId"` into its two parts.
/// Returns `None` if the separator is absent.
pub fn split_media_id(media_id: &str) -> Option<(String, String)> {
    let idx = media_id.find("::")?;
    Some((media_id[..idx].to_string(), media_id[idx + 2..].to_string()))
}

// ── HTTP helpers ──────────────────────────────────────────────────────────────

/// Determine the total file size from response headers.
/// For a 206 response, the `Content-Range` header gives the full size.
/// For a 200 response, `Content-Length` gives the body size which we add
/// to `existing_size` (the bytes already downloaded before the request).
pub fn extract_total_bytes(headers: &reqwest::header::HeaderMap, existing_size: u64) -> Option<u64> {
    if let Some(range) = headers.get(CONTENT_RANGE).and_then(|v| v.to_str().ok()) {
        if let Some(total_part) = range.split('/').nth(1) {
            if let Ok(total) = total_part.parse::<u64>() {
                return Some(total);
            }
        }
    }
    headers
        .get(CONTENT_LENGTH)
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.parse::<u64>().ok())
        .map(|v| v + existing_size)
}

// ── Filesystem helpers ────────────────────────────────────────────────────────

/// Remove a file if it exists; succeed silently if it does not.
pub fn remove_if_exists(path: &str) -> io::Result<()> {
    if !path.is_empty() && Path::new(path).exists() {
        fs::remove_file(path)
    } else {
        Ok(())
    }
}

/// Write `content` to `dest_path` atomically:
/// 1. Write to a `.tmp` sibling file.
/// 2. Rename the `.tmp` file over `dest_path`.
///
/// This ensures `dest_path` is never partially written on process crashes.
pub fn atomic_write(dest_path: &str, content: &[u8]) -> io::Result<()> {
    let dest = Path::new(dest_path);
    let tmp_path: PathBuf = dest.with_extension("tmp");

    fs::write(&tmp_path, content)?;
    fs::rename(&tmp_path, dest)?;
    Ok(())
}

// ── Quality normalization ─────────────────────────────────────────────────────

/// Canonicalize an arbitrary quality string to "Low", "Medium", or "High".
pub fn normalize_quality(preference: &str) -> &'static str {
    match preference.trim().to_ascii_lowercase().as_str() {
        "low" => "Low",
        "high" => "High",
        _ => "Medium",
    }
}
