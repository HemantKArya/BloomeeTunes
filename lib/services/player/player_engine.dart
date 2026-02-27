import 'dart:async';
import 'dart:developer';

import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';

// ─── Public Types ────────────────────────────────────────────────────────────

/// Playback lifecycle state.
enum EngineState { idle, loading, buffering, ready, completed, error }

/// Loop mode.
enum LoopMode { off, one, all }

/// A single equalizer frequency band.
class EqualizerBand {
  final double centerFrequency;
  double gain; // dB, range -12..+12

  EqualizerBand(this.centerFrequency, {this.gain = 0.0});
}

// ─── PlayerEngine ────────────────────────────────────────────────────────────

/// Low-level audio engine wrapping media_kit [Player].
///
/// Features:
/// - Dual-player for cross-fade transitions
/// - 10-band parametric equalizer via FFmpeg `equalizer` filter (lavfi bridge)
/// - Gapless playback via URI pre-resolution
/// - Clean reactive stream API
///
/// Non-responsibilities:
/// Queue management, track metadata, OS notifications — those are handled by
/// [BloomeeMusicPlayer] and [QueueManager].
class PlayerEngine {
  // ── Dual players for cross-fade ──
  late Player _playerA;
  late Player _playerB;
  bool _aIsActive = true;
  bool _disposed = false;

  Player get _active => _aIsActive ? _playerA : _playerB;
  Player get _standby => _aIsActive ? _playerB : _playerA;

  // ── Cross-fade ──
  Duration crossfadeDuration = Duration.zero;
  bool _isCrossfading = false;
  Completer<void>? _crossfadeCompleter; // Signals cancellation to running fade
  Completer<void>? _crossfadeDone; // Signals that fade cleanup is finished

  // ── Gapless pre-load ──
  Uri? _preloadedNextUri;
  bool _standbyPreloaded = false;

  // ── Loop tracking ──
  LoopMode _loopMode = LoopMode.off;

  // ── User volume (0..1) — preserved across cross-fade transitions ──
  double _userVolume = 1.0;

  // ── Media presence — used by _deriveState to avoid idle flicker ──
  bool _hasMedia = false;

  // ── Reactive subjects ──
  final BehaviorSubject<EngineState> _stateSubject =
      BehaviorSubject.seeded(EngineState.idle);
  final BehaviorSubject<bool> _playingSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<Duration> _positionSubject =
      BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<Duration> _durationSubject =
      BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<Duration> _bufferedSubject =
      BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<double> _volumeSubject = BehaviorSubject.seeded(1.0);
  final BehaviorSubject<double> _speedSubject = BehaviorSubject.seeded(1.0);

  final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  late final List<StreamSubscription> _subs;

  // ── Equalizer ──
  bool _eqEnabled = false;
  final List<EqualizerBand> _eqBands = [
    EqualizerBand(32),
    EqualizerBand(64),
    EqualizerBand(125),
    EqualizerBand(250),
    EqualizerBand(500),
    EqualizerBand(1000),
    EqualizerBand(2000),
    EqualizerBand(4000),
    EqualizerBand(8000),
    EqualizerBand(16000),
  ];

  // ────────────────────────────────────────────────────────────────────────────

  PlayerEngine() {
    _playerA = Player(
      configuration: const PlayerConfiguration(
        title: 'BloomeeTunes',
        bufferSize: 8 * 1024 * 1024,
      ),
    );
    _playerB = Player(
      configuration: const PlayerConfiguration(
        title: 'BloomeeTunes',
        bufferSize: 8 * 1024 * 1024,
      ),
    );
    _subs = [
      ..._subscribePlayer(_playerA, isA: true),
      ..._subscribePlayer(_playerB, isA: false),
    ];
  }

