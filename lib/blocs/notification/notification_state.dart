// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'notification_cubit.dart';

class NotificationState extends Equatable {
  final List<NotificationDB> notifications;
  const NotificationState({
    required this.notifications,
  });

  @override
  List<Object> get props => [notifications];
}

final class NotificationInitial extends NotificationState {
  NotificationInitial() : super(notifications: []);
}
