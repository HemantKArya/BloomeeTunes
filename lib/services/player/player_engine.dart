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

  // ── Transition tracking ──
  // Monotonic generation counter. Incremented by stop() and every transition
  // method (openDirect, activatePreloaded, crossfadeToPreloaded, fadeOutActive).
  // Running loops compare their captured generation to the current value;
  // a mismatch means "a newer transition started — abort immediately".
  int _generation = 0;
  bool _isTransitioning = false; // suppresses volume stream during fade/xfade

  // ── Gapless pre-load ──
  Uri? _preloadedNextUri;
  bool _standbyPreloaded = false;

  // ── Loop tracking ──
  LoopMode _loopMode = LoopMode.off;

  // ── User volume (0..1) — preserved across cross-fade transitions ──
  double _userVolume = 1.0;
  double _playerAVolume = 100.0;
  double _playerBVolume = 100.0;

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
        if (isA) {
          _playerAVolume = v;
        } else {
          _playerBVolume = v;
        }
        if (_isActive(isA) && !_isTransitioning) {
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
  }

  // ─── Transition Primitives ─────────────────────────────────────────────────
  //
  // The orchestrator (BloomeeMusicPlayer) implements the skip decision tree
  // and calls these deterministic building blocks. Every transition method:
  //   1. Increments _generation → aborts any previous running loop
  //   2. Does exactly ONE thing
  //   3. Completes fully — no fire-and-forget background work

  /// Open a URI on the active player (direct open, no crossfade).
  Future<void> openDirect(Uri uri, {bool autoPlay = true}) async {
    if (_disposed) return;
    _generation++;
    _isTransitioning = false;
    _hasMedia = false;
    _stateSubject.add(EngineState.loading);
    try {
      await _active.open(Media(uri.toString()), play: autoPlay);
      _hasMedia = true;
      if (_eqEnabled) await _applyEqualizer();
    } catch (e) {
      log('Failed to open: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
    }
  }

  /// Activate the preloaded standby player as the new active.
  /// Swaps active/standby, sets correct volume, starts playback.
  /// Only valid when [isPreloaded] is true.
  Future<void> activatePreloaded({bool autoPlay = true}) async {
    if (_disposed || !_standbyPreloaded) return;
    _generation++;
    _isTransitioning = false;

    final oldPlayer = _active;
    final newPlayer = _standby;

    // Swap so stream subscriptions route to the correct player
    _aIsActive = !_aIsActive;
    _standbyPreloaded = false;
    _preloadedNextUri = null;
    _hasMedia = true;

    // Stop old, set volume, play new
    try {
      await oldPlayer.stop();
    } catch (_) {}
    await newPlayer.setVolume(_userVolume * 100.0);
    if (autoPlay) await newPlayer.play();

    _stateSubject.add(EngineState.ready);
    if (_eqEnabled) await _applyEqualizer();
  }

  /// Crossfade from active (old) to preloaded standby (new) over [duration].
  /// Increments [_generation]; any previous loop aborts on mismatch.
  /// After crossfade, old player is stopped and roles are swapped.
  Future<void> crossfadeToPreloaded(Duration duration) async {
    if (_disposed || !_standbyPreloaded) return;

    final gen = ++_generation;
    _isTransitioning = true;

    final oldPlayer = _active;
    final newPlayer = _standby;
    final oldStartVol = _aIsActive ? _playerAVolume : _playerBVolume;
    final newStartVol = _aIsActive ? _playerBVolume : _playerAVolume;

    try {
      // Start new player silent
      await newPlayer.setVolume(newStartVol.clamp(0.0, 100.0));
      await newPlayer.play();

      // Swap so streams report the new player's state
      _aIsActive = !_aIsActive;
      _standbyPreloaded = false;
      _preloadedNextUri = null;
      _hasMedia = true;
      _stateSubject.add(EngineState.ready);

      if (_eqEnabled) await _applyEqualizer();

      // Crossfade ramp — Stopwatch-based for jitter-resistant timing
      const steps = 20;
      final totalMs = duration.inMilliseconds;
      final sw = Stopwatch()..start();

      for (int i = 1; i <= steps; i++) {
        if (_generation != gen || _disposed) return;

        final targetMs = (totalMs * i) ~/ steps;
        final sleepMs = targetMs - sw.elapsedMilliseconds;
        if (sleepMs > 0) {
          await Future.delayed(Duration(milliseconds: sleepMs));
        }
        if (_generation != gen || _disposed) return;

        final progress = (sw.elapsedMilliseconds / totalMs).clamp(0.0, 1.0);
        final targetVol =
            _userVolume * 100.0; // Re-read for live volume changes
        final oldVol = oldStartVol * (1.0 - progress);
        final newVol = newStartVol + ((targetVol - newStartVol) * progress);
        await Future.wait([
          oldPlayer.setVolume(oldVol.clamp(0.0, 100.0)),
          newPlayer.setVolume(newVol.clamp(0.0, 100.0)),
        ]);
      }

      if (_generation != gen || _disposed) return;

      // Cleanup: ensure new at full volume, stop old
      final vol = _userVolume * 100.0;
      await newPlayer.setVolume(vol);
      try {
        await oldPlayer.stop();
        await oldPlayer.setVolume(vol); // Reset for next use as standby
      } catch (_) {}
    } catch (e) {
      log('Crossfade error: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
    } finally {
      if (_generation == gen) {
        _isTransitioning = false;
      }
    }
  }

  /// Fade out the active player over [duration], then stop it.
  /// Increments [_generation]; any previous loop aborts on mismatch.
  /// After this returns, the active player is stopped and silent.
  Future<void> fadeOutActive(Duration duration) async {
    if (_disposed) return;

    // Nothing to fade if not playing — just stop
    if (!_active.state.playing) {
      try {
        await _active.stop();
      } catch (_) {}
      return;
    }

    final gen = ++_generation;
    _isTransitioning = true;

    final player = _active;
    final startVol = (_aIsActive ? _playerAVolume : _playerBVolume)
        .clamp(0.0, _userVolume * 100.0);

    try {
      const steps = 15;
      final totalMs = duration.inMilliseconds;
      final sw = Stopwatch()..start();

      for (int i = 1; i <= steps; i++) {
        if (_generation != gen || _disposed) return;

        final targetMs = (totalMs * i) ~/ steps;
        final sleepMs = targetMs - sw.elapsedMilliseconds;
        if (sleepMs > 0) {
          await Future.delayed(Duration(milliseconds: sleepMs));
        }
        if (_generation != gen || _disposed) return;

        final progress = (sw.elapsedMilliseconds / totalMs).clamp(0.0, 1.0);
        final nextVol = startVol * (1.0 - progress);
        await player.setVolume(nextVol.clamp(0.0, 100.0));
      }

      // Fadeout complete — stop and reset volume for reuse
      if (_generation == gen) {
        await player.stop();
        await player.setVolume(_userVolume * 100.0);
      }
    } catch (e) {
      log('Fadeout error: $e', name: 'PlayerEngine');
    } finally {
      if (_generation == gen) {
        _isTransitioning = false;
      }
    }
  }

  /// Stop playback and reset to idle state.
  /// Increments [_generation] to abort any running transition.
  Future<void> stop() async {
    if (_disposed) return;

    _generation++;
    _isTransitioning = false;
    _hasMedia = false;
    _standbyPreloaded = false;
    _preloadedNextUri = null;

    try {
      await Future.wait([_playerA.stop(), _playerB.stop()]);
      // Reset volume on both for a clean slate
      final vol = _userVolume * 100.0;
      await Future.wait([_playerA.setVolume(vol), _playerB.setVolume(vol)]);
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
    if (_isTransitioning) {
      // During crossfade/fadeout the loop applies _userVolume proportionally.
      // Just storing the value is sufficient — the loop re-reads it each step.
    } else {
      // Set on both players so standby is at correct volume for next transition
      final vol = _userVolume * 100.0;
      await Future.wait([_playerA.setVolume(vol), _playerB.setVolume(vol)]);
    }
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
    if (_disposed || _isTransitioning) return;

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
    if (!_isTransitioning) {
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

    // Abort any running transition loops (they check _disposed and _generation)
    _generation++;
    _isTransitioning = false;

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
