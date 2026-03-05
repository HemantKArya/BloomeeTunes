import 'package:equatable/equatable.dart';
import 'package:Bloomee/core/models/exported.dart';

/// State for [ContentBloc].
///
/// Uses Rust-generated types directly — no wrapper models.
class ContentState extends Equatable {
  /// Active content resolver plugin ID.
  final String? activePluginId;

  // ── Search ──
  final SearchStatus searchStatus;
  final String searchQuery;
  final PagedMediaItems? searchResults;

  // ── Album Details ──
  final DetailStatus albumDetailStatus;
  final AlbumDetails? albumDetails;

  // ── Artist Details ──
  final DetailStatus artistDetailStatus;
  final ArtistDetails? artistDetails;

  // ── Playlist Details ──
  final DetailStatus playlistDetailStatus;
  final PlaylistDetails? playlistDetails;

  // ── Streams ──
  final DetailStatus streamStatus;
  final List<Track>? streamTracks;

  // ── Home Sections ──
  final DetailStatus homeSectionsStatus;
  final List<Section>? homeSections;

  // ── Error ──
  final String? error;

  const ContentState({
    this.activePluginId,
    this.searchStatus = SearchStatus.initial,
    this.searchQuery = '',
    this.searchResults,
    this.albumDetailStatus = DetailStatus.initial,
    this.albumDetails,
    this.artistDetailStatus = DetailStatus.initial,
    this.artistDetails,
    this.playlistDetailStatus = DetailStatus.initial,
    this.playlistDetails,
    this.streamStatus = DetailStatus.initial,
    this.streamTracks,
    this.homeSectionsStatus = DetailStatus.initial,
    this.homeSections,
    this.error,
  });

  const ContentState.initial()
      : activePluginId = null,
        searchStatus = SearchStatus.initial,
        searchQuery = '',
        searchResults = null,
        albumDetailStatus = DetailStatus.initial,
        albumDetails = null,
        artistDetailStatus = DetailStatus.initial,
        artistDetails = null,
        playlistDetailStatus = DetailStatus.initial,
        playlistDetails = null,
        streamStatus = DetailStatus.initial,
        streamTracks = null,
        homeSectionsStatus = DetailStatus.initial,
        homeSections = null,
        error = null;

  ContentState copyWith({
    String? activePluginId,
    SearchStatus? searchStatus,
    String? searchQuery,
    PagedMediaItems? searchResults,
    DetailStatus? albumDetailStatus,
    AlbumDetails? albumDetails,
    DetailStatus? artistDetailStatus,
    ArtistDetails? artistDetails,
    DetailStatus? playlistDetailStatus,
    PlaylistDetails? playlistDetails,
    DetailStatus? streamStatus,
    List<Track>? streamTracks,
    DetailStatus? homeSectionsStatus,
    List<Section>? homeSections,
    String? error,
    bool clearError = false,
    bool clearSearchResults = false,
    bool clearAlbumDetails = false,
    bool clearArtistDetails = false,
    bool clearPlaylistDetails = false,
    bool clearStreams = false,
    bool clearHomeSections = false,
    bool clearActivePluginId = false,
  }) {
    return ContentState(
      activePluginId:
          clearActivePluginId ? null : (activePluginId ?? this.activePluginId),
      searchStatus: searchStatus ?? this.searchStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults:
          clearSearchResults ? null : (searchResults ?? this.searchResults),
      albumDetailStatus: albumDetailStatus ?? this.albumDetailStatus,
      albumDetails:
          clearAlbumDetails ? null : (albumDetails ?? this.albumDetails),
      artistDetailStatus: artistDetailStatus ?? this.artistDetailStatus,
      artistDetails:
          clearArtistDetails ? null : (artistDetails ?? this.artistDetails),
      playlistDetailStatus: playlistDetailStatus ?? this.playlistDetailStatus,
      playlistDetails: clearPlaylistDetails
          ? null
          : (playlistDetails ?? this.playlistDetails),
      streamStatus: streamStatus ?? this.streamStatus,
      streamTracks: clearStreams ? null : (streamTracks ?? this.streamTracks),
      homeSectionsStatus: homeSectionsStatus ?? this.homeSectionsStatus,
      homeSections:
          clearHomeSections ? null : (homeSections ?? this.homeSections),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        activePluginId,
        searchStatus,
        searchQuery,
        searchResults,
        albumDetailStatus,
        albumDetails,
        artistDetailStatus,
        artistDetails,
        playlistDetailStatus,
        playlistDetails,
        streamStatus,
        streamTracks,
        homeSectionsStatus,
        homeSections,
        error,
      ];
}

enum SearchStatus { initial, loading, loaded, error }

enum DetailStatus { initial, loading, loaded, loadingMore, error }
