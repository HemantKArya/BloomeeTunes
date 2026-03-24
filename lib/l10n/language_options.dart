import 'package:Bloomee/l10n/app_localizations.dart';

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
  switch (code.toLowerCase()) {
    case 'en':
      return 'English';
    case 'hi':
      return 'हिन्दी';
    case 'de':
      return 'Deutsch';
    case 'es':
      return 'Español';
    case 'ja':
      return '日本語';
    case 'ko':
      return '한국어';
    case 'zh':
      return '中文';
    case 'ru':
      return 'Русский';
    default:
      return code.toUpperCase();
  }
}
