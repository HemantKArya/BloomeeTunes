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

  // ── Gapless pre-load ──
  Uri? _preloadedNextUri;

  // ── Loop tracking ──
  LoopMode _loopMode = LoopMode.off;

  // ── User volume (0..1) — preserved across cross-fade transitions ──
  double _userVolume = 1.0;

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
            player.seek(Duration.zero).then((_) => player.play());
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
  double get speed => _active.state.rate;
  LoopMode get loopMode => _loopMode;

  // ─── Streams ───────────────────────────────────────────────────────────────

  Stream<EngineState> get stateStream => _stateSubject.stream;
  Stream<bool> get playingStream => _playingSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<Duration> get bufferedStream => _bufferedSubject.stream;
  Stream<double> get volumeStream => _volumeSubject.stream;

  /// Fires when a track finishes naturally (not on manual stop/skip).
  Stream<void> get completionStream => _completionController.stream;

  /// Fires on playback errors from MPV.
  Stream<String> get errorStream => _errorController.stream;

  // ─── Playback Control ──────────────────────────────────────────────────────

  /// Open a URI and optionally start playback.
  /// Stops any currently playing audio first to prevent overlap.
  Future<void> open(Uri uri, {bool autoPlay = true}) async {
    if (_disposed) return;
    if (crossfadeDuration > Duration.zero && _active.state.playing) {
      await _crossfadeOpen(uri, autoPlay: autoPlay);
    } else {
      await _directOpen(uri, autoPlay: autoPlay);
    }
  }

  Future<void> _directOpen(Uri uri, {bool autoPlay = true}) async {
    _stateSubject.add(EngineState.loading);
    _positionSubject.add(Duration.zero);
    _durationSubject.add(Duration.zero);
    try {
      await _active.open(Media(uri.toString()), play: autoPlay);
    } catch (e) {
      log('Failed to open: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
      rethrow;
    }
  }

  Future<void> _crossfadeOpen(Uri uri, {bool autoPlay = true}) async {
    _isCrossfading = true;
    final oldPlayer = _active;
    final newPlayer = _standby;

    try {
      await newPlayer.setVolume(0);
      await newPlayer.open(Media(uri.toString()), play: autoPlay);

      _aIsActive = !_aIsActive;
      _stateSubject.add(EngineState.ready);

      final targetVol = _userVolume * 100.0;
      const steps = 20;
      final stepMs = crossfadeDuration.inMilliseconds ~/ steps;

      for (int i = 1; i <= steps; i++) {
        if (_disposed) return;
        final progress = i / steps;
        oldPlayer.setVolume(targetVol * (1.0 - progress));
        newPlayer.setVolume(targetVol * progress);
        await Future.delayed(Duration(milliseconds: stepMs));
      }

      await oldPlayer.stop();
      await oldPlayer.setVolume(targetVol);
    } catch (e) {
      log('Cross-fade error: $e', name: 'PlayerEngine');
      _stateSubject.add(EngineState.error);
      _errorController.add(e.toString());
    } finally {
      _isCrossfading = false;
    }
  }

  /// Stop playback and reset to idle state.
  Future<void> stop() async {
    if (_disposed) return;
    try {
      await _active.stop();
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
    await _active.seek(position);
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
  }

  Future<void> setLoopMode(LoopMode mode) async {
    if (_disposed) return;
    _loopMode = mode;
    await _active.setPlaylistMode(PlaylistMode.none);
  }

  // ─── Gapless Pre-loading ───────────────────────────────────────────────────

  void preloadNext(Uri uri) => _preloadedNextUri = uri;
  void clearPreload() => _preloadedNextUri = null;
  Uri? get preloadedNextUri => _preloadedNextUri;

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
    } else if (player.state.playing ||
        player.state.position > Duration.zero ||
        player.state.duration > Duration.zero) {
      _stateSubject.add(EngineState.ready);
    } else if (_stateSubject.value == EngineState.loading) {
      // Keep loading.
    } else {
      _stateSubject.add(EngineState.idle);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final sub in _subs) {
      await sub.cancel();
    }
    await _playerA.dispose();
    await _playerB.dispose();
    await _stateSubject.close();
    await _playingSubject.close();
    await _positionSubject.close();
    await _durationSubject.close();
    await _bufferedSubject.close();
    await _volumeSubject.close();
    await _completionController.close();
    await _errorController.close();
  }
}
