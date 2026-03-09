import 'dart:developer';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';

/// Centralised Isar lifecycle manager.
///
/// Owns database open / close / backup-restore responsibilities that were
/// previously scattered across the legacy monolith.
class DBProvider {
  static late String appSuppDir;
  static late String appDocDir;
  static late Future<Isar> db;

  static final List<CollectionSchema<dynamic>> _schemas = [
    TrackDBSchema,
    SearchHistoryDBSchema,
    PlaylistEntryDBSchema,
    LyricsDBSchema,
    PlaylistDBSchema,
    NotificationsDBSchema,
    PlaybackHistoryDBSchema,
    AppSettingsBoolDBSchema,
    AppSettingsStrDBSchema,
    DownloadDBSchema,
    CacheEntryDBSchema,
    PluginStorageEntitySchema,
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
      final File dbFile = File(p.join(appSuppDir, 'dbv3.isar'));
      if (!await dbFile.exists()) {
        await checkAndRestoreDB(dbFile.path, [
          p.join(appDocDir, 'dbv3.isar'),
          p.join(appDocDir, 'bloomee_backup_dbv3.isar'),
          p.join(appSuppDir, 'bloomee_backup_dbv3.isar'),
        ]);
      }

      // Migrate DB from documents dir to support dir if needed
      if (!await dbFile.exists() &&
          await File(p.join(appDocDir, 'dbv3.isar')).exists()) {
        final tempDb = Isar.openSync(_schemas, directory: appDocDir);
        tempDb.copyToFile(dbFile.path);
        log("DB Copied to $appSuppDir", name: "DBProvider");
        tempDb.close();
      }

      log(appSuppDir, name: "DB");
      return Isar.openSync(_schemas, directory: appSuppDir, name: 'dbv3');
    }
    return Future.value(Isar.getInstance());
  }

  /// Schedule periodic maintenance tasks (called once during bootstrap).
  ///
  /// - Ensures the "Liked" and "_DOWNLOADS" system playlists exist.
  /// - After a 30-second delay: purges old history, orphan tracks, expired
  ///   cache, and limits search history.
  static void scheduleMaintenance() {
    final trackDAO = TrackDAO(db);
    final playlistDAO = PlaylistDAO(db, trackDAO);
    final historyDAO = HistoryDAO(db, trackDAO);
    final settingsDAO = SettingsDAO(db);
    final cacheDAO = CacheDAO(db);
    final searchHistoryDAO = SearchHistoryDAO(db);

    // Ensure standard playlists exist during startup.
    playlistDAO.ensurePlaylist(likedPlaylist);
    playlistDAO.ensurePlaylist(downloadPlaylist);
    playlistDAO.ensurePlaylist(localMusicPlaylist);

    Future.delayed(const Duration(seconds: 30), () async {
      // Read configured history retention days.
      final daysStr = await settingsDAO.getSettingStr(
            'historyClearTime',
            defaultValue: '7',
          ) ??
          '7';
      final days = int.tryParse(daysStr) ?? 7;

      await historyDAO.purgeOldHistory(days);
      await trackDAO.purgeOrphanTracks();
      await cacheDAO.purgeExpiredCache();
      await searchHistoryDAO.limitSearchHistory();
      log('Scheduled maintenance complete', name: 'DBProvider');
    });
  }

  /// Reset (clear) all collections in the database.
  static Future<void> resetDB() async {
    Isar isarDB = await db;
    isarDB.writeTxn(() async {
      await isarDB.playlistEntryDBs.clear();
      await isarDB.playlistDBs.clear();
      await isarDB.appSettingsBoolDBs.clear();
      await isarDB.appSettingsStrDBs.clear();
      await isarDB.lyricsDBs.clear();
      await isarDB.trackDBs.clear();
      await isarDB.playbackHistoryDBs.clear();
      await isarDB.searchHistoryDBs.clear();
      await isarDB.cacheEntryDBs.clear();
      await isarDB.notificationsDBs.clear();
      log("DB reset successfully", name: "DBProvider");
    });
  }

  // ── Standard playlists (excluded from backup restore) ─────────────────────
  static const downloadPlaylist = '_DOWNLOADS';
  static const recentlyPlayedPlaylist = 'recently_played';
  static const likedPlaylist = 'Liked';
  static const localMusicPlaylist = '_LOCAL_MUSIC';
  static final standardPlaylists = [
    downloadPlaylist,
    recentlyPlayedPlaylist,
    likedPlaylist,
    localMusicPlaylist,
  ];

  /// Get the database backup file path.
  static Future<String> getDbBackupFilePath() async {
    String backupPath = (await getDownloadsDirectory())?.path ?? appDocDir;
    backupPath =
        p.join(backupPath, 'bloomeeBackup', 'bloomee_backup_dbv3.json');
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

  /// Create a binary backup of the database using Isar's built-in copy.
  ///
  /// Returns the backup file path on success, or null on failure.
  static Future<String?> createBackUp() async {
    try {
      final isar = await db;
      String backupFilePath = await getDbBackupFilePath();
      // Change extension — binary Isar backup, not JSON.
      backupFilePath = backupFilePath.replaceAll('.json', '.isar');

      final backupDir = File(backupFilePath).parent;
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Isar's copyToFile creates a consistent snapshot without closing the DB.
      isar.copyToFile(backupFilePath);
      log('Backup created: $backupFilePath', name: 'DBProvider');
      return backupFilePath;
    } catch (e) {
      log('Failed to create backup', error: e, name: 'DBProvider');
    }
    return null;
  }

  /// Restore the database from a binary backup .isar file.
  ///
  /// Closes the live DB, copies the backup over the primary file, then
  /// re-opens. Returns a result map with keys `success` and optionally `error`.
  static Future<Map<String, dynamic>> restoreDB(String? path) async {
    try {
      String backupFilePath =
          path ?? (await getDbBackupFilePath()).replaceAll('.json', '.isar');
      final backupFile = File(backupFilePath);
      if (!backupFile.existsSync()) {
        return {
          'success': false,
          'error': 'Backup file not found: $backupFilePath'
        };
      }

      // Close live DB before overwriting the file.
      final isar = await db;
      await isar.close();

      final primary = File(p.join(appSuppDir, 'dbv3.isar'));
      await backupFile.copy(primary.path);

      // Re-open the DB and reassign the static future.
      db = openDB();
      await db;
      log('DB restored from $backupFilePath', name: 'DBProvider');
      return {'success': true};
    } catch (e) {
      log('Failed to restore DB', error: e, name: 'DBProvider');
      return {'success': false, 'error': e.toString()};
    }
  }
}
