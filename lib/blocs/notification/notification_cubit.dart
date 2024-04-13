import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  StreamSubscription? _subscription;
  NotificationCubit() : super(NotificationInitial()) {
    getNotification();
  }
  void getNotification() async {
    List<NotificationDB> notifications =
        await BloomeeDBService.getNotifications();
    emit(NotificationState(notifications: notifications));
  }

  void clearNotification() {
    BloomeeDBService.clearNotifications();
    log("Notification Cleared");
    getNotification();
  }

  Future<void> watchNotification() async {
    _subscription =
        (await BloomeeDBService.watchNotification()).listen((event) {
      getNotification();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
