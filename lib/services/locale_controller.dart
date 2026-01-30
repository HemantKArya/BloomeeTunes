import 'package:flutter/material.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/translation_service.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale;

  Locale get locale => _locale;

  LocaleController(String initialLanguageCode)
      : _locale = Locale(initialLanguageCode) {
    BloomeeTranslationService().init(initialLanguageCode);
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    await BloomeeTranslationService().init(languageCode);
    await BloomeeDBService.putSettingStr(GlobalStrConsts.languageCode, languageCode);
    notifyListeners();
  }
}
