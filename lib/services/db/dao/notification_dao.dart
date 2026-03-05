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
          isarDB.notificationsDBs.filter().typeEqualTo(type).findFirstSync();
      if (existing != null) {
        isarDB.writeTxnSync(
            () => isarDB.notificationsDBs.deleteSync(existing.id));
      }
    }

    isarDB.writeTxnSync(
      () => isarDB.notificationsDBs.putSync(
        NotificationsDB(
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

  Future<List<NotificationsDB>> getNotifications() async {
    Isar isarDB = await _db;
    return isarDB.notificationsDBs.where().sortByTimeDesc().findAllSync();
  }

  Future<void> clearNotifications() async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.notificationsDBs.where().deleteAllSync());
  }

  Future<Stream<void>> watchNotification() async {
    Isar isarDB = await _db;
    return isarDB.notificationsDBs.watchLazy();
  }
}
