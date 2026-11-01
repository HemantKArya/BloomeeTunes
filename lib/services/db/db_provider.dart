import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:Bloomee/services/db/database_schemas.dart';

/// Owns the canonical database. Imports never replace or close this instance.
class DBProvider {
  static late String appSuppDir;
  static late String appDocDir;
  static late Future<Isar> db;
  static Timer? _maintenance;
  static Future<Isar>? _opening;

  static const schemas = databaseSchemas;

  static Future<Isar> init(
      {required String appSupportPath,
      required String appDocumentsPath}) async {
    appSuppDir = appSupportPath;
    appDocDir = appDocumentsPath;
    db = openDB();
    final instance = await db;
    final reset = File('$appSuppDir/reset_requested');
    if (await reset.exists()) {
      final request = jsonDecode(await reset.readAsString());
      final name = request is Map ? request['snapshot'] : null;
      if (request is! Map ||
          request['version'] != 1 ||
          name is! String ||
          p.basename(name) != name ||
          !name.startsWith('before_reset_') ||
          !name.endsWith('.isar')) {
        throw const FormatException(
            'Invalid reset request. Database was preserved.');
      }
      final protection = File(p.join(appSuppDir, 'backups', name));
      if (!await protection.exists() || await protection.length() == 0) {
        throw const FileSystemException(
            'Reset recovery snapshot is missing. Database was preserved.');
      }
      await _resetDB();
      await reset.delete();
    }
    return instance;
  }

  static Future<Isar> openDB() {
    final existing = Isar.getInstance('dbv3');
    if (existing != null) return Future.value(existing);
    return _opening ??= _openCanonical();
  }

  static Future<Isar> _openCanonical() async {
    try {
      await Directory(appSuppDir).create(recursive: true);
      // Do not search for, migrate, or silently restore older database files.
      return await Isar.open(schemas, directory: appSuppDir, name: 'dbv3');
    } finally {
      _opening = null;
    }
  }

  static Future<void> scheduleMaintenance({
    required Future<void> Function(Future<void> Function()) runMaintenance,
  }) async {
    _maintenance?.cancel();
    final trackDAO = TrackDAO(db);
    final playlistDAO = PlaylistDAO(db, trackDAO);
    for (final name in [likedPlaylist, downloadPlaylist, localMusicPlaylist]) {
      await playlistDAO.ensurePlaylist(name);
    }
    _maintenance = Timer(const Duration(seconds: 30), () async {
      try {
        await runMaintenance(() async {
          final days = int.tryParse(await SettingsDAO(db).getSettingStr(
                      SettingKeys.historyClearTime,
                      defaultValue: '7') ??
                  '7') ??
              7;
          if (days > 0) await HistoryDAO(db, trackDAO).purgeOldHistory(days);
          // Unlinked metadata may be the only surviving evidence of an older
          // library with broken links. Automatic maintenance must not erase it
          // before the user can inspect/recover the library.
          await CacheDAO(db).purgeExpiredCache();
          await SearchHistoryDAO(db).limitSearchHistory();
        });
      } catch (error, stack) {
        log('Database maintenance failed',
            name: 'DBProvider', error: error, stackTrace: stack);
      }
    });
  }

  static void cancelMaintenance() {
    _maintenance?.cancel();
  }

  static Future<void> _resetDB() async {
    cancelMaintenance();
    final isar = await db;
    isar.writeTxnSync(() {
      isar.clearSync();
      for (final name in [
        likedPlaylist,
        downloadPlaylist,
        localMusicPlaylist
      ]) {
        isar.playlistDBs.putSync(PlaylistDB(name: name));
      }
    });
  }

  static const downloadPlaylist = '_DOWNLOADS';
  static const recentlyPlayedPlaylist = 'recently_played';
  static const likedPlaylist = 'Liked';
  static const localMusicPlaylist = '_LOCAL_MUSIC';
  static const standardPlaylists = [
    downloadPlaylist,
    recentlyPlayedPlaylist,
    likedPlaylist,
    localMusicPlaylist
  ];
}
