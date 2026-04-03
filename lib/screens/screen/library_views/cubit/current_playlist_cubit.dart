// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:Bloomee/utils/pallete_generator.dart';

part 'current_playlist_state.dart';

/// Cubit for viewing / managing a single playlist.
///
/// Uses [PlaylistDAO.loadPlaylist] to get a fully-hydrated [Playlist].
class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  static const int _pageSize = 40;

  Playlist? _playlist;
  PaletteGenerator? _paletteGenerator;
  final PlaylistDAO _playlistDao;
  int? _playlistId;
  int _loadedCount = 0;
  bool _isFetchingPage = false;

  CurrentPlaylistCubit({
    Playlist? playlist,
    required PlaylistDAO playlistDao,
  })  : _playlist = playlist,
        _playlistDao = playlistDao,
        super(const CurrentPlaylistInitial());

  /// Load a playlist by [playlistName] and emit the loaded state.
  ///
  /// Maintains backward compatibility for existing callers.
  Future<void> setupPlaylist(String playlistName) async {
    await openPlaylist(playlistName);
  }

  /// Open a playlist with staged hydration:
  /// 1) lightweight header state
  /// 2) first page of tracks
  /// 3) load more pages on demand
  Future<void> openPlaylist(
    String playlistName, {
    bool deferFirstPage = false,
  }) async {
    emit(
      state.copyWith(
        isFetched: false,
        status: CurrentPlaylistLoadStatus.loading,
        playlist: Playlist(tracks: const [], title: playlistName),
        totalTracks: 0,
        hasMore: false,
        isLoadingMore: false,
        errorMessage: null,
      ),
    );

    _paletteGenerator = null;
    _loadedCount = 0;
    _playlistId = null;

    final playlistDB = await _playlistDao.getPlaylistByName(playlistName);
    if (playlistDB == null) {
      emit(
        state.copyWith(
          status: CurrentPlaylistLoadStatus.error,
          errorMessage: 'Playlist "$playlistName" not found',
        ),
      );
      return;
    }

    _playlistId = playlistDB.id;
    final totalTracks = await _playlistDao.getPlaylistTrackCount(playlistDB.id);
    final basePlaylist =
        playlistDBToPlaylist(playlistDB).copyWith(tracks: const []);

    _playlist = basePlaylist;

    emit(
      state.copyWith(
        isFetched: true,
        status: totalTracks == 0
            ? CurrentPlaylistLoadStatus.success
            : CurrentPlaylistLoadStatus.partial,
        playlist: basePlaylist,
        totalTracks: totalTracks,
        hasMore: totalTracks > 0,
        isLoadingMore: false,
        errorMessage: null,
      ),
    );

    if (totalTracks > 0 && !deferFirstPage) {
      await loadMoreTracks();
    }
  }

  /// Load the next track page if available.
  Future<void> loadMoreTracks() async {
    final playlistId = _playlistId;
    if (playlistId == null || _isFetchingPage || !state.hasMore) return;

    _isFetchingPage = true;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final page = await _playlistDao.getPlaylistTracksPage(
        playlistId,
        offset: _loadedCount,
        limit: _pageSize,
      );
      final pageTracks = page.map(trackDBToTrack).toList(growable: false);

      final merged = <Track>[
        ...state.playlist.tracks,
        ...pageTracks,
      ];

      _loadedCount = merged.length;
      final hasMore = _loadedCount < state.totalTracks;
      _playlist = state.playlist.copyWith(tracks: merged);

      emit(
        state.copyWith(
          playlist: _playlist,
          hasMore: hasMore,
          isLoadingMore: false,
          status: hasMore
              ? CurrentPlaylistLoadStatus.partial
              : CurrentPlaylistLoadStatus.success,
          errorMessage: null,
        ),
      );

      if (_paletteGenerator == null && merged.isNotEmpty) {
        _generatePalette(merged.first.thumbnail.url);
      }
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          status: CurrentPlaylistLoadStatus.error,
          errorMessage: error.toString(),
        ),
      );
    } finally {
      _isFetchingPage = false;
    }
  }

  Future<void> _generatePalette(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    final palette = await getPalleteFromImage(imageUrl);
    _paletteGenerator = palette;
    emit(state.copyWith());
  }

  /// Ensure all pages are loaded (needed for play-all / shuffle behavior).
  Future<Playlist> ensureAllTracksLoaded() async {
    while (state.hasMore) {
      await loadMoreTracks();
    }
    return state.playlist;
  }

  /// Optimistically removes a track from the playlist and persists to DB.
  ///
  /// Returns the removed [Track] and its index so the UI can animate removal.
  Future<(Track, int)?> removeTrack(Track track) async {
    if (_playlist == null || _playlistId == null) return null;
    final tracks = List<Track>.from(state.playlist.tracks);
    final index = tracks.indexWhere((t) => t.id == track.id);
    if (index == -1) return null;

    final removed = tracks.removeAt(index);
    _playlist = _playlist!.copyWith(tracks: tracks);

    // Emit immediately for responsive UI
    emit(
      state.copyWith(
        playlist: _playlist,
        totalTracks: (state.totalTracks - 1).clamp(0, 1 << 30),
        hasMore: _loadedCount < (state.totalTracks - 1),
      ),
    );

    // Persist to DB
    await _playlistDao.removeTrackFromPlaylist(_playlistId!, track.id);

    _loadedCount = tracks.length;

    return (removed, index);
  }

  String getTitle() => state.playlist.title;

  int getPlaylistLength() => _playlist?.tracks.length ?? 0;

  String? getPlaylistCoverArt() {
    if (_playlist != null && _playlist!.tracks.isNotEmpty) {
      return _playlist!.tracks.first.thumbnail.url;
    }
    return '';
  }

  PaletteGenerator? getCurrentPlaylistPallete() => _paletteGenerator;

  /// Persists a fully reordered track list, replacing the old DB order.
  ///
  /// This is the canonical save from the edit view: it does a clean
  /// delete-then-re-insert so gaps from prior deletions never cause
  /// the position-index mismatch that silently broke the old approach.
  Future<void> updatePlaylist(List<Track> reorderedTracks) async {
    if (_playlist == null || _playlistId == null) return;
    final fullyLoaded = await ensureAllTracksLoaded();
    final existingTracks = fullyLoaded.tracks;

    if (reorderedTracks.length != existingTracks.length) {
      throw StateError(
        'Refusing to save partial playlist reorder: expected '
        '${existingTracks.length} tracks, got ${reorderedTracks.length}.',
      );
    }

    final expectedIds = existingTracks.map((t) => t.id).toSet();
    final providedIds = reorderedTracks.map((t) => t.id).toSet();
    if (expectedIds.length != providedIds.length ||
        !expectedIds.containsAll(providedIds)) {
      throw StateError(
        'Refusing to save playlist reorder with mismatched track set.',
      );
    }

    // Optimistic in-memory update so callers see the new order immediately.
    _playlist = _playlist!.copyWith(tracks: List<Track>.from(reorderedTracks));
    _loadedCount = reorderedTracks.length;
    emit(state.copyWith(
      playlist: _playlist,
      totalTracks: reorderedTracks.length,
      hasMore: false,
      status: CurrentPlaylistLoadStatus.success,
    ));
    // Persist: full replace keeps positions contiguous and correct.
    await _playlistDao.setPlaylistTracks(_playlistId!, reorderedTracks);
  }

  /// Reorder tracks. [oldIndex] and [newIndex] are 0-based UI positions.
  Future<void> reorderTrack(int oldIndex, int newIndex) async {
    if (_playlist == null || _playlistId == null) return;
    await _playlistDao.reorderTrack(_playlistId!, oldIndex, newIndex);
    await openPlaylist(_playlist!.title);
  }

  /// Optimistically replaces [original] with [replacement] in the current
  /// playlist state without re-querying the DB.  Call this after a smart-
  /// replace operation when the DB has already been updated elsewhere, so the
  /// UI reflects the change instantly.
  void replaceTrack(Track original, Track replacement) {
    if (_playlist == null) return;
    final updated = state.playlist.tracks
        .map((t) => t.id == original.id ? replacement : t)
        .toList(growable: false);
    _playlist = _playlist!.copyWith(tracks: updated);
    emit(state.copyWith(playlist: _playlist));
  }

  /// Returns the name of the currently loaded playlist, or null if none.
  String? get currentPlaylistName => _playlist?.title;
}
