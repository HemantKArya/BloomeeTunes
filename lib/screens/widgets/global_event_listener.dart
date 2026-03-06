import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/blocs/global_events/global_events_cubit.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/screens/screen/common_views/changelog_reader.dart';
import 'package:Bloomee/screens/widgets/gradient_alert_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/plugin/plugin_event_bus.dart';
import 'package:Bloomee/src/rust/api/plugin/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openURL(String url) async {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class GlobalEventListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const GlobalEventListener(
      {super.key, required this.child, required this.navigatorKey});

  @override
  State<GlobalEventListener> createState() => _GlobalEventListenerState();
}

class _GlobalEventListenerState extends State<GlobalEventListener> {
  StreamSubscription<PluginManagerEvent>? _pluginSub;
  StreamSubscription<AppError>? _appErrorSub;

  /// Rate-limit snackbars: track last message + timestamp to avoid flooding.
  String? _lastSnackbarMessage;
  DateTime _lastSnackbarTime = DateTime(2000);
  static const _snackbarCooldown = Duration(seconds: 2);

  /// Show a snackbar only if it's not a duplicate within the cooldown window.
  void _throttledSnackbar(String message) {
    final now = DateTime.now();
    if (message == _lastSnackbarMessage &&
        now.difference(_lastSnackbarTime) < _snackbarCooldown) {
      return; // suppress duplicate within cooldown
    }
    _lastSnackbarMessage = message;
    _lastSnackbarTime = now;
    SnackbarService.showMessage(message);
  }

  @override
  void initState() {
    super.initState();
    _pluginSub = PluginEventBus.instance.events.listen(_onPluginEvent);
    _appErrorSub = GlobalEventBus.instance.errors.listen(_onAppError);
  }

  @override
  void dispose() {
    _pluginSub?.cancel();
    _appErrorSub?.cancel();
    super.dispose();
  }

  void _onAppError(AppError error) {
    log('App error: $error', name: 'GlobalEventListener');
    switch (error) {
      case PluginNotLoadedError(:final pluginId):
        _throttledSnackbar('Plugin "$pluginId" is not loaded.');
      case MalformedMediaIdError(:final rawId):
        _throttledSnackbar('Malformed media ID: $rawId');
      case PluginErrorEvent(:final message):
        _throttledSnackbar(message);
      case NetworkFailureError(:final message):
        _throttledSnackbar(message);
    }
  }

  void _onPluginEvent(PluginManagerEvent event) {
    switch (event) {
      case PluginManagerEvent_PluginLoadFailed(:final id, :final error):
        log('Plugin load failed: $id — $error', name: 'GlobalEventListener');
        _throttledSnackbar('Plugin "$id" failed to load: $error');
      case PluginManagerEvent_PluginUnloadFailed(:final id, :final error):
        log('Plugin unload failed: $id — $error', name: 'GlobalEventListener');
        _throttledSnackbar('Plugin "$id" failed to unload: $error');
      case PluginManagerEvent_PluginInstallFailed(:final id, :final error):
        log('Plugin install failed: $id — $error', name: 'GlobalEventListener');
        _throttledSnackbar('Plugin "$id" install failed: $error');
      case PluginManagerEvent_PluginDeleteFailed(:final id, :final error):
        log('Plugin delete failed: $id — $error', name: 'GlobalEventListener');
        _throttledSnackbar('Plugin "$id" delete failed: $error');
      case PluginManagerEvent_Error(:final message):
        log('Plugin system error: $message', name: 'GlobalEventListener');
        _throttledSnackbar('Plugin error: $message');
      case PluginManagerEvent_PluginInstalled(:final id):
        _throttledSnackbar('Plugin "$id" installed successfully');
      case PluginManagerEvent_PluginLoaded(:final id):
        _throttledSnackbar('Plugin "$id" loaded');
      case PluginManagerEvent_PluginDeleted(:final id):
        _throttledSnackbar('Plugin "$id" deleted successfully');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalEventsCubit, GlobalEventsState>(
      listener: (context, state) {
        final dialogContext = widget.navigatorKey.currentContext ?? context;
        switch (state.runtimeType) {
          case UpdateAvailable:
            final s = state as UpdateAvailable;
            log("Update Available: ${s.message}");
            showDialog(
              context: dialogContext,
              builder: (context) {
                return GradientDialog(
                  "Update Available",
                  content: s.message,
                  presetIndex: 0,
                  actions: [
                    GradientDialogAction('Later',
                        onPressed: () {}, isText: true),
                    GradientDialogAction('Update Now', onPressed: () {
                      openURL(s.downloadUrl);
                    }),
                  ],
                );
              },
            );
            break;
          case AlertDialogState:
            final s = state as AlertDialogState;
            showDialog(
              context: dialogContext,
              builder: (context) {
                return GradientDialog(
                  s.title,
                  content: s.content,
                  presetIndex: 0,
                  actions: [
                    GradientDialogAction('OK', onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                );
              },
            );
            break;
          case WhatIsNewState:
            final s = state as WhatIsNewState;
            Navigator.of(dialogContext).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChangelogScreen(
                  changelogText: s.changeLogs,
                  showOlderVersions: false,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                          begin: const Offset(0.0, 1.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
            break;
          default:
            break;
        }
      },
      child: widget.child,
    );
  }
}
