import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

/// Handles content resolution: search, album/artist/playlist details,
/// stream URLs, home sections.
///
/// Uses Rust-generated model types directly — no converters.
///
/// Search uses debounce (300ms) + switchMap pattern via [transformer]
/// to cancel in-flight requests when the user types a new query.
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final PluginService _pluginService;

  ContentBloc({
    required PluginService pluginService,
    String? initialPluginId,
  })  : _pluginService = pluginService,
        super(ContentState(activePluginId: initialPluginId)) {
    on<SearchContent>(_onSearch, transformer: _debounceSearchTransformer());
    on<LoadMoreSearchContent>(_onLoadMoreSearch);
    on<SetActiveContentPlugin>(_onSetActivePlugin);
    on<LoadAlbumDetails>(_onLoadAlbumDetails);
    on<LoadMoreAlbumTracks>(_onLoadMoreAlbumTracks);
    on<LoadArtistDetails>(_onLoadArtistDetails);
    on<LoadMoreArtistAlbums>(_onLoadMoreArtistAlbums);
    on<LoadPlaylistDetails>(_onLoadPlaylistDetails);
    on<LoadMorePlaylistTracks>(_onLoadMorePlaylistTracks);
    on<GetStreams>(_onGetStreams);
    on<GetHomeSections>(_onGetHomeSections);
    on<LoadMoreHomeSectionItems>(_onLoadMoreHomeSectionItems);
    on<GetRadioTracks>(_onGetRadioTracks);
    on<ClearSearch>(_onClearSearch);
    on<ClearDetails>(_onClearDetails);
    on<ClearHomeSections>(_onClearHomeSections);
  }

  /// Debounce + switchMap for search events.
  ///
  /// - 300ms debounce: don't fire until user stops typing.
  /// - switchMap: cancel previous search request when a new one arrives.
  EventTransformer<SearchContent> _debounceSearchTransformer() {
    return (events, mapper) => events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(mapper);
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  Future<void> _onSearch(
    SearchContent event,
    Emitter<ContentState> emit,
  ) async {
    final pluginId = state.activePluginId;
    if (pluginId == null) {
      emit(state.copyWith(
        searchStatus: SearchStatus.error,
        error: 'No active content plugin selected',
      ));
      return;
    }

    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
        searchStatus: SearchStatus.initial,
        searchQuery: '',
        searchFilter: event.filter,
        clearSearchResults: true,
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      searchStatus: SearchStatus.loading,
      searchQuery: event.query,
      searchFilter: event.filter,
      clearError: true,
    ));

    try {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.search(
            query: event.query,
            filter: event.filter,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        search: (results) {
          emit(state.copyWith(
            searchStatus: SearchStatus.loaded,
            searchFilter: event.filter,
            searchResults: results,
          ));
        },
        // Handle unexpected response types gracefully.
        albumDetails: (_) => _unexpectedResponse(emit, 'search'),
        artistDetails: (_) => _unexpectedResponse(emit, 'search'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'search'),
        streams: (_) => _unexpectedResponse(emit, 'search'),
        moreTracks: (_) => _unexpectedResponse(emit, 'search'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'search'),
        homeSections: (_) => _unexpectedResponse(emit, 'search'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'search'),
        charts: (_) => _unexpectedResponse(emit, 'search'),
        chartDetails: (_) => _unexpectedResponse(emit, 'search'),
        ack: () => _unexpectedResponse(emit, 'search'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, SearchStatus.error);
    } catch (e, stack) {
      log('Search error', error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        searchStatus: SearchStatus.error,
        error: 'Search failed: $e',
      ));
    }
  }

  Future<void> _onLoadMoreSearch(
    LoadMoreSearchContent event,
    Emitter<ContentState> emit,
  ) async {
    final pluginId = state.activePluginId;
    final currentResults = state.searchResults;
    final query = state.searchQuery.trim();

    if (pluginId == null ||
        query.isEmpty ||
        currentResults == null ||
        state.searchStatus == SearchStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(
      searchStatus: SearchStatus.loadingMore,
      clearError: true,
    ));

    try {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.search(
            query: query,
            filter: state.searchFilter,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        search: (results) {
          emit(state.copyWith(
            searchStatus: SearchStatus.loaded,
            searchResults: PagedMediaItems(
              items: [...currentResults.items, ...results.items],
              nextPageToken: results.nextPageToken,
            ),
          ));
        },
        albumDetails: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        artistDetails: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        streams: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        moreTracks: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        homeSections: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        charts: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        chartDetails: (_) => _unexpectedResponse(emit, 'searchLoadMore'),
        ack: () => _unexpectedResponse(emit, 'searchLoadMore'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, SearchStatus.loaded);
    } catch (e, stack) {
      log(
        'Search pagination error',
        error: e,
        stackTrace: stack,
        name: 'ContentBloc',
      );
      emit(state.copyWith(
        searchStatus: SearchStatus.loaded,
        error: 'Failed to load more search results: $e',
      ));
    }
  }

  // ── Set Active Plugin ──────────────────────────────────────────────────────

  void _onSetActivePlugin(
    SetActiveContentPlugin event,
    Emitter<ContentState> emit,
  ) {
    emit(ContentState(activePluginId: event.pluginId));
  }

  // ── Album Details ──────────────────────────────────────────────────────────

  Future<void> _onLoadAlbumDetails(
    LoadAlbumDetails event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(
      albumDetailStatus: DetailStatus.loading,
      clearError: true,
    ));

    try {
      final localId = localIdOf(event.albumId) ?? event.albumId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getAlbumDetails(id: localId),
        ),
      );

      response.when(
        albumDetails: (details) {
          emit(state.copyWith(
            albumDetailStatus: DetailStatus.loaded,
            albumDetails: details,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'albumDetails'),
        artistDetails: (_) => _unexpectedResponse(emit, 'albumDetails'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'albumDetails'),
        streams: (_) => _unexpectedResponse(emit, 'albumDetails'),
        moreTracks: (_) => _unexpectedResponse(emit, 'albumDetails'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'albumDetails'),
        homeSections: (_) => _unexpectedResponse(emit, 'albumDetails'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'albumDetails'),
        charts: (_) => _unexpectedResponse(emit, 'albumDetails'),
        chartDetails: (_) => _unexpectedResponse(emit, 'albumDetails'),
        ack: () => _unexpectedResponse(emit, 'albumDetails'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, albumDetailStatus: DetailStatus.error);
    } catch (e, stack) {
      log('Album details error',
          error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        albumDetailStatus: DetailStatus.error,
        error: 'Failed to load album: $e',
      ));
    }
  }

  Future<void> _onLoadMoreAlbumTracks(
    LoadMoreAlbumTracks event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(albumDetailStatus: DetailStatus.loadingMore));

    try {
      final localId = localIdOf(event.albumId) ?? event.albumId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.moreAlbumTracks(
            id: localId,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        moreTracks: (paged) {
          final current = state.albumDetails;
          if (current != null) {
            final updatedTracks = PagedTracks(
              items: [...current.tracks.items, ...paged.items],
              nextPageToken: paged.nextPageToken,
            );
            emit(state.copyWith(
              albumDetailStatus: DetailStatus.loaded,
              albumDetails: AlbumDetails(
                summary: current.summary,
                tracks: updatedTracks,
                description: current.description,
              ),
            ));
          }
        },
        search: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        albumDetails: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        artistDetails: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        streams: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        homeSections: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        charts: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        chartDetails: (_) => _unexpectedResponse(emit, 'moreAlbumTracks'),
        ack: () => _unexpectedResponse(emit, 'moreAlbumTracks'),
      );
    } catch (e) {
      emit(state.copyWith(
        albumDetailStatus: DetailStatus.loaded,
        error: 'Failed to load more tracks: $e',
      ));
    }
  }

  // ── Artist Details ─────────────────────────────────────────────────────────

  Future<void> _onLoadArtistDetails(
    LoadArtistDetails event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(
      artistDetailStatus: DetailStatus.loading,
      clearError: true,
    ));

    try {
      final localId = localIdOf(event.artistId) ?? event.artistId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getArtistDetails(id: localId),
        ),
      );

      response.when(
        artistDetails: (details) {
          emit(state.copyWith(
            artistDetailStatus: DetailStatus.loaded,
            artistDetails: details,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'artistDetails'),
        albumDetails: (_) => _unexpectedResponse(emit, 'artistDetails'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'artistDetails'),
        streams: (_) => _unexpectedResponse(emit, 'artistDetails'),
        moreTracks: (_) => _unexpectedResponse(emit, 'artistDetails'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'artistDetails'),
        homeSections: (_) => _unexpectedResponse(emit, 'artistDetails'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'artistDetails'),
        charts: (_) => _unexpectedResponse(emit, 'artistDetails'),
        chartDetails: (_) => _unexpectedResponse(emit, 'artistDetails'),
        ack: () => _unexpectedResponse(emit, 'artistDetails'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, artistDetailStatus: DetailStatus.error);
    } catch (e, stack) {
      log('Artist details error',
          error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        artistDetailStatus: DetailStatus.error,
        error: 'Failed to load artist: $e',
      ));
    }
  }

  Future<void> _onLoadMoreArtistAlbums(
    LoadMoreArtistAlbums event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(artistDetailStatus: DetailStatus.loadingMore));

    try {
      final localId = localIdOf(event.artistId) ?? event.artistId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.moreArtistAlbums(
            id: localId,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        moreAlbums: (paged) {
          final current = state.artistDetails;
          if (current != null) {
            final updatedAlbums = PagedAlbums(
              items: [...current.albums.items, ...paged.items],
              nextPageToken: paged.nextPageToken,
            );
            emit(state.copyWith(
              artistDetailStatus: DetailStatus.loaded,
              artistDetails: ArtistDetails(
                summary: current.summary,
                topTracks: current.topTracks,
                albums: updatedAlbums,
                relatedArtists: current.relatedArtists,
                description: current.description,
              ),
            ));
          }
        },
        search: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        albumDetails: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        artistDetails: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        streams: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        moreTracks: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        homeSections: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        charts: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        chartDetails: (_) => _unexpectedResponse(emit, 'moreArtistAlbums'),
        ack: () => _unexpectedResponse(emit, 'moreArtistAlbums'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, artistDetailStatus: DetailStatus.error);
    } catch (e) {
      emit(state.copyWith(
        artistDetailStatus: DetailStatus.loaded,
        error: 'Failed to load more albums: $e',
      ));
    }
  }

  // ── Playlist Details ───────────────────────────────────────────────────────

  Future<void> _onLoadPlaylistDetails(
    LoadPlaylistDetails event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(
      playlistDetailStatus: DetailStatus.loading,
      clearError: true,
    ));

    try {
      final localId = localIdOf(event.playlistId) ?? event.playlistId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getPlaylistDetails(id: localId),
        ),
      );

      response.when(
        playlistDetails: (details) {
          emit(state.copyWith(
            playlistDetailStatus: DetailStatus.loaded,
            playlistDetails: details,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        albumDetails: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        artistDetails: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        streams: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        moreTracks: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        homeSections: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        charts: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        chartDetails: (_) => _unexpectedResponse(emit, 'playlistDetails'),
        ack: () => _unexpectedResponse(emit, 'playlistDetails'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null,
          playlistDetailStatus: DetailStatus.error);
    } catch (e, stack) {
      log('Playlist details error',
          error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        playlistDetailStatus: DetailStatus.error,
        error: 'Failed to load playlist: $e',
      ));
    }
  }

  Future<void> _onLoadMorePlaylistTracks(
    LoadMorePlaylistTracks event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(playlistDetailStatus: DetailStatus.loadingMore));

    try {
      final localId = localIdOf(event.playlistId) ?? event.playlistId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.morePlaylistTracks(
            id: localId,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        moreTracks: (paged) {
          final current = state.playlistDetails;
          if (current != null) {
            final updatedTracks = PagedTracks(
              items: [...current.tracks.items, ...paged.items],
              nextPageToken: paged.nextPageToken,
            );
            emit(state.copyWith(
              playlistDetailStatus: DetailStatus.loaded,
              playlistDetails: PlaylistDetails(
                summary: current.summary,
                tracks: updatedTracks,
                description: current.description,
              ),
            ));
          }
        },
        search: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        albumDetails: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        artistDetails: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        streams: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        homeSections: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        charts: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        chartDetails: (_) => _unexpectedResponse(emit, 'morePlaylistTracks'),
        ack: () => _unexpectedResponse(emit, 'morePlaylistTracks'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null,
          playlistDetailStatus: DetailStatus.error);
    } catch (e) {
      emit(state.copyWith(
        playlistDetailStatus: DetailStatus.loaded,
        error: 'Failed to load more tracks: $e',
      ));
    }
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  Future<void> _onGetStreams(
    GetStreams event,
    Emitter<ContentState> emit,
  ) async {
    emit(state.copyWith(
      streamStatus: DetailStatus.loading,
      clearStreams: true,
      clearError: true,
    ));

    try {
      final localId = localIdOf(event.trackId) ?? event.trackId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getStreams(id: localId),
        ),
      );

      response.when(
        streams: (tracks) {
          emit(state.copyWith(
            streamStatus: DetailStatus.loaded,
            streamSources: tracks,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'getStreams'),
        albumDetails: (_) => _unexpectedResponse(emit, 'getStreams'),
        artistDetails: (_) => _unexpectedResponse(emit, 'getStreams'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'getStreams'),
        moreTracks: (_) => _unexpectedResponse(emit, 'getStreams'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'getStreams'),
        homeSections: (_) => _unexpectedResponse(emit, 'getStreams'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'getStreams'),
        charts: (_) => _unexpectedResponse(emit, 'getStreams'),
        chartDetails: (_) => _unexpectedResponse(emit, 'getStreams'),
        ack: () => _unexpectedResponse(emit, 'getStreams'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, streamStatus: DetailStatus.error);
    } catch (e, stack) {
      log('GetStreams error', error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        streamStatus: DetailStatus.error,
        error: 'Failed to get streams: $e',
      ));
    }
  }

  // ── Home Sections ──────────────────────────────────────────────────────────

  Future<void> _onGetHomeSections(
    GetHomeSections event,
    Emitter<ContentState> emit,
  ) async {
    final pluginId = event.pluginId ?? state.activePluginId;
    if (pluginId == null) {
      emit(state.copyWith(
        homeSectionsStatus: DetailStatus.error,
        error: 'No active content plugin selected',
      ));
      return;
    }

    emit(state.copyWith(
      homeSectionsStatus: DetailStatus.loading,
      clearError: true,
    ));

    try {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: const PluginRequest.contentResolver(
          ContentResolverCommand.getHomeSections(),
        ),
      );

      response.when(
        homeSections: (sections) {
          emit(state.copyWith(
            homeSectionsStatus: DetailStatus.loaded,
            homeSections: sections,
            activePluginId: pluginId,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'homeSections'),
        albumDetails: (_) => _unexpectedResponse(emit, 'homeSections'),
        artistDetails: (_) => _unexpectedResponse(emit, 'homeSections'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'homeSections'),
        streams: (_) => _unexpectedResponse(emit, 'homeSections'),
        moreTracks: (_) => _unexpectedResponse(emit, 'homeSections'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'homeSections'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'homeSections'),
        charts: (_) => _unexpectedResponse(emit, 'homeSections'),
        chartDetails: (_) => _unexpectedResponse(emit, 'homeSections'),
        ack: () => _unexpectedResponse(emit, 'homeSections'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, homeSectionsStatus: DetailStatus.error);
    } catch (e, stack) {
      log('Home sections error',
          error: e, stackTrace: stack, name: 'ContentBloc');
      emit(state.copyWith(
        homeSectionsStatus: DetailStatus.error,
        error: 'Failed to load home sections: $e',
      ));
    }
  }

  Future<void> _onLoadMoreHomeSectionItems(
    LoadMoreHomeSectionItems event,
    Emitter<ContentState> emit,
  ) async {
    try {
      if (state.isHomeSectionLoading(event.sectionId)) {
        return;
      }

      emit(state.copyWith(
        loadingHomeSectionIds: [
          ...state.loadingHomeSectionIds,
          event.sectionId,
        ],
      ));

      final localId = localIdOf(event.sectionId) ?? event.sectionId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.loadMore(
            id: localId,
            moreLink: event.moreLink,
          ),
        ),
      );

      response.when(
        loadMoreItems: (items) {
          // Append items to the matching section.
          final currentSections = state.homeSections;
          if (currentSections != null) {
            final updated = currentSections.map((section) {
              if (section.id == event.sectionId) {
                return Section(
                  id: section.id,
                  title: section.title,
                  subtitle: section.subtitle,
                  cardType: section.cardType,
                  items: [...section.items, ...items],
                  moreLink: null,
                );
              }
              return section;
            }).toList();
            emit(state.copyWith(
              homeSections: updated,
              loadingHomeSectionIds: state.loadingHomeSectionIds
                  .where((id) => id != event.sectionId)
                  .toList(growable: false),
            ));
          }
        },
        search: (_) => _unexpectedResponse(emit, 'loadMore'),
        albumDetails: (_) => _unexpectedResponse(emit, 'loadMore'),
        artistDetails: (_) => _unexpectedResponse(emit, 'loadMore'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'loadMore'),
        streams: (_) => _unexpectedResponse(emit, 'loadMore'),
        moreTracks: (_) => _unexpectedResponse(emit, 'loadMore'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'loadMore'),
        homeSections: (_) => _unexpectedResponse(emit, 'loadMore'),
        charts: (_) => _unexpectedResponse(emit, 'loadMore'),
        chartDetails: (_) => _unexpectedResponse(emit, 'loadMore'),
        ack: () => _unexpectedResponse(emit, 'loadMore'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, homeSectionsStatus: DetailStatus.error);
      emit(state.copyWith(
        loadingHomeSectionIds: state.loadingHomeSectionIds
            .where((id) => id != event.sectionId)
            .toList(growable: false),
      ));
    } catch (e) {
      log('LoadMore error', error: e, name: 'ContentBloc');
      emit(state.copyWith(
        loadingHomeSectionIds: state.loadingHomeSectionIds
            .where((id) => id != event.sectionId)
            .toList(growable: false),
      ));
    }
  }

  // ── Radio Tracks ───────────────────────────────────────────────────────────

  Future<void> _onGetRadioTracks(
    GetRadioTracks event,
    Emitter<ContentState> emit,
  ) async {
    try {
      final localId = localIdOf(event.trackId) ?? event.trackId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getRadioTracks(
            id: localId,
            pageToken: event.pageToken,
          ),
        ),
      );

      response.when(
        moreTracks: (paged) {
          emit(state.copyWith(
            streamStatus: DetailStatus.loaded,
            radioTracks: paged.items,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'radioTracks'),
        albumDetails: (_) => _unexpectedResponse(emit, 'radioTracks'),
        artistDetails: (_) => _unexpectedResponse(emit, 'radioTracks'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'radioTracks'),
        streams: (_) => _unexpectedResponse(emit, 'radioTracks'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'radioTracks'),
        homeSections: (_) => _unexpectedResponse(emit, 'radioTracks'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'radioTracks'),
        charts: (_) => _unexpectedResponse(emit, 'radioTracks'),
        chartDetails: (_) => _unexpectedResponse(emit, 'radioTracks'),
        ack: () => _unexpectedResponse(emit, 'radioTracks'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, null, streamStatus: DetailStatus.error);
    } catch (e) {
      log('Radio tracks error', error: e, name: 'ContentBloc');
    }
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  void _onClearSearch(ClearSearch event, Emitter<ContentState> emit) {
    emit(state.copyWith(
      searchStatus: SearchStatus.initial,
      searchQuery: '',
      clearSearchResults: true,
      clearError: true,
    ));
  }

  void _onClearDetails(ClearDetails event, Emitter<ContentState> emit) {
    emit(state.copyWith(
      albumDetailStatus: DetailStatus.initial,
      artistDetailStatus: DetailStatus.initial,
      playlistDetailStatus: DetailStatus.initial,
      streamStatus: DetailStatus.initial,
      clearAlbumDetails: true,
      clearArtistDetails: true,
      clearPlaylistDetails: true,
      clearStreams: true,
      clearRadioTracks: true,
      clearError: true,
    ));
  }

  void _onClearHomeSections(
      ClearHomeSections event, Emitter<ContentState> emit) {
    emit(state.copyWith(
      homeSectionsStatus: DetailStatus.initial,
      clearHomeSections: true,
      clearActivePluginId: true,
      loadingHomeSectionIds: const [],
      clearError: true,
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _unexpectedResponse(Emitter<ContentState> emit, String context) {
    log('Unexpected response type for $context', name: 'ContentBloc');
    // Transition any currently-loading status to error so the UI
    // never gets stuck in a permanent loading state.
    emit(state.copyWith(
      error: 'Unexpected response from plugin',
      searchStatus: state.searchStatus == SearchStatus.loading
          ? SearchStatus.error
          : state.searchStatus == SearchStatus.loadingMore
              ? SearchStatus.loaded
              : null,
      albumDetailStatus: state.albumDetailStatus == DetailStatus.loading
          ? DetailStatus.error
          : state.albumDetailStatus == DetailStatus.loadingMore
              ? DetailStatus.loaded
              : null,
      artistDetailStatus: state.artistDetailStatus == DetailStatus.loading
          ? DetailStatus.error
          : state.artistDetailStatus == DetailStatus.loadingMore
              ? DetailStatus.loaded
              : null,
      playlistDetailStatus: state.playlistDetailStatus == DetailStatus.loading
          ? DetailStatus.error
          : state.playlistDetailStatus == DetailStatus.loadingMore
              ? DetailStatus.loaded
              : null,
      streamStatus: state.streamStatus == DetailStatus.loading
          ? DetailStatus.error
          : null,
      homeSectionsStatus: state.homeSectionsStatus == DetailStatus.loading
          ? DetailStatus.error
          : null,
    ));
  }

  void _handlePluginError(
    Emitter<ContentState> emit,
    PluginException e,
    SearchStatus? searchStatus, {
    DetailStatus? albumDetailStatus,
    DetailStatus? artistDetailStatus,
    DetailStatus? playlistDetailStatus,
    DetailStatus? streamStatus,
    DetailStatus? homeSectionsStatus,
  }) {
    if (e is PluginNotLoadedException) {
      GlobalEventBus.instance.emitError(
        AppError.pluginNotLoaded(pluginId: e.pluginId ?? 'unknown'),
      );
    } else if (e is PluginNotFoundException) {
      GlobalEventBus.instance.emitError(
        AppError.pluginError(
          pluginId: e.pluginId ?? 'unknown',
          message: 'Plugin not found: ${e.pluginId}',
        ),
      );
    }

    emit(state.copyWith(
      searchStatus: searchStatus,
      albumDetailStatus: albumDetailStatus,
      artistDetailStatus: artistDetailStatus,
      playlistDetailStatus: playlistDetailStatus,
      streamStatus: streamStatus,
      homeSectionsStatus: homeSectionsStatus,
      error: e.message,
    ));
  }
}
