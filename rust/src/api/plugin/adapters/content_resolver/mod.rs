pub mod bindgen;

use crate::api::plugin::commands::{
    ContentResolverCommand, ContentSearchFilter, PluginResponse,
};
use crate::api::plugin::errors::{PluginError, PluginResult};
use crate::api::plugin::loader::get_instance_with_host;
use crate::api::plugin::models::{
    AlbumDetails, AlbumSummary, ArtistDetails, ArtistSummary, Artwork, CardType, ImageLayout,
    Lyrics, MediaItem, PagedAlbums, PagedMediaItems, PagedTracks, PlaylistDetails,
    PlaylistSummary, Section, Track,
};
use crate::api::plugin::traits::Plugin;
use crate::api::plugin::types::{PluginAdapter, PluginType};
use crate::api::plugin::wasm_runtime::{HostPluginStore, SharedWasmEngine};
use once_cell::sync::Lazy;
use std::any::Any;

use bindgen::{exports_data_source, exports_discovery};

/// Global HTTP client that lives for the entire program lifetime
static HTTP_CLIENT: Lazy<reqwest::blocking::Client> = Lazy::new(|| {
    reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::blocking::Client::new())
});

/// ContentResolverHostImpl provides HTTP and utility host functions for content resolver plugins
#[flutter_rust_bridge::frb(opaque)]
pub struct ContentResolverHostImpl {
    _plugin_id: String,
}

impl ContentResolverHostImpl {
    pub fn new(plugin_id: String) -> Self {
        Self {
            _plugin_id: plugin_id,
        }
    }
}

impl Default for ContentResolverHostImpl {
    fn default() -> Self {
        Self::new("unknown".to_string())
    }
}

impl bindgen::UtilsHost for ContentResolverHostImpl {
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

/// Internal state for ContentResolver plugin
pub struct ContentResolverWasmState {
    instance: waclay::Instance,
    store: HostPluginStore<ContentResolverHostImpl>,
}

pub struct ContentResolverPluginAdapter {
    name: String,
    state: ContentResolverWasmState,
}

impl ContentResolverPluginAdapter {
    pub async fn load(
        name: String,
        wasm_path: String,
        engine: SharedWasmEngine,
    ) -> PluginResult<Self> {
        let mut store = HostPluginStore::new(&engine, ContentResolverHostImpl::new(name.clone()));

        let instance = get_instance_with_host(&mut store, engine, &wasm_path, |linker, store| {
            bindgen::imports::register_utils_host::<ContentResolverHostImpl, _>(linker, store)
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
            state: ContentResolverWasmState { instance, store },
        })
    }
}

impl Plugin for ContentResolverPluginAdapter {
    fn get_name(&self) -> &str {
        &self.name
    }

    fn get_plugin_type(&self) -> PluginType {
        PluginType::ContentResolver
    }

