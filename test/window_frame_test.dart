@TestOn('windows')
library;

import 'package:Bloomee/screens/widgets/window_frame.dart';
import 'package:Bloomee/services/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('window_manager');
const _codec = StandardMethodCodec();

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: GestureDetector(
          onTap: () => setState(() => taps++),
          child: Text('taps $taps'),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var maximized = false;
  final calls = <String>[];

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'isMaximized' => maximized,
        'isFullScreen' || 'isFocused' => call.method == 'isFocused',
        _ => null,
      };
    });
    await DesktopWindow.initialize();
  });

  Future<void> emit(WidgetTester tester, String event) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      _channel.name,
      _codec.encodeMethodCall(MethodCall('onEvent', {'eventName': event})),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  testWidgets('caption follows the window and never remounts the app',
      (tester) async {
    expect(DesktopWindow.isCustomFrame, isTrue);
    await tester.pumpWidget(const WindowFrame(child: _Counter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('taps 0'));
    await tester.pump();
    expect(find.text('taps 1'), findsOneWidget);
    expect(find.byTooltip('Maximize'), findsOneWidget);

    // The app below the caption gets the reduced height.
    final appSize = MediaQuery.sizeOf(tester.element(find.text('taps 1')));
    expect(
        appSize.height,
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
            WindowFrame.captionHeight);

    maximized = true;
    await emit(tester, 'maximize');
    expect(find.byTooltip('Restore Down'), findsOneWidget);
    expect(find.text('taps 1'), findsOneWidget, reason: 'state kept');

    maximized = false;
    await emit(tester, 'unmaximize');
    await emit(tester, 'minimize');
    await emit(tester, 'restore');
    expect(find.byTooltip('Maximize'), findsOneWidget);
    expect(find.text('taps 1'), findsOneWidget, reason: 'state kept');

    calls.clear();
    await tester.tap(find.byTooltip('Minimize'));
    await tester.tap(find.byTooltip('Maximize'));
    await tester.tap(find.byTooltip('Close'));
    expect(calls, containsAllInOrder(['minimize', 'maximize', 'close']));
  });

  test('close action: saved values, platform default, tray fallback', () {
    expect(DesktopCloseAction.parse('quit'), DesktopCloseAction.quit);
    expect(DesktopCloseAction.parse('minimize'), DesktopCloseAction.minimize);
    expect(DesktopCloseAction.parse(null), DesktopCloseAction.tray);
    expect(DesktopCloseAction.parse('bogus'), DesktopCloseAction.tray);

    // Hiding needs a tray icon to come back from; without one it minimises.
    DesktopWindow.closeAction.value = DesktopCloseAction.tray;
    expect(DesktopWindow.effectiveCloseAction, DesktopCloseAction.minimize);
    DesktopWindow.closeAction.value = DesktopCloseAction.quit;
    expect(DesktopWindow.effectiveCloseAction, DesktopCloseAction.quit);
  });
}
