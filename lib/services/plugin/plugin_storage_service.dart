import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/db/dao/plugin_storage_dao.dart';
import 'package:Bloomee/services/plugin/plugin_event_bus.dart';
import 'package:Bloomee/src/rust/api/plugin/events.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin.dart';
import 'package:Bloomee/src/rust/api/bridge.dart' as bridge;

/// Handles plugin storage persistence.
///
/// Two-layer architecture:
///   Layer 1 (Rust): In-memory HashMap — instant sync reads for WASM plugins.
///   Layer 2 (Dart): Isar DB — async persistence for app restarts.
///
/// This service:
///   - On startup: preloads all Isar entries into Rust in-memory storage.
///   - Listens to [PluginEventBus] for `StorageSet`, `StorageDeleted`,
///     `StorageCleared` events and persists changes to Isar asynchronously.
///   - Never blocks the plugin; Isar writes happen in the background.
class PluginStorageService {
  final PluginStorageDao _dao;
  final PluginEventBus _eventBus;

  StreamSubscription<PluginManagerEvent>? _eventSubscription;
  Future<void> _writeChain = Future<void>.value();

  PluginStorageService({
    required PluginStorageDao dao,
    required PluginEventBus eventBus,
  })  : _dao = dao,
        _eventBus = eventBus;

  /// Preload all stored entries from Isar into Rust in-memory storage.
  ///
  /// Call this during app startup AFTER [PluginManager] is created but
  /// BEFORE any plugins are loaded. This ensures plugins see their
  /// persisted state immediately.
  Future<void> preloadAll(PluginManager manager) async {
    final entries = await _dao.getAll();
    log('Preloading ${entries.length} storage entries into Rust',
        name: 'PluginStorageService');

    for (final entry in entries) {
      await bridge.pluginStoragePreload(
        manager: manager,
        pluginId: entry.pluginId,
        key: entry.key,
        value: entry.value,
      );
    }

    log('Preload complete', name: 'PluginStorageService');
  }

  /// Start listening to storage events from the plugin event bus.
  ///
  /// Each storage mutation event from Rust is persisted to Isar asynchronously.
  /// This is fire-and-forget — we don't block the event stream on DB writes.
  void startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventBus.events.listen(_handleEvent);
    log('PluginStorageService listening for storage events',
        name: 'PluginStorageService');
  }

  void _handleEvent(PluginManagerEvent event) {
    event.when(
      storageSet: (pluginId, key, value) {
        _enqueueWrite(() => _persistSet(pluginId, key, value));
      },
      storageDeleted: (pluginId, key) {
        _enqueueWrite(() => _persistDelete(pluginId, key));
      },
      storageCleared: (pluginId) {
        _enqueueWrite(() => _persistClear(pluginId));
      },
      // All other events are not our concern.
      pluginLoading: (_) {},
      pluginLoaded: (_, __) {},
      pluginLoadFailed: (_, __) {},
      pluginUnloading: (_) {},
      pluginUnloaded: (_) {},
      pluginUnloadFailed: (_, __) {},
      pluginInstalling: (_) {},
      pluginInstalled: (_) {},
      pluginInstallFailed: (_, __) {},
      pluginDeleting: (_) {},
      pluginDeleted: (_) {},
      pluginDeleteFailed: (_, __) {},
      pluginListRefreshed: (_) {},
      managerInitialized: () {},
      error: (_) {},
    );
  }

  void _enqueueWrite(Future<void> Function() op) {
    _writeChain = _writeChain.catchError((_) {}).then((_) => op());
  }

  Future<void> _persistSet(String pluginId, String key, String value) async {
    try {
      await _dao.putEntry(pluginId: pluginId, key: key, value: value);
    } catch (e, stack) {
      log('Failed to persist storage set: $pluginId/$key',
          name: 'PluginStorageService', error: e, stackTrace: stack);
    }
  }

  Future<void> _persistDelete(String pluginId, String key) async {
    try {
      await _dao.deleteEntry(pluginId: pluginId, key: key);
    } catch (e, stack) {
      log('Failed to persist storage delete: $pluginId/$key',
          name: 'PluginStorageService', error: e, stackTrace: stack);
    }
  }

  Future<void> _persistClear(String pluginId) async {
    try {
      await _dao.clearPlugin(pluginId);
    } catch (e, stack) {
      log('Failed to persist storage clear: $pluginId',
          name: 'PluginStorageService', error: e, stackTrace: stack);
    }
  }

  /// Stop listening and clean up.
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    log('PluginStorageService disposed', name: 'PluginStorageService');
  }
}
