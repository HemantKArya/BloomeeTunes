import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/widgets/setting_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/utils/country_list.dart';
import 'package:Bloomee/screens/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Bloomee/services/locale_controller.dart';
import 'package:Bloomee/generated/l10n/app_localizations.dart';

class CountrySettings extends StatelessWidget {
  const CountrySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AutoTranslateText(
          AppLocalizations.of(context)!.countryLangSettings,
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                  value: state.autoGetCountry,
                  subtitle: AutoTranslateText(
                    AppLocalizations.of(context)!.autoCheckCountrySubtitle,
                    style: TextStyle(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                            fontSize: 12.5)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  title: AutoTranslateText(
                    AppLocalizations.of(context)!.autoCheckCountry,
                    style: const TextStyle(
                            color: Default_Theme.primaryColor1, fontSize: 17)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  onChanged: (value) {
                    context.read<SettingsCubit>().setAutoGetCountry(value);
                  }),
              SettingTile(
                title: AppLocalizations.of(context)!.country,
                subtitle: AppLocalizations.of(context)!.countrySubtitle,
                trailing: DropdownButton(
                  value: state.countryCode,
                  isDense: true,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setCountryCode(newValue);
                    }
                  },
                  items: countries.values
                      .toList()
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          countries.keys.elementAt(
                              countries.values.toList().indexOf(value)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                onTap: () {},
              ),
              SettingTile(
                title: AppLocalizations.of(context)!.language,
                subtitle: AppLocalizations.of(context)!.languageSubtitle,
                trailing: DropdownButton<String>(
                  value: state.languageCode,
                  isDense: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<LocaleController>().setLocale(newValue);
                      context.read<SettingsCubit>().setLanguageCode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                    DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                  ],
                ),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}

