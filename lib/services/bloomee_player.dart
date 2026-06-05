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
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/meta_resolver/smart_track_replacement_service.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:async/async.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

/// BloomeeTunes main audio player.
///
/// Extends [BaseAudioHandler] so the OS MediaSession contract is satisfied:
/// the notification, headset buttons, lock screen, and Android Auto all work
/// correctly without any extra native code.
///
/// ## Audio Session / Focus Lifecycle
/// AudioSession.configure() is called **before** this class is instantiated
/// (in audio_service_initializer.dart → setupPlayerCubit()). By the time the
/// first user tap reaches play(), the session is already fully configured and
/// setActive(true) → requestAudioFocus() is guaranteed to work.
///
/// ## Interruption Handling
/// The handler is **synchronous** — matches the official audio_session example.
/// Per the audio_session documentation:
///   - AudioInterruptionType.pause END → auto-resume (e.g. call ended)
///   - AudioInterruptionType.unknown END → do NOT auto-resume (user must press play)
/// The `_shouldResumeAfterInterruption` bool is a single field encoding one decision.
///
/// ## Concurrency
/// All play/resolve operations use [CancelableCompleter] / [CancelableOperation]
/// so that rapid track skipping never leaves orphaned network requests.
class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late PlayerEngine engine;

  late PlayerErrorHandler _errorHandler;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late RecentlyPlayedTracker _recentlyPlayedTracker;
  late MediaResolverService _resolver;
  late SmartTrackReplacementService _smartTrackReplacementService;

  // Long-lived stream subjects — kept open to prevent downstream StreamBuilder
  // widgets from entering error state when the player is revived.
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);
  BehaviorSubject<bool> isResolving = BehaviorSubject<bool>.seeded(false);

  bool _isDisposed = false;

  // ── Concurrency tokens ─────────────────────────────────────────────────────
  CancelableCompleter<void>? _playCompleter;
  CancelableOperation<ResolvedMediaSource>? _preResolveOp;
  CancelableOperation<(Track, ResolvedMediaSource)>? _currentResolveOp;
  bool _isAdvancing = false;

  // ── Preload identity ───────────────────────────────────────────────────────
  String? _preloadedTrackId;
  bool _preloadedTrackOffline = false;

  // ── Stream subscriptions ───────────────────────────────────────────────────
  StreamSubscription? _engineStateSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _queueSyncSub;
  StreamSubscription? _positionSuccessSub;
  StreamSubscription<AudioInterruptionEvent>? _audioInterruptionSub;
  StreamSubscription<void>? _audioNoisySub;
  Timer? _relatedSongTimer;

  // ── Audio session state ────────────────────────────────────────────────────
  AudioSession? _audioSession;
  // Volume before duck — restored when duck ends.
  double? _volumeBeforeDuck;
  // True only when we paused due to an interruption with AudioInterruptionType.pause.
  // Per audio_session docs: only resume automatically on 'pause' end, never on 'unknown'.
  bool _shouldResumeAfterInterruption = false;

  // ── M-12 ──────────────────────────────────────────────────────────────────
  Duration _savedPositionForRevive = Duration.zero;

  // ── Modular component accessors ───────────────────────────────────────────
  BehaviorSubject<bool> get shuffleMode => _queueManager.shuffleMode;
  BehaviorSubject<PlayerError?> get lastError => _errorHandler.lastError;
  BehaviorSubject<List<Track>> get relatedSongs =>
      _relatedSongsManager.relatedSongs;

  @override
  BehaviorSubject<String> get queueTitle => _queueManager.queueTitle;

  Track _currentTrack = trackNull;
  Track get currentTrackInfo => _currentTrack;
  List<Track> get queueTracks => List<Track>.unmodifiable(_queueManager.tracks);
  int get currentQueueIndex => _queueManager.currentIndex;
  PluginService get pluginService => ServiceLocator.pluginService;

  // ─── Constructor ───────────────────────────────────────────────────────────

  BloomeeMusicPlayer() {
    _initEngine();
    _initModules();
    _initSubscriptions();
    _setupInterruptionListeners();
    // Engine settings (EQ, crossfade) restore happens async — acceptable
    // because the first play() will work with defaults until restore completes.
    _restoreEngineSettings();
    // Session restore runs after engine settings but does NOT auto-play.
    _restoreLastSession();
  }

  /// Restores the last queue from SettingsDAO so the user sees it on relaunch.
  ///
  /// Intentionally does NOT auto-play — the user must tap play to resume.
  /// Guarded by [_isDisposed] so a rapid dispose() during cold start is safe.
  Future<void> _restoreLastSession() async {
    if (_isDisposed) return;
    try {
      final restored = await _queueManager.restoreQueueState();
      if (_isDisposed) return; // re-check after await
      if (restored) {
        final track = _queueManager.currentTrack;
        if (track != null) {
          _updateCurrentTrack(track);
        }
      }
    } catch (e) {
      log('Session restore failed: $e', name: 'BloomeeMusicPlayer');
    }
  }

  // ─── Engine & Module Initialization ───────────────────────────────────────

  void _initEngine() {
    _isDisposed = false;
    engine = PlayerEngine();
  }

  /// Attaches to the already-configured AudioSession singleton and subscribes
  /// to interruption events. Since setupAudioSession() ran before this class
  /// was constructed, AudioSession.instance is guaranteed to be configured.
  ///
  /// This method is synchronous in its listener setup — it only calls `.then()`
  /// to retrieve the singleton, not to do async work. The listeners themselves
  /// are synchronous per the official audio_session example pattern.
  void _setupInterruptionListeners() {
    AudioSession.instance.then((session) {
      if (_isDisposed) return;
      _audioSession = session;

      // Cancel any existing subs first (safe for revive() calls).
      _audioInterruptionSub?.cancel();
      _audioNoisySub?.cancel();

      // Synchronous listener body: per audio_session official example, the
      // handler does NOT use async/await. Operations like pause/play are
      // called fire-and-forget — the engine queues them internally.
      _audioInterruptionSub =
          session.interruptionEventStream.listen(_handleInterruptionSync);

      _audioNoisySub = session.becomingNoisyEventStream
          .listen((_) => _onHeadphonesUnplugged());
    });
  }

  // ─── Interruption Handler ─────────────────────────────────────────────────

  /// Synchronous interruption handler.
  ///
  /// CRITICAL: This MUST be synchronous. The audio_session official example
  /// (pub.dev/packages/audio_session/example) uses synchronous calls throughout.
  /// Async handlers create a race: if BEGIN and END events arrive close together
  /// (short call, short notification), two async handlers can run concurrently
  /// and read/write `_shouldResumeAfterInterruption` in undefined order.
  ///
  /// Per the audio_session documentation:
  ///   - `pause` END   → interruption ended, auto-resume
  ///   - `unknown` END → interruption ended, do NOT auto-resume (user presses play)
  void _handleInterruptionSync(AudioInterruptionEvent event) {
    if (_isDisposed) return;

    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          // Lower volume to 35% for notifications/navigation. Restore on end.
          _volumeBeforeDuck ??= engine.volume;
          engine.setVolume((engine.volume * 0.35).clamp(0.0, 1.0));

        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          // Both map to "pause" on begin — the distinction matters only on END.
          _shouldResumeAfterInterruption = engine.playing;
          engine.pause(); // fire-and-forget — engine queues the command
      }
      return;
    }

    // — Interruption ended —
    switch (event.type) {
      case AudioInterruptionType.duck:
        final prev = _volumeBeforeDuck;
        _volumeBeforeDuck = null;
        if (prev != null) engine.setVolume(prev.clamp(0.0, 1.0));

      case AudioInterruptionType.pause:
        // e.g. short phone call ended, alarm finished → auto-resume.
        if (_shouldResumeAfterInterruption) {
          _shouldResumeAfterInterruption = false;
          _resumePlaybackAfterInterruption();
        }

      case AudioInterruptionType.unknown:
        // Per audio_session docs: "The interruption ended but we should NOT resume."
        // This includes the case where the OS sends AUDIOFOCUS_LOSS (permanent)
        // followed later by AUDIOFOCUS_GAIN — the user should press play manually.
        _shouldResumeAfterInterruption = false;
    }
  }

  /// Re-requests audio focus and resumes playback after an interruption ends.
  /// Called fire-and-forget from the synchronous handler.
  void _resumePlaybackAfterInterruption() {
    _activateAudioSession().then((granted) {
      if (granted && !_isDisposed) engine.play();
    }).catchError((Object e) {
      log('Resume after interruption failed: $e', name: 'BloomeeMusicPlayer');
    });
  }

  void _onHeadphonesUnplugged() {
    if (!_isDisposed) engine.pause();
  }

  // ─── Audio Session Activation ──────────────────────────────────────────────

  Future<bool> _activateAudioSession() async {
    try {
      final session = _audioSession ?? await AudioSession.instance;
      _audioSession = session;
      return await session.setActive(true);
    } catch (e) {
      log('setActive(true) failed: $e', name: 'BloomeeMusicPlayer');
      return false;
    }
  }

  Future<void> _deactivateAudioSession() async {
    try {
      await _audioSession?.setActive(false);
    } catch (_) {}
  }

  // ─── Engine Settings Restore ───────────────────────────────────────────────

  Future<void> _restoreEngineSettings() async {
    try {
      final dao = SettingsDAO(DBProvider.db);

      final cfStr = await dao.getSettingStr(SettingKeys.crossfadeDuration);
      engine.crossfadeDuration =
          Duration(seconds: int.tryParse(cfStr ?? '0') ?? 0);

      final eqSource = await dao.getSettingStr(SettingKeys.eqSource);
      if (eqSource == EqSourceValues.device) {
        // Device EQ mode: in-app EQ must stay off.
        await engine.setEqualizerEnabled(false);
        return;
      }

      final gainsJson = await dao.getSettingStr(SettingKeys.eqBandGains);
      if (gainsJson != null) {
        try {
          final gains = (jsonDecode(gainsJson) as List)
              .map((e) => (e as num).toDouble())
              .toList();
          if (gains.length == 10) {
            await engine.setEqualizerBandGains(gains, immediate: true);
          }
        } catch (_) {}
      }

      final eqOn = await dao.getSettingBool(SettingKeys.eqEnabled) ?? false;
      await engine.setEqualizerEnabled(eqOn);
    } catch (e) {
      log('restoreEngineSettings failed: $e', name: 'BloomeeMusicPlayer');
    }
  }

  // ─── Module Init ───────────────────────────────────────────────────────────

  void _initModules() {
    _errorHandler = PlayerErrorHandler();
    _queueManager = QueueManager();
    _relatedSongsManager = RelatedSongsManager(ServiceLocator.pluginService);
    _resolver = MediaResolverService.create(ServiceLocator.pluginService);
    _smartTrackReplacementService =
        SmartTrackReplacementService.create(ServiceLocator.pluginService);

    _errorHandler.onSkipToNext = _internalSkipToNext;
    _errorHandler.onRetryCurrentTrack = _retryCurrentTrack;
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

  // ─── Subscriptions ─────────────────────────────────────────────────────────

  void _initSubscriptions() {
    // Combine engine state signals into a single broadcast.
    _engineStateSub = Rx.combineLatest4(
      engine.stateStream,
      engine.playingStream,
      engine.bufferedStream,
      engine.speedStream,
      (s, pl, buf, spd) => (s, pl, buf, spd),
    ).distinct().listen((r) {
      final (s, pl, buf, spd) = r;
      _broadcastPlaybackState(s, pl, engine.position, buf, spd);
    });

    // Mark a track as successfully playing only once we see real position
    // advancement — guards circuit breaker against false positives.
    _positionSuccessSub = engine.positionStream.listen((pos) {
      if (pos > Duration.zero &&
          engine.state == EngineState.ready &&
          engine.playing) {
        final track = _queueManager.currentTrack;
        if (track != null) _errorHandler.markTrackSuccess(track.id);
      }
    });

    _completionSub = engine.completionStream.listen((_) => _onTrackCompleted());

    _errorSub = engine.errorStream.listen((error) {
      log('Engine error: $error', name: 'BloomeeMusicPlayer');
      final track = _queueManager.currentTrack;
      if (track != null) {
        _errorHandler.handleError(PlayerErrorType.playbackError, error, track);
      }
    });

    _queueSyncSub = _queueManager.tracksStream.listen((tracks) {
      queue.add(tracks.map(trackToMediaItem).toList());
      // Don't persist during restore — we'd just write back what we read.
      if (_queueManager.isRestoring) return;
      // Throttle persistence writes — queue mutations can fire in rapid bursts
      // (e.g. batch-loading a 50-track playlist). 2s throttle coalesces them
      // into a single DB write while still capturing the final state.
      EasyThrottle.throttle(
        'persist_queue',
        const Duration(seconds: 2),
        () => unawaited(_queueManager.persistQueueState()),
      );
    });

    // M-11: Related songs check fires every 15s, but only if actively playing.
    // A 15-second Timer.periodic is negligible battery impact — no need for
    // a reactive subscription approach that adds implementation complexity.
    _relatedSongTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isDisposed && engine.playing) _checkRelatedSongs();
    });
  }

  // ─── Playback State Broadcast ─────────────────────────────────────────────

  void _broadcastPlaybackState(EngineState state, bool playing,
      Duration position, Duration buffered, double speed) {
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
    ));

    EasyThrottle.throttle('discord_rpc', const Duration(seconds: 1), () {
      DiscordService.updatePresence(
          track: currentTrackInfo, isPlaying: playing);
    });
  }

  // ─── Track Identity ───────────────────────────────────────────────────────

  Track get currentMedia => _queueManager.currentTrack ?? trackNull;

  void _updateCurrentTrack(Track track) {
    _currentTrack = track;
    mediaItem.add(trackToMediaItem(track));
  }

  // ─── Public Playback Controls ─────────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_isDisposed) return;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    final granted = await _activateAudioSession();
    if (!granted) {
      SnackbarService.showMessage('Audio focus denied. Cannot start playback.');
      return;
    }
    // Cold resume: engine has nothing loaded, but queue has a track
    // (happens after session restore). Resolve and play the current track.
    if (engine.state == EngineState.idle) {
      final track = _queueManager.currentTrack;
      if (track != null) {
        await _enqueuePlayTrack(track, doPlay: true);
        return;
      }
    }
    await engine.play();
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    // Manual pause clears any pending auto-resume.
    _shouldResumeAfterInterruption = false;
    await engine.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    await engine.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    if (_isDisposed) return;
    final dur = engine.duration;
    await engine.seek(engine.position + n > dur ? dur : engine.position + n);
  }

  Future<void> seekNSecBackward(Duration n) async {
    if (_isDisposed) return;
    final back = engine.position - n;
    await engine.seek(back < Duration.zero ? Duration.zero : back);
  }

  @override
  Future<void> stop() async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
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

  // ─── Loop / Shuffle ────────────────────────────────────────────────────────

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

  // ─── Core Play Dispatch ────────────────────────────────────────────────────

  void _clearPreloadedMarker() {
    _preloadedTrackId = null;
    _preloadedTrackOffline = false;
  }

  Future<void> _enqueuePlayTrack(
    Track track, {
    bool doPlay = true,
    Duration? initialPosition,
  }) {
    if (_isDisposed) return Future.value();

    // Cancel any in-flight play operation — user changed track.
    final prev = _playCompleter;
    final completer = CancelableCompleter<void>(
      onCancel: () => log('Track load cancelled: ${track.title}',
          name: 'BloomeeMusicPlayer'),
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
    void complete() {
      if (!token.isCompleted && !token.isCanceled) token.complete();
    }

    if (!alive()) return;

    var resolvedTrack = track;
    final canUsePreloaded = engine.isPreloaded &&
        _preloadedTrackId != null &&
        _preloadedTrackId == track.id;

    try {
      _updateCurrentTrack(track);

      if (doPlay) {
        final granted = await _activateAudioSession();
        if (!alive()) return;
        if (!granted) {
          SnackbarService.showMessage(
              'Audio focus denied. Cannot start playback.');
          return complete();
        }
      }

      _currentResolveOp?.cancel();
      engine.setLoadingState();
      isResolving.add(true);

      EngineResult result;

      if (canUsePreloaded) {
        isOffline.add(_preloadedTrackOffline);
        result = engine.crossfadeDuration > Duration.zero
            ? await engine.crossfadeToPreloaded(engine.crossfadeDuration)
            : await engine.activatePreloaded(autoPlay: doPlay);
        _clearPreloadedMarker();
      } else {
        await engine.stop(keepLoadingState: true);
        if (!alive()) return;

        _currentResolveOp = CancelableOperation.fromFuture(
          _resolveWithFallback(track).timeout(const Duration(seconds: 15)),
        );
        final resolved = await _currentResolveOp!.valueOrCancellation();
        if (resolved == null || !alive()) return;

        resolvedTrack = resolved.$1;
        if (resolvedTrack.id != track.id) _updateCurrentTrack(resolvedTrack);
        isOffline.add(resolved.$2.isOffline);

        result = await engine.openDirect(
          resolved.$2.uri,
          httpHeaders: resolved.$2.headers,
          autoPlay: doPlay,
        );
      }

      if (!alive()) return;

      if (result is EngineFailure) {
        isResolving.add(false);
        _errorHandler.handleError(
          _errorHandler.categorizeError(result.error),
          result.error.toString(),
          resolvedTrack,
          result.error,
        );
        return complete();
      }

      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      isResolving.add(false);
      _errorHandler.clearError();
      _preResolveNextTrack();
      _checkRelatedSongs();
      complete();
    } on TimeoutException catch (e) {
      isResolving.add(false);
      if (!alive()) return;
      _errorHandler.handleError(
          PlayerErrorType.networkDropped, 'Network timeout', track, e);
      complete();
    } catch (e, stack) {
      isResolving.add(false);
      if (!alive()) return;
      log('Play failed: ${track.title}: $e',
          name: 'BloomeeMusicPlayer', stackTrace: stack);
      _errorHandler.handleError(
          _errorHandler.categorizeError(e), e.toString(), resolvedTrack, e);
      complete();
    }
  }

  Future<(Track, ResolvedMediaSource)> _resolveWithFallback(Track track) async {
    try {
      return (track, await _resolver.resolve(track));
    } catch (e) {
      final replacement = await _tryAutoReplace(track, e);
      if (replacement == null) rethrow;
      return (replacement, await _resolver.resolve(replacement));
    }
  }

  Future<Track?> _tryAutoReplace(Track track, Object error) async {
    if (!_isAutoResolvableError(error) || isLocalMediaId(track.id)) return null;
    final enabled = await SettingsDAO(DBProvider.db)
        .getSettingBool(SettingKeys.autoResolveUnavailableTracks);
    if (enabled == false) return null;
    final candidate =
        await _smartTrackReplacementService.findBestReplacement(track);
    if (candidate == null) return null;
    SnackbarService.showMessage(
      'Playing fallback source for ${track.title} from ${candidate.pluginName}.',
      duration: const Duration(seconds: 3),
    );
    return candidate.track;
  }

  bool _isAutoResolvableError(Object error) {
    if (error is PluginNotLoadedException || error is PluginNotFoundException) {
      return true;
    }
    final msg = error.toString().toLowerCase();
    return msg.contains('no streams returned') ||
        msg.contains('plugin is not loaded') ||
        msg.contains('plugin not found');
  }

  // ─── Preload ───────────────────────────────────────────────────────────────

  void _preResolveNextTrack() {
    final next = _queueManager.peekNext(loopMode: loopMode.value);
    if (next == null) {
      _clearPreloadedMarker();
      engine.clearPreload(); // ignore: discarded_futures
      return;
    }

    final expectedId = next.id;
    _preResolveOp?.cancel();
    _preResolveOp = CancelableOperation.fromFuture(_resolver.resolve(next));
    _preResolveOp!.value.then((resolved) async {
      if (_isDisposed) return;
      if (_queueManager.peekNext(loopMode: loopMode.value)?.id != expectedId) {
        _clearPreloadedMarker();
        engine.clearPreload(); // ignore: discarded_futures
        return;
      }
      final ok =
          await engine.preloadNext(resolved.uri, httpHeaders: resolved.headers);
      if (!_isDisposed && ok) {
        _preloadedTrackId = expectedId;
        _preloadedTrackOffline = resolved.isOffline;
      }
    }).catchError((Object _) {
      _clearPreloadedMarker();
      engine.clearPreload(); // ignore: discarded_futures
    });
  }

  // ─── Completion / Auto-Next ────────────────────────────────────────────────

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
      } finally {
        _isAdvancing = false;
      }
    });
  }

  Future<void> _retryCurrentTrack() async {
    final track = _queueManager.currentTrack;
    if (track == null) return;
    _errorHandler.clearError();
    await _enqueuePlayTrack(track,
        doPlay: true, initialPosition: engine.position);
  }

  // ─── Related Songs ────────────────────────────────────────────────────────

  // bool guard is correct in Dart's single-threaded cooperative model:
  // no two microtasks can read this field simultaneously. The try/finally
  // guarantees it resets even on exception.
  bool _checkingRelated = false;

  Future<void> _checkRelatedSongs() async {
    if (_checkingRelated) return;
    _checkingRelated = true;
    try {
      final track = _queueManager.currentTrack;
      if (track == null) return;
      await _relatedSongsManager.checkForRelatedSongs(
        currentMedia: track,
        queue: _queueManager.tracks,
        currentPlayingIdx: _queueManager.currentIndex,
        loopMode: loopMode.value,
      );
    } finally {
      _checkingRelated = false;
    }
  }

  Future<void> check4RelatedSongs() => _checkRelatedSongs();

  // ─── Player Health ─────────────────────────────────────────────────────────

  bool get isPlayerHealthy {
    if (_isDisposed) return false;
    if (fromPlaylist.isClosed ||
        isOffline.isClosed ||
        loopMode.isClosed ||
        isResolving.isClosed) return false;
    try {
      final _ = engine.state;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Rebuilds the engine and subscriptions when the OS has killed the
  /// underlying audio service (e.g. memory pressure, OEM task killers).
  Future<void> revive() async {
    if (!_isDisposed && isPlayerHealthy) return;
    log('Reviving BloomeeMusicPlayer...', name: 'BloomeeMusicPlayer');

    // Save position before engine teardown (M-12).
    try {
      _savedPositionForRevive = engine.position;
    } catch (_) {}

    if (fromPlaylist.isClosed)
      fromPlaylist = BehaviorSubject<bool>.seeded(false);
    if (isOffline.isClosed) isOffline = BehaviorSubject<bool>.seeded(false);
    if (loopMode.isClosed)
      loopMode = BehaviorSubject<LoopMode>.seeded(LoopMode.off);
    if (isResolving.isClosed) isResolving = BehaviorSubject<bool>.seeded(false);

    _shouldResumeAfterInterruption = false;

    _initEngine();
    _initModules();
    _initSubscriptions();
    _setupInterruptionListeners();
    _restoreEngineSettings();
    _isDisposed = false;

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    // M-12: reload last track at saved position (paused, no auto-play).
    final track = _queueManager.currentTrack;
    if (track != null) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (!_isDisposed) {
          await _enqueuePlayTrack(track,
              doPlay: false, initialPosition: _savedPositionForRevive);
        }
      });
    }
  }

  void syncPublicState() {
    if (_isDisposed) return;
    queue.add(_queueManager.tracks.map(trackToMediaItem).toList());
    final current = _queueManager.currentTrack;
    if (current != null) _updateCurrentTrack(current);
    _broadcastPlaybackState(
      engine.state,
      engine.playing,
      engine.position,
      engine.buffered,
      engine.speed,
    );
  }

  Future<void> replaceTrackInQueue(Track replacement) async {
    if (_isDisposed) return;
    final changed = _queueManager.replaceTrackById(replacement.id, replacement);
    if (!changed) return;
    if (_currentTrack.id == replacement.id) _updateCurrentTrack(replacement);
  }

  // ─── Queue Operations ─────────────────────────────────────────────────────

  @override
  Future<void> playMediaItem(MediaItem mi,
      {bool doPlay = true, Duration? initialPosition}) async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    await _enqueuePlayTrack(mediaItemToTrack(mi),
        doPlay: doPlay, initialPosition: initialPosition);
  }

  @override
  Future<void> skipToNext() async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
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
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
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
        await engine.stop();
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    _isAdvancing = true;
    try {
      _queueManager.jumpTo(index);
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    } finally {
      _isAdvancing = false;
    }
  }

  Future<void> loadPlaylist(
    Playlist playlist, {
    int idx = 0,
    bool doPlay = false,
    bool shuffling = false,
  }) async {
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    _isAdvancing = true;
    try {
      fromPlaylist.add(true);
      _relatedSongsManager.clearRelatedSongs();
      _clearPreloadedMarker();

      final trackToPlay = (idx >= 0 && idx < playlist.tracks.length)
          ? playlist.tracks[idx]
          : null;

      final sanitized = playlist.tracks
          .where((t) => t.id.trim().isNotEmpty && t.title.trim().isNotEmpty)
          .toList();

      if (sanitized.isEmpty) {
        SnackbarService.showMessage('This section has no playable tracks.',
            duration: const Duration(seconds: 2));
        return;
      }

      int newIdx = 0;
      if (trackToPlay != null) {
        final pos = sanitized.indexWhere((t) => t.id == trackToPlay.id);
        newIdx = pos != -1 ? pos : 0;
      }

      _queueManager.loadTracks(sanitized,
          playlistName: playlist.title, idx: newIdx, shuffling: shuffling);
      queueTitle.add(playlist.title);

      if (doPlay || shuffling) {
        final track = _queueManager.currentTrack;
        if (track != null) await _enqueuePlayTrack(track, doPlay: true);
      }
    } finally {
      _isAdvancing = false;
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mi) async =>
      _queueManager.addTrack(mediaItemToTrack(mi));

  Future<void> addQueueTrack(Track track) async =>
      _queueManager.addTrack(track);

  @override
  Future<void> addQueueItems(List<MediaItem> items,
          {String queueName = 'Queue', bool atLast = false}) async =>
      _queueManager.addTracks(items.map(mediaItemToTrack).toList(),
          atLast: atLast);

  Future<void> addQueueTracks(List<Track> tracks,
          {bool atLast = false}) async =>
      _queueManager.addTracks(tracks, atLast: atLast);

  Future<void> updateQueueTracks(List<Track> tracks,
      {bool doPlay = false, int startIndex = 0}) async {
    _queueManager.updateQueue(tracks, startIndex: startIndex);
    if (doPlay) {
      final t = _queueManager.currentTrack;
      if (t != null) await _enqueuePlayTrack(t, doPlay: true);
    }
  }

  Future<void> addPlayNextItem(MediaItem item) async =>
      _queueManager.addPlayNext(mediaItemToTrack(item));

  Future<void> addPlayNextTrack(Track track) async =>
      _queueManager.addPlayNext(track);

  @override
  Future<void> insertQueueItem(int index, MediaItem mi) async =>
      _queueManager.insertTrack(index, mediaItemToTrack(mi));

  @override
  Future<void> removeQueueItemAt(int index) async =>
      _queueManager.removeTrackAt(index);

  Future<void> moveQueueItem(int oldIndex, int newIndex) async =>
      _queueManager.moveTrack(oldIndex, newIndex);

  void clearQueue() {
    _clearPreloadedMarker();
    _queueManager.clearQueue();
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue,
      {bool doPlay = false}) async {
    _queueManager.updateQueue(newQueue.map(mediaItemToTrack).toList());
    if (doPlay) {
      final t = _queueManager.currentTrack;
      if (t != null) await _enqueuePlayTrack(t, doPlay: true);
    }
  }

  void setRecentlyPlayedThresholdSeconds(int s) =>
      _recentlyPlayedTracker.setThresholdSeconds(s);

  void setRecentlyPlayedPercentThreshold(double p) =>
      _recentlyPlayedTracker.setPercentThreshold(p);

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onTaskRemoved() async {
    // Always persist queue before the OS kills us — this is our last chance.
    await _queueManager.persistQueueState();
    // Keep playing in background — only stop if nothing is active.
    if (!engine.playing) {
      await stop();
      await _cleanup();
    }
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
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
    _relatedSongTimer = null;

    await Future.wait([
      _engineStateSub?.cancel() ?? Future.value(),
      _completionSub?.cancel() ?? Future.value(),
      _errorSub?.cancel() ?? Future.value(),
      _queueSyncSub?.cancel() ?? Future.value(),
      _positionSuccessSub?.cancel() ?? Future.value(),
      _audioInterruptionSub?.cancel() ?? Future.value(),
      _audioNoisySub?.cancel() ?? Future.value(),
    ]);

    _errorHandler.dispose();
    _queueManager.dispose();
    _relatedSongsManager.dispose();
    await _recentlyPlayedTracker.dispose();

    DiscordService.clearPresence();
    try {
      await engine.dispose();
    } catch (_) {}
    await _deactivateAudioSession();

    fromPlaylist.add(false);
    isOffline.add(false);
    loopMode.add(LoopMode.off);

    await super.stop();
  }
}
