import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
  }

  void initSettings() {
    BloomeeDBService.getSettingBool("auto_update_notify").then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });
  }

  void updateAutoUpdateNotify(bool value) {
    BloomeeDBService.putSettingBool("auto_update_notify", value);
    emit(state.copyWith(autoUpdateNotify: value));
  }
}
