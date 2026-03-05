// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  Future<void> setupPlaylist(String playlistName) async {
    emit(const CurrentPlaylistLoading());
    _playlist = await _playlistDao.loadPlaylist(playlistName);

    if (_playlist != null && _playlist!.tracks.isNotEmpty) {
      _paletteGenerator =
          await getPalleteFromImage(_playlist!.tracks.first.thumbnail.url);
    }

    emit(state.copyWith(
      isFetched: true,
      playlist: _playlist,
    ));
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

  /// Returns sequential position indices for current tracks (for edit view).
  Future<List<int>> getItemOrder() async {
    return List<int>.generate(state.playlist.tracks.length, (i) => i);
  }

  /// Applies a reordered track list to the DB.
  ///
  /// [newOrder] is a list where `newOrder[i]` is the original position
  /// of the track that should now be at position `i`.
  Future<void> updatePlaylist(List<int> newOrder) async {
    if (_playlist == null) return;
    final playlistDB = await _playlistDao.getPlaylistByName(_playlist!.title);
    if (playlistDB == null) return;
    await _playlistDao.setTrackOrder(playlistDB.id, newOrder);
    await setupPlaylist(_playlist!.title);
  }

  /// Reorder tracks. [oldIndex] and [newIndex] are 0-based UI positions.
  Future<void> reorderTrack(int oldIndex, int newIndex) async {
    if (_playlist == null) return;
    final playlistDB = await _playlistDao.getPlaylistByName(_playlist!.title);
    if (playlistDB == null) return;
    await _playlistDao.reorderTrack(playlistDB.id, oldIndex, newIndex);
    await setupPlaylist(_playlist!.title);
  }
}
