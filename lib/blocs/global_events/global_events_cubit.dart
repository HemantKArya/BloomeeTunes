import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/bloomee_updater_tools.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_events_state.dart';

class GlobalEventsCubit extends Cubit<GlobalEventsState> {
  final SettingsDAO _settingsDao;

  GlobalEventsCubit({required SettingsDAO settingsDao})
      : _settingsDao = settingsDao,
        super(GlobalEventsInitial()) {
    checkForUpdates();
  }

  /// At most one interruption per launch: "What's new" right after an
  /// update, otherwise the update dialog, once per new version. The inbox
  /// keeps listing an available update after that.
  void checkForUpdates() async {
    final updates = await getAppUpdates();
    if (isClosed) return;

    if (updates['changelogs'] != null) {
      emit(WhatIsNewState(changeLogs: updates['changelogs']));
      return;
    }
    if (updates['results'] != true) return;
    if (!(await _settingsDao.getSettingBool(SettingKeys.autoUpdateNotify) ??
        true)) {
      return;
    }

    final version = '${updates['newVer']}+${updates['newBuild']}';
    if (await _settingsDao.getSettingStr(SettingKeys.updatePrompted) ==
        version) {
      return;
    }
    await _settingsDao.putSettingStr(SettingKeys.updatePrompted, version);
    log('Update available: $version', name: 'GlobalEventsCubit');
    if (isClosed) return;
    emit(UpdateAvailable(
      newVersion: updates['newVer'],
      newBuild: updates['newBuild'],
      downloadUrl: "https://bloomee.sourceforge.io/",
    ));
  }

  void showAlertDialog(String title, String content) {
    emit(AlertDialogState(title: title, content: content));
  }
}
