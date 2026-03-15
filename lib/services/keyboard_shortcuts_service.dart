import 'dart:io' as io;
import 'dart:async';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/routes/app_router.dart';

/// A widget that handles global keyboard shortcuts for the application.
/// This wraps the entire app and listens to [HardwareKeyboard] directly,
/// so shortcuts keep working even when focus moves across widgets.
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

    // Only apply shortcuts on desktop platforms.
    if (!io.Platform.isWindows &&
        !io.Platform.isLinux &&
        !io.Platform.isMacOS) {
      return false;
    }

    // Handle key-up events for stopping continuous adjustments
    if (event is KeyUpEvent) {
      _stopVolumeAdjustForKey(event.logicalKey);
      // Let other systems handle key-up as needed (don't claim handled)
      return false;
    }

    // Only handle key-down to perform actions.
    if (event is! KeyDownEvent) return false;

    // Reuse the existing command routing and map the result to bool.
    return _handleKeyEvent(event) == KeyEventResult.handled;
  }

  /// Check if the current focus is on a text input field
  bool _isTextInputFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;

    // Check if the focused widget is within an editable text context
    final context = primaryFocus.context;
    if (context == null) return false;

    if (context.widget is EditableText) {
      return true;
    }

    // Check for EditableText ancestor which indicates text input
    final editableText = context.findAncestorWidgetOfExactType<EditableText>();
    return editableText != null;
  }

  /// Returns true when a non-text UI element currently owns keyboard focus.
  /// In this case, arrow/space should be left to that focused control.
  bool _hasActionableUiFocus() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;

    // Root scope means there is effectively no focused widget.
    if (primaryFocus == WidgetsBinding.instance.focusManager.rootScope) {
      return false;
    }

    // Editable text is handled separately by _isTextInputFocused.
    final context = primaryFocus.context;
    if (context != null && context.widget is EditableText) {
      return false;
    }

    return true;
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    // Don't handle shortcuts when typing in text fields (except for media keys)
    final isTextInput = _isTextInputFocused();
    final key = event.logicalKey;

    // Media keys should always work
    if (_handleMediaKey(key)) {
      return KeyEventResult.handled;
    }

    // Skip other shortcuts if text input is focused
    if (isTextInput) {
      return KeyEventResult.ignored;
    }

    // If any actionable UI element currently holds focus (list item, button,
    // menu, etc.), preserve standard keyboard semantics for that UI first.
    if (_hasActionableUiFocus()) {
      return KeyEventResult.ignored;
    }

    // Global media shortcuts (without player overlay open) to match desktop UX.
    if (_handleGlobalMediaShortcut(key)) {
      return KeyEventResult.handled;
    }

    // Remaining app shortcuts are scoped to player context to avoid interfering
    // with keyboard navigation in non-player screens.
    final isPlayerVisible = context.read<PlayerOverlayCubit>().state;
    if (!isPlayerVisible) {
      return KeyEventResult.ignored;
    }

    // Get modifier states
    final isAltPressed = HardwareKeyboard.instance.isAltPressed;
    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    // Handle shortcuts with modifiers
    if (isAltPressed && !isCtrlPressed && !isShiftPressed) {
      if (_handleAltShortcut(key)) {
        return KeyEventResult.handled;
      }
    }

    // Handle simple key shortcuts (no modifiers)
    if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
      if (_handleSimpleShortcut(key)) {
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Handle global media shortcuts (non-media-key variants).
  /// These are active app-wide, except when typing in text fields.
  bool _handleGlobalMediaShortcut(LogicalKeyboardKey key) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    final player = playerCubit.bloomeePlayer;

    // Space: Play/Pause
    if (key == LogicalKeyboardKey.space) {
      _togglePlayPause(player);
      return true;
    }

    // Track navigation
    if (key == LogicalKeyboardKey.arrowRight) {
      player.skipToNext();
      return true;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      player.skipToPrevious();
      return true;
    }

    // Volume control with held-key repeat
    if (key == LogicalKeyboardKey.arrowUp) {
      _startVolumeAdjust(key, 0.05, player);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _startVolumeAdjust(key, -0.05, player);
      return true;
    }

    return false;
  }

  /// Handle media keys (always work, even in text input)
  bool _handleMediaKey(LogicalKeyboardKey key) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    final player = playerCubit.bloomeePlayer;

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

  /// Handle shortcuts with Alt modifier
  bool _handleAltShortcut(LogicalKeyboardKey key) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    final player = playerCubit.bloomeePlayer;

    if (key == LogicalKeyboardKey.arrowRight) {
      // Alt + Right Arrow: Seek forward 5 seconds
      player.seekNSecForward(const Duration(seconds: 5));
      return true;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      // Alt + Left Arrow: Seek backward 5 seconds
      player.seekNSecBackward(const Duration(seconds: 5));
      return true;
    }

    return false;
  }

  /// Handle simple key shortcuts (no modifiers)
  bool _handleSimpleShortcut(LogicalKeyboardKey key) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    final player = playerCubit.bloomeePlayer;

    // R: Cycle repeat/loop modes
    if (key == LogicalKeyboardKey.keyR) {
      final newMode = _cycleLoopMode(player);
      context.read<ShortcutIndicatorCubit>().showLoopMode(newMode);
      return true;
    }

    // S: Toggle shuffle
    if (key == LogicalKeyboardKey.keyS) {
      final newShuffleState = !player.shuffleMode.value;
      player.shuffle(newShuffleState);
      context.read<ShortcutIndicatorCubit>().showShuffle(newShuffleState);
      return true;
    }

    // M: Mute/Unmute
    if (key == LogicalKeyboardKey.keyM) {
      final (isMuted, volumeLevel) = _toggleMute(player);
      context.read<ShortcutIndicatorCubit>().showMute(isMuted, volumeLevel);
      return true;
    }

    // L: Toggle like on current media
    if (key == LogicalKeyboardKey.keyL) {
      _toggleLike(player);
      return true;
    }

    // T: Open timer (only when player is visible)
    if (key == LogicalKeyboardKey.keyT) {
      final playerOverlayCubit = context.read<PlayerOverlayCubit>();
      if (playerOverlayCubit.state) {
        // Use the global navigator key because this handler lives above
        // the MaterialApp and its BuildContext may not contain a Navigator.
        GlobalRoutes.globalRouterKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const TimerView()),
        );
        return true;
      }
    }

    // Escape or Backspace: Close player overlay if open
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      final playerOverlayCubit = context.read<PlayerOverlayCubit>();
      if (playerOverlayCubit.state) {
        // First try to collapse up-next panel via callback
        if (playerOverlayCubit.collapseUpNextPanel()) {
          return true;
        }
        // Otherwise hide the player
        playerOverlayCubit.hidePlayer();
        return true;
      }
    }

    return false;
  }

  void _startVolumeAdjust(
      LogicalKeyboardKey key, double delta, dynamic player) {
    // If already adjusting for this key, noop
    if (_volumeAdjustKey == key && _volumeAdjustTimer != null) return;

    // Stop any previous adjuster
    _stopVolumeAdjustForKey(_volumeAdjustKey);

    // Apply immediate change
    final newVolume = _changeVolume(player, delta);
    if (mounted) context.read<ShortcutIndicatorCubit>().showVolume(newVolume);

    // Start repeating timer
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

  void _togglePlayPause(dynamic player) {
    if (player.engine.playing) {
      player.engine.pause();
    } else {
      player.engine.play();
    }
  }

  double _changeVolume(dynamic player, double delta) {
    final currentVolume = player.engine.volume;
    final newVolume = (currentVolume + delta).clamp(0.0, 1.0);
    player.engine.setVolume(newVolume);
    return newVolume;
  }

  double _lastVolumeBeforeMute = 1.0;

  /// Returns (isMuted, volumeLevel)
  (bool, double) _toggleMute(dynamic player) {
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

  LoopMode _cycleLoopMode(dynamic player) {
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
      default:
        nextMode = LoopMode.off;
        break;
    }
    player.setLoopMode(nextMode);
    return nextMode;
  }

  Future<void> _toggleLike(dynamic player) async {
    final currentMedia = player.currentMedia;
    if (currentMedia == null || isTrackNull(currentMedia)) return;

    final playlistDao = PlaylistDAO(DBProvider.db, TrackDAO(DBProvider.db));
    final isCurrentlyLiked = await playlistDao.isTrackLiked(currentMedia.id);
    final newLikeState = !isCurrentlyLiked;
    await playlistDao.setTrackLiked(currentMedia, newLikeState);
    SnackbarService.showMessage(
        "${currentMedia.title} is ${newLikeState ? 'Liked' : 'Unliked'}!!");

    // Show the like indicator
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
    // Remove global key handler and cancel any running timers
    HardwareKeyboard.instance.removeHandler(_onGlobalKeyEvent);
    _volumeAdjustTimer?.cancel();
    super.dispose();
  }
}
