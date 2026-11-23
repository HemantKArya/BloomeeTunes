pub mod bindgen;

use crate::api::plugin::commands::{ChartProviderCommand, PluginResponse};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{
    AlbumSummary, ArtistSummary, Artwork, ChartItem, ChartSummary, ImageLayout, MediaItem, Track,
    Trend,
};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use crate::utils::http;
use std::any::Any;
use std::collections::HashMap;

use bindgen::exports_chart_api;

/// ChartProviderHostImpl provides HTTP and utility host functions for chart provider plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct ChartProviderHostImpl {
    _plugin_id: String,
    storage: HashMap<String, String>,
}

impl ChartProviderHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
            storage: HashMap::new(),
        }
    }
}

impl Default for ChartProviderHostImpl {
    fn default() -> Self {
        Self::new("unknown".to_string())
    }
}

impl bindgen::UtilsHost for ChartProviderHostImpl {
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
}

/// Internal state for ChartProvider plugin
pub struct ChartProviderWasmState {
    instance: waclay::Instance,
    store: HostPluginStore<ChartProviderHostImpl>,
}

pub struct ChartProviderPluginAdapter {
    name: String,
    state: ChartProviderWasmState,
}

impl ChartProviderPluginAdapter {
    pub async fn load(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Self> {
        let mut store = HostPluginStore::new(&engine, ChartProviderHostImpl::new(name.clone()));

        let instance = get_instance_with_host(&mut store, engine, &wasm_path, |linker, store| {
            bindgen::imports::register_utils_host::<ChartProviderHostImpl, _>(linker, store)
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
            state: ChartProviderWasmState { instance, store },
        })
    }
}

impl Plugin for ChartProviderPluginAdapter {
    fn get_name(&self) -> &str {
        &self.name
    }

    fn get_plugin_type(&self) -> PluginType {
        PluginType::ChartProvider
    }

    fn handle_request(
        &mut self,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;
        if let PluginRequest::ChartProvider(command) = request {
            let state = &mut self.state;
            let plugin_id = &self.name;

            let response = match command {
                ChartProviderCommand::GetCharts => {
                    let func = exports_chart_api::get_get_charts(&state.instance, &mut state.store)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, ())
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::Charts(
                        result.into_iter().map(to_audio_chart_summary).collect(),
                    ))
                }
                ChartProviderCommand::GetChartDetails { id } => {
                    let func =
                        exports_chart_api::get_get_chart_details(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::ChartDetails(
                        result.into_iter().map(to_audio_chart_item).collect(),
                    ))
                }
            }?;

