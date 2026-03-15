import 'dart:async';
import 'dart:developer';

import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';

enum EngineState { idle, loading, buffering, ready, completed, error }

enum LoopMode { off, one, all }

sealed class EngineResult {}

class EngineSuccess extends EngineResult {}

class EngineFailure extends EngineResult {
  final Object error;
  EngineFailure(this.error);
}

class EngineCanceled extends EngineResult {}

class EqualizerBand {
  final double centerFrequency;
  double gain;
  EqualizerBand(this.centerFrequency, {this.gain = 0.0});
}

class VolumeFader {
  Timer? _timer;

  void fade(Player player, double startVol, double endVol, Duration duration) {
    _timer?.cancel();
    if (duration <= Duration.zero) {
      player.setVolume(endVol.clamp(0.0, 100.0)).ignore();
      return;
    }
    final sw = Stopwatch()..start();
    final totalMs = duration.inMilliseconds;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final elapsed = sw.elapsedMilliseconds;
      if (elapsed >= totalMs) {
        player.setVolume(endVol.clamp(0.0, 100.0)).ignore();
        timer.cancel();
        return;
      }
      final vol = startVol + ((endVol - startVol) * (elapsed / totalMs));
      player.setVolume(vol.clamp(0.0, 100.0)).ignore();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}

class PlayerEngine {
  late final Player _playerA;
  late final Player _playerB;
  bool _aIsActive = true;
  bool _disposed = false;

  Player get _active => _aIsActive ? _playerA : _playerB;
  Player get _standby => _aIsActive ? _playerB : _playerA;

  late final BehaviorSubject<Player> _activePlayerSubject;

  Duration crossfadeDuration = Duration.zero;

  final VolumeFader _oldPlayerFader = VolumeFader();
  final VolumeFader _newPlayerFader = VolumeFader();
  Timer? _fadeCleanupTimer;
  Timer? _fadeOutCleanupTimer;

  int _generation = 0;
  bool _isTransitioning = false;
  bool _crossfadeTriggered = false;

  // Prevents spurious EngineState.idle emissions during track transitions.
  // When true, _deriveState() will not emit idle even if _hasMedia is false.
  // Set by setLoadingState() at the start of every track load.
  // Cleared when _hasMedia becomes true (media successfully opened) or when
  // stop() is called without keepLoadingState (genuine user-initiated stop).
  bool _suppressIdleUntilMediaLoads = false;

  Uri? _pendingPreloadUri;
  Map<String, String>? _pendingPreloadHeaders;
  Uri? _preloadedNextUri;
  Map<String, String>? _preloadedNextHeaders;
  bool _standbyPreloaded = false;

  LoopMode _loopMode = LoopMode.off;
  double _userVolume = 1.0;

  double _playerAVolume = 100.0;
  double _playerBVolume = 100.0;
  bool _hasMedia = false;

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
  static const Duration _eqApplyDebounce = Duration(milliseconds: 180);
  Timer? _eqApplyDebounceTimer;

  PlayerEngine() {
    _playerA = Player(
        configuration: const PlayerConfiguration(
            title: 'BloomeeTunes', bufferSize: 8 * 1024 * 1024));
    _playerB = Player(
        configuration: const PlayerConfiguration(
            title: 'BloomeeTunes', bufferSize: 8 * 1024 * 1024));
    _activePlayerSubject = BehaviorSubject.seeded(_playerA);
    _subs = _buildSubscriptions();
  }

  List<StreamSubscription> _buildSubscriptions() {
    return [
      _activePlayerSubject.switchMap((p) => p.stream.playing).listen((playing) {
        _playingSubject.add(playing);
        _deriveState();
      }),
      _activePlayerSubject.switchMap((p) => p.stream.position).listen((pos) {
        _positionSubject.add(pos);
        _checkCrossfadeTrigger(pos);
      }),
      _activePlayerSubject.switchMap((p) => p.stream.duration).listen((d) {
        _durationSubject.add(d);
        _deriveState();
      }),
      _activePlayerSubject
          .switchMap((p) => p.stream.buffer)
          .listen(_bufferedSubject.add),
      _activePlayerSubject
          .switchMap((p) => p.stream.buffering)
          .listen((_) => _deriveState()),
      _activePlayerSubject
          .switchMap((p) => p.stream.completed)
          .listen((completed) {
        if (completed && _hasMedia && !_disposed && !_crossfadeTriggered) {
          _handleCompletion();
        }
      }),
      _activePlayerSubject.switchMap((p) => p.stream.volume).listen((v) {
        if (!_isTransitioning) _volumeSubject.add((v / 100.0).clamp(0.0, 1.0));
      }),
      _activePlayerSubject.switchMap((p) => p.stream.error).listen((error) {
        log('Engine error: $error', name: 'PlayerEngine');
        _triggerEngineFailure(error);
      }),
      _playerA.stream.volume.listen((v) => _playerAVolume = v),
      _playerB.stream.volume.listen((v) => _playerBVolume = v),
    ];
  }

