import 'package:Bloomee/core/models/backup/backup_settings_policy.dart';
import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';
import 'dart:isolate';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/database_schemas.dart';
import 'package:Bloomee/core/models/backup/recovery_copy.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';

/// Portable snapshots and atomic imports. The live Isar instance is never closed.
class BackupDAO {
  final Future<Isar> _db;
  final bool _background;
  const BackupDAO(this._db) : _background = true;
  const BackupDAO._worker(this._db) : _background = false;

  /// Read a retained v3 database on a disposable copy. Legacy schema migration
  /// is intentionally unsupported; the repository snapshots the live DB first.
  static Future<LibraryRecoveryPlan> readRecoveryFile(
          String path, String supportPath, String? documentsPath) =>
      Isolate.run(() async {
        final file = File(path);
        final size = await file.length();
        if (size == 0 || size > 256 * 1024 * 1024) {
          throw const FormatException('Empty or oversized recovery database.');
        }
        final root = await Directory(p.join(supportPath, 'import_staging'))
            .create(recursive: true);
        final stage = await root.createTemp('snapshot_recovery_');
        final name = 'recovery_${p.basename(stage.path)}';
        Isar? connection;
        try {
          await file.copy(p.join(stage.path, '$name.isar'));
          connection = await Isar.open(databaseSchemas,
              directory: stage.path, name: name, inspector: false);
          final plan = readLocalRecovery(connection);
          if (plan.document.trackCount == 0 &&
              plan.document.playlistCount == 0) {
            throw const FormatException(
                'No supported v3 library data found. Pre-v3 database migration is retired.');
          }
          final resolver = DownloadFileResolver(
              supportPath: supportPath, documentsPath: documentsPath);
          final downloads = <RecoveredDownload>[];
          var unavailable = 0;
          for (var offset = 0; offset < plan.downloads.length; offset += 32) {
            final batch = plan.downloads.skip(offset).take(32).toList();
            final resolved = await Future.wait(
                batch.map((d) => resolver.resolve(d.filePath, d.fileName)));
            for (var i = 0; i < batch.length; i++) {
              final row = batch[i];
              if (resolved[i] == null) unavailable++;
              downloads.add(RecoveredDownload(
                  mediaId: row.mediaId,
                  fileName: row.fileName,
                  filePath: resolved[i] == null
                      ? row.filePath
                      : p.dirname(resolved[i]!),
                  lastDownloaded: row.lastDownloaded));
            }
          }
          return LibraryRecoveryPlan(
              document: plan.document,
              downloads: downloads,
              unavailableFiles: unavailable,
              brokenEntries: plan.brokenEntries);
        } finally {
          if (connection != null) await connection.close();
          await stage.delete(recursive: true);
        }
      });

  static Future<T> _onWorker<T>(String directory, String name,
          Future<T> Function(BackupDAO) operation) =>
      Isolate.run(() async {
        final connection = await Isar.open(databaseSchemas,
            directory: directory, name: name, inspector: false);
        try {
          return await operation(BackupDAO._worker(Future.value(connection)));
        } finally {
          await connection.close();
        }
      });

  static Future<BackupDocument> _snapshotWorker(
          String directory, String name, String? playlistName) =>
      _onWorker(
          directory, name, (dao) => dao.snapshot(playlistName: playlistName));

  static Future<Map<String, int>> _applyWorker(
          String directory,
          String name,
          BackupDocument document,
          BackupSelection selection,
          String? receiptKey,
          List<RecoveredDownload> downloads) =>
      _onWorker(
          directory,
          name,
          (dao) => dao.apply(document, selection,
              receiptKey: receiptKey, recoveredDownloads: downloads));

  static Future<void> validateInBackground(BackupDocument document) =>
      Isolate.run(() => validateEntities(document));

  static const devicePlaylists = {
    '_DOWNLOADS',
    '_LOCAL_MUSIC',
    'recently_played'
  };

  static bool isDevicePlaylist(String name) => devicePlaylists
      .any((reserved) => reserved.toLowerCase() == name.toLowerCase());

  Future<bool> hasLibraryData() async {
    final isar = await _db;
    return await isar.playlistDBs.count() > 0 ||
        await isar.trackDBs.count() > 0;
  }

