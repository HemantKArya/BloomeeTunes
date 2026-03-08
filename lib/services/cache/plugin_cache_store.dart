import 'dart:collection';

/// Cache key namespace — used to pick the right LRU pool.
enum CacheType { chart, sections, chartList }

// ── Internal entry type ───────────────────────────────────────────────────────

class _LruEntry {
  final Object value;
  final DateTime storedAt;
  _LruEntry(this.value, this.storedAt);
}

// ── LRU map backed by LinkedHashMap ──────────────────────────────────────────

class _LruMap {
  final int capacity;
  final _map = LinkedHashMap<String, _LruEntry>();

  _LruMap(this.capacity);

  _LruEntry? get(String key) {
    final val = _map.remove(key);
    if (val != null) _map[key] = val; // move to MRU end
    return val;
  }

  void put(String key, _LruEntry entry) {
    _map.remove(key);
    _map[key] = entry;
    while (_map.length > capacity) {
      _map.remove(_map.keys.first); // evict LRU
    }
  }

  void removeWhere(bool Function(String key) test) =>
      _map.removeWhere((k, _) => test(k));

  void clear() => _map.clear();

  void trimTo(int size) {
    while (_map.length > size) {
      _map.remove(_map.keys.first);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PluginCacheStore — type-partitioned in-memory LRU (L1 cache)
// ═════════════════════════════════════════════════════════════════════════════

/// L1 in-memory cache for decoded plugin data.
///
/// Partitioned into fixed-capacity pools per [CacheType] so no one source
/// can crowd out another. Each slot stores both the decoded value and the
/// timestamp it was written, enabling synchronous staleness checks without
/// hitting Isar.
///
/// Memory budget (steady state):
/// - chart details    8 slots × ~100 KB ≈ 800 KB
/// - home sections    5 slots × ~120 KB ≈ 600 KB
/// - chart lists      5 slots × ~10  KB ≈  50 KB
/// Total: ~1.5 MB
class PluginCacheStore {
  final _charts = _LruMap(8); // chart item lists per chartId
  final _sections = _LruMap(5); // home sections per pluginId
  final _chartLists = _LruMap(5); // chart summaries per pluginId

  // ── Read ─────────────────────────────────────────────────────────────────

  /// Returns the cached value and when it was stored, or null on miss.
  ///
  /// Accessing an entry promotes it to MRU (LRU semantics).
  ({T value, DateTime storedAt})? getWithAge<T>(String key, CacheType type) {
    final entry = _poolFor(type).get(key);
    if (entry == null) return null;
    final v = entry.value;
    if (v is! T) return null;
    return (value: v as T, storedAt: entry.storedAt);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Store [value] in L1 under [key].
  ///
  /// [storedAt] defaults to now; pass the original Isar [lastUpdated] when
  /// promoting an L2 entry so the age is accurately preserved.
  void put(String key, Object value, CacheType type, {DateTime? storedAt}) {
    _poolFor(type).put(key, _LruEntry(value, storedAt ?? DateTime.now()));
  }

  // ── Eviction ─────────────────────────────────────────────────────────────

  /// Remove all L1 entries whose key starts with [prefix].
  ///
  /// Used when a plugin is unloaded so stale cross-plugin data is not served.
  void evictPrefix(String prefix) {
    for (final pool in [_charts, _sections, _chartLists]) {
      pool.removeWhere((k) => k.startsWith(prefix));
    }
  }

  /// Drop all L1 data (called on memory pressure).
  void clearAll() {
    _charts.clear();
    _sections.clear();
    _chartLists.clear();
  }

  /// Halve each pool (called on app-pause to reduce memory while backgrounded).
  void trimToHalf() {
    _charts.trimTo(4);
    _sections.trimTo(2);
    _chartLists.trimTo(2);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  _LruMap _poolFor(CacheType type) => switch (type) {
        CacheType.chart => _charts,
        CacheType.sections => _sections,
        CacheType.chartList => _chartLists,
      };
}
