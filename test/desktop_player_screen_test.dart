import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/player_screen.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/screens/widgets/artwork_ambient_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'support/player_test_fixture.dart';

void main() {
  testWidgets(
      'prototype desktop layout uses real controls and collapsible queue',
      (tester) async {
    final player = TestMusicPlayer();
    final cubit = BloomeePlayerCubit(player);
    final mini = MiniPlayerCubit(playerCubit: cubit);
    final overlay = PlayerOverlayCubit();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1580, 880);
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await mini.close();
      await cubit.close();
      await overlay.close();
      await player.closeStreams();
    });

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: mini),
        BlocProvider.value(value: overlay),
      ],
      child: MaterialApp(
        theme: AppTheme().defaultThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 800, name: TABLET),
            Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
          ],
        ),
        home: const AudioPlayerView(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final art = tester.getRect(find.byType(CoverImageVolSlider));
    final controls = tester.getRect(find.byType(PlayerCtrlWidgets));
    expect(art.width, greaterThan(450));
    expect(controls.left, greaterThan(art.right));
    expect(controls.center.dy, closeTo(art.center.dy, 1));
    expect(find.text('Up Next'), findsOneWidget);
    expect(tester.getSize(find.byType(ArtworkAmbientBackground)),
        const Size(1580, 880));
    final originalMedia = player.mediaItem.value!;
    final nextArt = Uri.parse('asset:next-artwork');
    player.mediaItem
        .add(MediaItem(id: 'next', title: 'Next track', artUri: nextArt));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ArtworkAmbientBackground>(
                find.byType(ArtworkAmbientBackground))
            .imageUrl,
        nextArt.toString());
    player.mediaItem.add(originalMedia);
    await tester.pumpAndSettle();

    final panelState = tester.state(find.byType(UpNextPanel));
    final queueController = tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .scrollController!;
    queueController.jumpTo(150);
    await tester.pumpAndSettle();
    final queueOffset = queueController.offset;
    await tester.tap(find.text('Up Next'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CoverImageVolSlider)).width,
        greaterThan(art.width));
    await tester.tap(find.byTooltip('Up Next'));
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(UpNextPanel)), same(panelState));
    expect(queueController.offset, queueOffset);

    // Exercise the shared background fallback on desktop and mobile.
    player.mediaItem
        .add(MediaItem(id: 'current', title: player.currentTrackInfo.title));
    await tester.pumpAndSettle();

    for (final width in [1280.0, 1100.0, 1024.0, 900.0, 801.0, 600.0]) {
      tester.view.physicalSize = Size(width, 880);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'window width $width');
      expect(find.byType(ArtworkAmbientBackground), findsOneWidget);
      expect(tester.getSize(find.byType(ArtworkAmbientBackground)),
          Size(width, 880));
    }
    for (final size in [const Size(801, 480), const Size(1580, 400)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'short window $size');
    }
    await tester.pumpWidget(const SizedBox());
  });
}
