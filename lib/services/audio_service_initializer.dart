import 'package:Bloomee/services/bloomeePlayer.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() {
    return _instance;
  }

  PlayerInitializer._internal();

  static bool _isInitialized = false;
  static BloomeeMusicPlayer? bloomeeMusicPlayer;

  Future<void> _initialize() async {
    bloomeeMusicPlayer = await AudioService.init(
      builder: () => BloomeeMusicPlayer(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.BloomeePlayer.notification.status',
        androidNotificationChannelName: 'BloomeTunes',
        androidResumeOnClick: true,
        // androidNotificationIcon: 'assets/icons/Bloomee_logo_fore.png',
        androidShowNotificationBadge: true,
        notificationColor: Default_Theme.accentColor2,
      ),
    );
  }

  Future<BloomeeMusicPlayer> getBloomeeMusicPlayer() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    return bloomeeMusicPlayer!;
  }
}
