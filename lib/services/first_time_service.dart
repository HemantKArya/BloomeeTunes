import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeService {
  static const String _hasSeenWelcomeKey = 'hasSeenWelcome';

  static Future<bool> isFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_hasSeenWelcomeKey) ?? false);
    } catch (e) {
      // If SharedPreferences fails, assume it's first time
      print('SharedPreferences error: $e');
      return true;
    }
  }

  static Future<void> setWelcomeSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenWelcomeKey, true);
    } catch (e) {
      // If SharedPreferences fails, just log the error
      print('SharedPreferences error: $e');
    }
  }

  static Future<String> getInitialRoute() async {
    final isFirst = await isFirstTime();
    return isFirst ? '/welcome' : '/Explore';
  }
}
