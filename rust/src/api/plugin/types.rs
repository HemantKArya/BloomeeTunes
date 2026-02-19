use crate::api::plugin::errors::PluginResult;
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::wasm_runtime::SharedWasmEngine;
use std::future::Future;

/// Plugin type enumeration
#[flutter_rust_bridge::frb]
#[derive(Clone, Copy, Debug, Hash, Eq, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum PluginType {
    ContentResolver,
    ChartProvider,
}

impl PluginType {
    pub fn type_string(&self) -> &'static str {
        match self {
            PluginType::ContentResolver => "content-resolver",
            PluginType::ChartProvider => "chart-provider",
        }
    }

    pub fn from_string(s: &str) -> Option<Self> {
        match s {
            "content-resolver" => Some(PluginType::ContentResolver),
            "chart-provider" => Some(PluginType::ChartProvider),
            _ => None,
        }
    }

    pub fn description(&self) -> &'static str {
        match self {
            PluginType::ContentResolver => "Content resolver (JioSaavn, etc.)",
            PluginType::ChartProvider => "Chart provider (Billboard, etc.)",
        }
    }
}

/// Trait that plugin adapters must implement for automatic registration
pub trait PluginAdapter: Plugin + Sized + Send + Sync + 'static {
    fn plugin_type() -> PluginType;

    fn create(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> impl Future<Output = PluginResult<Box<dyn Plugin>>> + Send;
}

/// Status of the plugin installation
#[flutter_rust_bridge::frb]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PluginInstallStatus {
    Installed,
    Updated,
    AlreadyInstalled,
    PluginLoaded,
    Failed,
}

/// Result of the plugin installation
#[flutter_rust_bridge::frb]
#[derive(Clone, Debug)]
pub struct PluginInstallResult {
    pub status: PluginInstallStatus,
    pub plugin_id: String,
    pub error: Option<String>,
}
