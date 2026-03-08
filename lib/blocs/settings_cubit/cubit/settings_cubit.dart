import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepo;

  SettingsCubit(this._settingsRepo) : super(SettingsInitial()) {
    _initSettings();
    autoUpdate();
  }

// Initialize the settings from the database
  Future<void> _initSettings() async {
    await Future.wait([
      _settingsRepo.getSettingBool(SettingKeys.autoUpdateNotify).then((value) {
        emit(state.copyWith(autoUpdateNotify: value ?? false));
      }),
      _settingsRepo.getSettingBool(SettingKeys.autoSlideCharts).then((value) {
        emit(state.copyWith(autoSlideCharts: value ?? true));
      }),
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
      }),
      _settingsRepo
          .getSettingStr(
        SettingKeys.downQuality,
        defaultValue: AudioStreamQualityPreference.medium.label,
      )
          .then((value) {
        final normalized = normalizeStoredStreamQualityLabel(
          value,
          fallback: AudioStreamQualityPreference.medium.label,
        );
        if (value != normalized) {
          _settingsRepo.putSettingStr(SettingKeys.downQuality, normalized);
        }
        emit(state.copyWith(downQuality: normalized));
      }),
      _settingsRepo
          .getSettingStr(
        SettingKeys.strmQuality,
      )
          .then((value) {
        final normalized = normalizeStoredStreamQualityLabel(
          value,
          fallback: AudioStreamQualityPreference.medium.label,
        );
        if (value != normalized) {
          _settingsRepo.putSettingStr(SettingKeys.strmQuality, normalized);
        }
        emit(state.copyWith(strmQuality: normalized));
      }),
      _settingsRepo.getSettingStr(SettingKeys.historyClearTime).then((value) {
        emit(state.copyWith(historyClearTime: value ?? "30"));
      }),
      _settingsRepo.getSettingBool(CacheKeys.lFMScrobbleSetting).then((value) {
        emit(state.copyWith(lastFMScrobble: value ?? false));
      }),
      _settingsRepo
          .getSettingBool(
        SettingKeys.autoPlay,
      )
          .then((value) {
        emit(state.copyWith(autoPlay: value ?? true));
      }),
      _settingsRepo.getSettingBool(CacheKeys.lFMUIPicks).then((value) {
        emit(state.copyWith(lFMPicks: value ?? false));
      }),
      _settingsRepo.getSettingStr(SettingKeys.backupPath).then((value) async {
        final defaultBackUpDir = await DBProvider.getDbBackupFilePath();

        await _settingsRepo.putSettingStr(
            SettingKeys.backupPath, defaultBackUpDir);
        emit(state.copyWith(backupPath: defaultBackUpDir));
      }),
      _settingsRepo.getSettingBool(SettingKeys.autoBackup).then((value) {
        emit(state.copyWith(autoBackup: value ?? false));
      }),
      _settingsRepo.getSettingBool(SettingKeys.autoGetCountry).then((value) {
        emit(state.copyWith(autoGetCountry: value ?? false));
      }),
      _settingsRepo.getSettingStr(SettingKeys.countryCode).then((value) {
        emit(state.copyWith(countryCode: value ?? "IN"));
      }),
      _settingsRepo.getSettingBool(SettingKeys.autoSaveLyrics).then((value) {
        emit(state.copyWith(autoSaveLyrics: value ?? false));
      }),
      _settingsRepo.getSettingStr(SettingKeys.chartShowMap).then((value) {
        Map chartMap = Map.from(state.chartMap);
        if (value != null) {
          chartMap = jsonDecode(value);
        }
        emit(state.copyWith(chartMap: Map.from(chartMap)));
      }),
      _settingsRepo
          .getSettingStr(SettingKeys.crossfadeDuration, defaultValue: '0')
          .then((value) {
        final seconds = int.tryParse(value ?? '0') ?? 0;
        emit(state.copyWith(crossfadeDuration: seconds));
      }),
      _settingsRepo.getSettingBool(SettingKeys.eqEnabled).then((value) {
        emit(state.copyWith(eqEnabled: value ?? false));
      }),
      _settingsRepo.getSettingStr(SettingKeys.eqBandGains).then((value) {
        if (value != null) {
          try {
            final decoded = jsonDecode(value) as List;
            final gains = decoded.map((e) => (e as num).toDouble()).toList();
            if (gains.length == 10) {
              emit(state.copyWith(eqBandGains: gains));
            }
          } catch (e) {
            log('Failed to decode EQ gains: $e', name: 'SettingsCubit');
          }
        }
      }),
      _settingsRepo
          .getSettingStr(SettingKeys.eqPreset, defaultValue: 'Flat')
          .then((value) {
        emit(state.copyWith(eqPreset: value ?? 'Flat'));
      }),
      _settingsRepo
          .getSettingStr(SettingKeys.homePluginId, defaultValue: '')
          .then((value) {
        emit(state.copyWith(homePluginId: value ?? ''));
      }),
      _settingsRepo
          .getSettingStr(SettingKeys.searchPluginId, defaultValue: '')
          .then((value) {
        emit(state.copyWith(searchPluginId: value ?? ''));
      }),
      _settingsRepo
          .getSettingStr(SettingKeys.resolverPriority, defaultValue: '[]')
          .then((value) {
        List<String> priority = const [];
        if (value != null && value.isNotEmpty) {
          try {
            priority = (jsonDecode(value) as List).cast<String>();
          } catch (e) {
            log('Failed to decode resolver priority: $e',
                name: 'SettingsCubit');
          }
        }
        emit(state.copyWith(resolverPriority: priority));
      }),
    ]);
    emit(state.copyWith(settingsReady: true));
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
      if (value == true) {
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
    final normalized = normalizeStoredStreamQualityLabel(
      value,
      fallback: AudioStreamQualityPreference.medium.label,
    );
    _settingsRepo.putSettingStr(SettingKeys.downQuality, normalized);
    emit(state.copyWith(downQuality: normalized));
  }

  void setStrmQuality(String value) {
    final normalized = normalizeStoredStreamQualityLabel(
      value,
      fallback: AudioStreamQualityPreference.medium.label,
    );
    _settingsRepo.putSettingStr(SettingKeys.strmQuality, normalized);
    emit(state.copyWith(strmQuality: normalized));
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

  // ── Crossfade ────────────────────────────────────────────────────────────

  void setCrossfadeDuration(int seconds) {
    _settingsRepo.putSettingStr(
        SettingKeys.crossfadeDuration, seconds.toString());
    emit(state.copyWith(crossfadeDuration: seconds));
  }

  // ── Equalizer persistence ───────────────────────────────────────────────

  void setEqEnabled(bool value) {
    _settingsRepo.putSettingBool(SettingKeys.eqEnabled, value);
    emit(state.copyWith(eqEnabled: value));
  }

  void setEqBandGains(List<double> gains) {
    _settingsRepo.putSettingStr(SettingKeys.eqBandGains, jsonEncode(gains));
    emit(state.copyWith(eqBandGains: gains));
  }

  void setEqPreset(String preset) {
    _settingsRepo.putSettingStr(SettingKeys.eqPreset, preset);
    emit(state.copyWith(eqPreset: preset));
  }

  void setHomePluginId(String pluginId) {
    _settingsRepo.putSettingStr(SettingKeys.homePluginId, pluginId);
    emit(state.copyWith(homePluginId: pluginId));
  }

  void setSearchPluginId(String pluginId) {
    _settingsRepo.putSettingStr(SettingKeys.searchPluginId, pluginId);
    emit(state.copyWith(searchPluginId: pluginId));
  }

  void setResolverPriority(List<String> priority) {
    _settingsRepo.putSettingStr(
        SettingKeys.resolverPriority, jsonEncode(priority));
    emit(state.copyWith(resolverPriority: priority));
  }

  Future<void> resetDownPath() async {
    String path;
    path = ((await getDownloadsDirectory()) ??
            (await getApplicationDocumentsDirectory()))
        .path;

    setDownPath(path);
    log("Download path reset to: $path", name: 'SettingsCubit');
  }

  /// Generic setting write — for one-off setting updates from UI.
  Future<void> putSettingStr(String key, String value) async {
    await _settingsRepo.putSettingStr(key, value);
  }
}
