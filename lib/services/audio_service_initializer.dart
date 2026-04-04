import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';

class PlayerInitializer {
  static final PlayerInitializer _instance = PlayerInitializer._internal();
  factory PlayerInitializer() => _instance;
  PlayerInitializer._internal();

  BloomeeMusicPlayer? _bloomeeMusicPlayer;
  bool _isInitializing = false;

  Future<BloomeeMusicPlayer> getBloomeeMusicPlayer() async {
    // Return immediately if already healthy
    if (_bloomeeMusicPlayer != null) {
      if (!_bloomeeMusicPlayer!.isPlayerHealthy) {
        await _bloomeeMusicPlayer!.revive();
      }
      return _bloomeeMusicPlayer!;
    }

    // Prevent race conditions if multiple UI components request the player simultaneously
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_bloomeeMusicPlayer == null) {
      _isInitializing = true;
      try {
        _bloomeeMusicPlayer = await AudioService.init(
          builder: () => BloomeeMusicPlayer(),
          config: const AudioServiceConfig(
            androidNotificationChannelId:
                'com.BloomeePlayer.notification.status',
            androidNotificationChannelName: 'BloomeTunes',
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidResumeOnClick: true,
            androidShowNotificationBadge: true,
            // Keep foreground priority while paused to reduce OS kills.
            androidStopForegroundOnPause: false,
            notificationColor: Default_Theme.accentColor2,
          ),
        );

        // // Brief delay on Android for native side to stabilize
        // if (Platform.isAndroid) {
        //   await Future.delayed(const Duration(milliseconds: 200));
        // }
      } finally {
        _isInitializing = false;
      }
    }

    return _bloomeeMusicPlayer!;
  }
}
