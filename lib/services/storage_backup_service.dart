import 'package:Bloomee/services/db/db_provider.dart';

class StorageBackupService {
  const StorageBackupService._();

  static Future<String?> createBackup() {
    return DBProvider.createBackUp();
  }

  static Future<void> resetAppData() {
    return DBProvider.resetDB();
  }

  static Future<Map<String, dynamic>> restoreBackup(String? path) {
    return DBProvider.restoreDB(path);
  }
}
