import 'package:Bloomee/screens/screen/home/chart_carousel.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/screens/screen/home/media_shelf.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<ChartSummary> _charts(int n) => [
      for (var i = 0; i < n; i++) ChartSummary(id: 'c$i', title: 'Chart $i'),
    ];

Section _section(int n) => Section(
      id: 's',
      title: 'New albums',
      cardType: CardType.carousel,
      items: [
        for (var i = 0; i < n; i++)
          MediaItem.album(
              AlbumSummary(id: 'a$i', title: 'Album $i', artists: const [])),
      ],
    );

ChartCarouselView _carousel(
  int charts, {
  bool autoPlay = true,
  Duration startDelay = Duration.zero,
  ValueChanged<ChartSummary>? onOpen,
}) =>
    ChartCarouselView(
      charts: _charts(charts),
      height: 250,
      viewportFraction: 0.65,
      enlargeCenter: true,
      autoPlay: autoPlay,
      startDelay: startDelay,
      onOpen: onOpen ?? (_) {},
    );

void main() {
  Widget host(Widget child, {ValueNotifier<bool>? tickers}) => MaterialApp(
        home: Scaffold(
          body: tickers == null
              ? child
              : ValueListenableBuilder<bool>(
                  valueListenable: tickers,
                  builder: (_, on, __) => TickerMode(enabled: on, child: child),
                ),
        ),
      );

  ChartCarouselViewState carousel(WidgetTester tester) =>
      tester.state(find.byType(ChartCarouselView));

  // Zero-length timers fire once fake time moves.
  Future<void> settle(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 1));

  group('chart carousel', () {
    testWidgets('slides by itself after a short wait', (tester) async {
      await tester.pumpWidget(
          host(_carousel(4, startDelay: const Duration(seconds: 3))));
      expect(carousel(tester).isAutoPlaying, isFalse, reason: 'startup quiet');

      await tester.pump(const Duration(seconds: 3));
      expect(carousel(tester).isAutoPlaying, isTrue);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 700));
      expect(carousel(tester).activeIndex, 1);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 700));
      expect(carousel(tester).activeIndex, 2);
    });

    testWidgets('stops while Home is hidden and resumes after', (tester) async {
      final tickers = ValueNotifier(true);
      await tester.pumpWidget(host(_carousel(4), tickers: tickers));
      await settle(tester);
      expect(carousel(tester).isAutoPlaying, isTrue);

      // Another tab or a pushed page mutes tickers.
      tickers.value = false;
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isFalse);
      await tester.pump(const Duration(seconds: 10));
      expect(carousel(tester).activeIndex, 0, reason: 'did not move');

      tickers.value = true;
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isTrue);
    });

    testWidgets('keeps sliding while the window is unfocused', (tester) async {
      await tester.pumpWidget(host(_carousel(4)));
      await settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isTrue);

      // Minimised or in the tray: stop.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isFalse);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isTrue);
    });

    testWidgets('touching pauses; it resumes after release', (tester) async {
      await tester.pumpWidget(host(_carousel(4)));
      await settle(tester);

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(ChartCarouselView)));
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isFalse);
      await gesture.up();
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isTrue);
    });

    testWidgets('a resting mouse does not stop it', (tester) async {
      await tester.pumpWidget(host(_carousel(4)));
      await settle(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(ChartCarouselView)));
      await tester.pump();
      expect(carousel(tester).isAutoPlaying, isTrue);
    });

    testWidgets('a single chart or the setting off never slides',
        (tester) async {
      await tester.pumpWidget(host(_carousel(1)));
      await settle(tester);
      expect(carousel(tester).isAutoPlaying, isFalse);

      await tester.pumpWidget(host(_carousel(6, autoPlay: false)));
      await settle(tester);
      expect(carousel(tester).isAutoPlaying, isFalse);
    });

    testWidgets('tapping a card opens its chart', (tester) async {
      ChartSummary? opened;
      await tester.pumpWidget(
          host(_carousel(3, autoPlay: false, onOpen: (c) => opened = c)));
      await tester.tap(find.text('Chart 0').first);
      expect(opened?.id, 'c0');
    });
  });

  testWidgets('media shelf builds only the cards on screen', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(host(HomeMediaShelf(section: _section(60), pluginId: 'p')));
    final built = find.byType(HomeMediaCard).evaluate().length;
    expect(built, inInclusiveRange(2, 6), reason: '60 items, $built built');
    expect(find.text('New albums'), findsOneWidget);
  });

  test('metrics follow the original breakpoints', () {
    const phone = HomeMetrics(width: 390, screenHeight: 800);
    const tablet = HomeMetrics(width: 700, screenHeight: 1000);
    const desktop = HomeMetrics(width: 1300, screenHeight: 900);
    expect(phone.isMobile, isTrue);
    expect(tablet.isTablet, isTrue);
    expect(desktop.isMobile || desktop.isTablet, isFalse);
    expect(phone.chartFraction, 0.65);
    expect(desktop.chartFraction, 0.30);
    expect(desktop.chartHeight, 250);
    expect(phone.chartHeight, closeTo(288, 0.01));
    expect(phone.trackColumnWidth, closeTo((390 - 40) * 0.88, 0.01));
    expect(desktop.trackColumnWidth, closeTo((1300 - 40) * 0.48, 0.01));
  });
}
