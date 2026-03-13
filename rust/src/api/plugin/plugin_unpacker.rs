use crate::api::plugin::manifest::{Manifest, CURRENT_MANIFEST_VERSION};
use crate::api::plugin::registrar::get_plugin_type_from_string;
use crate::api::plugin::types::{PluginInstallResult, PluginInstallStatus};
use anyhow::{Context, Result};
use std::cmp::Ordering;
use std::fs::File;
use std::io::BufReader;
use tar::Archive;
use zstd::stream::read::Decoder;

fn parse_version_int(version: &str) -> Option<u64> {
    let trimmed = version.trim();
    if trimmed.is_empty() || !trimmed.chars().all(|c| c.is_ascii_digit()) {
        return None;
    }
    trimmed.parse::<u64>().ok()
}

pub async fn unpack_and_read_manifest(
    archive_path: &str,
    temp_dir: &str,
) -> Result<(Manifest, String)> {
    let now_nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .context("System clock before UNIX_EPOCH")?
        .as_nanos();

    let temp_plugin_dir = format!(
        "{}/plugin_temp_{}",
        temp_dir,
        now_nanos
    );

    unpack_plugin(archive_path, &temp_plugin_dir, Some("bex")).await?;

    let manifest_path = format!("{}/manifest.json", temp_plugin_dir);
    let manifest = Manifest::from_file(&manifest_path)
        .await
        .with_context(|| format!("Failed to load manifest from '{}'", manifest_path))?;

    Ok((manifest, temp_plugin_dir))
}

pub async fn install_plugin(
    temp_plugin_dir: &str,
    manifest: &Manifest,
    plugins_dir: &str,
) -> Result<(String, PluginInstallStatus)> {
    let plugin_install_dir = format!("{}/{}", plugins_dir, manifest.id);
    let path = std::path::Path::new(&plugin_install_dir);

    let mut status = PluginInstallStatus::Installed;

    if path.exists() {
        // Check existing plugin version for comparison
        let existing_manifest_path = path.join("manifest.json");
        if existing_manifest_path.exists() {
            let existing_manifest_path_string =
                existing_manifest_path.to_string_lossy().to_string();
            if let Ok(existing_manifest) = Manifest::from_file(&existing_manifest_path_string).await
            {
                if let (Some(new_ver), Some(old_ver)) = (
                    parse_version_int(&manifest.version),
                    parse_version_int(&existing_manifest.version),
                ) {
                    match new_ver.cmp(&old_ver) {
                        Ordering::Greater => {
                            status = PluginInstallStatus::Updated;
                        }
                        Ordering::Equal => {
                            status = PluginInstallStatus::AlreadyInstalled;
                        }
                        Ordering::Less => {
                            status = PluginInstallStatus::Downgraded;
                        }
                    }
                }
            }
        }

        // Remove existing
        tokio::fs::remove_dir_all(&plugin_install_dir)
            .await
            .with_context(|| {
                format!(
                    "Failed to remove existing plugin at '{}'",
                    plugin_install_dir
                )
            })?;
    }

    tokio::fs::create_dir_all(&plugin_install_dir)
        .await
        .with_context(|| format!("Failed to create directory '{}'", plugin_install_dir))?;

    for file in ["manifest.json", "plugin.wasm", "plugin.wit"] {
        let source = format!("{}/{}", temp_plugin_dir, file);
        let dest = format!("{}/{}", plugin_install_dir, file);
        if std::path::Path::new(&source).exists() {
            tokio::fs::copy(&source, &dest)
                .await
                .with_context(|| format!("Failed to copy {}", file))?;
        }
    }

    Ok((manifest.id.clone(), status))
}

