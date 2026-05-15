//! Plugin Manager - Event-Driven Architecture
//!
//! Single source of truth for plugin state. All state changes emit events
//! via StreamSink to Dart for UI updates and persistence.
//!
//! # FIX M-02: get_loaded_plugins() no longer calls block_on
//!
//! The plugin registry now uses `std::sync::RwLock` for the outer map
//! (plugin ID → Arc<tokio::sync::Mutex<Plugin>>). This means:
//!   - `get_loaded_plugins()` can be a plain sync read without `block_on`.
//!   - `is_plugin_loaded()` and other queries that only need to look up the
//!     map key are also sync.
//!   - Per-plugin WASM execution still uses `tokio::sync::Mutex` because WASM
//!     calls must be serialized per plugin instance (waclay Store is not Send).

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
use tokio::sync::Mutex;

// ── Storage key ──────────────────────────────────────────────────────────────

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

// ── Plugin Manager ───────────────────────────────────────────────────────────

#[derive(Clone)]
#[flutter_rust_bridge::frb(opaque)]
pub struct PluginManager {
    /// FIX M-02: Outer map uses std::sync::RwLock so get_loaded_plugins() and
    /// is_plugin_loaded() are non-blocking sync reads — no block_on needed.
    /// Per-plugin execution still uses tokio::sync::Mutex to serialize WASM calls.
    plugins: Arc<std::sync::RwLock<HashMap<String, Arc<Mutex<Box<dyn Plugin>>>>>>,

    /// In-memory plugin storage (std::sync::RwLock — sync-safe for WASM host fns)
    storage: Arc<std::sync::RwLock<HashMap<StorageKey, String>>>,

    /// Event sink for Dart (held forever after init)
    event_sink: Arc<std::sync::Mutex<Option<StreamSink<PluginManagerEvent>>>>,

    /// Events produced before sink initialization.
    pending_events: Arc<std::sync::Mutex<Vec<PluginManagerEvent>>>,

    /// Plugins directory path
    pub plugins_dir: String,

    /// Tokio runtime handle for async operations
    runtime_handle: Handle,
}

impl PluginManager {
    const MAX_PENDING_EVENTS: usize = 1024;

    // ── Initialization ───────────────────────────────────────────────────────

    pub async fn new(plugins_dir: String) -> Self {
        let storage: Arc<std::sync::RwLock<HashMap<StorageKey, String>>> =
            Arc::new(std::sync::RwLock::new(HashMap::new()));
        let event_sink: Arc<std::sync::Mutex<Option<StreamSink<PluginManagerEvent>>>> =
            Arc::new(std::sync::Mutex::new(None));
        let pending_events: Arc<std::sync::Mutex<Vec<PluginManagerEvent>>> =
            Arc::new(std::sync::Mutex::new(Vec::new()));
        let runtime_handle = Handle::current();

        // Initialise global storage manager callbacks
        let storage_clone = storage.clone();
        let sink_clone = event_sink.clone();

        let set_fn = move |plugin_id: &str, key: &str, value: &str| -> bool {
            let pid = plugin_id.to_string();
            let k = key.to_string();
            let v = value.to_string();
            let storage_key = StorageKey::new(&pid, &k);

            if let Ok(mut guard) = storage_clone.write() {
                guard.insert(storage_key, v.clone());
            }

            if let Ok(guard) = sink_clone.lock() {
                if let Some(sink) = guard.as_ref() {
                    let _ = sink.add(PluginManagerEvent::storage_set(pid, k, v));
                }
            }
            true
        };

        let storage_clone = storage.clone();
        let get_fn = move |plugin_id: &str, key: &str| -> Option<String> {
            let storage_key = StorageKey::new(plugin_id, key);
            if let Ok(guard) = storage_clone.read() {
                guard.get(&storage_key).cloned()
            } else {
                None
            }
        };

        crate::api::plugin::storage::init_storage_manager(set_fn, get_fn).await;

        Self {
            plugins: Arc::new(std::sync::RwLock::new(HashMap::new())),
            storage,
            event_sink,
            pending_events,
            plugins_dir,
            runtime_handle,
        }
    }

