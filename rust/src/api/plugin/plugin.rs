//! Plugin Manager - Event-Driven Architecture
//!
//! Single source of truth for plugin state. All state changes emit events
//! via StreamSink to Dart for UI updates and persistence.

use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::events::PluginManagerEvent;
use crate::api::plugin::plugin_discovery::scan_plugins_directory;
use crate::api::plugin::plugin_info::PluginInfo;
use crate::api::plugin::registrar::load_plugin_with_registrar;
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::PluginType;
use crate::frb_generated::StreamSink;

use std::collections::HashMap;
use std::sync::Arc;
use tokio::runtime::Handle;
use tokio::sync::{Mutex, RwLock};

// ============================================================================
// STORAGE KEY
// ============================================================================

/// Key for in-memory storage (plugin_id + key)
#[derive(Clone, Debug, Hash, Eq, PartialEq)]
pub struct StorageKey {
    pub plugin_id: String,
    pub key: String,
}

impl StorageKey {
    pub fn new(plugin_id: impl Into<String>, key: impl Into<String>) -> Self {
        Self {
            plugin_id: plugin_id.into(),
            key: key.into(),
        }
    }
}

// ============================================================================
// PLUGIN MANAGER
// ============================================================================

#[derive(Clone)]
#[flutter_rust_bridge::frb(opaque)]
pub struct PluginManager {
    /// Thread-safe plugin registry (tokio RwLock - async-safe)
    plugins: Arc<RwLock<HashMap<String, Arc<Mutex<Box<dyn Plugin>>>>>>,

    /// Thread-safe in-memory storage (std::sync::RwLock - sync-safe for WASM)
    storage: Arc<std::sync::RwLock<HashMap<StorageKey, String>>>,

    /// Event sink for Dart (held forever after init)
    event_sink: Arc<std::sync::Mutex<Option<StreamSink<PluginManagerEvent>>>>,

    /// Events produced before sink initialization.
    pending_events: Arc<std::sync::Mutex<Vec<PluginManagerEvent>>>,

    /// Plugins directory path
    pub plugins_dir: String,

    /// Tokio runtime handle for blocking operations
    runtime_handle: Handle,
}

impl PluginManager {
    const MAX_PENDING_EVENTS: usize = 1024;

    // ========================================================================
    // INITIALIZATION
    // ========================================================================

    /// Create a new PluginManager (call from bridge)
    pub async fn new(plugins_dir: String) -> Self {
        let storage: Arc<std::sync::RwLock<HashMap<StorageKey, String>>> =
            Arc::new(std::sync::RwLock::new(HashMap::new()));
        let event_sink: Arc<std::sync::Mutex<Option<StreamSink<PluginManagerEvent>>>> =
            Arc::new(std::sync::Mutex::new(None));
        let pending_events: Arc<std::sync::Mutex<Vec<PluginManagerEvent>>> =
            Arc::new(std::sync::Mutex::new(Vec::new()));
        let runtime_handle = Handle::current();

        // --- Initialize Global Storage Manager ---
        let storage_clone = storage.clone();
        let sink_clone = event_sink.clone();

        let set_fn = move |plugin_id: &str, key: &str, value: &str| -> bool {
            let pid = plugin_id.to_string();
            let k = key.to_string();
            let v = value.to_string();
            let storage_key = StorageKey::new(&pid, &k);

            // 1. Sync Lock Storage
            if let Ok(mut guard) = storage_clone.write() {
                guard.insert(storage_key, v.clone());
            }

            // 2. Sync Lock Sink & Emit
            if let Ok(guard) = sink_clone.lock() {
                if let Some(sink) = guard.as_ref() {
                    let _ = sink.add(PluginManagerEvent::storage_set(pid, k, v));
                }
            }
            true
        };

        let storage_clone = storage.clone();
        let get_fn = move |plugin_id: &str, key: &str| -> Option<String> {
            let pid = plugin_id.to_string();
            let k = key.to_string();
            let storage_key = StorageKey::new(&pid, &k);

            if let Ok(guard) = storage_clone.read() {
                guard.get(&storage_key).cloned()
            } else {
                None
            }
        };

        crate::api::plugin::storage::init_storage_manager(set_fn, get_fn).await;

        Self {
            plugins: Arc::new(RwLock::new(HashMap::new())),
            storage,
            event_sink,
            pending_events,
            plugins_dir,
            runtime_handle,
        }
    }

