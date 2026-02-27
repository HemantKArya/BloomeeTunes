import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for in-app notifications.
class NotificationDAO {
  final Future<Isar> _db;

  const NotificationDAO(this._db);

  Future<void> putNotification({
    required String title,
    required String body,
    required String type,
    String? url,
    String? payload,
    bool unique = false,
  }) async {
    Isar isarDB = await _db;

    if (unique) {
      final existing =
          isarDB.notificationDBs.filter().typeEqualTo(type).findFirstSync();
      if (existing != null) {
        isarDB
            .writeTxnSync(() => isarDB.notificationDBs.deleteSync(existing.id!));
      }
    }

    isarDB.writeTxnSync(
      () => isarDB.notificationDBs.putSync(
        NotificationDB(
          title: title,
          body: body,
          time: DateTime.now(),
          type: type,
          url: url,
          payload: payload,
        ),
      ),
    );
  }

  Future<List<NotificationDB>> getNotifications() async {
    Isar isarDB = await _db;
    return isarDB.notificationDBs.where().sortByTimeDesc().findAllSync();
  }

  Future<void> clearNotifications() async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.notificationDBs.where().deleteAllSync());
  }

  Future<Stream<void>> watchNotification() async {
    Isar isarDB = await _db;
    return isarDB.notificationDBs.watchLazy();
  }
}
