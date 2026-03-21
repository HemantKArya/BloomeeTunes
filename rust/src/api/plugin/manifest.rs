use crate::api::plugin::errors::{PluginError, PluginResult};
use serde::de::{self, Deserializer};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[flutter_rust_bridge::frb]
pub const CURRENT_MANIFEST_VERSION: u32 = 1;

/// Plugin publisher information
#[flutter_rust_bridge::frb]
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PluginPublisher {
    pub name: String,
    pub url: Option<String>,
    pub contact: Option<String>,
    pub key_id: Option<String>,
}

/// Describes a required key/credential for a plugin.
///
/// JSON format:
/// ```json
/// {
///   "api_key": {
///     "description": "API key for authenticating",
///     "default": null,
///     "is_secret": true
///   }
/// }
/// ```
#[flutter_rust_bridge::frb]
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct KeyRequirement {
    /// Human-readable description of what this key is used for.
    pub description: String,
    /// Default value for this key. `None` means user must provide it.
    #[serde(default, rename = "default")]
    pub default_value: Option<String>,
    /// Whether this key should be treated as a secret (masked in UI).
    #[serde(default)]
    pub is_secret: bool,
}

#[flutter_rust_bridge::frb]
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Manifest {
    #[serde(deserialize_with = "deserialize_manifest_version")]
    pub manifest_version: u32,
    pub id: String,
    pub name: String,
    pub version: String,
    pub r#type: String,
    pub description: String,
    pub publisher: PluginPublisher,
    #[serde(default)]
    pub license: String,
    #[serde(default)]
    pub homepage: String,
    pub icon: Option<String>,
    #[serde(default)]
    pub host_site: Vec<String>,
    #[serde(default)]
    pub capabilities: Vec<String>,
    pub created_at: Option<String>,
    pub remote_url: Option<String>,
    #[serde(default)]
    pub keys_required: HashMap<String, KeyRequirement>,
    pub thumbnail_url: Option<String>,
    #[serde(default)]
    pub resolver: bool,
    pub last_updated: Option<String>,
    #[serde(default)]
    pub country_allowlist: Vec<String>,
}

fn parse_plugin_version(version: &str) -> Option<u64> {
    let trimmed = version.trim();
    if trimmed.is_empty() || !trimmed.chars().all(|c| c.is_ascii_digit()) {
        return None;
    }
    trimmed.parse::<u64>().ok()
}

fn deserialize_manifest_version<'de, D>(deserializer: D) -> Result<u32, D::Error>
where
    D: Deserializer<'de>,
{
    let value = serde_json::Value::deserialize(deserializer)?;
    match value {
        serde_json::Value::Number(number) => {
            let as_u64 = number
                .as_u64()
                .ok_or_else(|| de::Error::custom("manifest_version must be a positive integer"))?;
            u32::try_from(as_u64)
                .map_err(|_| de::Error::custom("manifest_version is too large"))
        }
        serde_json::Value::String(text) => {
            let trimmed = text.trim();
            if let Ok(v) = trimmed.parse::<u32>() {
                return Ok(v);
            }
            if let Some((whole, fractional)) = trimmed.split_once('.') {
                let whole_num = whole
                    .parse::<u32>()
                    .map_err(|_| de::Error::custom("Invalid manifest_version format"))?;
                let fractional_trimmed = fractional.trim_matches('0');
                if fractional_trimmed.is_empty() {
                    return Ok(whole_num);
                }
            }
            Err(de::Error::custom(
                "manifest_version must be an integer or integer-like string (e.g. '1' or '1.0')",
            ))
        }
        _ => Err(de::Error::custom(
            "manifest_version must be a number or string",
        )),
    }
}

impl Manifest {
    /// Load and validate a manifest from a JSON file
    #[flutter_rust_bridge::frb(ignore)]
    pub async fn from_file(file_path: &str) -> PluginResult<Self> {
        // Read the file content
        let content = tokio::fs::read_to_string(file_path).await.map_err(|e| {
            PluginError::ManifestParseError(format!(
                "Failed to read manifest file '{}': {}",
                file_path, e
            ))
        })?;

        // Parse JSON
        let manifest: Manifest = serde_json::from_str(&content).map_err(|e| {
            PluginError::ManifestParseError(format!(
                "Failed to parse manifest JSON from '{}': {}",
                file_path, e
            ))
        })?;

        // Validate the manifest
        manifest.validate()?;

        Ok(manifest)
    }

    /// Create a new manifest from parameters
    #[flutter_rust_bridge::frb(ignore)]
    pub fn new(
        id: String,
        name: String,
        version: String,
        plugin_type: String,
        description: String,
        publisher: PluginPublisher,
        license: String,
        homepage: String,
        icon: Option<String>,
        host_site: Vec<String>,
        capabilities: Vec<String>,
        created_at: Option<String>,
        remote_url: Option<String>,
    ) -> PluginResult<Self> {
        let manifest = Manifest {
            manifest_version: 1,
            id,
            name,
            version,
            r#type: plugin_type,
            description,
            publisher,
            license,
            homepage,
            icon,
            host_site,
            capabilities,
            created_at,
            remote_url,
            keys_required: HashMap::new(),
            thumbnail_url: None,
            resolver: false,
            last_updated: None,
            country_allowlist: Vec::new(),
        };

        // Validate the manifest
        manifest.validate()?;

        Ok(manifest)
    }

