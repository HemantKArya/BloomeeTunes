import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/country_list.dart';
import 'package:Bloomee/screens/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:Bloomee/services/locale_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String selectedCountry = 'United States';
  String selectedCountryCode = 'US';
  String selectedLanguage = 'English';
  String selectedLanguageCode = 'en';

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'हिन्दी (Hindi)', 'code': 'hi'},
    {'name': 'Español (Spanish)', 'code': 'es'},
    {'name': 'Français (French)', 'code': 'fr'},
    {'name': 'Deutsch (German)', 'code': 'de'},
    {'name': '日本語 (Japanese)', 'code': 'ja'},
    {'name': 'Русский (Russian)', 'code': 'ru'},
  ];

  @override
  void initState() {
    super.initState();
    _detectSystemSettings();
  }

  void _detectSystemSettings() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final String? sysLanguageCode = systemLocale.languageCode;
    final String? sysCountryCode = systemLocale.countryCode;

    // Detect Language
    if (sysLanguageCode != null) {
      final detectedLang = languages.firstWhere(
        (e) => e['code'] == sysLanguageCode,
        orElse: () => languages[0],
      );
      selectedLanguage = detectedLang['name']!;
      selectedLanguageCode = detectedLang['code']!;
      
      // Update the app language instantly to match system if supported
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LocaleController>().setLocale(selectedLanguageCode);
      });
    }

    // Detect Country
    if (sysCountryCode != null) {
      String? countryName;
      countries.forEach((key, value) {
        if (value == sysCountryCode) {
          countryName = key;
        }
      });

      if (countryName != null) {
        selectedCountry = countryName!;
        selectedCountryCode = sysCountryCode;
      }
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Default_Theme.themeColor,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/icons/BloomeeLogoFG.png',
                  height: 120,
                ),
                const SizedBox(height: 30),
                AutoTranslateText(
                  AppLocalizations.of(context)!.onboardingWelcome,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Default_Theme.primaryColor1,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
                const SizedBox(height: 10),
                AutoTranslateText(
                  AppLocalizations.of(context)!.confirmSettings,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                const Spacer(),
                _buildDropdown(
                  label: AppLocalizations.of(context)!.country,
                  icon: Icons.public,
                  value: selectedCountry,
                  isDetected: selectedCountryCode == WidgetsBinding.instance.platformDispatcher.locale.countryCode,
                  items: countries.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCountry = val!;
                      selectedCountryCode = countries[val]!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: AppLocalizations.of(context)!.language,
                  icon: Icons.language,
                  value: selectedLanguage,
                  isDetected: selectedLanguageCode == WidgetsBinding.instance.platformDispatcher.locale.languageCode,
                  items: languages.map((e) => e['name']!).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedLanguage = val!;
                      selectedLanguageCode = languages
                          .firstWhere((e) => e['name'] == val)['code']!;
                      context
                          .read<LocaleController>()
                          .setLocale(selectedLanguageCode);
                      // Instantly update app language for preview
                      context
                          .read<SettingsCubit>()
                          .setLanguageCode(selectedLanguageCode);
                    });
                  },
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      final settingsCubit = context.read<SettingsCubit>();
                      settingsCubit.setCountryCode(selectedCountryCode);
                      settingsCubit.setLanguageCode(selectedLanguageCode);
                      settingsCubit.setIsFirstLaunch(false);
                      context.go('/Explore');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Default_Theme.accentColor2,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: AutoTranslateText(
                      AppLocalizations.of(context)!.getStarted,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required bool isDetected,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Row(
            children: [
              AutoTranslateText(
                label,
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isDetected) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.detectedLabel,
                    style: const TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Default_Theme.themeColor,
              icon: const Icon(Icons.arrow_drop_down,
                  color: Default_Theme.primaryColor1),
              style: const TextStyle(color: Default_Theme.primaryColor1),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
