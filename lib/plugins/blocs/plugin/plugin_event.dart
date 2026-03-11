import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';

/// Events for [PluginBloc].
sealed class PluginEvent {
  const PluginEvent();
}

/// Load a plugin by ID and type.
class LoadPlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;
  const LoadPlugin({required this.pluginId, required this.pluginType});
}

/// Unload a plugin by ID and type.
class UnloadPlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;
  const UnloadPlugin({required this.pluginId, required this.pluginType});
}

/// Install a packed plugin (.bex file).
class InstallPlugin extends PluginEvent {
  final String packedFilePath;
  final bool shouldLoad;
  const InstallPlugin({required this.packedFilePath, this.shouldLoad = true});
}

/// Refresh the list of available plugins.
class RefreshPlugins extends PluginEvent {
  const RefreshPlugins();
}

/// Internal: forward a Rust [PluginManagerEvent] into the BLoC.
class PluginSystemEvent extends PluginEvent {
  final dynamic event;
  const PluginSystemEvent(this.event);
}

/// Initialize the plugin system (called once at startup).
class InitializePluginSystem extends PluginEvent {
  const InitializePluginSystem();
}

/// Auto-load previously loaded plugins from saved preferences.
class AutoLoadPlugins extends PluginEvent {
  final List<({String pluginId, PluginType pluginType})> plugins;
  const AutoLoadPlugins({required this.plugins});
}

/// Load a plugin from a [PluginInfo] object.
class LoadPluginFromInfo extends PluginEvent {
  final PluginInfo pluginInfo;
  const LoadPluginFromInfo({required this.pluginInfo});
}

/// Delete (uninstall) a plugin by removing its directory.
class DeletePlugin extends PluginEvent {
  final String pluginId;
  final PluginType pluginType;

  /// Whether to also remove saved storage keys (API keys, etc.) for this plugin.
  final bool cleanStorage;
  const DeletePlugin({
    required this.pluginId,
    required this.pluginType,
    this.cleanStorage = true,
  });
}