    /// Validate manifest structure
    #[flutter_rust_bridge::frb(ignore)]
    fn validate(&self) -> PluginResult<()> {
        // Removed strict manifest_version check here to allow parsing legacy/future manifests.
        // It should be validated at install time instead.

        // Validate required string fields are not empty
        let required_strings = vec![
            ("id", &self.id),
            ("name", &self.name),
            ("version", &self.version),
            ("type", &self.r#type),
            ("description", &self.description),
        ];

        for (field_name, value) in required_strings {
            if value.trim().is_empty() {
                return Err(PluginError::ManifestParseError(format!(
                    "Required field '{}' cannot be empty",
                    field_name
                )));
            }
        }

        if parse_plugin_version(&self.version).is_none() {
            return Err(PluginError::ManifestParseError(
                "Invalid plugin version: expected an integer string (e.g. '1', '2', '42')"
                    .to_string(),
            ));
        }

        // Validate publisher name is not empty
        if self.publisher.name.trim().is_empty() {
            return Err(PluginError::ManifestParseError(
                "Publisher name cannot be empty".to_string(),
            ));
        }

        // Validate icon if present
        if let Some(ref icon) = self.icon {
            if icon.trim().is_empty() {
                return Err(PluginError::ManifestParseError(
                    "Icon field cannot be empty if provided".to_string(),
                ));
            }
        }

        // Validate all host_site entries are valid URLs (basic check)
        for host in &self.host_site {
            if host.trim().is_empty() {
                return Err(PluginError::ManifestParseError(
                    "host_site entries cannot be empty".to_string(),
                ));
            }
            if !host.starts_with("http://") && !host.starts_with("https://") {
                return Err(PluginError::ManifestParseError(format!(
                    "host_site '{}' must be a valid HTTP/HTTPS URL",
                    host
                )));
            }
        }

        // Validate capabilities are valid strings
        for capability in &self.capabilities {
            if capability.trim().is_empty() {
                return Err(PluginError::ManifestParseError(
                    "capabilities entries cannot be empty".to_string(),
                ));
            }
        }

        // Validate homepage is a valid URL when provided
        if !self.homepage.trim().is_empty()
            && !self.homepage.starts_with("http://")
            && !self.homepage.starts_with("https://")
        {
            return Err(PluginError::ManifestParseError(format!(
                "homepage '{}' must be a valid HTTP/HTTPS URL",
                self.homepage
            )));
        }

        Ok(())
    }

    /// Check if the manifest is still valid (re-run validation)
    #[flutter_rust_bridge::frb(ignore)]
    pub fn check(&self) -> PluginResult<()> {
        self.validate()
    }

    /// Get the plugin ID
    #[flutter_rust_bridge::frb(ignore)]
    pub fn id(&self) -> &str {
        &self.id
    }

    /// Get the plugin name
    #[flutter_rust_bridge::frb(ignore)]
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Get the plugin type
    #[flutter_rust_bridge::frb(ignore)]
    pub fn plugin_type(&self) -> &str {
        &self.r#type
    }

    /// Check if the plugin supports a specific capability
    #[flutter_rust_bridge::frb(ignore)]
    pub fn has_capability(&self, capability: &str) -> bool {
        self.capabilities.contains(&capability.to_string())
    }

    /// Get all capabilities
    #[flutter_rust_bridge::frb(ignore)]
    pub fn capabilities(&self) -> &[String] {
        &self.capabilities
    }

    /// Get all host sites
    #[flutter_rust_bridge::frb(ignore)]
    pub fn host_sites(&self) -> &[String] {
        &self.host_site
    }

    /// Get the publisher information
    #[flutter_rust_bridge::frb(ignore)]
    pub fn publisher(&self) -> &PluginPublisher {
        &self.publisher
    }

    /// Get the icon path (if available)
    #[flutter_rust_bridge::frb(ignore)]
    pub fn icon(&self) -> Option<&str> {
        self.icon.as_deref()
    }

    /// Get the creation timestamp (if available)
    #[flutter_rust_bridge::frb(ignore)]
    pub fn created_at(&self) -> Option<&str> {
        self.created_at.as_deref()
    }
}

#[cfg(test)]
mod tests {
    use super::Manifest;

    #[test]
    fn parses_legacy_manifest_and_passes_validation() {
        // Test legacy manifest format (string manifest_version, missing optional fields)
        let json = r#"{
            "manifest_version": "1.0",
            "id": "com.example.legacy-plugin",
            "name": "Legacy Plugin",
            "version": "1",
            "type": "content-resolver",
            "publisher": {
                "name": "Example Publisher",
                "url": "https://example.com",
                "contact": "contact@example.com"
            },
            "description": "Example legacy plugin without optional metadata fields.",
            "created_at": "2025-12-10T00:00:00Z"
        }"#;

        let manifest: Manifest = serde_json::from_str(json).expect("manifest should parse");
        assert_eq!(manifest.manifest_version, 1);
        assert!(manifest.license.is_empty());
        assert!(manifest.homepage.is_empty());
        assert!(manifest.host_site.is_empty());
        assert!(manifest.capabilities.is_empty());
        manifest.validate().expect("manifest should validate");
    }

    #[test]
    fn rejects_manifest_with_invalid_version() {
        let json = r#"{
            "manifest_version": "2.0",
            "id": "com.example.plugin",
            "name": "Example",
            "version": "1",
            "type": "content-resolver",
            "publisher": { "name": "Example Inc" },
            "description": "Example plugin"
        }"#;

        let manifest: Manifest = serde_json::from_str(json).expect("manifest should parse");
        assert!(manifest.validate().is_err());
    }

    #[test]
    fn rejects_manifest_with_non_integer_plugin_version() {
        let json = r#"{
            "manifest_version": "1",
            "id": "com.example.plugin",
            "name": "Example",
            "version": "1.0.0",
            "type": "content-resolver",
            "publisher": { "name": "Example Inc" },
            "description": "Example plugin"
        }"#;

        let manifest: Manifest = serde_json::from_str(json).expect("manifest should parse");
        assert!(manifest.validate().is_err());
    }
}
