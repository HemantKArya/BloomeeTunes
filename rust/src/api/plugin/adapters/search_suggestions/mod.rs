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
use crate::utils::http;
use std::any::Any;
use std::collections::HashMap;

use bindgen::exports_suggestion_api;

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
        let response = http::send_blocking(http::Request {
            method,
            url,
            headers: options.headers.unwrap_or_default(),
            body: options.body,
            timeout_seconds: options.timeout_seconds,
        })?;
        Ok(bindgen::HttpResponse {
            status: response.status,
            headers: response.headers,
            body: response.body,
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
