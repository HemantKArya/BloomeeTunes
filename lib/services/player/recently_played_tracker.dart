import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/model/songModel.dart';

/// Tracks continuous playback of the current media item and pushes it to
/// the Recently Played DB only when the item has been played continuously
/// for at least [thresholdSeconds]. Default threshold is 15 seconds.
class RecentlyPlayedTracker {
  final AudioPlayer _audioPlayer;
  final MediaItem? Function() _getCurrentMediaItem;

  int _thresholdSeconds;
  double _percentThreshold;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;

  // Tracking state
  String? _trackingMediaId;
  int? _startPositionMs;
  bool _recordedForCurrent = false;
  int? _lastPositionMs;
  int? _lastPositionTimestampMs;

  RecentlyPlayedTracker(
    this._audioPlayer,
    this._getCurrentMediaItem, {
    int thresholdSeconds = 15,
    double percentThreshold = 0.4,
  })  : _thresholdSeconds = thresholdSeconds,
        _percentThreshold = percentThreshold {
    // Subscribe to player state and position streams
    _playerStateSub = _audioPlayer.playerStateStream.listen(_onPlayerState);
    _positionSub = _audioPlayer.positionStream.listen(_onPosition);
  }

  void _onPlayerState(PlayerState state) {
    final isPlaying = state.playing;
    final media = _getCurrentMediaItem();
    final mediaId = media?.id;

    if (isPlaying) {
      if (media == null) return;
      // If a new media started playing, reset tracking
      if (_trackingMediaId != mediaId) {
        _trackingMediaId = mediaId;
        _recordedForCurrent = false;
        _startPositionMs = _audioPlayer.position.inMilliseconds;
        _lastPositionMs = _startPositionMs;
        _lastPositionTimestampMs = DateTime.now().millisecondsSinceEpoch;
      }
      // If resuming the same media without seeking/skip, we continue from
      // the current position; _startPositionMs remains set at first play.
    } else {
      // Pause/stop/complete - break continuity
      _trackingMediaId = null;
      _startPositionMs = null;
      _lastPositionMs = null;
      _lastPositionTimestampMs = null;
    }
  }

  void _onPosition(Duration position) {
    if (_trackingMediaId == null || _recordedForCurrent) return;

    final media = _getCurrentMediaItem();
    if (media == null || media.id != _trackingMediaId) {
      // Media changed while tracking; reset
      _trackingMediaId = null;
      _startPositionMs = null;
      return;
    }

    // If position moved backward (seek back) reset continuity start
    final currMs = position.inMilliseconds;
    final startMs = _startPositionMs ?? currMs;
    if (currMs < startMs) {
      // backward seek -> reset continuity
      _startPositionMs = currMs;
      _lastPositionMs = currMs;
      _lastPositionTimestampMs = DateTime.now().millisecondsSinceEpoch;
      return;
    }

    // Detect forward seek/jump: if position advanced much more than wall-clock
    // time (allow small tolerance), treat as a seek and reset continuity start.
    final nowTs = DateTime.now().millisecondsSinceEpoch;
    if (_lastPositionMs != null && _lastPositionTimestampMs != null) {
      final posDelta = currMs - _lastPositionMs!;
      final timeDelta = nowTs - _lastPositionTimestampMs!;
      // expected posDelta ~ timeDelta (playback speed 1). Allow tolerance of
      // 1s + small buffer. If posDelta significantly exceeds timeDelta + 1000ms,
      // we assume a forward seek/skip occurred.
      if (posDelta > timeDelta + 1000) {
        // forward seek occurred: reset continuity start to current position
        _startPositionMs = currMs;
        _lastPositionMs = currMs;
        _lastPositionTimestampMs = nowTs;
        return;
      }
    }
    // update last seen position/time for next sample
    _lastPositionMs = currMs;
    _lastPositionTimestampMs = nowTs;

    final elapsedMs = currMs - startMs;

    final bool reachedTimeThreshold = elapsedMs >= _thresholdSeconds * 1000;
    final bool reachedPercentThreshold = media.duration != null
        ? currMs >= (media.duration!.inMilliseconds * _percentThreshold)
        : false;

    if (reachedTimeThreshold || reachedPercentThreshold) {
      // Threshold reached: push to DB and mark recorded to avoid duplicates
      try {
        final dbItem = MediaItem2MediaItemDB(media);
        BloomeeDBService.putRecentlyPlayed(dbItem);
        _recordedForCurrent = true;
      } catch (_) {
        // Do not crash the tracker on DB failures; ignore silently.
      }
    }
  }

  /// Change the required continuous threshold (seconds). Must be > 0.
  void setThresholdSeconds(int seconds) {
    if (seconds <= 0) return;
    _thresholdSeconds = seconds;
  }

  /// Set the required percent (0..1) of the track that must be played to
  /// count as played. Example: 0.4 for 40%.
  void setPercentThreshold(double percent) {
    if (percent <= 0 || percent > 1) return;
    _percentThreshold = percent;
  }

  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
  }
}
