/// Opens the legacy `default.isar` database (created by the old Bloomee ≤ v2
/// codebase) using the original Isar file name `default`.
///
/// This file is intentionally isolated so it can be deleted once no users
/// need migration from the old schema.
///
/// Usage:
/// ```dart
/// import 'package:Bloomee/services/db/legacy/legacy_db_opener.dart' as legacyOpener;
///
/// final isar = await legacyOpener.openLegacyDB(appSuppDir);
/// // read data …
/// await legacyOpener.closeLegacyDB();
/// ```
library;

import 'dart:developer';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

import 'legacy_global_db.dart';

/// The legacy DB uses the physical file name `default.isar`, so the Isar name
/// must stay `default`. Using any other name would open/create a different
/// file and silently migrate nothing.
const legacyDbName = 'default';

/// All schemas from the old GlobalDB that are needed for the migration.
/// Only include the ones we actually read during migration to minimise the
/// chance of schema-mismatch errors on unusual DB versions.
const List<CollectionSchema<dynamic>> _legacySchemas = [
  MediaPlaylistDBSchema,
  MediaItemDBSchema,
  AppSettingsBoolDBSchema,
  AppSettingsStrDBSchema,
  DownloadDBSchema,
  SavedCollectionsDBSchema,
  PlaylistsInfoDBSchema,
  // Read-only; we never write to the legacy DB.
];

Isar? _legacyInstance;

/// Returns `true` when the legacy `default.isar` file exists in [dir].
bool legacyDbExists(String dir) =>
    File(p.join(dir, 'default.isar')).existsSync();

/// Opens the legacy DB. Returns the [Isar] instance.
///
/// Safe to call multiple times — returns the existing instance if already open.
Future<Isar> openLegacyDB(String dir) async {
  if (_legacyInstance != null && _legacyInstance!.isOpen) {
    return _legacyInstance!;
  }

  final named = Isar.getInstance(legacyDbName);
  if (named != null && named.isOpen) {
    _legacyInstance = named;
    return named;
  }

  log('Opening legacy DB at $dir/default.isar', name: 'LegacyDBOpener');
  _legacyInstance = Isar.openSync(
    _legacySchemas,
    directory: dir,
    name: legacyDbName,
    relaxedDurability: true, // read-heavy; we never write
  );
  return _legacyInstance!;
}

/// Closes the legacy DB instance.
Future<void> closeLegacyDB() async {
  try {
    if (_legacyInstance != null && _legacyInstance!.isOpen) {
      await _legacyInstance!.close();
      _legacyInstance = null;
      log('Legacy DB closed', name: 'LegacyDBOpener');
    }
  } catch (e) {
    log('Error closing legacy DB', error: e, name: 'LegacyDBOpener');
  }
}
