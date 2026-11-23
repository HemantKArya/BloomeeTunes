import 'package:Bloomee/services/feed/feed_item.dart';

/// What this install remembers about announcements. Stored as one small
/// JSON setting and pruned to the ids still in the feed.
class FeedMemory {
  /// Seen in the inbox; no longer counted as new.
  final Set<String> seen;

  /// Closed on Home; the inbox still lists them.
  final Set<String> closed;

  /// Removed from the inbox by the user.
  final Set<String> dismissed;

  /// When this install first loaded the feed. Home stays quiet for a day.
  final DateTime? firstRun;

  /// The app update ("3.2.0+90") already seen in the inbox.
  final String? seenUpdate;

  const FeedMemory({
    this.seen = const {},
    this.closed = const {},
    this.dismissed = const {},
    this.firstRun,
    this.seenUpdate,
  });

  factory FeedMemory.fromJson(Object? json) {
    if (json is! Map) return const FeedMemory();
    Set<String> ids(String key) => {
          if (json[key] case final List list)
            for (final v in list)
              if (v is String) v
        };
    DateTime? time(String key) =>
        json[key] is String ? DateTime.tryParse(json[key] as String) : null;
    String? text(String key) => json[key] is String ? json[key] as String : null;
    return FeedMemory(
      seen: ids('seen'),
      closed: ids('closed'),
      dismissed: ids('dismissed'),
      firstRun: time('firstRun'),
      seenUpdate: text('seenUpdate'),
    );
  }

  Map<String, Object> toJson() => {
        if (seen.isNotEmpty) 'seen': seen.toList(),
        if (closed.isNotEmpty) 'closed': closed.toList(),
        if (dismissed.isNotEmpty) 'dismissed': dismissed.toList(),
        if (firstRun != null) 'firstRun': firstRun!.toUtc().toIso8601String(),
        if (seenUpdate != null) 'seenUpdate': seenUpdate!,
      };

  FeedMemory copyWith({
    Set<String>? seen,
    Set<String>? closed,
    Set<String>? dismissed,
    DateTime? firstRun,
    String? seenUpdate,
  }) =>
      FeedMemory(
        seen: seen ?? this.seen,
        closed: closed ?? this.closed,
        dismissed: dismissed ?? this.dismissed,
        firstRun: firstRun ?? this.firstRun,
        seenUpdate: seenUpdate ?? this.seenUpdate,
      );

  /// Forgets ids that left the feed, so the setting never grows.
  FeedMemory prunedTo(Iterable<String> ids) {
    final live = ids.toSet();
    return copyWith(
      seen: seen.intersection(live),
      closed: closed.intersection(live),
      dismissed: dismissed.intersection(live),
    );
  }
}

/// Decides what is shown where. Pure, so every rule is unit-tested.
abstract final class FeedRules {
  /// A fresh install sees no Home card on its first day.
  static const homeGrace = Duration(days: 1);

  /// Inbox entries: targeted at this install and not dismissed, urgent
  /// first, otherwise in feed order (newest at the top of the file).
  static List<FeedItem> inbox(
    List<FeedItem> items,
    FeedAudience audience,
    DateTime now,
    FeedMemory memory, {
    bool preview = false,
  }) {
    final visible = [
      for (final item in items)
        if (item.targets(audience, now, preview: preview) &&
            (preview || !memory.dismissed.contains(item.id)))
          item,
    ];
    return [
      ...visible.where((i) => i.urgent),
      ...visible.where((i) => !i.urgent),
    ];
  }

  /// One Home card at a time, taken from the queue in feed order: urgent
  /// entries until closed, then unseen `home: true` entries while "Show on
  /// Home" is on. Closing a card brings up the next one straight away, so
  /// every queued entry is shown once; a fresh install waits a day.
  static FeedItem? homeCard(
    List<FeedItem> inbox,
    DateTime now,
    FeedMemory memory, {
    required bool enabled,
    bool preview = false,
  }) {
    for (final item in inbox) {
      if (memory.closed.contains(item.id) && !preview) continue;
      if (item.urgent) return item;
      if (!item.home) continue;
      if (preview) return item;
      if (!enabled || memory.seen.contains(item.id)) continue;
      final first = memory.firstRun;
      if (first == null || now.difference(first) < homeGrace) return null;
      return item;
    }
    return null;
  }

  static FeedMemory markSeen(FeedMemory memory, List<FeedItem> inbox,
          {String? update}) =>
      memory.copyWith(
        seen: {...memory.seen, ...inbox.map((i) => i.id)},
        seenUpdate: update,
      );

  static FeedMemory closeHomeCard(FeedMemory memory, FeedItem item) =>
      memory.copyWith(
        closed: {...memory.closed, item.id},
        seen: {...memory.seen, item.id},
      );

  static FeedMemory dismiss(FeedMemory memory, FeedItem item) =>
      memory.copyWith(
        dismissed: {...memory.dismissed, item.id},
        seen: {...memory.seen, item.id},
      );
}
