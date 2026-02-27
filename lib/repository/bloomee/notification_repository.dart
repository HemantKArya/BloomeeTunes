import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/notification_dao.dart';

/// Repository for in-app notifications.
///
/// Wraps [NotificationDAO] and provides a clean interface
/// for creating, querying, and observing notifications.
class NotificationRepository {
  final NotificationDAO _notificationDao;

  const NotificationRepository(this._notificationDao);

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? url,
    String? payload,
    bool unique = false,
  }) =>
      _notificationDao.putNotification(
        title: title,
        body: body,
        type: type,
        url: url,
        payload: payload,
        unique: unique,
      );

  /// Returns all notifications sorted by time (newest first).
  Future<List<NotificationDB>> getNotifications() =>
      _notificationDao.getNotifications();

  Future<void> clearAll() => _notificationDao.clearNotifications();

  Future<Stream<void>> watchNotifications() =>
      _notificationDao.watchNotification();
}
