use crate::api::plugin::events::PluginManagerEvent;
use crate::api::plugin::errors::PluginError;
use crate::api::plugin::plugin::PluginManager;
use crate::api::plugin::plugin_info::PluginInfo;
use crate::api::plugin::types::{PluginInstallResult, PluginType};
use crate::api::downloader::{
    DownloadManager, DownloadManagerEvent, DownloadTaskSnapshot, EnqueueDownloadRequest,
};
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::frb;

fn encode_plugin_error(error: PluginError) -> String {
    format!("PLUGIN_ERROR::{:?}::{}", error, error)
}

#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// Initialize the plugin event stream from Dart.
/// Call this ONCE after creating the PluginManager.
/// Dart will receive Stream<PluginManagerEvent> for UI updates and persistence.
#[frb]
pub async fn init_plugin_event_stream(
    manager: &PluginManager,
    sink: StreamSink<PluginManagerEvent>,
) {
    manager.init_event_stream(sink).await;
}

#[frb]
pub async fn create_download_manager(
    plugin_manager: &PluginManager,
    state_dir: String,
    temp_dir: String,
    max_concurrent_tasks: u32,
) -> Result<DownloadManager, String> {
    DownloadManager::new(
        plugin_manager.clone(),
        state_dir,
        temp_dir,
        max_concurrent_tasks,
    )
    .await
}

#[frb]
pub async fn init_download_event_stream(
    manager: &DownloadManager,
    sink: StreamSink<DownloadManagerEvent>,
) {
    manager.init_event_stream(sink).await;
}

#[frb]
pub async fn restore_download_tasks(
    manager: &DownloadManager,
) -> Result<Vec<DownloadTaskSnapshot>, String> {
    manager.restore_tasks().await
}

#[frb]
pub async fn enqueue_download_task(
    manager: &DownloadManager,
    request: EnqueueDownloadRequest,
) -> Result<String, String> {
    manager.enqueue(request).await
}

#[frb]
pub fn get_download_task_snapshots(manager: &DownloadManager) -> Vec<DownloadTaskSnapshot> {
    manager.get_snapshots()
}

#[frb]
pub async fn pause_download_task(manager: &DownloadManager, task_id: String) -> bool {
    manager.pause_task(task_id).await
}

#[frb]
pub async fn resume_download_task(manager: &DownloadManager, task_id: String) -> bool {
    manager.resume_task(task_id).await
}

#[frb]
pub async fn cancel_download_task(
    manager: &DownloadManager,
    task_id: String,
    delete_partial: bool,
) -> bool {
    manager.cancel_task(task_id, delete_partial).await
}

#[frb]
pub async fn acknowledge_download_persisted(
    manager: &DownloadManager,
    task_id: String,
) -> bool {
    manager.acknowledge_persisted(task_id).await
}

// ============================================================================
// STORAGE FUNCTIONS (In-Memory with Event Emission)
// ============================================================================

/// Set a storage value for a plugin (instant in-memory, emits event for Dart)
#[frb]
pub async fn plugin_storage_set(
    manager: &PluginManager,
    plugin_id: String,
    key: String,
    value: String,
) -> bool {
    manager.storage_set(&plugin_id, &key, &value).await
}

/// Get a storage value for a plugin (instant in-memory read)
#[frb]
pub async fn plugin_storage_get(
    manager: &PluginManager,
    plugin_id: String,
    key: String,
) -> Option<String> {
    manager.storage_get(&plugin_id, &key).await
}

/// Preload a storage value from Dart (startup sync, no event emitted)
#[frb]
pub async fn plugin_storage_preload(
    manager: &PluginManager,
    plugin_id: String,
    key: String,
    value: String,
) {
    manager.storage_preload(&plugin_id, &key, &value).await
}

/// Clear all storage for a plugin
#[frb]
pub async fn plugin_storage_clear(manager: &PluginManager, plugin_id: String) {
    manager.storage_clear(&plugin_id).await
}

#[frb]
pub async fn create_plugin_manager(plugins_dir: String) -> PluginManager {
    PluginManager::new(plugins_dir).await
}

#[frb(sync)]
pub fn get_loaded_plugins(manager: &PluginManager) -> Vec<String> {
    manager.get_loaded_plugins()
}

#[frb]
pub async fn get_available_plugins(manager: &PluginManager) -> Vec<PluginInfo> {
    manager.get_available_plugins().await
}

