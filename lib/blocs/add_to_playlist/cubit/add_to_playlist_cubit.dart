// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';

import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/utils/load_Image.dart';

import '../../../model/MediaPlaylistModel.dart';

part 'add_to_playlist_state.dart';

class AddToPlaylistCubit extends Cubit<AddToPlaylistState> {
  BloomeeDBCubit bloomeeDBCubit;
  BehaviorSubject<MediaItemModel> mediaItemModelBS =
      BehaviorSubject.seeded(mediaItemModelNull);
  AddToPlaylistCubit({
    required this.bloomeeDBCubit,
  }) : super(AddToPlaylistInitial()) {
    getAndEmitPlaylists();
  }

  List<MediaPlaylist> mediaPlaylist = [];

  AddToPlaylistState addToPlaylistState =
      AddToPlaylistState(playlists: List.empty(growable: true));

  Future<void> getAndEmitPlaylists() async {
    addToPlaylistState =
        AddToPlaylistState(playlists: List.empty(growable: true));
    mediaPlaylist = await bloomeeDBCubit.getListOfPlaylists2();
    List<String> _playlists = List.empty(growable: true);
    if (addToPlaylistState.playlists.isNotEmpty) {
      for (var element in addToPlaylistState.playlists) {
        _playlists.add(element.playlistName ?? "Unknown");
      }
    }
    if (mediaPlaylist.length > 0) {
      for (var element in mediaPlaylist) {
        // if (_playlists.contains(element.albumName)) {
        //   int? _idx = _playlists.indexOf(element.albumName);

        //   addToPlaylistState.playlists.removeAt(_idx);
        // }
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
            subTitle: "Saavan");
        addToPlaylistState.playlists.add(_playlistItem);

        // addToPlaylistState.playlistNames?.add(element.albumName);
        // addToPlaylistState.subTitles?.add("Saavan");
      }
      emit(state.copyWith(playlists: addToPlaylistState.playlists));
      log("emitted from addtoplaylist ${_playlists.toString()} - ${addToPlaylistState.playlists.length} - MediaPlaylists ${mediaPlaylist}");
    }
  }
}
