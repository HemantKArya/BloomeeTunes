use crate::api::plugin::plugin_info::PluginInfo;

#[flutter_rust_bridge::frb]
pub async fn scan_plugins_directory(plugins_dir: String) -> Vec<PluginInfo> {
    let mut plugins: Vec<PluginInfo> = Vec::new();

    // Scan plugin directories
    if let Ok(mut entries) = tokio::fs::read_dir(&plugins_dir).await {
        while let Some(entry) = entries.next_entry().await.transpose() {
            if let Ok(entry) = entry {
                if let Ok(file_type) = entry.file_type().await {
                    if file_type.is_dir() {
                        let dir_path = entry.path().to_string_lossy().to_string();

                        // Try to create PluginInfo (validates manifest and wasm)
                        match PluginInfo::from_path(&dir_path).await {
                            Ok(plugin_info) => {
                                plugins.push(plugin_info);
                            }
                            Err(e) => {
                                tracing::warn!(
                                    plugin_dir = %dir_path,
                                    error = %e,
                                    "Failed to load plugin from directory"
                                );
                            }
                        }
                    }
                }
            }
        }
    }

    plugins
}
