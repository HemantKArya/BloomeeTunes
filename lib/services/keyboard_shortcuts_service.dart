import 'dart:io' as io;
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

/// A widget that handles global keyboard shortcuts for the application.
/// This wraps the entire app and captures keyboard events regardless of focus.
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
  final FocusNode _focusNode =
      FocusNode(debugLabel: 'KeyboardShortcutsHandler');

  @override
  void initState() {
    super.initState();
    // Request focus after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Check if the current focus is on a text input field
  bool _isTextInputFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;

    // Check if the focused widget is within an editable text context
    final context = primaryFocus.context;
    if (context == null) return false;

    // Check for EditableText ancestor which indicates text input
    final editableText = context.findAncestorWidgetOfExactType<EditableText>();
    return editableText != null;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only handle key down events to prevent double-triggering
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Only apply shortcuts on desktop platforms
    if (!io.Platform.isWindows &&
        !io.Platform.isLinux &&
        !io.Platform.isMacOS) {
      return KeyEventResult.ignored;
    }

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

    // Space: Play/Pause
    if (key == LogicalKeyboardKey.space) {
      _togglePlayPause(player);
      return true;
    }

    // Arrow keys for navigation
    if (key == LogicalKeyboardKey.arrowRight) {
      player.skipToNext();
      return true;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      player.skipToPrevious();
      return true;
    }

    // Volume control with Up/Down arrows
    if (key == LogicalKeyboardKey.arrowUp) {
      final newVolume = _changeVolume(player, 0.05);
      context.read<ShortcutIndicatorCubit>().showVolume(newVolume);
      return true;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      final newVolume = _changeVolume(player, -0.05);
      context.read<ShortcutIndicatorCubit>().showVolume(newVolume);
      return true;
    }

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
        Navigator.of(context).push(
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

  void _togglePlayPause(dynamic player) {
    if (player.audioPlayer.playing) {
      player.audioPlayer.pause();
    } else {
      player.audioPlayer.play();
    }
  }

  double _changeVolume(dynamic player, double delta) {
    final currentVolume = player.audioPlayer.volume;
    final newVolume = (currentVolume + delta).clamp(0.0, 1.0);
    player.audioPlayer.setVolume(newVolume);
    return newVolume;
  }

  double _lastVolumeBeforeMute = 1.0;

  /// Returns (isMuted, volumeLevel)
  (bool, double) _toggleMute(dynamic player) {
    final currentVolume = player.audioPlayer.volume;
    if (currentVolume > 0) {
      _lastVolumeBeforeMute = currentVolume;
      player.audioPlayer.setVolume(0.0);
      return (true, 0.0);
    } else {
      player.audioPlayer.setVolume(_lastVolumeBeforeMute);
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
    if (currentMedia == null) return;

    final dbCubit = context.read<BloomeeDBCubit>();
    final isCurrentlyLiked = await dbCubit.isLiked(currentMedia);
    final newLikeState = !isCurrentlyLiked;
    dbCubit.setLike(currentMedia, isLiked: newLikeState);

    // Show the like indicator
    if (mounted) {
      context.read<ShortcutIndicatorCubit>().showLike(newLikeState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      // Allow focus to pass through to children
      canRequestFocus: true,
      skipTraversal: true,
      child: GestureDetector(
        // Capture taps to regain focus when clicking outside text fields
        onTap: () {
          if (!_isTextInputFocused()) {
            _focusNode.requestFocus();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}
