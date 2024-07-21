// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState {
  bool autoUpdateNotify;
  bool autoSlideCharts;
  String downPath;
  String downQuality;
  String ytDownQuality;
  String strmQuality;
  String ytStrmQuality;
  String backupPath;
  bool autoBackup;
  String historyClearTime;
  bool autoGetCountry;
  String countryCode;
  List<bool> sourceEngineSwitches;
  SettingsState({
    required this.autoUpdateNotify,
    required this.autoSlideCharts,
    required this.downPath,
    required this.downQuality,
    required this.ytDownQuality,
    required this.strmQuality,
    required this.ytStrmQuality,
    required this.backupPath,
    required this.autoBackup,
    required this.historyClearTime,
    required this.autoGetCountry,
    required this.countryCode,
    required this.sourceEngineSwitches,
  });

  SettingsState copyWith({
    bool? autoUpdateNotify,
    bool? autoSlideCharts,
    String? downPath,
    String? downQuality,
    String? ytDownQuality,
    String? strmQuality,
    String? ytStrmQuality,
    String? backupPath,
    bool? autoBackup,
    String? historyClearTime,
    bool? autoGetCountry,
    String? countryCode,
    List<bool>? sourceEngineSwitches,
  }) {
    return SettingsState(
      autoUpdateNotify: autoUpdateNotify ?? this.autoUpdateNotify,
      autoSlideCharts: autoSlideCharts ?? this.autoSlideCharts,
      downPath: downPath ?? this.downPath,
      downQuality: downQuality ?? this.downQuality,
      ytDownQuality: ytDownQuality ?? this.ytDownQuality,
      strmQuality: strmQuality ?? this.strmQuality,
      ytStrmQuality: ytStrmQuality ?? this.ytStrmQuality,
      backupPath: backupPath ?? this.backupPath,
      autoBackup: autoBackup ?? this.autoBackup,
      historyClearTime: historyClearTime ?? this.historyClearTime,
      autoGetCountry: autoGetCountry ?? this.autoGetCountry,
      countryCode: countryCode ?? this.countryCode,
      sourceEngineSwitches: sourceEngineSwitches ?? this.sourceEngineSwitches,
    );
  }
}

final class SettingsInitial extends SettingsState {
  SettingsInitial()
      : super(
          autoUpdateNotify: false,
          autoSlideCharts: true,
          downPath: "",
          downQuality: "320 kbps",
          ytDownQuality: "High",
          strmQuality: "96 kbps",
          ytStrmQuality: "Low",
          backupPath: "",
          autoBackup: true,
          historyClearTime: "30",
          autoGetCountry: true,
          countryCode: "IN",
          sourceEngineSwitches: SourceEngine.values.map((e) => true).toList(),
        );
}
