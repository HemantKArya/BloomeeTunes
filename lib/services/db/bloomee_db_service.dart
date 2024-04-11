import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';

class BloomeeDBService {
  static late Future<Isar> db;

  BloomeeDBService() {
    db = openDB();
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
          YtLinkCacheDBSchema,
          DownloadDBSchema,
        ],
        directory: _path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  static Future<bool> createBackUp() async {
    try {
      final isar = await db;
      String? backUpDir;
      try {
        backUpDir = await getSettingStr(GlobalStrConsts.backupPath);
      } catch (e) {
        log(e.toString(), name: "DB");
        backUpDir = (await getApplicationSupportDirectory()).path;
      }

      final File backUpFile = File('$backUpDir/bloomee_backup_db.isar');
      if (await backUpFile.exists()) {
        await backUpFile.delete();
      }

      await isar.copyToFile('$backUpDir/bloomee_backup_db.isar');

      log("Backup created successfully ${backUpFile.path}",
          name: "BloomeeDBService");
      return true;
    } catch (e) {
      log("Failed to create backup", error: e, name: "BloomeeDBService");
    }
    return false;
  }

  static Future<bool> backupExists() async {
    try {
      String? backUpDir;
      try {
        backUpDir = await getSettingStr(GlobalStrConsts.backupPath);
      } catch (e) {
        log(e.toString(), name: "DB");
        backUpDir = (await getApplicationSupportDirectory()).path;
      }

      final dbFile = File('$backUpDir/bloomee_backup_db.isar');
      if (dbFile.existsSync()) {
        return true;
      }
    } catch (e) {
      log("No backup exists", error: e, name: "BloomeeDBService");
    }
    return false;
  }

  static Future<bool> restoreDB() async {
    try {
      final isar = await db;
      final dbDirectory = await getApplicationDocumentsDirectory();

      String? backUpDir;
      try {
        backUpDir = await getSettingStr(GlobalStrConsts.backupPath);
      } catch (e) {
        log(e.toString(), name: "DB");
        backUpDir = (await getApplicationSupportDirectory()).path;
      }

      await isar.close();

      final dbFile = File('$backUpDir/bloomee_backup_db.isar');
      final dbPath = File('${dbDirectory.path}/default.isar');

      if (await dbFile.exists()) {
        await dbFile.copy(dbPath.path);
        log("Successfully restored", name: "BloomeeDBService");
        BloomeeDBService();
        return true;
      }
    } catch (e) {
      log("Restoring DB failed", error: e, name: "BloomeeDBService");
    }
    BloomeeDBService();
    return false;
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
      final tmpId = await addPlaylist(mediaPlaylistDB);
      _mediaPlaylistDB = isarDB.mediaPlaylistDBs
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync();
      log("${_mediaPlaylistDB.toString()} ID: $tmpId", name: "DB");
    }

    if (_mediaitem != null) {
      // log("1", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(_mediaPlaylistDB!);
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

  static Future<int?> addPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    int? id;
    MediaPlaylistDB? _mediaPlaylist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylist == null) {
      isarDB.writeTxnSync(
          () => id = isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
    } else {
      log("Already created", name: "DB");
      id = _mediaPlaylist.isarId;
    }
    return id;
  }

  static Future<MediaPlaylistDB?> getPlaylist(String playlistName) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
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

  static Future<void> putAPICache(String key, String value) async {
    Isar isarDB = await db;
    if (key.isNotEmpty && value.isNotEmpty) {
      isarDB.writeTxnSync(
        () => isarDB.appSettingsStrDBs.putSync(
          AppSettingsStrDB(
            settingName: key,
            settingValue: value,
            settingValue2: "CACHE",
            lastUpdated: DateTime.now(),
          ),
        ),
      );
    }
  }

  static Future<String?> getAPICache(String key) async {
    Isar isarDB = await db;
    final apiCache = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync();
    if (apiCache != null) {
      return apiCache.settingValue;
    }
    return null;
  }

