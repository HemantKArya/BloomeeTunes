import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

/// Owns the Discord Rich Presence IPC for the lifetime of the app.
///
/// ## Why `mp:<url>` works through the FFI binding
/// `dart_discord_rpc` is an FFI wrapper around the legacy `discord-rpc` C
/// SDK. The C library does **not** validate `largeImageKey` — it serializes
/// the field as-is into the JSON frame on Discord's local IPC socket. The
/// modern Discord IPC server interprets the `mp:` prefix in `large_image`
/// as "proxy this external URL", fetches it server-side, caches it on
/// Discord's CDN, and serves it from there. The string is opaque to the
/// client library, so the `mp:` form reaches Discord intact.
///
/// Requirements for `mp:` to work:
///   - HTTPS only
///   - ≤ 5 MB
///   - PNG / JPEG / WebP / GIF
///
/// ## Layout (Spotify-style)
///   - `details`     → track title (bold first line)
///   - `state`       → artist(s) (second line)
///   - `largeImageKey` / `largeImageText` → album art / album name
///   - `smallImageKey` / `smallImageText` → play/pause icon + label
///   - `startTimeStamp` + `endTimeStamp` → time bar (only when playing)
///
/// The "Playing" / "Paused" badge at the top of the activity is automatic
/// — Discord derives it from whether `endTimeStamp` is set, so we never
/// prefix the state text with "Paused ・".
class DiscordService {
  static DiscordRPC? _discordRPC;

  /// Currently rendered track id. A change here resets the start anchor.
  static String? _activeTrackId;

  /// Epoch seconds when the current track started playing.
  static int? _trackStartEpochSec;

  /// Equality cache for the last frame we shipped to Discord. Skips the
  /// IPC round-trip when nothing visible changed.
  static _LastSent? _lastSent;

  /// Initializes Discord RPC once.
  static void initialize() {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    if (_discordRPC != null) return;
    try {
      DiscordRPC.initialize();
      _discordRPC = DiscordRPC(applicationId: '1512528534667661443');
      _discordRPC?.start(autoRegister: true);
      log('Discord RPC initialized', name: 'DiscordService');
    } catch (e) {
      log('Discord RPC init failed: $e', name: 'DiscordService');
    }
  }

  /// Updates the Discord presence for [track].
  ///
  /// [isPlaying] toggles the time bar (Discord only renders it when both
  /// `startTimeStamp` and `endTimeStamp` are set). [position] is the
  /// current playback position; [duration] is the total track length.
  static void updatePresence({
    required Track track,
    required bool isPlaying,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
  }) {
    final rpc = _discordRPC;
    if (rpc == null || isTrackNull(track)) return;

    try {
      // ── Track change → reset start anchor, force IPC send ─────────────
      if (_activeTrackId != track.id) {
        _activeTrackId = track.id;
        _trackStartEpochSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _lastSent = null;
      }

      final artistStr = track.artists.isNotEmpty
          ? track.artists.map((a) => a.name).join(', ')
          : 'Unknown Artist';

      // Spotify-style: details = title, state = artist. No "Paused" prefix
      // — Discord shows the play/pause state via the small image and via
      // the presence/absence of endTimeStamp.
      final details = track.title;
      final state = artistStr;

      // ── Timestamps ─────────────────────────────────────────────────────
      // Time bar only renders when BOTH start and end are set. Omit
      // endTimeStamp on pause so the bar disappears entirely.
      final startTs = _trackStartEpochSec;
      int? endTs;
      if (isPlaying && duration > Duration.zero && position >= Duration.zero) {
        final remaining = duration - position;
        if (remaining > Duration.zero) {
          endTs = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
              remaining.inSeconds;
        }
      }

      // ── Per-track album art via Discord's media proxy ─────────────────
      // `mp:<https-url>` tells Discord's IPC server to fetch the image
      // itself, cache it on its CDN, and serve it as the large image.
      // The FFI binding just forwards the string verbatim.
      final cover = _bestCover(track);
      final largeImageKey = cover == null ? null : 'mp:$cover';
      final largeImageText = track.album?.title ?? track.title;

      // ── Play/pause small image ────────────────────────────────────────
      // Asset keys 'play' and 'pause' must be uploaded in the Discord
      // Developer Portal under Rich Presence → Art Assets. If missing,
      // Discord simply omits the small image — no error. We only attach
      // the small image when there is a large image, otherwise the small
      // image has nowhere to render.
      final smallImageKey =
          largeImageKey == null ? null : (isPlaying ? 'play' : 'pause');
      final smallImageText = isPlaying ? 'Playing' : 'Paused';

      final candidate = _LastSent(
        details: details,
        state: state,
        isPlaying: isPlaying,
        startTs: startTs,
        endTs: endTs,
        largeImageKey: largeImageKey,
        largeImageText: largeImageText,
        smallImageKey: smallImageKey,
        smallImageText: smallImageText,
      );
      if (_lastSent != null && _lastSent! == candidate) return;
      _lastSent = candidate;

      rpc.updatePresence(
        DiscordPresence(
          details: candidate.details,
          state: candidate.state,
          startTimeStamp: candidate.startTs,
          endTimeStamp: candidate.endTs,
          largeImageKey: candidate.largeImageKey,
          largeImageText: candidate.largeImageText,
          smallImageKey: candidate.smallImageKey,
          smallImageText: candidate.smallImageText,
        ),
      );
    } catch (e) {
      log('Discord RPC error: $e', name: 'DiscordService');
    }
  }

  /// Picks the best available cover URL for the track, or null.
  /// Prefers high-res → standard → low-res. Requires HTTPS (mp: rejects
  /// plain http://).
  static String? _bestCover(Track track) {
    final t = track.thumbnail;
    String? pick = (t.urlHigh != null && t.urlHigh!.isNotEmpty)
        ? t.urlHigh
        : (t.url.isNotEmpty ? t.url : null);
    pick ??= (t.urlLow != null && t.urlLow!.isNotEmpty) ? t.urlLow : null;
    if (pick == null) return null;
    if (!pick.startsWith('https://')) return null;
    return pick;
  }

  /// Clears Discord presence.
  static void clearPresence() {
    _activeTrackId = null;
    _trackStartEpochSec = null;
    _lastSent = null;
    final rpc = _discordRPC;
    if (rpc == null) return;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    try {
      rpc.clearPresence();
    } catch (e) {
      log('Discord clearPresence failed: $e', name: 'DiscordService');
    }
  }
}

/// Fields whose values actually affect what Discord renders. Anything not
/// in this struct is intentionally ignored so we don't churn the IPC
/// channel on cosmetic no-op updates.
class _LastSent {
  final String? details;
  final String? state;
  final bool isPlaying;
  final int? startTs;
  final int? endTs;
  final String? largeImageKey;
  final String? largeImageText;
  final String? smallImageKey;
  final String? smallImageText;

  const _LastSent({
    required this.details,
    required this.state,
    required this.isPlaying,
    required this.startTs,
    required this.endTs,
    required this.largeImageKey,
    required this.largeImageText,
    required this.smallImageKey,
    required this.smallImageText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LastSent &&
          details == other.details &&
          state == other.state &&
          isPlaying == other.isPlaying &&
          startTs == other.startTs &&
          endTs == other.endTs &&
          largeImageKey == other.largeImageKey &&
          largeImageText == other.largeImageText &&
          smallImageKey == other.smallImageKey &&
          smallImageText == other.smallImageText;

  @override
  int get hashCode => Object.hash(
        details,
        state,
        isPlaying,
        startTs,
        endTs,
        largeImageKey,
        largeImageText,
        smallImageKey,
        smallImageText,
      );
}