  Future<BackupDocument> snapshot({String? playlistName}) async {
    final isar = await _db;
    if (_background) {
      return _snapshotWorker(isar.directory!, isar.name, playlistName);
    }
    return isar.txnSync(() {
      final tracks = <String, TrackDB>{};
      final playlists = <Map<String, dynamic>>[];
      for (final p in isar.playlistDBs.where().findAllSync()) {
        if (isDevicePlaylist(p.name)) continue;
        if (playlistName != null && p.name != playlistName) continue;
        final ids = <String>[];
        final seen = <String>{};
        for (final entry in isar.playlistEntryDBs
            .where()
            .playlistIdEqualToAnyPosition(p.id)
            .findAllSync()) {
          entry.track.loadSync();
          final t = entry.track.value;
          if (t == null) {
            throw StateError(
                'Playlist ${p.name} contains a broken track reference.');
          }
          tracks[t.mediaId] = t;
          if (seen.add(t.mediaId)) ids.add(t.mediaId);
        }
        playlists.add(_playlistMap(p)..['entries'] = ids);
      }
      if (playlistName != null && playlists.isEmpty) {
        throw StateError('Playlist not found: $playlistName');
      }
      final history = <Map<String, dynamic>>[];
      if (playlistName == null) {
        for (final h in isar.playbackHistoryDBs.where().findAllSync()) {
          h.track.loadSync();
          final t = h.track.value;
          if (t == null) continue;
          tracks[t.mediaId] = t;
          history.add({
            'mediaId': t.mediaId,
            'playedAt': h.playedAt.toUtc().toIso8601String()
          });
        }
      }
      return BackupDocument.fromMap({
        'format': BackupDocument.format,
        'schemaVersion': BackupDocument.version,
        'kind': playlistName == null ? 'backup' : 'playlist',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'tracks': tracks.values.map(_trackMap).toList(),
        'playlists': playlists,
        if (playlistName == null) ...{
          'history': history,
          'searchHistory': isar.searchHistoryDBs
              .where()
              .findAllSync()
              .map((h) => {
                    'query': h.query,
                    'lastSearched': h.lastSearched.toUtc().toIso8601String(),
                  })
              .toList(),
          'settings': [
            for (final s in isar.appSettingsStrDBs.where().findAllSync())
              if (BackupSettingsPolicy.valid(s.settingName, s.settingValue))
                {'key': s.settingName, 'value': s.settingValue},
            for (final s in isar.appSettingsBoolDBs.where().findAllSync())
              if (BackupSettingsPolicy.valid(s.settingName, s.settingValue))
                {'key': s.settingName, 'value': s.settingValue},
          ],
        },
      });
    });
  }

  /// Decode every nested entity before preview/commit, including unselected data.
  static void validateEntities(BackupDocument document) {
    for (final t in document.rows('tracks')) {
      _track(t);
    }
    for (final p in document.rows('playlists')) {
      _playlist(p);
    }
  }