  void _checkCrossfadeTrigger(Duration pos) {
    if (_disposed || !_hasMedia || crossfadeDuration <= Duration.zero) return;
    if (_crossfadeTriggered || _isTransitioning || _loopMode == LoopMode.one) {
      return;
    }
    final dur = _durationSubject.value;
    if (dur <= Duration.zero) return;
    final remaining = dur - pos;
    if (remaining <= crossfadeDuration && remaining.inMilliseconds > 50) {
      _crossfadeTriggered = true;
      _handleCompletion();
    }
  }

  void _triggerEngineFailure(String error) {
    _hasMedia = false;
    _suppressIdleUntilMediaLoads = false;
    _playingSubject.add(false);
    _stateSubject.add(EngineState.error);
    _errorController.add(error);
  }

  void _swapActivePlayer() {
    _aIsActive = !_aIsActive;
    final p = _active;
    _playingSubject.add(p.state.playing);
    _positionSubject.add(p.state.position);
    _durationSubject.add(p.state.duration);
    _bufferedSubject.add(p.state.buffer);
    _activePlayerSubject.add(p);
    _deriveState();
  }

  void _handleCompletion() {
    if (_disposed || !_hasMedia || _loopMode == LoopMode.one) return;
    _stateSubject.add(EngineState.completed);
    _completionController.add(null);
  }

