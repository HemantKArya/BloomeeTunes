// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool settingsReady; // true only after all settings loaded from DB
  final bool autoUpdateNotify;
  final bool autoSlideCharts;
  final String downPath;
  final String downQuality;
  final String strmQuality;
  final String backupPath;
  final bool autoBackup;
  final String historyClearTime;
  final bool autoGetCountry;
  final bool lFMPicks;
  final bool lastFMScrobble;
  final bool autoSaveLyrics;
  final bool autoPlay;
  final String countryCode;
  final Map chartMap;
  final int crossfadeDuration; // seconds, 0 = disabled
  final bool eqEnabled;
  final List<double> eqBandGains; // 10 gains, -12..+12 dB
  final String eqPreset;
  final String homePluginId; // content resolver plugin for home sections
  final String searchPluginId; // persisted search plugin selection
  final List<String> resolverPriority; // content resolver priority order
  const SettingsState({
    required this.settingsReady,
    required this.autoUpdateNotify,
    required this.autoSlideCharts,
    required this.downPath,
    required this.downQuality,
    required this.strmQuality,
    required this.backupPath,
    required this.autoBackup,
    required this.historyClearTime,
    required this.autoGetCountry,
    required this.countryCode,
    required this.autoSaveLyrics,
    required this.lFMPicks,
    required this.lastFMScrobble,
    required this.chartMap,
    required this.autoPlay,
    required this.crossfadeDuration,
    required this.eqEnabled,
    required this.eqBandGains,
    required this.eqPreset,
    required this.homePluginId,
    required this.searchPluginId,
    required this.resolverPriority,
  });

  SettingsState copyWith({
    bool? settingsReady,
    bool? autoUpdateNotify,
    bool? autoSlideCharts,
    String? downPath,
    String? downQuality,
    String? strmQuality,
    String? backupPath,
    bool? autoBackup,
    String? historyClearTime,
    bool? autoGetCountry,
    String? countryCode,
    bool? lFMPicks,
    bool? lastFMScrobble,
    Map? chartMap,
    bool? autoSaveLyrics,
    bool? autoPlay,
    int? crossfadeDuration,
    bool? eqEnabled,
    List<double>? eqBandGains,
    String? eqPreset,
    String? homePluginId,
    String? searchPluginId,
    List<String>? resolverPriority,
  }) {
    return SettingsState(
      settingsReady: settingsReady ?? this.settingsReady,
      autoUpdateNotify: autoUpdateNotify ?? this.autoUpdateNotify,
      autoSlideCharts: autoSlideCharts ?? this.autoSlideCharts,
      downPath: downPath ?? this.downPath,
      downQuality: downQuality ?? this.downQuality,
      strmQuality: strmQuality ?? this.strmQuality,
      backupPath: backupPath ?? this.backupPath,
      autoBackup: autoBackup ?? this.autoBackup,
      historyClearTime: historyClearTime ?? this.historyClearTime,
      autoGetCountry: autoGetCountry ?? this.autoGetCountry,
      countryCode: countryCode ?? this.countryCode,
      lFMPicks: lFMPicks ?? this.lFMPicks,
      lastFMScrobble: lastFMScrobble ?? this.lastFMScrobble,
      chartMap: Map.from(chartMap ?? this.chartMap),
      autoSaveLyrics: autoSaveLyrics ?? this.autoSaveLyrics,
      autoPlay: autoPlay ?? this.autoPlay,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      eqEnabled: eqEnabled ?? this.eqEnabled,
      eqBandGains: eqBandGains != null
          ? List<double>.from(eqBandGains)
          : List<double>.from(this.eqBandGains),
      eqPreset: eqPreset ?? this.eqPreset,
      homePluginId: homePluginId ?? this.homePluginId,
      searchPluginId: searchPluginId ?? this.searchPluginId,
      resolverPriority: resolverPriority != null
          ? List<String>.from(resolverPriority)
          : List<String>.from(this.resolverPriority),
    );
  }

  @override
  List<Object?> get props => [
        settingsReady,
        autoUpdateNotify,
        autoSlideCharts,
        downPath,
        downQuality,
        strmQuality,
        backupPath,
        autoBackup,
        historyClearTime,
        autoGetCountry,
        countryCode,
        chartMap,
        lFMPicks,
        lastFMScrobble,
        autoSaveLyrics,
        autoPlay,
        crossfadeDuration,
        eqEnabled,
        eqBandGains,
        eqPreset,
        homePluginId,
        searchPluginId,
        resolverPriority,
      ];
}

class SettingsInitial extends SettingsState {
  SettingsInitial()
      : super(
          settingsReady: false,
          autoUpdateNotify: false,
          autoSlideCharts: true,
          downPath: "",
          downQuality: "Medium",
          strmQuality: "Medium",
          backupPath: "",
          autoBackup: true,
          historyClearTime: "30",
          autoGetCountry: true,
          countryCode: "IN",
          chartMap: {},
          lFMPicks: false,
          lastFMScrobble: true,
          autoSaveLyrics: false,
          autoPlay: true,
          crossfadeDuration: 0,
          eqEnabled: false,
          eqBandGains: List<double>.filled(10, 0.0),
          eqPreset: 'Flat',
          homePluginId: '',
          searchPluginId: '',
          resolverPriority: const [],
        );
}
