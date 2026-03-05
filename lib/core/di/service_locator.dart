/// Dependency injection container.
///
/// Owns singleton instances of all plugin-system services.
/// No external DI framework (get_it) — simple static singletons.
///
/// Call [ServiceLocator.setup] from [bootstrapApp] (in [services/bootstrap.dart])
/// before [runApp] so that registered services are available at widget-tree build time.
library service_locator;

import 'package:Bloomee/services/db/dao/plugin_storage_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_event_bus.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/plugin/plugin_storage_service.dart';

/// Service locator — static singleton registry.
///
/// Usage:
/// ```dart
/// final pluginService = ServiceLocator.pluginService;
/// final eventBus = ServiceLocator.pluginEventBus;
/// ```
class ServiceLocator {
  ServiceLocator._();

  static bool _initialized = false;

  // ── Plugin System Singletons ─────────────────────────────────────────────

  static late final PluginService pluginService;
  static late final PluginEventBus pluginEventBus;
  static late final PluginStorageService pluginStorageService;
  static late final PluginStorageDao pluginStorageDao;

  /// Wire up all application dependencies.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> setup() async {
    if (_initialized) return;
    _initialized = true;

    // ── Plugin system ──────────────────────────────────────────────────────

    // 1. DAO for plugin storage persistence.
    pluginStorageDao = PluginStorageDao(DBProvider.db);

    // 2. Event bus (singleton — connect later during plugin init).
    pluginEventBus = PluginEventBus.instance;

    // 3. Storage service (needs DAO + event bus).
    pluginStorageService = PluginStorageService(
      dao: pluginStorageDao,
      eventBus: pluginEventBus,
    );

    // 4. Plugin service (main interface — initialize later with pluginsDir).
    pluginService = PluginService();
  }

  /// Initialize the plugin system.
  ///
  /// Call this AFTER [setup()] and AFTER the database is open.
  /// This creates the Rust PluginManager, connects the event bus,
  /// preloads storage from Isar, and starts listening for storage events.
  static Future<void> initializePluginSystem() async {
    // 1. Initialize PluginService (creates Rust PluginManager).
    await pluginService.initialize();

    // 2. Connect event bus to Rust event stream.
    pluginEventBus.connect(pluginService.manager);

    // 3. Preload all Isar storage entries into Rust in-memory storage.
    await pluginStorageService.preloadAll(pluginService.manager);

    // 4. Start listening for storage mutation events (persist to Isar).
    pluginStorageService.startListening();
  }

  /// Shutdown plugin system gracefully.
  static Future<void> disposePluginSystem() async {
    pluginStorageService.dispose();
    pluginEventBus.dispose();
    await pluginService.dispose();
  }
}
