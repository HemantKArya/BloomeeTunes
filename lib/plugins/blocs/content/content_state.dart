import 'package:equatable/equatable.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

/// State for [ContentBloc].
///
/// Uses Rust-generated types directly — no wrapper models.
class ContentState extends Equatable {
  /// Active content resolver plugin ID.
  final String? activePluginId;

  // ── Search ──
  final SearchStatus searchStatus;
  final String searchQuery;
  final ContentSearchFilter searchFilter;
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
  final List<StreamSource>? streamSources;
  final List<Track>? radioTracks;

  // ── Home Sections ──
  final DetailStatus homeSectionsStatus;
  final List<Section>? homeSections;
  final List<String> loadingHomeSectionIds;

  // ── Error ──
  final String? error;

  const ContentState({
    this.activePluginId,
    this.searchStatus = SearchStatus.initial,
    this.searchQuery = '',
    this.searchFilter = ContentSearchFilter.all,
    this.searchResults,
    this.albumDetailStatus = DetailStatus.initial,
    this.albumDetails,
    this.artistDetailStatus = DetailStatus.initial,
    this.artistDetails,
    this.playlistDetailStatus = DetailStatus.initial,
    this.playlistDetails,
    this.streamStatus = DetailStatus.initial,
    this.streamSources,
    this.radioTracks,
    this.homeSectionsStatus = DetailStatus.initial,
    this.homeSections,
    this.loadingHomeSectionIds = const [],
    this.error,
  });

  const ContentState.initial()
      : activePluginId = null,
        searchStatus = SearchStatus.initial,
        searchQuery = '',
        searchFilter = ContentSearchFilter.all,
        searchResults = null,
        albumDetailStatus = DetailStatus.initial,
        albumDetails = null,
        artistDetailStatus = DetailStatus.initial,
        artistDetails = null,
        playlistDetailStatus = DetailStatus.initial,
        playlistDetails = null,
        streamStatus = DetailStatus.initial,
        streamSources = null,
        radioTracks = null,
        homeSectionsStatus = DetailStatus.initial,
        homeSections = null,
        loadingHomeSectionIds = const [],
        error = null;

  ContentState copyWith({
    String? activePluginId,
    SearchStatus? searchStatus,
    String? searchQuery,
    ContentSearchFilter? searchFilter,
    PagedMediaItems? searchResults,
    DetailStatus? albumDetailStatus,
    AlbumDetails? albumDetails,
    DetailStatus? artistDetailStatus,
    ArtistDetails? artistDetails,
    DetailStatus? playlistDetailStatus,
    PlaylistDetails? playlistDetails,
    DetailStatus? streamStatus,
    List<StreamSource>? streamSources,
    List<Track>? radioTracks,
    DetailStatus? homeSectionsStatus,
    List<Section>? homeSections,
    List<String>? loadingHomeSectionIds,
    String? error,
    bool clearError = false,
    bool clearSearchResults = false,
    bool clearAlbumDetails = false,
    bool clearArtistDetails = false,
    bool clearPlaylistDetails = false,
    bool clearStreams = false,
    bool clearRadioTracks = false,
    bool clearHomeSections = false,
    bool clearActivePluginId = false,
  }) {
    return ContentState(
      activePluginId:
          clearActivePluginId ? null : (activePluginId ?? this.activePluginId),
      searchStatus: searchStatus ?? this.searchStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      searchFilter: searchFilter ?? this.searchFilter,
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
      streamSources:
          clearStreams ? null : (streamSources ?? this.streamSources),
      radioTracks: clearRadioTracks ? null : (radioTracks ?? this.radioTracks),
      homeSectionsStatus: homeSectionsStatus ?? this.homeSectionsStatus,
      homeSections:
          clearHomeSections ? null : (homeSections ?? this.homeSections),
      loadingHomeSectionIds:
          loadingHomeSectionIds ?? this.loadingHomeSectionIds,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool isHomeSectionLoading(String sectionId) =>
      loadingHomeSectionIds.contains(sectionId);

  @override
  List<Object?> get props => [
        activePluginId,
        searchStatus,
        searchQuery,
        searchFilter,
        searchResults,
        albumDetailStatus,
        albumDetails,
        artistDetailStatus,
        artistDetails,
        playlistDetailStatus,
        playlistDetails,
        streamStatus,
        streamSources,
        radioTracks,
        homeSectionsStatus,
        homeSections,
        loadingHomeSectionIds,
        error,
      ];
}

enum SearchStatus { initial, loading, loadingMore, loaded, error }

enum DetailStatus { initial, loading, loaded, loadingMore, error }
