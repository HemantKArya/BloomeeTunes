// Renders the Home layout (charts carousel and shelves) at phone and
// desktop widths, with the app's placeholder artwork:
//
//   flutter test test/home_preview_test.dart
//
// build/home_preview/phone.png and build/home_preview/desktop.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home/chart_carousel.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/screens/screen/home/media_shelf.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _fonts() async {
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
  await family('Fjalla', ['assets/fonts/Fjalla/FjallaOne-Regular.ttf']);
  await family('packages/icons_plus/MingCute',
      ['packages/icons_plus/assets/fonts/MingCute.ttf']);
}

void main() {
  final out = Directory('build/home_preview');

  setUpAll(() async {
    await _fonts();
    out.createSync(recursive: true);
  });

  Future<void> render(WidgetTester tester, String name, Size size) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    // No network in tests: cards show the placeholder artwork.
    Artwork cover(int i) => const Artwork(url: '', layout: ImageLayout.square);

    final charts = [
      for (final t in [
        'Top 50 · Global',
        'Viral Hits',
        'Top 50 · India',
        'Fresh Finds',
        'Indie Rising',
        'Lo-fi Beats',
        'Top Albums',
      ])
        ChartSummary(id: t, title: t, thumbnail: cover(t.length)),
    ];
    Section albums(String title, int offset) => Section(
          id: title,
          title: title,
          subtitle: offset == 0 ? 'Picked for your evening' : null,
          cardType: CardType.carousel,
          items: [
            for (var i = 0; i < 12; i++)
              MediaItem.album(AlbumSummary(
                id: '$title$i',
                title: [
                  'Midnight Drive',
                  'Golden Hour',
                  'Paper Planes',
                  'Neon Rain',
                  'Slow Bloom',
                  'Afterglow'
                ][i % 6],
                artists: [
                  ArtistSummary(
                      id: 'x$i',
                      name: [
                        'Aurora Lane',
                        'The Velvet',
                        'Kavya',
                        'Nightfall'
                      ][i % 4]),
                ],
                thumbnail: cover(i + offset),
              )),
          ],
        );
    final artists = Section(
      id: 'artists',
      title: 'Artists you might like',
      cardType: CardType.carousel,
      items: [
        for (var i = 0; i < 10; i++)
          MediaItem.artist(ArtistSummary(
            id: 'ar$i',
            name: [
              'Aurora Lane',
              'The Velvet',
              'Kavya',
              'Nightfall',
              'Mira'
            ][i % 5],
            subtitle: 'Artist',
            thumbnail: cover(i + 5),
          )),
      ],
    );

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: RepaintBoundary(
        key: key,
        child: Material(
          color: Default_Theme.themeColor,
          child: LayoutBuilder(builder: (context, c) {
            final m = HomeMetrics(width: c.maxWidth, screenHeight: c.maxHeight);
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text('Discover',
                      style: Default_Theme.primaryTextStyle.copyWith(
                          fontSize: 34, color: Default_Theme.primaryColor1)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ChartCarouselView(
                    charts: charts,
                    height: m.chartHeight,
                    viewportFraction: m.chartFraction,
                    enlargeCenter: m.isMobile,
                    autoPlay: false,
                    onOpen: (_) {},
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      const HomeCategoryLabel('Recently'),
                      Expanded(
                        child: Container(
                          height: 220,
                          margin: const EdgeInsets.only(right: 16),
                          alignment: Alignment.center,
                          child: Text('(song rows need the player)',
                              style: TextStyle(
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.3))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final s in [
                albums('New releases', 0),
                artists,
                albums('Trending now', 6),
              ])
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: HomeMediaShelf(section: s, pluginId: 'p'),
                  ),
                ),
            ]);
          }),
        ),
      ),
    ));
    // Let the placeholder images decode before the snapshot.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${out.path}/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
    // ignore: avoid_print
    print('Preview: ${out.absolute.path}${Platform.pathSeparator}$name.png');
  }

  testWidgets('phone', (t) => render(t, 'phone', const Size(400, 1000)));
  testWidgets('desktop', (t) => render(t, 'desktop', const Size(1280, 900)));
}
