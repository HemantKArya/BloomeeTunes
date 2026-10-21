import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class LanguageOption {
  final String code;
  final String label;

  const LanguageOption({required this.code, required this.label});
}

List<LanguageOption> buildLanguageOptions() {
  final seen = <String>{};
  final options = <LanguageOption>[];

  for (final locale in AppLocalizations.supportedLocales) {
    final code = locale.languageCode;
    if (!seen.add(code)) continue;
    options.add(LanguageOption(code: code, label: languageLabelForCode(code)));
  }

  options.sort((a, b) => a.label.compareTo(b.label));
  return options;
}

String languageLabelForCode(String code) {
  switch (code.replaceAll('-', '_').toLowerCase()) {
    case 'en':
      return 'English';
    case 'hi':
      return 'हिन्दी';
    case 'de':
      return 'Deutsch';
    case 'es':
      return 'Español';
    case 'tr':
      return 'Türkçe';
    case 'pt':
    case 'pt_br':
      return 'Português';
    case 'fr':
      return 'Français';
    case 'ja':
      return '日本語';
    case 'ko':
      return '한국어';
    case 'zh':
      return '中文';
    default:
      return code.toUpperCase();
  }
}

/// An empty preference follows the system language. Older Portuguese regional
/// preferences use the same `pt` option as the other supported languages.
Locale? localeForLanguageCode(String code) {
  final normalized = code.trim().replaceAll('-', '_');
  if (normalized.isEmpty) return null;
  final parts = normalized.split('_');
  if (parts.first.toLowerCase() == 'pt') return const Locale('pt');
  return Locale(parts.first.toLowerCase(),
      parts.length > 1 ? parts[1].toUpperCase() : null);
}