    pub async fn init_event_stream(&self, sink: StreamSink<PluginManagerEvent>) {
        if let Ok(mut guard) = self.event_sink.lock() {
            *guard = Some(sink);
        }
        let queued_events: Vec<PluginManagerEvent> =
            if let Ok(mut pending) = self.pending_events.lock() {
                pending.drain(..).collect()
            } else {
                Vec::new()
            };
        for event in queued_events {
            self.emit(event).await;
        }
        self.emit(PluginManagerEvent::ManagerInitialized).await;
    }

    // ── Event emission ───────────────────────────────────────────────────────

    async fn emit(&self, event: PluginManagerEvent) {
        if let Ok(guard) = self.event_sink.lock() {
            if let Some(sink) = guard.as_ref() {
                let _ = sink.add(event);
                return;
            }
        }

        if let Ok(mut pending) = self.pending_events.lock() {
            if pending.len() >= Self::MAX_PENDING_EVENTS {
                // Drop oldest storage events preferentially to preserve lifecycle events.
                if let Some(pos) = pending.iter().position(|e| {
                    matches!(e, PluginManagerEvent::StorageSet { .. })
                }) {
                    pending.remove(pos);
                } else {
                    pending.remove(0);
                }
            }
            pending.push(event);
        }
    }

    // ── Plugin loading ───────────────────────────────────────────────────────

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

