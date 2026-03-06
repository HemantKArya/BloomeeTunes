import 'package:equatable/equatable.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';

enum PluginOperation {
  loading,
  unloading,
  installing,
  deleting,
}

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

  /// Per-plugin active operations.
  final Map<String, PluginOperation> pluginOperations;

  /// Most recent error message, if any.
  final String? error;

  /// Most recent success notification, if any.
  final String? successMessage;

  const PluginState({
    this.availablePlugins = const [],
    this.loadedPluginIds = const {},
    this.isInitialized = false,
    this.isLoading = false,
    this.pluginOperations = const {},
    this.error,
    this.successMessage,
  });

  /// Initial state before any operations.
  const PluginState.initial()
      : availablePlugins = const [],
        loadedPluginIds = const {},
        isInitialized = false,
        isLoading = false,
        pluginOperations = const {},
        error = null,
        successMessage = null;

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

  /// Whether any plugin-specific operation is active.
  bool get hasActiveOperations => isLoading || pluginOperations.isNotEmpty;

  /// Return the active operation for [pluginId], if any.
  PluginOperation? operationFor(String pluginId) => pluginOperations[pluginId];

  PluginState copyWith({
    List<PluginInfo>? availablePlugins,
    Set<String>? loadedPluginIds,
    bool? isInitialized,
    bool? isLoading,
    Map<String, PluginOperation>? pluginOperations,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return PluginState(
      availablePlugins: availablePlugins ?? this.availablePlugins,
      loadedPluginIds: loadedPluginIds ?? this.loadedPluginIds,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      pluginOperations: pluginOperations ?? this.pluginOperations,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        availablePlugins,
        loadedPluginIds,
        isInitialized,
        isLoading,
        pluginOperations,
        error,
        successMessage,
      ];
}
