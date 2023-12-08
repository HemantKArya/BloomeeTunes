// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/MediaDB.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/utils/pallete_generator.dart';

part 'current_playlist_state.dart';

// load current playlist
// return if data is loaded or not
// provide fucntion to return length of playlist
// provide album art

class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  MediaPlaylist? mediaPlaylist;
  PaletteGenerator? paletteGenerator;
  late MediaDBCubit mediaDBCubit;
  CurrentPlaylistCubit({
    this.mediaPlaylist,
    required this.mediaDBCubit,
  }) : super(CurrentPlaylistInitial()) {}

  Future<void> loadPlaylist(String playlistName) async {
    if (mediaPlaylist !=
        await mediaDBCubit
            .getPlaylistItems(MediaPlaylistDB(playlistName: playlistName))) {
      setupPlaylist(playlistName);
    } else {
      emit(state.copyWith(
          albumName: mediaPlaylist?.albumName,
          isFetched: true,
          mediaItem: mediaPlaylist?.mediaItems));
    }
  }

  Future<void> setupPlaylist(String playlistName) async {
    emit(CurrentPlaylistLoading());
    mediaPlaylist = await mediaDBCubit
        .getPlaylistItems(MediaPlaylistDB(playlistName: playlistName));

    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      paletteGenerator = await getPalleteFromImage(
          mediaPlaylist!.mediaItems[0].artUri.toString());
    }
    // log(paletteGenerator.toString());
    emit(state.copyWith(
        albumName: mediaPlaylist?.albumName,
        isFetched: true,
        mediaItem: mediaPlaylist?.mediaItems));
  }

  int getPlaylistLength() {
    if (mediaPlaylist != null) {
      return mediaPlaylist?.mediaItems.length ?? 0;
    } else {
      return 0;
    }
  }

  String? getPlaylistCoverArt() {
    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      return mediaPlaylist?.mediaItems[0].artUri.toString();
    } else {
      return "";
    }
  }

  PaletteGenerator? getCurrentPlaylistPallete() {
    return paletteGenerator;
  }
}
