import 'dart:developer';

import 'package:Bloomee/model/media_playlist_model.dart';
import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:isar_community/isar.dart';

/// DAO for recently played history.
class HistoryDAO {
  final Future<Isar> _db;

  const HistoryDAO(this._db);

  Future<void> putRecentlyPlayed(
    MediaItemDB mediaItemDB, {
    required Future<int?> Function(MediaItemDB, String) addMediaItem,
  }) async {
    Isar isarDB = await _db;
    int? id;
    id = await addMediaItem(mediaItemDB, "recently_played");
    MediaItemDB? item =
        isarDB.mediaItemDBs.filter().idEqualTo(id).findFirstSync();

    if (item != null) {
      RecentlyPlayedDB? recentlyPlayed = isarDB.recentlyPlayedDBs
          .filter()
          .mediaItem((q) => q.idEqualTo(item.id!))
          .findFirstSync();
      if (recentlyPlayed != null) {
        isarDB.writeTxnSync(() => isarDB.recentlyPlayedDBs
            .putSync(recentlyPlayed..lastPlayed = DateTime.now()));
      } else {
        isarDB.writeTxnSync(() => isarDB.recentlyPlayedDBs.putSync(
            RecentlyPlayedDB(lastPlayed: DateTime.now())
              ..mediaItem.value = item));
      }
    } else {
      log("Failed to add in Recently_Played", name: "DB");
    }
  }

  Future<void> refreshRecentlyPlayed({
    required Future<String?> Function(String, {String? defaultValue})
        getSettingStr,
    required Future<void> Function(MediaItemDB, MediaPlaylistDB)
        removeMediaItemFromPlaylist,
  }) async {
    Isar isarDB = await _db;
    List<int> ids = List.empty(growable: true);

    int days = int.parse((await getSettingStr(
        SettingKeys.historyClearTime,
        defaultValue: "7"))!);

    List<RecentlyPlayedDB> recentlyPlayed =
        isarDB.recentlyPlayedDBs.where().findAllSync();
    for (var element in recentlyPlayed) {
      if (DateTime.now().difference(element.lastPlayed).inDays > days) {
        await element.mediaItem.load();
        if (element.mediaItem.value != null) {
          log("Removing ${element.mediaItem.value!.title}", name: "DB");
          removeMediaItemFromPlaylist(element.mediaItem.value!,
              MediaPlaylistDB(playlistName: "recently_played"));
          ids.add(element.id!);
        } else {
          ids.add(element.id!);
        }
      }
    }
    isarDB.writeTxn(() => isarDB.recentlyPlayedDBs.deleteAll(ids));
  }

  Future<MediaPlaylist> getRecentlyPlayed({int limit = 0}) async {
    List<MediaItemModel> mediaItems = [];
    Isar isarDB = await _db;
    if (limit == 0) {
      List<RecentlyPlayedDB> recentlyPlayed =
          isarDB.recentlyPlayedDBs.where().sortByLastPlayedDesc().findAllSync();
      for (var element in recentlyPlayed) {
        if (element.mediaItem.value != null) {
          mediaItems.add(mediaItemDBToMediaItem(element.mediaItem.value!));
        }
      }
    } else {
      List<RecentlyPlayedDB> recentlyPlayed = isarDB.recentlyPlayedDBs
          .where()
          .sortByLastPlayedDesc()
          .limit(limit)
          .findAllSync();
      for (var element in recentlyPlayed) {
        if (element.mediaItem.value != null) {
          mediaItems.add(mediaItemDBToMediaItem(element.mediaItem.value!));
        }
      }
    }
    return MediaPlaylist(
        mediaItems: mediaItems, playlistName: "Recently Played");
  }

  Future<Stream<void>> watchRecentlyPlayed() async {
    Isar isarDB = await _db;
    return isarDB.recentlyPlayedDBs.watchLazy();
  }
}
