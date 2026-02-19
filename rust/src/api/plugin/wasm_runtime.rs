/// WASM runtime backend configuration.
///
/// Centralized selection and helpers for the runtime engine used by plugins.
///
/// # Backend Compatibility (wasm_runtime_layer 0.6.0 required by waclay 0.2.1)
///
/// | Backend                  | Version | Compatible | Notes                           |
/// |--------------------------|---------|------------|---------------------------------|
/// | wasmi_runtime_layer      | 1.0.0   | ✅ Yes     | Interpreter, portable           |
/// | wasmtime_runtime_layer   | 39.0.0  | ✅ Yes     | JIT, high performance           |
/// | wasmer_runtime_layer     | 6.0.0   | ❌ No      | Uses wasm_runtime_layer 0.5.0   |
/// | js_wasm_runtime_layer    | 0.6.0   | ✅ Yes     | Browser WebAssembly (wasm32)    |

// ============================================================================
// BACKEND SELECTION - CHANGE THIS TO SWITCH RUNTIMES
// ============================================================================

// Choose ONE of the following backends by uncommenting:

// Option 1: Wasmi - Interpreter backend (default, portable, slower execution)
// This is the RECOMMENDED backend as it works out of the box without extra configuration.
pub use wasmi_runtime_layer::Engine as WasmRuntimeEngine;

// Option 2: Wasmtime - JIT backend (faster execution, native compilation)
// NOTE: Requires wasmtime with GC features enabled. If you get GC-related errors,
// add `wasmtime = { version = "39", features = ["gc-drc", "gc-null"] }` to Cargo.toml
// pub use wasmtime_runtime_layer::Engine as WasmRuntimeEngine;

// Option 3: Wasmer - NOT CURRENTLY COMPATIBLE
// The wasmer_runtime_layer v6.0.0 depends on wasm_runtime_layer v0.5.0,
// but waclay v0.2.1 requires wasm_runtime_layer v0.6.0.
// This causes a trait mismatch error. Wait for wasmer_runtime_layer update.
// pub use wasmer_runtime_layer::Engine as WasmRuntimeEngine;

// ============================================================================
// TYPE ALIASES - Used throughout the codebase
// ============================================================================

use std::sync::Arc;
use waclay::Engine as WasmComponentEngine;

/// The WASM component engine type configured with the selected runtime backend
pub type ConfiguredWasmEngine = WasmComponentEngine<WasmRuntimeEngine>;

/// Arc-wrapped WASM engine for shared ownership across the plugin system
pub type SharedWasmEngine = Arc<ConfiguredWasmEngine>;

/// Store type for plugins without host functions
pub type SimplePluginStore = waclay::Store<(), WasmRuntimeEngine>;

/// Store type for plugins with host functions
pub type HostPluginStore<T> = waclay::Store<T, WasmRuntimeEngine>;

// ============================================================================
// ENGINE FACTORY
// ============================================================================

/// Create a new runtime engine instance with default config.
pub fn create_runtime_engine() -> WasmRuntimeEngine {
    WasmRuntimeEngine::default()
}

/// Create a new WASM component engine with the configured runtime backend
pub fn create_wasm_engine() -> ConfiguredWasmEngine {
    WasmComponentEngine::new(create_runtime_engine())
}

/// Create a new shared (Arc-wrapped) WASM component engine
pub fn create_shared_wasm_engine() -> SharedWasmEngine {
    Arc::new(create_wasm_engine())
}

// ============================================================================
// GLOBAL SHARED ENGINE
// ============================================================================

/// Global shared engine used by all plugins (reduces overhead).
static GLOBAL_WASM_ENGINE: once_cell::sync::Lazy<SharedWasmEngine> =
    once_cell::sync::Lazy::new(|| create_shared_wasm_engine());

/// Get a reference to the global shared WASM engine
///
/// This is the preferred way to obtain the engine for plugin loading.
pub fn get_global_engine() -> &'static SharedWasmEngine {
    &GLOBAL_WASM_ENGINE
}

// ============================================================================
// BACKEND INFORMATION
// ============================================================================

/// Get information about the currently configured WASM runtime backend
/// 
/// Returns information about Wasmi (interpreter) by default.
/// To switch to Wasmtime (JIT), change the pub use statement at the top of this file.
pub fn runtime_info() -> RuntimeInfo {
    // Default: Wasmi interpreter backend
    RuntimeInfo {
        name: "Wasmi",
        version: "1.0.0",
        description: "Lightweight WebAssembly interpreter",
        features: &["Interpreter-based", "Low memory footprint", "Fast startup", "Portable"],
    }
    
    // Alternative: Wasmtime JIT backend (uncomment if using wasmtime_runtime_layer)
    // RuntimeInfo {
    //     name: "Wasmtime",
    //     version: "39.0.0",
    //     description: "High-performance WebAssembly JIT runtime",
    //     features: &["JIT compilation", "High performance", "Native speed", "Cranelift backend"],
    // }
}

/// Information about the WASM runtime backend
#[derive(Debug, Clone)]
pub struct RuntimeInfo {
    pub name: &'static str,
    pub version: &'static str,
    pub description: &'static str,
    pub features: &'static [&'static str],
}

impl RuntimeInfo {
    pub fn display(&self) -> String {
        format!(
            "{} v{}: {} (Features: {})",
            self.name,
            self.version,
            self.description,
            self.features.join(", ")
        )
    }
}
