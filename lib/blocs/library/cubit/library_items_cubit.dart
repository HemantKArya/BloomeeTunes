// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/services/db/MediaDB.dart';

import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/utils/load_Image.dart';

part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  MediaDBCubit mediaDBCubit;
  List<MediaPlaylist> mediaPlaylist = [];
  LibraryItemsState libraryItemsState =
      LibraryItemsState(playlists: List.empty(growable: true));

  LibraryItemsCubit({required this.mediaDBCubit})
      : super(LibraryItemsInitial()) {
    mediaDBCubit.refreshLibrary.listen(
      (value) {
        log(value.toString(), name: "libItemsCubit");
        if (value) {
          getAndEmitPlaylists();
          log("got refresh command", name: "libItemsCubit");
        }
      },
    );
    getAndEmitPlaylists();
  }

  Future<void> getAndEmitPlaylists() async {
    List<PlaylistItemProperties> _playlists = List.empty(growable: true);
    libraryItemsState =
        LibraryItemsState(playlists: List.empty(growable: true));

    mediaPlaylist = await mediaDBCubit.getListOfPlaylists2();

    // List<String> _playlists = List.empty(growable: true);

    // if (libraryItemsState.playlists.isNotEmpty) {
    //   for (var element in libraryItemsState.playlists) {
    //     _playlists.add(element.playlistName ?? "Unknown");
    //   }
    //   libraryItemsState.playlists = [];
    // }
    libraryItemsState.playlists.clear();
    log("emitted from library0 ${_playlists.length} - MediaPlaylists ${mediaPlaylist.length}",
        name: "libItemsCubit");

    if (mediaPlaylist.length > 0) {
      for (var element in mediaPlaylist) {
        ImageProvider _tempProvider;

        if (element.mediaItems.length > 0) {
          _tempProvider =
              await getImageProvider(element.mediaItems[0].artUri.toString());
        } else {
          _tempProvider = await getImageProvider("");
        }
        PlaylistItemProperties _playlistItem = PlaylistItemProperties(
            playlistName: element.albumName,
            imageProvider: _tempProvider,
            subTitle: "${element.mediaItems.length} Items");
        // libraryItemsState.playlists.add(_playlistItem);
        _playlists.add(_playlistItem);

        // libraryItemsState.playlistNames?.add(element.albumName);
        // libraryItemsState.subTitles?.add("Saavan");
      }
      if (_playlists.length == mediaPlaylist.length) {
        emit(state.copyWith(playlists: _playlists));
      }
      log("emitted from library ${_playlists.length} - MediaPlaylists ${mediaPlaylist.length}",
          name: "libItemsCubit");
    }
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      mediaDBCubit.removePlaylist(mediaPlaylistDB);
      getAndEmitPlaylists();
    }
  }
}
