//! Plugin Storage - Synchronous Access for WASM Host Functions
//!
//! This module provides synchronous storage access for WASM host functions.
//! Since WASM host functions are called synchronously, we need a way to access
//! the storage without blocking on async operations.
//!
//! Architecture:
//! - PluginManager holds the in-memory storage (Arc<RwLock<HashMap>>)
//! - This module provides a global reference to the manager for WASM host functions
//! - All storage operations are instant (in-memory) and emit events for Dart persistence

use std::sync::Arc;
use tokio::sync::RwLock;

/// Global reference to the plugin manager for storage access from WASM host functions
static STORAGE_MANAGER: once_cell::sync::Lazy<RwLock<Option<StorageManagerRef>>> =
    once_cell::sync::Lazy::new(|| RwLock::new(None));

/// Reference to the PluginManager storage functions
/// This is a lightweight reference that WASM host functions can use
#[flutter_rust_bridge::frb(ignore)]
pub struct StorageManagerRef {
    /// Callback to set storage value
    set_fn: Arc<dyn Fn(&str, &str, &str) -> bool + Send + Sync>,
    /// Callback to get storage value
    get_fn: Arc<dyn Fn(&str, &str) -> Option<String> + Send + Sync>,
}

/// Initialize the storage manager reference.
/// Called during PluginManager initialization.
#[flutter_rust_bridge::frb(ignore)]
pub async fn init_storage_manager<F, G>(set_fn: F, get_fn: G)
where
    F: Fn(&str, &str, &str) -> bool + Send + Sync + 'static,
    G: Fn(&str, &str) -> Option<String> + Send + Sync + 'static,
{
    let mut manager = STORAGE_MANAGER.write().await;
    *manager = Some(StorageManagerRef {
        set_fn: Arc::new(set_fn),
        get_fn: Arc::new(get_fn),
    });
}

/// Synchronous storage set for WASM host functions.
/// This is called from within WASM execution (synchronous context).
#[flutter_rust_bridge::frb(ignore)]
pub fn storage_set_sync(plugin_id: &str, key: &str, value: &str) -> bool {
    // Try to get the manager synchronously
    let manager_guard = match STORAGE_MANAGER.try_read() {
        Ok(guard) => guard,
        Err(_) => {
            tracing::error!("storage_set_sync: failed to acquire lock");
            return false;
        }
    };

    match manager_guard.as_ref() {
        Some(manager) => (manager.set_fn)(plugin_id, key, value),
        None => {
            tracing::error!("storage_set_sync: storage manager not initialized");
            false
        }
    }
}

/// Synchronous storage get for WASM host functions.
/// This is called from within WASM execution (synchronous context).
#[flutter_rust_bridge::frb(ignore)]
pub fn storage_get_sync(plugin_id: &str, key: &str) -> Option<String> {
    // Try to get the manager synchronously
    let manager_guard = match STORAGE_MANAGER.try_read() {
        Ok(guard) => guard,
        Err(_) => {
            tracing::error!("storage_get_sync: failed to acquire lock");
            return None;
        }
    };

    match manager_guard.as_ref() {
        Some(manager) => (manager.get_fn)(plugin_id, key),
        None => {
            tracing::error!("storage_get_sync: storage manager not initialized");
            None
        }
    }
}

/// Check if storage manager is initialized for legacy compatibility
#[flutter_rust_bridge::frb(ignore)]
pub fn is_storage_initialized() -> bool {
    match STORAGE_MANAGER.try_read() {
        Ok(guard) => guard.is_some(),
        Err(_) => false,
    }
}
