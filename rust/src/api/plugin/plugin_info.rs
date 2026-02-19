use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::manifest::Manifest;
use crate::api::plugin::types::PluginType;

/// Plugin information with validation
#[flutter_rust_bridge::frb(opaque)]
#[derive(Clone, Debug)]
pub struct PluginInfo {
    pub name: String,
    pub plugin_type: PluginType,
    pub manifest: Manifest,
    pub plugin_path: String,
}

impl PluginInfo {
    /// Create a new PluginInfo from provided data
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(
        name: String,
        plugin_type: PluginType,
        manifest: Manifest,
        plugin_path: String,
    ) -> PluginResult<Self> {
        let plugin_info = PluginInfo {
            name,
            plugin_type,
            manifest,
            plugin_path,
        };

        // Validate the plugin info
        plugin_info.validate()?;

        Ok(plugin_info)
    }

    /// Create PluginInfo from a plugin directory (manifest.json + plugin.wasm)
    #[flutter_rust_bridge::frb(ignore)]
    pub async fn from_path(dir_path: &str) -> PluginResult<Self> {
        // Check if directory exists
        let dir_path = std::path::Path::new(dir_path);
        if !dir_path.exists() {
            return Err(PluginError::PluginNotFound(format!(
                "Plugin directory does not exist: {}",
                dir_path.display()
            )));
        }

        if !dir_path.is_dir() {
            return Err(PluginError::InvalidConfiguration(format!(
                "Path is not a directory: {}",
                dir_path.display()
            )));
        }

        // Look for manifest.json file
        let manifest_path = dir_path.join("manifest.json");
        if !manifest_path.exists() {
            return Err(PluginError::ManifestParseError(format!(
                "manifest.json not found in: {}",
                dir_path.display()
            )));
        }

        // Load manifest (this already validates it)
        let manifest_path_string = manifest_path.to_string_lossy().to_string();
        let manifest = Manifest::from_file(&manifest_path_string).await?;

        // Look for .wasm file
        let wasm_path = dir_path.join("plugin.wasm");
        if !wasm_path.exists() {
            return Err(PluginError::WasmLoadFailed(format!(
                "WASM file not found: {} (expected: plugin.wasm)",
                wasm_path.display()
            )));
        }

        // Determine plugin type from manifest
        let plugin_type = Self::plugin_type_from_string(&manifest.r#type)?;

        let plugin_info = PluginInfo {
            name: manifest.name.clone(),
            plugin_type,
            manifest,
            plugin_path: dir_path.to_string_lossy().to_string(),
        };

        // Final validation (just check WASM and manifest validity)
        plugin_info.validate()?;

        Ok(plugin_info)
    }

    /// Check whether the plugin files still exist and manifest is valid
    #[flutter_rust_bridge::frb(ignore)]
    pub async fn check(&self) -> PluginResult<bool> {
        // Check if directory still exists
        let dir_path = std::path::Path::new(&self.plugin_path);
        if !dir_path.exists() || !dir_path.is_dir() {
            return Ok(false);
        }

        // Check if manifest.json still exists
        let manifest_path = dir_path.join("manifest.json");
        if !manifest_path.exists() {
            return Ok(false);
        }

        // Check if WASM file still exists
        let wasm_path = dir_path.join("plugin.wasm");
        if !wasm_path.exists() {
            return Ok(false);
        }

        // Check if manifest is still valid
        let manifest_path_string = manifest_path.to_string_lossy().to_string();
        match Manifest::from_file(&manifest_path_string).await {
            Ok(loaded_manifest) => {
                // Use manifest.check() to validate the loaded manifest
                if loaded_manifest.check().is_err() {
                    return Ok(false);
                }

                // Check if manifest is still the same
                if loaded_manifest.id != self.manifest.id
                    || loaded_manifest.name != self.manifest.name
                    || loaded_manifest.version != self.manifest.version
                {
                    return Ok(false);
                }
                Ok(true)
            }
            Err(_) => Ok(false),
        }
    }

    /// Validate plugin info
    #[flutter_rust_bridge::frb(ignore)]
    fn validate(&self) -> PluginResult<()> {
        // Validate name is not empty
        if self.name.trim().is_empty() {
            return Err(PluginError::InvalidConfiguration(
                "Plugin name cannot be empty".to_string(),
            ));
        }

        // Validate plugin path exists
        let path = std::path::Path::new(&self.plugin_path);
        if !path.exists() {
            return Err(PluginError::PluginNotFound(format!(
                "Plugin path does not exist: {}",
                self.plugin_path
            )));
        }

        // Validate manifest is still valid
        self.manifest.check()?;

        // Validate WASM file exists
        let wasm_path = path.join("plugin.wasm");
        if !wasm_path.exists() {
            return Err(PluginError::WasmLoadFailed(format!(
                "WASM file not found: {}",
                wasm_path.display()
            )));
        }

        // Validate plugin type matches manifest type
        // We parse the manifest type string again to handle variations (e.g. metadata-provider vs metadata_provider)
        let manifest_plugin_type = Self::plugin_type_from_string(&self.manifest.r#type)?;
        if manifest_plugin_type != self.plugin_type {
            let expected_type_str = Self::plugin_type_to_string(self.plugin_type.clone());
            return Err(PluginError::InvalidConfiguration(format!(
                "Plugin type mismatch: expected '{}', got '{}'",
                expected_type_str, self.manifest.r#type
            )));
        }

        Ok(())
    }

    fn plugin_type_to_string(plugin_type: PluginType) -> String {
        plugin_type.type_string().to_string()
    }

    fn plugin_type_from_string(type_str: &str) -> PluginResult<PluginType> {
        PluginType::from_string(type_str).ok_or_else(|| {
            PluginError::InvalidConfiguration(format!("Unknown plugin type: {}", type_str))
        })
    }

    /// Get the plugin ID from manifest
    #[flutter_rust_bridge::frb(ignore)]
    pub fn id(&self) -> &str {
        &self.manifest.id
    }

    /// Get the plugin version from manifest
    #[flutter_rust_bridge::frb(ignore)]
    pub fn version(&self) -> &str {
        &self.manifest.version
    }

    /// Get the plugin description from manifest
    #[flutter_rust_bridge::frb(ignore)]
    pub fn description(&self) -> &str {
        &self.manifest.description
    }

    /// Get the plugin publisher from manifest
    #[flutter_rust_bridge::frb(ignore)]
    pub fn publisher(&self) -> &crate::api::plugin::manifest::PluginPublisher {
        &self.manifest.publisher
    }

    /// Get the WASM file path
    #[flutter_rust_bridge::frb(ignore)]
    pub fn wasm_path(&self) -> String {
        format!("{}/plugin.wasm", self.plugin_path)
    }

    /// Get the manifest file path
    #[flutter_rust_bridge::frb(ignore)]
    pub fn manifest_path(&self) -> String {
        format!("{}/manifest.json", self.plugin_path)
    }
}
