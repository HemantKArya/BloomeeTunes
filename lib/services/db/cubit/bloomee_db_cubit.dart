import 'dart:developer';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';

part 'bloomee_db_state.dart';

class BloomeeDBCubit extends Cubit<MediadbState> {
  // BehaviorSubject<bool> refreshLibrary = BehaviorSubject<bool>.seeded(false);
  BloomeeDBService bloomeeDBService = BloomeeDBService();
  BloomeeDBCubit() : super(MediadbInitial()) {
    addNewPlaylistToDB(MediaPlaylistDB(playlistName: "Liked"));
  }

  Future<void> addNewPlaylistToDB(MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false}) async {
    List<String> _list = await getListOfPlaylists();
    if (!_list.contains(mediaPlaylistDB.playlistName)) {
      BloomeeDBService.addPlaylist(mediaPlaylistDB);
      // refreshLibrary.add(true);
      if (!undo) {
        SnackbarService.showMessage(
            "Playlist ${mediaPlaylistDB.playlistName} added");
      }
    }
  }

  Future<void> setLike(MediaItem mediaItem, {isLiked = false}) async {
    BloomeeDBService.addMediaItem(MediaItem2MediaItemDB(mediaItem), "Liked");
    // refreshLibrary.add(true);
    BloomeeDBService.likeMediaItem(MediaItem2MediaItemDB(mediaItem),
        isLiked: isLiked);
    if (isLiked) {
      SnackbarService.showMessage("${mediaItem.title} is Liked!!");
    } else {
      SnackbarService.showMessage("${mediaItem.title} is Unliked!!");
    }
  }

  Future<bool> isLiked(MediaItem mediaItem) {
    // bool res = true;
    return BloomeeDBService.isMediaLiked(MediaItem2MediaItemDB(mediaItem));
  }

  List<MediaItemDB> reorderByRank(
      List<MediaItemDB> orgMediaList, List<int> rankIndex) {
    // Ensure rankIndex and orgMediaList are unique and non-null
    if (orgMediaList.isEmpty || rankIndex.isEmpty) {
      log('Error: One or both input lists are empty.', name: "BloomeeDBCubit");
      return orgMediaList;
    }

    if (rankIndex.length != orgMediaList.length) {
      log('Error: Mismatch in lengths of rankIndex and orgMediaList.',
          name: "BloomeeDBCubit");
      return orgMediaList;
    }

    try {
      // Create a map for quick lookup of MediaItemDB by id
      final mediaMap = {for (var item in orgMediaList) item.id: item};

      // Reorder the list based on rankIndex
      final reorderedList = rankIndex.map((id) {
        if (!mediaMap.containsKey(id)) {
          throw StateError('ID $id not found in orgMediaList.');
        }
        return mediaMap[id]!;
      }).toList();

      log('Reordered list created successfully.', name: "BloomeeDBCubit");
      return reorderedList;
    } catch (e, stackTrace) {
      log('Error during reordering: $e',
          name: "BloomeeDBCubit", stackTrace: stackTrace);
      return orgMediaList;
    }
  }

  Future<MediaPlaylist> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    MediaPlaylist _mediaPlaylist = MediaPlaylist(
        mediaItems: [], playlistName: mediaPlaylistDB.playlistName);

    var _dbList = await BloomeeDBService.getPlaylistItems(mediaPlaylistDB);
    final playlist =
        await BloomeeDBService.getPlaylist(mediaPlaylistDB.playlistName);
    final info =
        await BloomeeDBService.getPlaylistInfo(mediaPlaylistDB.playlistName);
    if (playlist != null) {
      _mediaPlaylist =
          fromPlaylistDB2MediaPlaylist(mediaPlaylistDB, playlistsInfoDB: info);

      if (_dbList != null) {
        List<int> _rankList =
            await BloomeeDBService.getPlaylistItemsRank(mediaPlaylistDB);

        if (_rankList.isNotEmpty) {
          _dbList = reorderByRank(_dbList, _rankList);
        }
        _mediaPlaylist.mediaItems.clear();

        for (var element in _dbList) {
          _mediaPlaylist.mediaItems.add(MediaItemDB2MediaItem(element));
        }
      }
    }
    return _mediaPlaylist;
  }

  Future<void> setPlayListItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    BloomeeDBService.setPlaylistItemsRank(mediaPlaylistDB, rankList);
  }

  Future<Stream> getStreamOfPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    return await BloomeeDBService.getStream4MediaList(mediaPlaylistDB);
  }

  Future<List<String>> getListOfPlaylists() async {
    List<String> mediaPlaylists = [];
    final _albumList = await BloomeeDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element.playlistName);
      });
    }
    return mediaPlaylists;
  }

  Future<List<MediaPlaylist>> getListOfPlaylists2() async {
    List<MediaPlaylist> mediaPlaylists = [];
    final _albumList = await BloomeeDBService.getPlaylists4Library();
    if (_albumList.isNotEmpty) {
      _albumList.toList().forEach((element) {
        mediaPlaylists.add(element);
      });
    }
    return mediaPlaylists;
  }

  Future<void> reorderPositionOfItemInDB(
      String playlistName, int old_idx, int new_idx) async {
    BloomeeDBService.reorderItemPositionInPlaylist(
        MediaPlaylistDB(playlistName: playlistName), old_idx, new_idx);
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    BloomeeDBService.removePlaylist(mediaPlaylistDB);
    SnackbarService.showMessage("${mediaPlaylistDB.playlistName} is Deleted!!",
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Default_Theme.accentColor2,
          onPressed: () => addNewPlaylistToDB(mediaPlaylistDB, undo: true),
        ));
  }

  Future<void> removeMediaFromPlaylist(
      MediaItem mediaItem, MediaPlaylistDB mediaPlaylistDB,
      {bool showSnackbar = true}) async {
    MediaItemDB _mediaItemDB = MediaItem2MediaItemDB(mediaItem);
    BloomeeDBService.removeMediaItemFromPlaylist(_mediaItemDB, mediaPlaylistDB)
        .then((value) {
      if (showSnackbar) {
        SnackbarService.showMessage(
            "${mediaItem.title} is removed from ${mediaPlaylistDB.playlistName}!!",
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
                label: "Undo",
                textColor: Default_Theme.accentColor2,
                onPressed: () => addMediaItemToPlaylist(
                    MediaItemDB2MediaItem(_mediaItemDB), mediaPlaylistDB,
                    undo: true)));
      }
    });
  }

  Future<int?> addMediaItemToPlaylist(
      MediaItemModel mediaItemModel, MediaPlaylistDB mediaPlaylistDB,
      {bool undo = false, bool showSnackbar = true}) async {
    final _id = await BloomeeDBService.addMediaItem(
        MediaItem2MediaItemDB(mediaItemModel), mediaPlaylistDB.playlistName);
    // refreshLibrary.add(true);
    if (!undo && showSnackbar) {
      SnackbarService.showMessage(
          "${mediaItemModel.title} is added to ${mediaPlaylistDB.playlistName}!!");
    }
    return _id;
  }

  Future<bool?> getSettingBool(String key) async {
    return await BloomeeDBService.getSettingBool(key);
  }

  Future<void> putSettingBool(String key, bool value) async {
    if (key.isNotEmpty) {
      BloomeeDBService.putSettingBool(key, value);
    }
  }

  Future<String?> getSettingStr(String key) async {
    return await BloomeeDBService.getSettingStr(key);
  }

  Future<void> putSettingStr(String key, String value) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      BloomeeDBService.putSettingStr(key, value);
    }
  }

  Future<Stream<AppSettingsStrDB?>?> getWatcher4SettingStr(String key) async {
    if (key.isNotEmpty) {
      return await BloomeeDBService.getWatcher4SettingStr(key);
    } else {
      return null;
    }
  }

  Future<Stream<AppSettingsBoolDB?>?> getWatcher4SettingBool(String key) async {
    if (key.isNotEmpty) {
      var _watcher = await BloomeeDBService.getWatcher4SettingBool(key);
      if (_watcher != null) {
        return _watcher;
      } else {
        BloomeeDBService.putSettingBool(key, false);
        return BloomeeDBService.getWatcher4SettingBool(key);
      }
    } else {
      return null;
    }
  }

  @override
  Future<void> close() async {
    // refreshLibrary.close();
    super.close();
  }
}
