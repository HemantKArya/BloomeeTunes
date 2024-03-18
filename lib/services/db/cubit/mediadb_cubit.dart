import 'dart:developer';

import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/MediaDB.dart';
import 'package:Bloomee/services/db/MediaIsarService.dart';

part 'mediadb_state.dart';

class MediaDBCubit extends Cubit<MediadbState> {
  BehaviorSubject<bool> refreshLibrary = BehaviorSubject<bool>.seeded(false);
  MediaIsarDBService isarDBService = MediaIsarDBService();
  MediaDBCubit() : super(MediadbInitial()) {
    addNewPlaylistToDB(MediaPlaylistDB(playlistName: "Liked"));
  }

  Future<void> addNewPlaylistToDB(MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false}) async {
    List<String> _list = await getListOfPlaylists();
    if (!_list.contains(mediaPlaylistDB.playlistName)) {
      isarDBService.addPlaylist(mediaPlaylistDB);
      refreshLibrary.add(true);
      if (!undo) {
        SnackbarService.showMessage(
            "Playlist ${mediaPlaylistDB.playlistName} added");
      }
    }
  }

  MediaItemDB MediaItem2MediaItemDB(MediaItem mediaItem) {
    return MediaItemDB(
        title: mediaItem.title,
        album: mediaItem.album ?? "Unknown",
        artist: mediaItem.artist ?? "Unknown",
        artURL: mediaItem.artUri.toString(),
        genre: mediaItem.genre ?? "Unknown",
        mediaID: mediaItem.id,
        duration: mediaItem.duration?.inSeconds,
        streamingURL: mediaItem.extras?["url"],
        permaURL: mediaItem.extras?["perma_url"],
        language: mediaItem.extras?["language"] ?? "Unknown",
        isLiked: false,
        source: mediaItem.extras?["source"] ?? "Saavn");
  }

  MediaItemModel MediaItemDB2MediaItem(MediaItemDB mediaItemDB) {
    return MediaItemModel(
        id: mediaItemDB.mediaID,
        title: mediaItemDB.title,
        album: mediaItemDB.album,
        artist: mediaItemDB.artist,
        duration: mediaItemDB.duration != null
            ? Duration(seconds: mediaItemDB.duration!)
            : const Duration(seconds: 120),
        artUri: Uri.parse(mediaItemDB.artURL),
        genre: mediaItemDB.genre,
        extras: {
          "url": mediaItemDB.streamingURL,
          "source": mediaItemDB.source ?? "None",
          "perma_url": mediaItemDB.permaURL,
          "language": mediaItemDB.language,
        });
  }

  Future<void> setLike(MediaItem mediaItem, {isLiked = false}) async {
    isarDBService.addMediaItem(MediaItem2MediaItemDB(mediaItem),
        MediaPlaylistDB(playlistName: "Liked"));
    refreshLibrary.add(true);
    isarDBService.likeMediaItem(MediaItem2MediaItemDB(mediaItem),
        isLiked: isLiked);
    if (isLiked) {
      SnackbarService.showMessage("${mediaItem.title} is Liked!!");
    } else {
      SnackbarService.showMessage("${mediaItem.title} is Unliked!!");
    }
  }

  Future<bool> isLiked(MediaItem mediaItem) {
    // bool res = true;
    return isarDBService.isMediaLiked(MediaItem2MediaItemDB(mediaItem));
  }

  List<MediaItemDB> reorderByRank(
      List<MediaItemDB> orgMediaList, List<int> rankIndex) {
    // rankIndex = rankIndex.toSet().toList();
    // orgMediaList.toSet().toList();
    List<MediaItemDB> reorderedList = orgMediaList;
    orgMediaList.forEach((element) {
      log('orgMEdia - ${element.id} - ${element.title}', name: "MediaDBCubit");
    });
    log(rankIndex.toString(), name: "MediaDBCubit");
    if (rankIndex.length == orgMediaList.length) {
      reorderedList = rankIndex
          .map((e) => orgMediaList.firstWhere(
                (element) => e == element.id,
              ))
          .map((e) => e)
          .toList();
      log('ranklist length - ${rankIndex.length} org length - ${orgMediaList.length}',
          name: "MediaDBCubit");
      return reorderedList;
    } else {
      return orgMediaList;
    }
  }

  Future<MediaPlaylist> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    MediaPlaylist _mediaPlaylist =
        MediaPlaylist(mediaItems: [], albumName: mediaPlaylistDB.playlistName);

    var _dbList = await isarDBService.getPlaylistItems(mediaPlaylistDB);
    if (_dbList != null) {
      List<int> _rankList =
          await isarDBService.getPlaylistItemsRank(mediaPlaylistDB);

      if (_rankList.isNotEmpty) {
        _dbList = reorderByRank(_dbList, _rankList);
      }

      for (var element in _dbList) {
        _mediaPlaylist.mediaItems.add(MediaItemDB2MediaItem(element));
      }
    }

    return _mediaPlaylist;
  }

  Future<void> setPlayListItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    isarDBService.setPlaylistItemsRank(mediaPlaylistDB, rankList);
  }

  Future<Stream> getStreamOfPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    return await isarDBService.getStream4MediaList(mediaPlaylistDB);
  }

  Future<List<String>> getListOfPlaylists() async {
    List<String> mediaPlaylists = [];
    final _albumList = await isarDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element.playlistName);
      });
    }
    return mediaPlaylists;
  }

  MediaPlaylist fromPlaylistDB2MediaPlaylist(MediaPlaylistDB mediaPlaylistDB) {
    MediaPlaylist mediaPlaylist =
        MediaPlaylist(mediaItems: [], albumName: mediaPlaylistDB.playlistName);
    if (mediaPlaylistDB.mediaItems.isNotEmpty) {
      mediaPlaylistDB.mediaItems.forEach((element) {
        mediaPlaylist.mediaItems.add(MediaItemDB2MediaItem(element));
      });
    }
    return mediaPlaylist;
  }

  Future<List<MediaPlaylist>> getListOfPlaylists2() async {
    List<MediaPlaylist> mediaPlaylists = [];
    final _albumList = await isarDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(fromPlaylistDB2MediaPlaylist(element));
      });
    }
    return mediaPlaylists;
  }

  Future<void> reorderPositionOfItemInDB(
      String playlistName, int old_idx, int new_idx) async {
    isarDBService.reorderItemPositionInPlaylist(
        MediaPlaylistDB(playlistName: playlistName), old_idx, new_idx);
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    isarDBService.removePlaylist(mediaPlaylistDB);
    SnackbarService.showMessage("${mediaPlaylistDB.playlistName} is Deleted!!",
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Default_Theme.accentColor2,
          onPressed: () => addNewPlaylistToDB(mediaPlaylistDB, undo: true),
        ));
  }

  Future<void> removeMediaFromPlaylist(
      MediaItem mediaItem, MediaPlaylistDB mediaPlaylistDB) async {
    MediaItemDB _mediaItemDB = MediaItem2MediaItemDB(mediaItem);
    isarDBService
        .removeMediaItemFromPlaylist(_mediaItemDB, mediaPlaylistDB)
        .then((value) {
      SnackbarService.showMessage(
          "${mediaItem.title} is removed from ${mediaPlaylistDB.playlistName}!!",
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
              label: "Undo",
              textColor: Default_Theme.accentColor2,
              onPressed: () => addMediaItemToPlaylist(
                  MediaItemDB2MediaItem(_mediaItemDB), mediaPlaylistDB,
                  undo: true)));
    });
  }

  Future<void> removeMediaItemFromDB(MediaItemDB mediaItemDB) async {}

  Future<void> addMediaItemToPlaylist(
      MediaItemModel mediaItemModel, MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false}) async {
    isarDBService.addMediaItem(
        MediaItem2MediaItemDB(mediaItemModel), mediaPlaylistDB);
    refreshLibrary.add(true);
    if (!undo) {
      SnackbarService.showMessage(
          "${mediaItemModel.title} is added to ${mediaPlaylistDB.playlistName}!!");
    }
  }

  @override
  Future<void> close() async {
    refreshLibrary.close();
    super.close();
  }
}