  // ─── State machine ─────────────────────────────────────────────────────────
  //
  // The idle state is what audio_service maps to AudioProcessingState.idle,
  // which signals Android to call stopForeground(). On Android 12+, once the
  // foreground service is stopped, it cannot be restarted from the background
  // (ForegroundServiceStartNotAllowedException). libmpv's native C threads are
  // unaware of the Android service lifecycle and keep outputting audio,
  // creating a zombie audio instance with no notification.
  //
  // During a track transition, _doPlay() in BloomeeMusicPlayer calls:
  //   setLoadingState()           → sets _suppressIdleUntilMediaLoads = true
  //   engine.stop(keepLoading)    → sets _hasMedia = false, does NOT clear suppression
  //   [player streams fire]       → _deriveState() called, suppression blocks idle
  //   engine.openDirect(...)      → sets _hasMedia = true, clearance in _deriveState()
  //
  // On genuine user stop or swipe-from-recents:
  //   stop() with keepLoadingState = false → clears suppression, idle propagates correctly
  //
  void _deriveState() {
    if (_disposed) return;

    if (!_hasMedia) {
      if (!_suppressIdleUntilMediaLoads) {
        _stateSubject.add(EngineState.idle);
      }
      return;
    }

    // Media is loaded — suppression no longer needed.
    _suppressIdleUntilMediaLoads = false;

    final player = _active;
    if (player.state.buffering) {
      _stateSubject.add(EngineState.buffering);
    } else if (_isTransitioning) {
      _stateSubject.add(EngineState.ready);
    } else if (player.state.duration > Duration.zero ||
        player.state.position > Duration.zero ||
        player.state.playing) {
      _stateSubject.add(EngineState.ready);
    } else {
      _stateSubject.add(EngineState.loading);
    }
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  EngineState get state => _stateSubject.value;
  bool get playing => _playingSubject.value;
  Duration get position => _positionSubject.value;
  Duration get duration => _durationSubject.value;
  Duration get buffered => _bufferedSubject.value;
  double get volume => _volumeSubject.value;
  double get speed => _speedSubject.value;
  LoopMode get loopMode => _loopMode;
  Stream<EngineState> get stateStream => _stateSubject.stream;
  Stream<bool> get playingStream => _playingSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<Duration> get bufferedStream => _bufferedSubject.stream;
  Stream<double> get volumeStream => _volumeSubject.stream;
  Stream<double> get speedStream => _speedSubject.stream;
  Stream<void> get completionStream => _completionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Called at the start of every track load. Activates idle suppression so
  // the stream events fired by the subsequent stop() call do not propagate
  // idle to audio_service.
  void setLoadingState() {
    if (_disposed) return;
    _suppressIdleUntilMediaLoads = true;
    _stateSubject.add(EngineState.loading);
  }

  // ─── Transition primitives ─────────────────────────────────────────────────

  Future<EngineResult> openDirect(
    Uri uri, {
    Map<String, String>? httpHeaders,
    bool autoPlay = true,
  }) async {
    if (_disposed) return EngineFailure('Engine disposed');
    final gen = ++_generation;

    _oldPlayerFader.cancel();
    _newPlayerFader.cancel();
    _fadeCleanupTimer?.cancel();
    _fadeOutCleanupTimer?.cancel();

    _isTransitioning = false;
    _crossfadeTriggered = false;
    _hasMedia = false;

    setLoadingState();

    try {
      await _active.setVolume(_userVolume * 100.0);
      await _active.open(
        Media(uri.toString(), httpHeaders: httpHeaders),
        play: autoPlay,
      );
      if (_disposed || _generation != gen) return EngineCanceled();

      _hasMedia = true;
      if (_eqEnabled) await _applyEqualizer();
      _deriveState();
      return EngineSuccess();
    } catch (e) {
      if (_generation != gen) return EngineCanceled();
      _triggerEngineFailure(e.toString());
      return EngineFailure(e);
    }
  }

  Future<EngineResult> activatePreloaded({bool autoPlay = true}) async {
    if (_disposed || !_standbyPreloaded || _preloadedNextUri == null) {
      return EngineFailure('Not preloaded');
    }

    final gen = ++_generation;
    _oldPlayerFader.cancel();
    _newPlayerFader.cancel();
    _fadeCleanupTimer?.cancel();
    _fadeOutCleanupTimer?.cancel();
    _isTransitioning = false;
    _crossfadeTriggered = false;

    setLoadingState();
    final oldPlayer = _active;
    final newPlayer = _standby;

    try {
      oldPlayer.stop().catchError((_) {});
      if (_generation != gen || _disposed) return EngineCanceled();

      await newPlayer.setVolume(_userVolume * 100.0);
      if (_generation != gen || _disposed) return EngineCanceled();

      if (autoPlay) await newPlayer.play();
      if (_generation != gen || _disposed) return EngineCanceled();

      _standbyPreloaded = false;
      _preloadedNextUri = null;
      _hasMedia = true;

      _swapActivePlayer();
      if (_eqEnabled) await _applyEqualizer();

      return EngineSuccess();
    } catch (e) {
      if (_generation != gen) return EngineCanceled();
      newPlayer.stop().catchError((_) {});
      _standbyPreloaded = false;
      _triggerEngineFailure(e.toString());
      return EngineFailure(e);
    }
  }

  Future<EngineResult> crossfadeToPreloaded(Duration duration) async {
    if (_disposed) return EngineFailure('Engine disposed');

    if (!_standbyPreloaded) {
      if (_pendingPreloadUri != null) {
        final uri = _pendingPreloadUri!;
        final headers = _pendingPreloadHeaders;
        _pendingPreloadUri = null;
        _pendingPreloadHeaders = null;
        return openDirect(uri, httpHeaders: headers, autoPlay: true);
      }
      return EngineFailure('Not preloaded');
    }

    _oldPlayerFader.cancel();
    _newPlayerFader.cancel();
    _fadeCleanupTimer?.cancel();
    _fadeOutCleanupTimer?.cancel();

    final gen = ++_generation;
    _isTransitioning = true;
    _crossfadeTriggered = false;

    setLoadingState();

    final oldPlayer = _active;
    final newPlayer = _standby;
    final oldStartVol = _aIsActive ? _playerAVolume : _playerBVolume;

    try {
      await newPlayer.setVolume(0.0);
      await newPlayer.play();

      if (_generation != gen || _disposed) {
        newPlayer.stop().catchError((_) {});
        return EngineCanceled();
      }

      _standbyPreloaded = false;
      _preloadedNextUri = null;
      _hasMedia = true;

      _swapActivePlayer();
      if (_eqEnabled) await _applyEqualizer();

      _oldPlayerFader.fade(oldPlayer, oldStartVol, 0.0, duration);
      _newPlayerFader.fade(newPlayer, 0.0, _userVolume * 100.0, duration);

      _fadeCleanupTimer = Timer(duration, () async {
        if (!_disposed) {
          _oldPlayerFader.cancel();
          _newPlayerFader.cancel();
          await oldPlayer.stop().catchError((_) {});
          await oldPlayer.setVolume(_userVolume * 100.0).catchError((_) {});
          await newPlayer.setVolume(_userVolume * 100.0).catchError((_) {});
          _isTransitioning = false;

          if (_pendingPreloadUri != null) {
            final uri = _pendingPreloadUri!;
            final headers = _pendingPreloadHeaders;
            _pendingPreloadUri = null;
            _pendingPreloadHeaders = null;
            preloadNext(uri, httpHeaders: headers);
          }
        }
      });

      return EngineSuccess();
    } catch (e) {
      if (_generation != gen) return EngineCanceled();
      _oldPlayerFader.cancel();
      _newPlayerFader.cancel();
      _fadeCleanupTimer?.cancel();
      _isTransitioning = false;
      _active.setVolume(_userVolume * 100.0).catchError((_) {});
      _triggerEngineFailure(e.toString());
      return EngineFailure(e);
    }
  }

  void fadeOutActive(Duration duration) {
    if (_disposed) return;
    final player = _active;
    if (!player.state.playing) {
      player.stop().catchError((_) {});
      return;
    }
    _isTransitioning = true;
    final startVol = (_aIsActive ? _playerAVolume : _playerBVolume)
        .clamp(0.0, _userVolume * 100.0);
    _oldPlayerFader.cancel();
    _oldPlayerFader.fade(player, startVol, 0.0, duration);
    _fadeOutCleanupTimer?.cancel();
    _fadeOutCleanupTimer = Timer(duration, () {
      if (!_disposed) {
        _oldPlayerFader.cancel();
        player.stop().catchError((_) {});
        player.setVolume(_userVolume * 100.0).catchError((_) {});
        _isTransitioning = false;
      }
    });
  }

  Future<void> stop({bool keepLoadingState = false}) async {
    if (_disposed) return;

    ++_generation;

    _oldPlayerFader.cancel();
    _newPlayerFader.cancel();
    _fadeCleanupTimer?.cancel();
    _fadeOutCleanupTimer?.cancel();

    _isTransitioning = false;
    _crossfadeTriggered = false;
    _hasMedia = false;
    _standbyPreloaded = false;
    _preloadedNextUri = null;
    _preloadedNextHeaders = null;
    _pendingPreloadUri = null;
    _pendingPreloadHeaders = null;

    // keepLoadingState = true means a track transition is in progress —
    // setLoadingState() already activated suppression before this call.
    // keepLoadingState = false means a genuine stop — clear suppression so
    // idle state propagates to audio_service and the Android service stops.
    if (!keepLoadingState) {
      _suppressIdleUntilMediaLoads = false;
    }

    _positionSubject.add(Duration.zero);
    _durationSubject.add(Duration.zero);
    _bufferedSubject.add(Duration.zero);
    _playingSubject.add(false);

    try {
      await Future.wait([_playerA.stop(), _playerB.stop()]);
      final vol = _userVolume * 100.0;
      await Future.wait([_playerA.setVolume(vol), _playerB.setVolume(vol)]);
    } catch (e) {
      log('Stop error: $e', name: 'PlayerEngine');
    }

    if (!keepLoadingState) {
      _stateSubject.add(EngineState.idle);
    }
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
    final actualDuration = _active.state.duration;
    if (actualDuration <= Duration.zero) return;
    final clamped = Duration(
        milliseconds:
            position.inMilliseconds.clamp(0, actualDuration.inMilliseconds));
    await _active.seek(clamped);
  }

  Future<void> setVolume(double value) async {
    if (_disposed) return;
    _userVolume = value.clamp(0.0, 1.0);
    if (!_isTransitioning) {
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
    final mpvMode =
        mode == LoopMode.one ? PlaylistMode.single : PlaylistMode.none;
    await Future.wait(
        [_playerA.setPlaylistMode(mpvMode), _playerB.setPlaylistMode(mpvMode)]);
  }

  // ─── Gapless preloading ────────────────────────────────────────────────────

  Future<bool> preloadNext(Uri uri, {Map<String, String>? httpHeaders}) async {
    if (_disposed) return false;
    if (_standbyPreloaded &&
        _preloadedNextUri == uri &&
        _preloadedNextHeaders == httpHeaders) {
      return true;
    }

    if (_isTransitioning) {
      _pendingPreloadUri = uri;
      _pendingPreloadHeaders = httpHeaders;
      _preloadedNextUri = uri;
      _preloadedNextHeaders = httpHeaders;
      return true;
    }

    try {
      await _standby.setVolume(0);
      await _standby.open(
        Media(uri.toString(), httpHeaders: httpHeaders),
        play: false,
      );
      _preloadedNextUri = uri;
      _preloadedNextHeaders = httpHeaders;
      _standbyPreloaded = true;
      _pendingPreloadUri = null;
      _pendingPreloadHeaders = null;
      log('Preloaded next track: $uri', name: 'PlayerEngine');
      return true;
    } catch (e) {
      log('Preload failed: $e', name: 'PlayerEngine');
      _preloadedNextUri = null;
      _preloadedNextHeaders = null;
      _standbyPreloaded = false;
      return false;
    }
  }

  Future<void> clearPreload() async {
    _preloadedNextUri = null;
    _preloadedNextHeaders = null;
    _standbyPreloaded = false;
    _pendingPreloadUri = null;
    _pendingPreloadHeaders = null;
    if (!_isTransitioning) {
      try {
        await _standby.stop();
      } catch (_) {}
    }
  }

  bool get isPreloaded => _standbyPreloaded || _pendingPreloadUri != null;

  // ─── Equalizer ─────────────────────────────────────────────────────────────

  List<EqualizerBand> get equalizerBands => List.unmodifiable(_eqBands);
  bool get equalizerEnabled => _eqEnabled;

  Future<void> setEqualizerEnabled(bool enabled) async {
    _eqEnabled = enabled;
    _eqApplyDebounceTimer?.cancel();
    await _applyEqualizer();
  }

  Future<void> setEqualizerBandGain(int bandIndex, double gain,
      {bool immediate = false}) async {
    if (bandIndex < 0 || bandIndex >= _eqBands.length) return;
    _eqBands[bandIndex].gain = gain.clamp(-12.0, 12.0);
    if (!_eqEnabled) return;
    if (immediate) {
      _eqApplyDebounceTimer?.cancel();
      await _applyEqualizer();
      return;
    }
    _scheduleEqualizerApply();
  }

  Future<void> setEqualizerBandGains(List<double> gains,
      {bool immediate = false}) async {
    final count =
        gains.length < _eqBands.length ? gains.length : _eqBands.length;
    for (var i = 0; i < count; i++) {
      _eqBands[i].gain = gains[i].clamp(-12.0, 12.0);
    }
    if (!_eqEnabled) return;
    if (immediate) {
      _eqApplyDebounceTimer?.cancel();
      await _applyEqualizer();
      return;
    }
    _scheduleEqualizerApply();
  }

  Future<void> resetEqualizer() async {
    for (final band in _eqBands) {
      band.gain = 0.0;
    }
    _eqApplyDebounceTimer?.cancel();
    await _applyEqualizer();
  }

  void _scheduleEqualizerApply() {
    if (_disposed) return;
    _eqApplyDebounceTimer?.cancel();
    _eqApplyDebounceTimer = Timer(_eqApplyDebounce, () {
      if (_disposed || !_eqEnabled) return;
      _applyEqualizer();
    });
  }

  Future<void> _applyEqualizer() async {
    if (_disposed) return;
    try {
      final filter = _eqEnabled ? _buildEqualizerFilter() : '';
      final platformA = _playerA.platform;
      final platformB = _playerB.platform;
      if (platformA is NativePlayer) await platformA.setProperty('af', filter);
      if (platformB is NativePlayer) await platformB.setProperty('af', filter);
    } catch (e) {
      log('Equalizer apply error: $e', name: 'PlayerEngine');
    }
  }

  String _buildEqualizerFilter() {
    final parts = <String>[];
    for (final band in _eqBands) {
      if (band.gain.abs() < 0.1) continue;
      parts.add('equalizer=f=${band.centerFrequency}:t=o:w=1:g=${band.gain}');
    }
    if (parts.isEmpty) return '';
    return 'lavfi=[${parts.join(',')}]';
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    ++_generation;

    _oldPlayerFader.dispose();
    _newPlayerFader.dispose();
    _fadeCleanupTimer?.cancel();
    _fadeOutCleanupTimer?.cancel();
    _eqApplyDebounceTimer?.cancel();

    _isTransitioning = false;

    for (final sub in _subs) {
      await sub.cancel();
    }
    await _activePlayerSubject.close();
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
