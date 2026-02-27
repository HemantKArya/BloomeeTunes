import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepo;

  SettingsCubit(this._settingsRepo) : super(SettingsInitial()) {
    initSettings();
    autoUpdate();
  }

// Initialize the settings from the database
  void initSettings() {
    _settingsRepo.getSettingBool(SettingKeys.autoUpdateNotify).then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });

    _settingsRepo.getSettingBool(SettingKeys.autoSlideCharts).then((value) {
      emit(state.copyWith(autoSlideCharts: value ?? true));
    });

    _settingsRepo
        .getSettingStr(SettingKeys.downPathSetting)
        .then((value) async {
      String path;
      if (value != null) {
        path = value;
      } else {
        path = ((await getDownloadsDirectory()) ??
                (await getApplicationDocumentsDirectory()))
            .path;
        setDownPath(path);
        log("Download path set to: $path", name: 'SettingsCubit');
      }
      emit(state.copyWith(downPath: path));
    });

    _settingsRepo
        .getSettingStr(SettingKeys.downQuality, defaultValue: '320 kbps')
        .then((value) {
      emit(state.copyWith(downQuality: value ?? "320 kbps"));
    });

    _settingsRepo.getSettingStr(SettingKeys.ytDownQuality).then((value) {
      emit(state.copyWith(ytDownQuality: value ?? "High"));
    });

    _settingsRepo
        .getSettingStr(
      SettingKeys.strmQuality,
    )
        .then((value) {
      emit(state.copyWith(strmQuality: value ?? "96 kbps"));
    });

    _settingsRepo.getSettingStr(SettingKeys.ytStrmQuality).then((value) {
      if (value == "High" || value == "Low") {
        emit(state.copyWith(ytStrmQuality: value ?? "Low"));
      } else {
        _settingsRepo.putSettingStr(SettingKeys.ytStrmQuality, "Low");
        emit(state.copyWith(ytStrmQuality: "Low"));
      }
    });

    _settingsRepo.getSettingStr(SettingKeys.historyClearTime).then((value) {
      emit(state.copyWith(historyClearTime: value ?? "30"));
    });

    _settingsRepo.getSettingBool(CacheKeys.lFMScrobbleSetting).then((value) {
      emit(state.copyWith(lastFMScrobble: value ?? false));
    });

    _settingsRepo
        .getSettingBool(
      SettingKeys.autoPlay,
    )
        .then((value) {
      emit(state.copyWith(autoPlay: value ?? true));
    });

    _settingsRepo.getSettingBool(CacheKeys.lFMUIPicks).then((value) {
      emit(state.copyWith(lFMPicks: value ?? false));
    });

    _settingsRepo.getSettingStr(SettingKeys.backupPath).then((value) async {
      final defaultBackUpDir = await DBProvider.getDbBackupFilePath();

      await _settingsRepo.putSettingStr(
          SettingKeys.backupPath, defaultBackUpDir);
      emit(state.copyWith(backupPath: defaultBackUpDir));
    });

    _settingsRepo.getSettingBool(SettingKeys.autoBackup).then((value) {
      emit(state.copyWith(autoBackup: value ?? false));
    });

    _settingsRepo.getSettingBool(SettingKeys.autoGetCountry).then((value) {
      emit(state.copyWith(autoGetCountry: value ?? false));
    });

    _settingsRepo.getSettingStr(SettingKeys.countryCode).then((value) {
      emit(state.copyWith(countryCode: value ?? "IN"));
    });

    _settingsRepo.getSettingBool(SettingKeys.autoSaveLyrics).then((value) {
      emit(state.copyWith(autoSaveLyrics: value ?? false));
    });

    for (var eg in SourceEngine.values) {
      _settingsRepo.getSettingBool(eg.value).then((value) {
        List<bool> switches = List.from(state.sourceEngineSwitches);
        switches[SourceEngine.values.indexOf(eg)] = value ?? true;
        emit(state.copyWith(sourceEngineSwitches: switches));
        log(switches.toString(), name: 'SettingsCubit');
      });
    }

    Map chartMap = Map.from(state.chartMap);
    _settingsRepo.getSettingStr(SettingKeys.chartShowMap).then((value) {
      if (value != null) {
        chartMap = jsonDecode(value);
      }
      emit(state.copyWith(chartMap: Map.from(chartMap)));
    });
  }

  void setChartShow(String title, bool value) {
    Map chartMap = Map.from(state.chartMap);
    chartMap[title] = value;
    _settingsRepo.putSettingStr(SettingKeys.chartShowMap, jsonEncode(chartMap));
    emit(state.copyWith(chartMap: Map.from(chartMap)));
  }

  Future<void> setAutoPlay(bool value) async {
    await _settingsRepo.putSettingBool(SettingKeys.autoPlay, value);
    emit(state.copyWith(autoPlay: value));
  }

  void autoUpdate() {
    _settingsRepo.getSettingBool(SettingKeys.autoBackup).then((value) {
      if (value != null || value == true) {
        DBProvider.createBackUp();
      }
    });
  }

  void setCountryCode(String value) {
    _settingsRepo.putSettingStr(SettingKeys.countryCode, value);
    emit(state.copyWith(countryCode: value));
  }

  void setAutoSaveLyrics(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoSaveLyrics, value);
    emit(state.copyWith(autoSaveLyrics: value));
  }

  void setLastFMScrobble(bool value) {
    _settingsRepo.putSettingBool(CacheKeys.lFMScrobbleSetting, value);
    emit(state.copyWith(lastFMScrobble: value));
  }

  void setLastFMExpore(bool value) {
    _settingsRepo.putSettingBool(CacheKeys.lFMUIPicks, value);
    emit(state.copyWith(lFMPicks: value));
  }

  void setAutoGetCountry(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoGetCountry, value);
    emit(state.copyWith(autoGetCountry: value));
  }

  void setAutoUpdateNotify(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoUpdateNotify, value);
    emit(state.copyWith(autoUpdateNotify: value));
  }

  void setAutoSlideCharts(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoSlideCharts, value);
    emit(state.copyWith(autoSlideCharts: value));
  }

  void setDownPath(String value) {
    _settingsRepo.putSettingStr(SettingKeys.downPathSetting, value);
    emit(state.copyWith(downPath: value));
  }

  void setDownQuality(String value) {
    _settingsRepo.putSettingStr(SettingKeys.downQuality, value);
    emit(state.copyWith(downQuality: value));
  }

  void setYtDownQuality(String value) {
    _settingsRepo.putSettingStr(SettingKeys.ytDownQuality, value);
    emit(state.copyWith(ytDownQuality: value));
  }

  void setStrmQuality(String value) {
    _settingsRepo.putSettingStr(SettingKeys.strmQuality, value);
    emit(state.copyWith(strmQuality: value));
  }

  void setYtStrmQuality(String value) {
    _settingsRepo.putSettingStr(SettingKeys.ytStrmQuality, value);
    emit(state.copyWith(ytStrmQuality: value));
  }

  void setBackupPath(String value) {
    _settingsRepo.putSettingStr(SettingKeys.backupPath, value);
    emit(state.copyWith(backupPath: value));
  }

  void setAutoBackup(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.autoBackup, value);
    emit(state.copyWith(autoBackup: value));
  }

  void setHistoryClearTime(String value) {
    _settingsRepo.putSettingStr(SettingKeys.historyClearTime, value);
    emit(state.copyWith(historyClearTime: value));
  }

  void setSourceEngineSwitches(int index, bool value) {
    List<bool> switches = List.from(state.sourceEngineSwitches);
    switches[index] = value;
    _settingsRepo.putSettingBool(SourceEngine.values[index].value, value);
    emit(state.copyWith(sourceEngineSwitches: List.from(switches)));
  }

  Future<void> resetDownPath() async {
    String path;
    path = ((await getDownloadsDirectory()) ??
            (await getApplicationDocumentsDirectory()))
        .path;

    setDownPath(path);
    log("Download path reset to: $path", name: 'SettingsCubit');
  }

  Future<List<SourceEngine>> getAvailableSourceEngines() async {
    return _settingsRepo.getAvailableSourceEngines();
  }

  Future<String?> getJsQualityURL(String url, {bool isStreaming = true}) async {
    return _settingsRepo.getJsQualityURL(url, isStreaming: isStreaming);
  }

  /// Generic setting write — for one-off setting updates from UI.
  Future<void> putSettingStr(String key, String value) async {
    await _settingsRepo.putSettingStr(key, value);
  }
}
