import 'dart:async';
import 'dart:io';

import 'package:Bloomee/services/audio_service_initializer.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/services/desktop_window.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

/// The tray (Windows, Linux) or menu bar (macOS) icon.
///
/// Left click brings the window back (Windows; Linux indicators and macOS
/// open the menu instead). The menu mirrors what is playing and offers
/// transport controls, so the app can be used while hidden.
abstract final class DesktopTray {
  static const _iconWindows = 'assets/tray/tray_icon.ico';
  static const _iconOther = 'assets/tray/tray_icon.png';

  static bool _available = false;

  /// False when the platform has no usable tray; hiding to it is then
  /// replaced by minimising.
  static bool get isAvailable => _available;

  static final _listener = _TrayListener();
  static BloomeeMusicPlayer? _player;
  static final _subscriptions = <StreamSubscription<dynamic>>[];

  /// What the menu currently shows; it is rebuilt only when this changes.
  static String? _shownKey;

  static Future<void> start() async {
    if (_available) return;
    try {
      await trayManager.setIcon(
        Platform.isWindows ? _iconWindows : _iconOther,
        iconSize: 18,
      );
      _available = true;
    } catch (e) {
      debugPrint('Tray unavailable: $e');
      return;
    }
    trayManager.addListener(_listener);
    try {
      final player = await PlayerInitializer().getBloomeeMusicPlayer();
      _player = player;
      _subscriptions
        ..add(player.mediaItem.listen((_) => refresh()))
        ..add(player.playbackState
            .map((s) => s.playing)
            .distinct()
            .listen((_) => refresh()));
    } catch (e) {
      debugPrint('Tray player controls unavailable: $e');
    }
    await refresh();
  }

  static Future<void> stop() async {
    if (!_available) return;
    _available = false;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    trayManager.removeListener(_listener);
    _shownKey = null;
    try {
      await trayManager.destroy();
    } catch (_) {}
  }

  /// Rebuilds the menu and tooltip if the track, play state, window
  /// visibility or language changed.
  static Future<void> refresh() async {
    if (!_available) return;
    final l10n = DesktopWindow.labels();
    final item = _player?.mediaItem.valueOrNull;
    final playing = _player?.playbackState.valueOrNull?.playing ?? false;
    final shown = await DesktopWindow.isShown();
    final nowPlaying = _describe(item);

    final key = [nowPlaying, playing, shown, l10n.localeName].join('|');
    if (key == _shownKey || !_available) return;
    _shownKey = key;

    final hasTrack = item != null;
    final menu = Menu(items: [
      MenuItem(
        key: 'now_playing',
        label: nowPlaying ?? l10n.trayNothingPlaying,
        disabled: true,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'play_pause',
        label: playing ? l10n.trayPause : l10n.trayPlay,
        disabled: !hasTrack,
      ),
      MenuItem(key: 'next', label: l10n.trayNext, disabled: !hasTrack),
      MenuItem(key: 'previous', label: l10n.trayPrevious, disabled: !hasTrack),
      MenuItem.separator(),
      MenuItem(
        key: 'toggle_window',
        label: shown ? l10n.trayHideWindow : l10n.trayShowWindow,
      ),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: l10n.trayQuit),
    ]);

    try {
      await trayManager.setContextMenu(menu);
      if (!Platform.isLinux) {
        // Windows limits tooltips to 127 characters.
        final tip = nowPlaying == null ? 'Bloomee' : 'Bloomee\n$nowPlaying';
        await trayManager
            .setToolTip(tip.length > 127 ? '${tip.substring(0, 126)}…' : tip);
      }
    } catch (e) {
      debugPrint('Tray update failed: $e');
    }
  }

  static String? _describe(MediaItem? item) {
    if (item == null) return null;
    final title = item.title.trim();
    final artist = item.artist?.trim() ?? '';
    final text = artist.isEmpty ? title : '$title — $artist';
    // Menu labels are a single line; keep them a readable width.
    return text.length > 60 ? '${text.substring(0, 59)}…' : text;
  }

  static Future<void> _onMenuItem(String? key) async {
    final player = _player;
    switch (key) {
      case 'play_pause':
        if (player == null) return;
        player.playbackState.valueOrNull?.playing ?? false
            ? await player.pause()
            : await player.play();
      case 'next':
        await player?.skipToNext();
      case 'previous':
        await player?.skipToPrevious();
      case 'toggle_window':
        await DesktopWindow.toggle();
      case 'quit':
        await DesktopWindow.quit();
    }
  }
}

class _TrayListener with TrayListener {
  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      unawaited(DesktopWindow.show());
    } else {
      unawaited(trayManager.popUpContextMenu());
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    // Foreground first, or Windows leaves the menu open after clicking away.
    unawaited(trayManager.popUpContextMenu(
      // ignore: deprecated_member_use
      bringAppToFront: Platform.isWindows,
    ));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) =>
      unawaited(DesktopTray._onMenuItem(menuItem.key));
}