  /// Subscribe to a player's streams, forwarding only the active player's
  /// events to the public subjects.
  List<StreamSubscription> _subscribePlayer(Player player,
      {required bool isA}) {
    return [
      player.stream.playing.listen((playing) {
        if (_isActive(isA)) {
          _playingSubject.add(playing);
          _deriveState();
        }
      }),
      player.stream.position.listen((pos) {
        if (_isActive(isA)) _positionSubject.add(pos);
      }),
      player.stream.duration.listen((dur) {
        if (_isActive(isA)) _durationSubject.add(dur);
      }),
      player.stream.buffer.listen((buf) {
        if (_isActive(isA)) _bufferedSubject.add(buf);
      }),
      player.stream.buffering.listen((_) {
        if (_isActive(isA)) _deriveState();
      }),
      player.stream.completed.listen((completed) {
        if (_isActive(isA) && completed) {
          if (_loopMode == LoopMode.one) {
            player
                .seek(Duration.zero)
                .then((_) => player.play())
                .catchError((e) {
              log('Loop-one replay failed: $e', name: 'PlayerEngine');
              _stateSubject.add(EngineState.error);
              _errorController.add(e.toString());
            });
          } else {
            _stateSubject.add(EngineState.completed);
            _completionController.add(null);
          }
        }
      }),
      player.stream.volume.listen((v) {
        if (_isActive(isA) && !_isCrossfading) {
          _volumeSubject.add((v / 100.0).clamp(0.0, 1.0));
        }
      }),
      player.stream.error.listen((error) {
        if (_isActive(isA)) {
          log('Engine error: $error', name: 'PlayerEngine');
          _stateSubject.add(EngineState.error);
          _errorController.add(error);
        }
      }),
    ];
  }

  bool _isActive(bool isA) => isA == _aIsActive;

  // ─── Getters ───────────────────────────────────────────────────────────────

  EngineState get state => _stateSubject.value;
  bool get playing => _playingSubject.value;
  Duration get position => _positionSubject.value;
  Duration get duration => _durationSubject.value;
  Duration get buffered => _bufferedSubject.value;
  double get volume => _volumeSubject.value;
  double get speed => _speedSubject.value;
  LoopMode get loopMode => _loopMode;

  // ─── Streams ───────────────────────────────────────────────────────────────

  Stream<EngineState> get stateStream => _stateSubject.stream;
  Stream<bool> get playingStream => _playingSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<Duration> get bufferedStream => _bufferedSubject.stream;
  Stream<double> get volumeStream => _volumeSubject.stream;
  Stream<double> get speedStream => _speedSubject.stream;

  /// Fires when a track finishes naturally (not on manual stop/skip).
  Stream<void> get completionStream => _completionController.stream;

  /// Fires on playback errors from MPV.
  Stream<String> get errorStream => _errorController.stream;

  // ─── Playback Control ──────────────────────────────────────────────────────

  /// Manually set loading state (e.g. while resolving URI before actual open).
  void setLoadingState() {
    if (_disposed) return;
    _stateSubject.add(EngineState.loading);
    // Don't reset position/duration — keep showing last known values while
    // loading. Prevents seek bar from jumping to zero during track transition.
  }

  /// Open a URI and optionally start playback.
  /// Stops any currently playing audio first to prevent overlap.
  /// Cancels and awaits cleanup of any ongoing crossfade transition.
  Future<void> open(Uri uri, {bool autoPlay = true}) async {
    if (_disposed) return;

    // Signal cancellation and wait for the old crossfade to fully exit
    // before manipulating the players again — prevents the race condition
    // where both crossfades touch the same player concurrently.
    if (_crossfadeCompleter != null && !_crossfadeCompleter!.isCompleted) {
      _crossfadeCompleter!.complete();
      await _crossfadeDone?.future;
    }

    if (crossfadeDuration > Duration.zero && _active.state.playing) {
      await _crossfadeOpen(uri, autoPlay: autoPlay);
    } else {
      await _directOpen(uri, autoPlay: autoPlay);
    }
  }

