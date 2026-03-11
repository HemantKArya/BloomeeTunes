pub mod bindgen;

use crate::api::plugin::commands::{LyricsProviderCommand, PluginResponse};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{
    LyricsLine, LyricsMatch, LyricsMetadata, LyricsSyncType, LyricsToken, PluginLyrics,
    TrackMetadata,
};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use once_cell::sync::Lazy;
use std::any::Any;
use std::collections::HashMap;

use bindgen::exports_lyrics_api;

/// Global HTTP client that lives for the entire program lifetime
static HTTP_CLIENT: Lazy<reqwest::blocking::Client> = Lazy::new(|| {
    reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::blocking::Client::new())
});

/// LyricsProviderHostImpl provides HTTP and utility host functions for lyrics provider plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct LyricsProviderHostImpl {
    _plugin_id: String,
    storage: HashMap<String, String>,
}

impl LyricsProviderHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
            storage: HashMap::new(),
        }
    }
}

impl Default for LyricsProviderHostImpl {
    fn default() -> Self {
        Self::new("unknown".to_string())
    }
}

impl bindgen::UtilsHost for LyricsProviderHostImpl {
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
}

/// Internal state for LyricsProvider plugin
pub struct LyricsProviderWasmState {
    instance: waclay::Instance,
    store: HostPluginStore<LyricsProviderHostImpl>,
}

pub struct LyricsProviderPluginAdapter {
    name: String,
    state: LyricsProviderWasmState,
}

impl LyricsProviderPluginAdapter {
    pub async fn load(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Self> {
        let mut store = HostPluginStore::new(&engine, LyricsProviderHostImpl::new(name.clone()));

        let instance = get_instance_with_host(&mut store, engine, &wasm_path, |linker, store| {
            bindgen::imports::register_utils_host::<LyricsProviderHostImpl, _>(linker, store)
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
            state: LyricsProviderWasmState { instance, store },
        })
    }
}

impl Plugin for LyricsProviderPluginAdapter {
    fn get_name(&self) -> &str {
        &self.name
    }

    fn get_plugin_type(&self) -> PluginType {
        PluginType::LyricsProvider
    }

    fn handle_request(
        &mut self,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;
        if let PluginRequest::LyricsProvider(command) = request {
            let state = &mut self.state;

            match command {
                LyricsProviderCommand::GetLyrics { metadata } => {
                    let func =
                        exports_lyrics_api::get_get_lyrics(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let bg_meta = to_bindgen_track_metadata(metadata);
                    let result = func
                        .call(&mut state.store, bg_meta)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::LyricsResult(
                        result.map(|(l, m)| (to_plugin_lyrics(l), to_lyrics_metadata(m))),
                    ))
                }
                LyricsProviderCommand::Search { query } => {
                    let func =
                        exports_lyrics_api::get_search(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, query)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::LyricsSearchResults(
                        result.into_iter().map(to_lyrics_match).collect(),
                    ))
                }
                LyricsProviderCommand::GetLyricsById { id } => {
                    let func =
                        exports_lyrics_api::get_get_lyrics_by_id(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::LyricsById(
                        to_plugin_lyrics(result.0),
                        to_lyrics_metadata(result.1),
                    ))
                }
            }
        } else {
            Err(PluginError::InvalidConfiguration(format!(
                "Invalid request type for LyricsProvider: {:?}",
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

impl PluginAdapter for LyricsProviderPluginAdapter {
    fn plugin_type() -> PluginType {
        PluginType::LyricsProvider
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

fn to_bindgen_track_metadata(m: TrackMetadata) -> bindgen::TrackMetadata {
    bindgen::TrackMetadata {
        title: m.title,
        artist: m.artist,
        album: m.album,
        duration_ms: m.duration_ms,
    }
}

fn to_plugin_lyrics(l: bindgen::Lyrics) -> PluginLyrics {
    PluginLyrics {
        plain: l.plain,
        lrc: l.lrc,
        lines: l.lines.map(|lines| lines.into_iter().map(to_lyrics_line).collect()),
        is_instrumental: l.is_instrumental,
        sync_type: to_lyrics_sync_type(l.sync_type),
    }
}

fn to_lyrics_line(l: bindgen::LyricsLine) -> LyricsLine {
    LyricsLine {
        start_ms: l.start_ms,
        duration_ms: l.duration_ms,
        content: l.content,
        tokens: l.tokens.map(|t| t.into_iter().map(to_lyrics_token).collect()),
    }
}

fn to_lyrics_token(t: bindgen::LyricsToken) -> LyricsToken {
    LyricsToken {
        offset_ms: t.offset_ms,
        text: t.text,
    }
}

fn to_lyrics_sync_type(s: bindgen::LyricsSyncType) -> LyricsSyncType {
    match s {
        bindgen::LyricsSyncType::None => LyricsSyncType::None,
        bindgen::LyricsSyncType::Line => LyricsSyncType::Line,
        bindgen::LyricsSyncType::Syllable => LyricsSyncType::Syllable,
    }
}

fn to_lyrics_metadata(m: bindgen::LyricsMetadata) -> LyricsMetadata {
    LyricsMetadata {
        source: m.source,
        author: m.author,
        language: m.language,
        copyright: m.copyright,
        is_verified: m.is_verified,
    }
}

fn to_lyrics_match(m: bindgen::LyricsMatch) -> LyricsMatch {
    LyricsMatch {
        id: m.id,
        title: m.title,
        artist: m.artist,
        album: m.album,
        duration_ms: m.duration_ms,
        sync_type: to_lyrics_sync_type(m.sync_type),
    }
}
