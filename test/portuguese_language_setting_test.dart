import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/l10n/language_options.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/country_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings extends Cubit<SettingsState> implements SettingsCubit {
  _Settings(String code)
      : super(
            SettingsInitial().copyWith(languageCode: code, countryCode: 'IN'));

  @override
  void setLanguageCode(String code) => emit(state.copyWith(languageCode: code));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final savedCode in ['pt', 'pt_BR', 'pt-BR']) {
    testWidgets('$savedCode displays Portuguese and permits changing languages',
        (tester) async {
      final settings = _Settings(savedCode);
      addTearDown(settings.close);
      await tester.pumpWidget(BlocProvider<SettingsCubit>.value(
        value: settings,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) => MaterialApp(
            locale: localeForLanguageCode(state.languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CountrySettings(),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final picker = find.byType(SettingDropdownTile<String>).first;
      expect(find.descendant(of: picker, matching: find.text('Português')),
          findsNWidgets(2));
      expect(find.text('Padrão do sistema'), findsNothing);
      expect(find.text('Português (Brasil)'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(picker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(settings.state.languageCode, 'en');
      expect(find.text('Country & Language'), findsOneWidget);

      await tester.tap(find.byType(SettingDropdownTile<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português').last);
      await tester.pumpAndSettle();
      expect(settings.state.languageCode, 'pt');
      expect(find.text('País e idioma'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
