import 'dart:developer';

import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for API response cache (TTL-aware) and API token storage.
///
/// API response cache uses [CacheEntryDB] which supports TTL expiry and an
/// optional binary blob field. API tokens (long-lived) remain in
/// [AppSettingsStrDB] with their expiry embedded.
class CacheDAO {
  final Future<Isar> _db;

  const CacheDAO(this._db);

  // ── API response cache (CacheEntryDB) ─────────────────────────────────────

  /// Upsert a cache entry by [key].
  ///
  /// [value] is the primary string payload (e.g. serialised JSON).
  /// [blob] is an optional raw payload (e.g. binary response).
  /// [ttl] sets when the entry expires; null means it never expires.
  Future<void> putCache(
    String key,
    String value, {
    String? blob,
    Duration? ttl,
  }) async {
    if (key.isEmpty) return;
    final isar = await _db;
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    final entry = CacheEntryDB(
      key: key,
      value: value,
      blob: blob,
      lastUpdated: DateTime.now(),
      ttl: expiry,
    );
    await isar.writeTxn(() => isar.cacheEntryDBs.put(entry));
  }

  /// Retrieve a cache entry by [key].
  ///
  /// Returns null if the entry does not exist or has expired (and deletes
  /// stale entries lazily).
  Future<CacheEntryDB?> getCache(String key) async {
    final isar = await _db;
    final entry = await isar.cacheEntryDBs.filter().keyEqualTo(key).findFirst();
    if (entry == null) return null;

    if (entry.isExpired) {
      // Lazily delete the expired entry.
      await isar.writeTxn(() => isar.cacheEntryDBs.delete(entry.id));
      log('Cache miss (expired): $key', name: 'CacheDAO');
      return null;
    }
    return entry;
  }

  /// Retrieve only the string [value] for [key], or null if missing/expired.
  Future<String?> getCacheValue(String key) async {
    final entry = await getCache(key);
    return entry?.value;
  }

  /// Delete a single cache entry by [key].
  Future<void> removeCache(String key) async {
    final isar = await _db;
    await isar.writeTxn(
        () => isar.cacheEntryDBs.filter().keyEqualTo(key).deleteAll());
  }

  /// Delete all entries whose TTL has passed.
  ///
  /// Returns the number of entries deleted.
  Future<int> purgeExpiredCache() async {
    final isar = await _db;
    final now = DateTime.now();
    final count = await isar.writeTxn(() => isar.cacheEntryDBs
        .filter()
        .ttlIsNotNull()
        .ttlLessThan(now)
        .deleteAll());
    if (count > 0) {
      log('Purged $count expired cache entries', name: 'CacheDAO');
    }
    return count;
  }

  /// Delete every cache entry regardless of TTL.
  Future<void> clearAllCache() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.cacheEntryDBs.clear());
    log('Cleared all cache', name: 'CacheDAO');
  }

  // ── API tokens (AppSettingsStrDB) ─────────────────────────────────────────

  /// Store an API token for [apiName] with its expiry in seconds.
  ///
  /// [expireInSeconds] = 0 means the token never expires.
  Future<void> putApiToken(
    String apiName,
    String token, {
    int expireInSeconds = 0,
  }) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsStrDBs.put(
          AppSettingsStrDB(
            settingName: apiName,
            settingValue: token,
            settingValue2: expireInSeconds.toString(),
            lastUpdated: DateTime.now(),
          ),
        ));
  }

  /// Retrieve the token for [apiName] if still valid, otherwise null.
  Future<String?> getApiToken(String apiName) async {
    final isar = await _db;
    final record = await isar.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .findFirst();
    if (record == null) return null;

    final expireIn = int.tryParse(record.settingValue2 ?? '0') ?? 0;
    if (expireIn == 0) return record.settingValue; // never expires

    final age = DateTime.now()
        .difference(
            record.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0))
        .inSeconds
        .abs();
    if (age < expireIn - 30) return record.settingValue; // 30-s safety margin
    return null; // expired
  }

  /// Delete the token entry for [apiName].
  Future<void> removeApiToken(String apiName) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .deleteAll());
  }
}
