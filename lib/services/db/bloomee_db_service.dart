import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/backup_validator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:isar_community/isar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:path_provider/path_provider.dart';

class BloomeeDBService {
  static late Future<Isar> db;
  static late String appSuppDir;
  static late String appDocDir;
  static final BloomeeDBService _instance = BloomeeDBService._internal();

  // Standard Playlists
  static const downloadPlaylist = '_DOWNLOADS';
  static const recentlyPlayedPlaylist = 'recently_played';
  static const likedPlaylist = 'Liked';

  static final standardPlaylists = [
    downloadPlaylist,
    recentlyPlayedPlaylist,
    likedPlaylist,
  ];

  BloomeeDBService get instance => _instance;

  factory BloomeeDBService({String? appSuppPath, String? appDocPath}) {
    if (appSuppPath != null) {
      appSuppDir = appSuppPath;
    }
    if (appDocPath != null) {
      appDocDir = appDocPath;
    }

    return _instance;
  }

  BloomeeDBService._internal() {
    db = openDB();
    Future.delayed(const Duration(seconds: 30), () async {
      await refreshRecentlyPlayed();
      await purgeUnassociatedMediaItems();
      await limitSearchHistory();
      await deleteAllYTLinks();
    });
  }

  /// Get the database backup file path
  static Future<String> getDbBackupFilePath() async {
    String? backupPath;

    backupPath = await getSettingStr(GlobalStrConsts.backupPath);
    // if (backupPath == null || backupPath.isEmpty || backupPath == appDocDir) {
    backupPath = (await getDownloadsDirectory())?.path ?? appDocDir;
    backupPath = p.join(backupPath, 'bloomeeBackup', 'bloomee_backup_db.json');
    // }
    return backupPath;
  }

