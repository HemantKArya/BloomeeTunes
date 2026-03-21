import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:country_codes/country_codes.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:http/http.dart' as http;

class CountryInfoService {
  static const String defaultCountryCode = 'IN';
  static bool _countryCodesInitialized = false;

  static final List<Uri> _countryLookupUris = [
    Uri.parse('https://ipwho.is/'),
    Uri.parse('https://api.country.is/'),
    Uri.parse('https://ipapi.co/json/'),
    Uri.parse('http://ip-api.com/json'),
  ];

  const CountryInfoService._();

  static String normalizeCountryCode(String? value) {
    final normalized = (value ?? '').trim().toUpperCase().replaceAll(
          RegExp(r'[^A-Z]'),
          '',
        );
    return normalized.length == 2 ? normalized : '';
  }

  static Future<String?> readCachedCountryCode(SettingsDAO settingsDao) async {
    final cached = normalizeCountryCode(
      await settingsDao.getSettingStr(SettingKeys.countryCode),
    );
    return cached.isEmpty ? null : cached;
  }

  static Future<String?> resolveAndCacheCountryCodeFromDeviceLocale({
    required SettingsDAO settingsDao,
  }) async {
    final code = await resolveCountryCodeFromDeviceLocale();
    if (code == null) {
      return null;
    }

    await settingsDao.putSettingStr(SettingKeys.countryCode, code);
    return code;
  }

  static Future<String?> resolveCountryCodeFromDeviceLocale() async {
    try {
      if (!_countryCodesInitialized) {
        await CountryCodes.init();
        _countryCodesInitialized = true;
      }

      final locale = CountryCodes.getDeviceLocale();
      final code = normalizeCountryCode(locale?.countryCode);
      if (code.isEmpty) {
        return null;
      }
      return code;
    } catch (_) {
      return null;
    }
  }

  static Future<String> resolveAndCacheCountryCode({
    required SettingsDAO settingsDao,
    bool forceRefresh = false,
  }) async {
    final cached = await readCachedCountryCode(settingsDao);
    final autoGetCountry =
        await settingsDao.getSettingBool(SettingKeys.autoGetCountry) ?? true;

    if (!forceRefresh && cached != null) {
      return cached;
    }

    if (forceRefresh || autoGetCountry || cached == null) {
      final fetched = await _fetchCountryCode();
      if (fetched != null) {
        await settingsDao.putSettingStr(SettingKeys.countryCode, fetched);
        log('Resolved country code: $fetched', name: 'CountryInfoService');
        return fetched;
      }
    }

    if (cached != null) {
      return cached;
    }

    // Final fallback for first-run cold starts or provider outages.
    // Keep setup non-blocking by persisting a sane default.
    const fallback = defaultCountryCode;
    await settingsDao.putSettingStr(SettingKeys.countryCode, fallback);
    log(
      'Country lookup failed; using fallback country $fallback',
      name: 'CountryInfoService',
    );
    return fallback;
  }

  // Policy resolver for plugin allowlist checks.
  // Uses selected cached country only and never performs network lookup.
  static Future<String> resolveCountryCodeForPolicyCheck({
    required SettingsDAO settingsDao,
    bool forceRefresh = false,
  }) async {
    final cached = await readCachedCountryCode(settingsDao);
    return cached ?? '';
  }

  static Future<String?> _fetchCountryCode() async {
    for (final uri in _countryLookupUris) {
      try {
        final response =
            await http.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) {
          continue;
        }

        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json is! Map) {
          continue;
        }

        final map = Map<String, dynamic>.from(json);
        final countryCode = normalizeCountryCode(
          map['countryCode'] ??
              map['country_code'] ??
              map['country'] ??
              map['countryCode2'],
        );
        if (countryCode.isNotEmpty) {
          return countryCode;
        }
      } catch (_) {}
    }

    return null;
  }
}

Future<String> getCountry() {
  return CountryInfoService.resolveAndCacheCountryCode(
    settingsDao: SettingsDAO(DBProvider.db),
  );
}
