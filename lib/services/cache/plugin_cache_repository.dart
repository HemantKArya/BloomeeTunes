import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:Bloomee/services/cache/plugin_cache_store.dart';
import 'package:Bloomee/services/cache/plugin_cache_writer.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/global_db.dart' show CacheEntryDB;

export 'package:Bloomee/services/cache/plugin_cache_store.dart' show CacheType;

// ═════════════════════════════════════════════════════════════════════════════
// PluginCacheRepository — unified L1+L2 cache facade used by blocs
// ═════════════════════════════════════════════════════════════════════════════

/// Single dependency for blocs needing to read or write plugin response cache.
///
/// Provides:
/// - Two-tier reads: L1 in-memory LRU → L2 Isar with isolate decode.
/// - Staleness status alongside every read so callers can decide whether to
///   refresh in the background.
/// - Fire-and-forget writes: L1 is updated synchronously; Isar is updated via
///   [PluginCacheWriter] debounced batch.
/// - In-flight deduplication: parallel callers for the same key share one
///   network Future, preventing duplicate requests.
/// - Lifecycle hooks for memory pressure and app-pause.
///
/// All bloc constructors retrieve this via `ServiceLocator.pluginCache` so no
/// constructor signature changes are needed in widgets.
class PluginCacheRepository with WidgetsBindingObserver {
  final PluginCacheStore _store;
  final CacheDAO _cacheDao;
  final PluginCacheWriter _writer;

  /// In-flight network call deduplication map.
  final _inFlight = <String, Future<dynamic>>{};

  PluginCacheRepository({
    required PluginCacheStore store,
    required CacheDAO cacheDao,
    required PluginCacheWriter writer,
  })  : _store = store,
        _cacheDao = cacheDao,
        _writer = writer {
    WidgetsBinding.instance.addObserver(this);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Attempt to read [key] from L1 then L2, returning the data and whether it
  /// is considered stale (age > [stalenessThreshold]).
  ///
  /// - L1 hit: synchronous, < 0.01 ms.
  /// - L2 hit: Isar read + isolate decode via [decode], typically 5–15 ms.
  ///   The entry is promoted to L1 with its original write timestamp preserved.
  /// - Miss: returns `(value: null, isStale: true)`.
  Future<({T? value, bool isStale})> getCachedWithStaleness<T>({
    required String key,
    required CacheType type,
    required Future<T> Function(String blob) decode,
    required Duration stalenessThreshold,
  }) async {
    // ── L1 ──────────────────────────────────────────────────────────────────
    final l1 = _store.getWithAge<T>(key, type);
    if (l1 != null) {
      final stale =
          l1.storedAt.add(stalenessThreshold).isBefore(DateTime.now());
      return (value: l1.value, isStale: stale);
    }

    // ── L2 ──────────────────────────────────────────────────────────────────
    CacheEntryDB? entry;
    try {
      entry = await _cacheDao.getCache(key);
    } catch (e) {
      log('L2 read failed for $key: $e', name: 'PluginCacheRepository');
    }
    if (entry == null || entry.value.isEmpty)
      return (value: null, isStale: true);

    final T decoded = await decode(entry.value);

    // Promote to L1 preserving the original write time so age is accurate.
    _store.put(key, decoded as Object, type,
        storedAt: entry.lastUpdated ?? DateTime.now());

    final storedAt =
        entry.lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
    final stale = storedAt.add(stalenessThreshold).isBefore(DateTime.now());
    return (value: decoded, isStale: stale);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Store [value] in L1 immediately and schedule Isar write.
  ///
  /// [blob] is the pre-encoded JSON string (from plugin_cache_codec).
  /// [ttl] is optional expiry — for plugin cache entries use `null`
  /// (data is kept indefinitely; staleness is checked via `lastUpdated`).
  void put({
    required String key,
    required Object value,
    required CacheType type,
    required String blob,
    Duration? ttl,
  }) {
    _store.put(key, value, type);
    _writer.schedule(key, blob, ttl: ttl);
  }

  // ── In-flight deduplication ───────────────────────────────────────────────

  /// Run [work] once even if called concurrently with the same [key].
  ///
  /// If a call is already in-flight for [key], the same Future is returned to
  /// all callers so only one network request is made.
  Future<T> deduplicate<T>(String key, Future<T> Function() work) {
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]! as Future<T>;
    }
    final future = work().whenComplete(() => _inFlight.remove(key));
    _inFlight[key] = future;
    return future;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Evict all L1 entries for [pluginId] when it is unloaded.
  ///
  /// Isar entries are kept — they expire naturally or are overwritten on
  /// next fetch.
  void evictPlugin(String pluginId) {
    _store.evictPrefix('chart_cache::$pluginId::');
    _store.evictPrefix('home_sections::$pluginId');
    _store.evictPrefix('chart_list::$pluginId');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _store.trimToHalf();
      unawaited(_writer.flushNow());
    }
  }

  @override
  void didHaveMemoryPressure() {
    _store.clearAll();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _writer.dispose();
  }
}
