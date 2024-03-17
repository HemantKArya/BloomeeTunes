import 'package:Bloomee/services/bloomeePlayer.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() {
    return _instance;
  }
  static late BloomeeMusicPlayer bloomeePlayer;

  PlayerInitializer._internal();

  static bool _isInitialized = false;

  Future<void> _initialize() async {
    bloomeePlayer = await AudioService.init(
      builder: () => BloomeeMusicPlayer(),
      config: const AudioServiceConfig(
          androidStopForegroundOnPause: false,
          androidNotificationChannelId: 'com.BloomeePlayer.notification.status',
          androidNotificationChannelName: 'BloomeTunes',
          androidResumeOnClick: true,
          // androidNotificationIcon: 'assets/icons/Bloomee_logo_fore.png',
          androidShowNotificationBadge: true,
          notificationColor: Default_Theme.accentColor2),
    );
  }

  Future<BloomeeMusicPlayer> getPlayer() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    return bloomeePlayer;
  }
}
