import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/services/backup/backup_files.dart';
import 'package:Bloomee/services/backup/serial_executor.dart';
import 'package:Bloomee/services/db/dao/backup_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:Bloomee/core/models/backup/recovery_copy.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

class BackupRepository {
  final BackupDAO dao;
  final Future<Isar> database;
  final String supportPath;
  final SerialExecutor _operations = SerialExecutor();
  final Random _random = Random.secure();

  BackupRepository(
      {required this.dao, required this.database, required this.supportPath});

  String _id() =>
      '${DateTime.now().toUtc().microsecondsSinceEpoch}_${List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
  String get snapshotDirectory => p.join(supportPath, 'backups');

  Future<void> runMaintenance(Future<void> Function() maintenance) =>
      _operations.run(maintenance);

  /// Called once during bootstrap, before imports can open staged databases.
  Future<void> cleanInterruptedWork() => _operations.run(() async {
        final staging = Directory(p.join(supportPath, 'import_staging'));
        if (await staging.exists()) {
          await for (final entry in staging.list(followLinks: false)) {
            if (entry is Directory &&
                p.basename(entry.path).startsWith('snapshot_')) {
              await entry.delete(recursive: true);
            }
          }
        }
        final snapshots = Directory(snapshotDirectory);
        if (await snapshots.exists()) {
          await for (final entry in snapshots.list(followLinks: false)) {
            if (entry is File && entry.path.endsWith('.isar.partial')) {
              await entry.delete();
            }
          }
        }
        final exports = Directory(
            p.join((await getTemporaryDirectory()).path, 'bloomee_exports'));
        if (await exports.exists()) {
          final cutoff = DateTime.now().subtract(const Duration(days: 7));
          await for (final entry in exports.list(followLinks: false)) {
            if (entry is File && (await entry.lastModified()).isBefore(cutoff)) {
              await entry.delete();
            }
          }
        }
      });

  Future<BackupDocument> prepare(String path) => _operations.run(() async {
        final file = File(path);
        final size = await file.length();
        if (size == 0 || size > BackupDocument.maxBytes * 8) {
          throw const FormatException('Empty or oversized backup.');
        }
        final prefix = await file.open();
        late List<int> header;
        try {
          header = await prefix.read(256);
        } finally {
          await prefix.close();
        }
        final text = utf8
            .decode(header, allowMalformed: true)
            .replaceFirst('\uFEFF', '')
            .trimLeft();
        late BackupDocument document;
        if (text.startsWith('{') ||
            p.extension(path).toLowerCase() == '.json') {
          document = await BackupFiles.readJson(path);
        } else if (['.isar', '.db'].contains(p.extension(path).toLowerCase())) {
          // A binary snapshot is only a compatibility source. Never replace live files.
          final dir = await Directory(p.join(supportPath, 'import_staging'))
              .create(recursive: true);
          final stage = await dir.createTemp('snapshot_');
          final name = 'import_${_id()}';
          Isar? source;
          try {
            await file.copy(p.join(stage.path, '$name.isar'));
            source = await Isar.open(DBProvider.schemas,
                directory: stage.path, name: name, inspector: false);
            final sourceDao = BackupDAO(Future.value(source));
            if (!await sourceDao.hasLibraryData()) {
              throw const FormatException(
                  'Snapshot has no supported library data. Export JSON from the original app version.');
            }
            document = await sourceDao.snapshot();
          } catch (error) {
            throw FormatException(
                'Cannot read this database snapshot. It may be incompatible or damaged. Original data was not changed. $error');
          } finally {
            if (source != null) await source.close();
            await stage.delete(recursive: true);
          }
        } else {
          // JSON is identified by structure even when providers rename it.
          document = await BackupFiles.readJson(path);
        }
        await BackupDAO.validateInBackground(document);
        return document;
      });

  Future<String> export({String? playlistName}) => _operations.run(() async {
        final document = await dao.snapshot(playlistName: playlistName);
        final directory = await Directory(
                p.join((await getTemporaryDirectory()).path, 'bloomee_exports'))
            .create(recursive: true);
        final name = playlistName == null
            ? 'Bloomee_Backup'
            : BackupFiles.safeName(playlistName);
        final target = File(p.join(directory.path, '${name}_${_id()}.json'));
        final temporary = File('${target.path}.partial');
        try {
          await temporary.writeAsString(jsonEncode(document.data), flush: true);
          if (await temporary.length() > BackupDocument.maxBytes) {
            throw const FormatException(
                'Export exceeds the supported 32 MB JSON limit. Export smaller playlists.');
          }
          // Round-trip validation before the file can be saved or shared.
          await BackupFiles.readJson(temporary.path);
          await temporary.rename(target.path);
          return target.path;
        } finally {
          if (await temporary.exists()) await temporary.delete();
        }
      });

