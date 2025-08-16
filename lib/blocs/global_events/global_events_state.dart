part of 'global_events_cubit.dart';

sealed class GlobalEventsState extends Equatable {
  const GlobalEventsState();

  @override
  List<Object> get props => [];
}

final class GlobalEventsInitial extends GlobalEventsState {}

final class UpdateAvailable extends GlobalEventsState {
  final String newVersion;
  final String message;
  final String downloadUrl;

  const UpdateAvailable(
      {required this.newVersion,
      required this.message,
      required this.downloadUrl});
}

final class WhatIsNewState extends GlobalEventsState {
  final String changeLogs;

  const WhatIsNewState({required this.changeLogs});
}

final class AlertDialogState extends GlobalEventsState {
  final String title;
  final String content;

  const AlertDialogState({required this.title, required this.content});
}
