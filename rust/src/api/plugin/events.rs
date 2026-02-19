//! Plugin Manager Event System
//!
//! This module defines all events emitted by the PluginManager.
//! Events flow through a single StreamSink to Dart for UI updates and persistence.

use crate::api::plugin::plugin_info::PluginInfo;
use crate::api::plugin::types::PluginType;

/// All events emitted by the PluginManager.
///
/// Dart listens to these via a single StreamSink and updates UI/persistence accordingly.
#[flutter_rust_bridge::frb]
#[derive(Clone, Debug)]
pub enum PluginManagerEvent {
    // ========================================================================
    // LIFECYCLE EVENTS
    // ========================================================================
    /// Plugin load started - UI should show spinner
    PluginLoading { id: String },

    /// Plugin successfully loaded
    PluginLoaded { id: String, plugin_type: PluginType },

    /// Plugin load failed
    PluginLoadFailed { id: String, error: String },

    /// Plugin unload started - UI should show spinner
    PluginUnloading { id: String },

    /// Plugin successfully unloaded
    PluginUnloaded { id: String },

    /// Plugin unload failed
    PluginUnloadFailed { id: String, error: String },

    // ========================================================================
    // INSTALLATION EVENTS
    // ========================================================================
    /// Plugin installation started - UI should show spinner
    PluginInstalling { id: String },

    /// Plugin successfully installed
    PluginInstalled { id: String },

    /// Plugin installation failed
    PluginInstallFailed { id: String, error: String },

    // ========================================================================
    // DELETION EVENTS
    // ========================================================================
    /// Plugin deletion started - UI should show spinner
    PluginDeleting { id: String },

    /// Plugin successfully deleted
    PluginDeleted { id: String },

    /// Plugin deletion failed
    PluginDeleteFailed { id: String, error: String },

    // ========================================================================
    // DISCOVERY EVENTS
    // ========================================================================
    /// Available plugins list refreshed
    PluginListRefreshed { plugins: Vec<PluginInfo> },

    // ========================================================================
    // STORAGE EVENTS (for async Dart persistence)
    // ========================================================================
    /// Plugin storage value set - Dart should persist to Isar
    StorageSet {
        plugin_id: String,
        key: String,
        value: String,
    },

    /// Plugin storage value deleted - Dart should remove from Isar
    StorageDeleted { plugin_id: String, key: String },

    /// All plugin storage cleared - Dart should remove all entries for plugin
    StorageCleared { plugin_id: String },

    // ========================================================================
    // SYSTEM EVENTS
    // ========================================================================
    /// Plugin manager initialized
    ManagerInitialized,

    /// General error (not tied to specific plugin operation)
    Error { message: String },
}

impl PluginManagerEvent {
    /// Helper to create a PluginLoading event
    pub fn loading(id: impl Into<String>) -> Self {
        Self::PluginLoading { id: id.into() }
    }

    /// Helper to create a PluginLoaded event
    pub fn loaded(id: impl Into<String>, plugin_type: PluginType) -> Self {
        Self::PluginLoaded {
            id: id.into(),
            plugin_type,
        }
    }

    /// Helper to create a PluginLoadFailed event
    pub fn load_failed(id: impl Into<String>, error: impl Into<String>) -> Self {
        Self::PluginLoadFailed {
            id: id.into(),
            error: error.into(),
        }
    }

    /// Helper to create a PluginUnloading event
    pub fn unloading(id: impl Into<String>) -> Self {
        Self::PluginUnloading { id: id.into() }
    }

    /// Helper to create a PluginUnloaded event
    pub fn unloaded(id: impl Into<String>) -> Self {
        Self::PluginUnloaded { id: id.into() }
    }

    /// Helper to create a PluginUnloadFailed event
    pub fn unload_failed(id: impl Into<String>, error: impl Into<String>) -> Self {
        Self::PluginUnloadFailed {
            id: id.into(),
            error: error.into(),
        }
    }

    /// Helper to create a PluginInstalling event
    pub fn installing(id: impl Into<String>) -> Self {
        Self::PluginInstalling { id: id.into() }
    }

    /// Helper to create a PluginInstalled event
    pub fn installed(id: impl Into<String>) -> Self {
        Self::PluginInstalled { id: id.into() }
    }

    /// Helper to create a PluginInstallFailed event
    pub fn install_failed(id: impl Into<String>, error: impl Into<String>) -> Self {
        Self::PluginInstallFailed {
            id: id.into(),
            error: error.into(),
        }
    }

    /// Helper to create a PluginDeleting event
    pub fn deleting(id: impl Into<String>) -> Self {
        Self::PluginDeleting { id: id.into() }
    }

    /// Helper to create a PluginDeleted event
    pub fn deleted(id: impl Into<String>) -> Self {
        Self::PluginDeleted { id: id.into() }
    }

    /// Helper to create a PluginDeleteFailed event
    pub fn delete_failed(id: impl Into<String>, error: impl Into<String>) -> Self {
        Self::PluginDeleteFailed {
            id: id.into(),
            error: error.into(),
        }
    }

    /// Helper to create a StorageSet event
    pub fn storage_set(
        plugin_id: impl Into<String>,
        key: impl Into<String>,
        value: impl Into<String>,
    ) -> Self {
        Self::StorageSet {
            plugin_id: plugin_id.into(),
            key: key.into(),
            value: value.into(),
        }
    }

    /// Helper to create a StorageDeleted event
    pub fn storage_deleted(plugin_id: impl Into<String>, key: impl Into<String>) -> Self {
        Self::StorageDeleted {
            plugin_id: plugin_id.into(),
            key: key.into(),
        }
    }
}
