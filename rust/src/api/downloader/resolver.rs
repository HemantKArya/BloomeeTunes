/// Stream resolution: selects the best stream for a download task by calling
/// the plugin manager, caching the result, and refreshing only when the cached
/// URL has expired.
use std::path::Path;
use std::sync::{Arc, Mutex};
use std::sync::atomic::Ordering;

use crate::api::downloader::types::ManagedTask;
use crate::api::downloader::utils::{
    current_unix_epoch_secs, guess_extension_from_url, normalize_quality, split_media_id,
    build_download_file_name,
};
use crate::api::plugin::commands::{ContentResolverCommand, PluginRequest, PluginResponse};
use crate::api::plugin::models::{Quality, StreamSource};
use crate::api::plugin::plugin::PluginManager;

/// Seconds before a stream's stated expiry at which we consider it too close to
/// use. This prevents starting a download with a URL that will expire mid-flight.
const EXPIRY_MARGIN_SECS: u64 = 60;

/// Return `true` if `stream` has a non-empty HTTPS/HTTP URL and is not expired
/// (with a safety margin of [`EXPIRY_MARGIN_SECS`]).
pub fn is_stream_usable(stream: &StreamSource) -> bool {
    let url = stream.url.trim();
    if url.is_empty() || !(url.starts_with("http://") || url.starts_with("https://")) {
        return false;
    }
    if let Some(expires_at) = stream.expires_at {
        let now = current_unix_epoch_secs();
        if expires_at <= now + EXPIRY_MARGIN_SECS {
            return false;
        }
    }
    true
}

/// Pick the best stream from `streams` given a quality preference string.
/// Falls back to progressively wider selections before giving up.
pub fn select_best_stream(streams: &[StreamSource], preference: &str) -> Option<StreamSource> {
    let priority: &[Quality] = match normalize_quality(preference) {
        "Low" => &[Quality::Low, Quality::Medium, Quality::High, Quality::Lossless],
        "High" => &[Quality::Lossless, Quality::High, Quality::Medium, Quality::Low],
        _ => &[Quality::Medium, Quality::High, Quality::Low, Quality::Lossless],
    };

    for &quality in priority {
        if let Some(s) = streams.iter().find(|s| s.quality == quality && is_stream_usable(s)) {
            return Some(s.clone());
        }
    }
    // Last resort: any usable stream regardless of quality.
    streams.iter().find(|s| is_stream_usable(s)).cloned()
}

/// Resolve the best stream for `task_id`, using the cached stream when still
/// valid or fetching a fresh one from the plugin manager otherwise.
///
/// Also derives and stores `file_name` / `target_path` on first successful
/// resolution so the rest of the pipeline always has a non-empty target.
///
/// Returns `Err` if the task was cancelled while waiting on the plugin call.
pub async fn resolve_stream(
    task: &Arc<Mutex<ManagedTask>>,
    plugin_manager: &PluginManager,
) -> Result<StreamSource, String> {
    // 1. Return cached stream if it is still usable.
    {
        let guard = task.lock().map_err(|_| "Task mutex poisoned".to_string())?;
        if guard.cancel_requested.load(Ordering::Acquire) {
            return Err("Task was cancelled during stream resolution".to_string());
        }
        if let Some(cached) = &guard.persisted.selected_stream {
            if is_stream_usable(cached) {
                return Ok(cached.clone());
            }
        }
    }

    // 2. Need a fresh stream – read the fields we need under a short lock.
    let (track, preference) = {
        let guard = task.lock().map_err(|_| "Task mutex poisoned".to_string())?;
        (guard.persisted.track.clone(), guard.persisted.preferred_quality.clone())
    };

    // 3. Fetch from plugin manager (this is async and may take time).
    let stream = if let Some((plugin_id, local_id)) = split_media_id(&track.id) {
        let response = plugin_manager
            .handle_plugin_request(
                &plugin_id,
                PluginRequest::ContentResolver(ContentResolverCommand::GetStreams {
                    id: local_id,
                }),
            )
            .await
            .map_err(|e| e.to_string())?;

        let streams = match response {
            PluginResponse::Streams(s) => s,
            _ => return Err("Unexpected plugin response for GetStreams".to_string()),
        };

        select_best_stream(&streams, &preference)
            .ok_or_else(|| format!("No usable streams returned for '{}'", track.title))?
    } else if let Some(url) = track.url.clone() {
        // Direct URL track (not a plugin-managed ID).
        if url.starts_with("http://") || url.starts_with("https://") {
            StreamSource {
                url: url.clone(),
                quality: Quality::High,
                format: guess_extension_from_url(None, &url),
                headers: None,
                expires_at: None,
            }
        } else {
            return Err(format!("Invalid direct URL for '{}'", track.title));
        }
    } else {
        return Err(format!("No stream source available for '{}'", track.title));
    };

    // 4. Check for cancellation again before mutating the task (avoids a race
    //    where the user cancelled while the plugin call was in flight).
    {
        let guard = task.lock().map_err(|_| "Task mutex poisoned".to_string())?;
        if guard.cancel_requested.load(Ordering::Acquire) {
            return Err("Task was cancelled during stream resolution".to_string());
        }
    }

    // 5. Persist the resolved stream and derive file name / target path if not set.
    {
        let mut guard = task.lock().map_err(|_| "Task mutex poisoned".to_string())?;
        guard.persisted.selected_stream = Some(stream.clone());

        if guard.persisted.file_name.is_empty() || guard.persisted.target_path.is_empty() {
            let ext = guess_extension_from_url(
                Some(&stream.format),
                &stream.url,
            );
            let file_name = build_download_file_name(&guard.persisted.track, &ext);
            let target_path = Path::new(&guard.persisted.download_dir)
                .join(&file_name)
                .to_string_lossy()
                .into_owned();
            guard.persisted.file_name = file_name;
            guard.persisted.target_path = target_path;
        }
    }

    Ok(stream)
}

