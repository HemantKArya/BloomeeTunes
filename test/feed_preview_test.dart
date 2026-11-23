// Renders the inbox and Home card to PNG files, using the real fonts:
//
//   flutter test test/feed_preview_test.dart
//
// build/feed_preview/feed.png     your ghpage/feed.json (drafts included)
// build/feed_preview/gallery.png  one entry of every kind, for the design
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/widgets/feed_card.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:Bloomee/services/feed/feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings implements SettingsDAO {
  final _s = <String, String>{};
  @override
  Future<String?> getSettingStr(String key, {String? defaultValue}) async =>
      _s[key] ?? defaultValue;
  @override
  Future<void> putSettingStr(String key, String value) async => _s[key] = value;
  @override
  Future<bool?> getSettingBool(String key, {bool? defaultValue}) async =>
      defaultValue;
  @override
  Future<void> putSettingBool(String key, bool value) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _gallery = {
  'items': [
    {
      'id': 'notice',
      'kind': 'notice',
      'urgent': true,
      'title': 'YouTube Music search is down',
      'body': 'A fix is on the way. Other sources keep working.',
    },
    {
      'id': 'app',
      'kind': 'app',
      'home': true,
      'title': 'Meet Melodex',
      'body': 'Our new lyrics app. Free and open source.',
      'action': {'label': 'Get it', 'url': 'https://example.com'},
    },
    {
      'id': 'form',
      'kind': 'form',
      'title': 'Join the Bloomee 4 beta',
      'body': 'Try new features early and tell us what you think.',
      'action': {'label': 'Sign up', 'url': 'https://example.com'},
    },
    {
      'id': 'news',
      'title': 'Bloomee is on the Microsoft Store',
      'body': 'Automatic updates and a cleaner install.',
      'action': {'url': 'https://example.com'},
    },
  ]
};

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> assets) async {
    final loader = FontLoader(name);
    for (final a in assets) {
      loader.addFont(rootBundle.load(a));
    }
    await loader.load();
  }

  await family('Gilroy', [
    'assets/fonts/Gilroy/Gilroy-Regular.ttf',
    'assets/fonts/Gilroy/Gilroy-Medium.ttf',
    'assets/fonts/Gilroy/Gilroy-Bold.ttf',
  ]);
  await family('packages/icons_plus/MingCute',
      ['packages/icons_plus/assets/fonts/MingCute.ttf']);
}

void main() {
  final out = Directory('build/feed_preview');

  setUpAll(() async {
    await _loadFonts();
    out.createSync(recursive: true);
  });

  Future<void> render(
      WidgetTester tester, String name, String feedPath) async {
    tester.view.physicalSize = const Size(1240, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    late NotificationCubit cubit;
    await tester.runAsync(() async {
      cubit = NotificationCubit(
        settingsDao: _Settings(),
        feed: FeedService(source: feedPath),
        audience: () async => const FeedAudience(
            platform: 'windows', storeBuild: false, appVersion: '3.1.1'),
        checkUpdate: () async => '3.2.0+90',
        startDelay: Duration.zero,
      );
      for (var i = 0;
          i < 200 &&
              (cubit.state.update == null ||
                  cubit.state.refreshing ||
                  cubit.state.items.isEmpty);
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });

    final key = GlobalKey();
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
          key: key,
          child: Material(
            color: Default_Theme.themeColor,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const HomeFeedCard(),
                Container(
                    height: 1,
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.1)),
                const Expanded(child: NotificationView()),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${out.path}/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
    // ignore: avoid_print
    print('Preview: ${out.absolute.path}${Platform.pathSeparator}$name.png');
    await cubit.close();
  }

  testWidgets('render ghpage/feed.json', (tester) async {
    await render(tester, 'feed', 'ghpage/feed.json');
  }, skip: !File('ghpage/feed.json').existsSync());

  testWidgets('render every kind of entry', (tester) async {
    final file = File('${out.path}/gallery.json')
      ..writeAsStringSync(jsonEncode(_gallery));
    await render(tester, 'gallery', file.path);
  });
}
