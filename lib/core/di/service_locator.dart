/// Dependency injection shell.
///
/// Phase 2+ will register DAOs, repositories, and services here.
/// Currently this is an empty scaffold — all service initialization is still
/// performed by the legacy [bootstrap.dart] flow.
///
/// When get_it is added as a dependency, replace this with:
///
/// ```dart
/// import 'package:get_it/get_it.dart';
/// final GetIt locator = GetIt.instance;
/// ```
library service_locator;

/// Service locator placeholder.
///
/// Call [ServiceLocator.setup] from [bootstrapApp] (in [services/bootstrap.dart])
/// before [runApp] so that registered services are available at widget-tree build time.
class ServiceLocator {
  ServiceLocator._();

  static bool _initialized = false;

  /// Wire up all application dependencies.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> setup() async {
    if (_initialized) return;
    _initialized = true;

    // ── Phase 2: register DAOs ──────────────────────────────────────────────
    // locator.registerSingleton<PlaylistDao>(PlaylistDao(db));
    // locator.registerSingleton<TrackDao>(TrackDao(db));
    // locator.registerSingleton<SettingsDao>(SettingsDao(db));

    // ── Phase 3: register repositories ─────────────────────────────────────
    // locator.registerSingleton<PlaylistRepository>(PlaylistRepositoryImpl(...));
    // locator.registerSingleton<SearchRepository>(SearchRepositoryImpl(...));
  }
}