#[frb]
pub async fn refresh_available_plugins(manager: &PluginManager) {
    manager.refresh_available_plugins().await;
}

#[frb]
pub async fn get_plugin_info(
    manager: &PluginManager,
    plugin_id: String,
    plugin_type: PluginType,
) -> Option<PluginInfo> {
    let available_plugins = manager.get_available_plugins().await;
    available_plugins
        .into_iter()
        .find(|p| p.id() == plugin_id && p.plugin_type == plugin_type)
}

#[frb]
pub async fn load_plugin(
    manager: &PluginManager,
    plugin_id: String,
    plugin_type: PluginType,
) -> Result<(), String> {
    manager.load_plugin_by_id(&plugin_id, plugin_type).await
}

#[frb]
pub async fn unload_plugin(
    manager: &PluginManager,
    plugin_id: String,
    plugin_type: PluginType,
) -> Result<(), String> {
    manager.unload_plugin_by_id(&plugin_id, plugin_type).await
}

#[frb]
pub async fn is_plugin_loaded(
    manager: &PluginManager,
    plugin_id: String,
    plugin_type: PluginType,
) -> bool {
    manager
        .is_plugin_loaded_by_id(&plugin_id, plugin_type)
        .await
}

/// NEW: Typed request/response plugin calling (MUCH faster than call_plugin)
/// This avoids JSON serialization/deserialization overhead
/// Prefer this over call_plugin for production use
#[frb]
pub async fn handle_plugin_request(
    manager: &PluginManager,
    plugin_id: String,
    request: crate::api::plugin::commands::PluginRequest,
) -> Result<crate::api::plugin::commands::PluginResponse, String> {
    manager
        .handle_plugin_request(&plugin_id, request)
        .await
        .map_err(encode_plugin_error)
}

#[frb]
pub async fn install_packed_plugin(
    packed_file_path: String,
    plugins_dir: String,
    temp_dir: String,
    should_load: bool,
    policy_country_code: String,
    manager: &PluginManager,
) -> Result<PluginInstallResult, String> {
    let manager_ref = if should_load { Some(manager) } else { None };
    match crate::api::plugin::plugin_unpacker::install_packed_plugin(
        &packed_file_path,
        &plugins_dir,
        &temp_dir,
        should_load,
        &policy_country_code,
        manager_ref,
    )
    .await
    {
        Ok(result) => Ok(result),
        Err(e) => Err(format!("Failed to install packed plugin: {}", e)),
    }
}

#[frb]
pub fn scan_bex_files(directory: String) -> Result<Vec<String>, String> {
    crate::api::plugin::plugin_unpacker::scan_bex_files(&directory)
        .map_err(|e| format!("Failed to scan directory: {}", e))
}

/// Inspect a packed plugin (.bex) file and return its manifest without installing.
/// This is used for pre-install security checks (e.g., impersonation detection).
/// Returns the manifest and cleans up the temporary files.
#[frb]
pub async fn inspect_packed_plugin(
    packed_file_path: String,
    temp_dir: String,
) -> Result<crate::api::plugin::manifest::Manifest, String> {
    match crate::api::plugin::plugin_unpacker::unpack_and_read_manifest(
        &packed_file_path,
        &temp_dir,
    )
    .await
    {
        Ok((manifest, temp_plugin_dir)) => {
            let _ = tokio::fs::remove_dir_all(&temp_plugin_dir).await;
            Ok(manifest)
        }
        Err(e) => Err(format!("Failed to inspect packed plugin: {}", e)),
    }
}

#[frb]
pub fn get_plugins_dir(manager: &PluginManager) -> String {
    manager.plugins_dir.clone()
}

#[frb]
pub async fn shutdown_plugin_manager(manager: &PluginManager) {
    manager.shutdown().await;
}

pub struct MetadataResult {
    pub filename: String,
    pub is_success: bool,
}

#[frb]
pub async fn get_filename_url(url: String) -> MetadataResult {
    match crate::utils::extract_filename(&url).await {
        Ok(name) => MetadataResult {
            filename: name,
            is_success: true,
        },
        Err(e) => {
            tracing::error!(error = %e, "Error extracting filename");
            MetadataResult {
                filename: String::new(),
                is_success: false,
            }
        }
    }
}
