import 'dart:async';

/// Pure play-time logic: decides when a listen counts as a scrobble.
///
/// Event driven (no polling): feed it [update] whenever the current track or
/// playing state may have changed, and [onCompleted] when a track finishes.
/// A single timer fires when the threshold is reached.
class PlaybackSessionTracker<T> {
  PlaybackSessionTracker({
    required this.keyOf,
    required this.durationSecOf,
    required this.onNowPlaying,
    required this.onScrobble,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Stable identity of a track ('' = no track).
  final String Function(T) keyOf;
  final int Function(T) durationSecOf;
  final void Function(T track) onNowPlaying;
  final void Function(T track, int startedAtSec) onScrobble;
  final DateTime Function() _now;

  T? _track;
  String _key = '';
  bool _playing = false;
  bool _scrobbled = false;
  int _startedAt = 0;
  Duration _accum = Duration.zero;
  DateTime? _runStart;
  Timer? _timer;

  Duration get elapsed =>
      _accum + (_runStart == null ? Duration.zero : _now().difference(_runStart!));

  /// Seconds of play needed: >30s tracks, half the length or 4 min.
  /// Unknown duration: 30s.
  static int? thresholdSec(int durationSec) {
    if (durationSec <= 0) return 30;
    if (durationSec <= 30) return null; // never scrobbles
    return (durationSec / 2).ceil().clamp(1, 240);
  }

  void update({required T? track, required bool playing}) {
    final key = track == null ? '' : keyOf(track);
    if (key != _key) {
      _endSession();
      _track = track;
      _key = key;
      if (key.isNotEmpty) onNowPlaying(track as T);
    }
    if (key.isEmpty) return;
    _setPlaying(playing);
  }

  /// Track reached its end (also covers repeat-one replays).
  void onCompleted() {
    if (_key.isEmpty) return;
    _checkNow();
    _endSession(keepTrack: true);
  }

  void _setPlaying(bool playing) {
    if (playing == _playing) return;
    _playing = playing;
    if (playing) {
      _runStart = _now();
      if (_startedAt == 0) _startedAt = _now().millisecondsSinceEpoch ~/ 1000;
      _arm();
    } else {
      _accum = elapsed;
      _runStart = null;
      _timer?.cancel();
    }
  }

  void _arm() {
    _timer?.cancel();
    if (_scrobbled || _track == null) return;
    final need = thresholdSec(durationSecOf(_track as T));
    if (need == null) return;
    final remaining = Duration(seconds: need) - elapsed;
    _timer = Timer(remaining.isNegative ? Duration.zero : remaining, _checkNow);
  }

  void _checkNow() {
    if (_scrobbled || _track == null) return;
    final need = thresholdSec(durationSecOf(_track as T));
    if (need != null && elapsed.inSeconds >= need) {
      _scrobbled = true;
      onScrobble(_track as T, _startedAt);
    }
  }

  void _endSession({bool keepTrack = false}) {
    _checkNow();
    _timer?.cancel();
    _accum = Duration.zero;
    _runStart = null;
    _playing = false;
    _scrobbled = false;
    _startedAt = 0;
    if (!keepTrack) {
      _track = null;
      _key = '';
    }
  }

  void dispose() => _timer?.cancel();
}
