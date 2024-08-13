// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/utils/pallete_generator.dart';
part 'current_playlist_state.dart';

class CurrentPlaylistCubit extends Cubit<CurrentPlaylistState> {
  MediaPlaylist? mediaPlaylist;
  PaletteGenerator? paletteGenerator;
  late BloomeeDBCubit bloomeeDBCubit;
  CurrentPlaylistCubit({
    this.mediaPlaylist,
    required this.bloomeeDBCubit,
  }) : super(CurrentPlaylistInitial()) {}

  Future<void> setupPlaylist(String playlistName) async {
    emit(CurrentPlaylistLoading());
    mediaPlaylist = await bloomeeDBCubit
        .getPlaylistItems(MediaPlaylistDB(playlistName: playlistName));

    if (mediaPlaylist?.mediaItems.isNotEmpty ?? false) {
      paletteGenerator = await getPalleteFromImage(
          mediaPlaylist!.mediaItems[0].artUri.toString());
    }
    // log(paletteGenerator.toString());
    emit(state.copyWith(
        playlistName: mediaPlaylist?.playlistName,
        isFetched: true,
        mediaPlaylist: mediaPlaylist,
        mediaItem: List<MediaItemModel>.from(mediaPlaylist!.mediaItems)));
  }

  Future<List<int>> getItemOrder() async {
    return await BloomeeDBService.getPlaylistItemsRankByName(
        mediaPlaylist!.playlistName);
  }

  String getTitle() {
    return state.mediaPlaylist.playlistName;
  }

  Future<void> updatePlaylist(List<int> newOrder) async {
    final oldOrder = await getItemOrder();
    if (!listEquals(newOrder, oldOrder) &&
        mediaPlaylist != null &&
        newOrder.length >= mediaPlaylist!.mediaItems.length) {
      await BloomeeDBService.updatePltItemsRankByName(
          mediaPlaylist!.playlistName, newOrder);
      final playlist = await bloomeeDBCubit.getPlaylistItems(
          MediaPlaylistDB(playlistName: mediaPlaylist!.playlistName));
      setupPlaylist(playlist.playlistName);
    }
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