  Future<String> _snapshot(String reason) async {
    final dir = await Directory(snapshotDirectory).create(recursive: true);
    final target = File(p.join(dir.path, '${reason}_${_id()}.isar'));
    final pending = File('${target.path}.partial');
    try {
      final isar = await database;
      await isar.copyToFile(pending.path);
      if (!await pending.exists() || await pending.length() == 0) {
        throw const FileSystemException('Recovery snapshot was not completed.');
      }
      final handle = await pending.open(mode: FileMode.append);
      try {
        await handle.flush();
      } finally {
        await handle.close();
      }
      await pending.rename(target.path);
      return target.path;
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  }

  Future<String> createSnapshot({String reason = 'automatic'}) =>
      _operations.run(() async {
        final path = await _snapshot(reason);
        await _rotate(reason, keep: 7);
        return path;
      });

  Future<void> automaticIfDue() => _operations.run(() async {
        final settings = SettingsDAO(database);
        if (await settings.getSettingBool(SettingKeys.autoBackup) != true) {
          return;
        }
        final raw =
            await settings.getSettingStr(SettingKeys.lastBackupTimestamp);
        final last = raw == null ? null : DateTime.tryParse(raw)?.toUtc();
        final now = DateTime.now().toUtc();
        if (last != null &&
            !last.isAfter(now) &&
            now.difference(last) < const Duration(hours: 24)) {
          return;
        }
        await _snapshot('automatic');
        await settings.putSettingStr(SettingKeys.lastBackupTimestamp,
            DateTime.now().toUtc().toIso8601String());
        await _rotate('automatic', keep: 7);
      });

  /// Execute reset on the next bootstrap, before background writers exist.
  Future<void> requestReset() => _operations.run(() async {
        final snapshot = await _snapshot('before_reset');
        final marker = File(p.join(supportPath, 'reset_requested'));
        final temporary = File('${marker.path}.partial');
        await temporary.writeAsString(
            jsonEncode({'version': 1, 'snapshot': p.basename(snapshot)}),
            flush: true);
        if (await marker.exists()) await marker.delete();
        await temporary.rename(marker.path);
      });

  Future<void> cancelReset() => _operations.run(() async {
        final marker = File(p.join(supportPath, 'reset_requested'));
        if (await marker.exists()) await marker.delete();
      });

  Future<Map<String, int>> apply(
          BackupDocument document, BackupSelection selection,
          {String? deliveryId}) =>
      _operations.run(() async {
        if (await File(p.join(supportPath, 'reset_requested')).exists()) {
          throw StateError('Cancel the scheduled reset before importing data.');
        }
        final any = (selection.library && document.has('playlists')) ||
            (selection.history &&
                (document.has('history') || document.has('searchHistory'))) ||
            (selection.settings && document.has('settings'));
        if (!any) {
          throw const FormatException(
              'Select at least one available data section.');
        }
        // Failure to protect current data aborts the import before any mutation.
        await _snapshot('before_import');
        final result = await dao.apply(document, selection,
            receiptKey: deliveryId == null
                ? null
                : '_backupReceipt/${sha256.convert(utf8.encode(deliveryId))}');
        // Failed imports retain their pre-import snapshot. Only successful runs rotate.
        await _rotate('before_import', keep: 7);
        return result;
      });

  Future<List<RecoveryCopy>> recoverySnapshots() => _operations.run(() async {
        final dir = Directory(snapshotDirectory);
        if (!await dir.exists()) return [];
        final files = await dir
            .list()
            .where((e) => e is File && e.path.endsWith('.isar'))
            .toList();
        final copies = <RecoveryCopy>[];
        for (final f in files) {
          final name = p.basename(f.path);
          final match = RegExp(r'_(\d+)_([a-f0-9]+)\.isar$').firstMatch(name);
          final timestamp = int.tryParse(match?.group(1) ?? '');
          if (timestamp == null) continue;
          copies.add(RecoveryCopy(
              path: f.path,
              createdAt:
                  DateTime.fromMicrosecondsSinceEpoch(timestamp, isUtc: true),
              reason: name.startsWith('before_import_')
                  ? RecoveryReason.beforeImport
                  : name.startsWith('before_reset_')
                      ? RecoveryReason.beforeReset
                      : RecoveryReason.automatic));
        }
        copies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return copies;
      });

  Future<void> _rotate(String reason, {required int keep}) async {
    try {
      final dir = Directory(snapshotDirectory);
      final files = await dir
          .list()
          .where((e) =>
              e is File &&
              p.basename(e.path).startsWith('${reason}_') &&
              e.path.endsWith('.isar'))
          .cast<File>()
          .toList();
      files.sort((a, b) => b.path.compareTo(a.path));
      for (final file in files.skip(keep)) {
        await file.delete();
      }
    } on FileSystemException {
      // Retention failure must never turn a committed import into a reported failure.
    }
  }
}
