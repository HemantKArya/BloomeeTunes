import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/l10n/equalizer_labels.dart';
import 'package:Bloomee/l10n/language_options.dart';
import 'package:Bloomee/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:Bloomee/screens/widgets/global_footer.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final template = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final messageKeys =
      template.keys.where((key) => !key.startsWith('@')).toSet();

  for (final locale in AppLocalizations.supportedLocales) {
    test('${locale.toLanguageTag()} has complete, unambiguous translations',
        () {
      final messages = <String, dynamic>{};
      final files = {
        'lib/l10n/app_${locale.languageCode}.arb',
        'lib/l10n/app_$locale.arb',
      };
      for (final file in files) {
        final raw = File(file).readAsStringSync();
        final keys = RegExp(r'^  "([^"\n]+)"\s*:', multiLine: true)
            .allMatches(raw)
            .map((match) => match.group(1)!)
            .toList();
        expect(keys.toSet().length, keys.length,
            reason: '$file contains duplicate keys.');
        messages.addAll(jsonDecode(raw) as Map<String, dynamic>);
      }
      expect(messages.keys.where((key) => !key.startsWith('@')).toSet(),
          messageKeys);
      for (final key in messageKeys) {
        expect((messages[key] as String).trim(), isNotEmpty, reason: key);
        expect(messages[key], isNot(contains(RegExp(r'\?{2,}|\w\?\w|\uFFFD'))),
            reason: '$key contains damaged text encoding.');
        final metadata = template['@$key'] as Map<String, dynamic>?;
        final placeholders = metadata?['placeholders'] as Map<String, dynamic>?;
        for (final name in placeholders?.keys ?? <String>[]) {
          expect(messages[key], matches('\\{$name(?:,|\\})'),
              reason: '$key must preserve $name');
        }
      }
    });

    test('${locale.toLanguageTag()} preserves runtime context', () async {
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.playerLiked('Track title'), contains('Track title'));
      expect(l10n.playerUnliked('Track title'), contains('Track title'));
      expect(l10n.pluginManagerDeleteMessage('Plugin name'),
          contains('Plugin name'));
      expect(l10n.backupImportResult(2, 3, 4, 5),
          allOf(contains('2'), contains('3'), contains('4'), contains('5')));
      expect(l10n.backupNewCopyDetails, isNot(l10n.backupMergeDetails));
      expect(equalizerPresetLabel(l10n, 'Bass Boost'), isNotEmpty);
      expect(equalizerPresetLabel(l10n, 'User preset'), 'User preset');
      for (final count in [0, 1, 2]) {
        expect(l10n.localMusicTrackCount(count), contains('$count'));
        expect(l10n.playlistSongCount(count), contains('$count'));
        expect(l10n.storageDays(count), contains('$count'));
        expect(l10n.albumViewTrackCount(count), contains('$count'));
        expect(l10n.pluginRepositoryPluginsCount(count), contains('$count'));
        expect(l10n.pluginRepositoryAvailableCount(count), contains('$count'));
      }
    });

    testWidgets(
        '${locale.toLanguageTag()} shortcut messages fit and follow locale',
        (tester) async {
      final cubit = ShortcutIndicatorCubit();
      addTearDown(cubit.close);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: ShortcutIndicatorOverlay(child: child!),
          ),
          home: const Scaffold(),
        ),
      ));
      await tester.pumpAndSettle();
      final l10n = await AppLocalizations.delegate.load(locale);
      cubit.showShuffle(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(l10n.shortcutShuffleOn), findsOneWidget);
      expect(tester.takeException(), isNull);
      cubit.showLike(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(l10n.shortcutUnliked), findsOneWidget);
      expect(tester.takeException(), isNull);
      cubit.hide();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('${locale.toLanguageTag()} navigation fits translated labels',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final router = GoRouter(initialLocation: '/tab0', routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: HorizontalNavBar(navigationShell: shell),
            ),
          ),
          branches: List.generate(
              5,
              (index) => StatefulShellBranch(routes: [
                    GoRoute(
                      path: '/tab$index',
                      builder: (context, state) => const SizedBox(),
                    ),
                  ])),
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
      ));
      for (final width in [320.0, 360.0, 450.0]) {
        tester.view.physicalSize = Size(width, 640);
        for (var index = 0; index < 5; index++) {
          router.go('/tab$index');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: 'Tab $index at width $width');
        }
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  test('Portuguese uses one language option, including older saved regions',
      () {
    final options = buildLanguageOptions();
    final byCode = {for (final option in options) option.code: option.label};
    expect(byCode['tr'], 'Türkçe');
    expect(byCode['fr'], 'Français');
    expect(byCode['es'], 'Español');
    expect(byCode['pt'], 'Português');
    expect(byCode.containsKey('pt_BR'), isFalse);
    expect(options.length, 10);
    expect(localeForLanguageCode('pt_BR'), const Locale('pt'));
    expect(localeForLanguageCode('pt-BR'), const Locale('pt'));
    expect(localeForLanguageCode('pt'), const Locale('pt'));
    expect(localeForLanguageCode(''), isNull);
    expect(localeForLanguageCode('tr'), const Locale('tr'));
    expect(localeForLanguageCode('fr'), const Locale('fr'));
  });
}
