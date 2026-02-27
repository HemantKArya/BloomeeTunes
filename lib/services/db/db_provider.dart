import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/backup_validator.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

/// Centralised Isar lifecycle manager.
///
/// Owns database open / close / backup-restore responsibilities that were
/// previously scattered across the legacy monolith.
class DBProvider {
  static late String appSuppDir;
  static late String appDocDir;
  static late Future<Isar> db;

  static final List<CollectionSchema<dynamic>> _schemas = [
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
  ];

  /// Initialise path state and open the database.
  static Future<Isar> init({
    required String appSupportPath,
    required String appDocumentsPath,
  }) {
    appSuppDir = appSupportPath;
    appDocDir = appDocumentsPath;
    db = openDB();
    return db;
  }

  /// Check for DB backup file and restore when the primary DB is missing.
  static Future<void> checkAndRestoreDB(
      String dbPath, List<String> bPaths) async {
    try {
      final File dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        for (var element in bPaths) {
          final File backUpFile = File(element);
          if (await backUpFile.exists()) {
            await backUpFile.copy(dbFile.path);
            log("DB Restored from $element", name: "DBProvider");
            break;
          }
        }
      }
    } catch (e) {
      log("Failed to restore DB", error: e, name: "DBProvider");
    }
  }

  /// Open (or return existing) Isar instance.
  static Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final File dbFile = File(p.join(appSuppDir, 'default.isar'));
      if (!await dbFile.exists()) {
        await checkAndRestoreDB(dbFile.path, [
          p.join(appDocDir, 'default.isar'),
          p.join(appDocDir, 'bloomee_backup_db.isar'),
          p.join(appSuppDir, 'bloomee_backup_db.isar'),
        ]);
      }

      // Migrate DB from documents dir to support dir if needed
      if (!await dbFile.exists() &&
          await File(p.join(appDocDir, 'default.isar')).exists()) {
        final tempDb = Isar.openSync(_schemas, directory: appDocDir);
        tempDb.copyToFile(dbFile.path);
        log("DB Copied to $appSuppDir", name: "DBProvider");
        tempDb.close();
      }

      log(appSuppDir, name: "DB");
      return Isar.openSync(_schemas, directory: appSuppDir);
    }
    return Future.value(Isar.getInstance());
  }

  /// Schedule periodic maintenance tasks (called once during bootstrap).
  static void scheduleMaintenance() {
    // Ensure the standard "Liked" playlist exists.
    PlaylistDAO(db).addPlaylist(MediaPlaylistDB(playlistName: likedPlaylist));

    Future.delayed(const Duration(seconds: 30), () async {
      final playlistDao = PlaylistDAO(db);
      final settingsDao = SettingsDAO(db);
      HistoryDAO(db).refreshRecentlyPlayed(
        getSettingStr: settingsDao.getSettingStr,
        removeMediaItemFromPlaylist: playlistDao.removeMediaItemFromPlaylist,
      );
      playlistDao.purgeUnassociatedMediaItems();
      SearchHistoryDAO(db).limitSearchHistory();
      CacheDAO(db).deleteAllYTLinks();
    });
  }

  /// Reset (clear) all collections in the database.
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
      log("DB reset successfully", name: "DBProvider");
    });
  }

  // ── Standard playlists (excluded from backup restore) ─────────────────────
  static const downloadPlaylist = '_DOWNLOADS';
  static const recentlyPlayedPlaylist = 'recently_played';
  static const likedPlaylist = 'Liked';
  static final standardPlaylists = [
    downloadPlaylist,
    recentlyPlayedPlaylist,
    likedPlaylist,
  ];

  /// Get the database backup file path.
  static Future<String> getDbBackupFilePath() async {
    String backupPath = (await getDownloadsDirectory())?.path ?? appDocDir;
    backupPath = p.join(backupPath, 'bloomeeBackup', 'bloomee_backup_db.json');
    return backupPath;
  }

  /// Check whether a backup file exists.
  static Future<bool> backupExists() async {
    try {
      String backupFile = await getDbBackupFilePath();
      final dbFile = File(backupFile);
      if (dbFile.existsSync()) {
        return true;
      }
    } catch (e) {
      log("No backup exists", error: e, name: "DBProvider");
    }
    return false;
  }

  /// Create a full JSON backup of the database.
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

      log("Backup created successfully ${backUpFile.path}", name: "DBProvider");
      return backUpFile.path;
    } catch (e) {
      log("Failed to create backup", error: e, name: "DBProvider");
    }
    return null;
  }

  /// Restore the database from a JSON backup file.
  static Future<Map<String, dynamic>> restoreDB(
    String? path, {
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
        final playlistDao = PlaylistDAO(db);
        for (var item in jsonMap["media_items"]) {
          final mediaItemDB = MediaItemDB.fromJson(item);
          for (var playlistJson in jsonDecode(item)["mediaInPlaylists"]) {
            final playlistMap = jsonDecode(playlistJson);
            final playlistName = playlistMap["playlistName"];
            if (playlistName != null &&
                ![downloadPlaylist, recentlyPlayedPlaylist]
                    .contains(playlistName)) {
              await playlistDao.addMediaItem(mediaItemDB, playlistName);
            }
          }
        }
      }
      log("DB restored successfully", name: "DBProvider");
      return {"success": true};
    }
    return {"success": false, "errors": checkResults["errors"]};
  }
}
