import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/discord/discord_presence_settings.dart';
import 'package:Bloomee/src/rust/api/discord.dart';
import 'package:flutter/foundation.dart';

export 'package:Bloomee/services/discord/discord_presence_settings.dart';

/// Discord Rich Presence front-end.
///
/// The connection, rate limiting, reconnects and field validation all live
/// on a dedicated Rust thread (`rust/src/discord_rpc`); every call here is a
/// non-blocking push. This class only maps the current track + settings to
/// an activity and skips calls that would not change what Discord shows, so
/// the 1 Hz playback ticks cost nothing while a song plays normally.
class DiscordService {
  DiscordService._();

  static const _clientId = '1512528534667661443';
  static const _repoUrl = 'https://github.com/HemantKArya/BloomeeTunes';
  static const pauseGrace = Duration(minutes: 5);

  /// Seek / resume larger than this re-anchors Discord's time bar.
  static const _anchorSlackMs = 1500;

  static bool get isSupported =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Current preferences; the settings screen listens to this.
  static final settings =
      ValueNotifier<DiscordPresenceSettings>(DiscordPresenceSettings.defaults);

  /// Live connection status from the Rust worker (null until first event).
  static final status = ValueNotifier<DiscordStatus?>(null);

  static SettingsDAO? _dao;
  static StreamSubscription<DiscordStatus>? _statusSub;
  static bool _running = false;

  static Track? _track;
  static bool _playing = false;
  static Duration _position = Duration.zero;
  static Duration _duration = Duration.zero;
  static DateTime? _pausedAt;
  static Timer? _pauseTimer;

  /// Identity of the last activity pushed, plus its time-bar anchor.
  static String? _lastKey;
  static int? _lastAnchorMs;

  static Future<void> initialize() async {
    if (!isSupported || _dao != null) return;
    _dao = SettingsDAO(DBProvider.db);
    try {
      final raw = await _dao!.getSettingStr(SettingKeys.discordPresence);
      if (raw != null) settings.value = DiscordPresenceSettings.fromJson(raw);
    } catch (e) {
      log('Discord settings load failed: $e', name: 'DiscordService');
    }
    try {
      _statusSub ??= discordStatusStream().listen(
        (s) => status.value = s,
        onError: (Object e) =>
            log('Discord status stream: $e', name: 'DiscordService'),
      );
    } catch (e) {
      log('Discord status stream failed: $e', name: 'DiscordService');
    }
    _apply();
  }

  static Future<void> updateSettings(DiscordPresenceSettings next) async {
    if (next == settings.value) return;
    settings.value = next;
    _apply();
    try {
      await _dao?.putSettingStr(SettingKeys.discordPresence, next.toJson());
    } catch (e) {
      log('Discord settings save failed: $e', name: 'DiscordService');
    }
  }

  /// Drops the connection and reconnects immediately.
  static void reconnect() {
    if (_running) _guard(discordReconnect);
  }

  /// Called from the player on playback ticks; cheap when nothing changed.
  static void updatePresence({
    required Track track,
    required bool isPlaying,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
  }) {
    final changed = _track?.id != track.id || _playing != isPlaying;
    _track = track;
    _position = position;
    _duration = duration;
    if (changed) _setPlaying(isPlaying);
    if (_running) _publish();
  }

