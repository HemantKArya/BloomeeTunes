use flutter_rust_bridge::frb;

use crate::api::plugin::models::{
    AlbumDetails, ArtistDetails, ChartItem, ChartSummary, MediaItem, PagedAlbums,
    PagedMediaItems, PagedTracks, PlaylistDetails, Section, StreamSource,
};

#[frb(mirror(PluginRequest))]
#[derive(Debug)]
pub enum PluginRequest {
    ContentResolver(ContentResolverCommand),
    ChartProvider(ChartProviderCommand),
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
    Ack,
}