pub async fn install_packed_plugin(
    packed_file_path: &str,
    plugins_dir: &str,
    temp_dir: &str,
    should_load: bool,
    manager: Option<&crate::api::plugin::plugin::PluginManager>,
) -> Result<PluginInstallResult> {
    let (manifest, temp_plugin_dir) = unpack_and_read_manifest(packed_file_path, temp_dir).await?;

    let cleanup = || async {
        let _ = tokio::fs::remove_dir_all(&temp_plugin_dir).await;
    };

    if manifest.manifest_version != CURRENT_MANIFEST_VERSION {
        cleanup().await;
        return Ok(PluginInstallResult {
            status: PluginInstallStatus::Failed,
            plugin_id: manifest.id,
            error: Some(format!(
                "Manifest version mismatch: Expected {}, got {}",
                CURRENT_MANIFEST_VERSION, manifest.manifest_version
            )),
        });
    }

    if let Some(plugin_mgr) = manager {
        if let Some(plugin_type) = get_plugin_type_from_string(manifest.plugin_type()) {
            if plugin_mgr.is_plugin_loaded(&manifest.id, plugin_type).await {
                cleanup().await;
                return Ok(PluginInstallResult {
                    status: PluginInstallStatus::PluginLoaded,
                    plugin_id: manifest.id,
                    error: Some("Plugin is currently loaded".to_string()),
                });
            }
        }
    }

    let install_res = install_plugin(&temp_plugin_dir, &manifest, plugins_dir).await;
    cleanup().await;

    let (plugin_id, status) = install_res?;

    if should_load {
        if let Some(plugin_mgr) = manager {
            let plugin_type = get_plugin_type_from_string(manifest.plugin_type())
                .ok_or_else(|| anyhow::anyhow!("Unknown type: {}", manifest.plugin_type()))?;

            let plugin_path = format!("{}/{}/plugin.wasm", plugins_dir, plugin_id);

            plugin_mgr
                .load_plugin_from_path(&plugin_id, plugin_type, &plugin_path)
                .await
                .map_err(|e| anyhow::anyhow!("Failed to load: {}", e))?;
        }
    }

    Ok(PluginInstallResult {
        status,
        plugin_id,
        error: None,
    })
}

pub async fn unpack_plugin(
    archive_path: &str,
    output_folder: &str,
    expected_extension: Option<&str>,
) -> Result<()> {
    if archive_path.is_empty() || output_folder.is_empty() {
        anyhow::bail!("Archive path and output folder cannot be empty");
    }

    let path = std::path::Path::new(archive_path);
    if !path.exists() {
        anyhow::bail!("Archive file not found: {}", archive_path);
    }

    if let Some(expected_ext) = expected_extension {
        match path.extension() {
            Some(ext) if ext == expected_ext => {}
            Some(ext) => anyhow::bail!(
                "Expected .{} extension, got .{}",
                expected_ext,
                ext.to_string_lossy()
            ),
            None => anyhow::bail!("Expected .{} extension, got none", expected_ext),
        }
    }

    tokio::fs::create_dir_all(output_folder)
        .await
        .with_context(|| format!("Failed to create directory '{}'", output_folder))?;

    let archive_path_owned = archive_path.to_string();
    let output_folder_owned = output_folder.to_string();
    tokio::task::spawn_blocking(move || -> Result<()> {
        let file = File::open(&archive_path_owned)
            .with_context(|| format!("Failed to open '{}'", archive_path_owned))?;
        let decoder =
            Decoder::new(BufReader::new(file)).with_context(|| "Failed to create decoder")?;
        Archive::new(decoder)
            .unpack(&output_folder_owned)
            .with_context(|| format!("Failed to unpack to '{}'", output_folder_owned))?;
        Ok(())
    })
    .await??;

    Ok(())
}

pub fn scan_bex_files(directory: &str) -> Result<Vec<String>> {
    let mut files = Vec::new();
    let paths = std::fs::read_dir(directory)
        .with_context(|| format!("Failed to read directory '{}'", directory))?;

    for path in paths {
        let path = path.with_context(|| "Failed to read entry")?.path();
        if path.extension().and_then(|s| s.to_str()) == Some("bex") {
            if let Some(path_str) = path.to_str() {
                files.push(path_str.to_string());
            }
        }
    }
    Ok(files)
}
