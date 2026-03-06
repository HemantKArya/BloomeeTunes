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
    final isarDB = await _db;

    if (unique) {
      final existing =
          await isarDB.notificationsDBs.filter().typeEqualTo(type).findFirst();
      if (existing != null) {
        await isarDB.writeTxn(
          () async => isarDB.notificationsDBs.delete(existing.id),
        );
      }
    }

    await isarDB.writeTxn(
      () async => isarDB.notificationsDBs.put(
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
    final isarDB = await _db;
    return isarDB.notificationsDBs.where().sortByTimeDesc().findAll();
  }

  Future<void> clearNotifications() async {
    final isarDB = await _db;
    await isarDB.writeTxn(
      () async => isarDB.notificationsDBs.where().deleteAll(),
    );
  }

  Future<Stream<void>> watchNotification() async {
    Isar isarDB = await _db;
    return isarDB.notificationsDBs.watchLazy();
  }
}