            // Stamp entity IDs with "pluginId::" prefix
            Ok(stamp_chart_response(plugin_id, response))
        } else {
            Err(PluginError::InvalidConfiguration(format!(
                "Invalid request type for ChartProvider: {:?}",
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

impl PluginAdapter for ChartProviderPluginAdapter {
    fn plugin_type() -> PluginType {
        PluginType::ChartProvider
    }

    async fn create(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Box<dyn Plugin>> {
        Ok(Box::new(Self::load(name, wasm_path, engine).await?))
    }
}

// Converters

fn default_artwork() -> Artwork {
    Artwork {
        url: String::new(),
        url_low: None,
        url_high: None,
        layout: ImageLayout::Square,
    }
}

fn to_audio_artwork(a: bindgen::Artwork) -> Artwork {
    Artwork {
        url: a.url,
        url_low: a.url_low,
        url_high: a.url_high,
        layout: ImageLayout::Square,
    }
}

fn to_audio_artist_item(a: bindgen::ArtistItem) -> ArtistSummary {
    ArtistSummary {
        id: a.id,
        name: a.name,
        thumbnail: a.thumbnail.map(to_audio_artwork),
        subtitle: None,
        url: None,
    }
}

fn to_audio_album_item(a: bindgen::AlbumItem) -> AlbumSummary {
    AlbumSummary {
        id: a.id,
        title: a.title,
        artists: a
            .artists
            .into_iter()
            .map(|name| ArtistSummary {
                id: String::new(),
                name,
                thumbnail: None,
                subtitle: None,
                url: None,
            })
            .collect(),
        thumbnail: a.thumbnail.map(to_audio_artwork),
        subtitle: None,
        year: a.year,
        url: None,
    }
}

fn to_audio_track_item(t: bindgen::TrackItem) -> Track {
    // Track.thumbnail is required (Artwork, not Option); use a placeholder if missing
    let placeholder = default_artwork();
    Track {
        id: t.id,
        title: t.title,
        // artists is a comma-separated string in the chart WIT; split into minimal ArtistSummary
        artists: t
            .artists
            .split(',')
            .map(|name| ArtistSummary {
                id: String::new(),
                name: name.trim().to_string(),
                thumbnail: None,
                subtitle: None,
                url: None,
            })
            .filter(|a| !a.name.is_empty())
            .collect(),
        // album is just the title string in the chart WIT
        album: t.album.map(|title| AlbumSummary {
            id: String::new(),
            title,
            artists: vec![],
            thumbnail: None,
            subtitle: None,
            year: None,
            url: None,
        }),
        duration_ms: t.duration_ms,
        thumbnail: t.thumbnail.map(to_audio_artwork).unwrap_or(placeholder),
        url: None,
        is_explicit: t.is_explicit,
        lyrics: None,
    }
}

fn to_audio_media_item(m: bindgen::MediaItem) -> MediaItem {
    match m {
        bindgen::MediaItem::Track(t) => MediaItem::Track(to_audio_track_item(t)),
        bindgen::MediaItem::Album(a) => MediaItem::Album(to_audio_album_item(a)),
        bindgen::MediaItem::Artist(a) => MediaItem::Artist(to_audio_artist_item(a)),
    }
}

fn to_audio_chart_summary(s: bindgen::ChartSummary) -> ChartSummary {
    ChartSummary {
        id: s.id,
        title: s.title,
        description: s.description,
        thumbnail: s.thumbnail.map(to_audio_artwork),
    }
}

fn to_audio_chart_item(i: bindgen::ChartItem) -> ChartItem {
    ChartItem {
        item: to_audio_media_item(i.item),
        rank: i.rank,
        trend: match i.trend {
            bindgen::Trend::Up => Trend::Up,
            bindgen::Trend::Down => Trend::Down,
            bindgen::Trend::Same => Trend::Same,
            bindgen::Trend::NewEntry => Trend::NewEntry,
            bindgen::Trend::ReEntry => Trend::ReEntry,
            bindgen::Trend::Unknown => Trend::Unknown,
        },
        change: i.change,
        peak_rank: i.peak_rank,
        weeks_on_chart: i.weeks_on_chart,
    }
}

// ── ID Stamping ──────────────────────────────────────────────────────────────

const STAMP_SEP: &str = "::";

fn stamp_id(pid: &str, id: &str) -> String {
    if id.contains(STAMP_SEP) || id.is_empty() {
        id.to_string()
    } else {
        format!("{}{}{}", pid, STAMP_SEP, id)
    }
}

fn stamp_track(pid: &str, mut t: Track) -> Track {
    t.id = stamp_id(pid, &t.id);
    t.artists = t.artists.into_iter().map(|a| stamp_artist(pid, a)).collect();
    t.album = t.album.map(|a| stamp_album(pid, a));
    t
}

fn stamp_artist(pid: &str, mut a: ArtistSummary) -> ArtistSummary {
    a.id = stamp_id(pid, &a.id);
    a
}

fn stamp_album(pid: &str, mut a: AlbumSummary) -> AlbumSummary {
    a.id = stamp_id(pid, &a.id);
    a.artists = a.artists.into_iter().map(|ar| stamp_artist(pid, ar)).collect();
    a
}

fn stamp_media_item(pid: &str, item: MediaItem) -> MediaItem {
    match item {
        MediaItem::Track(t) => MediaItem::Track(stamp_track(pid, t)),
        MediaItem::Album(a) => MediaItem::Album(stamp_album(pid, a)),
        MediaItem::Artist(a) => MediaItem::Artist(stamp_artist(pid, a)),
        MediaItem::Playlist(p) => {
            // Chart provider doesn't produce playlists, but handle for completeness
            let _ = pid;
            MediaItem::Playlist(p)
        }
    }
}

fn stamp_chart_summary(pid: &str, mut c: ChartSummary) -> ChartSummary {
    c.id = stamp_id(pid, &c.id);
    c
}

fn stamp_chart_item(pid: &str, mut c: ChartItem) -> ChartItem {
    c.item = stamp_media_item(pid, c.item);
    c
}

fn stamp_chart_response(plugin_id: &str, response: PluginResponse) -> PluginResponse {
    match response {
        PluginResponse::Charts(charts) => PluginResponse::Charts(
            charts.into_iter().map(|c| stamp_chart_summary(plugin_id, c)).collect(),
        ),
        PluginResponse::ChartDetails(items) => PluginResponse::ChartDetails(
            items.into_iter().map(|c| stamp_chart_item(plugin_id, c)).collect(),
        ),
        other => other,
    }
}
