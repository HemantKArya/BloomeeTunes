// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState {
  bool autoUpdateNotify;
  SettingsState({
    required this.autoUpdateNotify,
  });

  SettingsState copyWith({
    bool? autoUpdateNotify,
  }) {
    return SettingsState(
      autoUpdateNotify: autoUpdateNotify ?? this.autoUpdateNotify,
    );
  }
}

final class SettingsInitial extends SettingsState {
  SettingsInitial() : super(autoUpdateNotify: false);
}