    fn handle_request(
        &mut self,
        request: crate::api::plugin::commands::PluginRequest,
    ) -> PluginResult<PluginResponse> {
        use crate::api::plugin::commands::PluginRequest;
        if let PluginRequest::ContentResolver(command) = request {
            let state = &mut self.state;

            match command {
                ContentResolverCommand::GetHomeSections => {
                    let func =
                        exports_discovery::get_get_home_sections(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, ())
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::HomeSections(
                        result.into_iter().map(to_audio_section).collect(),
                    ))
                }
                ContentResolverCommand::LoadMore { id, more_link } => {
                    let func = exports_discovery::get_load_more(&state.instance, &mut state.store)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, (id, more_link))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::LoadMoreItems(
                        result.into_iter().map(to_audio_media_item).collect(),
                    ))
                }
                ContentResolverCommand::GetAlbumDetails { id } => {
                    let func = exports_data_source::get_get_album_details(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::AlbumDetails(to_audio_album_details(
                        result,
                    )))
                }
                ContentResolverCommand::GetArtistDetails { id } => {
                    let func = exports_data_source::get_get_artist_details(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::ArtistDetails(to_audio_artist_details(
                        result,
                    )))
                }
                ContentResolverCommand::GetPlaylistDetails { id } => {
                    let func = exports_data_source::get_get_playlist_details(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::PlaylistDetails(
                        to_audio_playlist_details(result),
                    ))
                }
                ContentResolverCommand::GetStreams { id } => {
                    let func =
                        exports_data_source::get_get_streams(&state.instance, &mut state.store)
                            .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, id)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    // Convert Vec<StreamSource> → Vec<Track> with stream URLs
                    let tracks: Vec<Track> = result
                        .into_iter()
                        .enumerate()
                        .map(|(i, s)| Track {
                            id: format!("stream_{}", i),
                            title: format!("{:?} {}", s.quality, s.format),
                            artists: vec![],
                            album: None,
                            duration_ms: None,
                            thumbnails: vec![],
                            url: Some(s.url),
                            is_explicit: false,
                            lyrics: None,
                        })
                        .collect();
                    Ok(PluginResponse::Streams(tracks))
                }
                ContentResolverCommand::Search {
                    query,
                    filter,
                    page_token,
                } => {
                    let func = exports_data_source::get_search(&state.instance, &mut state.store)
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let filter_enum = to_bindgen_search_filter(filter);
                    let result = func
                        .call(&mut state.store, (query, filter_enum, page_token))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::Search(to_paged_audio_media_items(
                        result,
                    )))
                }
                ContentResolverCommand::MoreAlbumTracks { id, page_token } => {
                    let func = exports_data_source::get_more_album_tracks(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, (id, page_token))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::MoreTracks(to_paged_audio_tracks(result)))
                }
                ContentResolverCommand::MoreArtistAlbums { id, page_token } => {
                    let func = exports_data_source::get_more_artist_albums(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, (id, page_token))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::MoreAlbums(to_paged_audio_albums(result)))
                }
                ContentResolverCommand::MorePlaylistTracks { id, page_token } => {
                    let func = exports_data_source::get_more_playlist_tracks(
                        &state.instance,
                        &mut state.store,
                    )
                    .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?;
                    let result = func
                        .call(&mut state.store, (id, page_token))
                        .map_err(|e| PluginError::WasmExecutionError(e.to_string()))?
                        .map_err(|e| PluginError::WasmExecutionError(e))?;
                    Ok(PluginResponse::MoreTracks(to_paged_audio_tracks(result)))
                }
            }
        } else {
            Err(PluginError::InvalidConfiguration(format!(
                "Invalid request type for ContentResolver: {:?}",
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

impl PluginAdapter for ContentResolverPluginAdapter {
    fn plugin_type() -> PluginType {
        PluginType::ContentResolver
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

fn to_audio_section(s: bindgen::Section) -> Section {
    Section {
        id: s.id,
        title: s.title,
        subtitle: s.subtitle,
        card_type: match s.card_type {
            bindgen::SectionType::Carousel => CardType::Carousel,
            bindgen::SectionType::Grid => CardType::Grid,
            bindgen::SectionType::Vlist => CardType::Vlist,
        },
        items: s.items.into_iter().map(to_audio_media_item).collect(),
        more_link: s.more_link,
    }
}

fn to_paged_audio_media_items(p: bindgen::PagedMediaItems) -> PagedMediaItems {
    PagedMediaItems {
        items: p.items.into_iter().map(to_audio_media_item).collect(),
        next_page_token: p.next_page_token,
    }
}

fn to_paged_audio_albums(p: bindgen::PagedAlbums) -> PagedAlbums {
    PagedAlbums {
        items: p.items.into_iter().map(to_audio_album).collect(),
        next_page_token: p.next_page_token,
    }
}

fn to_paged_audio_tracks(p: bindgen::PagedTracks) -> PagedTracks {
    PagedTracks {
        items: p.items.into_iter().map(to_audio_track).collect(),
        next_page_token: p.next_page_token,
    }
}

fn to_audio_album_details(d: bindgen::AlbumDetails) -> AlbumDetails {
    AlbumDetails {
        summary: to_audio_album(d.summary),
        tracks: to_paged_audio_tracks(d.tracks),
        description: d.description,
    }
}

fn to_audio_artist_details(d: bindgen::ArtistDetails) -> ArtistDetails {
    ArtistDetails {
        summary: to_audio_artist(d.summary),
        top_tracks: d.top_tracks.into_iter().map(to_audio_track).collect(),
        albums: to_paged_audio_albums(d.albums),
        related_artists: d.related_artists.into_iter().map(to_audio_artist).collect(),
        description: d.description,
    }
}

fn to_audio_playlist_details(d: bindgen::PlaylistDetails) -> PlaylistDetails {
    PlaylistDetails {
        summary: to_audio_playlist(d.summary),
        tracks: to_paged_audio_tracks(d.tracks),
        description: d.description,
    }
}

fn to_bindgen_search_filter(filter: ContentSearchFilter) -> bindgen::SearchFilter {
    match filter {
        ContentSearchFilter::All => bindgen::SearchFilter::All,
        ContentSearchFilter::Track => bindgen::SearchFilter::Track,
        ContentSearchFilter::Album => bindgen::SearchFilter::Album,
        ContentSearchFilter::Artist => bindgen::SearchFilter::Artist,
        ContentSearchFilter::Playlist => bindgen::SearchFilter::Playlist,
    }
}
