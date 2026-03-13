// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:Bloomee/utils/pallete_generator.dart';

part 'current_playlist_state.dart';

/// Cubit for viewing / managing a single playlist.
///
/// Uses [PlaylistDAO.loadPlaylist] to get a fully-hydrated [Playlist].
class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  Playlist? _playlist;
  PaletteGenerator? _paletteGenerator;
  final PlaylistDAO _playlistDao;

  CurrentPlaylistCubit({
    Playlist? playlist,
    required PlaylistDAO playlistDao,
  })  : _playlist = playlist,
        _playlistDao = playlistDao,
        super(const CurrentPlaylistInitial());

  /// Load a playlist by [playlistName] and emit the loaded state.
  ///
  /// Emits playlist data immediately, then generates the palette in the
  /// background and emits again so the UI can render content before the
  /// palette is ready.
  Future<void> setupPlaylist(String playlistName) async {
    emit(const CurrentPlaylistLoading());
    _playlist = await _playlistDao.loadPlaylist(playlistName);

    // Emit data immediately so the list is visible while palette loads.
    emit(state.copyWith(
      isFetched: true,
      playlist: _playlist,
    ));

    // Generate palette in the background, then re-emit.
    if (_playlist != null && _playlist!.tracks.isNotEmpty) {
      _paletteGenerator =
          await getPalleteFromImage(_playlist!.tracks.first.thumbnail.url);
      emit(state.copyWith(playlist: _playlist));
    }
  }

  /// Optimistically removes a track from the playlist and persists to DB.
  ///
  /// Returns the removed [Track] and its index so the UI can animate removal.
  Future<(Track, int)?> removeTrack(Track track) async {
    if (_playlist == null) return null;
    final tracks = List<Track>.from(_playlist!.tracks);
    final index = tracks.indexWhere((t) => t.id == track.id);
    if (index == -1) return null;

    final removed = tracks.removeAt(index);
    _playlist = _playlist!.copyWith(tracks: tracks);

    // Emit immediately for responsive UI
    emit(state.copyWith(playlist: _playlist));

    // Persist to DB
    final playlistDB = await _playlistDao.getPlaylistByName(_playlist!.title);
    if (playlistDB != null) {
      await _playlistDao.removeTrackFromPlaylist(playlistDB.id, track.id);
    }

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
    if (_playlist == null) return;
    final playlistDB = await _playlistDao.getPlaylistByName(_playlist!.title);
    if (playlistDB == null) return;
    // Optimistic in-memory update so callers see the new order immediately.
    _playlist = _playlist!.copyWith(tracks: List<Track>.from(reorderedTracks));
    emit(state.copyWith(playlist: _playlist));
    // Persist: full replace keeps positions contiguous and correct.
    await _playlistDao.setPlaylistTracks(playlistDB.id, reorderedTracks);
  }

  /// Reorder tracks. [oldIndex] and [newIndex] are 0-based UI positions.
  Future<void> reorderTrack(int oldIndex, int newIndex) async {
    if (_playlist == null) return;
    final playlistDB = await _playlistDao.getPlaylistByName(_playlist!.title);
    if (playlistDB == null) return;
    await _playlistDao.reorderTrack(playlistDB.id, oldIndex, newIndex);
    await setupPlaylist(_playlist!.title);
  }

  /// Optimistically replaces [original] with [replacement] in the current
  /// playlist state without re-querying the DB.  Call this after a smart-
  /// replace operation when the DB has already been updated elsewhere, so the
  /// UI reflects the change instantly.
  void replaceTrack(Track original, Track replacement) {
    if (_playlist == null) return;
    final updated = _playlist!.tracks
        .map((t) => t.id == original.id ? replacement : t)
        .toList(growable: false);
    _playlist = _playlist!.copyWith(tracks: updated);
    emit(state.copyWith(playlist: _playlist));
  }

  /// Returns the name of the currently loaded playlist, or null if none.
  String? get currentPlaylistName => _playlist?.title;
}