    /// Initialize the event stream from Dart.
    /// Call this ONCE after creating the manager.
    /// The sink is held forever and used for all event emissions.
    pub async fn init_event_stream(&self, sink: StreamSink<PluginManagerEvent>) {
        if let Ok(mut guard) = self.event_sink.lock() {
            *guard = Some(sink);
        }
        let queued_events: Vec<PluginManagerEvent> = if let Ok(mut pending) = self.pending_events.lock() {
            pending.drain(..).collect()
        } else {
            Vec::new()
        };
        for event in queued_events {
            self.emit(event).await;
        }
        self.emit(PluginManagerEvent::ManagerInitialized).await;
    }

    // ========================================================================
    // EVENT EMISSION
    // ========================================================================

    /// Emit an event to Dart (non-blocking)
    async fn emit(&self, event: PluginManagerEvent) {
        if let Ok(guard) = self.event_sink.lock() {
            if let Some(sink) = guard.as_ref() {
                let _ = sink.add(event); // Ignore result - fire and forget
                return;
            }
        }

        if let Ok(mut pending) = self.pending_events.lock() {
            if pending.len() >= Self::MAX_PENDING_EVENTS {
                let _ = pending.remove(0);
            }
            pending.push(event);
        }
    }

    // ========================================================================
    // PLUGIN LOADING
    // ========================================================================

    /// Load a plugin by ID with event emission
    pub async fn load_plugin(&self, plugin_info: &PluginInfo) -> Result<(), String> {
        let plugin_id = plugin_info.id();
        let plugin_path = plugin_info.wasm_path();
        let plugin_type = plugin_info.plugin_type.clone();

        self.load_plugin_from_resolved_path(plugin_id, plugin_type, &plugin_path)
            .await
    }

    async fn load_plugin_from_resolved_path(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
        plugin_path: &str,
    ) -> Result<(), String> {
        self.emit(PluginManagerEvent::loading(plugin_id)).await;

        if self.plugins.read().await.contains_key(plugin_id) {
            let msg = format!("Plugin '{}' is already loaded", plugin_id);
            self.emit(PluginManagerEvent::load_failed(plugin_id, &msg))
                .await;
            return Err(msg);
        }

        if !std::path::Path::new(plugin_path).exists() {
            let msg = format!("Plugin file not found: {}", plugin_path);
            self.emit(PluginManagerEvent::load_failed(plugin_id, &msg))
                .await;
            return Err(msg);
        }

        match self
            .do_load_plugin(plugin_id, plugin_type.clone(), &plugin_path)
            .await
        {
            Ok(()) => {
                self.emit(PluginManagerEvent::loaded(plugin_id, plugin_type))
                    .await;
                Ok(())
            }
            Err(e) => {
                self.emit(PluginManagerEvent::load_failed(plugin_id, &e))
                    .await;
                Err(e)
            }
        }
    }

    /// Internal: Load plugin from path (no events emitted)
    async fn do_load_plugin(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
        plugin_path: &str,
    ) -> Result<(), String> {
        let plugin = load_plugin_with_registrar(plugin_id, plugin_type, plugin_path)
            .await
            .map_err(|e| format!("Failed to load '{}': {:?}", plugin_id, e))?;

        let mut plugins = self.plugins.write().await;
        if !plugins.contains_key(plugin_id) {
            plugins.insert(plugin_id.to_string(), Arc::new(Mutex::new(plugin)));
        }
        Ok(())
    }

