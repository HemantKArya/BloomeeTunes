import 'dart:developer';
import 'package:isar_community/isar.dart';
import 'package:Bloomee/services/db/global_db.dart';

/// Data access object for [PluginStorageEntity].
///
/// Provides CRUD operations for plugin key-value storage persistence.
/// Used by [PluginStorageService] to mirror Rust in-memory storage to Isar.
class PluginStorageDao {
  final Future<Isar> _db;

  PluginStorageDao(this._db);

  /// Upsert a storage entry. Uses composite key for uniqueness.
  Future<void> putEntry({
    required String pluginId,
    required String key,
    required String value,
  }) async {
    final isar = await _db;
    final entity = PluginStorageEntity(
      pluginId: pluginId,
      key: key,
      value: value,
      updatedAt: DateTime.now(),
    );
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys.put(entity);
    });
  }

  /// Get a single entry by plugin ID and key.
  Future<PluginStorageEntity?> getEntry({
    required String pluginId,
    required String key,
  }) async {
    final isar = await _db;
    final compositeKey = '$pluginId/$key';
    return isar.pluginStorageEntitys
        .where()
        .compositeKeyEqualTo(compositeKey)
        .findFirst();
  }

  /// Get all entries for a specific plugin.
  Future<List<PluginStorageEntity>> getAllForPlugin(String pluginId) async {
    final isar = await _db;
    return isar.pluginStorageEntitys
        .where()
        .pluginIdEqualTo(pluginId)
        .findAll();
  }

  /// Get all plugin storage entries (for startup preload).
  Future<List<PluginStorageEntity>> getAll() async {
    final isar = await _db;
    return isar.pluginStorageEntitys.where().findAll();
  }

  /// Delete a single entry.
  Future<void> deleteEntry({
    required String pluginId,
    required String key,
  }) async {
    final isar = await _db;
    final compositeKey = '$pluginId/$key';
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys
          .where()
          .compositeKeyEqualTo(compositeKey)
          .deleteAll();
    });
  }

  /// Clear all storage for a plugin.
  Future<void> clearPlugin(String pluginId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys
          .where()
          .pluginIdEqualTo(pluginId)
          .deleteAll();
    });
    log('Cleared storage for plugin: $pluginId', name: 'PluginStorageDao');
  }

  /// Clear ALL plugin storage (nuclear option).
  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.pluginStorageEntitys.clear();
    });
  }
}
