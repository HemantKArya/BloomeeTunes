use flutter_rust_bridge::frb;

use crate::api::plugin::models::{
    AlbumDetails, ArtistDetails, ChartItem, ChartSummary, LyricsMatch, LyricsMetadata, MediaItem,
    PagedAlbums, PagedMediaItems, PagedTracks, PlaylistDetails, PluginLyrics, Section,
    StreamSource, Suggestion, TrackMetadata, TrackSegment,
};

#[frb(mirror(PluginRequest))]
#[derive(Debug)]
pub enum PluginRequest {
    ContentResolver(ContentResolverCommand),
    ChartProvider(ChartProviderCommand),
    LyricsProvider(LyricsProviderCommand),
    SearchSuggestionProvider(SearchSuggestionCommand),
}

#[frb(mirror(ContentResolverCommand))]
#[derive(Debug)]
pub enum ContentResolverCommand {
    GetAlbumDetails {
        id: String,
    },
    GetArtistDetails {
        id: String,
    },
    GetPlaylistDetails {
        id: String,
    },
    GetStreams {
        id: String,
    },
    Search {
        query: String,
        filter: ContentSearchFilter,
        page_token: Option<String>,
    },
    MoreAlbumTracks {
        id: String,
        page_token: String,
    },
    MoreArtistAlbums {
        id: String,
        page_token: String,
    },
    MorePlaylistTracks {
        id: String,
        page_token: String,
    },
    GetRadioTracks {
        id: String,
        page_token: Option<String>,
    },
    GetHomeSections,
    LoadMore {
        id: String,
        more_link: String,
    },
    GetSegmentsForTrack {
        id: String,
    },
}

#[frb(mirror(ContentSearchFilter))]
#[derive(Debug, Clone, Copy)]
pub enum ContentSearchFilter {
    All,
    Track,
    Album,
    Artist,
    Playlist,
}

#[frb(mirror(ChartProviderCommand))]
#[derive(Debug)]
pub enum ChartProviderCommand {
    GetCharts,
    GetChartDetails { id: String },
}

#[frb(mirror(LyricsProviderCommand))]
#[derive(Debug)]
pub enum LyricsProviderCommand {
    GetLyrics {
        metadata: TrackMetadata,
    },
    Search {
        query: String,
    },
    GetLyricsById {
        id: String,
    },
}

#[frb(mirror(SearchSuggestionCommand))]
#[derive(Debug)]
pub enum SearchSuggestionCommand {
    GetSuggestions {
        query: String,
        limit: Option<u8>,
        include_entities: bool,
    },
    GetDefaultSuggestions {
        limit: Option<u8>,
        include_entities: bool,
    },
}

#[frb(mirror(PluginResponse))]
pub enum PluginResponse {
    AlbumDetails(AlbumDetails),
    ArtistDetails(ArtistDetails),
    PlaylistDetails(PlaylistDetails),
    Streams(Vec<StreamSource>),
    Search(PagedMediaItems),
    MoreTracks(PagedTracks),
    MoreAlbums(PagedAlbums),
    HomeSections(Vec<Section>),
    LoadMoreItems(Vec<MediaItem>),
    Charts(Vec<ChartSummary>),
    ChartDetails(Vec<ChartItem>),
    Segments(Vec<TrackSegment>),
    LyricsResult(Option<(PluginLyrics, LyricsMetadata)>),
    LyricsSearchResults(Vec<LyricsMatch>),
    LyricsById(PluginLyrics, LyricsMetadata),
    Suggestions(Vec<Suggestion>),
    Ack,
}
