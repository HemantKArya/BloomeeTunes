import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

/// Repository for application settings (string and boolean key-value pairs).
///
/// Wraps [SettingsDAO] and provides a clean interface for cubits.
class SettingsRepository {
  final SettingsDAO _settingsDao;

  const SettingsRepository(this._settingsDao);

  // --------------- String settings ---------------

  Future<void> putSettingStr(String key, String value) =>
      _settingsDao.putSettingStr(key, value);

  Future<String?> getSettingStr(String key, {String? defaultValue}) =>
      _settingsDao.getSettingStr(key, defaultValue: defaultValue);

  Future<Stream<AppSettingsStrDB?>?> watchSettingStr(String key) =>
      _settingsDao.getWatcher4SettingStr(key);

  // --------------- Boolean settings ---------------

  Future<void> putSettingBool(String key, bool value) =>
      _settingsDao.putSettingBool(key, value);

  Future<bool?> getSettingBool(String key, {bool? defaultValue}) =>
      _settingsDao.getSettingBool(key, defaultValue: defaultValue);

  Future<Stream<AppSettingsBoolDB?>?> watchSettingBool(String key) =>
      _settingsDao.getWatcher4SettingBool(key);

  // --------------- Audio quality ---------------

  /// Get JioSaavn quality URL based on user's streaming/download quality setting.
  Future<String?> getJsQualityURL(String url, {bool isStreaming = true}) async {
    String settingKey =
        isStreaming ? SettingKeys.strmQuality : SettingKeys.downQuality;
    String? quality = await _settingsDao.getSettingStr(settingKey);
    String? qualityUrl;
    switch (quality) {
      case "96 kbps":
        qualityUrl = url;
      case "160 kbps":
        qualityUrl = url.replaceAll('_96', '_160').replaceAll('_320', '_160');
      case "320 kbps":
        qualityUrl = url.replaceAll('_96', '_320').replaceAll('_160', '_320');
      default:
        qualityUrl = url.replaceAll('_160', '_96').replaceAll('_320', '_96');
    }
    return qualityUrl;
  }
}
