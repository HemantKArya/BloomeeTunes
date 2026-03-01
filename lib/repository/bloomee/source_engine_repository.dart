import 'package:Bloomee/core/models/source_engines.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';

/// Repository for source engine configuration — determines which
/// engines are available based on country and user settings.
///
/// Wraps [SettingsDAO] reads for country and engine-enabled flags.
/// Reuses the existing [SourceEngine] enum and [sourceEngineCountries]
/// map from `source_engines.dart`.
class SourceEngineRepository {
  final SettingsDAO _settingsDao;

  const SourceEngineRepository(this._settingsDao);

  /// Returns the list of source engines available to the user
  /// based on their country setting and per-engine enabled flags.
  Future<List<SourceEngine>> getAvailableEngines() async {
    final country = await _settingsDao.getSettingStr(
      SettingKeys.countryCode,
      defaultValue: 'IN',
    );

    final engines = <SourceEngine>[];

    for (final engine in SourceEngine.values) {
      final countries = sourceEngineCountries[engine] ?? [];

      // If no country restriction, engine is available everywhere
      if (countries.isEmpty || countries.contains(country ?? 'IN')) {
        // Check if user has disabled this engine
        final enabled = await _settingsDao.getSettingBool(
          engine.value,
          defaultValue: true,
        );
        if (enabled ?? true) {
          engines.add(engine);
        }
      }
    }

    return engines;
  }

  /// Enables or disables a source engine.
  Future<void> setEngineEnabled(SourceEngine engine, bool enabled) =>
      _settingsDao.putSettingBool(engine.value, enabled);

  /// Checks if a specific engine is enabled.
  Future<bool> isEngineEnabled(SourceEngine engine) async {
    final enabled = await _settingsDao.getSettingBool(
      engine.value,
      defaultValue: true,
    );
    return enabled ?? true;
  }

  /// Gets the user's configured country code.
  Future<String> getCountryCode() async {
    final country = await _settingsDao.getSettingStr(
      SettingKeys.countryCode,
      defaultValue: 'IN',
    );
    return country ?? 'IN';
  }

  /// Sets the user's country code.
  Future<void> setCountryCode(String countryCode) =>
      _settingsDao.putSettingStr(SettingKeys.countryCode, countryCode);
}
