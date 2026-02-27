import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';

/// Tracks continuous playback of the current media item and pushes it to
/// the Recently Played DB only when the item has been played continuously
/// for at least [_thresholdSeconds]. Default threshold is 15 seconds.
class RecentlyPlayedTracker {
  final PlayerEngine _engine;
  final MediaItem? Function() _getCurrentMediaItem;

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
    this._getCurrentMediaItem, {
    int thresholdSeconds = 15,
    double percentThreshold = 0.4,
  })  : _thresholdSeconds = thresholdSeconds,
        _percentThreshold = percentThreshold {
    _stateSub = _engine.stateStream.listen(_onEngineState);
    _positionSub = _engine.positionStream.listen(_onPosition);
  }

  void _onEngineState(EngineState state) {
    final isPlaying = _engine.playing;
    final media = _getCurrentMediaItem();
    final mediaId = media?.id;

    if (isPlaying && state == EngineState.ready) {
      if (media == null) return;
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

  void _onPosition(Duration position) {
    if (_trackingMediaId == null || _recordedForCurrent) return;

    final media = _getCurrentMediaItem();
    if (media == null || media.id != _trackingMediaId) {
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
    final bool reachedPercentThreshold = media.duration != null
        ? currMs >= (media.duration!.inMilliseconds * _percentThreshold)
        : false;

    if (reachedTimeThreshold || reachedPercentThreshold) {
      try {
        final dbItem = mediaItemToMediaItemDB(media);
        final playlistDao = PlaylistDAO(DBProvider.db);
        HistoryDAO(DBProvider.db).putRecentlyPlayed(
          dbItem,
          addMediaItem: playlistDao.addMediaItem,
        );
        _recordedForCurrent = true;
      } catch (_) {
        // Do not crash the tracker on DB failures; ignore silently.
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