  Future<Map<String, int>> apply(
      BackupDocument document, BackupSelection selection,
      {String? receiptKey,
      List<RecoveredDownload> recoveredDownloads = const []}) async {
    final isar = await _db;
    if (_background) {
      return _applyWorker(isar.directory!, isar.name, document, selection,
          receiptKey, recoveredDownloads);
    }
    validateEntities(document);
    if (recoveredDownloads.isNotEmpty &&
        (!selection.library || selection.mode != BackupImportMode.merge)) {
      throw ArgumentError('Device recovery only supports a library merge.');
    }
    final documentIds =
        document.rows('tracks').map((t) => t['mediaId']).toSet();
    if (recoveredDownloads.any((d) => !documentIds.contains(d.mediaId))) {
      throw const FormatException('Recovery download is missing its track.');
    }
    if (selection.mode == BackupImportMode.replace &&
        !document.allowsReplacement) {
      throw const FormatException(
          'Legacy files support new-copy or merge import only.');
    }
    final trackRows = document.rows('tracks').map(_track).toList();
    final playlistRows = document.rows('playlists').map(_playlist).toList();
    return isar.writeTxnSync(() {
      if (receiptKey != null &&
          isar.appSettingsBoolDBs
                  .filter()
                  .settingNameEqualTo(receiptKey)
                  .findFirstSync() !=
              null) {
        return {
          'addedTracks': 0,
          'addedPlaylists': 0,
          'addedEntries': 0,
          'addedHistory': 0,
          'addedSearches': 0,
          'addedDownloads': 0,
          'changedSettings': 0
        };
      }
      var addedTracks = 0;
      var addedPlaylists = 0;
      var addedEntries = 0;
      var addedHistory = 0;
      var addedSearches = 0;
      var changedSettings = 0;
      var addedDownloads = 0;
      final wantsHistory = selection.history &&
          (document.has('history') || document.has('searchHistory'));
      final tracks = <String, TrackDB>{};
      final needed = <String>{
        for (final d in recoveredDownloads) d.mediaId,
        if (selection.library)
          for (final p in document.rows('playlists'))
            if (!isDevicePlaylist(p['name'] as String))
              ...(p['entries'] as List).cast<String>(),
        if (wantsHistory)
          for (final h in document.rows('history')) h['mediaId'] as String,
      };

      if (selection.library || wantsHistory) {
        for (final incoming in trackRows) {
          if (!needed.contains(incoming.mediaId)) continue;
          final existing = isar.trackDBs
              .filter()
              .mediaIdEqualTo(incoming.mediaId)
              .findFirstSync();
          // Existing metadata and link identity always survive a merge/import.
          final t = existing ?? incoming;
          if (existing == null) {
            t.id = isar.trackDBs.putSync(t);
            addedTracks++;
          }
          tracks[t.mediaId] = t;
        }
      }
      if (selection.library && document.has('playlists')) {
        if (selection.mode == BackupImportMode.replace) {
          for (final p in isar.playlistDBs.where().findAllSync()) {
            if (isDevicePlaylist(p.name)) continue;
            isar.playlistEntryDBs
                .filter()
                .playlistIdEqualTo(p.id)
                .deleteAllSync();
            isar.playlistDBs.deleteSync(p.id);
          }
        }
        for (var i = 0; i < playlistRows.length; i++) {
          final incoming = playlistRows[i];
          if (isDevicePlaylist(incoming.name)) continue;
          var existing = isar.playlistDBs
              .filter()
              .nameEqualTo(incoming.name, caseSensitive: false)
              .findFirstSync();
          if (selection.mode == BackupImportMode.newCopy &&
              incoming.name.toLowerCase() != 'liked') {
            final base = incoming.name;
            var n = 1;
            while (existing != null) {
              incoming.name = '$base ($n)';
              n++;
              existing = isar.playlistDBs
                  .filter()
                  .nameEqualTo(incoming.name, caseSensitive: false)
                  .findFirstSync();
            }
          }
          if (existing != null && existing.type != incoming.type) {
            throw StateError(
                'Playlist ${incoming.name} conflicts with a different collection type. Use a new copy.');
          }
          final p = existing ?? incoming;
          if (existing == null) {
            p.id = isar.playlistDBs.putSync(p);
            addedPlaylists++;
          }
          final entries = isar.playlistEntryDBs
              .where()
              .playlistIdEqualToAnyPosition(p.id)
              .findAllSync();
          final seen = <String>{};
          var nextPosition = 0;
          for (final e in entries) {
            e.track.loadSync();
            if (e.track.value != null) seen.add(e.track.value!.mediaId);
            if (e.position >= nextPosition) nextPosition = e.position + 1;
          }
          for (final id in document.rows('playlists')[i]['entries'] as List) {
            if (!seen.add(id as String)) continue;
            final e =
                PlaylistEntryDB(playlistId: p.id, position: nextPosition++)
                  ..playlist.value = p
                  ..track.value = tracks[id]!;
            isar.playlistEntryDBs.putSync(e);
            e.playlist.saveSync();
            e.track.saveSync();
            addedEntries++;
          }
          // Library subscribers watch playlist rows, so entry changes must touch
          // their parent in the same transaction.
          p.updatedAt = DateTime.now();
          isar.playlistDBs.putSync(p);
        }
      }
      if (wantsHistory) {
        if (selection.mode == BackupImportMode.replace) {
          if (document.has('history')) isar.playbackHistoryDBs.clearSync();
          if (document.has('searchHistory')) isar.searchHistoryDBs.clearSync();
        }
        final existingOccurrences = <String, int>{};
        for (final h in isar.playbackHistoryDBs.where().findAllSync()) {
          h.track.loadSync();
          final key =
              '${h.track.value?.mediaId}|${h.playedAt.toUtc().toIso8601String()}';
          existingOccurrences.update(key, (count) => count + 1,
              ifAbsent: () => 1);
        }
        final incomingOccurrences = <String, int>{};
        for (final h in document.rows('history')) {
          final at = DateTime.parse(h['playedAt'] as String).toUtc();
          final key = '${h['mediaId']}|${at.toIso8601String()}';
          final occurrence = incomingOccurrences
              .update(key, (count) => count + 1, ifAbsent: () => 1);
          if ((existingOccurrences[key] ?? 0) >= occurrence) continue;
          final row = PlaybackHistoryDB(playedAt: at)
            ..track.value = tracks[h['mediaId']]!;
          isar.playbackHistoryDBs.putSync(row);
          row.track.saveSync();
          addedHistory++;
        }
        for (final h in document.rows('searchHistory')) {
          final query = h['query'] as String;
          final existing = isar.searchHistoryDBs
              .filter()
              .queryEqualTo(query)
              .findFirstSync();
          final at = DateTime.parse(h['lastSearched'] as String).toUtc();
          if (existing != null && !at.isAfter(existing.lastSearched)) continue;
          final row = SearchHistoryDB(query: query, lastSearched: at);
          if (existing != null) row.id = existing.id;
          isar.searchHistoryDBs.putSync(row);
          addedSearches++;
        }
      }
      if (selection.settings && document.has('settings')) {
        if (selection.mode == BackupImportMode.replace) {
          for (final row in isar.appSettingsStrDBs.where().findAllSync()) {
            if (BackupSettingsPolicy.supports(row.settingName)) {
              isar.appSettingsStrDBs.deleteSync(row.id);
            }
          }
          for (final row in isar.appSettingsBoolDBs.where().findAllSync()) {
            if (BackupSettingsPolicy.supports(row.settingName)) {
              isar.appSettingsBoolDBs.deleteSync(row.id);
            }
          }
        }
        for (final s in document.rows('settings')) {
          final key = s['key'] as String;
          if (!BackupSettingsPolicy.supports(key)) continue;
          final value = s['value'];
          if (value is bool) {
            final exists = isar.appSettingsBoolDBs
                .filter()
                .settingNameEqualTo(key)
                .findFirstSync();
            if (exists == null || selection.mode == BackupImportMode.replace) {
              isar.appSettingsBoolDBs.putSync(
                  AppSettingsBoolDB(settingName: key, settingValue: value));
              changedSettings++;
            }
          } else {
            final exists = isar.appSettingsStrDBs
                .filter()
                .settingNameEqualTo(key)
                .findFirstSync();
            if (exists == null || selection.mode == BackupImportMode.replace) {
              isar.appSettingsStrDBs.putSync(AppSettingsStrDB(
                  settingName: key, settingValue: value as String));
              changedSettings++;
            }
          }
        }
      }
      for (final systemName in ['_DOWNLOADS', '_LOCAL_MUSIC']) {
        final mappings = recoveredDownloads
            .where((download) =>
                isLocalMediaId(download.mediaId) ==
                (systemName == '_LOCAL_MUSIC'))
            .toList();
        if (mappings.isEmpty) continue;
        var downloadsPlaylist = isar.playlistDBs
            .filter()
            .nameEqualTo(systemName, caseSensitive: false)
            .findFirstSync();
        downloadsPlaylist ??= PlaylistDB(name: systemName);
        downloadsPlaylist.id = isar.playlistDBs.putSync(downloadsPlaylist);
        final entries = isar.playlistEntryDBs
            .where()
            .playlistIdEqualToAnyPosition(downloadsPlaylist.id)
            .findAllSync();
        final seen = <String>{};
        var position = 0;
        for (final entry in entries) {
          entry.track.loadSync();
          if (entry.track.value != null) seen.add(entry.track.value!.mediaId);
          if (entry.position >= position) position = entry.position + 1;
        }
        for (final download in mappings) {
          final existing = isar.downloadDBs
              .filter()
              .mediaIdEqualTo(download.mediaId)
              .findFirstSync();
          // A recovery merge never replaces a current download mapping.
          if (existing == null) {
            isar.downloadDBs.putSync(DownloadDB(
                fileName: download.fileName,
                filePath: download.filePath,
                mediaId: download.mediaId,
                lastDownloaded: download.lastDownloaded));
            addedDownloads++;
          }
          if (!seen.add(download.mediaId)) continue;
          final entry = PlaylistEntryDB(
              playlistId: downloadsPlaylist.id, position: position++)
            ..playlist.value = downloadsPlaylist
            ..track.value = tracks[download.mediaId]!;
          isar.playlistEntryDBs.putSync(entry);
          entry.playlist.saveSync();
          entry.track.saveSync();
        }
        downloadsPlaylist.updatedAt = DateTime.now();
        isar.playlistDBs.putSync(downloadsPlaylist);
      }
      if (receiptKey != null) {
        isar.appSettingsBoolDBs.putSync(
            AppSettingsBoolDB(settingName: receiptKey, settingValue: true));
      }
      return {
        'addedTracks': addedTracks,
        'addedPlaylists': addedPlaylists,
        'addedHistory': addedHistory,
        'addedSearches': addedSearches,
        'changedSettings': changedSettings,
        'addedDownloads': addedDownloads,
        'addedEntries': addedEntries
      };
    });
  }

