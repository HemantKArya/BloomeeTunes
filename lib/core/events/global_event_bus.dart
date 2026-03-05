/// Global event bus for cross-cutting concerns.
///
/// Plugin errors that should surface as user-visible UI (snackbars, dialogs)
/// are emitted here. The root widget listens and shows appropriate feedback.
///
/// This is NOT for plugin lifecycle events (use [PluginEventBus] for that).
/// This is for app-wide error notifications that any part of the system can emit.
library global_event_bus;

import 'dart:async';
import 'dart:developer';

/// Application-wide error events.
///
/// Pattern-match on these in the root widget to show appropriate UI feedback.
sealed class AppError {
  const AppError();

  /// A stored media ID references a plugin that is not currently loaded.
  const factory AppError.pluginNotLoaded({
    required String pluginId,
    String? mediaId,
  }) = PluginNotLoadedError;

  /// A media ID could not be parsed (missing "::" separator).
  const factory AppError.malformedMediaId({
    required String rawId,
  }) = MalformedMediaIdError;

  /// A network operation failed.
  const factory AppError.networkFailure({
    required String message,
  }) = NetworkFailureError;

  /// A generic plugin error that should be shown to the user.
  const factory AppError.pluginError({
    required String pluginId,
    required String message,
  }) = PluginErrorEvent;
}

class PluginNotLoadedError extends AppError {
  final String pluginId;
  final String? mediaId;

  const PluginNotLoadedError({required this.pluginId, this.mediaId});

  @override
  String toString() =>
      'Plugin "$pluginId" is not loaded${mediaId != null ? ' (mediaId: $mediaId)' : ''}';
}

class MalformedMediaIdError extends AppError {
  final String rawId;

  const MalformedMediaIdError({required this.rawId});

  @override
  String toString() => 'Malformed media ID: "$rawId"';
}

class NetworkFailureError extends AppError {
  final String message;

  const NetworkFailureError({required this.message});

  @override
  String toString() => 'Network failure: $message';
}

class PluginErrorEvent extends AppError {
  final String pluginId;
  final String message;

  const PluginErrorEvent({required this.pluginId, required this.message});

  @override
  String toString() => 'Plugin "$pluginId" error: $message';
}

/// Singleton broadcast bus for application-wide error events.
///
/// Usage:
/// ```dart
/// // Emit an error (from anywhere in the app):
/// GlobalEventBus.instance.emitError(AppError.pluginNotLoaded(pluginId: 'xyz'));
///
/// // Listen (typically in root widget):
/// GlobalEventBus.instance.errors.listen((error) { ... });
/// ```
class GlobalEventBus {
  GlobalEventBus._();

  static final GlobalEventBus instance = GlobalEventBus._();

  final StreamController<AppError> _controller =
      StreamController<AppError>.broadcast();

  /// Stream of application-wide error events.
  Stream<AppError> get errors => _controller.stream;

  /// Emit an error event to all listeners.
  void emitError(AppError error) {
    log('GlobalEventBus: $error', name: 'GlobalEventBus');
    _controller.add(error);
  }

  /// Clean up resources. Call on app shutdown.
  void dispose() {
    _controller.close();
  }
}

/// Utility: ensure a plugin is loaded, or emit a [PluginNotLoadedError].
///
/// Returns `true` if the plugin is loaded, `false` otherwise.
/// When `false`, a [PluginNotLoadedError] is automatically emitted
/// to [GlobalEventBus] so the UI can show a snackbar.
///
/// Usage:
/// ```dart
/// if (!requirePlugin(pluginId, loadedIds)) return;
/// // proceed with command execution...
/// ```
bool requirePlugin(String pluginId, Set<String> loadedPluginIds) {
  if (loadedPluginIds.contains(pluginId)) return true;

  GlobalEventBus.instance.emitError(
    AppError.pluginNotLoaded(pluginId: pluginId),
  );
  return false;
}
