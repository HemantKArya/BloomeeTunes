import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';

/// Tracks continuous playback of the current track and pushes it to
/// the playback history DB only when the item has been played continuously
/// for at least [_thresholdSeconds]. Default threshold is 15 seconds.
class RecentlyPlayedTracker {
  final PlayerEngine _engine;
  final Track? Function() _getCurrentTrack;

  int _thresholdSeconds;
  double _percentThreshold;
  StreamSubscription<EngineState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;

  // Tracking state
  String? _trackingMediaId;
  int? _startPositionMs;
  bool _recordedForCurrent = false;
  int? _lastPositionMs;
  int? _lastPositionTimestampMs;

  RecentlyPlayedTracker(
    this._engine,
    this._getCurrentTrack, {
    int thresholdSeconds = 15,
    double percentThreshold = 0.4,
  })  : _thresholdSeconds = thresholdSeconds,
        _percentThreshold = percentThreshold {
    _stateSub = _engine.stateStream.listen(_onEngineState);
    _positionSub = _engine.positionStream.listen(_onPosition);
  }

  void _onEngineState(EngineState state) {
    final isPlaying = _engine.playing;
    final track = _getCurrentTrack();
    final mediaId = track?.id;

    if (isPlaying && state == EngineState.ready) {
      if (track == null) return;
      if (_trackingMediaId != mediaId) {
        _trackingMediaId = mediaId;
        _recordedForCurrent = false;
        _startPositionMs = _engine.position.inMilliseconds;
        _lastPositionMs = _startPositionMs;
        _lastPositionTimestampMs = DateTime.now().millisecondsSinceEpoch;
      }
    } else if (state == EngineState.idle ||
        state == EngineState.completed ||
        state == EngineState.error) {
      _trackingMediaId = null;
      _startPositionMs = null;
      _lastPositionMs = null;
      _lastPositionTimestampMs = null;
    }
  }

  Future<void> _onPosition(Duration position) async {
    if (_trackingMediaId == null || _recordedForCurrent) return;

    final track = _getCurrentTrack();
    if (track == null || track.id != _trackingMediaId) {
      _trackingMediaId = null;
      _startPositionMs = null;
      return;
    }

    final currMs = position.inMilliseconds;
    final startMs = _startPositionMs ?? currMs;
    if (currMs < startMs) {
      _startPositionMs = currMs;
      _lastPositionMs = currMs;
      _lastPositionTimestampMs = DateTime.now().millisecondsSinceEpoch;
      return;
    }

    final nowTs = DateTime.now().millisecondsSinceEpoch;
    if (_lastPositionMs != null && _lastPositionTimestampMs != null) {
      final posDelta = currMs - _lastPositionMs!;
      final timeDelta = nowTs - _lastPositionTimestampMs!;
      if (posDelta > timeDelta + 1000) {
        _startPositionMs = currMs;
        _lastPositionMs = currMs;
        _lastPositionTimestampMs = nowTs;
        return;
      }
    }
    _lastPositionMs = currMs;
    _lastPositionTimestampMs = nowTs;

    final elapsedMs = currMs - startMs;

    final bool reachedTimeThreshold = elapsedMs >= _thresholdSeconds * 1000;
    final durationMs = track.durationMs?.toInt();
    final bool reachedPercentThreshold =
        durationMs != null ? currMs >= (durationMs * _percentThreshold) : false;

    if (reachedTimeThreshold || reachedPercentThreshold) {
      _recordedForCurrent = true;
      try {
        final trackDao = TrackDAO(DBProvider.db);
        final historyDao = HistoryDAO(DBProvider.db, trackDao);
        await historyDao.recordPlay(track);
        log('Tracked play for ${track.id}', name: 'RecentlyPlayedTracker');
      } catch (e) {
        log('Failed to record play: $e', name: 'RecentlyPlayedTracker');
      }
    }
  }

  void setThresholdSeconds(int seconds) {
    if (seconds <= 0) return;
    _thresholdSeconds = seconds;
  }

  void setPercentThreshold(double percent) {
    if (percent <= 0 || percent > 1) return;
    _percentThreshold = percent;
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _positionSub?.cancel();
  }
}
