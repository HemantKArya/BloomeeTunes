import 'dart:async';

import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/scrobble/lastfm_api.dart';
import 'package:Bloomee/services/scrobble/scrobble_provider.dart';
import 'package:Bloomee/services/scrobble/scrobble_queue.dart';
import 'package:Bloomee/services/scrobble/scrobble_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

/// In-memory CacheDAO (never touches Isar).
class _MemDao extends CacheDAO {
  _MemDao() : super(Completer<Isar>().future);
  final Map<String, String> store = {};

  @override
  Future<void> putCache(String key, String value,
      {String? blob, Duration? ttl}) async {
    store[key] = value;
  }

  @override
  Future<String?> getCacheValue(String key) async => store[key];

  @override
  Future<List<({String key, String value})>> getCacheByPrefix(String prefix,
      {int? limit}) async {
    final keys = store.keys.where((k) => k.startsWith(prefix)).toList()..sort();
    return keys
        .take(limit ?? keys.length)
        .map((k) => (key: k, value: store[k]!))
        .toList();
  }

  @override
  Future<void> removeCacheKeys(List<String> keys) async {
    keys.forEach(store.remove);
  }
}

class _FakeProvider implements ScrobbleProvider {
  final List<ScrobbleOutcome> script;
  final List<List<ScrobbleTrack>> sent = [];
  bool ready = true;
  _FakeProvider(this.script);

  @override
  String get id => 'fake';
  @override
  bool get isReady => ready;
  @override
  int get maxBatch => 50;
  @override
  Future<void> nowPlaying(ScrobbleTrack t) async {}
  @override
  Future<ScrobbleOutcome> submit(List<ScrobbleTrack> b) async {
    sent.add(b);
    return script.isEmpty ? ScrobbleOutcome.success : script.removeAt(0);
  }
}

ScrobbleTrack _t(String n, int ts) =>
    ScrobbleTrack(artist: 'A', trackName: n, timestamp: ts);

void main() {
  late _MemDao dao;

  setUp(() => dao = _MemDao());

  test('success removes entries and records last sent', () async {
    final p = _FakeProvider([ScrobbleOutcome.success]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.enqueue(_t('one', 100));
    await q.flush();
    expect(await q.pendingCount(), 0);
    expect(q.status.value.lastSuccessAt, isNotNull);
    expect(q.status.value.lastTrack, contains('one'));
    expect(q.status.value.phase, ScrobblePhase.idle);
    q.dispose();
  });

  test('retryable keeps entries, sets retrying; kick resends in order',
      () async {
    // Each enqueue also triggers a flush, hence three failures.
    final p = _FakeProvider([
      ScrobbleOutcome.retryable,
      ScrobbleOutcome.retryable,
      ScrobbleOutcome.retryable,
    ]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.enqueue(_t('a', 100));
    await q.enqueue(_t('b', 200));
    await q.flush();
    expect(q.status.value.phase, ScrobblePhase.retrying);
    expect(q.status.value.issue, ScrobbleIssue.network);
    expect(await q.pendingCount(), 2);

    q.kick(); // "Sync now"
    await q.flush();
    expect(await q.pendingCount(), 0);
    expect(q.status.value.issue, isNull);
    expect(p.sent.last.map((e) => e.trackName), ['a', 'b']);
    q.dispose();
  });

  test('rejected batch is dropped and does not block the queue', () async {
    final p = _FakeProvider([ScrobbleOutcome.rejected]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.enqueue(_t('bad', 100));
    await q.flush();
    expect(await q.pendingCount(), 0);
    expect(q.status.value.issue, ScrobbleIssue.rejected);
    expect(q.status.value.rejectedCount, 1);
    q.dispose();
  });

  test('authFailed pauses and keeps entries until kick', () async {
    final p = _FakeProvider([ScrobbleOutcome.authFailed]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.enqueue(_t('a', 100));
    await q.flush();
    expect(q.status.value.phase, ScrobblePhase.authPaused);
    final calls = p.sent.length;
    await q.flush(); // paused: must not call the provider
    expect(p.sent.length, calls);
    expect(await q.pendingCount(), 1);
    q.kick();
    await q.flush();
    expect(await q.pendingCount(), 0);
    q.dispose();
  });

  test('clear empties the queue', () async {
    final p = _FakeProvider([ScrobbleOutcome.retryable]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.enqueue(_t('a', 100));
    await q.flush();
    await q.clear();
    expect(await q.pendingCount(), 0);
    expect(q.status.value.pending, 0);
    q.dispose();
  });

  test('migrates legacy single-blob cache', () async {
    dao.store['lastFMTrackedCacheForFutureScrobble'] =
        '[{"artist":"A","trackName":"old","timestamp":5,"album":null,"duration":null,"chosenByUser":false}]';
    final p = _FakeProvider([]);
    final q = ScrobbleQueue(cacheDao: dao, provider: p);
    await q.migrateLegacy();
    await q.flush();
    expect(p.sent.single.single.trackName, 'old');
    expect(dao.store['lastFMTrackedCacheForFutureScrobble'], 'null');
    q.dispose();
  });
}
