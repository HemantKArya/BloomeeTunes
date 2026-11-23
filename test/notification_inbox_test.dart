import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/widgets/feed_card.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:Bloomee/services/feed/feed_rules.dart';
import 'package:Bloomee/services/feed/feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Settings in memory instead of Isar.
class _Settings implements SettingsDAO {
  final strings = <String, String>{};
  final bools = <String, bool>{};

  @override
  Future<String?> getSettingStr(String key, {String? defaultValue}) async =>
      strings[key] ?? defaultValue;
  @override
  Future<void> putSettingStr(String key, String value) async =>
      strings[key] = value;
  @override
  Future<bool?> getSettingBool(String key, {bool? defaultValue}) async =>
      bools[key] ?? defaultValue;
  @override
  Future<void> putSettingBool(String key, bool value) async =>
      bools[key] = value;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _feed = {
  'items': [
    {
      'id': 'store',
      'kind': 'app',
      'home': true,
      'title': {'en': 'Bloomee is on the Store', 'de': 'Bloomee im Store'},
      'body': 'Automatic updates.',
      'action': {'label': 'Get it', 'url': 'https://example.com/store'},
    },
    {'id': 'form', 'kind': 'form', 'home': true, 'title': 'Join the beta'},
    {'id': 'draft', 'draft': true, 'title': 'Not live yet'},
    {'id': 'android', 'platforms': ['android'], 'title': 'Android only'},
  ]
};

void main() {
  late Directory dir;
  late _Settings settings;
  final now = DateTime.utc(2026, 12, 10);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('inbox_test');
    File('${dir.path}/feed.json').writeAsStringSync(jsonEncode(_feed));
    settings = _Settings()
      // Installed a while ago, so Home may show a card.
      ..strings[SettingKeys.feedMemory] = jsonEncode(
          FeedMemory(firstRun: now.subtract(const Duration(days: 5)))
              .toJson());
  });
  tearDown(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  NotificationCubit cubit({String? update}) => NotificationCubit(
        settingsDao: settings,
        // The published URL, served from a temp cache: not a preview.
        feed: FeedService(
          source: FeedService.defaultUrl,
          cacheDir: () async {
            final cache = File('${dir.path}/feed_cache.json');
            if (!cache.existsSync()) {
              cache.writeAsStringSync(jsonEncode({
                'body': jsonEncode(_feed),
                'fetchedAt': now.toIso8601String(),
              }));
            }
            return dir;
          },
          now: () => now,
        ),
        now: () => now,
        audience: () async => const FeedAudience(
            platform: 'windows', storeBuild: false, appVersion: '3.1.1'),
        checkUpdate: () async => update,
        startDelay: Duration.zero,
      );

  /// Builds the cubit with real async (file reads) and waits until the
  /// feed and the update are in.
  Future<NotificationCubit> ready(WidgetTester tester, {String? update}) async {
    late NotificationCubit c;
    await tester.runAsync(() async {
      c = cubit(update: update);
      for (var i = 0; i < 200; i++) {
        if (c.state.items.isNotEmpty &&
            (update == null || c.state.update != null)) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    return c;
  }

  Widget app(NotificationCubit c, Widget child) => BlocProvider.value(
        value: c,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      );

  testWidgets('inbox lists the update and live entries, then marks seen',
      (tester) async {
    final c = await ready(tester, update: '3.2.0+90');
    expect(c.state.unread, 3, reason: 'update + two live entries');

    await tester.pumpWidget(app(c, const NotificationView()));
    await tester.pumpAndSettle();

    expect(find.text('Bloomee 3.2.0+90 is available'), findsOneWidget);
    expect(find.text('Bloomee is on the Store'), findsOneWidget);
    expect(find.text('Join the beta'), findsOneWidget);
    expect(find.text('Not live yet'), findsNothing, reason: 'draft');
    expect(find.text('Android only'), findsNothing, reason: 'other platform');
    expect(find.text('Get it'), findsOneWidget);
    expect(find.text('New'), findsNWidgets(3));
    expect(c.state.unread, 0, reason: 'opening the inbox marks it seen');

    // Dismiss "Join the beta".
    final card = find.ancestor(
        of: find.text('Join the beta'), matching: find.byType(FeedCard));
    await tester.tap(
        find.descendant(of: card, matching: find.byTooltip('Dismiss')));
    await tester.pumpAndSettle();
    expect(find.text('Join the beta'), findsNothing);
    expect(
        FeedMemory.fromJson(
                jsonDecode(settings.strings[SettingKeys.feedMemory]!))
            .dismissed,
        {'form'});

    // Preview shows the draft (debug builds only).
    expect(c.canPreview, isTrue);
    await tester.tap(find.byTooltip('Preview drafts'));
    await tester.pumpAndSettle();
    expect(find.text('Not live yet'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);

    await c.close();
  });

  testWidgets('Home cards come one at a time, the next right after closing',
      (tester) async {
    final c = await ready(tester);
    await tester.pumpWidget(app(c, const HomeFeedCard()));
    await tester.pumpAndSettle();
    expect(find.text('Bloomee is on the Store'), findsOneWidget);

    expect(find.text('Join the beta'), findsNothing, reason: 'one at a time');

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Bloomee is on the Store'), findsNothing);
    expect(find.text('Join the beta'), findsOneWidget, reason: 'next in line');
    expect(c.state.items.map((i) => i.id), contains('store'),
        reason: 'still in the inbox');

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(FeedCard), findsNothing);
    expect(c.state.homeCard, isNull, reason: 'queue empty');

    await c.setShowOnHome(false);
    expect(settings.bools[SettingKeys.feedOnHome], isFalse);
    await c.close();
  });

  testWidgets('entries follow the app language', (tester) async {
    final c = await ready(tester);
    await tester.pumpWidget(BlocProvider.value(
      value: c,
      child: const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationView(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bloomee im Store'), findsOneWidget);
    expect(find.text('Join the beta'), findsOneWidget, reason: 'English');
    await c.close();
  });
}
