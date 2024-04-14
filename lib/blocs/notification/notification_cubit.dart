import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  StreamSubscription? _subscription;
  NotificationCubit() : super(NotificationInitial()) {
    getLatestVersion().then((value) {
      if (value["results"]) {
        if (int.parse(value["currBuild"]) < int.parse(value["newBuild"])) {
          BloomeeDBService.putNotification(
            title: "Update Available",
            body:
                "New Version of Bloomee🌸 is now available!! Version: ${value["newVer"]} + ${value["newBuild"]}",
            type: "app_update",
            unique: true,
          );
        }
      }
    });
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