    /// Load a plugin by ID (looks up from available plugins)
    pub async fn load_plugin_by_id(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
    ) -> Result<(), String> {
        let available = self.get_available_plugins_internal().await;
        let plugin_info = available
            .iter()
            .find(|p| p.id() == plugin_id && p.plugin_type == plugin_type);

        match plugin_info {
            Some(info) => {
                let plugin_path = info.wasm_path();
                self.load_plugin_from_resolved_path(plugin_id, plugin_type, &plugin_path)
                    .await
            }
            None => {
                let msg = format!("Plugin '{}' ({:?}) not found", plugin_id, plugin_type);
                self.emit(PluginManagerEvent::load_failed(plugin_id, &msg))
                    .await;
                Err(msg)
            }
        }
    }

    /// Load plugin from an explicit path (for install-then-load flow)
    pub async fn load_plugin_from_path(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
        plugin_path: &str,
    ) -> Result<(), String> {
        self.load_plugin_from_resolved_path(plugin_id, plugin_type, plugin_path)
            .await
    }

    // ========================================================================
    // PLUGIN UNLOADING
    // ========================================================================

    /// Unload a plugin with event emission
    pub async fn unload_plugin(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
    ) -> Result<(), String> {
        // Emit: Unloading started
        self.emit(PluginManagerEvent::unloading(plugin_id)).await;

        // Check if plugin exists and types match
        let plugin_arc = {
            let plugins = self.plugins.read().await;
            plugins.get(plugin_id).cloned()
        };

        match plugin_arc {
            Some(arc) => {
                // Verify type
                if arc.lock().await.get_plugin_type() != plugin_type {
                    let msg = format!("Plugin '{}' type mismatch", plugin_id);
                    self.emit(PluginManagerEvent::unload_failed(plugin_id, &msg))
                        .await;
                    return Err(msg);
                }

                // Remove from registry
                self.plugins.write().await.remove(plugin_id);
                self.emit(PluginManagerEvent::unloaded(plugin_id)).await;
                Ok(())
            }
            None => {
                let msg = format!("Plugin '{}' is not loaded", plugin_id);
                self.emit(PluginManagerEvent::unload_failed(plugin_id, &msg))
                    .await;
                Err(msg)
            }
        }
    }

    /// Alias for unload_plugin (API compatibility)
    pub async fn unload_plugin_by_id(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
    ) -> Result<(), String> {
        self.unload_plugin(plugin_id, plugin_type).await
    }

    // ========================================================================
    // PLUGIN QUERIES
    // ========================================================================

    /// Check if a plugin is loaded
    pub async fn is_plugin_loaded(&self, plugin_id: &str, plugin_type: PluginType) -> bool {
        let plugin_arc = self.plugins.read().await.get(plugin_id).cloned();
        match plugin_arc {
            Some(arc) => arc.lock().await.get_plugin_type() == plugin_type,
            None => false,
        }
    }

    /// Alias for is_plugin_loaded (API compatibility)
    pub async fn is_plugin_loaded_by_id(&self, plugin_id: &str, plugin_type: PluginType) -> bool {
        self.is_plugin_loaded(plugin_id, plugin_type).await
    }

    /// Get list of loaded plugin IDs
    pub fn get_loaded_plugins(&self) -> Vec<String> {
        // Use blocking approach for sync API
        let plugins = self.runtime_handle.block_on(self.plugins.read());
        plugins.keys().cloned().collect()
    }

    /// Get available plugins (scanned from directory)
    pub async fn get_available_plugins(&self) -> Vec<PluginInfo> {
        self.get_available_plugins_internal().await
    }

    /// Internal: Get available plugins without emitting events
    async fn get_available_plugins_internal(&self) -> Vec<PluginInfo> {
        scan_plugins_directory(self.plugins_dir.clone()).await
    }

    /// Refresh available plugins and emit event
    pub async fn refresh_available_plugins(&self) {
        let plugins = scan_plugins_directory(self.plugins_dir.clone()).await;
        self.emit(PluginManagerEvent::PluginListRefreshed { plugins })
            .await;
    }

    // ========================================================================
    // STORAGE (In-Memory with Event Emission)
    // ========================================================================

    /// Set a storage value (instant in-memory, emits event for Dart persistence)
    pub async fn storage_set(&self, plugin_id: &str, key: &str, value: &str) -> bool {
        let storage_key = StorageKey::new(plugin_id, key);

        // 1. Instant in-memory write
        if let Ok(mut guard) = self.storage.write() {
            guard.insert(storage_key, value.to_string());
        }

        // 2. Emit event for Dart to persist asynchronously
        self.emit(PluginManagerEvent::storage_set(plugin_id, key, value))
            .await;

        true
    }

