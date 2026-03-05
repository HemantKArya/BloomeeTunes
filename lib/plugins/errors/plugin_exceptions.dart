/// Plugin exception hierarchy.
///
/// All plugin-related errors are typed exceptions extending [PluginException].
/// Service layer catches raw errors and wraps them in the appropriate subclass.
/// BLoC layer pattern-matches on these for error state emission.
library plugin_exceptions;

/// Base class for all plugin-related exceptions.
sealed class PluginException implements Exception {
  /// The plugin ID involved, if known.
  final String? pluginId;

  /// Human-readable error message.
  final String message;

  /// Optional underlying error.
  final Object? cause;

  const PluginException({
    this.pluginId,
    required this.message,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (pluginId != null) buffer.write(' [plugin: $pluginId]');
    if (cause != null) buffer.write(' (cause: $cause)');
    return buffer.toString();
  }
}

/// Thrown when attempting to execute a command on a plugin that is not loaded.
class PluginNotLoadedException extends PluginException {
  const PluginNotLoadedException({
    required String pluginId,
    String message = 'Plugin is not loaded',
  }) : super(pluginId: pluginId, message: message);
}

/// Thrown when a plugin command execution fails.
///
/// The [errorCode] may contain structured error info from Rust
/// (format: `"PLUGIN_ERROR::{ErrorVariant}::{message}"`).
class PluginExecutionException extends PluginException {
  /// Raw error string from Rust bridge.
  final String? errorCode;

  const PluginExecutionException({
    String? pluginId,
    required String message,
    this.errorCode,
    Object? cause,
  }) : super(pluginId: pluginId, message: message, cause: cause);
}

/// Thrown when plugin installation fails.
class PluginInstallException extends PluginException {
  const PluginInstallException({
    String? pluginId,
    required String message,
    Object? cause,
  }) : super(pluginId: pluginId, message: message, cause: cause);
}

/// Thrown when a plugin cannot be found (not available in plugin directory).
class PluginNotFoundException extends PluginException {
  const PluginNotFoundException({
    required String pluginId,
    String message = 'Plugin not found',
  }) : super(pluginId: pluginId, message: message);
}

/// Thrown when a media ID cannot be parsed (missing "::" separator).
class MalformedMediaIdException extends PluginException {
  /// The raw ID that failed to parse.
  final String rawId;

  const MalformedMediaIdException({
    required this.rawId,
    String message = 'Malformed media ID',
  }) : super(message: message);
}
