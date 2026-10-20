import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/player_screen.dart';
import 'package:Bloomee/screens/widgets/player_overlay_wrapper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/player_test_fixture.dart';

void main() {
  Future<void> finishTransition(WidgetTester tester) async {
    // Deliver real vsync-sized steps, including the first tick after a
    // reversal and the frame scheduled by the dismissed status callback.
    for (var frame = 0; frame < 26; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<PlayerOverlayCubit> mount(WidgetTester tester,
      {bool initiallyVisible = false, bool disableAnimations = false}) async {
    final player = TestMusicPlayer();
    // No palette/network work is needed for these lifecycle tests.
    player.mediaItem.add(player.mediaItem.value!.copyWith(artUri: null));
    final playerCubit = BloomeePlayerCubit(player);
    final progress =
        BehaviorSubject<ProgressBarStreams>.seeded(ProgressBarStreams(
      position: Duration.zero,
      duration: const Duration(minutes: 3),
      buffered: Duration.zero,
      isPlaying: true,
    ));
    playerCubit.progressStreams = progress;
    final mini = MiniPlayerCubit(playerCubit: playerCubit);
    final overlay = PlayerOverlayCubit();
    if (initiallyVisible) overlay.showPlayer();
    addTearDown(() async {
      await mini.close();
      await playerCubit.close();
      await overlay.close();
      await player.closeStreams();
      await progress.close();
    });
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1580, 880);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: playerCubit),
        BlocProvider.value(value: mini),
        BlocProvider.value(value: overlay),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        // Deliberately no parent subscription to overlay visibility: the
        // overlay must not rely on a navigation-shell rebuild to open.
        home: const PlayerOverlayWrapper(child: _AnimatedLibrary()),
      ),
    ));
    await tester.pump();
    return overlay;
  }

  testWidgets('first open works without rebuilding the navigation shell',
      (tester) async {
    final overlay = await mount(tester);
    overlay.showPlayer();
    await tester.pump();
    await finishTransition(tester);
    expect(find.byType(AudioPlayerView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('initially visible overlay is displayed immediately',
      (tester) async {
    await mount(tester, initiallyVisible: true);
    await tester.pump();
    expect(find.byType(AudioPlayerView), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'closing retains the player but pauses covered and hidden tickers',
      (tester) async {
    final overlay = await mount(tester);
    final library =
        tester.state<_AnimatedLibraryState>(find.byType(_AnimatedLibrary));
    overlay.showPlayer();
    await tester.pump();
    await finishTransition(tester);
    final player = tester.state(find.byType(AudioPlayerView));
    final coveredTicks = library.ticks;
    await tester.pump(const Duration(milliseconds: 100));
    expect(library.ticks, coveredTicks);
    overlay.hidePlayer();
    await tester.pump();
    await finishTransition(tester);
    expect(find.byType(AudioPlayerView), findsNothing);
    expect(find.byType(AudioPlayerView, skipOffstage: false), findsOneWidget);
    final hiddenPlayerElement =
        tester.element(find.byType(AudioPlayerView, skipOffstage: false));
    expect(TickerMode.valuesOf(hiddenPlayerElement).enabled, isFalse);
    final visibleTicks = library.ticks;
    await tester.pump(const Duration(milliseconds: 100));
    expect(library.ticks, greaterThan(visibleTicks));
    overlay.showPlayer();
    await tester.pump();
    await finishTransition(tester);
    expect(tester.state(find.byType(AudioPlayerView)), same(player));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('prepares once and disconnects hidden progress updates',
      (tester) async {
    final overlay = await mount(tester);
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    expect(find.byType(AudioPlayerView), findsNothing);
    final hidden = find.byType(AudioPlayerView, skipOffstage: false);
    expect(hidden, findsOneWidget);
    final preparedState = tester.state(hidden);
    final progress = tester
        .element(find.byType(PlayerOverlayWrapper))
        .read<BloomeePlayerCubit>()
        .progressStreams as BehaviorSubject<ProgressBarStreams>;
    expect(progress.hasListener, isFalse);
    overlay.showPlayer();
    await finishTransition(tester);
    expect(progress.hasListener, isTrue);
    expect(tester.state(find.byType(AudioPlayerView)), same(preparedState));
    overlay.hidePlayer();
    await finishTransition(tester);
    expect(progress.hasListener, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion switches immediately and releases snapshots',
      (tester) async {
    final overlay = await mount(tester, disableAnimations: true);
    overlay.showPlayer();
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(find.byType(AudioPlayerView)).dy, 0);
    expect(
        tester
            .widget<SnapshotWidget>(find.byType(SnapshotWidget))
            .controller
            .allowSnapshotting,
        isFalse);
    overlay.hidePlayer();
    await tester.pump();
    await tester.pump();
    expect(find.byType(AudioPlayerView), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('rapid reversals end in the requested visibility',
      (tester) async {
    final overlay = await mount(tester);
    overlay.showPlayer();
    await tester.pump();
    overlay.hidePlayer();
    await tester.pump(const Duration(milliseconds: 50));
    overlay.showPlayer();
    await tester.pump();
    await finishTransition(tester);
    expect(find.byType(AudioPlayerView), findsOneWidget);
    overlay.hidePlayer();
    await tester.pump();
    await finishTransition(tester);
    expect(find.byType(AudioPlayerView), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

class _AnimatedLibrary extends StatefulWidget {
  const _AnimatedLibrary();

  @override
  State<_AnimatedLibrary> createState() => _AnimatedLibraryState();
}

class _AnimatedLibraryState extends State<_AnimatedLibrary>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;
  int ticks = 0;

  @override
  void initState() {
    super.initState();
    animation =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() => ticks++)
          ..repeat();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Library'));

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }
}
