use crate::api::plugin::wasm_runtime::{SharedWasmEngine, WasmRuntimeEngine};
use waclay::{Component, Instance, Linker, Store};

/// Load a WASM component without host functions
pub async fn get_instance(
    store: &mut Store<(), WasmRuntimeEngine>,
    engine: SharedWasmEngine,
    path: &str,
) -> Result<Instance, String> {
    let wasm_bytes = tokio::fs::read(path)
        .await
        .map_err(|e| format!("Failed to read WASM file '{}': {}", path, e))?;

    let component = Component::new(&engine, &wasm_bytes)
        .map_err(|e| format!("Failed to create component from '{}': {:?}", path, e))?;

    let linker = Linker::default();

    let instance = linker
        .instantiate(store, &component)
        .map_err(|e| format!("Failed to instantiate component from '{}': {:?}", path, e))?;

    Ok(instance)
}

/// Load a WASM component with host functions (for plugins that need imports like search)
///
/// # Type Parameters
/// * `T` - The host state type that implements the required host traits
///
/// # Arguments
/// * `store` - The WASM store with host state
/// * `engine` - The WASM component engine
/// * `path` - Path to the WASM file
/// * `register_host` - Callback to register host functions in the linker
pub async fn get_instance_with_host<T, F>(
    store: &mut Store<T, WasmRuntimeEngine>,
    engine: SharedWasmEngine,
    path: &str,
    register_host: F,
) -> Result<Instance, String>
where
    T: 'static,
    F: FnOnce(&mut Linker, &mut Store<T, WasmRuntimeEngine>) -> Result<(), String>,
{
    let wasm_bytes = tokio::fs::read(path)
        .await
        .map_err(|e| format!("Failed to read WASM file '{}': {}", path, e))?;

    let component = Component::new(&engine, &wasm_bytes)
        .map_err(|e| format!("Failed to create component from '{}': {:?}", path, e))?;

    let mut linker = Linker::default();

    // Register host functions
    register_host(&mut linker, store)?;

    let instance = linker
        .instantiate(store, &component)
        .map_err(|e| format!("Failed to instantiate component from '{}': {:?}", path, e))?;

    Ok(instance)
}
