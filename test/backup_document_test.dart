import 'dart:convert';

import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/services/backup/serial_executor.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sample() => {
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'backup',
      'tracks': [
        <String, dynamic>{'mediaId': 'source::one', 'title': 'One'}
      ],
      'playlists': [
        {
          'name': 'Mix',
          'type': 'userPlaylist',
          'entries': ['source::one']
        }
      ],
    };

void main() {
  test('canonical JSON round trips and freezes nested preview data', () {
    final d = BackupDocument.decode(jsonEncode(sample()));
    expect(d.trackCount, 1);
    expect(d.playlistCount, 1);
    expect(() => d.rows('tracks').first['title'] = 'changed',
        throwsUnsupportedError);
    expect(() => (d.rows('playlists').first['entries'] as List).clear(),
        throwsUnsupportedError);
  });

  test('accepts UTF-8 BOM and Unicode playlist names', () {
    final input = sample();
    (input['playlists'] as List).first['name'] = 'रात 🌙';
    expect(
        BackupDocument.decode('\uFEFF${jsonEncode(input)}')
            .rows('playlists')
            .first['name'],
        'रात 🌙');
  });

  for (final mutation in <String, void Function(Map<String, dynamic>)>{
    'future version': (m) => m['schemaVersion'] = 2,
    'wrong kind': (m) => m['kind'] = 'settings-only',
    'missing track ID': (m) => (m['tracks'] as List).first.remove('mediaId'),
    'empty title': (m) => (m['tracks'] as List).first['title'] = '',
    'negative duration': (m) => (m['tracks'] as List).first['durationMs'] = -1,
    'fractional duration': (m) =>
        (m['tracks'] as List).first['durationMs'] = 0.2,
    'missing reference': (m) =>
        (m['playlists'] as List).first['entries'] = ['missing'],
    'duplicate reference': (m) => (m['playlists'] as List).first['entries'] = [
          'source::one',
          'source::one'
        ],
    'invalid section type': (m) => m['settings'] = {},
    'invalid settings value': (m) => m['settings'] = [
          {'key': 'languageCode', 'value': []}
        ],
    'invalid history date': (m) => m['history'] = [
          {'mediaId': 'source::one', 'playedAt': 'bad'}
        ],
  }.entries) {
    test('rejects ${mutation.key}', () {
      final input = sample();
      mutation.value(input);
      expect(() => BackupDocument.fromMap(input), throwsFormatException);
    });
  }

  test('legacy playlist converts IDs and preserves incoming order', () {
    final d = BackupDocument.fromMap({
      'playlistName': 'Old',
      'mediaItems': [
        {
          'mediaID': 'second',
          'source': 'saavn',
          'title': 'Second',
          'duration': 4
        },
        {'mediaID': 'first', 'source': 'saavn', 'title': 'First'},
      ],
    });
    expect(d.rows('playlists').single['entries'], [
      'content-resolver.bloomfactory.jisaavn::second',
      'content-resolver.bloomfactory.jisaavn::first',
    ]);
    expect(d.rows('tracks').first['durationMs'], 4000);
  });

  test('legacy full backup supports embedded JSON strings and likes', () {
    final d = BackupDocument.fromMap({
      'playlists': [
        jsonEncode({'playlistName': 'Liked'}),
        {'playlistName': 'Empty'}
      ],
      'media_items': [
        jsonEncode({
          'mediaID': 'source::one',
          'title': 'One',
          'mediaInPlaylists': [
            jsonEncode({'playlistName': 'Liked'})
          ],
        })
      ],
    });
    expect(d.rows('playlists').first['entries'], ['source::one']);
    expect(d.rows('playlists').last['entries'], isEmpty);
    expect(d.warnings, isNotEmpty);
    expect(d.has('settings'), false);
  });

  test('recognizes legacy single tracks with mediaID', () {
    final d = BackupDocument.fromMap(
        {'mediaID': 'one', 'title': 'One', 'duration': 1});
    expect(d.kind, 'track');
    expect(d.rows('tracks').single['mediaId'], 'one');
  });

  test('canonical single-track files get an Imported destination automatically',
      () {
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'track',
      'tracks': [
        {'mediaId': 'source::one', 'title': 'One'}
      ],
    });
    expect(document.rows('playlists').single['name'], 'Imported');
    expect(document.rows('playlists').single['entries'], ['source::one']);
  });

  test('arbitrary JSON and excessive nesting are rejected', () {
    expect(() => BackupDocument.decode('{"hello":"world"}'),
        throwsFormatException);
    final m = sample();
    dynamic nested = [];
    for (var i = 0; i < 20; i++) {
      nested = [nested];
    }
    m['extra'] = nested;
    expect(() => BackupDocument.fromMap(m), throwsFormatException);
  });

  test('portable preferences reject values that can break the settings UI', () {
    for (final setting in [
      {'key': 'crossfadeDuration', 'value': '999'},
      {'key': 'languageCode', 'value': 'not-a-language'},
      {'key': 'eqEnabled', 'value': 'true'},
      {'key': 'autoHistoryCleanupTime', 'value': '-7'},
      {'key': 'eqBandGains', 'value': '[100]'},
    ]) {
      final input = sample()..['settings'] = [setting];
      expect(() => BackupDocument.fromMap(input), throwsFormatException);
    }
  });

  test('operation queue preserves order and survives a failure', () async {
    final queue = SerialExecutor();
    final order = <int>[];
    final first = queue.run(() async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      order.add(1);
    });
    final failure = queue.run<void>(() async {
      order.add(2);
      throw StateError('injected');
    });
    final handled = expectLater(failure, throwsStateError);
    final last = queue.run(() async {
      order.add(3);
      return 42;
    });
    await first;
    await handled;
    expect(await last, 42);
    expect(order, [1, 2, 3]);
  });
}
