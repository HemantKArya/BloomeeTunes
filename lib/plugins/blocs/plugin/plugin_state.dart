import 'package:equatable/equatable.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';

/// State for [PluginBloc].
///
/// Tracks available plugins, loaded plugin IDs, installation state,
/// and the most recent error.
class PluginState extends Equatable {
  /// All plugins found in the plugins directory.
  final List<PluginInfo> availablePlugins;

  /// IDs of currently loaded plugins.
  final Set<String> loadedPluginIds;

  /// Whether the plugin system is initialized.
  final bool isInitialized;

  /// Whether a plugin operation is in progress.
  final bool isLoading;

  /// ID of the plugin currently being operated on (load/unload/install).
  final String? operatingPluginId;

  /// Most recent error message, if any.
  final String? error;

  const PluginState({
    this.availablePlugins = const [],
    this.loadedPluginIds = const {},
    this.isInitialized = false,
    this.isLoading = false,
    this.operatingPluginId,
    this.error,
  });

  /// Initial state before any operations.
  const PluginState.initial()
      : availablePlugins = const [],
        loadedPluginIds = const {},
        isInitialized = false,
        isLoading = false,
        operatingPluginId = null,
        error = null;

  /// Get loaded content resolver plugins.
  List<PluginInfo> get loadedContentResolvers => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.contentResolver &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  /// Get loaded chart provider plugins.
  List<PluginInfo> get loadedChartProviders => availablePlugins
      .where((p) =>
          p.pluginType == PluginType.chartProvider &&
          loadedPluginIds.contains(p.manifest.id))
      .toList();

  /// Check if a specific plugin is loaded.
  bool isPluginLoaded(String pluginId) => loadedPluginIds.contains(pluginId);

  PluginState copyWith({
    List<PluginInfo>? availablePlugins,
    Set<String>? loadedPluginIds,
    bool? isInitialized,
    bool? isLoading,
    String? operatingPluginId,
    String? error,
    bool clearError = false,
    bool clearOperatingPlugin = false,
  }) {
    return PluginState(
      availablePlugins: availablePlugins ?? this.availablePlugins,
      loadedPluginIds: loadedPluginIds ?? this.loadedPluginIds,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      operatingPluginId: clearOperatingPlugin
          ? null
          : (operatingPluginId ?? this.operatingPluginId),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        availablePlugins,
        loadedPluginIds,
        isInitialized,
        isLoading,
        operatingPluginId,
        error,
      ];
}