  /// Runs on an isolated staging copy. Broken links are reported, never
  /// guessed; unreferenced metadata is kept in a separate recovered playlist.
  static LibraryRecoveryPlan readLocalRecovery(Isar source) =>
      source.txnSync(() {
        final tracks = {
          for (final t in source.trackDBs.where().findAllSync())
            t.mediaId: _trackMap(t)
              ..['title'] = t.title.trim().isEmpty ? t.mediaId : t.title
        };
        var broken = 0;
        final playlists = <Map<String, dynamic>>[];
        for (final playlist in source.playlistDBs.where().findAllSync()) {
          if (isDevicePlaylist(playlist.name)) continue;
          final ids = <String>{};
          for (final entry in source.playlistEntryDBs
              .where()
              .playlistIdEqualToAnyPosition(playlist.id)
              .findAllSync()) {
            entry.track.loadSync();
            final id = entry.track.value?.mediaId;
            if (id == null) {
              broken++;
            } else {
              ids.add(id);
            }
          }
          playlists.add(_playlistMap(playlist)..['entries'] = ids.toList());
        }
        final downloads = <RecoveredDownload>[];
        for (final row in source.downloadDBs.where().findAllSync()) {
          tracks.putIfAbsent(
              row.mediaId,
              () => {
                    'mediaId': row.mediaId,
                    'title': row.fileName.isEmpty ? row.mediaId : row.fileName
                  });
          downloads.add(RecoveredDownload(
              mediaId: row.mediaId,
              fileName: row.fileName,
              filePath: row.filePath,
              lastDownloaded: row.lastDownloaded));
        }
        return recoveryPlan(tracks, playlists, downloads,
            brokenEntries: broken);
      });

