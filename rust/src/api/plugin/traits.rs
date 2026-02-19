use crate::api::plugin::commands::{PluginRequest, PluginResponse};
use crate::api::plugin::errors::PluginResult;
use crate::api::plugin::types::PluginType;
use std::any::Any;

/// Base trait for all plugins
pub trait Plugin: Any + Send + Sync {
    fn get_name(&self) -> &str;
    fn get_plugin_type(&self) -> PluginType;
    #[flutter_rust_bridge::frb(ignore)]
    fn as_any(&self) -> &dyn Any;
    #[flutter_rust_bridge::frb(ignore)]
    fn as_any_mut(&mut self) -> &mut dyn Any;

    /// NEW: Typed request/response handling (preferred for performance)
    /// Accepts strongly-typed PluginRequest, returns strongly-typed PluginResponse
    #[flutter_rust_bridge::frb(ignore)]
    fn handle_request(&mut self, request: PluginRequest) -> PluginResult<PluginResponse>;
}
