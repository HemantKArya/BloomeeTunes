import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:Bloomee/services/feed/feed_rules.dart';
import 'package:Bloomee/services/feed/feed_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _windows =
    FeedAudience(platform: 'windows', storeBuild: false, appVersion: '3.1.1');
const _store =
    FeedAudience(platform: 'windows', storeBuild: true, appVersion: '3.1.1');
const _android =
    FeedAudience(platform: 'android', storeBuild: false, appVersion: '3.0.0');

FeedItem _item(Map<String, Object?> json) =>
    FeedItem.tryParse({'id': 'x', 'title': 'T', ...json})!;

void main() {
  final now = DateTime.utc(2026, 12, 10, 12);

  group('parsing', () {
    test('skips unusable entries and repeated ids, keeps the rest', () {
      final items = FeedItem.parseFeed({
        'items': [
          {'id': 'a', 'title': 'A'},
          {'id': 'a', 'title': 'again'},
          {'title': 'no id'},
          {'id': 'b'},
          'junk',
          {'id': 'c', 'title': {'en': 'C'}, 'kind': 'nonsense'},
        ]
      });
      expect(items.map((i) => i.id), ['a', 'c']);
      expect(items.last.kind, FeedKind.announcement);
    });

    test('a document that is not a feed throws', () {
      expect(() => FeedItem.parseFeed([]), throwsFormatException);
      expect(() => FeedItem.parseFeed({'items': 3}), throwsFormatException);
    });

    test('text falls back from locale to language to English', () {
      final text = FeedText.parse(
          {'en': 'Hi', 'pt': 'Olá', 'pt_BR': 'Oi', 'hi': 'नमस्ते'})!;
      expect(text.resolve(const Locale('pt', 'BR')), 'Oi');
      expect(text.resolve(const Locale('pt', 'PT')), 'Olá');
      expect(text.resolve(const Locale('ja')), 'Hi');
      expect(FeedText.parse({'de': 'Hallo'})!.resolve(const Locale('ja')),
          'Hallo');
      expect(FeedText.parse('  '), isNull);
    });

    test('only safe links are kept; the link follows the install', () {
      final item = _item({
        'action': {
          'url': {
            'android': 'https://play.google.com/x',
            'store': 'ms-windows-store://pdp/?productid=1',
            'default': 'https://example.com',
            'linux': 'javascript:alert(1)',
            'macos': 'http://insecure.example.com',
          }
        },
        'image': 'http://insecure.example.com/a.png',
        'icon': 'http://insecure.example.com/logo.png',
      });
      expect(item.actionUrlFor(_android), 'https://play.google.com/x');
      expect(item.actionUrlFor(_store), 'ms-windows-store://pdp/?productid=1');
      expect(item.actionUrlFor(_windows), 'https://example.com');
      expect(
          item.actionUrlFor(const FeedAudience(
              platform: 'linux', storeBuild: false, appVersion: '1')),
          'https://example.com');
      expect(item.image, isNull);
      expect(item.icon, isNull);
      expect(_item({'icon': 'https://example.com/logo.png'}).icon,
          'https://example.com/logo.png');
      expect(_item({}).actionUrlFor(_windows), isNull);
    });

    test('versions compare numerically', () {
      expect(compareVersions('3.1.10', '3.1.9'), 1);
      expect(compareVersions('v3.1.1+90', '3.1.1'), 0);
      expect(compareVersions('3.1', '3.1.0'), 0);
      expect(compareVersions('2.9.9', '3.0.0'), -1);
    });
  });

  group('targeting', () {
    test('drafts only in preview', () {
      final draft = _item({'draft': true});
      expect(draft.targets(_windows, now), isFalse);
      expect(draft.targets(_windows, now, preview: true), isTrue);
    });

    test('end date includes the whole day', () {
      final item = _item({'start': '2026-12-10', 'end': '2026-12-10'});
      expect(item.targets(_windows, DateTime.utc(2026, 12, 9, 23)), isFalse);
      expect(item.targets(_windows, DateTime.utc(2026, 12, 10, 23, 59)),
          isTrue);
      expect(item.targets(_windows, DateTime.utc(2026, 12, 11)), isFalse);
      // Scheduled entries can be previewed early.
      expect(
          item.targets(_windows, DateTime.utc(2026, 1, 1), preview: true),
          isTrue);
    });

    test('platform, store and version filters', () {
      expect(_item({'platforms': ['android']}).targets(_windows, now), isFalse);
      expect(_item({'platforms': ['Windows']}).targets(_windows, now), isTrue);
      expect(_item({'store': false}).targets(_store, now), isFalse);
      expect(_item({'store': true}).targets(_store, now), isTrue);
      expect(_item({'minVersion': '3.1.0'}).targets(_android, now), isFalse);
      expect(_item({'maxVersion': '3.0.5'}).targets(_windows, now), isFalse);
      // Audience filters apply in preview too: previews show this install.
      expect(
          _item({'platforms': ['ios']}).targets(_windows, now, preview: true),
          isFalse);
    });
  });

  group('rules', () {
    final a = _item({'id': 'a', 'home': true});
    final b = _item({'id': 'b'});
    final urgent = _item({'id': 'u', 'urgent': true});
    final settled = FeedMemory(firstRun: now.subtract(const Duration(days: 2)));

    test('inbox: urgent first, then feed order, dismissed removed', () {
      expect(
          FeedRules.inbox([a, b, urgent], _windows, now, settled)
              .map((i) => i.id),
          ['u', 'a', 'b']);
      final memory = FeedRules.dismiss(settled, a);
      expect(FeedRules.inbox([a, b], _windows, now, memory).map((i) => i.id),
          ['b']);
      expect(
          FeedRules.inbox([a, b], _windows, now, memory, preview: true).length,
          2);
    });

    test('home: one card at a time, the next right after closing', () {
      expect(FeedRules.homeCard([a, b], now, settled, enabled: true), a);
      expect(FeedRules.homeCard([b], now, settled, enabled: true), isNull);
      expect(FeedRules.homeCard([a], now, settled, enabled: false), isNull);

      final fresh = FeedMemory(firstRun: now);
      expect(FeedRules.homeCard([a], now, fresh, enabled: true), isNull);

      // The queue moves on immediately, in feed order.
      final c = _item({'id': 'c', 'home': true});
      final d = _item({'id': 'd', 'home': true});
      var memory = FeedRules.closeHomeCard(settled, a);
      expect(FeedRules.homeCard([a, b, c, d], now, memory, enabled: true), c);
      memory = FeedRules.closeHomeCard(memory, c);
      expect(FeedRules.homeCard([a, b, c, d], now, memory, enabled: true), d);
      memory = FeedRules.closeHomeCard(memory, d);
      expect(FeedRules.homeCard([a, b, c, d], now, memory, enabled: true),
          isNull);

      // Seen in the inbox: no longer pushed on Home.
      final seen = FeedRules.markSeen(settled, [a]);
      expect(FeedRules.homeCard([a], now, seen, enabled: true), isNull);
    });

    test('urgent stays on Home until closed, whatever the settings', () {
      final memory = FeedRules.markSeen(FeedMemory(firstRun: now), [urgent]);
      expect(
          FeedRules.homeCard([urgent], now, memory, enabled: false), urgent);
      final closed = FeedRules.closeHomeCard(memory, urgent);
      expect(FeedRules.homeCard([urgent], now, closed, enabled: false), isNull);
    });

    test('memory survives a round trip and is pruned to live ids', () {
      final memory = FeedRules.dismiss(
          FeedRules.markSeen(settled, [a, b], update: '3.2.0+90'), b);
      final restored =
          FeedMemory.fromJson(jsonDecode(jsonEncode(memory.toJson())));
      expect(restored.seen, {'a', 'b'});
      expect(restored.dismissed, {'b'});
      expect(restored.seenUpdate, '3.2.0+90');
      expect(restored.firstRun, settled.firstRun);
      final pruned = restored.prunedTo(['a']);
      expect(pruned.seen, {'a'});
      expect(pruned.dismissed, isEmpty);
      expect(FeedMemory.fromJson('garbage').seen, isEmpty);
    });
  });

  group('FeedService', () {
    late Directory dir;
    late DateTime clock;
    final requests = <http.Request>[];
    var reply = http.Response('', 500);

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('feed_test');
      clock = now;
      requests.clear();
    });
    tearDown(() => dir.delete(recursive: true));

    FeedService service() => FeedService(
          source: FeedService.defaultUrl,
          client: MockClient((request) async {
            requests.add(request);
            return reply;
          }),
          cacheDir: () async => dir,
          now: () => clock,
        );

    String feed(List<String> ids) => jsonEncode({
          'items': [for (final id in ids) {'id': id, 'title': id}]
        });

    test('caches, waits out the TTL, then asks only if it changed', () async {
      reply = http.Response(feed(['a']), 200, headers: {'etag': '"v1"'});
      final first = service();
      expect((await first.refresh())!.map((i) => i.id), ['a']);
      expect(await first.refresh(), isNull, reason: 'still fresh');
      expect(requests, hasLength(1));

      // A new launch reads the cached copy straight away.
      final second = service();
      expect((await second.cached()).map((i) => i.id), ['a']);

      clock = now.add(FeedService.ttl);
      reply = http.Response('', 304);
      expect((await second.refresh())!.map((i) => i.id), ['a']);
      expect(requests.last.headers['If-None-Match'], '"v1"');

      // Forced (pull to refresh) ignores the TTL.
      reply = http.Response(feed(['b', 'a']), 200);
      expect((await second.refresh(force: true))!.map((i) => i.id),
          ['b', 'a']);
    });

    test('a broken or unreachable feed keeps the last good copy', () async {
      reply = http.Response(feed(['a']), 200);
      await service().refresh();

      clock = now.add(FeedService.ttl);
      reply = http.Response('<html>oops</html>', 200);
      final s = service();
      expect(await s.refresh(), isNull);
      reply = http.Response('', 503);
      expect(await s.refresh(force: true), isNull);
      expect((await s.cached()).map((i) => i.id), ['a']);
    });

    test('simultaneous refreshes share one request', () async {
      reply = http.Response(feed(['a']), 200);
      final s = service();
      await Future.wait([s.refresh(), s.refresh(), s.refresh()]);
      expect(requests, hasLength(1));
    });

    test('a local file previews the feed and is re-read every time',
        () async {
      final file = File('${dir.path}/feed.json')
        ..writeAsStringSync(feed(['draft']));
      final s = FeedService(source: file.path, cacheDir: () async => dir);
      expect(s.isPreviewSource, isTrue);
      expect((await s.refresh())!.single.id, 'draft');
      file.writeAsStringSync(feed(['edited']));
      expect((await s.refresh())!.single.id, 'edited');
    });
  });

  // ghpage/feed.json is git-ignored (deploy_page.py --feed sends it straight to the
  // ghpage branch), so a fresh checkout does not have it.
  final published = File('ghpage/feed.json');
  test('your ghpage/feed.json is valid', () {
    final raw = jsonDecode(published.readAsStringSync());
    final items = FeedItem.parseFeed(raw);
    expect(items, hasLength((raw['items'] as List).length),
        reason: 'every entry needs an id and a title, ids unique');
    for (final item in items) {
      final action = (raw['items'] as List)
          .firstWhere((e) => e['id'] == item.id)['action'];
      if (action != null) {
        expect(item.actionUrls, isNotEmpty,
            reason: '${item.id}: action links must be https or a store link');
      }
    }
  },
      skip: published.existsSync()
          ? false
          : 'ghpage/feed.json is not in this checkout');
}
