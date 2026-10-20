import 'dart:convert';

import 'package:Bloomee/core/constants/setting_keys.dart';

/// Explicit allowlist: device paths, credentials, plugin storage, queue state,
/// repository URLs and startup flags must never travel in a portable backup.
class BackupSettingsPolicy {
  static const booleanKeys = {
    SettingKeys.autoUpdateNotify,
    SettingKeys.autoSlideCharts,
    SettingKeys.autoPlay,
    SettingKeys.autoResolveUnavailableTracks,
    SettingKeys.eqEnabled,
    SettingKeys.autoGetCountry,
    SettingKeys.autoSaveLyrics,
    SettingKeys.localMusicConfirmDelete,
  };
  static const stringKeys = {
    SettingKeys.strmQuality,
    SettingKeys.crossfadeDuration,
    SettingKeys.eqBandGains,
    SettingKeys.eqPreset,
    SettingKeys.eqSource,
    SettingKeys.downQuality,
    SettingKeys.historyClearTime,
    SettingKeys.languageCode,
    SettingKeys.countryCode,
    SettingKeys.chartShowMap,
  };
  static bool supports(String key) =>
      booleanKeys.contains(key) || stringKeys.contains(key);

  static bool valid(String key, dynamic value) {
    if (booleanKeys.contains(key)) return value is bool;
    if (!stringKeys.contains(key) || value is! String) return false;
    switch (key) {
      case SettingKeys.historyClearTime:
        return ['3', '7', '14', '30', '60', '90', '180', '365'].contains(value);
      case SettingKeys.languageCode:
        return ['', 'en', 'de', 'es', 'hi', 'ja', 'ko', 'zh'].contains(value);
      case SettingKeys.countryCode:
        return RegExp(r'^[A-Za-z]{2}$').hasMatch(value);
      case SettingKeys.eqSource:
        return ['builtin', 'device'].contains(value);
      case SettingKeys.crossfadeDuration:
        final number = int.tryParse(value);
        return number != null && number >= 0 && number <= 12;
      case SettingKeys.eqBandGains:
        try {
          final gains = jsonDecode(value);
          return gains is List &&
              gains.length == 10 &&
              gains.every((v) => v is num && v.isFinite && v >= -15 && v <= 15);
        } catch (_) {
          return false;
        }
      case SettingKeys.chartShowMap:
        try {
          final map = jsonDecode(value);
          return map is Map<String, dynamic> &&
              map.values.every((v) => v is bool);
        } catch (_) {
          return false;
        }
      default:
        return value.length <= 256;
    }
  }
}
