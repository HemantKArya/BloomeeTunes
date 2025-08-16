import 'dart:developer';

import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_events_state.dart';

class GlobalEventsCubit extends Cubit<GlobalEventsState> {
  GlobalEventsCubit() : super(GlobalEventsInitial()) {
    checkForUpdates();
  }

  void checkForUpdates() async {
    final Map<String, dynamic> updates = await getAppUpdates();
    log("Checking for updates...", name: 'GlobalEventsCubit');

    if (updates['changelogs'] != null) {
      emit(WhatIsNewState(changeLogs: updates['changelogs']));
    }

    if (await BloomeeDBService.getSettingBool(
            GlobalStrConsts.autoUpdateNotify) ??
        true) {
      if (updates["results"]) {
        emit(UpdateAvailable(
          newVersion: updates["newVer"],
          message:
              "New Version of Bloomee🌸 is now available!!\n\nVersion: ${updates["newVer"]} + ${updates["newBuild"]}",
          downloadUrl: "https://bloomee.sourceforge.io/",
        ));
      }
    }
  }

  void showAlertDialog(String title, String content) {
    emit(AlertDialogState(title: title, content: content));
  }
}
