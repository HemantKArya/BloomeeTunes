use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::PluginType;
use crate::api::plugin::wasm_runtime::{get_global_engine, SharedWasmEngine};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

/// Register all plugin adapters
fn register_all_adapters(registrar: &mut PluginRegistrar) {
    crate::api::plugin::adapters::register_builtin_adapters(registrar);
}

/// Plugin factory function type
#[flutter_rust_bridge::frb(ignore)]
pub type PluginFactory = Arc<
    dyn Fn(
            String,
            String,
            SharedWasmEngine,
        ) -> std::pin::Pin<
            Box<dyn std::future::Future<Output = PluginResult<Box<dyn Plugin>>> + Send>,
        > + Send
        + Sync,
>;

/// Plugin registrar for managing plugin types and their factories
#[flutter_rust_bridge::frb(ignore)]
#[derive(Clone)]
pub struct PluginRegistrar {
    factories: HashMap<PluginType, PluginFactory>,
}

impl PluginRegistrar {
    pub fn new() -> Self {
        Self {
            factories: HashMap::new(),
        }
    }

    pub fn with_all_adapters() -> Self {
        let mut registrar = Self::new();
        register_all_adapters(&mut registrar);
        registrar
    }

    pub fn register_plugin<F>(&mut self, plugin_type: PluginType, factory: F) -> PluginResult<()>
    where
        F: Fn(
                String,
                String,
                SharedWasmEngine,
            ) -> std::pin::Pin<
                Box<dyn std::future::Future<Output = PluginResult<Box<dyn Plugin>>> + Send>,
            > + Send
            + Sync
            + 'static,
    {
        if self.factories.contains_key(&plugin_type) {
            return Err(PluginError::InvalidConfiguration(format!(
                "Plugin type {:?} already registered",
                plugin_type
            )));
        }
        self.factories.insert(plugin_type, Arc::new(factory));
        Ok(())
    }

    pub fn get_factory(&self, plugin_type: &PluginType) -> Option<PluginFactory> {
        self.factories.get(plugin_type).cloned()
    }
}

impl Default for PluginRegistrar {
    fn default() -> Self {
        Self::with_all_adapters()
    }
}

/// Thread-safe global plugin registrar instance
#[flutter_rust_bridge::frb(ignore)]
pub type GlobalRegistrar = Arc<Mutex<PluginRegistrar>>;

/// Create a new global registrar instance
#[flutter_rust_bridge::frb(ignore)]
pub fn create_global_registrar() -> GlobalRegistrar {
    Arc::new(Mutex::new(PluginRegistrar::with_all_adapters()))
}

/// Get the global registrar instance (lazy initialized)
static GLOBAL_REGISTRAR: once_cell::sync::Lazy<GlobalRegistrar> =
    once_cell::sync::Lazy::new(|| create_global_registrar());

/// Get the global plugin registrar
#[flutter_rust_bridge::frb(ignore)]
pub fn get_global_registrar() -> &'static GlobalRegistrar {
    &GLOBAL_REGISTRAR
}

/// Get plugin type from string representation
#[flutter_rust_bridge::frb(ignore)]
pub fn get_plugin_type_from_string(type_str: &str) -> Option<PluginType> {
    PluginType::from_string(type_str)
}

/// Get the global shared WASM component engine
///
/// This now delegates to the centralized wasm_runtime module
#[flutter_rust_bridge::frb(ignore)]
pub fn get_global_wasm_engine() -> &'static SharedWasmEngine {
    get_global_engine()
}

#[flutter_rust_bridge::frb(ignore)]
pub async fn load_plugin_with_registrar(
    plugin_id: &str,
    plugin_type: PluginType,
    plugin_path: &str,
) -> PluginResult<Box<dyn Plugin>> {
    let factory = get_global_registrar()
        .lock()
        .map_err(|_| PluginError::InstantiationFailed("Lock poisoned".to_string()))?
        .get_factory(&plugin_type)
        .ok_or_else(|| PluginError::PluginTypeNotRegistered(plugin_type))?;

    factory(
        plugin_id.to_string(),
        plugin_path.to_string(),
        get_global_wasm_engine().clone(),
    )
    .await
}
