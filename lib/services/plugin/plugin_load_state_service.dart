import 'dart:convert';
import 'dart:async';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

class PluginLoadStateService {
  final SettingsDAO _settingsDao;
  static Future<void> _mutationChain = Future<void>.value();

  const PluginLoadStateService(this._settingsDao);

  Future<T> _enqueueMutation<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _mutationChain = _mutationChain.catchError((_) {}).then((_) async {
      try {
        completer.complete(await action());
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    });
    return completer.future;
  }

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
    return _enqueueMutation(() => _settingsDao.putSettingStr(
          SettingKeys.autoLoadPluginIds,
          jsonEncode(pluginIds.toList()..sort()),
        ));
  }

  Future<Set<String>> addAutoLoadPluginIds(Iterable<String> pluginIds) {
    return _enqueueMutation(() async {
      final current = await readAutoLoadPluginIds();
      current.addAll(pluginIds.map((e) => e.trim()).where((e) => e.isNotEmpty));
      await _settingsDao.putSettingStr(
        SettingKeys.autoLoadPluginIds,
        jsonEncode(current.toList()..sort()),
      );
      return current;
    });
  }

  Future<Set<String>> removeAutoLoadPluginIds(Iterable<String> pluginIds) {
    return _enqueueMutation(() async {
      final current = await readAutoLoadPluginIds();
      for (final id in pluginIds) {
        current.remove(id.trim());
      }
      await _settingsDao.putSettingStr(
        SettingKeys.autoLoadPluginIds,
        jsonEncode(current.toList()..sort()),
      );
      return current;
    });
  }
}
