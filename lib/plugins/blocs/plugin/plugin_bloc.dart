import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/plugin_storage_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/services/plugin/plugin_event_bus.dart';
import 'package:Bloomee/services/plugin/plugin_load_state_service.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/events.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';

/// Manages plugin lifecycle: load, unload, install, refresh.
///
/// Reacts to [PluginManagerEvent]s from the Rust plugin system
/// via [PluginEventBus] and updates [PluginState] accordingly.
///
/// This BLoC is the single source of truth for which plugins
/// are available and loaded. Other BLoCs (ContentBloc, ChartBloc)
/// read from [PluginState] to know which plugin to target.
class PluginBloc extends Bloc<PluginEvent, PluginState> {
  final PluginService _pluginService;
  final PluginEventBus _eventBus;
  final PluginLoadStateService _loadStateService;

  StreamSubscription<PluginManagerEvent>? _eventSubscription;

  PluginState _setPluginOperation(
    PluginState current,
    String pluginId,
    PluginOperation operation,
  ) {
    final updated = Map<String, PluginOperation>.from(current.pluginOperations)
      ..[pluginId] = operation;
    return current.copyWith(
      isLoading: true,
      pluginOperations: updated,
      clearSuccessMessage: true,
    );
  }

  PluginState _clearPluginOperation(
    PluginState current,
    String pluginId,
  ) {
    final updated = Map<String, PluginOperation>.from(current.pluginOperations)
      ..remove(pluginId);
    return current.copyWith(
      isLoading: updated.isNotEmpty,
      pluginOperations: updated,
    );
  }

  Future<void> _persistAutoLoadSafe(Set<String> pluginIds) async {
    try {
      await _loadStateService.writeAutoLoadPluginIds(pluginIds);
    } catch (e, stack) {
      log(
        'Failed to persist auto-load plugin IDs',
        error: e,
        stackTrace: stack,
        name: 'PluginBloc',
      );
    }
  }

  PluginBloc({
    required PluginService pluginService,
    required PluginEventBus eventBus,
    PluginLoadStateService? loadStateService,
  })  : _pluginService = pluginService,
        _eventBus = eventBus,
        _loadStateService = loadStateService ??
            PluginLoadStateService(SettingsDAO(DBProvider.db)),
        super(const PluginState.initial()) {
    // Register event handlers.
    on<InitializePluginSystem>(_onInitialize);
    on<LoadPlugin>(_onLoadPlugin);
    on<LoadPluginFromInfo>(_onLoadPluginFromInfo);
    on<UnloadPlugin>(_onUnloadPlugin);
    on<InstallPlugin>(_onInstallPlugin);
    on<DeletePlugin>(_onDeletePlugin);
    on<RefreshPlugins>(_onRefreshPlugins);
    on<PluginSystemEvent>(_onSystemEvent);
    on<AutoLoadPlugins>(_onAutoLoadPlugins);

    // Subscribe to Rust plugin events.
    _eventSubscription = _eventBus.events.listen((event) {
      if (!isClosed) {
        add(PluginSystemEvent(event));
      }
    });
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> _onInitialize(
    InitializePluginSystem event,
    Emitter<PluginState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccessMessage: true,
      ));

      if (!_pluginService.isInitialized) {
        emit(state.copyWith(
          availablePlugins: const [],
          loadedPluginIds: const {},
          isInitialized: true,
          isLoading: false,
          pluginOperations: const {},
          error: 'Plugin system unavailable',
        ));
        return;
      }

      // Fetch available plugins and current loaded state.
      final available = await _pluginService.getAvailablePlugins();
      final loaded = _pluginService.getLoadedPlugins();

      emit(state.copyWith(
        availablePlugins: available,
        loadedPluginIds: loaded.toSet(),
        isInitialized: true,
        isLoading: false,
        pluginOperations: const {},
      ));

      final preferredAutoLoadIds =
          await _loadStateService.readAutoLoadPluginIds();
      final missingAutoLoad = available
          .where((p) => preferredAutoLoadIds.contains(p.manifest.id))
          .where((p) => !loaded.contains(p.manifest.id))
          .map((p) => (pluginId: p.manifest.id, pluginType: p.pluginType))
          .toList(growable: false);

