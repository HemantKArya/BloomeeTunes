import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/import_export_service.dart';

enum _RestorePayloadType {
  isarSnapshot,
  legacyFullJson,
  playlistOrTrackJson,
  unsupported,
}

class RestoreBackupOptions {
  final bool restoreMediaItems;
  final bool restoreSearchHistory;
  final bool restoreSettings;

  const RestoreBackupOptions({
    this.restoreMediaItems = true,
    this.restoreSearchHistory = true,
    this.restoreSettings = true,
  });
}

class StorageBackupService {
  const StorageBackupService._();

  static Future<String?> createBackup() {
    return DBProvider.createBackUp();
  }

  static Future<String?> createJsonBackup() {
    return DBProvider.createLegacyJsonBackup();
  }

  static Future<void> resetAppData() {
    return DBProvider.resetDB();
  }

  static Future<Map<String, dynamic>> restoreBackup(
    String? path, {
    RestoreBackupOptions options = const RestoreBackupOptions(),
  }) async {
    if (path == null || path.trim().isEmpty) {
      return {'success': false, 'error': 'No backup file selected.'};
    }

    final file = File(path);
    if (!await file.exists()) {
      return {'success': false, 'error': 'Backup file not found: $path'};
    }

    final payloadType = await _detectPayloadType(file);
    switch (payloadType) {
      case _RestorePayloadType.isarSnapshot:
        return DBProvider.restoreDB(path);
      case _RestorePayloadType.legacyFullJson:
        return DBProvider.restoreLegacyJsonBackup(
          path,
          restoreMediaItems: options.restoreMediaItems,
        );
      case _RestorePayloadType.playlistOrTrackJson:
        final imported = await ImportExportService.importJSON(path);
        return {
          'success': imported,
          'mode': 'import',
          if (!imported)
            'error': 'Failed to import playlist/song JSON. Check file format.'
        };
      case _RestorePayloadType.unsupported:
        return {
          'success': false,
          'error':
              'Unsupported backup format. Use .isar snapshots, legacy full JSON backup, or playlist/song JSON exports.',
        };
    }
  }

  static Future<_RestorePayloadType> _detectPayloadType(File file) async {
    final normalizedPath = file.path.toLowerCase();
    final ext = normalizedPath.split('.').last;
    if (ext == 'isar' || ext == 'db' || normalizedPath.endsWith('.isar.db')) {
      return _RestorePayloadType.isarSnapshot;
    }

    if (ext != 'json' && ext != 'blm') {
      return _RestorePayloadType.unsupported;
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return _RestorePayloadType.unsupported;
      }

      final isLegacyFull = decoded.containsKey('_meta') &&
          decoded.containsKey('playlists') &&
          decoded.containsKey('media_items');
      if (isLegacyFull) {
        return _RestorePayloadType.legacyFullJson;
      }

      final isPlaylistExport = decoded.containsKey('playlistName') &&
          (decoded.containsKey('tracks') || decoded.containsKey('mediaItems'));
      final isTrackExport = decoded.containsKey('title') &&
          (decoded.containsKey('mediaId') ||
              decoded.containsKey('duration') ||
              decoded.containsKey('permaURL'));

      if (isPlaylistExport || isTrackExport) {
        return _RestorePayloadType.playlistOrTrackJson;
      }
    } catch (_) {
      return _RestorePayloadType.unsupported;
    }

    return _RestorePayloadType.unsupported;
  }
}
