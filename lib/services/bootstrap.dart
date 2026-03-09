import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/local_music_service.dart';
import 'package:Bloomee/src/rust/frb_generated.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Application bootstrap — run once before [runApp].
///
/// Responsibilities:
/// - Initialize platform path constants.
/// - Open the Isar database via [DBProvider].
/// - Schedule periodic DB maintenance tasks.
/// - Wire the [ServiceLocator] and initialize the plugin system.
Future<void> bootstrapApp() async {
  // Initialize flutter_rust_bridge before any Rust API call.
  await RustLib.init();

  final String appDocPath = (await getApplicationDocumentsDirectory()).path;
  final String appSuppPath = (await getApplicationSupportDirectory()).path;

  // Open DB and schedule maintenance.
  await DBProvider.init(
      appSupportPath: appSuppPath, appDocumentsPath: appDocPath);
  DBProvider.scheduleMaintenance();

  // DI wiring (registers singletons).
  await ServiceLocator.setup();

  // Initialize plugin system:
  //   Creates Rust PluginManager → connects event bus →
  //   preloads storage from Isar → starts storage event handler.
  try {
    await ServiceLocator.initializePluginSystem();
    log('Plugin system initialized successfully', name: 'Bootstrap');
  } catch (e, stack) {
    // Plugin system failure is non-fatal — the app can still run
    // with degraded functionality (no plugin content).
    log('Plugin system initialization failed (non-fatal)',
        error: e, stackTrace: stack, name: 'Bootstrap');
  }

  // Auto-scan local music folders if enabled (fire-and-forget).
  try {
    final settingsDao = SettingsDAO(DBProvider.db);
    final autoScan =
        await settingsDao.getSettingBool(SettingKeys.localMusicAutoScan) ??
            true;
    if (autoScan) {
      LocalMusicService.create().scanAndPersist();
    }
  } catch (e) {
    log('Local music auto-scan skipped', error: e, name: 'Bootstrap');
  }
}
