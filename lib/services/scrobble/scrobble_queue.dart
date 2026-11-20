import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:Bloomee/services/scrobble/lastfm_api.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/scrobble/scrobble_provider.dart';
import 'package:Bloomee/services/scrobble/scrobble_status.dart';

/// Persistent, serialised outbox for scrobbles.
///
/// One DB row per scrobble (atomic append/remove), flushed in batches with
/// exponential backoff on transient failures. Flush triggers: enqueue,
/// [kick] (app start / connectivity regained), and a backoff timer.
class ScrobbleQueue {
  ScrobbleQueue({required CacheDAO cacheDao, required ScrobbleProvider provider})
      : _dao = cacheDao,
        _provider = provider,
        _prefix = 'scrobbleq:${provider.id}:';

  final CacheDAO _dao;
  final ScrobbleProvider _provider;
  final String _prefix;

  static const _legacyKey = 'lastFMTrackedCacheForFutureScrobble';
  static const _maxQueued = 5000;

  /// Live pipeline status for the settings UI.
  final ValueNotifier<ScrobbleStatus> status =
      ValueNotifier(const ScrobbleStatus());

  void _set(ScrobbleStatus Function(ScrobbleStatus s) f) {
    if (_disposed) return;
    status.value = f(status.value);
  }

  Future<void> refreshPending() async {
    final n = await pendingCount();
    _set((s) => s.copyWith(pending: n));
  }

  /// Discards everything waiting to be sent.
  Future<void> clear() => _serial(() async {
        final rows = await _dao.getCacheByPrefix(_prefix);
        await _dao.removeCacheKeys(rows.map((r) => r.key).toList());
        _retryTimer?.cancel();
        _failures = 0;
        _set((s) => s.copyWith(
            pending: 0,
            phase: _authPaused ? ScrobblePhase.authPaused : ScrobblePhase.idle,
            clearRetry: true,
            clearIssue: !_authPaused));
      });

  Future<void> _chain = Future.value();
  Timer? _retryTimer;
  int _failures = 0;
  int _seq = 0;
  bool _authPaused = false;
  bool _disposed = false;

  Future<T> _serial<T>(Future<T> Function() action) {
    final r = _chain.then((_) => action());
    _chain = r.then<void>((_) {}, onError: (_) {});
    return r;
  }

  Future<void> enqueue(ScrobbleTrack entry) async {
    await _serial(() async {
      final key =
          '$_prefix${entry.timestamp.toString().padLeft(12, '0')}-${(_seq++).toString().padLeft(6, '0')}';
      await _dao.putCache(key, jsonEncode(entry.toMap()));
    });
    await refreshPending();
    unawaited(flush());
  }

  /// Number of queued scrobbles.
  Future<int> pendingCount() async =>
      (await _dao.getCacheByPrefix(_prefix)).length;

  /// Called after login/app start/connectivity regained.
  void kick() {
    _authPaused = false;
    _failures = 0;
    _set((s) => s.copyWith(clearIssue: true));
    unawaited(flush());
  }

  /// Moves entries from the old single-blob cache into per-row storage.
  Future<void> migrateLegacy() => _serial(() async {
        final raw = await _dao.getCacheValue(_legacyKey);
        if (raw == null || raw.isEmpty || raw == 'null') return;
        try {
          final list = jsonDecode(raw) as List;
          for (final e in list) {
            final t = ScrobbleTrack.fromMap(e as Map<String, dynamic>);
            await _dao.putCache(
              '$_prefix${t.timestamp.toString().padLeft(12, '0')}-m${(_seq++).toString().padLeft(5, '0')}',
              jsonEncode(t.toMap()),
            );
          }
        } catch (e) {
          log('Legacy scrobble cache unreadable: $e', name: 'Scrobble');
        }
        await _dao.putCache(_legacyKey, 'null');
      });

  Future<void> flush() => _serial(() async {
        if (_disposed || !_provider.isReady) return;
        if (_authPaused) {
          await refreshPending();
          return;
        }
        _retryTimer?.cancel();
        _set((s) => s.copyWith(phase: ScrobblePhase.sending, clearRetry: true));

        while (!_disposed) {
          final rows =
              await _dao.getCacheByPrefix(_prefix, limit: _provider.maxBatch);
          if (rows.isEmpty) {
            _failures = 0;
            _set((s) => s.copyWith(phase: ScrobblePhase.idle, pending: 0));
            return;
          }
          final entries = <ScrobbleTrack>[];
          final badKeys = <String>[];
          final goodKeys = <String>[];
          for (final r in rows) {
            try {
              entries.add(ScrobbleTrack.fromMap(
                  jsonDecode(r.value) as Map<String, dynamic>));
              goodKeys.add(r.key);
            } catch (_) {
              badKeys.add(r.key); // corrupt row: drop it, never block queue
            }
          }
          if (badKeys.isNotEmpty) await _dao.removeCacheKeys(badKeys);
          if (entries.isEmpty) continue;

          final outcome = await _provider.submit(entries);
          switch (outcome) {
            case ScrobbleOutcome.success:
            case ScrobbleOutcome.rejected:
              if (outcome == ScrobbleOutcome.rejected) {
                log('Dropping rejected batch (${entries.length})',
                    name: 'Scrobble');
              }
              await _dao.removeCacheKeys(goodKeys);
              _failures = 0;
              final last = entries.last;
              final rejected = outcome == ScrobbleOutcome.rejected;
              _set((s) => s.copyWith(
                    lastSuccessAt: rejected ? null : DateTime.now(),
                    lastTrack: rejected ? null : '${last.trackName} · ${last.artist}',
                    issue: rejected ? ScrobbleIssue.rejected : null,
                    clearIssue: !rejected,
                    rejectedCount: rejected ? entries.length : 0,
                  ));
              await refreshPending();
              break;
            case ScrobbleOutcome.retryable:
              _scheduleRetry();
              return;
            case ScrobbleOutcome.authFailed:
              _authPaused = true; // resumes via kick() after re-login
              _set((s) => s.copyWith(
                  phase: ScrobblePhase.authPaused, issue: ScrobbleIssue.auth));
              await refreshPending();
              log('Scrobbling paused: authentication failed',
                  name: 'Scrobble');
              return;
          }
        }
      }).then((_) => _trim());

  Future<void> _trim() async {
    final rows = await _dao.getCacheByPrefix(_prefix);
    if (rows.length > _maxQueued) {
      await _dao.removeCacheKeys(
          rows.take(rows.length - _maxQueued).map((r) => r.key).toList());
    }
  }

  void _scheduleRetry() {
    _failures++;
    final secs = math.min(30 * 60, 15 * math.pow(2, _failures - 1).toInt());
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: secs), () => unawaited(flush()));
    _set((s) => s.copyWith(
          phase: ScrobblePhase.retrying,
          issue: ScrobbleIssue.network,
          nextRetryAt: DateTime.now().add(Duration(seconds: secs)),
        ));
    unawaited(refreshPending());
    log('Scrobble retry in ${secs}s', name: 'Scrobble');
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    status.dispose();
  }
}
