use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum HttpMethod {
    Get,
    Post,
    Put,
    Delete,
    Head,
    Patch,
    Options,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ImageLayout {
    Portrait,
    Landscape,
    Square,
    Banner,
    Circular,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MappingIds {
    pub id: String,
    pub source: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Thumbnail {
    pub medium: String,
    pub low: Option<String>,
    pub high: Option<String>,
    pub layout: ImageLayout,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SectionLink {
    pub id: String,
    pub image: Option<Thumbnail>,
    pub title: String,
    pub subtitle: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CardType {
    Carousel,
    Grid,
    Vlist,
    News,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Artwork {
    pub url: String,
    pub url_low: Option<String>,
    pub url_high: Option<String>,
    pub layout: ImageLayout,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArtistSummary {
    pub id: String,
    pub name: String,
    pub thumbnails: Vec<Artwork>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlbumSummary {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub thumbnails: Vec<Artwork>,
    pub year: Option<u32>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Lyrics {
    pub plain: Option<String>,
    pub synced: Option<String>,
    pub copyright: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Track {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub album: Option<AlbumSummary>,
    pub duration_ms: Option<u64>,
    pub thumbnails: Vec<Artwork>,
    pub url: Option<String>,
    pub is_explicit: bool,
    pub lyrics: Option<Lyrics>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlaylistSummary {
    pub id: String,
    pub title: String,
    pub owner: Option<String>,
    pub thumbnails: Vec<Artwork>,
    pub track_count: Option<u32>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", content = "data")]
pub enum MediaItem {
    Track(Track),
    Album(AlbumSummary),
    Artist(ArtistSummary),
    Playlist(PlaylistSummary),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PagedTracks {
    pub items: Vec<Track>,
    pub next_page_token: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PagedMediaItems {
    pub items: Vec<MediaItem>,
    pub next_page_token: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PagedAlbums {
    pub items: Vec<AlbumSummary>,
    pub next_page_token: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlbumDetails {
    pub summary: AlbumSummary,
    pub tracks: PagedTracks,
    pub description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArtistDetails {
    pub summary: ArtistSummary,
    pub top_tracks: Vec<Track>,
    pub albums: PagedAlbums,
    pub related_artists: Vec<ArtistSummary>,
    pub description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlaylistDetails {
    pub summary: PlaylistSummary,
    pub tracks: PagedTracks,
    pub description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Section {
    pub id: String,
    pub title: String,
    pub subtitle: Option<String>,
    pub card_type: CardType,
    pub items: Vec<MediaItem>,
    pub more_link: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChartSummary {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub thumbnail: Option<Artwork>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Trend {
    Up,
    Down,
    Same,
    NewEntry,
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChartItem {
    pub item: MediaItem,
    pub rank: u32,
    pub trend: Trend,
    pub change: Option<u32>,
    pub peak_rank: Option<u32>,
    pub weeks_on_chart: Option<u32>,
}
