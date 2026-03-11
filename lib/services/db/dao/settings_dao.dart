import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for settings (string & bool) persistence.
class SettingsDAO {
  final Future<Isar> _db;

  const SettingsDAO(this._db);

  // --------------- String settings ---------------

  Future<void> putSettingStr(String key, String value) async {
    Isar isarDB = await _db;
    if (key.isNotEmpty) {
      await isarDB.writeTxn(() async {
        await isarDB.appSettingsStrDBs
            .put(AppSettingsStrDB(settingName: key, settingValue: value));
      });
    }
  }

  Future<String?> getSettingStr(String key, {String? defaultValue}) async {
    Isar isarDB = await _db;
    final settingValue = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
    if (settingValue != null) {
      return settingValue;
    } else {
      return defaultValue;
    }
  }

  Future<Stream<AppSettingsStrDB?>?> getWatcher4SettingStr(String key) async {
    Isar isarDB = await _db;
    int? id = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.id;
    if (id != null) {
      return isarDB.appSettingsStrDBs.watchObject(id, fireImmediately: true);
    } else {
      return null;
    }
  }

  // --------------- Bool settings ---------------

  Future<void> putSettingBool(String key, bool value) async {
    Isar isarDB = await _db;
    if (key.isNotEmpty) {
      await isarDB.writeTxn(() async {
        await isarDB.appSettingsBoolDBs
            .put(AppSettingsBoolDB(settingName: key, settingValue: value));
      });
    }
  }

  Future<bool?> getSettingBool(String key, {bool? defaultValue}) async {
    Isar isarDB = await _db;
    final settingValue = isarDB.appSettingsBoolDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.settingValue;
    if (settingValue != null) {
      return settingValue;
    } else {
      return defaultValue;
    }
  }

  Future<Stream<AppSettingsBoolDB?>?> getWatcher4SettingBool(String key) async {
    Isar isarDB = await _db;
    int? id = isarDB.appSettingsBoolDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync()
        ?.id;
    if (id != null) {
      return isarDB.appSettingsBoolDBs.watchObject(id, fireImmediately: true);
    } else {
      await isarDB.writeTxn(() async {
        await isarDB.appSettingsBoolDBs
            .put(AppSettingsBoolDB(settingName: key, settingValue: false));
      });
      return isarDB.appSettingsBoolDBs.watchObject(
        isarDB.appSettingsBoolDBs
            .filter()
            .settingNameEqualTo(key)
            .findFirstSync()!
            .id,
        fireImmediately: true,
      );
    }
  }
}
