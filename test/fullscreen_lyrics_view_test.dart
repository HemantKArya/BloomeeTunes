import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart'
    show Track, Artwork, ImageLayout;
import 'package:Bloomee/screens/screen/player_views/fullscreen_lyrics_view.dart';
import 'package:Bloomee/screens/widgets/artwork_ambient_background.dart';
import 'package:Bloomee/screens/widgets/gradient_progress_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:Bloomee/screens/widgets/player_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'support/player_test_fixture.dart';

class _Lyrics extends Cubit<LyricsState> implements LyricsCubit {
  _Lyrics(super.initialState);
  int? savedOffset;
  bool failSave = false;
  void replace(LyricsState state) => emit(state);

  @override
  Future<void> setLyricsToDB(Lyrics lyrics, String mediaID,
      {int? offset}) async {
    if (failSave) throw StateError('test storage failure');
    savedOffset = offset;
    emit(LyricsLoaded(lyrics.copyWith(offset: offset), state.track));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Lyrics _document({int offset = 0, bool plain = false}) => Lyrics(
      id: 'fixture',
      artist: 'Artist',
      title: 'Song',
      mediaID: 'current',
      provider: LyricsProvider.plugin,
      lyricsPlain: 'First line\nSecond line\nThird line',
      lyricsSynced: plain
          ? ''
          : List.generate(
                  24,
                  (i) =>
                      '[${((i + 1) * 10 ~/ 60).toString().padLeft(2, '0')}:${((i + 1) * 10 % 60).toString().padLeft(2, '0')}.00]Line ${i + 1}')
              .join('\n'),
      offset: offset,
    );

void main() {
  Future<(TestMusicPlayer, _Lyrics)> mount(WidgetTester tester,
      {int position = 0, int offset = 0, bool plain = false}) async {
    final player = TestMusicPlayer();
    (player.engine as TestPlayerEngine)
        .positions
        .add(Duration(seconds: position));
    final cubit = BloomeePlayerCubit(player);
    final mini = MiniPlayerCubit(playerCubit: cubit);
    final lyrics = _Lyrics(LyricsLoaded(
        _document(offset: offset, plain: plain), player.currentTrackInfo));
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await lyrics.close();
      await mini.close();
      await cubit.close();
      await player.closeStreams();
    });
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: mini),
        BlocProvider<LyricsCubit>.value(value: lyrics),
      ],
      child: MaterialApp(
        theme: AppTheme().defaultThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FullscreenLyricsView(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return (player, lyrics);
  }

  Finder selectedLines() => find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.selected == true);

  testWidgets(
      'lyrics fullscreen hides controls and Escape restores the same lyrics',
      (tester) async {
    final (player, _) = await mount(tester, position: 25);
    final lyricsState = tester.state(find.byType(FullscreenSyncedLyrics));
    expect(find.byType(PlayerProgressBar), findsOneWidget);
    await tester.tap(find.byTooltip('Fullscreen lyrics'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerProgressBar), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byTooltip('Exit fullscreen'), findsOneWidget);
    expect(
        tester.state(find.byType(FullscreenSyncedLyrics)), same(lyricsState));
    (player.engine as TestPlayerEngine)
        .positions
        .add(const Duration(seconds: 35));
    await tester.pumpAndSettle();
    expect(find.descendant(of: selectedLines(), matching: find.text('Line 3')),
        findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PlayerProgressBar), findsOneWidget);
    expect(
        tester.state(find.byType(FullscreenSyncedLyrics)), same(lyricsState));
    await tester.tap(find.byTooltip('Fullscreen lyrics'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Exit fullscreen'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerProgressBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'shared ambient, persistent controls, and correct pre-roll highlight',
      (tester) async {
    final (player, _) = await mount(tester);
    expect(find.byType(ArtworkAmbientBackground), findsOneWidget);
    expect(find.byType(GradientProgressBar), findsOneWidget);
    expect(selectedLines(), findsNothing);
    (player.engine as TestPlayerEngine)
        .positions
        .add(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(selectedLines(), findsOneWidget);
    (player.engine as TestPlayerEngine).positions.add(Duration.zero);
    await tester.pumpAndSettle();
    expect(selectedLines(), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    expect(find.byTooltip('More Options').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('mouse scrolling suspends following until explicitly resumed',
      (tester) async {
    final (player, _) = await mount(tester, position: 15);
    await tester.sendEventToBinding(PointerScrollEvent(
      position: tester.getCenter(find.byType(ScrollablePositionedList)),
      scrollDelta: const Offset(0, 220),
    ));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Follow playback'), findsOneWidget);
    (player.engine as TestPlayerEngine)
        .positions
        .add(const Duration(seconds: 25));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byTooltip('Follow playback'), findsOneWidget);
    await tester.tap(find.byTooltip('Follow playback'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Follow playback'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'lyric taps clamp seeks and timing supports cancel, failure, and save',
      (tester) async {
    final (player, lyrics) = await mount(tester, offset: 15000);
    await tester.tap(find.text('Line 1'));
    await tester.pumpAndSettle();
    expect(player.lastSeek, Duration.zero);

    Future<void> timing() async {
      await tester.tap(find.byTooltip('More Options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adjust Sync (Delay/Offset)'));
      await tester.pumpAndSettle();
    }

    await timing();
    await tester.tap(find.text('Earlier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(lyrics.state.lyrics.offset, 15000);
    expect(find.text('Save timing'), findsNothing);

    await timing();
    await tester.tap(find.text('Earlier'));
    await tester.pumpAndSettle();
    lyrics.failSave = true;
    await tester.tap(find.text('Save timing'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save lyrics. Try again.'), findsOneWidget);
    expect(find.text('Save timing'), findsOneWidget);
    lyrics.failSave = false;
    await tester.tap(find.text('Save timing'));
    await tester.pumpAndSettle();
    expect(lyrics.savedOffset, 15050);
    expect(find.text('Save timing'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a new track clears stale highlight and manual following state',
      (tester) async {
    final (_, lyrics) = await mount(tester, position: 25);
    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Follow playback'), findsOneWidget);
    const track = Track(
        id: 'next',
        title: 'Next track',
        artists: [],
        thumbnail: Artwork(url: '', layout: ImageLayout.square),
        isExplicit: false);
    lyrics.replace(LyricsLoaded(
        _document().copyWith(
            mediaID: 'next', id: 'new', lyricsSynced: '[01:00.00]New verse'),
        track));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Follow playback'), findsNothing);
    expect(selectedLines(), findsNothing);
    expect(find.text('New verse'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'empty timed data falls back to selectable plain lyrics on narrow windows',
      (tester) async {
    await mount(tester, plain: true);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.byType(FullscreenSyncedLyrics), findsNothing);
    for (final size in [
      const Size(900, 600),
      const Size(600, 800),
      const Size(360, 640)
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$size');
    }
    await tester.pumpWidget(const SizedBox());
  });
}
