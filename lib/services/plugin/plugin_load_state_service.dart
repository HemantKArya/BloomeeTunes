import 'dart:convert';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

class PluginLoadStateService {
  final SettingsDAO _settingsDao;

  const PluginLoadStateService(this._settingsDao);

  Future<Set<String>> readAutoLoadPluginIds() async {
    final raw = await _settingsDao.getSettingStr(SettingKeys.autoLoadPluginIds);
    if (raw == null || raw.trim().isEmpty) return <String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet();
      }
    } catch (_) {
      return <String>{};
    }

    return <String>{};
  }

  Future<void> writeAutoLoadPluginIds(Set<String> pluginIds) {
    return _settingsDao.putSettingStr(
      SettingKeys.autoLoadPluginIds,
      jsonEncode(pluginIds.toList()..sort()),
    );
  }
}
