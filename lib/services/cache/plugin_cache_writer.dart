import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/db/dao/cache_dao.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PluginCacheWriter — debounced, coalescing Isar write pipeline
// ═════════════════════════════════════════════════════════════════════════════

/// Batches cache writes to Isar behind a debounce timer.
///
/// Callers [schedule] a write. Writes are coalesced by key (last write wins)
/// and flushed together in one Isar transaction either after [_flushDelay]
/// of inactivity, or immediately when [_maxPending] entries are queued.
///
/// This prevents back-to-back navigation events (chart hop, discover scroll)
/// from hammering Isar with individual puts.
class PluginCacheWriter {
  final CacheDAO _cacheDao;

  final _pending = <String, _WriteEntry>{};
  Timer? _flushTimer;

  static const _flushDelay = Duration(seconds: 2);
  static const _maxPending = 10;

  PluginCacheWriter(this._cacheDao);

  /// Schedule a cache write for [key].
  ///
  /// [blob] is the serialised JSON string. [ttl] optionally sets expiry.
  /// If the same key is scheduled again before flush, the last write wins.
  void schedule(String key, String blob, {Duration? ttl}) {
    _pending[key] = _WriteEntry(blob, ttl);

    // Safety cap: flush synchronously once the batch is full.
    if (_pending.length >= _maxPending) {
      _flushTimer?.cancel();
      unawaited(_flush());
      return;
    }

    _flushTimer?.cancel();
    _flushTimer = Timer(_flushDelay, () => unawaited(_flush()));
  }

  /// Force an immediate flush — call on [AppLifecycleState.paused].
  Future<void> flushNow() async {
    _flushTimer?.cancel();
    await _flush();
  }

  void dispose() {
    _flushTimer?.cancel();
  }

  Future<void> _flush() async {
    if (_pending.isEmpty) return;

    final batch = Map<String, _WriteEntry>.from(_pending);
    _pending.clear();

    try {
      await _cacheDao.putCacheBatch({
        for (final e in batch.entries)
          e.key: (value: e.value.blob, ttl: e.value.ttl),
      });
    } catch (e, st) {
      log('PluginCacheWriter flush failed: $e',
          stackTrace: st, name: 'PluginCacheWriter');
      // Non-fatal — next write attempt will overwrite.
    }
  }
}

class _WriteEntry {
  final String blob;
  final Duration? ttl;
  const _WriteEntry(this.blob, this.ttl);
}
