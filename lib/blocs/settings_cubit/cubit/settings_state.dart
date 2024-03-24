// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState {
  bool autoUpdateNotify;
  bool autoSlideCharts;
  SettingsState({
    required this.autoUpdateNotify,
    required this.autoSlideCharts,
  });

  SettingsState copyWith({
    bool? autoUpdateNotify,
    bool? autoSlideCharts,
  }) {
    return SettingsState(
      autoUpdateNotify: autoUpdateNotify ?? this.autoUpdateNotify,
      autoSlideCharts: autoSlideCharts ?? this.autoSlideCharts,
    );
  }
}

final class SettingsInitial extends SettingsState {
  SettingsInitial() : super(autoUpdateNotify: false, autoSlideCharts: true);
}