      if (missingAutoLoad.isNotEmpty) {
        add(AutoLoadPlugins(plugins: missingAutoLoad));
      } else {
        await _persistAutoLoadSafe(loaded.toSet());
      }

      log('PluginBloc initialized: ${available.length} available, ${loaded.length} loaded',
          name: 'PluginBloc');
    } catch (e, stack) {
      log('PluginBloc initialization failed',
          error: e, stackTrace: stack, name: 'PluginBloc');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to initialize plugin system: $e',
      ));
    }
  }

  // ── Load Plugin ────────────────────────────────────────────────────────────

  Future<void> _onLoadPlugin(
    LoadPlugin event,
    Emitter<PluginState> emit,
  ) async {
    emit(state.copyWith(
      clearError: true,
      clearSuccessMessage: true,
      pluginOperations: {
        ...state.pluginOperations,
        event.pluginId: PluginOperation.loading,
      },
      isLoading: true,
    ));

    try {
      await _pluginService.loadPlugin(
        pluginId: event.pluginId,
        pluginType: event.pluginType,
      );
      // State update happens via PluginSystemEvent (pluginLoaded).
    } on PluginException catch (e) {
      emit(state.copyWith(
        error: e.message,
        pluginOperations: (Map<String, PluginOperation>.from(
          state.pluginOperations,
        )..remove(event.pluginId)),
        isLoading: state.pluginOperations.length > 1,
      ));
    }
  }

  Future<void> _onLoadPluginFromInfo(
    LoadPluginFromInfo event,
    Emitter<PluginState> emit,
  ) async {
    final info = event.pluginInfo;
    add(LoadPlugin(
      pluginId: info.manifest.id,
      pluginType: info.pluginType,
    ));
  }

  // ── Unload Plugin ──────────────────────────────────────────────────────────

  Future<void> _onUnloadPlugin(
    UnloadPlugin event,
    Emitter<PluginState> emit,
  ) async {
    emit(state.copyWith(
      clearError: true,
      clearSuccessMessage: true,
      pluginOperations: {
        ...state.pluginOperations,
        event.pluginId: PluginOperation.unloading,
      },
      isLoading: true,
    ));

    try {
      await _pluginService.unloadPlugin(
        pluginId: event.pluginId,
        pluginType: event.pluginType,
      );
      // State update happens via PluginSystemEvent (pluginUnloaded).
    } on PluginException catch (e) {
      emit(state.copyWith(
        error: e.message,
        pluginOperations: (Map<String, PluginOperation>.from(
          state.pluginOperations,
        )..remove(event.pluginId)),
        isLoading: state.pluginOperations.length > 1,
      ));
    }
  }

  // ── Install Plugin ─────────────────────────────────────────────────────────

  Future<void> _onInstallPlugin(
    InstallPlugin event,
    Emitter<PluginState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    ));

    try {
      final result = await _pluginService.installPlugin(
        packedFilePath: event.packedFilePath,
        shouldLoad: event.shouldLoad,
      );

      log('Install result: ${result.pluginId} — ${result.status}',
          name: 'PluginBloc');

      final message = switch (result.status) {
        PluginInstallStatus.updated =>
          'Plugin "${result.pluginId}" upgraded to a newer version.',
        PluginInstallStatus.alreadyInstalled =>
          'Plugin "${result.pluginId}" is already on the latest version.',
        PluginInstallStatus.downgraded =>
          'Plugin "${result.pluginId}" installed with an older version.',
        PluginInstallStatus.pluginLoaded =>
          'Plugin "${result.pluginId}" is currently loaded. Unload it before reinstalling.',
        PluginInstallStatus.failed =>
          'Failed to install plugin "${result.pluginId}".',
        PluginInstallStatus.installed =>
          'Plugin "${result.pluginId}" installed successfully.',
      };

      emit(state.copyWith(successMessage: message));

      // Refresh available plugins after install.
      add(const RefreshPlugins());
    } on PluginException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.message,
      ));
    }
  }

  // ── Refresh Available Plugins ──────────────────────────────────────────────

  // ── Delete Plugin ──────────────────────────────────────────────────────────

  Future<void> _onDeletePlugin(
    DeletePlugin event,
    Emitter<PluginState> emit,
  ) async {
    emit(state.copyWith(
      clearError: true,
      clearSuccessMessage: true,
      pluginOperations: {
        ...state.pluginOperations,
        event.pluginId: PluginOperation.deleting,
      },
      isLoading: true,
    ));

    try {
      await _pluginService.deletePlugin(
        pluginId: event.pluginId,
        pluginType: event.pluginType,
      );
      // deletePlugin() fires pluginListRefreshed (not pluginDeleted), so
      // we perform storage cleanup directly here instead of waiting for an
      // event that never arrives.
      if (event.cleanStorage) {
        unawaited(_cleanupPluginStorage(event.pluginId));
      }
      // State update happens via pluginListRefreshed event from Rust.
    } on PluginException catch (e) {
      emit(state.copyWith(
        error: e.message,
        pluginOperations: (Map<String, PluginOperation>.from(
          state.pluginOperations,
        )..remove(event.pluginId)),
        isLoading: state.pluginOperations.length > 1,
      ));
    } catch (e) {
      log('Delete failed for ${event.pluginId}: $e', name: 'PluginBloc');
      emit(state.copyWith(
        error: 'Failed to delete plugin: $e',
        pluginOperations: (Map<String, PluginOperation>.from(
          state.pluginOperations,
        )..remove(event.pluginId)),
        isLoading: state.pluginOperations.length > 1,
      ));
    }
  }

  // ── Refresh Available Plugins ──────────────────────────────────────────────

  Future<void> _onRefreshPlugins(
    RefreshPlugins event,
    Emitter<PluginState> emit,
  ) async {
    try {
      await _pluginService.refreshPlugins();
      final available = await _pluginService.getAvailablePlugins();
      final loaded = _pluginService.getLoadedPlugins();

      emit(state.copyWith(
        availablePlugins: available,
        loadedPluginIds: loaded.toSet(),
        isLoading: false,
        pluginOperations: const {},
      ));
      await _persistAutoLoadSafe(loaded.toSet());
    } catch (e) {
      log('Failed to refresh plugins', error: e, name: 'PluginBloc');
    }
  }

  // ── Auto Load ──────────────────────────────────────────────────────────────

  Future<void> _onAutoLoadPlugins(
    AutoLoadPlugins event,
    Emitter<PluginState> emit,
  ) async {
    for (final plugin in event.plugins) {
      try {
        await _pluginService.loadPlugin(
          pluginId: plugin.pluginId,
          pluginType: plugin.pluginType,
        );
      } catch (e) {
        log('Auto-load failed for ${plugin.pluginId}: $e', name: 'PluginBloc');
      }
    }

    final loaded = _pluginService.getLoadedPlugins().toSet();
    await _persistAutoLoadSafe(loaded);
  }

  // ── System Events (from Rust) ──────────────────────────────────────────────

  Future<void> _onSystemEvent(
    PluginSystemEvent event,
    Emitter<PluginState> emit,
  ) async {
    final e = event.event;
    if (e is! PluginManagerEvent) return;

    e.when(
      pluginLoading: (pluginId) {
        if (state.operationFor(pluginId) == PluginOperation.deleting) {
          emit(state.copyWith(isLoading: true));
          return;
        }
        emit(_setPluginOperation(state, pluginId, PluginOperation.loading));
      },
      pluginLoaded: (pluginId, pluginType) {
        final newLoaded = {...state.loadedPluginIds, pluginId};
        emit(_clearPluginOperation(state, pluginId).copyWith(
          loadedPluginIds: newLoaded,
          clearError: true,
        ));
        unawaited(_persistAutoLoadSafe(newLoaded));
      },
      pluginLoadFailed: (pluginId, error) {
        emit(_clearPluginOperation(state, pluginId).copyWith(
          error: 'Failed to load $pluginId: $error',
        ));
      },
      pluginUnloading: (pluginId) {
        if (state.operationFor(pluginId) == PluginOperation.deleting) {
          emit(state.copyWith(isLoading: true));
          return;
        }
        emit(_setPluginOperation(state, pluginId, PluginOperation.unloading));
      },
      pluginUnloaded: (pluginId) {
        final newLoaded = {...state.loadedPluginIds}..remove(pluginId);
        final deleting =
            state.operationFor(pluginId) == PluginOperation.deleting;
        emit((deleting ? state : _clearPluginOperation(state, pluginId))
            .copyWith(
          loadedPluginIds: newLoaded,
          isLoading:
              deleting || state.pluginOperations.length > (deleting ? 0 : 1),
          clearError: true,
        ));
        unawaited(_persistAutoLoadSafe(newLoaded));
      },
      pluginUnloadFailed: (pluginId, error) {
        emit(_clearPluginOperation(state, pluginId).copyWith(
          error: 'Failed to unload $pluginId: $error',
        ));
      },
      pluginInstalling: (pluginId) {
        emit(_setPluginOperation(state, pluginId, PluginOperation.installing));
      },
      pluginInstalled: (pluginId) {
        emit(_clearPluginOperation(state, pluginId));
      },
      pluginInstallFailed: (pluginId, error) {
        emit(_clearPluginOperation(state, pluginId).copyWith(
          error: 'Install failed for $pluginId: $error',
        ));
      },
      pluginDeleting: (pluginId) {
        emit(_setPluginOperation(state, pluginId, PluginOperation.deleting));
      },
      pluginDeleted: (pluginId) {
        final newLoaded = {...state.loadedPluginIds}..remove(pluginId);
        emit(_clearPluginOperation(state, pluginId).copyWith(
          loadedPluginIds: newLoaded,
          successMessage: 'Plugin "$pluginId" deleted successfully.',
        ));
        unawaited(_persistAutoLoadSafe(newLoaded));
        // Refresh to update available list.
        add(const RefreshPlugins());
      },
      pluginDeleteFailed: (pluginId, error) {
        emit(_clearPluginOperation(state, pluginId).copyWith(
          error: 'Delete failed for $pluginId: $error',
        ));
      },
      pluginListRefreshed: (plugins) {
        // Use the provided list directly — do NOT call RefreshPlugins()
        // which would trigger refreshAvailablePlugins() → emits
        // pluginListRefreshed again → infinite loop.
        final loaded = _pluginService.isInitialized
            ? _pluginService.getLoadedPlugins()
            : <String>[];
        final previousDeletingIds = state.pluginOperations.entries
            .where((entry) => entry.value == PluginOperation.deleting)
            .map((entry) => entry.key)
            .toSet();
        final availableIds =
            plugins.map((plugin) => plugin.manifest.id).toSet();
        final deletedIds = previousDeletingIds.difference(availableIds);
        final updatedOperations = Map<String, PluginOperation>.from(
          state.pluginOperations,
        )..removeWhere(
            (pluginId, operation) =>
                operation == PluginOperation.deleting &&
                !availableIds.contains(pluginId),
          );

        emit(state.copyWith(
          availablePlugins: plugins,
          loadedPluginIds: loaded.toSet(),
          isLoading: updatedOperations.isNotEmpty,
          pluginOperations: updatedOperations,
          successMessage: deletedIds.isNotEmpty
              ? 'Plugin "${deletedIds.first}" deleted successfully.'
              : null,
          clearSuccessMessage: deletedIds.isEmpty,
        ));
        unawaited(_persistAutoLoadSafe(loaded.toSet()));
      },
      storageSet: (_, __, ___) {},
      storageDeleted: (_, __) {},
      storageCleared: (_) {},
      managerInitialized: () {
        emit(state.copyWith(isInitialized: true));
      },
      error: (message) {
        emit(state.copyWith(error: message, clearSuccessMessage: true));
      },
    );
  }

  Future<void> _cleanupPluginStorage(String pluginId) async {
    try {
      final dao = PluginStorageDao(DBProvider.db);
      await dao.clearPlugin(pluginId);
      log('Cleaned storage for deleted plugin: $pluginId', name: 'PluginBloc');
    } catch (e) {
      log('Failed to clean storage for plugin $pluginId: $e',
          name: 'PluginBloc');
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
