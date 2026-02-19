use crate::api::plugin::types::PluginType;
use flutter_rust_bridge::frb;

/// Custom error type for plugin operations
#[frb]
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub enum PluginError {
    PluginTypeNotRegistered(PluginType),
    PluginNotFound(String),
    PluginAlreadyLoaded(String),
    PluginNotLoaded(String),
    FunctionNotFound(String),
    InvalidArguments(String),
    InstantiationFailed(String),
    WasmLoadFailed(String),
    ManifestParseError(String),
    InvalidConfiguration(String),
    WasmExecutionError(String),
    SerializationError(String),
    DeserializationError(String),
}

impl std::fmt::Display for PluginError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PluginError::PluginTypeNotRegistered(pt) => {
                write!(f, "Plugin type {:?} not registered", pt)
            }
            PluginError::PluginNotFound(name) => write!(f, "Plugin '{}' not found", name),
            PluginError::PluginAlreadyLoaded(name) => {
                write!(f, "Plugin '{}' is already loaded", name)
            }
            PluginError::PluginNotLoaded(name) => write!(f, "Plugin '{}' is not loaded", name),
            PluginError::FunctionNotFound(func) => {
                write!(f, "Function '{}' not found in plugin", func)
            }
            PluginError::InvalidArguments(msg) => write!(f, "Invalid arguments: {}", msg),
            PluginError::InstantiationFailed(msg) => {
                write!(f, "Plugin instantiation failed: {}", msg)
            }
            PluginError::WasmLoadFailed(msg) => write!(f, "WASM loading failed: {}", msg),
            PluginError::ManifestParseError(msg) => write!(f, "Manifest parsing failed: {}", msg),
            PluginError::InvalidConfiguration(msg) => write!(f, "Invalid configuration: {}", msg),
            PluginError::WasmExecutionError(msg) => write!(f, "WASM execution error: {}", msg),
            PluginError::SerializationError(msg) => write!(f, "Serialization error: {}", msg),
            PluginError::DeserializationError(msg) => write!(f, "Deserialization error: {}", msg),
        }
    }
}

impl std::error::Error for PluginError {}

/// Result type alias for plugin operations
#[frb(ignore)]
pub type PluginResult<T> = Result<T, PluginError>;