    /// Get a storage value (instant in-memory read)
    pub async fn storage_get(&self, plugin_id: &str, key: &str) -> Option<String> {
        let storage_key = StorageKey::new(plugin_id, key);
        if let Ok(guard) = self.storage.read() {
            guard.get(&storage_key).cloned()
        } else {
            None
        }
    }

    /// Delete a storage value
    pub async fn storage_delete(&self, plugin_id: &str, key: &str) -> bool {
        let storage_key = StorageKey::new(plugin_id, key);

        // 1. Remove from in-memory
        let existed = if let Ok(mut guard) = self.storage.write() {
            guard.remove(&storage_key).is_some()
        } else {
            false
        };

        // 2. Emit event for Dart
        if existed {
            self.emit(PluginManagerEvent::storage_deleted(plugin_id, key))
                .await;
        }

        existed
    }

    /// Clear all storage for a plugin
    pub async fn storage_clear(&self, plugin_id: &str) {
        // Remove all entries for this plugin
        if let Ok(mut guard) = self.storage.write() {
            guard.retain(|k, _| k.plugin_id != plugin_id);
        }

        // Emit event
        self.emit(PluginManagerEvent::StorageCleared {
            plugin_id: plugin_id.to_string(),
        })
        .await;
    }

    /// Preload a storage value from Dart (startup sync, no event emitted)
    pub async fn storage_preload(&self, plugin_id: &str, key: &str, value: &str) {
        let storage_key = StorageKey::new(plugin_id, key);
        if let Ok(mut guard) = self.storage.write() {
            guard.insert(storage_key, value.to_string());
        }
    }

    // ========================================================================
    // PLUGIN REQUEST HANDLING
    // ========================================================================

    /// Handle a typed request to a plugin
    #[flutter_rust_bridge::frb(ignore)]
    pub async fn handle_plugin_request(
        &self,
        plugin_id: &str,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<crate::api::plugin::commands::PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;

        let plugin_arc = self
            .plugins
            .read()
            .await
            .get(plugin_id)
            .cloned()
            .ok_or_else(|| PluginError::PluginNotFound(plugin_id.to_string()))?;

        let handle = self.runtime_handle.clone();

        tokio::task::spawn_blocking(move || {
            let mut plugin = handle.block_on(plugin_arc.lock());

            // Validate plugin type matches request type
            let expected_type = match &request {
                PluginRequest::ContentResolver(_) => PluginType::ContentResolver,
                PluginRequest::ChartProvider(_) => PluginType::ChartProvider,
                PluginRequest::LyricsProvider(_) => PluginType::LyricsProvider,
                PluginRequest::SearchSuggestionProvider(_) => {
                    PluginType::SearchSuggestionProvider
                }
                PluginRequest::ContentImporter(_) => PluginType::ContentImporter,
            };

            if plugin.get_plugin_type() != expected_type {
                return Err(PluginError::InvalidConfiguration(format!(
                    "Plugin '{}' type {:?} doesn't match request type {:?}",
                    plugin.get_name(),
                    plugin.get_plugin_type(),
                    expected_type
                )));
            }

            plugin.handle_request(request)
        })
        .await
        .map_err(|e| PluginError::WasmExecutionError(format!("Join error: {}", e)))?
    }

    /// Gracefully shutdown manager-owned state.
    pub async fn shutdown(&self) {
        let loaded_ids: Vec<String> = {
            let plugins = self.plugins.read().await;
            plugins.keys().cloned().collect()
        };

        self.plugins.write().await.clear();

        for plugin_id in loaded_ids {
            self.emit(PluginManagerEvent::unloaded(plugin_id)).await;
        }

        if let Ok(mut pending) = self.pending_events.lock() {
            pending.clear();
        }
        if let Ok(mut sink) = self.event_sink.lock() {
            *sink = None;
        }
    }
}