  Future<void> _directOpen(Uri uri, {bool autoPlay = true}) async {
    _hasMedia = false;
    _stateSubject.add(EngineState.loading);
    // Don't reset position/duration here — let the player streams update them
    // naturally after open(). Resetting to zero breaks seek during loading.
    try {
      await _active.open(Media(uri.toString()), play: autoPlay);
      _hasMedia = true;
    } catch (e) {
      log('Failed to open: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
      // Consistent with crossfade: emit error on stream, do not rethrow
    }
  }

  Future<void> _crossfadeOpen(Uri uri, {bool autoPlay = true}) async {
    // Fresh completers for this crossfade run
    _crossfadeCompleter = Completer<void>();
    _crossfadeDone = Completer<void>();
    final cancellation = _crossfadeCompleter!;
    final done = _crossfadeDone!;

    _isCrossfading = true;
    _hasMedia = false;
    final oldPlayer = _active;
    final newPlayer = _standby;

    try {
      await newPlayer.setVolume(0);

      // Check if standby was preloaded with this URI
      if (_standbyPreloaded && _preloadedNextUri == uri) {
        // Standby already has the track buffered, just start playing
        if (autoPlay) await newPlayer.play();
        _standbyPreloaded = false;
        _preloadedNextUri = null;
      } else {
        await newPlayer.open(Media(uri.toString()), play: autoPlay);
      }

      _aIsActive = !_aIsActive;
      _hasMedia = true;
      _stateSubject.add(EngineState.ready);

      // Re-apply EQ to the new active player (MPV resets af on open)
      if (_eqEnabled) await _applyEqualizer();

      final targetVol = _userVolume * 100.0;
      const steps = 20;
      final totalMs = crossfadeDuration.inMilliseconds;
      // Use a Stopwatch so accumulated event-loop jitter is corrected each step
      final sw = Stopwatch()..start();

      for (int i = 1; i <= steps; i++) {
        if (_disposed || cancellation.isCompleted) break;

        // Sleep only the remaining time to hit the target timestamp
        final targetMs = (totalMs * i) ~/ steps;
        final sleepMs = targetMs - sw.elapsedMilliseconds;
        if (sleepMs > 0) {
          await Future.delayed(Duration(milliseconds: sleepMs));
        }

        if (_disposed || cancellation.isCompleted) break;

        // Use elapsed time for the actual progress — stays accurate under jitter
        final progress = (sw.elapsedMilliseconds / totalMs).clamp(0.0, 1.0);
        await Future.wait([
          oldPlayer.setVolume(targetVol * (1.0 - progress)),
          newPlayer.setVolume(targetVol * progress),
        ]);
      }

      // Ensure new player is at full volume regardless of cancellation
      await newPlayer.setVolume(targetVol);
      await oldPlayer.stop();
      // Reset old player volume for the next time it's used as standby
      await oldPlayer.setVolume(targetVol);
    } catch (e) {
      log('Cross-fade error: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
    } finally {
      _isCrossfading = false;
      done.complete(); // Signal that cleanup is truly finished
    }
  }

  /// Stop playback and reset to idle state.
  /// Cancels any ongoing crossfade and silences both players.
  Future<void> stop() async {
    if (_disposed) return;

    // Signal cancellation and wait for crossfade cleanup to finish
    if (_crossfadeCompleter != null && !_crossfadeCompleter!.isCompleted) {
      _crossfadeCompleter!.complete();
      await _crossfadeDone?.future;
    }
    _isCrossfading = false;
    _hasMedia = false;
    _standbyPreloaded = false;
    _preloadedNextUri = null;

    try {
      // Stop both players — standby may have audio from crossfade or preload
      await Future.wait([_playerA.stop(), _playerB.stop()]);
    } catch (e) {
      log('Stop error: $e', name: 'PlayerEngine');
    }
    _stateSubject.add(EngineState.idle);
    _playingSubject.add(false);
    _positionSubject.add(Duration.zero);
    _durationSubject.add(Duration.zero);
  }

  Future<void> play() async {
    if (_disposed) return;
    await _active.play();
  }

  Future<void> pause() async {
    if (_disposed) return;
    await _active.pause();
  }

  Future<void> seek(Duration position) async {
    if (_disposed) return;

    // Use player's actual duration for clamping, not our subject value which
    // might be stale during transitions. If duration is invalid/zero, skip seek
    // to prevent seeking to 0 when user is trying to seek during loading.
    final actualDuration = _active.state.duration;
    if (actualDuration <= Duration.zero) {
      log('Seek ignored: duration not ready', name: 'PlayerEngine');
      return;
    }

    final clamped = Duration(
      milliseconds:
          position.inMilliseconds.clamp(0, actualDuration.inMilliseconds),
    );
    await _active.seek(clamped);
  }

  Future<void> setVolume(double value) async {
    if (_disposed) return;
    _userVolume = value.clamp(0.0, 1.0);
    await _active.setVolume(_userVolume * 100.0);
    _volumeSubject.add(_userVolume);
  }

  Future<void> setSpeed(double speed) async {
    if (_disposed) return;
    await _active.setRate(speed);
    _speedSubject.add(speed);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    if (_disposed) return;
    _loopMode = mode;
    // Engine always uses PlaylistMode.none — loop-one is handled via the
    // completed listener, and LoopMode.all is honoured by the queue layer
    // (BloomeeMusicPlayer.skipToNext wraps around when loopMode == all).
    await _active.setPlaylistMode(PlaylistMode.none);
  }

  // ─── Gapless Pre-loading ───────────────────────────────────────────────────

  /// Actually prebuffer the next track by opening it in the standby player
  /// with play: false. This ensures near-instant transition.
  Future<void> preloadNext(Uri uri) async {
    if (_disposed || _isCrossfading) return;

    // Don't preload if already preloaded with same URI
    if (_standbyPreloaded && _preloadedNextUri == uri) return;

    try {
      // Set volume to 0 so it doesn't play audio if somehow it starts
      await _standby.setVolume(0);
      // Open but don't play - this buffers the content
      await _standby.open(Media(uri.toString()), play: false);
      _preloadedNextUri = uri;
      _standbyPreloaded = true;
      log('Preloaded next track: $uri', name: 'PlayerEngine');
    } catch (e) {
      log('Preload failed: $e', name: 'PlayerEngine');
      _preloadedNextUri = null;
      _standbyPreloaded = false;
    }
  }

  /// Release the preloaded standby track, freeing its 8 MB buffer.
  Future<void> clearPreload() async {
    _preloadedNextUri = null;
    _standbyPreloaded = false;
    if (!_isCrossfading) {
      try {
        await _standby.stop();
      } catch (_) {}
    }
  }

  Uri? get preloadedNextUri => _preloadedNextUri;
  bool get isPreloaded => _standbyPreloaded;

  // ─── Equalizer ─────────────────────────────────────────────────────────────

  List<EqualizerBand> get equalizerBands => List.unmodifiable(_eqBands);
  bool get equalizerEnabled => _eqEnabled;

  Future<void> setEqualizerEnabled(bool enabled) async {
    _eqEnabled = enabled;
    await _applyEqualizer();
  }

  Future<void> setEqualizerBandGain(int bandIndex, double gain) async {
    if (bandIndex < 0 || bandIndex >= _eqBands.length) return;
    _eqBands[bandIndex].gain = gain.clamp(-12.0, 12.0);
    if (_eqEnabled) await _applyEqualizer();
  }

  Future<void> resetEqualizer() async {
    for (final band in _eqBands) {
      band.gain = 0.0;
    }
    await _applyEqualizer();
  }

  Future<void> _applyEqualizer() async {
    if (_disposed) return;
    try {
      final filter = _eqEnabled ? _buildEqualizerFilter() : '';
      // Use NativePlayer.setProperty to set MPV's audio filter chain.
      // media_kit exposes NativePlayer via player.platform.
      final platformA = _playerA.platform;
      final platformB = _playerB.platform;
      if (platformA is NativePlayer) {
        await platformA.setProperty('af', filter);
      }
      if (platformB is NativePlayer) {
        await platformB.setProperty('af', filter);
      }
    } catch (e) {
      log('Equalizer apply error: $e', name: 'PlayerEngine');
    }
  }

  /// Build an FFmpeg equalizer filter chain via MPV's lavfi bridge.
  ///
  /// Uses the FFmpeg `equalizer` filter (parametric biquad) — one instance per
  /// band with an octave bandwidth. This is available in all standard ffmpeg
  /// builds shipped with media_kit.
  String _buildEqualizerFilter() {
    final parts = <String>[];
    for (final band in _eqBands) {
      if (band.gain.abs() < 0.1) continue; // Skip near-zero bands
      // f=frequency, t=o (octave width type), w=1 (one octave), g=gain in dB
      parts.add('equalizer=f=${band.centerFrequency}:t=o:w=1:g=${band.gain}');
    }
    if (parts.isEmpty) return '';
    return 'lavfi=[${parts.join(',')}]';
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _deriveState() {
    if (_disposed) return;
    final player = _active;
    if (player.state.buffering) {
      _stateSubject.add(EngineState.buffering);
    } else if (player.state.completed) {
      // Handled by completion listener.
    } else if (_hasMedia) {
      // Media is open — report ready regardless of position/duration being zero
      // yet. This prevents the loading→idle flicker that occurred when a newly
      // opened track had both position and duration at zero momentarily.
      _stateSubject.add(EngineState.ready);
    } else if (_stateSubject.value == EngineState.loading) {
      // Keep loading until _hasMedia is set.
    } else {
      _stateSubject.add(EngineState.idle);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true; // Set early — guards all async paths below

    // Cancel any crossfade in progress before tearing down
    if (_crossfadeCompleter != null && !_crossfadeCompleter!.isCompleted) {
      _crossfadeCompleter!.complete();
      await _crossfadeDone?.future;
    }

    for (final sub in _subs) {
      await sub.cancel();
    }
    await Future.wait([_playerA.dispose(), _playerB.dispose()]);
    await _stateSubject.close();
    await _playingSubject.close();
    await _positionSubject.close();
    await _durationSubject.close();
    await _bufferedSubject.close();
    await _volumeSubject.close();
    await _speedSubject.close();
    await _completionController.close();
    await _errorController.close();
  }
}