  static LibraryRecoveryPlan recoveryPlan(
      Map<String, Map<String, dynamic>> tracks,
      List<Map<String, dynamic>> playlists,
      List<RecoveredDownload> downloads,
      {int brokenEntries = 0}) {
    final referenced = <String>{
      for (final p in playlists) ...(p['entries'] as List).cast<String>(),
      for (final d in downloads) d.mediaId
    };
    final orphanIds =
        tracks.keys.where((id) => !referenced.contains(id)).toList();
    if (orphanIds.isNotEmpty) {
      var name = 'Recovered tracks';
      var suffix = 1;
      while (playlists.any(
          (p) => (p['name'] as String).toLowerCase() == name.toLowerCase())) {
        name = 'Recovered tracks (${suffix++})';
      }
      playlists
          .add({'name': name, 'type': 'userPlaylist', 'entries': orphanIds});
    }
    return LibraryRecoveryPlan(
        document: BackupDocument.fromMap({
          'format': BackupDocument.format,
          'schemaVersion': BackupDocument.version,
          'kind': 'backup',
          'sourceFormat': 'legacy',
          'tracks': tracks.values.toList(),
          'playlists': playlists
        }),
        downloads: downloads,
        brokenEntries: brokenEntries);
  }

  static Map<String, dynamic>? _artMap(ArtworkDB? a) => a == null
      ? null
      : {
          'url': a.url,
          'urlLow': a.urlLow,
          'urlHigh': a.urlHigh,
          'layout': a.layout.name,
        };
  static Map<String, dynamic> _artistMap(ArtistSummaryDB a) => {
        'mediaId': a.mediaId,
        'name': a.name,
        'url': a.url,
        'subtitle': a.subtitle,
        'thumbnail': _artMap(a.thumbnail),
      };
  static Map<String, dynamic>? _albumMap(AlbumSummaryDB? a) => a == null
      ? null
      : {
          'mediaId': a.mediaId,
          'title': a.name,
          'year': a.year,
          'url': a.url,
          'artists': a.artists?.map(_artistMap).toList(),
          'thumbnail': _artMap(a.thumbnail),
        };
  static Map<String, dynamic> _trackMap(TrackDB t) => {
        'mediaId': t.mediaId,
        'title': t.title,
        'artists': t.artists?.map(_artistMap).toList(),
        'album': _albumMap(t.album),
        'thumbnail': _artMap(t.thumbnail),
        'durationMs': t.durationMs,
        'genre': t.genre,
        'language': t.language,
        'isExplicit': t.isExplicit,
      };
  static Map<String, dynamic> _playlistMap(PlaylistDB p) => {
        'name': p.name,
        'type': p.type.name,
        'subtitle': p.subtitle,
        'description': p.description,
        'thumbnail': _artMap(p.thumbnail),
        'artists': p.artists?.map(_artistMap).toList(),
        'album': _albumMap(p.album),
        'isPinned': p.isPinned,
        'sortOrder': p.sortOrder,
        'createdAt': p.createdAt.toUtc().toIso8601String(),
        'updatedAt': p.updatedAt.toUtc().toIso8601String(),
        'remotePlaylist': p.remotePlaylist == null
            ? null
            : {
                'title': p.remotePlaylist!.name,
                'mediaId': p.remotePlaylist!.mediaId,
                'url': p.remotePlaylist!.url,
                'subtitle': p.remotePlaylist!.subtitle,
                'artists': p.remotePlaylist!.artists?.map(_artistMap).toList(),
                'album': _albumMap(p.remotePlaylist!.album),
                'thumbnail': _artMap(p.remotePlaylist!.thumbnail),
              },
      };