  // check for DB backup and restore automatically, when there is no DB
  static Future<void> checkAndRestoreDB(
      String dbPath, List<String> bPaths) async {
    try {
      final File dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        for (var element in bPaths) {
          final File backUpFile = File(element);
          if (await backUpFile.exists()) {
            await backUpFile.copy(dbFile.path);
            log("DB Restored from $element", name: "BloomeeDBService");
            break;
          }
        }
      }
    } catch (e) {
      log("Failed to restore DB", error: e, name: "BloomeeDBService");
    }
  }

  static Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      //check if DB exists in support directory
      final File dbFile = File(p.join(appSuppDir, 'default.isar'));
      if (!await dbFile.exists()) {
        // check for backup and restore
        await checkAndRestoreDB(dbFile.path, [
          p.join(appDocDir, 'default.isar'),
          p.join(appDocDir, 'bloomee_backup_db.isar'),
          p.join(appSuppDir, 'bloomee_backup_db.isar'),
        ]);
      }

      if (!await dbFile.exists() &&
          await File(p.join(appDocDir, 'default.isar')).exists()) {
        final _db = Isar.openSync(
          [
            MediaPlaylistDBSchema,
            MediaItemDBSchema,
            AppSettingsBoolDBSchema,
            AppSettingsStrDBSchema,
            RecentlyPlayedDBSchema,
            ChartsCacheDBSchema,
            YtLinkCacheDBSchema,
            NotificationDBSchema,
            DownloadDBSchema,
            PlaylistsInfoDBSchema,
            SavedCollectionsDBSchema,
            LyricsDBSchema,
            SearchHistoryDBSchema,
          ],
          directory: appDocDir,
        );
        _db.copyToFile(dbFile.path);
        log("DB Copied to $appSuppDir", name: "BloomeeDBService");
        _db.close();
      }

      log(appSuppDir, name: "DB");
      return Isar.openSync(
        [
          MediaPlaylistDBSchema,
          MediaItemDBSchema,
          AppSettingsBoolDBSchema,
          AppSettingsStrDBSchema,
          RecentlyPlayedDBSchema,
          ChartsCacheDBSchema,
          YtLinkCacheDBSchema,
          NotificationDBSchema,
          DownloadDBSchema,
          PlaylistsInfoDBSchema,
          SavedCollectionsDBSchema,
          LyricsDBSchema,
          SearchHistoryDBSchema,
        ],
        directory: appSuppDir,
      );
    }
    return Future.value(Isar.getInstance());
  }

  static Future<String?> createBackUp() async {
    try {
      final isar = await db;
      final packageInfo = await PackageInfo.fromPlatform();
      String backupFilePath = await getDbBackupFilePath();

      final File backUpFile = File(backupFilePath);
      final bSettings = await isar.appSettingsBoolDBs.where().findAll();
      final sSettings = await isar.appSettingsStrDBs.where().findAll();
      final playlists = await isar.mediaPlaylistDBs.where().findAll();
      final searchHistory = await isar.searchHistoryDBs.where().findAll();
      final savedCollections = await isar.savedCollectionsDBs.where().findAll();
      final plInfo = await isar.playlistsInfoDBs.where().findAll();
      final mediaItemsInPlaylists = <MediaItemDB>{};
      for (var playlist in playlists) {
        mediaItemsInPlaylists.addAll(playlist.mediaItems);
      }

      final mediaItems = mediaItemsInPlaylists.toList();

      if (await backUpFile.exists()) {
        await backUpFile.delete();
      } else {
        await backUpFile.create(recursive: true);
        await backUpFile.delete();
      }

      final jsonString = jsonEncode({
        "_meta": {
          'generated_by': 'Bloomee - Open Source Music Streaming Application',
          'version':
              'v${packageInfo.version}+${int.parse(packageInfo.buildNumber) % 1000}',
          "created_at": DateTime.now().toIso8601String(),
          "note":
              "This file is an automatically generated full backup of Bloomee. It includes playlists, search history, settings, and other app data. Manual modification is strongly discouraged and may cause data corruption. For help, visit: https://github.com/HemantKArya/BloomeeTunes."
        },
        "b_settings": bSettings.map((e) => e.toJson()).toList(),
        "s_settings": sSettings.map((e) => e.toJson()).toList(),
        "playlists": playlists.map((e) => e.toJson()).toList(),
        "search_history": searchHistory.map((e) => e.toJson()).toList(),
        "saved_collections": savedCollections.map((e) => e.toJson()).toList(),
        "pl_info": plInfo.map((e) => e.toJson()).toList(),
        "media_items": mediaItems.map((e) => e.toJson()).toList(),
      });

      await backUpFile.writeAsString(jsonString);

      log("Backup created successfully ${backUpFile.path}",
          name: "BloomeeDBService");
      return backUpFile.path;
    } catch (e) {
      log("Failed to create backup", error: e, name: "BloomeeDBService");
    }
    return null;
  }

  static Future<bool> backupExists() async {
    try {
      String backupFile = await getDbBackupFilePath();

      final dbFile = File(backupFile);
      if (dbFile.existsSync()) {
        return true;
      }
    } catch (e) {
      log("No backup exists", error: e, name: "BloomeeDBService");
    }
    return false;
  }

  static Future<Map<String, dynamic>> restoreDB(
    String? path, {
    // bool settings = true,
    bool mediaItems = true,
    bool searchHistory = true,
  }) async {
    final isar = await db;
    final filePath = path ?? await getDbBackupFilePath();
    final checkResults = await verifyBackupFile(filePath);
    final backupFile = File(filePath);

    if (checkResults["isValid"] == true && backupFile.existsSync()) {
      final jsonString = await backupFile.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      await isar.writeTxn(() async {
        // if (jsonMap.containsKey("b_settings") &&
        //     jsonMap["b_settings"] != null &&
        //     settings) {
        //   for (var item in jsonMap["b_settings"]) {
        //     await isar.appSettingsBoolDBs.put(AppSettingsBoolDB.fromJson(item));
        //   }
        // }
        // if (jsonMap.containsKey("s_settings") &&
        //     jsonMap["s_settings"] != null &&
        //     settings) {
        //   for (var item in jsonMap["s_settings"]) {
        //     await isar.appSettingsStrDBs.put(AppSettingsStrDB.fromJson(item));
        //   }
        // }
        if (jsonMap.containsKey("playlists") &&
            jsonMap["playlists"] != null &&
            mediaItems) {
          for (var item in jsonMap["playlists"]) {
            if (standardPlaylists
                .contains(MediaPlaylistDB.fromJson(item).playlistName)) {
              continue;
            }
            await isar.mediaPlaylistDBs.put(MediaPlaylistDB.fromJson(item));
          }
        }
        if (jsonMap.containsKey("search_history") &&
            jsonMap["search_history"] != null &&
            searchHistory) {
          for (var item in jsonMap["search_history"]) {
            await isar.searchHistoryDBs.put(SearchHistoryDB.fromJson(item));
          }
        }
        if (jsonMap.containsKey("saved_collections") &&
            jsonMap["saved_collections"] != null &&
            mediaItems) {
          for (var item in jsonMap["saved_collections"]) {
            await isar.savedCollectionsDBs
                .put(SavedCollectionsDB.fromJson(item));
          }
        }
        if (jsonMap.containsKey("pl_info") &&
            jsonMap["pl_info"] != null &&
            mediaItems) {
          for (var item in jsonMap["pl_info"]) {
            await isar.playlistsInfoDBs.put(PlaylistsInfoDB.fromJson(item));
          }
        }
      });
      if (jsonMap.containsKey("media_items") &&
          jsonMap["media_items"] != null &&
          mediaItems) {
        for (var item in jsonMap["media_items"]) {
          final mediaItemDB = MediaItemDB.fromJson(item);
          for (var playlistJson in jsonDecode(item)["mediaInPlaylists"]) {
            final playlistMap = jsonDecode(playlistJson);
            final playlistName = playlistMap["playlistName"];
            if (playlistName != null &&
                ![downloadPlaylist, recentlyPlayedPlaylist]
                    .contains(playlistName)) {
              await addMediaItem(mediaItemDB, playlistName);
            }
          }
        }
      }
      log("DB restored successfully", name: "BloomeeDBService");
      return {"success": true};
    }
    return {"success": false, "errors": checkResults["errors"]};
  }

  static Future<void> resetDB() async {
    Isar isarDB = await db;
    isarDB.writeTxn(() async {
      await isarDB.appSettingsBoolDBs.clear();
      await isarDB.appSettingsStrDBs.clear();
      await isarDB.mediaPlaylistDBs.clear();
      await isarDB.searchHistoryDBs.clear();
      await isarDB.savedCollectionsDBs.clear();
      await isarDB.playlistsInfoDBs.clear();
      await isarDB.mediaItemDBs.clear();
      await isarDB.recentlyPlayedDBs.clear();
      log("DB reset successfully", name: "BloomeeDBService");
    });
  }

  // Will be removed in future versions
  static Future<void> deleteAllYTLinks() async {
    Isar isarDB = await db;
    isarDB.writeTxn(() => isarDB.ytLinkCacheDBs.clear());
  }

  static Future<void> putSearchHistory(String searchQuery) async {
    Isar isarDB = await db;
    // check if already exist
    SearchHistoryDB? _searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .queryEqualTo(searchQuery)
        .findFirstSync();
    if (_searchHistoryDB != null) {
      isarDB.writeTxn(() => isarDB.searchHistoryDBs
          .put(_searchHistoryDB..lastSearched = DateTime.now()));
    } else {
      isarDB.writeTxnSync(() => isarDB.searchHistoryDBs.putSync(SearchHistoryDB(
            query: searchQuery,
            lastSearched: DateTime.now(),
          )));
    }
  }

  static Future<List<Map<String, String>>> getLastSearches(
      {int limit = 10}) async {
    Isar isarDB = await db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .where()
        .sortByLastSearchedDesc()
        .limit(limit)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.isarId.toString(),
      });
    }
    return searchHistory;
  }

  static Future<List<Map<String, String>>> getSimilarSearches(
      String query) async {
    Isar isarDB = await db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .queryContains(query)
        .sortByLastSearchedDesc()
        .limit(3)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.isarId.toString(),
      });
    }
    return searchHistory;
  }

  static Future<void> limitSearchHistory() async {
    // limit search history to 100 items
    Isar isarDB = await db;
    List<SearchHistoryDB> searchHistoryDB =
        isarDB.searchHistoryDBs.where().sortByLastSearchedDesc().findAllSync();
    if (searchHistoryDB.length > 100) {
      final idsToDelete =
          searchHistoryDB.sublist(100).map((e) => e.isarId).toList();
      isarDB.writeTxn(() => isarDB.searchHistoryDBs.deleteAll(idsToDelete));
    }
  }

  static Future<void> removeSearchHistory(String id) async {
    Isar isarDB = await db;
    isarDB.writeTxn(() => isarDB.searchHistoryDBs.delete(int.parse(id)));
  }

  static Future<void> clearAllSearchHistory() async {
    Isar isarDB = await db;
    isarDB.writeTxn(() => isarDB.searchHistoryDBs.clear());
  }

  static Future<int?> addMediaItem(
      MediaItemDB mediaItemDB, String playlistName) async {
    int? id;
    Isar isarDB = await db;
    MediaPlaylistDB mediaPlaylistDB =
        MediaPlaylistDB(playlistName: playlistName);

    // search for media item if already exists
    MediaItemDB? _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();

    // search for playlist if already exists
    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    log(_mediaPlaylistDB.toString(), name: "DB");

    if (_mediaPlaylistDB == null) {
      // create playlist if not exists
      final tmpId = await createPlaylist(playlistName);
      _mediaPlaylistDB = isarDB.mediaPlaylistDBs
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync();
      log("${_mediaPlaylistDB.toString()} ID: $tmpId", name: "DB");
    }

    // add playlist to _mediaitem
    if (_mediaitem != null) {
      // update and save existing media item
      _mediaitem.mediaInPlaylistsDB.add(_mediaPlaylistDB!);
      id = _mediaitem.id;
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem!));
    } else {
      // save given new media item
      _mediaitem = mediaItemDB;
      log("id: ${_mediaitem.id}", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      isarDB.writeTxnSync(() => id = isarDB.mediaItemDBs.putSync(_mediaitem!));
    }

    // add current rank for media item in playlist orderList
    if (!(_mediaPlaylistDB?.mediaRanks.contains(_mediaitem.id) ?? false)) {
      mediaPlaylistDB = _mediaitem.mediaInPlaylistsDB
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

    return id;
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

  static Future<void> purgeUnassociatedMediaItem(
      MediaItemDB mediaItemDB) async {
    // Remove media items that are not associated with any playlist
    if (mediaItemDB.mediaInPlaylistsDB.isEmpty) {
      log("Purging ${mediaItemDB.title}", name: "DB");
      await removeMediaItem(mediaItemDB);
    }
  }

  static Future<void> purgeUnassociatedMediaItems() async {
    // Remove media items that are not associated with any playlist
    Isar isarDB = await db;
    List<MediaItemDB> mediaItems = isarDB.mediaItemDBs.where().findAllSync();
    for (var element in mediaItems) {
      await purgeUnassociatedMediaItem(element);
    }
  }

  static Future<void> purgeUnassociatedMediaFromList(
      List<MediaItemDB> mediaItems) async {
    // purge media items that are not associated with any playlist from given list
    for (var element in mediaItems) {
      await purgeUnassociatedMediaItem(element);
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
          await removeMediaItem(_mediaitem);
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
    } else {
      log("MediaItem or MediaPlaylist is null", name: "DB");
      if (_mediaitem != null) {
        await purgeUnassociatedMediaItem(_mediaitem);
      }
    }
  }

  static Future<int?> addPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    int? id;
    if (mediaPlaylistDB.playlistName.isEmpty) {
      return null;
    }
    MediaPlaylistDB? _mediaPlaylist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylist == null) {
      id = isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
    } else {
      log("Already created", name: "DB");
      id = _mediaPlaylist.isarId;
    }
    return id;
  }

  static Future<int?> createPlaylist(
    String playlistName, {
    String? artURL,
    String? description,
    String? permaURL,
    String? source,
    String? artists,
    bool isAlbum = false,
    List<MediaItemDB> mediaItems = const [],
  }) async {
    if (playlistName.isEmpty) {
      return null;
    }

    int? id;
    MediaPlaylistDB mediaPlaylistDB = MediaPlaylistDB(
      playlistName: playlistName,
      lastUpdated: DateTime.now(),
    );
    id = await addPlaylist(mediaPlaylistDB);
    if (id != null) {
      if (mediaItems.isNotEmpty) {
        for (var element in mediaItems) {
          await addMediaItem(element, playlistName);
        }
      }
      if (artURL != null ||
          description != null ||
          permaURL != null ||
          source != null ||
          artists != null ||
          isAlbum) {
        await createPlaylistInfo(
          playlistName,
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum,
        );
      }
      log("Playlist Created: $playlistName", name: "DB");
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

  static Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    bool _res = false;

    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    if (_mediaPlaylistDB != null) {
      final mediaItems = _mediaPlaylistDB.mediaItems.map((e) => e).toList();
      isarDB.writeTxnSync(() =>
          _res = isarDB.mediaPlaylistDBs.deleteSync(mediaPlaylistDB.isarId));
      if (_res) {
        await purgeUnassociatedMediaFromList(mediaItems);
        await removePlaylistByName(mediaPlaylistDB.playlistName);
        log("${mediaPlaylistDB.playlistName} is Deleted!!", name: "DB");
      }
    }
  }

  static Future<void> removePlaylistByName(String playlistName) async {
    Isar isarDB = await db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    if (mediaPlaylistDB != null) {
      await removePlaylist(mediaPlaylistDB);
    }
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

  static Future<List<int>> getPlaylistItemsRankByName(
      String playlistName) async {
    Isar isarDB = await db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    return mediaPlaylistDB?.mediaRanks.toList() ?? [];
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

  static Future<void> updatePltItemsRankByName(
      String playlistName, List<int> rankList) async {
    Isar isarDB = await db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    if (mediaPlaylistDB != null &&
        mediaPlaylistDB.mediaItems.length >= rankList.length) {
      isarDB.writeTxnSync(() {
        mediaPlaylistDB.mediaRanks = rankList;
        isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB);
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

  static Future<List<MediaItemDB>?> getPlaylistItemsByName(
      String playlistName) async {
    Isar isarDB = await db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    return mediaPlaylistDB?.mediaItems.toList();
  }

  /// Returns list of playlist names that contain the given song (by mediaID/permaURL)
  static Future<List<String>> getPlaylistsContainingSong(String mediaId) async {
    Isar isarDB = await db;

    // Find the media item by its ID (permaURL)
    MediaItemDB? mediaItem =
        isarDB.mediaItemDBs.filter().mediaIDEqualTo(mediaId).findFirstSync();

    if (mediaItem == null) {
      return [];
    }

    // Get all playlists this media item belongs to
    final playlists = mediaItem.mediaInPlaylistsDB.toList();
    return playlists.map((p) => p.playlistName).toList();
  }

  static Future<List<MediaPlaylist>> getPlaylists4Library() async {
    Isar isarDB = await db;
    final playlists = await isarDB.mediaPlaylistDBs.where().findAll();
    List<MediaPlaylist> mediaPlaylists = [];
    for (var e in playlists) {
      PlaylistsInfoDB? info = await getPlaylistInfo(e.playlistName);
      mediaPlaylists
          .add(fromPlaylistDB2MediaPlaylist(e, playlistsInfoDB: info));
    }
    return mediaPlaylists;
  }

  static Future<Stream<void>> getPlaylistsWatcher() async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs.watchLazy(fireImmediately: true);
  }

  static Future<Stream<void>> getPlaylistWatcher(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs.watchObject(mediaPlaylistDB.isarId);
  }

  static Future<int?> createPlaylistInfo(
    String playlistName, {
    String? artURL,
    String? description,
    String? permaURL,
    String? source,
    String? artists,
    bool isAlbum = false,
  }) async {
    if (playlistName.isNotEmpty) {
      return await addPlaylistInfo(
        PlaylistsInfoDB(
          playlistName: playlistName,
          lastUpdated: DateTime.now(),
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum,
        ),
      );
    }
    return null;
  }

  static Future<int> addPlaylistInfo(PlaylistsInfoDB playlistInfoDB) async {
    Isar isarDB = await db;
    return isarDB
        .writeTxnSync(() => isarDB.playlistsInfoDBs.putSync(playlistInfoDB));
  }

  Future<void> updatePlaylistInfo(PlaylistsInfoDB playlistsInfoDB) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(() => isarDB.playlistsInfoDBs.putSync(playlistsInfoDB));
  }

  static Future<void> removePlaylistInfo(
      PlaylistsInfoDB playlistsInfoDB) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(
        () => isarDB.playlistsInfoDBs.deleteSync(playlistsInfoDB.isarId));
  }

  static Future<PlaylistsInfoDB?> getPlaylistInfo(String playlistName) async {
    Isar isarDB = await db;
    return isarDB.playlistsInfoDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
  }

  static Future<List<PlaylistsInfoDB>> getPlaylistsInfo() async {
    Isar isarDB = await db;
    return isarDB.playlistsInfoDBs.where().findAllSync();
  }

  static Future<void> removePlaylistInfoByName(String playlistName) async {
    Isar isarDB = await db;
    int c = isarDB.writeTxnSync(() => isarDB.playlistsInfoDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .deleteAllSync());
    log("$c items deleted", name: "DB");
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
      addMediaItem(mediaItemDB, "Liked");
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
    id = await addMediaItem(mediaItemDB, "recently_played");
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
    List<int> ids = List.empty(growable: true);

    int days = int.parse((await getSettingStr(GlobalStrConsts.historyClearTime,
        defaultValue: "7"))!);

    List<RecentlyPlayedDB> _recentlyPlayed =
        isarDB.recentlyPlayedDBs.where().findAllSync();
    for (var element in _recentlyPlayed) {
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
    return MediaPlaylist(
        mediaItems: mediaItems, playlistName: "Recently Played");
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
              int.parse(apiToken.settingValue2!) ||
          apiToken.settingValue2 == "0") {
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
    DownloadDB? _downloadDB = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (_downloadDB != null) {
      // update existing downloadDB
      _downloadDB.fileName = fileName;
      _downloadDB.filePath = filePath;
      _downloadDB.lastDownloaded = lastDownloaded;
      isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(_downloadDB));
      log("Updated DownloadDB for ${mediaItem.title}", name: "DB");
      return;
    }
    isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(downloadDB));
    addMediaItem(
        MediaItem2MediaItemDB(mediaItem), GlobalStrConsts.downloadPlaylist);
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
        isarDB.downloadDBs.where(sort: Sort.desc).findAllSync();
    // Sort downloaded songs by last downloaded date
    _downloadedSongs.sort((a, b) {
      final aDate = a.lastDownloaded;
      final bDate = b.lastDownloaded;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

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

  static Future<void> putNotification({
    required String title,
    required String body,
    required String type,
    String? url,
    String? payload,
    bool unique = false,
  }) async {
    Isar isarDB = await db;

    if (unique) {
      final _notification =
          isarDB.notificationDBs.filter().typeEqualTo(type).findFirstSync();
      if (_notification != null) {
        isarDB.writeTxnSync(
            () => isarDB.notificationDBs.deleteSync(_notification.id!));
      }
    }

    isarDB.writeTxnSync(
      () => isarDB.notificationDBs.putSync(
        NotificationDB(
          title: title,
          body: body,
          time: DateTime.now(),
          type: type,
          url: url,
          payload: payload,
        ),
      ),
    );
  }

  static Future<List<NotificationDB>> getNotifications() async {
    Isar isarDB = await db;
    return isarDB.notificationDBs.where().sortByTimeDesc().findAllSync();
  }

  static Future<void> clearNotifications() async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(() => isarDB.notificationDBs.where().deleteAllSync());
  }

  static Future<Stream<void>> watchNotification() async {
    Isar isarDB = await db;
    return isarDB.notificationDBs.watchLazy();
  }

  static Future<void> putOnlArtistModel(ArtistModel artistModel) async {
    Isar isarDB = await db;
    Map extra = Map.from(artistModel.extra);
    extra["country"] = artistModel.country;

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "artist",
          coverArt: artistModel.imageUrl,
          title: artistModel.name,
          subtitle: artistModel.description,
          source: artistModel.source,
          sourceId: artistModel.sourceId,
          sourceURL: artistModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  static Future<void> putOnlAlbumModel(AlbumModel albumModel) async {
    Isar isarDB = await db;
    Map extra =
        Map.from(albumModel.extra); // Create a modifiable copy of the map
    extra.addEntries([MapEntry("country", albumModel.country)]);
    extra.addEntries([MapEntry("artists", albumModel.artists)]);
    extra.addEntries([MapEntry("genre", albumModel.genre)]);
    extra.addEntries([MapEntry("language", albumModel.language)]);
    extra.addEntries([MapEntry("year", albumModel.year)]);

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "album",
          coverArt: albumModel.imageURL,
          title: albumModel.name,
          subtitle: albumModel.description,
          source: albumModel.source,
          sourceId: albumModel.sourceId,
          sourceURL: albumModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  static Future<void> putOnlPlaylistModel(
      PlaylistOnlModel playlistModel) async {
    Isar isarDB = await db;
    Map extra = Map.from(playlistModel.extra);
    extra.addEntries([MapEntry("artists", playlistModel.artists)]);
    extra.addEntries([MapEntry("language", playlistModel.language)]);
    extra.addEntries([MapEntry("year", playlistModel.year)]);

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "playlist",
          coverArt: playlistModel.imageURL,
          title: playlistModel.name,
          subtitle: playlistModel.description,
          source: playlistModel.source,
          sourceId: playlistModel.sourceId,
          sourceURL: playlistModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  static Future<List> getSavedCollections() async {
    Isar isarDB = await db;
    final savedCollections = isarDB.savedCollectionsDBs.where().findAllSync();
    List _savedCollections = [];
    for (var element in savedCollections) {
      switch (element.type) {
        case "artist":
          _savedCollections.add(formatSavedArtistOnl(element));
          break;
        case "album":
          _savedCollections.add(formatSavedAlbumOnl(element));
          break;
        case "playlist":
          _savedCollections.add(formatSavedPlaylistOnl(element));
          break;
        default:
          break;
      }
    }
    return _savedCollections;
  }

  static Future<void> removeFromSavedCollecs(String sourceID) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(
      () => isarDB.savedCollectionsDBs
          .filter()
          .sourceIdEqualTo(sourceID)
          .deleteAllSync(),
    );
  }

  static Future<bool> isInSavedCollections(String sourceID) async {
    bool value = false;
    Isar isarDB = await db;
    final item = isarDB.savedCollectionsDBs
        .filter()
        .sourceIdEqualTo(sourceID)
        .findFirstSync();
    if (item != null) {
      value = true;
    }
    return value;
  }

  static Future<Stream<void>> getSavedCollecsWatcher() async {
    Isar isarDB = await db;
    return isarDB.savedCollectionsDBs.watchLazy(fireImmediately: true);
  }

  static Future<void> putLyrics(Lyrics lyrics, {int? offset}) async {
    if (lyrics.mediaID != null) {
      Isar isarDB = await db;
      isarDB.writeTxnSync(() => isarDB.lyricsDBs.putSync(LyricsDB(
            mediaID: lyrics.mediaID!,
            sourceId: lyrics.id,
            plainLyrics: lyrics.lyricsPlain,
            syncedLyrics: lyrics.lyricsSynced,
            title: lyrics.title,
            source: "lrcnet",
            artist: lyrics.artist,
            album: lyrics.album,
            duration: double.parse(lyrics.duration ?? "0").toInt(),
            offset: offset,
            url: lyrics.url,
          )));
    }
  }

  static Future<Lyrics?> getLyrics(String mediaID) async {
    Isar isarDB = await db;
    LyricsDB? lyricsDB =
        isarDB.lyricsDBs.filter().mediaIDEqualTo(mediaID).findFirstSync();
    if (lyricsDB != null) {
      return Lyrics(
        id: lyricsDB.sourceId,
        title: lyricsDB.title,
        artist: lyricsDB.artist,
        album: lyricsDB.album,
        duration: lyricsDB.duration.toString(),
        lyricsPlain: lyricsDB.plainLyrics,
        lyricsSynced: lyricsDB.syncedLyrics,
        provider: LyricsProvider.lrcnet,
        url: lyricsDB.url,
        mediaID: lyricsDB.mediaID,
      );
    }
    return null;
  }

  static Future<void> removeLyricsById(String mediaID) async {
    Isar isarDB = await db;
    isarDB.writeTxnSync(() =>
        isarDB.lyricsDBs.filter().mediaIDEqualTo(mediaID).deleteAllSync());
  }

  /// Efficiently search for songs in library playlists by title or artist
  /// Uses direct DB filtering instead of loading all songs into memory
  static Future<List<(MediaItemModel, String)>> searchMediaItemsInLibrary(
      String query) async {
    if (query.trim().isEmpty) return [];

    Isar isarDB = await db;
    final lowerQuery = query.toLowerCase();

    // Get all media items that match the query (title or artist)
    final matchingItems = await isarDB.mediaItemDBs
        .filter()
        .group((q) => q
            .titleContains(lowerQuery, caseSensitive: false)
            .or()
            .artistContains(lowerQuery, caseSensitive: false))
        .findAll();

    // For each matching item, find which playlist(s) it belongs to
    List<(MediaItemModel, String)> results = [];
    for (final item in matchingItems) {
      // Load the links (IsarLinks are lazy loaded)
      await item.mediaInPlaylistsDB.load();

      // Check if this item is in any playlist
      final playlists = item.mediaInPlaylistsDB.toList();
      if (playlists.isNotEmpty) {
        // Skip system playlists, find first user playlist
        for (final playlist in playlists) {
          if (playlist.playlistName != recentlyPlayedPlaylist &&
              playlist.playlistName != downloadPlaylist) {
            results.add((MediaItemDB2MediaItem(item), playlist.playlistName));
            break;
          }
        }
      }
    }

    return results;
  }
}

ArtistModel formatSavedArtistOnl(SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return ArtistModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageUrl: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    country: extra["country"],
  );
}

AlbumModel formatSavedAlbumOnl(SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return AlbumModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageURL: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    country: extra["country"],
    artists: extra["artists"],
    genre: extra["genre"],
    year: extra["year"],
    extra: extra,
    language: extra["language"],
  );
}

PlaylistOnlModel formatSavedPlaylistOnl(SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return PlaylistOnlModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageURL: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    artists: extra["artists"],
    language: extra["language"],
    year: extra["year"],
    extra: extra,
  );
}