  static clearAPICache() async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(
      () => isarDB.appSettingsStrDBs
          .filter()
          .settingValue2Contains("CACHE")
          .deleteAllSync(),
    );
  }

  static Future<String?> getSettingStr(String key,
      {String? defaultValue}) async {
    Isar isarDB = await db;
    final settingValue = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
    if (settingValue != null) {
      return settingValue;
    } else {
      // if (defaultValue != null) {
      //   putSettingStr(key, defaultValue);
      // }
      return defaultValue;
    }
  }

  static Future<bool?> getSettingBool(String key, {bool? defaultValue}) async {
    Isar isarDB = await db;
    final settingValue = isarDB.appSettingsBoolDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
    if (settingValue != null) {
      return settingValue;
    } else {
      // if (defaultValue != null) {
      //   putSettingBool(key, defaultValue);
      // }
      return defaultValue;
    }
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

  static Future<void> refreshRecentlyPlayed({int days = 7}) async {
    Isar isarDB = await db;

    List<RecentlyPlayedDB> _recentlyPlayed =
        isarDB.recentlyPlayedDBs.where().findAllSync();
    for (var element in _recentlyPlayed) {
      if (DateTime.now().difference(element.lastPlayed).inDays > days) {
        removeMediaItemFromPlaylist(element.mediaItem.value!,
            MediaPlaylistDB(playlistName: "recently_played"));
        isarDB.writeTxnSync(
            () => isarDB.recentlyPlayedDBs.deleteSync(element.id!));
      }
    }
  }

  static Future<MediaPlaylist> getRecentlyPlayed({int limit = 0}) async {
    List<MediaItemModel> mediaItems = [];
    Isar isarDB = await db;
    if (limit == 0) {
      List<RecentlyPlayedDB> recentlyPlayed =
          isarDB.recentlyPlayedDBs.where().sortByLastPlayedDesc().findAllSync();
      for (var element in recentlyPlayed) {
        if (element.mediaItem.value != null) {
          mediaItems.add(MediaItemDB2MediaItem(element.mediaItem.value!));
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
          mediaItems.add(MediaItemDB2MediaItem(element.mediaItem.value!));
        }
      }
    }
    return MediaPlaylist(mediaItems: mediaItems, albumName: "Recently Played");
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

  static Future<void> putYtLinkCache(
      String id, String lowUrl, String highUrl, int expireAt) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(() => isarDB.ytLinkCacheDBs.putSync(YtLinkCacheDB(
        videoId: id, lowQURL: lowUrl, highQURL: highUrl, expireAt: expireAt)));
  }

  static Future<YtLinkCacheDB?> getYtLinkCache(String id) async {
    Isar isarDB = await db;
    return isarDB.ytLinkCacheDBs.filter().videoIdEqualTo(id).findFirstSync();
  }

  static Future<void> putApiTokenDB(
      String apiName, String token, String expireIn) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(
      () => isarDB.appSettingsStrDBs.putSync(
        AppSettingsStrDB(
          settingName: apiName,
          settingValue: token,
          settingValue2: expireIn,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  static Future<String?> getApiTokenDB(String apiName) async {
    Isar isarDB = await db;
    final apiToken = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .findFirstSync();
    if (apiToken != null) {
      if ((apiToken.lastUpdated!.difference(DateTime.now()).inSeconds + 30)
              .abs() <
          int.parse(apiToken.settingValue2!)) {
        return apiToken.settingValue;
      }
    }
    return null;
  }

  static Future<void> putDownloadDB(
      {required String fileName,
      required String filePath,
      required DateTime lastDownloaded,
      required MediaItemModel mediaItem}) async {
    DownloadDB downloadDB = DownloadDB(
      fileName: fileName,
      filePath: filePath,
      lastDownloaded: lastDownloaded,
      mediaId: mediaItem.id,
    );
    Isar isarDB = await db;
    isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(downloadDB));
    addMediaItem(MediaItem2MediaItemDB(mediaItem),
        MediaPlaylistDB(playlistName: GlobalStrConsts.downloadPlaylist));
  }

  static Future<void> removeDownloadDB(MediaItemModel mediaItem) async {
    Isar isarDB = await db;
    DownloadDB? downloadDB = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (downloadDB != null) {
      isarDB.writeTxnSync(() => isarDB.downloadDBs.deleteSync(downloadDB.id!));
      removeMediaItemFromPlaylist(MediaItem2MediaItemDB(mediaItem),
          MediaPlaylistDB(playlistName: GlobalStrConsts.downloadPlaylist));
    }

    try {
      File file = File("${downloadDB!.filePath}/${downloadDB.fileName}");
      if (file.existsSync()) {
        file.deleteSync();
        log("File Deleted: ${downloadDB.fileName}", name: "DB");
      }
    } catch (e) {
      log("Failed to delete file: ${downloadDB!.fileName}",
          error: e, name: "DB");
    }
  }

  static Future<DownloadDB?> getDownloadDB(MediaItemModel mediaItem) async {
    Isar isarDB = await db;
    final temp = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (temp != null &&
        File("${temp.filePath}/${temp.fileName}").existsSync()) {
      return temp;
    }
    return null;
  }

  static Future<void> updateDownloadDB(DownloadDB downloadDB) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(downloadDB));
  }

  static Future<List<MediaItemModel>> getDownloadedSongs() async {
    Isar isarDB = await db;
    List<DownloadDB> _downloadedSongs =
        isarDB.downloadDBs.where().findAllSync();
    List<MediaItemModel> _mediaItems = List.empty(growable: true);
    for (var element in _downloadedSongs) {
      if (File("${element.filePath}/${element.fileName}").existsSync()) {
        log("File exists", name: "DB");
        _mediaItems.add(MediaItemDB2MediaItem(isarDB.mediaItemDBs
            .filter()
            .mediaIDEqualTo(element.mediaId)
            .findFirstSync()!));
      } else {
        log("File not exists ${element.fileName} ", name: "DB");
        removeDownloadDB(MediaItemDB2MediaItem(isarDB.mediaItemDBs
            .filter()
            .mediaIDEqualTo(element.mediaId)
            .findFirstSync()!));
      }
    }
    return _mediaItems;
  }
}
