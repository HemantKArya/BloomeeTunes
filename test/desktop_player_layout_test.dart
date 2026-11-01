import 'package:Bloomee/screens/widgets/desktop_player_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const artworkKey = ValueKey('artwork');
  const controlsKey = ValueKey('controls');

  Future<void> showLayout(WidgetTester tester, Size size,
      {double textScale = 1}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: DesktopPlayerLayout(
            artwork: const Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(key: artworkKey, color: Colors.blue),
              ),
            ),
            controls: SizedBox(key: controlsKey, height: 250 * textScale),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  }

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('stacked desktop gives remaining height to square artwork',
      (tester) async {
    await showLayout(tester, const Size(600, 760));
    expect(tester.getSize(find.byKey(artworkKey)), const Size(360, 360));
    expect(tester.getBottomLeft(find.byKey(artworkKey)).dy,
        lessThan(tester.getTopLeft(find.byKey(controlsKey)).dy));
  });

  testWidgets('wide desktop places controls beside larger artwork',
      (tester) async {
    await showLayout(tester, const Size(1400, 760));
    final art = tester.getRect(find.byKey(artworkKey));
    final controls = tester.getRect(find.byKey(controlsKey));
    expect(art.width, 640);
    expect(controls.left, greaterThan(art.right));
    expect(controls.center.dy, art.center.dy);
  });

  testWidgets('reclaiming sidebar width enlarges the artwork', (tester) async {
    await showLayout(tester, const Size(1048, 760));
    final initialWidth = tester.getSize(find.byKey(artworkKey)).width;
    await showLayout(tester, const Size(1360, 760));
    expect(tester.getSize(find.byKey(artworkKey)).width,
        greaterThan(initialWidth));
  });

  testWidgets('short windows keep controls reachable by scrolling',
      (tester) async {
    await showLayout(tester, const Size(600, 360));
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(find.byKey(controlsKey)).dy,
        lessThanOrEqualTo(360));
  });

  testWidgets('larger text uses the scrollable compact layout', (tester) async {
    await showLayout(tester, const Size(600, 600), textScale: 2);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
