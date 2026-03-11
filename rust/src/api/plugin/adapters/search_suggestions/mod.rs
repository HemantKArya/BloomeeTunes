pub mod bindgen;

use crate::api::plugin::commands::{SearchSuggestionCommand, PluginResponse};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{
    EntitySuggestion, EntityType, Suggestion, SuggestionArtwork,
};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use once_cell::sync::Lazy;
use std::any::Any;
use std::collections::HashMap;

use bindgen::exports_suggestion_api;

/// Global HTTP client that lives for the entire program lifetime
static HTTP_CLIENT: Lazy<reqwest::blocking::Client> = Lazy::new(|| {
    reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::blocking::Client::new())
});

/// SearchSuggestionHostImpl provides HTTP and utility host functions for search suggestion plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct SearchSuggestionHostImpl {
    _plugin_id: String,
    storage: HashMap<String, String>,
}

impl SearchSuggestionHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
            storage: HashMap::new(),
        }
    }
}

impl Default for SearchSuggestionHostImpl {
    fn default() -> Self {
        Self::new("unknown".to_string())
    }
}

impl bindgen::UtilsHost for SearchSuggestionHostImpl {
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

    fn storage_delete(&mut self, key: String) -> bool {
        self.storage.remove(&key).is_some()
    }

    fn log(&mut self, message: String) {
        tracing::info!(plugin_id = %self._plugin_id, "[plugin] {}", message);
    }
}

/// Internal state for SearchSuggestion plugin
pub struct SearchSuggestionWasmState {
    instance: waclay::Instance,
    store: HostPluginStore<SearchSuggestionHostImpl>,
}

pub struct SearchSuggestionPluginAdapter {
    name: String,
    state: SearchSuggestionWasmState,
}

impl SearchSuggestionPluginAdapter {
    pub async fn load(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Self> {
        let mut store =
            HostPluginStore::new(&engine, SearchSuggestionHostImpl::new(name.clone()));

        let instance = get_instance_with_host(&mut store, engine, &wasm_path, |linker, store| {
            bindgen::imports::register_utils_host::<SearchSuggestionHostImpl, _>(linker, store)
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
            state: SearchSuggestionWasmState { instance, store },
        })
    }
}

impl Plugin for SearchSuggestionPluginAdapter {
    fn get_name(&self) -> &str {
        &self.name
    }

    fn get_plugin_type(&self) -> PluginType {
        PluginType::SearchSuggestionProvider
    }

    fn handle_request(
        &mut self,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;
        if let PluginRequest::SearchSuggestionProvider(command) = request {
            let state = &mut self.state;

            match command {
                SearchSuggestionCommand::GetSuggestions {
                    query,
                    limit,
                    include_entities,
                } => {
                    let func = exports_suggestion_api::get_get_suggestions(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let options = bindgen::SuggestionOptions {
                        limit,
                        include_entities,
                        allowed_types: None,
                    };
                    let result = func
                        .call(&mut state.store, (query, options))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::Suggestions(
                        result.into_iter().map(to_suggestion).collect(),
                    ))
                }
                SearchSuggestionCommand::GetDefaultSuggestions {
                    limit,
                    include_entities,
                } => {
                    let func = exports_suggestion_api::get_get_default_suggestions(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let options = bindgen::SuggestionOptions {
                        limit,
                        include_entities,
                        allowed_types: None,
                    };
                    let result = func
                        .call(&mut state.store, options)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::Suggestions(
                        result.into_iter().map(to_suggestion).collect(),
                    ))
                }
            }
        } else {
            Err(PluginError::InvalidConfiguration(format!(
                "Invalid request type for SearchSuggestionProvider: {:?}",
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

impl PluginAdapter for SearchSuggestionPluginAdapter {
    fn plugin_type() -> PluginType {
        PluginType::SearchSuggestionProvider
    }

    async fn create(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Box<dyn Plugin>> {
        Ok(Box::new(Self::load(name, wasm_path, engine).await?))
    }
}

// ── Converters ──────────────────────────────────────────────────────────────

fn to_entity_type(e: bindgen::EntityType) -> EntityType {
    match e {
        bindgen::EntityType::Track => EntityType::Track,
        bindgen::EntityType::Album => EntityType::Album,
        bindgen::EntityType::Artist => EntityType::Artist,
        bindgen::EntityType::Playlist => EntityType::Playlist,
        bindgen::EntityType::Genre => EntityType::Genre,
        bindgen::EntityType::Unknown => EntityType::Unknown,
    }
}

fn to_suggestion_artwork(a: bindgen::Artwork) -> SuggestionArtwork {
    SuggestionArtwork {
        url: a.url,
        url_low: a.url_low,
    }
}

fn to_entity_suggestion(e: bindgen::EntitySuggestion) -> EntitySuggestion {
    EntitySuggestion {
        id: e.id,
        title: e.title,
        subtitle: e.subtitle,
        kind: to_entity_type(e.kind),
        thumbnail: e.thumbnail.map(to_suggestion_artwork),
    }
}

fn to_suggestion(s: bindgen::Suggestion) -> Suggestion {
    match s {
        bindgen::Suggestion::Query(q) => Suggestion::Query(q),
        bindgen::Suggestion::Entity(e) => Suggestion::Entity(to_entity_suggestion(e)),
    }
}