        // FIX M-02: Use std::sync::RwLock read — no block_on needed.
        if self
            .plugins
            .read()
            .map(|p| p.contains_key(plugin_id))
            .unwrap_or(false)
        {
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

        match self.do_load_plugin(plugin_id, plugin_type.clone(), plugin_path).await {
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

    async fn do_load_plugin(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
        plugin_path: &str,
    ) -> Result<(), String> {
        let plugin = load_plugin_with_registrar(plugin_id, plugin_type, plugin_path)
            .await
            .map_err(|e| format!("Failed to load '{}': {:?}", plugin_id, e))?;

        // FIX M-02: Write lock is std::sync — no async needed.
        if let Ok(mut plugins) = self.plugins.write() {
            if !plugins.contains_key(plugin_id) {
                plugins.insert(plugin_id.to_string(), Arc::new(Mutex::new(plugin)));
            }
        }
        Ok(())
    }

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

    pub async fn load_plugin_from_path(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
        plugin_path: &str,
    ) -> Result<(), String> {
        self.load_plugin_from_resolved_path(plugin_id, plugin_type, plugin_path)
            .await
    }

    // ── Plugin unloading ─────────────────────────────────────────────────────

    pub async fn unload_plugin(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
    ) -> Result<(), String> {
        self.emit(PluginManagerEvent::unloading(plugin_id)).await;

        // Get arc from registry (std RwLock, sync read)
        let plugin_arc = self
            .plugins
            .read()
            .ok()
            .and_then(|p| p.get(plugin_id).cloned());

        match plugin_arc {
            Some(arc) => {
                // Verify type (async lock on the individual plugin)
                if arc.lock().await.get_plugin_type() != plugin_type {
                    let msg = format!("Plugin '{}' type mismatch", plugin_id);
                    self.emit(PluginManagerEvent::unload_failed(plugin_id, &msg))
                        .await;
                    return Err(msg);
                }

                // Remove from registry (std RwLock, sync write)
                if let Ok(mut plugins) = self.plugins.write() {
                    plugins.remove(plugin_id);
                }
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

    pub async fn unload_plugin_by_id(
        &self,
        plugin_id: &str,
        plugin_type: PluginType,
    ) -> Result<(), String> {
        self.unload_plugin(plugin_id, plugin_type).await
    }

    // ── Plugin queries ───────────────────────────────────────────────────────

    /// FIX M-02: is_plugin_loaded is now a fully async function that only
    /// acquires the std RwLock for the map lookup, then the tokio Mutex for
    /// type verification. No block_on involved.
    pub async fn is_plugin_loaded(&self, plugin_id: &str, plugin_type: PluginType) -> bool {
        let plugin_arc = self
            .plugins
            .read()
            .ok()
            .and_then(|p| p.get(plugin_id).cloned());
        match plugin_arc {
            Some(arc) => arc.lock().await.get_plugin_type() == plugin_type,
            None => false,
        }
    }

    pub async fn is_plugin_loaded_by_id(&self, plugin_id: &str, plugin_type: PluginType) -> bool {
        self.is_plugin_loaded(plugin_id, plugin_type).await
    }

    /// FIX M-02: No longer uses block_on — uses std::sync::RwLock directly.
    pub fn get_loaded_plugins(&self) -> Vec<String> {
        self.plugins
            .read()
            .map(|p| p.keys().cloned().collect())
            .unwrap_or_default()
    }

    pub async fn get_available_plugins(&self) -> Vec<PluginInfo> {
        self.get_available_plugins_internal().await
    }

    async fn get_available_plugins_internal(&self) -> Vec<PluginInfo> {
        scan_plugins_directory(self.plugins_dir.clone()).await
    }

    pub async fn refresh_available_plugins(&self) {
        let plugins = scan_plugins_directory(self.plugins_dir.clone()).await;
        self.emit(PluginManagerEvent::PluginListRefreshed { plugins })
            .await;
    }

    // ── Storage ──────────────────────────────────────────────────────────────

    pub async fn storage_set(&self, plugin_id: &str, key: &str, value: &str) -> bool {
        let storage_key = StorageKey::new(plugin_id, key);

        if let Ok(mut guard) = self.storage.write() {
            guard.insert(storage_key, value.to_string());
        }

        self.emit(PluginManagerEvent::storage_set(plugin_id, key, value))
            .await;

        true
    }

    pub async fn storage_get(&self, plugin_id: &str, key: &str) -> Option<String> {
        let storage_key = StorageKey::new(plugin_id, key);
        if let Ok(guard) = self.storage.read() {
            guard.get(&storage_key).cloned()
        } else {
            None
        }
    }

    pub async fn storage_delete(&self, plugin_id: &str, key: &str) -> bool {
        let storage_key = StorageKey::new(plugin_id, key);

        let existed = if let Ok(mut guard) = self.storage.write() {
            guard.remove(&storage_key).is_some()
        } else {
            false
        };

        if existed {
            self.emit(PluginManagerEvent::storage_deleted(plugin_id, key))
                .await;
        }

        existed
    }

    pub async fn storage_clear(&self, plugin_id: &str) {
        if let Ok(mut guard) = self.storage.write() {
            guard.retain(|k, _| k.plugin_id != plugin_id);
        }

        self.emit(PluginManagerEvent::StorageCleared {
            plugin_id: plugin_id.to_string(),
        })
        .await;
    }

    pub async fn storage_preload(&self, plugin_id: &str, key: &str, value: &str) {
        let storage_key = StorageKey::new(plugin_id, key);
        if let Ok(mut guard) = self.storage.write() {
            guard.insert(storage_key, value.to_string());
        }
    }

    // ── Request handling ─────────────────────────────────────────────────────

    /// Handle a typed request to a plugin.
    ///
    /// Uses spawn_blocking to run the synchronous WASM execution off the async
    /// executor. The per-plugin tokio Mutex is locked inside the blocking task
    /// using the runtime handle's block_on — this is correct because we're
    /// already inside spawn_blocking (a dedicated OS thread, not an async task).
    #[flutter_rust_bridge::frb(ignore)]
    pub async fn handle_plugin_request(
        &self,
        plugin_id: &str,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<crate::api::plugin::commands::PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;

        // FIX M-02: Map lookup uses std RwLock — instant, no block_on.
        let plugin_arc = self
            .plugins
            .read()
            .map_err(|_| PluginError::WasmExecutionError("Plugin registry lock poisoned".to_string()))?
            .get(plugin_id)
            .cloned()
            .ok_or_else(|| PluginError::PluginNotFound(plugin_id.to_string()))?;

        let handle = self.runtime_handle.clone();

        tokio::task::spawn_blocking(move || {
            // Lock the individual plugin's tokio Mutex via block_on.
            // This is safe: we're on a blocking thread (spawn_blocking), so
            // block_on will not deadlock the main tokio runtime.
            let mut plugin = handle.block_on(plugin_arc.lock());

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

    // ── Shutdown ─────────────────────────────────────────────────────────────

    pub async fn shutdown(&self) {
        // Collect loaded IDs first using std RwLock
        let loaded_ids: Vec<String> = self
            .plugins
            .read()
            .map(|p| p.keys().cloned().collect())
            .unwrap_or_default();

        // Clear registry
        if let Ok(mut plugins) = self.plugins.write() {
            plugins.clear();
        }

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