// Temporary profiling harness for the search screen.
// Run: flutter drive --profile -d windows \
//   --driver test_driver/integration_test.dart \
//   --target integration_test/search_perf_test.dart --dart-define=PERF_OUT=<dir>
import 'dart:convert';
import 'dart:io';
import 'dart:developer' show Timeline;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:Bloomee/main.dart' as app;
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/routes/app_router.dart';
import 'package:Bloomee/screens/screen/search_screen.dart';

const _outDir = String.fromEnvironment('PERF_OUT');
const _profileWidgets = bool.fromEnvironment('PERF_WIDGETS');

Future<void> wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('search screen perf', (tester) async {
    app.main(const []);
    for (var i = 0; i < 40; i++) {
      await wait(250);
      await tester.pump();
    }

    // Wait for content-resolver plugins.
    PluginBloc? pluginBloc;
    for (var i = 0; i < 120; i++) {
      final els = find.byType(Scaffold).evaluate();
      if (els.isNotEmpty) {
        pluginBloc = els.first.read<PluginBloc>();
        if (pluginBloc.state.loadedContentResolvers.isNotEmpty) break;
      }
      await wait(250);
    }
    // ignore: avoid_print
    print('PERF plugins available='
        '${pluginBloc?.state.availablePlugins.map((p) => p.manifest.id).toList()} '
        'loaded=${pluginBloc?.state.loadedPluginIds} '
        'resolvers=${pluginBloc?.state.loadedContentResolvers.length}');

    if (_profileWidgets) {
      debugProfileBuildsEnabled = true;
      debugProfileLayoutsEnabled = true;
      debugProfilePaintsEnabled = true;
    }

    final phases = <String, Map<String, dynamic>>{};
    var current = 'startup';
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final p = phases.putIfAbsent(
            current, () => {'frames': 0, 'build': <int>[], 'raster': <int>[]});
        p['frames'] = (p['frames'] as int) + 1;
        final b = t.buildDuration.inMicroseconds;
        final r = t.rasterDuration.inMicroseconds;
        if (b > 8000) (p['build'] as List<int>).add(b);
        if (r > 8000) (p['raster'] as List<int>).add(r);
      }
    });

    Future<void> phase(String name, Future<void> Function() body) async {
      current = name;
      Timeline.instantSync('PHASE $name');
      await body();
      await wait(300);
    }

    Finder inSearch(Finder f) =>
        find.descendant(of: find.byType(SearchScreen), matching: f).first;

    await binding.traceAction(() async {
      await phase('open_search_first', () async {
        AppRouter.globalRouter.go('/Search');
        await wait(2500);
      });
      await phase('back_to_home', () async {
        AppRouter.globalRouter.go('/Explore');
        await wait(2000);
      });
      await phase('open_search_second', () async {
        AppRouter.globalRouter.go('/Search');
        await wait(2000);
      });

      final field = inSearch(find.byType(TextField));
      await phase('focus_field', () async {
        await tester.showKeyboard(field);
        await wait(2500);
      });
      await phase('typing', () async {
        const query = 'imagine dragons';
        for (var i = 1; i <= query.length; i++) {
          final tf = tester.widget<TextField>(field);
          tf.controller!.text = query.substring(0, i);
          tf.onChanged!(query.substring(0, i));
          await wait(120);
        }
        await wait(3000);
      });

      await phase('submit_and_results', () async {
        final tf = tester.widget<TextField>(field);
        tf.onSubmitted!(tf.controller!.text);
        await wait(7000);
      });

      await phase('scroll_results', () async {
        final scrollable = inSearch(find.byType(CustomScrollView));
        for (var i = 0; i < 4; i++) {
          await tester.fling(scrollable, const Offset(0, -600), 1500,
              warnIfMissed: false);
          await wait(700);
        }
        for (var i = 0; i < 4; i++) {
          await tester.fling(scrollable, const Offset(0, 600), 1500,
              warnIfMissed: false);
          await wait(700);
        }
        await wait(1000);
      });

      String typesIn(String name) => find
          .byWidgetPredicate((w) => w.runtimeType.toString() == name,
              skipOffstage: false)
          .evaluate()
          .length
          .toString();
      // ignore: avoid_print
      print('PERF after submit: songs=${typesIn('SongCardWidget')} '
          'suggestions=${typesIn('_SuggestionsSliver')} '
          'content=${typesIn('_ContentSliver')} '
          'pluginsBox=${typesIn('_PluginsGlassyBoxSliver')} '
          'chips=${typesIn('_PluginChip')} '
          'text="${tester.widget<TextField>(field).controller?.text}"');
      final chips = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_PluginChip');
      final count = chips.evaluate().length;
      // ignore: avoid_print
      print('PERF plugin chips found: $count');
      for (var round = 0; round < 2; round++) {
        for (var i = 0; i < count; i++) {
          await phase('chip_r${round}_$i', () async {
            await tester.tap(chips.at(i), warnIfMissed: false);
            await wait(5000);
          });
        }
      }
    }, reportKey: 'timeline');

    File('$_outDir/timeline.json')
        .writeAsStringSync(jsonEncode(binding.reportData?['timeline']));
    File('$_outDir/phases.json').writeAsStringSync(jsonEncode(phases));
    // ignore: avoid_print
    print('PERF_PHASES ${jsonEncode(phases)}');
  }, timeout: const Timeout(Duration(minutes: 6)));
}
