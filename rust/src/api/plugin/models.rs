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
    pub thumbnail: Option<Artwork>,
    pub subtitle: Option<String>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AlbumSummary {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub thumbnail: Option<Artwork>,
    pub subtitle: Option<String>,
    pub year: Option<u32>,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Lyrics {
    pub plain: Option<String>,
    pub synced: Option<String>,
    pub copyright: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Quality {
    Low,
    Medium,
    High,
    Lossless,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamSource {
    pub url: String,
    pub quality: Quality,
    pub format: String,
    pub headers: Option<Vec<(String, String)>>,
    pub expires_at: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Track {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub album: Option<AlbumSummary>,
    pub duration_ms: Option<u64>,
    pub thumbnail: Artwork,
    pub url: Option<String>,
    pub is_explicit: bool,
    pub lyrics: Option<Lyrics>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlaylistSummary {
    pub id: String,
    pub title: String,
    pub owner: Option<String>,
    pub thumbnail: Artwork,
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
    ReEntry,
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

// ── Segment Types ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SegmentType {
    Intro,
    Outro,
    Sponsor,
    SelfPromo,
    Interaction,
    MusicOfftopic,
    Chapter,
    Filler,
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrackSegment {
    pub segment_type: SegmentType,
    pub start_ms: u64,
    pub end_ms: u64,
    pub title: Option<String>,
    pub is_skippable: bool,
}

// ── Lyrics Provider Types ─────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LyricsSyncType {
    None,
    Line,
    Syllable,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricsToken {
    pub offset_ms: u32,
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricsLine {
    pub start_ms: u32,
    pub duration_ms: Option<u32>,
    pub content: String,
    pub tokens: Option<Vec<LyricsToken>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PluginLyrics {
    pub plain: Option<String>,
    pub lrc: Option<String>,
    pub lines: Option<Vec<LyricsLine>>,
    pub is_instrumental: bool,
    pub sync_type: LyricsSyncType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricsMetadata {
    pub source: Option<String>,
    pub author: Option<String>,
    pub language: Option<String>,
    pub copyright: Option<String>,
    pub is_verified: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrackMetadata {
    pub title: String,
    pub artist: String,
    pub album: Option<String>,
    pub duration_ms: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyricsMatch {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album: Option<String>,
    pub duration_ms: Option<u64>,
    pub sync_type: LyricsSyncType,
}

// ── Search Suggestion Types ───────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EntityType {
    Track,
    Album,
    Artist,
    Playlist,
    Genre,
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SuggestionArtwork {
    pub url: String,
    pub url_low: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EntitySuggestion {
    pub id: String,
    pub title: String,
    pub subtitle: Option<String>,
    pub kind: EntityType,
    pub thumbnail: Option<SuggestionArtwork>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", content = "data")]
pub enum Suggestion {
    Query(String),
    Entity(EntitySuggestion),
}

// ── Content Importer Types ────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ImportCollectionType {
    Playlist,
    Album,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImportCollectionSummary {
    pub title: String,
    pub kind: ImportCollectionType,
    pub description: Option<String>,
    pub owner: Option<String>,
    pub thumbnail_url: Option<String>,
    pub track_count: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImportTrackItem {
    pub title: String,
    pub artists: Vec<String>,
    pub thumbnail_url: Option<String>,
    pub album_title: Option<String>,
    pub duration_ms: Option<u64>,
    pub is_explicit: bool,
    pub url: Option<String>,
    pub source_id: Option<String>,
}
