import 'dart:async';
import 'dart:io';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/desktop_tray.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// What the window's close button (and Alt+F4 / Cmd+W) does.
enum DesktopCloseAction {
  /// Hide the window; playback continues and the tray icon reopens it.
  tray,

  /// Minimise to the taskbar / Dock; playback continues.
  minimize,

  /// Quit the app.
  quit;

  /// Linux defaults to minimising: GNOME shows tray icons only with an
  /// extension, and a hidden window there could look like a lost app.
  static DesktopCloseAction get platformDefault =>
      Platform.isLinux ? minimize : tray;

  static DesktopCloseAction parse(String? value) =>
      values.where((v) => v.name == value).firstOrNull ?? platformDefault;
}

/// The native window behind the custom title bar.
///
/// The system title bar is hidden but the native frame stays, so snapping,
/// taskbar minimise/restore, window animations, rounded corners and the
/// system menu keep working. The caption itself is drawn by `WindowFrame`.
abstract final class DesktopWindow {
  static bool get isSupported =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  static const minimumSize = Size(380, 560);

  static bool _frameReady = false;

  /// True once the system title bar is hidden and the app draws its own.
  static bool get isCustomFrame => _frameReady;

  static final closeAction =
      ValueNotifier<DesktopCloseAction>(DesktopCloseAction.platformDefault);

  /// The app's chosen language. Window and tray labels live outside the
  /// app's Localizations, so the app reports it here.
  static Locale? locale;

  static SettingsDAO? _dao;
  static final _listener = _CloseListener();
  static bool _quitting = false;

  /// Hides the system title bar. Runs before the first frame: the Windows
  /// and Linux runners show the window on that frame, and macOS hides its
  /// title bar natively (MainFlutterWindow.swift).
  static Future<void> initialize() async {
    if (!isSupported || _frameReady) return;
    try {
      await windowManager.ensureInitialized();
      if (!Platform.isMacOS) {
        await windowManager.setTitleBarStyle(
          TitleBarStyle.hidden,
          windowButtonVisibility: false,
        );
      }
      await windowManager.setMinimumSize(minimumSize);
      if (Platform.isWindows) {
        // Dark system menu and frame edges to match the app.
        await windowManager.setBrightness(Brightness.dark);
      }
      _frameReady = true;
    } catch (e) {
      // Fall back to the system title bar rather than a window without one.
      debugPrint('Custom window frame unavailable: $e');
      try {
        await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      } catch (_) {}
    }
  }

  /// Takes over the close button and starts the tray. Runs once the
  /// database and player are ready; until then closing simply quits.
  static Future<void> attach() async {
    if (!_frameReady || _dao != null) return;
    _dao = SettingsDAO(DBProvider.db);
    try {
      closeAction.value = DesktopCloseAction.parse(
          await _dao!.getSettingStr(SettingKeys.desktopCloseAction));
    } catch (_) {}
    await DesktopTray.start();
    windowManager.addListener(_listener);
    await windowManager.setPreventClose(true);
  }

  static Future<void> setCloseAction(DesktopCloseAction action) async {
    if (closeAction.value == action) return;
    closeAction.value = action;
    try {
      await _dao?.putSettingStr(SettingKeys.desktopCloseAction, action.name);
    } catch (e) {
      debugPrint('Saving close action failed: $e');
    }
  }

  /// The action actually taken: hiding needs a tray icon to come back from.
  static DesktopCloseAction get effectiveCloseAction =>
      closeAction.value == DesktopCloseAction.tray && !DesktopTray.isAvailable
          ? DesktopCloseAction.minimize
          : closeAction.value;

  static Future<void> _onCloseRequested() async {
    if (_quitting) return;
    switch (effectiveCloseAction) {
      case DesktopCloseAction.tray:
        await hide();
      case DesktopCloseAction.minimize:
        await windowManager.minimize();
      case DesktopCloseAction.quit:
        await quit();
    }
  }

  /// Hides the window. Nothing is drawn while hidden, and decoded images
  /// are released so the app idles on as little memory as possible.
  static Future<void> hide() async {
    await windowManager.hide();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    await DesktopTray.refresh();
  }

  static Future<void> show() async {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
    await DesktopTray.refresh();
  }

  static Future<bool> isShown() async =>
      await windowManager.isVisible() && !await windowManager.isMinimized();

  static Future<void> toggle() async => await isShown() ? hide() : show();

  /// Quits the app, from the close button or the tray menu.
  static Future<void> quit() async {
    if (_quitting) return;
    _quitting = true;
    await DesktopTray.stop();
    windowManager.removeListener(_listener);
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  /// Labels for the caption and tray, in the app's language.
  static AppLocalizations labels() {
    final resolved = locale ??
        basicLocaleListResolution(
            WidgetsBinding.instance.platformDispatcher.locales,
            AppLocalizations.supportedLocales);
    try {
      return lookupAppLocalizations(resolved);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}

class _CloseListener with WindowListener {
  @override
  void onWindowClose() => unawaited(DesktopWindow._onCloseRequested());

  @override
  void onWindowEvent(String eventName) {
    // Keeps the tray's Show/Hide entry right when the system changes it.
    const visibility = {'show', 'hide', 'minimize', 'restore'};
    if (visibility.contains(eventName)) unawaited(DesktopTray.refresh());
  }
}
