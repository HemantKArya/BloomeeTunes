import 'dart:developer';
import 'dart:async';
import 'dart:convert';

import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/core/models/exported.dart' hide MediaItem;
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/media_resolver_service.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/player/player_error_handler.dart';
import 'package:Bloomee/services/player/queue_manager.dart';
import 'package:Bloomee/services/player/related_songs_manager.dart';
import 'package:Bloomee/services/player/recently_played_tracker.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/meta_resolver/smart_track_replacement_service.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:async/async.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

/// Main music player — extends [BaseAudioHandler] for OS notification / media
/// controls and orchestrates [PlayerEngine],[QueueManager],
/// and [PlayerErrorHandler].
class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late PlayerEngine engine;

  // Modular components
  late PlayerErrorHandler _errorHandler;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late RecentlyPlayedTracker _recentlyPlayedTracker;
  late MediaResolverService _resolver;
  late SmartTrackReplacementService _smartTrackReplacementService;

  // State subjects (Kept alive indefinitely to avoid orphaning UI StreamBuilders)
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);

  bool _isDisposed = false;

  // ── Concurrency & Cancellation Tokens ──
  CancelableCompleter<void>? _playCompleter;
  CancelableOperation<ResolvedMediaSource>? _preResolveOp;
  CancelableOperation<ResolvedMediaSource>? _currentResolveOp;
  bool _isAdvancing = false;
  bool _checkingRelated = false;

  // Preload identity tracking
  String? _preloadedTrackId;
  bool _preloadedTrackOffline = false;

  /// The plugin that actually resolved the current track's stream.
  ///
  /// Usually matches the plugin ID in the track’s media ID. If a fallback plugin is chosen by [_tryAutoResolveUnavailableTrack], this holds
  /// the fallback ID so [_checkRelatedSongs] forwards the active plugin to [RelatedSongsManager] for radio/mix requests.
  String? _lastResolvedPluginId;

  // Stream subscriptions
  StreamSubscription? _engineStateSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _queueSyncSub;
  StreamSubscription?
      _positionSuccessSub; // Validates hardware playback success
  Timer? _relatedSongTimer;
  StreamSubscription<AudioInterruptionEvent>? _audioInterruptionSub;
  StreamSubscription<void>? _audioNoisySub;

  AudioSession? _audioSession;
  bool _audioSessionConfigured = false;
  DateTime? _lastAudioSessionConfiguredAt;
  double? _volumeBeforeDuck;
  bool _resumeAfterInterruption = false;

  // Expose from modular components
  BehaviorSubject<bool> get shuffleMode => _queueManager.shuffleMode;
  BehaviorSubject<PlayerError?> get lastError => _errorHandler.lastError;
  BehaviorSubject<List<Track>> get relatedSongs =>
      _relatedSongsManager.relatedSongs;

  /// Whether the player is currently resolving a media URL (before engine loads).
  final BehaviorSubject<bool> isResolving = BehaviorSubject<bool>.seeded(false);

  @override
  BehaviorSubject<String> get queueTitle => _queueManager.queueTitle;

  // Currently playing track (domain model — NOT audio_service MediaItem)
  Track _currentTrack = trackNull;

  /// The current track as a domain [Track].
  Track get currentTrackInfo => _currentTrack;
  List<Track> get queueTracks => List<Track>.unmodifiable(_queueManager.tracks);
  int get currentQueueIndex => _queueManager.currentIndex;
  PluginService get pluginService => ServiceLocator.pluginService;

  /// Re-broadcast current queue/media/playback values for newly attached UI
  /// listeners after activity/app surface recreation.
  void syncPublicState() {
    if (_isDisposed) return;

    final tracks = _queueManager.tracks;
    queue.add(List<MediaItem>.from(tracks.map(trackToMediaItem)));

    if (_currentTrack.id != trackNull.id) {
      mediaItem.add(trackToMediaItem(_currentTrack));
    }

    _broadcastPlaybackState(
      engine.state,
      engine.playing,
      engine.position,
      engine.buffered,
      engine.speed,
    );
  }

  BloomeeMusicPlayer() {
    _initEngine();
    _initModules();
    _initSubscriptions();
    _initAudioSession();
    _restoreEngineSettings();
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initEngine() {
    _isDisposed = false;
    engine = PlayerEngine();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await _configureAudioSession(session, force: true);
      _audioSession = session;

      await _audioInterruptionSub?.cancel();
      _audioInterruptionSub = session.interruptionEventStream.listen((event) {
        _handleInterruption(event);
      });

      await _audioNoisySub?.cancel();
      _audioNoisySub = session.becomingNoisyEventStream.listen((_) async {
        if (_isDisposed) return;
        if (engine.playing) await pause();
      });

      log('Audio session configured', name: 'BloomeeMusicPlayer');
    } catch (e) {
      _audioSessionConfigured = false;
      log('Failed to initialize audio session: $e', name: 'BloomeeMusicPlayer');
    }
  }

  Future<void> _configureAudioSession(AudioSession session,
      {bool force = false}) async {
    final lastConfiguredAt = _lastAudioSessionConfiguredAt;
    if (!force &&
        _audioSessionConfigured &&
        lastConfiguredAt != null &&
        DateTime.now().difference(lastConfiguredAt) <
            const Duration(seconds: 10)) {
      return;
    }

    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
        flags: AndroidAudioFlags.none,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    ));

    _audioSessionConfigured = true;
    _lastAudioSessionConfiguredAt = DateTime.now();
  }

  Future<void> ensureAudioSessionConfigured({bool force = false}) async {
    final session = _audioSession ?? await AudioSession.instance;
    _audioSession = session;
    await _configureAudioSession(session, force: force);
  }

  Future<void> _handleInterruption(AudioInterruptionEvent event) async {
    if (_isDisposed) return;

    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _volumeBeforeDuck ??= engine.volume;
          await engine.setVolume((engine.volume * 0.35).clamp(0.0, 1.0));
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          _resumeAfterInterruption = engine.playing;
          if (engine.playing) await pause();
          break;
      }
      return;
    }

    switch (event.type) {
      case AudioInterruptionType.duck:
        final previousVolume = _volumeBeforeDuck;
        _volumeBeforeDuck = null;
        if (previousVolume != null) {
          await engine.setVolume(previousVolume.clamp(0.0, 1.0));
        }
        break;
      case AudioInterruptionType.pause:
        if (_resumeAfterInterruption) {
          final granted = await _activateAudioSession();
          if (granted && !_isDisposed) await play();
        }
        _resumeAfterInterruption = false;
        break;
      case AudioInterruptionType.unknown:
        _resumeAfterInterruption = false;
        break;
    }
  }

  Future<bool> _activateAudioSession() async {
    try {
      final session = _audioSession ?? await AudioSession.instance;
      _audioSession = session;
      await _configureAudioSession(session);
      return await session.setActive(true);
    } catch (e) {
      log('Failed to activate audio session: $e', name: 'BloomeeMusicPlayer');
      return false;
    }
  }

  Future<void> _deactivateAudioSession() async {
    try {
      final session = _audioSession;
      if (session != null) await session.setActive(false);
    } catch (e) {
      log('Failed to deactivate audio session: $e', name: 'BloomeeMusicPlayer');
    }
  }

  Future<void> _restoreEngineSettings() async {
    try {
      final settingsDao = SettingsDAO(DBProvider.db);

      final cfStr =
          await settingsDao.getSettingStr(SettingKeys.crossfadeDuration);
      final parsedCrossfade = int.tryParse((cfStr ?? '').trim());
      final cfSeconds = parsedCrossfade ?? 2;
      if (cfStr != cfSeconds.toString()) {
        await settingsDao.putSettingStr(
          SettingKeys.crossfadeDuration,
          cfSeconds.toString(),
        );
      }
      engine.crossfadeDuration = Duration(seconds: cfSeconds);

      final storedQuality = await settingsDao.getSettingStr(
        SettingKeys.strmQuality,
      );
      final normalizedQuality = normalizeStoredStreamQualityLabel(
        storedQuality,
        fallback: AudioStreamQualityPreference.high.label,
      );
      if (storedQuality != normalizedQuality) {
        await settingsDao.putSettingStr(
            SettingKeys.strmQuality, normalizedQuality);
      }

      final eqOn =
          await settingsDao.getSettingBool(SettingKeys.eqEnabled) ?? false;

      final gainsJson =
          await settingsDao.getSettingStr(SettingKeys.eqBandGains);
      if (gainsJson != null) {
        try {
          final decoded = jsonDecode(gainsJson) as List;
          final gains = decoded.map((e) => (e as num).toDouble()).toList();
          if (gains.length == 10) {
            for (int i = 0; i < 10; i++) {
              await engine.setEqualizerBandGain(i, gains[i]);
            }
          }
        } catch (e) {
          log('Failed to restore EQ gains: $e', name: 'BloomeeMusicPlayer');
        }
      }

      await engine.setEqualizerEnabled(eqOn);
      log('Engine settings restored: crossfade=${cfSeconds}s, eq=$eqOn',
          name: 'BloomeeMusicPlayer');
    } catch (e) {
      log('Failed to restore engine settings: $e', name: 'BloomeeMusicPlayer');
    }
  }

  void _initModules() {
    _errorHandler = PlayerErrorHandler();
    _queueManager = QueueManager();
    _relatedSongsManager = RelatedSongsManager(ServiceLocator.pluginService);
    _resolver = MediaResolverService.create(ServiceLocator.pluginService);
    _smartTrackReplacementService =
        SmartTrackReplacementService.create(ServiceLocator.pluginService);

    // INTERNAL skip handler: doesn't reset circuit breaker!
    _errorHandler.onSkipToNext = () => _internalSkipToNext();
    _errorHandler.onRetryCurrentTrack = () => _retryCurrentTrack();

    // Circuit Breaker tripped: Halt execution securely.
    _errorHandler.onStopPlayback = () async {
      _playCompleter?.operation.cancel();
      _playCompleter = null;
      _currentResolveOp?.cancel();
      _preResolveOp?.cancel();

      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        playing: false,
      ));

      await engine.stop();
      DiscordService.clearPresence();
    };

    _relatedSongsManager.onAddQueueItems =
        (items, {bool atLast = false}) => addQueueTracks(items, atLast: atLast);

    _recentlyPlayedTracker = RecentlyPlayedTracker(
      engine,
      () => _queueManager.currentTrack,
    );
  }

  void _initSubscriptions() {
    _engineStateSub = Rx.combineLatest4(
      engine.stateStream,
      engine.playingStream,
      engine.bufferedStream,
      engine.speedStream,
      (state, playing, buffered, speed) => (state, playing, buffered, speed),
    ).distinct().listen((record) {
      final (state, playing, buffered, speed) = record;
      _broadcastPlaybackState(state, playing, engine.position, buffered, speed);
    });

    // Hardware-verified playback success tracking
    // Absolutely guarantees we only reset the circuit breaker if the track plays
    _positionSuccessSub = engine.positionStream.listen((pos) {
      if (pos > Duration.zero &&
          engine.state == EngineState.ready &&
          engine.playing) {
        final track = _queueManager.currentTrack;
        if (track != null) _errorHandler.markTrackSuccess(track.id);
      }
    });

    _completionSub = engine.completionStream.listen((_) {
      _onTrackCompleted();
    });

    _errorSub = engine.errorStream.listen((error) {
      log('Engine error: $error', name: 'BloomeeMusicPlayer');
      final track = _queueManager.currentTrack;
      if (track != null) {
        _errorHandler.handleError(PlayerErrorType.playbackError, error, track);
      }
    });

    _queueSyncSub = _queueManager.tracksStream.listen((tracks) {
      queue.add(
        List<MediaItem>.from(tracks.map((t) => trackToMediaItem(t))),
      );
    });

    _relatedSongTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isDisposed && engine.playing) _checkRelatedSongs();
    });
  }

  // ─── State Broadcasting ────────────────────────────────────────────────────

  void _broadcastPlaybackState(EngineState state, bool playing,
      Duration position, Duration buffered, double speed) {
    _syncCurrentMediaItemDuration(state, position);

    final processingState = switch (state) {
      EngineState.idle => AudioProcessingState.idle,
      EngineState.loading => AudioProcessingState.loading,
      EngineState.buffering => AudioProcessingState.buffering,
      EngineState.ready => AudioProcessingState.ready,
      EngineState.completed => AudioProcessingState.completed,
      EngineState.error => AudioProcessingState.error,
    };

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      processingState: processingState,
      systemActions: const {
        MediaAction.skipToPrevious,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: position,
      updateTime: DateTime.now(),
      playing: playing,
      bufferedPosition: buffered,
      speed: speed,
      queueIndex: _queueManager.currentIndex,
    ));

    EasyThrottle.throttle(
      'discord_rpc',
      const Duration(milliseconds: 1000),
      () {
        DiscordService.updatePresence(
          track: currentTrackInfo,
          isPlaying: playing,
        );
      },
    );
  }

  // ─── Current Track ─────────────────────────────────────────────────────────

  Track get currentMedia {
    return _queueManager.currentTrack ?? trackNull;
  }

  // ─── Playback Control ──────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_isDisposed) return;
    _errorHandler.resetCircuitBreaker(); // Reset on manual action
    await ensureAudioSessionConfigured();
    final granted = await _activateAudioSession();
    if (!granted) {
      SnackbarService.showMessage('Audio focus denied. Cannot start playback.');
      return;
    }
    await engine.play();
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    await engine.pause();
    log('paused', name: 'BloomeeMusicPlayer');
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    await engine.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    if (_isDisposed) return;
    final dur = engine.duration;
    if (dur >= engine.position + n) {
      await engine.seek(engine.position + n);
    } else {
      await engine.seek(dur);
    }
  }

  Future<void> seekNSecBackward(Duration n) async {
    if (_isDisposed) return;
    if (engine.position - n >= Duration.zero) {
      await engine.seek(engine.position - n);
    } else {
      await engine.seek(Duration.zero);
    }
  }

  @override
  Future<void> stop() async {
    _errorHandler.resetCircuitBreaker(); // Reset on manual action
    _playCompleter?.operation.cancel();
    _playCompleter = null;
    _preResolveOp?.cancel();
    _currentResolveOp?.cancel();

    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.idle));

    await engine.stop();
    await _deactivateAudioSession();
    DiscordService.clearPresence();
    await super.stop();
  }

  @override
  Future<void> rewind() async {
    if (_isDisposed) return;

    if (engine.state == EngineState.ready ||
        engine.state == EngineState.buffering) {
      await engine.seek(Duration.zero);
    } else if (engine.state == EngineState.completed) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  // ─── Loop & Shuffle ────────────────────────────────────────────────────────

  void setLoopMode(LoopMode mode) {
    loopMode.add(mode);
    engine.setLoopMode(mode);
  }

  void setCrossfadeDuration(Duration duration) {
    engine.crossfadeDuration = duration;
  }

  Future<void> shuffle(bool enabled) async {
    _queueManager.shuffle(enabled);
  }

  // ─── Track Playing ─────────────────────────────────────────────────────────

  void _clearPreloadedMarker() {
    _preloadedTrackId = null;
    _preloadedTrackOffline = false;
  }

  void _setOfflineState(bool offline) {
    isOffline.add(offline);
  }

  Future<void> _enqueuePlayTrack(Track track,
      {bool doPlay = true, Duration? initialPosition}) {
    if (_isDisposed) return Future.value();

    final prev = _playCompleter;
    final completer = CancelableCompleter<void>(
      onCancel: () =>
          log('Canceled: ${track.title}', name: 'BloomeeMusicPlayer'),
    );
    _playCompleter = completer;
    prev?.operation.cancel();

    _doPlay(track, completer, doPlay: doPlay, initialPosition: initialPosition);

    return completer.operation.valueOrCancellation().then((_) {});
  }

  Future<void> _doPlay(
    Track track,
    CancelableCompleter<void> token, {
    bool doPlay = true,
    Duration? initialPosition,
  }) async {
    bool alive() => !token.isCanceled && !_isDisposed;

    void done() {
      if (!token.isCompleted && !token.isCanceled) token.complete();
    }

    if (!alive()) return;

    final crossfadeEnabled = engine.crossfadeDuration > Duration.zero;
    var resolvedTrack = track;
    final canUsePreloaded = engine.isPreloaded &&
        _preloadedTrackId != null &&
        _preloadedTrackId == track.id;

    try {
      if (doPlay) {
        await ensureAudioSessionConfigured();
        final granted = await _activateAudioSession();
        if (!alive()) return;
        if (!granted) {
          SnackbarService.showMessage(
              'Audio focus denied. Cannot start playback.');
          return done();
        }
      }

      _currentResolveOp?.cancel();

      try {
        _updateCurrentTrack(track);
      } catch (e) {
        log('_updateCurrentTrack failed: $e', name: 'BloomeeMusicPlayer');
      }
      engine.setLoadingState();
      isResolving.add(true);

      EngineResult transitionResult;

      if (!crossfadeEnabled) {
        if (canUsePreloaded) {
          // Preloaded path: the stream was resolved earlier by _preResolveNextTrack.
          // We don't have access to its resolvedPluginId here, so clear the cached value the preloaded track's embedded plugin ID will be used for radio.
          // This works because preloading only succeeds when the original plugin is active (it was able to resolve the stream), so its plugin ID is valid.
          _lastResolvedPluginId = null;
          _setOfflineState(_preloadedTrackOffline);
          transitionResult = await engine.activatePreloaded(autoPlay: doPlay);
          _clearPreloadedMarker();
        } else {
          await engine.stop(keepLoadingState: true);
          if (!alive()) return;

          final resolveOp = CancelableOperation.fromFuture(
            _resolveTrackWithAutoReplacement(track)
                .timeout(const Duration(seconds: 15)),
          );

          final result = await resolveOp.valueOrCancellation();
          if (result == null || !alive()) return;
          resolvedTrack = result.$1;
          if (resolvedTrack.id != track.id) {
            _updateCurrentTrack(resolvedTrack);
          }

          // Cache the plugin that actually served this stream so that _checkRelatedSongs can forward it to RelatedSongsManager.
          _lastResolvedPluginId = result.$2.resolvedPluginId;

          _setOfflineState(result.$2.isOffline);
          transitionResult = await engine.openDirect(
            result.$2.uri,
            httpHeaders: result.$2.headers,
            autoPlay: doPlay,
          );
        }
      } else {
        if (canUsePreloaded) {
          // See comment in the non-crossfade preloaded branch above.
          _lastResolvedPluginId = null;
          _setOfflineState(_preloadedTrackOffline);
          transitionResult =
              await engine.crossfadeToPreloaded(engine.crossfadeDuration);
          _clearPreloadedMarker();
        } else {
          await engine.stop(keepLoadingState: true);
          if (!alive()) return;

          final resolveOp = CancelableOperation.fromFuture(
            _resolveTrackWithAutoReplacement(track)
                .timeout(const Duration(seconds: 15)),
          );

          final result = await resolveOp.valueOrCancellation();
          if (result == null || !alive()) return;
          resolvedTrack = result.$1;
          if (resolvedTrack.id != track.id) {
            _updateCurrentTrack(resolvedTrack);
          }

          // Cache the plugin that actually served this stream.
          _lastResolvedPluginId = result.$2.resolvedPluginId;

          _setOfflineState(result.$2.isOffline);
          transitionResult = await engine.openDirect(
            result.$2.uri,
            httpHeaders: result.$2.headers,
            autoPlay: doPlay,
          );
        }
      }

      if (!alive()) return;

      if (transitionResult is EngineFailure) {
        isResolving.add(false);
        final err = transitionResult.error;
        final type = _errorHandler.categorizeError(err);
        _errorHandler.handleError(type, err.toString(), resolvedTrack, err);
        return done();
      }

      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      isResolving.add(false);
      _errorHandler.clearError();

      _preResolveNextTrack();
      await _checkRelatedSongs();

      log('Now playing: ${track.title}', name: 'BloomeeMusicPlayer');
      done();
    } on TimeoutException catch (e) {
      isResolving.add(false);
      if (!alive()) return;
      log('Timeout loading ${track.title}: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
          PlayerErrorType.networkError, 'Network timeout', track, e);
      done();
    } catch (e, stackTrace) {
      isResolving.add(false);
      if (!alive()) return;
      log('Failed to play ${track.title}: $e',
          name: 'BloomeeMusicPlayer', error: e, stackTrace: stackTrace);
      final type = _errorHandler.categorizeError(e);
      _errorHandler.handleError(type, e.toString(), resolvedTrack, e);
      done();
    }
  }

  Future<(Track, ResolvedMediaSource)> _resolveTrackWithAutoReplacement(
    Track track,
  ) async {
    try {
      final resolved = await _resolver.resolve(track);
      return (track, resolved);
    } catch (error) {
      final replacement = await _tryAutoResolveUnavailableTrack(track, error);
      if (replacement == null) rethrow;
      final resolved = await _resolver.resolve(replacement);
      return (replacement, resolved);
    }
  }

  Future<Track?> _tryAutoResolveUnavailableTrack(
    Track track,
    Object error,
  ) async {
    if (!_isAutoResolvableError(error) || isLocalMediaId(track.id)) {
      return null;
    }

    final enabled = await SettingsDAO(DBProvider.db).getSettingBool(
      SettingKeys.autoResolveUnavailableTracks,
    );
    if (enabled == false) return null;

    final replacementCandidate =
        await _smartTrackReplacementService.findBestReplacement(track);
    if (replacementCandidate == null) return null;

    SnackbarService.showMessage(
      'Playing a fallback source for ${track.title} from ${replacementCandidate.pluginName}.',
      duration: const Duration(seconds: 3),
    );
    return replacementCandidate.track;
  }

  bool _isAutoResolvableError(Object error) {
    if (error is PluginNotLoadedException || error is PluginNotFoundException) {
      return true;
    }
    final message = error.toString().toLowerCase();
    return message.contains('no streams returned') ||
        message.contains('plugin is not loaded') ||
        message.contains('plugin not found');
  }

  void _updateCurrentTrack(Track track) {
    _currentTrack = track;
    mediaItem.add(trackToMediaItem(_currentTrack));
    _syncCurrentMediaItemDuration(engine.state, engine.position);
  }

  void _syncCurrentMediaItemDuration(EngineState state, Duration position) {
    if (_currentTrack.id == trackNull.id) return;

    final media = mediaItem.valueOrNull;
    if (media == null || media.id != _currentTrack.id) return;

    final engineDuration = engine.duration;
    Duration? effectiveDuration;
    if (engineDuration > Duration.zero) {
      effectiveDuration = engineDuration;
    } else if (_currentTrack.durationMs != null) {
      effectiveDuration =
          Duration(milliseconds: _currentTrack.durationMs!.toInt());
    }

    final targetPosition =
        state == EngineState.completed && effectiveDuration != null
            ? effectiveDuration
            : position;

    if (media.duration != effectiveDuration) {
      mediaItem.add(media.copyWith(duration: effectiveDuration));
    }

    if (playbackState.hasValue) {
      final current = playbackState.value;
      final shouldRefreshPosition = current.updatePosition != targetPosition ||
          current.queueIndex != _queueManager.currentIndex;
      if (shouldRefreshPosition) {
        playbackState.add(current.copyWith(
          updatePosition: targetPosition,
          queueIndex: _queueManager.currentIndex,
        ));
      }
    }
  }

  // ─── Preload ───────────────────────────────────────────────────────────────

  void _preResolveNextTrack() {
    final nextTrack = _queueManager.peekNext(loopMode: loopMode.value);
    if (nextTrack == null) {
      _clearPreloadedMarker();
      unawaited(engine.clearPreload());
      return;
    }

    final expectedId = nextTrack.id;
    _preResolveOp?.cancel();

    _preResolveOp =
        CancelableOperation.fromFuture(_resolver.resolve(nextTrack));
    _preResolveOp!.value.then((result) async {
      if (_isDisposed) return;

      final stillNext = _queueManager.peekNext(loopMode: loopMode.value);
      if (stillNext?.id != expectedId) {
        _clearPreloadedMarker();
        unawaited(engine.clearPreload());
        return;
      }

      final success = await engine.preloadNext(
        result.uri,
        httpHeaders: result.headers,
      );

      if (!_isDisposed && success) {
        _preloadedTrackId = expectedId;
        _preloadedTrackOffline = result.isOffline;
      }
    }).catchError((e) {
      log('Pre-resolve failed: $e', name: 'BloomeeMusicPlayer');
      _clearPreloadedMarker();
      unawaited(engine.clearPreload());
    });
  }

  // ─── Auto-next / Completion ────────────────────────────────────────────────

  void _onTrackCompleted() {
    if (loopMode.value == LoopMode.one || _isAdvancing) return;
    _isAdvancing = true;

    Future.microtask(() async {
      try {
        final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
        if (advanced) {
          final next = _queueManager.currentTrack;
          if (next != null) await _enqueuePlayTrack(next, doPlay: true);
        } else {
          await engine.stop();
        }
      } catch (e) {
        log('Auto-next failed: $e', name: 'BloomeeMusicPlayer');
      } finally {
        _isAdvancing = false;
      }
    });
  }

  Future<void> _retryCurrentTrack() async {
    final track = _queueManager.currentTrack;
    if (track == null) return;
    final pos = engine.position;
    log('Retrying: ${track.title} at $pos', name: 'BloomeeMusicPlayer');
    try {
      _errorHandler.clearError();
      await _enqueuePlayTrack(track, doPlay: true, initialPosition: pos);
    } catch (e) {
      log('Retry failed: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
          PlayerErrorType.playbackError, 'Retry failed: $e', track, e);
    }
  }

  Future<void> _checkRelatedSongs() async {
    if (_checkingRelated) return;
    _checkingRelated = true;

    try {
      final track = _queueManager.currentTrack;
      if (track == null) return;
      final queueItems = _queueManager.tracks;

      await _relatedSongsManager.checkForRelatedSongs(
        currentMedia: track,
        queue: queueItems,
        currentPlayingIdx: _queueManager.currentIndex,
        loopMode: loopMode.value,
        // Forward the plugin that actually resolved the stream.
        // When cross-plugin fallback was used (e.g. ytmusic disabled, stream served by youtube plugin instead), this ensures getRadioTracks is sent to the active fallback plugin rather than the disabled original, so the Auto-Mix queue is built correctly.
        resolvedPluginId: _lastResolvedPluginId,
      );
    } finally {
      _checkingRelated = false;
    }
  }

  Future<void> check4RelatedSongs() => _checkRelatedSongs();

  // ─── Recently Played Config ────────────────────────────────────────────────

  void setRecentlyPlayedThresholdSeconds(int seconds) {
    _recentlyPlayedTracker.setThresholdSeconds(seconds);
  }

  void setRecentlyPlayedPercentThreshold(double percent) {
    _recentlyPlayedTracker.setPercentThreshold(percent);
  }

  // ─── Player Health ─────────────────────────────────────────────────────────

  bool get isPlayerHealthy => !_isDisposed;

  Future<void> revive() async {
    if (!_isDisposed) return;
    log('Reviving BloomeeMusicPlayer...', name: 'BloomeeMusicPlayer');

    _initEngine();
    _initModules();
    _initSubscriptions();
    _initAudioSession();
    _restoreEngineSettings();
    _isDisposed = false;
    _audioSessionConfigured = false;
    _lastAudioSessionConfiguredAt = null;
    _volumeBeforeDuck = null;
    _resumeAfterInterruption = false;
    _lastResolvedPluginId = null;
    isResolving.add(false);

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  // ─── Queue Operations (BaseAudioHandler interface) ────────────────────────

  @override
  Future<void> playMediaItem(MediaItem mediaItem,
      {bool doPlay = true, Duration? initialPosition}) async {
    _errorHandler.resetCircuitBreaker(); // User intent: reset errors
    final track = mediaItemToTrack(mediaItem);
    await _enqueuePlayTrack(track,
        doPlay: doPlay, initialPosition: initialPosition);
  }

  @override
  Future<void> skipToNext() async {
    _errorHandler.resetCircuitBreaker(); // User intent: reset errors
    await _internalSkipToNext();
  }

  Future<void> _internalSkipToNext() async {
    _isAdvancing = true;
    try {
      final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
      if (advanced) {
        final next = _queueManager.currentTrack;
        if (next != null) await _enqueuePlayTrack(next, doPlay: true);
      } else {
        _playCompleter?.operation.cancel();
        _playCompleter = null;
        _currentResolveOp?.cancel();
        await engine.stop();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    _errorHandler.resetCircuitBreaker(); // User intent: reset errors
    await _internalSkipToPrevious();
  }

  Future<void> _internalSkipToPrevious() async {
    _isAdvancing = true;
    try {
      final advanced =
          _queueManager.advanceToPrevious(loopMode: loopMode.value);
      if (advanced) {
        final prev = _queueManager.currentTrack;
        if (prev != null) await _enqueuePlayTrack(prev, doPlay: true);
      } else {
        _playCompleter?.operation.cancel();
        _playCompleter = null;
        _currentResolveOp?.cancel();
        await engine.stop();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _errorHandler.resetCircuitBreaker(); // User intent: reset errors
    // Guard exactly like _internalSkipToNext so a stale completion event
    // from the previous track cannot race with the user's explicit jump and
    // advance _currentIndex past the intended position.
    _isAdvancing = true;
    try {
      _queueManager.jumpTo(index);
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    } finally {
      _isAdvancing = false;
    }
  }

  Future<void> loadPlaylist(Playlist playlist,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    _errorHandler.resetCircuitBreaker(); // User intent: reset errors
    // Prevent any in-flight completion event from racing with our intent.
    // Without this, a song finishing right as the user loads a new playlist
    // can call advanceToNext() on the freshly-loaded queue, shifting
    // _currentIndex and causing the wrong track to start.
    _isAdvancing = true;
    try {
      fromPlaylist.add(true);
      _relatedSongsManager.clearRelatedSongs();
      _lastResolvedPluginId = null;

      final sanitizedTracks = playlist.tracks
          .where((track) =>
              track.id.trim().isNotEmpty && track.title.trim().isNotEmpty)
          .toList();

      if (sanitizedTracks.isEmpty) {
        SnackbarService.showMessage(
          'This section has no playable tracks.',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      _clearPreloadedMarker();

      _queueManager.loadTracks(
        sanitizedTracks,
        playlistName: playlist.title,
        idx: idx,
        shuffling: shuffling,
      );
      queueTitle.add(playlist.title);

      if (doPlay || shuffling) {
        final track = _queueManager.currentTrack;
        if (track != null) await _enqueuePlayTrack(track, doPlay: true);
      }
    } catch (e, stack) {
      log('loadPlaylist failed',
          name: 'BloomeeMusicPlayer', error: e, stackTrace: stack);
      SnackbarService.showMessage(
        'Unable to start playback for this playlist.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queueManager.addTrack(mediaItemToTrack(mediaItem));
  }

  Future<void> addQueueTrack(Track track) async {
    _queueManager.addTrack(track);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = 'Queue', bool atLast = false}) async {
    final tracks = mediaItems.map(mediaItemToTrack).toList();
    _queueManager.addTracks(tracks, atLast: atLast);
  }

  Future<void> addQueueTracks(List<Track> tracks, {bool atLast = false}) async {
    _queueManager.addTracks(tracks, atLast: atLast);
  }

  Future<void> updateQueueTracks(List<Track> tracks,
      {bool doPlay = false, int startIndex = 0}) async {
    _queueManager.updateQueue(tracks, startIndex: startIndex);
    if (doPlay) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  Future<void> addPlayNextItem(MediaItem item) async {
    _queueManager.addPlayNext(mediaItemToTrack(item));
  }

  Future<void> addPlayNextTrack(Track track) async {
    _queueManager.addPlayNext(track);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    // _queueSyncSub already propagates the change to the audio_service
    // queue via _queueManager.tracksStream. Calling super.insertQueueItem
    // would double-write to the queue subject and risk ordering issues.
    _queueManager.insertTrack(index, mediaItemToTrack(mediaItem));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    _queueManager.removeTrackAt(index);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    _queueManager.moveTrack(oldIndex, newIndex);
  }

  /// Clear the queue, keeping only the currently playing track.
  void clearQueue() {
    _clearPreloadedMarker();
    _queueManager.clearQueue();
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue, {bool doPlay = false}) async {
    final tracks = queue.map(mediaItemToTrack).toList();
    _queueManager.updateQueue(tracks);
    if (doPlay) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  Future<void> replaceTrackInQueue(Track replacement) async {
    final changed = _queueManager.replaceTrackById(replacement.id, replacement);
    if (!changed) {
      return;
    }

    if (_currentTrack.id == replacement.id) {
      _updateCurrentTrack(replacement);
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    try {
      await engine.dispose();
    } catch (_) {}

    await _cleanup();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
    await _cleanup();
    return super.onNotificationDeleted();
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _playCompleter?.operation.cancel();
    _playCompleter = null;
    _preResolveOp?.cancel();
    _currentResolveOp?.cancel();

    _relatedSongTimer?.cancel();
    await _engineStateSub?.cancel();
    await _completionSub?.cancel();
    await _errorSub?.cancel();
    await _queueSyncSub?.cancel();
    await _positionSuccessSub?.cancel(); // Cancel success verifier
    await _audioInterruptionSub?.cancel();
    await _audioNoisySub?.cancel();

    _errorHandler.dispose();
    _queueManager.dispose();
    _relatedSongsManager.dispose();
    await _recentlyPlayedTracker.dispose();
    isResolving.add(false);

    DiscordService.clearPresence();

    try {
      await engine.dispose();
    } catch (e) {
      log('Error disposing engine: $e', name: 'BloomeeMusicPlayer');
    }

    await _deactivateAudioSession();

    fromPlaylist.add(false);
    _setOfflineState(false);
    loopMode.add(LoopMode.off);
    _lastResolvedPluginId = null;

    await super.stop();
  }
}