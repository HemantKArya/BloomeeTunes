pub mod bindgen;

use crate::api::plugin::commands::{ContentImporterCommand, PluginResponse};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{ImportCollectionSummary, ImportCollectionType, ImportTrackItem};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use once_cell::sync::Lazy;
use std::any::Any;
use std::collections::HashMap;

use bindgen::exports_importer;

/// Global HTTP client for content-importer plugins
static HTTP_CLIENT: Lazy<reqwest::blocking::Client> = Lazy::new(|| {
    reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::blocking::Client::new())
});

/// Host implementation for content-importer plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct ContentImporterHostImpl {
    _plugin_id: String,
    storage: HashMap<String, String>,
}

impl ContentImporterHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
            storage: HashMap::new(),
        }
    }
}

impl Default for ContentImporterHostImpl {
    fn default() -> Self {
        Self::new("unknown".to_string())
    }
}

impl bindgen::UtilsHost for ContentImporterHostImpl {
    fn http_request(
        &mut self,
        url: String,
        options: bindgen::RequestOptions,
    ) -> Result<bindgen::HttpResponse, String> {
        let method = match options.method {
            bindgen::HttpMethod::Get => reqwest::Method::GET,
            bindgen::HttpMethod::Post => reqwest::Method::POST,
            bindgen::HttpMethod::Put => reqwest::Method::PUT,
            bindgen::HttpMethod::Delete => reqwest::Method::DELETE,
            bindgen::HttpMethod::Head => reqwest::Method::HEAD,
            bindgen::HttpMethod::Patch => reqwest::Method::PATCH,
            bindgen::HttpMethod::Options => reqwest::Method::OPTIONS,
        };

        let mut req = HTTP_CLIENT.request(method, &url);

        if let Some(timeout) = options.timeout_seconds {
            let capped_timeout = timeout.min(30);
            req = req.timeout(std::time::Duration::from_secs(capped_timeout as u64));
        }

        if let Some(headers) = options.headers {
            for (k, v) in headers {
                req = req.header(k, v);
            }
        }

        if let Some(body) = options.body {
            req = req.body(body);
        }

        let resp = req.send().map_err(|e| e.to_string())?;

        let status = resp.status().as_u16();
        let headers: Vec<(String, String)> = resp
            .headers()
            .iter()
            .map(|(k, v)| (k.as_str().to_string(), v.to_str().unwrap_or("").to_string()))
            .collect();
        let body_bytes = resp.bytes().map_err(|e| e.to_string())?.to_vec();

        Ok(bindgen::HttpResponse {
            status,
            headers,
            body: body_bytes,
        })
    }

    fn random_number(&mut self) -> u64 {
        use rand::Rng;
        rand::thread_rng().gen()
    }

    fn current_unix_timestamp(&mut self) -> u64 {
        use std::time::{SystemTime, UNIX_EPOCH};
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    }

    fn storage_get(&mut self, key: String) -> Option<String> {
        self.storage.get(&key).cloned()
    }

    fn storage_set(&mut self, key: String, value: String) -> bool {
        self.storage.insert(key, value);
        true
    }
}

/// Internal WASM state for ContentImporter plugin
pub struct ContentImporterWasmState {
    instance: waclay::Instance,
    store: HostPluginStore<ContentImporterHostImpl>,
}

pub struct ContentImporterPluginAdapter {
    name: String,
    state: ContentImporterWasmState,
}

impl ContentImporterPluginAdapter {
    pub async fn load(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Self> {
        let mut store =
            HostPluginStore::new(&engine, ContentImporterHostImpl::new(name.clone()));

        let instance = get_instance_with_host(&mut store, engine, &wasm_path, |linker, store| {
            bindgen::imports::register_utils_host::<ContentImporterHostImpl, _>(linker, store)
                .map_err(|e| format!("Failed to register host functions: {:?}", e))?;
            Ok(())
        })
        .await
        .map_err(|e| {
            PluginError::WasmExecutionError(format!(
                "Failed to load WASM for plugin '{}': {}",
                &name, e
            ))
        })?;

        Ok(Self {
            name,
            state: ContentImporterWasmState { instance, store },
        })
    }
}

impl Plugin for ContentImporterPluginAdapter {
    fn get_name(&self) -> &str {
        &self.name
    }

    fn get_plugin_type(&self) -> PluginType {
        PluginType::ContentImporter
    }

    fn handle_request(
        &mut self,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;
        if let PluginRequest::ContentImporter(command) = request {
            let state = &mut self.state;

            match command {
                ContentImporterCommand::CanHandleUrl { url } => {
                    let func =
                        exports_importer::get_can_handle_url(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, url)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    Ok(PluginResponse::CanHandle(result))
                }
                ContentImporterCommand::GetCollectionInfo { url } => {
                    let func = exports_importer::get_get_collection_info(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, url)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::CollectionInfo(to_import_collection_summary(
                        result,
                    )))
                }
                ContentImporterCommand::GetTracks { url } => {
                    let func =
                        exports_importer::get_get_tracks(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, url)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::ImportTracks(
                        result.items.into_iter().map(to_import_track_item).collect(),
                    ))
                }
            }
        } else {
            Err(PluginError::InvalidConfiguration(format!(
                "Invalid request type for ContentImporter: {:?}",
                request
            )))
        }
    }

    fn as_any(&self) -> &dyn Any {
        self
    }

    fn as_any_mut(&mut self) -> &mut dyn Any {
        self
    }
}

impl PluginAdapter for ContentImporterPluginAdapter {
    fn plugin_type() -> PluginType {
        PluginType::ContentImporter
    }

    async fn create(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Box<dyn Plugin>> {
        Ok(Box::new(Self::load(name, wasm_path, engine).await?))
    }
}

// ── Converters ───────────────────────────────────────────────────────────────

fn to_import_collection_summary(
    s: bindgen::CollectionSummary,
) -> ImportCollectionSummary {
    ImportCollectionSummary {
        title: s.title,
        kind: match s.kind {
            bindgen::CollectionType::Playlist => ImportCollectionType::Playlist,
            bindgen::CollectionType::Album => ImportCollectionType::Album,
        },
        description: s.description,
        owner: s.owner,
        thumbnail_url: s.thumbnail_url,
        track_count: s.track_count,
    }
}

fn to_import_track_item(t: bindgen::TrackItem) -> ImportTrackItem {
    ImportTrackItem {
        title: t.title,
        artists: t.artists,
        thumbnail_url: t.thumbnail_url,
        album_title: t.album_title,
        duration_ms: t.duration_ms,
        is_explicit: t.is_explicit.unwrap_or(false),
        url: t.url,
        source_id: t.source_id,
    }
}
