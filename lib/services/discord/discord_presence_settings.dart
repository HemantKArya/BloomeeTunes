import 'dart:convert';

import 'package:Bloomee/src/rust/api/discord.dart';

/// What to do with the presence while playback is paused.
enum DiscordPausedBehavior {
  /// Keep the card, with a "Paused" badge and no time bar.
  keep,

  /// Keep it for a few minutes, then clear (like Spotify).
  hideAfterDelay,

  /// Clear as soon as playback pauses.
  hide,
}

/// User-facing Discord Rich Presence preferences, persisted as one JSON
/// string under `SettingKeys.discordPresence`.
class DiscordPresenceSettings {
  final bool enabled;

  /// What shows next to your name: app name, song title or artist.
  final DiscordStatusDisplay statusDisplay;
  final DiscordPausedBehavior whenPaused;
  final bool showArtwork;
  final bool showProgress;

  /// Song title / artist / album open their source pages when clicked.
  final bool showLinks;

  /// Publish tracks from the local library (file tags) too.
  final bool shareLocalFiles;

  const DiscordPresenceSettings({
    this.enabled = true,
    this.statusDisplay = DiscordStatusDisplay.appName,
    this.whenPaused = DiscordPausedBehavior.hideAfterDelay,
    this.showArtwork = true,
    this.showProgress = true,
    this.showLinks = true,
    this.shareLocalFiles = true,
  });

  static const defaults = DiscordPresenceSettings();

  DiscordPresenceSettings copyWith({
    bool? enabled,
    DiscordStatusDisplay? statusDisplay,
    DiscordPausedBehavior? whenPaused,
    bool? showArtwork,
    bool? showProgress,
    bool? showLinks,
    bool? shareLocalFiles,
  }) =>
      DiscordPresenceSettings(
        enabled: enabled ?? this.enabled,
        statusDisplay: statusDisplay ?? this.statusDisplay,
        whenPaused: whenPaused ?? this.whenPaused,
        showArtwork: showArtwork ?? this.showArtwork,
        showProgress: showProgress ?? this.showProgress,
        showLinks: showLinks ?? this.showLinks,
        shareLocalFiles: shareLocalFiles ?? this.shareLocalFiles,
      );

  String toJson() => jsonEncode({
        'enabled': enabled,
        'statusDisplay': statusDisplay.name,
        'whenPaused': whenPaused.name,
        'showArtwork': showArtwork,
        'showProgress': showProgress,
        'showLinks': showLinks,
        'shareLocalFiles': shareLocalFiles,
      });

  /// Tolerant of missing/unknown fields so older or newer saved values
  /// never break startup.
  factory DiscordPresenceSettings.fromJson(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return defaults;
    }
    if (decoded is! Map) return defaults;
    bool flag(String key, bool fallback) =>
        decoded is Map && decoded[key] is bool ? decoded[key] as bool : fallback;
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = (decoded as Map)[key];
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return DiscordPresenceSettings(
      enabled: flag('enabled', defaults.enabled),
      statusDisplay: pick(
          DiscordStatusDisplay.values, 'statusDisplay', defaults.statusDisplay),
      whenPaused: pick(
          DiscordPausedBehavior.values, 'whenPaused', defaults.whenPaused),
      showArtwork: flag('showArtwork', defaults.showArtwork),
      showProgress: flag('showProgress', defaults.showProgress),
      showLinks: flag('showLinks', defaults.showLinks),
      shareLocalFiles: flag('shareLocalFiles', defaults.shareLocalFiles),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DiscordPresenceSettings &&
      enabled == other.enabled &&
      statusDisplay == other.statusDisplay &&
      whenPaused == other.whenPaused &&
      showArtwork == other.showArtwork &&
      showProgress == other.showProgress &&
      showLinks == other.showLinks &&
      shareLocalFiles == other.shareLocalFiles;

  @override
  int get hashCode => Object.hash(enabled, statusDisplay, whenPaused, showArtwork,
      showProgress, showLinks, shareLocalFiles);
}