  static void clearPresence() {
    _track = null;
    _setPlaying(false);
    if (_running) _push(null, key: 'clear');
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  static void _apply() {
    if (!isSupported) return;
    final enabled = settings.value.enabled;
    if (enabled && !_running) {
      _running = _guard(() => discordStart(clientId: _clientId));
    } else if (!enabled && _running) {
      _guard(discordStop);
      _running = false;
      _lastKey = null;
      status.value = null;
      return;
    }
    _armPauseTimer();
    if (_running) _publish(force: true);
  }

  static void _setPlaying(bool playing) {
    _playing = playing;
    _pausedAt = playing ? null : DateTime.now();
    _armPauseTimer();
  }

  /// One timer per pause (never a poll) to clear after [pauseGrace].
  static void _armPauseTimer() {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    final since = _pausedAt;
    if (_playing ||
        since == null ||
        settings.value.whenPaused != DiscordPausedBehavior.hideAfterDelay) {
      return;
    }
    final left = pauseGrace - DateTime.now().difference(since);
    if (left <= Duration.zero) return;
    _pauseTimer = Timer(left, () {
      if (_running) _publish(force: true);
    });
  }

  static bool get _hiddenWhilePaused {
    if (_playing) return false;
    return switch (settings.value.whenPaused) {
      DiscordPausedBehavior.keep => false,
      DiscordPausedBehavior.hide => true,
      DiscordPausedBehavior.hideAfterDelay => _pausedAt != null &&
          DateTime.now().difference(_pausedAt!) >= pauseGrace,
    };
  }

  static void _publish({bool force = false}) {
    final track = _track;
    final s = settings.value;
    if (track == null ||
        isTrackNull(track) ||
        (!s.shareLocalFiles && isLocalMediaId(track.id)) ||
        _hiddenWhilePaused) {
      _push(null, key: 'clear', force: force);
      return;
    }

    final withBar = _playing && s.showProgress;
    final anchor = withBar
        ? DateTime.now().millisecondsSinceEpoch - _position.inMilliseconds
        : null;
    // Duration is part of the identity: the first tick of a new song often
    // arrives before its length is known, and the end time must follow.
    final key =
        '${track.id}|$_playing|${_duration.inSeconds}|${s.hashCode}';
    final sameAnchor = anchor == null
        ? _lastAnchorMs == null
        : _lastAnchorMs != null &&
            (anchor - _lastAnchorMs!).abs() <= _anchorSlackMs;
    if (!force && key == _lastKey && sameAnchor) return;
    _lastAnchorMs = anchor;
    _push(_buildActivity(track, s, withBar), key: key, force: true);
  }

  static void _push(DiscordActivity? activity,
      {required String key, bool force = false}) {
    if (!force && key == _lastKey) return;
    _lastKey = key;
    if (activity == null) _lastAnchorMs = null;
    _guard(() => discordSetActivity(activity: activity));
  }

  static DiscordActivity _buildActivity(
      Track track, DiscordPresenceSettings s, bool withBar) {
    final title = track.title.trim();
    final artists = artistLine(track.artists.map((a) => a.name),
        title: title, album: track.album?.title);
    final cover = s.showArtwork ? _cover(track) : null;
    final songUrl = _web(track.url);
    return DiscordActivity(
      // Always "Listening to Bloomee".
      kind: DiscordActivityKind.listening,
      statusDisplay: s.statusDisplay,
      details: title,
      detailsUrl: s.showLinks ? songUrl : null,
      state: artists,
      stateUrl: s.showLinks && track.artists.isNotEmpty
          ? _web(track.artists.first.url)
          : null,
      largeImage: cover,
      // Third line of the card: only a real album name, never a repeat.
      largeText: albumLine(
          title: title, album: track.album?.title, artists: artists),
      largeUrl: s.showLinks ? _web(track.album?.url) : null,
      // Asset keys uploaded in the Discord developer portal.
      smallImage: cover == null ? null : (_playing ? 'play' : 'pause'),
      smallText: _playing ? 'Playing' : 'Paused',
      progress: withBar
          ? DiscordProgress(
              positionMs: _ms(_position),
              durationMs: _duration > Duration.zero ? _ms(_duration) : null,
            )
          : null,
      // Discord shows buttons to friends only (never on your own profile).
      // The title already links to the song, so one button is enough.
      buttons: const [DiscordButton(label: getBloomeeLabel, url: _repoUrl)],
    );
  }

  static const getBloomeeLabel = 'Get Bloomee 🌸';

  /// Artist names for the second line. Some sources pad the artist list
  /// with the album or release year ("Artist, Album, 2025"); those, blanks
  /// and duplicates are dropped.
  static String? artistLine(
    Iterable<String> names, {
    String? title,
    String? album,
  }) {
    final skip = {
      if (title != null) _norm(title),
      if (album != null) _norm(album),
    }..remove('');
    final seen = <String>{};
    final unique = [
      for (final raw in names)
        if (raw.trim().isNotEmpty &&
            !_year.hasMatch(raw.trim()) &&
            !skip.contains(_norm(raw)) &&
            seen.add(raw.trim().toLowerCase()))
          raw.trim(),
    ];
    return unique.isEmpty ? null : unique.join(', ');
  }

  static final _year = RegExp(r'^\d{4}$');

  static String _norm(String v) => v
      .toLowerCase()
      .replaceAll(RegExp(r'\s*[-–(\[]\s*(single|ep)\s*[)\]]?\s*$'), '')
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');

  /// The album for the third line, or null when it would only repeat the
  /// title or artist (singles, "Title - Single", missing metadata).
  static String? albumLine({
    required String title,
    String? album,
    String? artists,
  }) {
    final a = album?.trim() ?? '';
    if (a.isEmpty) return null;
    final n = _norm(a);
    if (n.isEmpty || n == _norm(title)) return null;
    if (artists != null && n == _norm(artists)) return null;
    return a;
  }

  /// First https cover Discord's media proxy can fetch (≤ 256 chars).
  static String? _cover(Track track) {
    final t = track.thumbnail;
    for (final url in [t.urlHigh, t.url, t.urlLow]) {
      if (url != null && url.startsWith('https://') && url.length <= 256) {
        return url;
      }
    }
    return null;
  }

  static String? _web(String? url) =>
      url != null && (url.startsWith('https://') || url.startsWith('http://'))
          ? url
          : null;

  static int _ms(Duration d) => d.inMilliseconds.clamp(0, 0xFFFFFFFF);

  static bool _guard(void Function() call) {
    try {
      call();
      return true;
    } catch (e) {
      log('Discord RPC call failed: $e', name: 'DiscordService');
      return false;
    }
  }
}
