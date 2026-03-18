import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/country_setting.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/onboarding_service.dart';
import 'package:Bloomee/utils/country_info.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingOverlay({super.key, required this.onComplete});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  static const _cardColor = Color(0xFF14101A);
  static const _fieldColor = Color(0xFF1C1624);

  final SettingsDAO _settingsDao = SettingsDAO(DBProvider.db);

  String _selectedLang = '';
  String _selectedCountry = CountryInfoService.defaultCountryCode;
  bool _autoDetectCountry = false;
  bool _isResolvingCountry = false;
  bool _countryTouchedByUser = false;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final lang =
        await _settingsDao.getSettingStr(SettingKeys.languageCode) ?? '';
    final auto =
        await _settingsDao.getSettingBool(SettingKeys.autoGetCountry) ?? false;

    final storedCountryRaw =
        await _settingsDao.getSettingStr(SettingKeys.countryCode);
    final storedCountry =
        CountryInfoService.normalizeCountryCode(storedCountryRaw);

    final country = storedCountry.isEmpty
        ? CountryInfoService.defaultCountryCode
        : storedCountry;

    if (!mounted) return;
    setState(() {
      _selectedLang = lang;
      _selectedCountry = country;
      _autoDetectCountry = auto;
      _currentLocale = lang.isEmpty ? null : Locale(lang);
    });

    // Improve first guess quickly without network delay.
    _updateCountryFromDeviceLocaleIfNeeded(
      shouldGuess: storedCountry.isEmpty,
    );
  }

  Future<void> _updateCountryFromDeviceLocaleIfNeeded({
    required bool shouldGuess,
  }) async {
    if (!shouldGuess) {
      return;
    }

    final guessed =
        await CountryInfoService.resolveCountryCodeFromDeviceLocale();
    if (!mounted || guessed == null || _countryTouchedByUser) {
      return;
    }

    setState(() {
      _selectedCountry = guessed;
    });
    await _settingsDao.putSettingStr(SettingKeys.countryCode, guessed);
  }

  void _updateLang(String? val) {
    if (val == null) return;
    setState(() {
      _selectedLang = val;
      _currentLocale = val.isEmpty ? null : Locale(val);
    });
    _settingsDao.putSettingStr(SettingKeys.languageCode, val);
  }

  void _updateCountry(String? val) {
    if (val == null) return;
    setState(() {
      _countryTouchedByUser = true;
      _selectedCountry = val;
      if (_autoDetectCountry) {
        _autoDetectCountry = false;
        _settingsDao.putSettingBool(SettingKeys.autoGetCountry, false);
      }
    });
    _settingsDao.putSettingStr(SettingKeys.countryCode, val);
  }

  Future<void> _updateAutoDetect(bool val) async {
    setState(() {
      _autoDetectCountry = val;
    });
    await _settingsDao.putSettingBool(SettingKeys.autoGetCountry, val);

    if (val) {
      setState(() => _isResolvingCountry = true);
      final code = await CountryInfoService.resolveAndCacheCountryCode(
        settingsDao: _settingsDao,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _selectedCountry = code;
        _isResolvingCountry = false;
      });
    }
  }

  Future<void> _finish() async {
    await _settingsDao.putSettingBool(
      SettingKeys.autoGetCountry,
      _autoDetectCountry,
    );
    await _settingsDao.putSettingStr(SettingKeys.countryCode, _selectedCountry);
    await _settingsDao.putSettingStr(SettingKeys.languageCode, _selectedLang);
    await OnboardingService.markDone(_settingsDao);
    widget.onComplete();
  }

  List<DropdownMenuItem<String>> _buildLanguageItems(AppLocalizations l10n) {
    final uniqueCodes = <String>{};
    final options = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: '',
        child: Text(l10n.countrySettingSystemDefault),
      ),
    ];

    for (final locale in AppLocalizations.supportedLocales) {
      if (!uniqueCodes.add(locale.languageCode)) continue;
      options.add(
        DropdownMenuItem(
          value: locale.languageCode,
          child: Text(_languageLabel(locale.languageCode)),
        ),
      );
    }

    return options;
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Default_Theme().defaultThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          if (l10n == null) {
            return const Scaffold(backgroundColor: Default_Theme.themeColor);
          }

          final languageItems = _buildLanguageItems(l10n);
          final countryItems = countries.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          final selectedCountry = countries.containsValue(_selectedCountry)
              ? _selectedCountry
              : CountryInfoService.defaultCountryCode;

          final textTheme = Theme.of(context).textTheme;

          return Scaffold(
            backgroundColor: Default_Theme.themeColor,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Default_Theme.themeColor,
                    Default_Theme.themeColor.withValues(alpha: 0.95),
                    const Color(0xFF07040B),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            MingCute.music_2_fill,
                            size: 70,
                            color: Default_Theme.accentColor2,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.onboardingTitle,
                            style: textTheme.headlineMedium?.copyWith(
                              color: Default_Theme.primaryColor1,
                              fontWeight: FontWeight.w800,
                              fontFamily:
                                  Default_Theme.secondoryTextStyle.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.onboardingSubtitle,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.75),
                              fontFamily:
                                  Default_Theme.secondoryTextStyle.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          _FieldLabel(label: l10n.countrySettingLanguageLabel),
                          const SizedBox(height: 10),
                          _DropdownField(
                            value: _selectedLang,
                            items: languageItems,
                            onChanged: _updateLang,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _FieldLabel(
                                  label: l10n.countrySettingAutoDetect,
                                ),
                              ),
                              if (_isResolvingCountry)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Default_Theme.accentColor2,
                                  ),
                                ),
                              if (_isResolvingCountry)
                                const SizedBox(width: 10),
                              _AestheticSwitch(
                                value: _autoDetectCountry,
                                onChanged: _updateAutoDetect,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedOpacity(
                            opacity: _autoDetectCountry ? 0.6 : 1,
                            duration: const Duration(milliseconds: 180),
                            child: IgnorePointer(
                              ignoring: _autoDetectCountry,
                              child: _DropdownField(
                                value: selectedCountry,
                                items: countryItems
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.value,
                                        child: Text('${e.key} (${e.value})'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _updateCountry,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Default_Theme.accentColor2,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l10n.continueButton,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Default_Theme.primaryColor1,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ).merge(Default_Theme.secondoryTextStyle),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _OnboardingOverlayState._fieldColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _OnboardingOverlayState._fieldColor,
          icon: Icon(
            MingCute.down_line,
            color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
          ),
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ).merge(Default_Theme.secondoryTextStyle),
          selectedItemBuilder: (context) {
            return items
                .map(
                  (item) => Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ).merge(Default_Theme.secondoryTextStyle),
                      child: item.child,
                    ),
                  ),
                )
                .toList();
          },
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AestheticSwitch extends StatelessWidget {
  const _AestheticSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value
              ? Default_Theme.accentColor2.withValues(alpha: 0.2)
              : Default_Theme.primaryColor1.withValues(alpha: 0.06),
          border: Border.all(
            color: value
                ? Default_Theme.accentColor2.withValues(alpha: 0.65)
                : Default_Theme.primaryColor1.withValues(alpha: 0.18),
            width: 1.4,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor1.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
