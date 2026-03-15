import 'dart:io' as io;
import 'dart:async';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/routes/app_router.dart';

class KeyboardShortcutsHandler extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutsHandler({
    super.key,
    required this.child,
  });

  @override
  State<KeyboardShortcutsHandler> createState() =>
      _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  Timer? _volumeAdjustTimer;
  LogicalKeyboardKey? _volumeAdjustKey;
  static const Duration _volumeRepeatInterval = Duration(milliseconds: 80);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onGlobalKeyEvent);
  }

  bool _onGlobalKeyEvent(KeyEvent event) {
    if (!mounted) return false;

    if (!io.Platform.isWindows &&
        !io.Platform.isLinux &&
        !io.Platform.isMacOS &&
        !io.Platform.isAndroid) {
      return false;
    }

    if (event is KeyUpEvent) {
      _stopVolumeAdjustForKey(event.logicalKey);
      return false;
    }

    if (event is! KeyDownEvent) return false;
    return _handleKeyEvent(event) == KeyEventResult.handled;
  }

  bool _isTextInputFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;

    final context = primaryFocus.context;
    if (context == null) return false;

    if (context.widget is EditableText) {
      return true;
    }

    final editableText = context.findAncestorWidgetOfExactType<EditableText>();
    return editableText != null;
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    final isTextInput = _isTextInputFocused();
    final key = event.logicalKey;

    if (_handleMediaKey(key)) {
      return KeyEventResult.handled;
    }

    if (isTextInput) {
      return KeyEventResult.ignored;
    }

    final isPlayerVisible = context.read<PlayerOverlayCubit>().state;
    if (!isPlayerVisible) {
      return KeyEventResult.ignored;
    }

    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    if (isAltPressed && !isCtrlPressed && !isShiftPressed) {
      if (_handleAltShortcut(key)) {
        return KeyEventResult.handled;
      }
    }

    if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
      if (_handleSimpleShortcut(key)) {
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  bool _handleMediaKey(LogicalKeyboardKey key) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    if (key == LogicalKeyboardKey.mediaPlayPause) {
      _togglePlayPause(player);
      return true;
    } else if (key == LogicalKeyboardKey.mediaTrackNext) {
      player.skipToNext();
      return true;
    } else if (key == LogicalKeyboardKey.mediaTrackPrevious) {
      player.skipToPrevious();
      return true;
    } else if (key == LogicalKeyboardKey.mediaStop) {
      player.stop();
      return true;
    }

    return false;
  }

  bool _handleAltShortcut(LogicalKeyboardKey key) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    if (key == LogicalKeyboardKey.arrowRight) {
      player.seekNSecForward(const Duration(seconds: 5));
      return true;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      player.seekNSecBackward(const Duration(seconds: 5));
      return true;
    }

    return false;
  }

  bool _handleSimpleShortcut(LogicalKeyboardKey key) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    if (key == LogicalKeyboardKey.space) {
      _togglePlayPause(player);
      return true;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      player.skipToNext();
      return true;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      player.skipToPrevious();
      return true;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      _startVolumeAdjust(key, 0.05, player);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _startVolumeAdjust(key, -0.05, player);
      return true;
    }

    if (key == LogicalKeyboardKey.keyR) {
      final newMode = _cycleLoopMode(player);
      context.read<ShortcutIndicatorCubit>().showLoopMode(newMode);
      return true;
    }

    if (key == LogicalKeyboardKey.keyS) {
      final newShuffleState = !player.shuffleMode.value;
      player.shuffle(newShuffleState);
      context.read<ShortcutIndicatorCubit>().showShuffle(newShuffleState);
      return true;
    }

    if (key == LogicalKeyboardKey.keyM) {
      final (isMuted, volumeLevel) = _toggleMute(player);
      context.read<ShortcutIndicatorCubit>().showMute(isMuted, volumeLevel);
      return true;
    }

    if (key == LogicalKeyboardKey.keyL) {
      _toggleLike(player);
      return true;
    }

    if (key == LogicalKeyboardKey.keyT) {
      final playerOverlayCubit = context.read<PlayerOverlayCubit>();
      if (playerOverlayCubit.state) {
        GlobalRoutes.globalRouterKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const TimerView()),
        );
        return true;
      }
    }

    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      final playerOverlayCubit = context.read<PlayerOverlayCubit>();
      if (playerOverlayCubit.state) {
        if (playerOverlayCubit.collapseUpNextPanel()) {
          return true;
        }
        playerOverlayCubit.hidePlayer();
        return true;
      }
    }

    return false;
  }

  void _startVolumeAdjust(
      LogicalKeyboardKey key, double delta, BloomeeMusicPlayer player) {
    if (_volumeAdjustKey == key && _volumeAdjustTimer != null) return;

    _stopVolumeAdjustForKey(_volumeAdjustKey);

    final newVolume = _changeVolume(player, delta);
    if (mounted) context.read<ShortcutIndicatorCubit>().showVolume(newVolume);

    _volumeAdjustKey = key;
    _volumeAdjustTimer = Timer.periodic(_volumeRepeatInterval, (_) {
      final nv = _changeVolume(player, delta);
      if (mounted) context.read<ShortcutIndicatorCubit>().showVolume(nv);
    });
  }

  void _stopVolumeAdjustForKey(LogicalKeyboardKey? key) {
    if (_volumeAdjustKey == key) {
      _volumeAdjustTimer?.cancel();
      _volumeAdjustTimer = null;
      _volumeAdjustKey = null;
    }
  }

  void _togglePlayPause(BloomeeMusicPlayer player) {
    if (player.engine.playing) {
      player.engine.pause();
    } else {
      player.engine.play();
    }
  }

  double _changeVolume(BloomeeMusicPlayer player, double delta) {
    final currentVolume = player.engine.volume;
    final newVolume = (currentVolume + delta).clamp(0.0, 1.0);
    player.engine.setVolume(newVolume);
    return newVolume;
  }

  double _lastVolumeBeforeMute = 1.0;

  (bool, double) _toggleMute(BloomeeMusicPlayer player) {
    final currentVolume = player.engine.volume;
    if (currentVolume > 0) {
      _lastVolumeBeforeMute = currentVolume;
      player.engine.setVolume(0.0);
      return (true, 0.0);
    } else {
      player.engine.setVolume(_lastVolumeBeforeMute);
      return (false, _lastVolumeBeforeMute);
    }
  }

  LoopMode _cycleLoopMode(BloomeeMusicPlayer player) {
    final currentMode = player.loopMode.value;
    LoopMode nextMode;
    switch (currentMode) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;
      case LoopMode.all:
        nextMode = LoopMode.one;
        break;
      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }
    player.setLoopMode(nextMode);
    return nextMode;
  }

  Future<void> _toggleLike(BloomeeMusicPlayer player) async {
    final currentMedia = player.currentMedia;
    if (isTrackNull(currentMedia)) return;

    final playlistDao = PlaylistDAO(DBProvider.db, TrackDAO(DBProvider.db));
    final isCurrentlyLiked = await playlistDao.isTrackLiked(currentMedia.id);
    final newLikeState = !isCurrentlyLiked;
    await playlistDao.setTrackLiked(currentMedia, newLikeState);
    SnackbarService.showMessage(
        "${currentMedia.title} is ${newLikeState ? 'Liked' : 'Unliked'}!!");

    if (mounted) {
      context.read<ShortcutIndicatorCubit>().showLike(newLikeState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKeyEvent);
    _volumeAdjustTimer?.cancel();
    super.dispose();
  }
}
