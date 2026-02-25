pub mod bindgen;

use crate::api::plugin::commands::{ChartProviderCommand, PluginResponse};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{
    AlbumSummary, ArtistSummary, Artwork, ChartItem, ChartSummary, ImageLayout, Lyrics,
    MediaItem, PlaylistSummary, Track, Trend,
};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use once_cell::sync::Lazy;
use std::any::Any;

use bindgen::exports_chart_api;

/// Global HTTP client that lives for the entire program lifetime
static HTTP_CLIENT: Lazy<reqwest::blocking::Client> = Lazy::new(|| {
    reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::blocking::Client::new())
});

/// ChartProviderHostImpl provides HTTP and utility host functions for chart provider plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct ChartProviderHostImpl {
    _plugin_id: String,
}

impl ChartProviderHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
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

    fn storage_get(&mut self, _key: String) -> Option<String> {
        None
    }

    fn storage_set(&mut self, _key: String, _value: String) -> bool {
        false
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

            match command {
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
            }
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

fn to_audio_artwork(a: bindgen::Artwork) -> Artwork {
    Artwork {
        url: a.url,
        url_low: None,
        url_high: None,
        layout: match a.layout {
            bindgen::ImageLayout::Square => ImageLayout::Square,
            bindgen::ImageLayout::Portrait => ImageLayout::Portrait,
            bindgen::ImageLayout::Landscape => ImageLayout::Landscape,
            bindgen::ImageLayout::Banner => ImageLayout::Banner,
            bindgen::ImageLayout::Circular => ImageLayout::Circular,
        },
    }
}

fn to_audio_artist(a: bindgen::ArtistSummary) -> ArtistSummary {
    ArtistSummary {
        id: a.id,
        name: a.name,
        thumbnails: a.thumbnails.into_iter().map(to_audio_artwork).collect(),
        url: a.url,
    }
}

fn to_audio_lyrics(l: bindgen::Lyrics) -> Lyrics {
    Lyrics {
        plain: l.plain,
        synced: l.synced,
        copyright: l.copyright,
    }
}

fn to_audio_album(a: bindgen::AlbumSummary) -> AlbumSummary {
    AlbumSummary {
        id: a.id,
        title: a.title,
        artists: a.artists.into_iter().map(to_audio_artist).collect(),
        thumbnails: a.thumbnails.into_iter().map(to_audio_artwork).collect(),
        year: a.year,
        url: a.url,
    }
}

fn to_audio_track(t: bindgen::Track) -> Track {
    Track {
        id: t.id,
        title: t.title,
        artists: t.artists.into_iter().map(to_audio_artist).collect(),
        album: t.album.map(to_audio_album),
        duration_ms: t.duration_ms,
        thumbnails: t.thumbnails.into_iter().map(to_audio_artwork).collect(),
        url: t.url,
        is_explicit: t.is_explicit,
        lyrics: t.lyrics.map(to_audio_lyrics),
    }
}

fn to_audio_playlist(p: bindgen::PlaylistSummary) -> PlaylistSummary {
    PlaylistSummary {
        id: p.id,
        title: p.title,
        owner: p.owner,
        thumbnails: p.thumbnails.into_iter().map(to_audio_artwork).collect(),
        track_count: p.track_count,
        url: p.url,
    }
}

fn to_audio_media_item(m: bindgen::MediaItem) -> MediaItem {
    match m {
        bindgen::MediaItem::Track(t) => MediaItem::Track(to_audio_track(t)),
        bindgen::MediaItem::Album(a) => MediaItem::Album(to_audio_album(a)),
        bindgen::MediaItem::Artist(a) => MediaItem::Artist(to_audio_artist(a)),
        bindgen::MediaItem::Playlist(p) => MediaItem::Playlist(to_audio_playlist(p)),
    }
}

fn to_audio_chart_summary(s: bindgen::ChartSummary) -> ChartSummary {
    ChartSummary {
        id: s.id,
        title: s.title,
        description: s.description,
        thumbnails: s.thumbnails.into_iter().map(to_audio_artwork).collect(),
        updated_at: s.updated_at,
        period: s.period,
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
            bindgen::Trend::Unknown => Trend::Unknown,
        },
        change: i.change,
        previous_rank: i.previous_rank,
        peak_rank: i.peak_rank,
        weeks_on_chart: i.weeks_on_chart,
    }
}
