import 'dart:developer';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';

class BloomeeDBService {
  static late Future<Isar> db;

  BloomeeDBService() {
    db = openDB();
  }

  static Future<int?> addMediaItem(
      MediaItemDB mediaItemDB, MediaPlaylistDB mediaPlaylistDB) async {
    int? _id;
    Isar isarDB = await db;
    MediaItemDB? _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    log(_mediaPlaylistDB.toString(), name: "DB");

    if (_mediaPlaylistDB == null) {
      addPlaylist(mediaPlaylistDB);
    }

    if (_mediaitem != null) {
      // log("1", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      _id = _mediaitem.id;
      // log("2", name: "DB");
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem!));
    } else {
      // log("3", name: "DB");
      MediaItemDB? _mediaitem = mediaItemDB;
      log("id: ${_mediaitem.id}", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      // log("4", name: "DB");
      isarDB.writeTxnSync(() => _id = isarDB.mediaItemDBs.putSync(_mediaitem));
    }
    _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (_mediaitem?.mediaInPlaylistsDB != null &&
        !(_mediaPlaylistDB?.mediaRanks.contains(_mediaitem!.id) ?? false)) {
      mediaPlaylistDB = _mediaitem!.mediaInPlaylistsDB
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync()!;

      List<int> _list = mediaPlaylistDB.mediaRanks.toList(growable: true);
      _list.add(_mediaitem.id!);
      mediaPlaylistDB.mediaRanks = _list;
      isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
      log(mediaPlaylistDB.mediaRanks.toString(), name: "DB");
    }

    return _id;
  }

  static Future<void> removeMediaItem(MediaItemDB mediaItemDB) async {
    Isar isarDB = await db;
    bool _res = false;
    isarDB.writeTxnSync(
        () => _res = isarDB.mediaItemDBs.deleteSync(mediaItemDB.id!));
    if (_res) {
      log("${mediaItemDB.title} is Deleted!!", name: "DB");
    }
  }

  static Future<void> removeMediaItemFromPlaylist(
      MediaItemDB mediaItemDB, MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    MediaItemDB? _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();

    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaitem != null && _mediaPlaylistDB != null) {
      if (_mediaitem.mediaInPlaylistsDB.contains(mediaPlaylistDB)) {
        _mediaitem.mediaInPlaylistsDB.remove(mediaPlaylistDB);
        log("Removed from playlist", name: "DB");
        isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem));
        if (_mediaitem.mediaInPlaylistsDB.isEmpty) {
          removeMediaItem(_mediaitem);
        }
        if (_mediaPlaylistDB.mediaRanks.contains(_mediaitem.id)) {
          // _mediaPlaylistDB.mediaRanks.indexOf(_mediaitem.id!)

          List<int> _list = _mediaPlaylistDB.mediaRanks.toList(growable: true);
          _list.remove(_mediaitem.id);
          _mediaPlaylistDB.mediaRanks = _list;
          isarDB.writeTxnSync(
              () => isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB));
        }
      }
    }

    // isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(mediaItemDB));
  }

  static Future<void> addPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylist == null) {
      isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
    } else {
      log("Already created", name: "DB");
    }
  }

  static Future<void> likeMediaItem(MediaItemDB mediaItemDB,
      {isLiked = false}) async {
    Isar isarDB = await db;
    addPlaylist(MediaPlaylistDB(playlistName: "Liked"));
    MediaItemDB? _mediaItem = isarDB.mediaItemDBs
        .filter()
        .titleEqualTo(mediaItemDB.title)
        .and()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (isLiked && _mediaItem != null) {
      addMediaItem(mediaItemDB, MediaPlaylistDB(playlistName: "Liked"));
    } else if (_mediaItem != null) {
      removeMediaItemFromPlaylist(
          mediaItemDB, MediaPlaylistDB(playlistName: "Liked"));
    }
  }

  static Future<void> reorderItemPositionInPlaylist(
      MediaPlaylistDB mediaPlaylistDB, int old_idx, int new_idx) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .where()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylistDB != null) {
      if (_mediaPlaylistDB.mediaRanks.length > old_idx &&
          _mediaPlaylistDB.mediaRanks.length > new_idx) {
        List<int> _rankList =
            _mediaPlaylistDB.mediaRanks.toList(growable: true);
        int _element = (_rankList.removeAt(old_idx));
        _rankList.insert(new_idx, _element);
        _mediaPlaylistDB.mediaRanks = _rankList;
        isarDB.writeTxnSync(
            () => isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB));
      }
    }
  }

  static Future<bool> isMediaLiked(MediaItemDB mediaItemDB) async {
    Isar isarDB = await db;
    MediaItemDB? _mediaItemDB = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (_mediaItemDB != null) {
      return (isarDB.mediaPlaylistDBs
                  .getSync(MediaPlaylistDB(playlistName: "Liked").isarId))
              ?.mediaItems
              .contains(_mediaItemDB) ??
          true;
    } else {
      return false;
    }
  }

  static Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      String _path = (await getApplicationDocumentsDirectory()).path;
      log(_path, name: "DB");
      return await Isar.open(
        [
          MediaPlaylistDBSchema,
          MediaItemDBSchema,
          AppSettingsBoolDBSchema,
          AppSettingsStrDBSchema,
          RecentlyPlayedDBSchema,
          ChartsCacheDBSchema,
        ],
        directory: _path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  static Future<Stream> getStream4MediaList(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs.watchObject(mediaPlaylistDB.isarId);
  }

  static Future<List<int>> getPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs
            .getSync(mediaPlaylistDB.isarId)
            ?.mediaRanks
            .toList() ??
        [];
  }

  static Future<void> setPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylistDB =
        isarDB.mediaPlaylistDBs.getSync(mediaPlaylistDB.isarId);
    if (_mediaPlaylistDB != null &&
        _mediaPlaylistDB.mediaItems.length >= rankList.length) {
      isarDB.writeTxnSync(() {
        _mediaPlaylistDB.mediaRanks = rankList;
        isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB);
      });
    }
  }

  static Future<List<MediaItemDB>?> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs
        .getSync(mediaPlaylistDB.isarId)
        ?.mediaItems
        .toList();
  }

  static Future<List<MediaPlaylistDB>> getPlaylists4Library() async {
    Isar isarDB = await db;
    return await isarDB.mediaPlaylistDBs.where().findAll();
  }

  static Future<Stream<void>> getPlaylistsWatcher() async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs.watchLazy(fireImmediately: true);
  }

  static Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    bool _res = false;
    isarDB.writeTxnSync(() =>
        _res = isarDB.mediaPlaylistDBs.deleteSync(mediaPlaylistDB.isarId));
    if (_res) {
      log("${mediaPlaylistDB.playlistName} is Deleted!!", name: "DB");
    }
  }

  static Future<void> putSettingStr(String key, String value) async {
    Isar isarDB = await db;
    if (key.isNotEmpty && value.isNotEmpty) {
      isarDB.writeTxnSync(() => isarDB.appSettingsStrDBs
          .putSync(AppSettingsStrDB(settingName: key, settingValue: value)));
    }
  }

  static Future<void> putSettingBool(String key, bool value) async {
    Isar isarDB = await db;
    if (key.isNotEmpty) {
      isarDB.writeTxnSync(() => isarDB.appSettingsBoolDBs
          .putSync(AppSettingsBoolDB(settingName: key, settingValue: value)));
    }
  }

  static Future<String?> getSettingStr(String key) async {
    Isar isarDB = await db;
    return isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
  }

  static Future<bool?> getSettingBool(String key) async {
    Isar isarDB = await db;
    return isarDB.appSettingsBoolDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
  }

  static Future<Stream<AppSettingsStrDB?>?> getWatcher4SettingStr(
      String key) async {
    Isar isarDB = await db;
    int? id = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.isarId;
    if (id != null) {
      return isarDB.appSettingsStrDBs.watchObject(
        id,
        fireImmediately: true,
      );
    } else {
      return null;
    }
  }

  static Future<Stream<AppSettingsBoolDB?>?> getWatcher4SettingBool(
      String key) async {
    Isar isarDB = await db;
    int? id = isarDB.appSettingsBoolDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.isarId;
    if (id != null) {
      return isarDB.appSettingsBoolDBs.watchObject(
        id,
        fireImmediately: true,
      );
    } else {
      isarDB.writeTxnSync(() => isarDB.appSettingsBoolDBs
          .putSync(AppSettingsBoolDB(settingName: key, settingValue: false)));
      return isarDB.appSettingsBoolDBs.watchObject(
        isarDB.appSettingsBoolDBs
            .filter()
            .settingNameEqualTo(key)
            .findFirstSync()!
            .isarId,
        fireImmediately: true,
      );
    }
  }

  static Future<void> putRecentlyPlayed(MediaItemDB mediaItemDB) async {
    Isar isarDB = await db;
    int? id;
    id = await addMediaItem(
        mediaItemDB, MediaPlaylistDB(playlistName: "recently_played"));
    MediaItemDB? _mediaItemDB =
        isarDB.mediaItemDBs.filter().idEqualTo(id).findFirstSync();

    if (_mediaItemDB != null) {
      RecentlyPlayedDB? _recentlyPlayed = isarDB.recentlyPlayedDBs
          .filter()
          .mediaItem((q) => q.idEqualTo(_mediaItemDB.id!))
          .findFirstSync();
      if (_recentlyPlayed != null) {
        isarDB.writeTxnSync(() => isarDB.recentlyPlayedDBs
            .putSync(_recentlyPlayed..lastPlayed = DateTime.now()));
      } else {
        isarDB.writeTxnSync(() => isarDB.recentlyPlayedDBs.putSync(
            RecentlyPlayedDB(lastPlayed: DateTime.now())
              ..mediaItem.value = _mediaItemDB));
      }
    } else {
      log("Failed to add in Recently_Played", name: "DB");
    }
  }

  static Future<void> refreshRecentlyPlayed() async {
    Isar isarDB = await db;

    List<RecentlyPlayedDB> _recentlyPlayed =
        isarDB.recentlyPlayedDBs.where().findAllSync();
    for (var element in _recentlyPlayed) {
      if (DateTime.now().difference(element.lastPlayed).inDays > 7) {
        removeMediaItemFromPlaylist(element.mediaItem.value!,
            MediaPlaylistDB(playlistName: "recently_played"));
        isarDB.writeTxnSync(
            () => isarDB.recentlyPlayedDBs.deleteSync(element.id!));
      }
    }
  }

  static Future<MediaPlaylist> getRecentlyPlayed() async {
    Isar isarDB = await db;
    List<RecentlyPlayedDB> _recentlyPlayed =
        isarDB.recentlyPlayedDBs.where().sortByLastPlayedDesc().findAllSync();
    List<MediaItemModel> _mediaItems = [];
    for (var element in _recentlyPlayed) {
      _mediaItems.add(MediaItemDB2MediaItem(element.mediaItem.value!));
    }
    return MediaPlaylist(mediaItems: _mediaItems, albumName: "Recently Played");
  }

  static Future<Stream<void>> watchRecentlyPlayed() async {
    Isar isarDB = await db;
    return isarDB.recentlyPlayedDBs.watchLazy();
  }

  static Future<void> putChart(ChartModel chartModel) async {
    log("Putting Chart", name: "DB");
    Isar isarDB = await db;
    int? _id;
    isarDB.writeTxnSync(() => _id =
        isarDB.chartsCacheDBs.putSync(chartModelToChartCacheDB(chartModel)));
    log("Chart Putted with ID: $_id", name: "DB");
  }

  static Future<ChartModel?> getChart(String chartName) async {
    Isar isarDB = await db;
    final chartCacheDB = isarDB.chartsCacheDBs
        .filter()
        .chartNameEqualTo(chartName)
        .findFirstSync();
    if (chartCacheDB != null) {
      return chartCacheDBToChartModel(chartCacheDB);
    } else {
      return null;
    }
  }

  static Future<ChartItemModel?> getFirstFromChart(String chartName) async {
    Isar isarDB = await db;
    final chartCacheDB = isarDB.chartsCacheDBs
        .filter()
        .chartNameEqualTo(chartName)
        .findFirstSync();
    if (chartCacheDB != null) {
      return chartItemDBToChartItemModel(chartCacheDB.chartItems.first);
    } else {
      return null;
    }
  }
}
