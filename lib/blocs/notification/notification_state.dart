part of 'notification_cubit.dart';

class NotificationState extends Equatable {
  /// Announcements for this install, urgent first.
  final List<FeedItem> items;

  /// "3.2.0+90" when an app update is available.
  final String? update;

  /// The one announcement offered on Home, if any.
  final FeedItem? homeCard;

  /// Entries not seen yet; [updateKey] stands for the update.
  final Set<String> newIds;

  /// The user's "Show on Home" choice.
  final bool showOnHome;

  /// Drafts and scheduled entries are shown, nothing is filtered.
  final bool preview;

  final bool refreshing;

  const NotificationState({
    this.items = const [],
    this.update,
    this.homeCard,
    this.newIds = const {},
    this.showOnHome = true,
    this.preview = false,
    this.refreshing = false,
  });

  static const updateKey = 'app-update';

  /// The bell badge.
  int get unread => newIds.length;

  bool get isEmpty => items.isEmpty && update == null;

  NotificationState copyWith({
    List<FeedItem>? items,
    String? Function()? update,
    FeedItem? Function()? homeCard,
    Set<String>? newIds,
    bool? showOnHome,
    bool? preview,
    bool? refreshing,
  }) =>
      NotificationState(
        items: items ?? this.items,
        update: update != null ? update() : this.update,
        homeCard: homeCard != null ? homeCard() : this.homeCard,
        newIds: newIds ?? this.newIds,
        showOnHome: showOnHome ?? this.showOnHome,
        preview: preview ?? this.preview,
        refreshing: refreshing ?? this.refreshing,
      );

  @override
  List<Object?> get props =>
      [items, update, homeCard, newIds, showOnHome, preview, refreshing];
}
