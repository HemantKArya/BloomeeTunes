import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/common_views/changelog_reader.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/player_test_fixture.dart';

class _Settings extends Cubit<SettingsState> implements SettingsCubit {
  _Settings() : super(SettingsInitial());
  int writes = 0;
  @override
  Future<void> putSettingStr(String key, String value) async {
    writes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Player extends TestMusicPlayer {
  int? selected;
  @override
  Future<void> skipToQueueItem(int index) async {
    selected = index;
  }
}

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme().defaultThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  setUp(() => PackageInfo.setMockInitialValues(
      appName: 'Bloomee',
      packageName: 'test.bloomee',
      version: '3.1.0',
      buildNumber: '0',
      buildSignature: ''));

  testWidgets(
      'long release builds visible changes and persists once across rebuilds',
      (tester) async {
    final settings = _Settings();
    addTearDown(settings.close);
    final entries = List.generate(1000, (i) => '- Release entry $i').join('\n');
    final text = '## [3.1.0] - 2026-10-21\n### Fixed\n$entries';
    var revision = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(BlocProvider<SettingsCubit>.value(
      value: settings,
      child: _app(StatefulBuilder(builder: (context, setState) {
        rebuild = setState;
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(revision == 0 ? 1 : 1.05)),
            child: ChangelogScreen(changelogText: text));
      })),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Release entry 0', findRichText: true), findsOneWidget);
    expect(find.byType(ChangeItemWidget).evaluate().length, lessThan(35));
    expect(find.text('Release entry 999', findRichText: true), findsNothing);
    rebuild(() => revision++);
    await tester.pumpAndSettle();
    expect(settings.writes, 1);
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.byType(ChangeItemWidget), findsNothing);
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.text('Release entry 0', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'About remains scrollable on small screens and animation does not rebuild painters',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 520);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const About()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final wave = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is WaveformPainter);
    final particles = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is ParticlePainter);
    final wavePainter = tester.widget<CustomPaint>(wave).painter;
    final particlePainter = tester.widget<CustomPaint>(particles).painter;
    await tester.pump(const Duration(milliseconds: 100));
    expect(identical(tester.widget<CustomPaint>(wave).painter, wavePainter),
        isTrue);
    expect(
        identical(
            tester.widget<CustomPaint>(particles).painter, particlePainter),
        isTrue);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('v3.1.0+0').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'mobile queue opens, closes and scrolls lazily with repeated songs',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final player = _Player();
    final cubit = BloomeePlayerCubit(player);
    addTearDown(() async {
      await cubit.close();
      await player.closeStreams();
    });
    final tracks =
        List.generate(1000, (i) => MediaItem(id: 'song_$i', title: 'Song $i'));
    tracks[1] = tracks[0];
    player.queue.add(tracks);
    player.mediaItem.add(tracks[500]);
    final controller = UpNextPanelController();
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: _app(Scaffold(
          body: LayoutBuilder(
              builder: (context, constraints) => UpNextPanel(
                  peekHeight: 60,
                  parentHeight: constraints.maxHeight,
                  controller: controller)))),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(controller.isExpanded, isFalse);
    controller.toggle();
    await tester.pumpAndSettle();
    expect(controller.isExpanded, isTrue);
    expect(find.text('Song 500'), findsOneWidget);
    expect(find.byType(SongCardWidget).evaluate().length, lessThan(30));
    await tester.fling(
        find.byType(CustomScrollView), const Offset(0, -600), 1800);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final scroll = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    scroll.jumpTo(0);
    await tester.pumpAndSettle();
    expect(find.text('Song 0'), findsNWidgets(2));
    final second = find.byType(SongCardWidget).at(1);
    await tester.tap(second);
    await tester.pump();
    expect(player.selected, 1);
    expect(controller.collapse(), isTrue);
    await tester.pumpAndSettle();
    expect(controller.isExpanded, isFalse);
    expect(tester.takeException(), isNull);
  });
}