  static ArtworkDB? _art(dynamic value) {
    if (value == null) return null;
    final m = value as Map<String, dynamic>;
    return ArtworkDB()
      ..url = m['url'] as String? ?? ''
      ..urlLow = m['urlLow'] as String?
      ..urlHigh = m['urlHigh'] as String?
      ..layout =
          ImageLayoutDB.values.byName(m['layout'] as String? ?? 'square');
  }

  static List<ArtistSummaryDB>? _artists(dynamic value) => value == null
      ? null
      : (value as List).map((v) {
          final a = v as Map<String, dynamic>;
          return ArtistSummaryDB()
            ..name = a['name'] as String?
            ..mediaId = a['mediaId'] as String?
            ..url = a['url'] as String?
            ..subtitle = a['subtitle'] as String?
            ..thumbnail = _art(a['thumbnail']);
        }).toList();
  static AlbumSummaryDB? _album(dynamic value) {
    if (value == null) return null;
    final a = value as Map<String, dynamic>;
    if (a['year'] != null && a['year'] is! String && a['year'] is! int) {
      throw const FormatException('Invalid album year.');
    }
    return AlbumSummaryDB()
      ..name = a['title'] as String? ?? ''
      ..mediaId = a['mediaId'] as String?
      ..url = a['url'] as String?
      ..year = a['year']?.toString()
      ..artists = _artists(a['artists'])
      ..thumbnail = _art(a['thumbnail']);
  }

  static TrackDB _track(Map<String, dynamic> t) => TrackDB(
        mediaId: t['mediaId'] as String,
        title: t['title'] as String,
        artists: _artists(t['artists']),
        album: _album(t['album']),
        thumbnail: _art(t['thumbnail']),
        durationMs: t['durationMs'] as int?,
        genre: t['genre'] as String?,
        language: t['language'] as String?,
        isExplicit: t['isExplicit'] as bool? ?? false,
      );
  static PlaylistDB _playlist(Map<String, dynamic> p) {
    final row = PlaylistDB(
        name: p['name'] as String,
        type: PlaylistTypeDB.values.byName(p['type'] as String),
        description: p['description'] as String?,
        subtitle: p['subtitle'] as String?,
        thumbnail: _art(p['thumbnail']),
        artists: _artists(p['artists']),
        album: _album(p['album']),
        sortOrder: p['sortOrder'] as int? ?? 0,
        isPinned: p['isPinned'] as bool? ?? false,
        createdat: p['createdAt'] == null
            ? null
            : DateTime.parse(p['createdAt'] as String),
        updatedat: p['updatedAt'] == null
            ? null
            : DateTime.parse(p['updatedAt'] as String));
    if (p['remotePlaylist'] != null) {
      final r = p['remotePlaylist'] as Map<String, dynamic>;
      row.remotePlaylist = RemotePlaylistSummaryDB(
          title: r['title'] as String?,
          mediaId: r['mediaId'] as String?,
          url: r['url'] as String?,
          subtitle: r['subtitle'] as String?,
          artists: _artists(r['artists']),
          album: _album(r['album']),
          thumbnail: _art(r['thumbnail']));
    }
    return row;
  }
}
