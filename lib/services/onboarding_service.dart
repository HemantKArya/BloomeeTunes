import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

class OnboardingService {
  static bool _onboardingDone = false;

  static bool get onboardingDone => _onboardingDone;

  static Future<void> checkAndCacheDone(SettingsDAO settingsDao) async {
    _onboardingDone =
        await settingsDao.getSettingBool(SettingKeys.appSetupCompleted) ??
            false;
  }

  static Future<void> markDone(SettingsDAO settingsDao) async {
    await settingsDao.putSettingBool(SettingKeys.appSetupCompleted, true);
    _onboardingDone = true;
  }
}
