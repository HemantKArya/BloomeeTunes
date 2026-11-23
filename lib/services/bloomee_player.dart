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
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:rxdart/rxdart.dart';

/// What a playlist's play button does (see
/// [BloomeeMusicPlayer.playOrResumePlaylist]).
enum PlaylistPlayAction { resume, resyncAndResume, load }

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
  late SmartTrackReplacementService _replacements;

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
  bool _playRequested = false;
  Duration _retryPosition = Duration.zero;
  CancelableOperation<(Track, ResolvedMediaSource)>? _preResolveOp;
  CancelableOperation<(Track, ResolvedMediaSource)>? _currentResolveOp;
  bool _isAdvancing = false;

  // ── Preload identity ───────────────────────────────────────────────────────
  String? _preloadedTrackId;
  bool _preloadedTrackOffline = false;
  // The track a preload was last started for (in flight or done).
  String? _preloadTargetId;

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

  /// Unmodifiable.
  List<Track> get queueTracks => _queueManager.tracks;
  int get currentQueueIndex => _queueManager.currentIndex;
  PluginService get pluginService => ServiceLocator.pluginService;
  SmartTrackReplacementService get smartReplacement => _replacements;

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

  Future<void> reloadPreferences() => _restoreEngineSettings();

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
    _replacements =
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

    _relatedSongsManager.onAddQueueItems = _queueManager.addTracks;

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
        if (engine.recoveryPosition > Duration.zero) {
          _retryPosition = engine.recoveryPosition;
        }
        if (_playRequested) {
          _errorHandler.handleError(
              _errorHandler.categorizeError(error), error, track);
        }
      }
    });

    _queueSyncSub = _queueManager.tracksStream.listen((tracks) {
      queue.add(tracks.map(trackToMediaItem).toList());
      _refreshPreloadIfStale();
      // Don't persist during restore — we'd just write back what we read.
      if (_queueManager.isRestoring) return;
      _schedulePersist();
    });

    // M-11: Related songs check fires every 15s, but only if actively playing.
    // A 15-second Timer.periodic is negligible battery impact — no need for
    // a reactive subscription approach that adds implementation complexity.
    _relatedSongTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isDisposed && engine.playing) _checkRelatedSongs();
    });
  }

  /// Persists queue + current index shortly after the last change.
  ///
  /// Trailing debounce (not a leading throttle): bursts of queue edits and
  /// rapid track changes collapse into one write that captures the FINAL
  /// state. Must also run on index-only changes (auto-advance, skips), which
  /// do not emit on tracksStream.
  void _schedulePersist() {
    if (_isDisposed || _queueManager.isRestoring) return;
    EasyDebounce.debounce(
      'persist_queue',
      const Duration(seconds: 1),
      () => unawaited(_queueManager.persistQueueState()),
    );
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
        track: currentTrackInfo,
        isPlaying: playing,
        position: position,
        duration: engine.duration,
      );
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
    _playRequested = true;
    _errorHandler.resetCircuitBreaker();
    _shouldResumeAfterInterruption = false;
    final granted = await _activateAudioSession();
    if (!granted) {
      SnackbarService.showMessage('Audio focus denied. Cannot start playback.');
      return;
    }
    // Cold resume: engine has nothing loaded, but queue has a track
    // (happens after session restore). Resolve and play the current track.
    if (engine.state == EngineState.idle || engine.state == EngineState.error) {
      final track = _queueManager.currentTrack;
      if (track != null) {
        await _enqueuePlayTrack(track,
            doPlay: true, initialPosition: _retryPosition);
        return;
      }
    }
    final current = _queueManager.currentTrack;
    if (current != null) _errorHandler.registerAttempt(current.id);
    await engine.play();
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    _playRequested = false;
    _errorHandler.cancelPendingRetry();
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
    _playRequested = false;
    _retryPosition = Duration.zero;
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
    // Loop-all changes what follows the last track.
    _refreshPreloadIfStale();
  }

  void setCrossfadeDuration(Duration duration) {
    engine.crossfadeDuration = duration;
  }

  Future<void> shuffle(bool enabled) async {
    _queueManager.setShuffle(enabled);
  }

  // ─── Core Play Dispatch ────────────────────────────────────────────────────

  void _clearPreloadedMarker() {
    _preloadedTrackId = null;
    _preloadedTrackOffline = false;
    _preloadTargetId = null;
  }

  Future<void> _enqueuePlayTrack(
    Track track, {
    bool doPlay = true,
    Duration? initialPosition,
  }) {
    if (_isDisposed) return Future.value();
    _playRequested = doPlay;
    _retryPosition = initialPosition ?? Duration.zero;
    // Every track change (skip, auto-advance, jump) funnels through here.
    _schedulePersist();

    // Cancel any in-flight play operation — user changed track.
    final prev = _playCompleter;
    final completer = CancelableCompleter<void>(
      onCancel: () => log('Track load cancelled: ${track.title}',
          name: 'BloomeeMusicPlayer'),
    );
    _playCompleter = completer;
    prev?.operation.cancel();

    _errorHandler.registerAttempt(track.id);
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
        result = engine.crossfadeDuration > Duration.zero && _playRequested
            ? await engine.crossfadeToPreloaded(engine.crossfadeDuration)
            : await engine.activatePreloaded(
                autoPlay: doPlay && _playRequested);
        _clearPreloadedMarker();
      } else {
        await engine.stop(keepLoadingState: true);
        if (!alive()) return;

        _currentResolveOp = CancelableOperation.fromFuture(
          // Plugin HTTP requests can take up to 30 seconds. Do not expire
          // playback at 15 seconds while extraction is still running.
          _resolveWithFallback(track).timeout(const Duration(seconds: 45)),
        );
        final resolved = await _currentResolveOp!.valueOrCancellation();
        if (resolved == null || !alive()) return;

        resolvedTrack = resolved.$1;
        if (resolvedTrack.id != track.id) {
          // Smart Replace swapped in another track: track its success and
          // retries under the id now in the queue.
          _errorHandler.registerAttempt(resolvedTrack.id);
          _updateCurrentTrack(resolvedTrack);
        }
        isOffline.add(resolved.$2.isOffline);

        result = await engine.openDirect(
          resolved.$2.uri,
          httpHeaders: resolved.$2.headers,
          // Complete loading and establish the resume point before deciding
          // to play. Pause may arrive while the native open is awaiting I/O.
          autoPlay: false,
          initialPosition: initialPosition,
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

      if (canUsePreloaded &&
          initialPosition != null &&
          initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      if (!alive()) return;
      if (!canUsePreloaded && doPlay && _playRequested) {
        await engine.play();
      } else if (!_playRequested) {
        await engine.pause();
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

  /// Resolves [track]; if its source is gone, plays a matching track from
  /// another resolver instead (Smart Replace) and swaps it into the queue,
  /// and into the playlists when the match is near-certain, so the search
  /// happens once per dead track. Used for playback and preload alike.
  Future<(Track, ResolvedMediaSource)> _resolveWithFallback(Track track) async {
    try {
      return (track, await _resolver.resolve(track));
    } catch (error, stack) {
      if (!await _shouldAutoReplace(track, error)) rethrow;
      for (final candidate in await _replacements.findAutoReplacements(track)) {
        try {
          final source = await _resolver.resolve(candidate.track);
          _adoptReplacement(track, candidate);
          return (candidate.track, source);
        } catch (e) {
          log('Replacement ${candidate.track.id} unplayable: $e',
              name: 'BloomeeMusicPlayer');
        }
      }
      _replacements.forget(track.id);
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// Network failures are left to the retry logic: a search would fail the
  /// same way, and the track itself is fine.
  Future<bool> _shouldAutoReplace(Track track, Object error) async {
    if (_isDisposed || isLocalMediaId(track.id)) return false;
    if (_errorHandler.categorizeError(error) ==
        PlayerErrorType.networkDropped) {
      return false;
    }
    final enabled = await SettingsDAO(DBProvider.db)
        .getSettingBool(SettingKeys.autoResolveUnavailableTracks);
    return enabled != false;
  }

  void _adoptReplacement(
      Track original, SmartTrackReplacementCandidate candidate) {
    if (_isDisposed) return;
    final replacement = candidate.track;
    // A preload of [original] carries on as the preload of [replacement];
    // without this the queue change would restart it.
    if (_preloadTargetId == original.id) _preloadTargetId = replacement.id;
    _queueManager.replaceTrack(original.id, replacement);
    final persist = candidate.confidence >=
        SmartTrackReplacementService.persistMinConfidence;
    if (persist) {
      unawaited(_replacements
          .applyReplacement(original: original, replacement: replacement)
          .then<void>((_) {}, onError: (Object e) {
        log('Saving replacement failed: $e', name: 'BloomeeMusicPlayer');
      }));
    }
    SnackbarService.showMessage(
      persist
          ? 'Replaced unavailable "${original.title}" with a copy from '
              '${candidate.pluginName}.'
          : 'Playing "${original.title}" from ${candidate.pluginName}.',
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Preload ───────────────────────────────────────────────────────────────

  bool get _isLoadingTrack => !(_playCompleter?.isCompleted ?? true);

  /// Re-preloads when a queue edit or loop change altered the next track.
  /// Never while a track is loading: it would compete for the same plugin.
  void _refreshPreloadIfStale() {
    if (_isDisposed || _isLoadingTrack || engine.state == EngineState.idle) {
      return;
    }
    final nextId = _queueManager.peekNext(loopMode: loopMode.value)?.id;
    if (nextId != _preloadTargetId) _preResolveNextTrack();
  }

  void _preResolveNextTrack() {
    final next = _queueManager.peekNext(loopMode: loopMode.value);
    _preResolveOp?.cancel();
    _preloadTargetId = next?.id;
    if (next == null) {
      _clearPreloadedMarker();
      engine.clearPreload(); // ignore: discarded_futures
      return;
    }

    final op = CancelableOperation.fromFuture(_resolveWithFallback(next));
    _preResolveOp = op;
    op.value.then((resolved) async {
      // [track] is a replacement if [next] was unavailable; the queue
      // already holds it in [next]'s place.
      final (track, source) = resolved;
      if (_isDisposed || op.isCanceled) return;
      if (_queueManager.peekNext(loopMode: loopMode.value)?.id != track.id) {
        _clearPreloadedMarker();
        engine.clearPreload(); // ignore: discarded_futures
        return;
      }
      final ok =
          await engine.preloadNext(source.uri, httpHeaders: source.headers);
      if (!_isDisposed && ok && identical(_preResolveOp, op)) {
        _preloadedTrackId = track.id;
        _preloadedTrackOffline = source.isOffline;
      }
    }).catchError((Object _) {
      if (!identical(_preResolveOp, op)) return;
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
    if (track == null || !_playRequested || _isDisposed) return;
    _errorHandler.clearError();
    await _enqueuePlayTrack(track,
        doPlay: true, initialPosition: _retryPosition);
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
        remaining: () => _queueManager.remaining,
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

  /// Swaps [original] for [replacement] in the queue in place. If
  /// [original] is the current track it is reloaded as [replacement] at the
  /// same position; a dead current track (not loaded) starts afresh.
  Future<void> replaceTrackInQueue(Track replacement, {Track? original}) async {
    if (_isDisposed) return;
    final oldId = original?.id ?? replacement.id;
    final wasCurrent = _queueManager.currentTrack?.id == oldId;
    if (!_queueManager.replaceTrack(oldId, replacement)) return;
    if (!wasCurrent) return;
    if (oldId == replacement.id) {
      _updateCurrentTrack(replacement); // metadata refresh
      return;
    }
    final loaded = engine.state == EngineState.ready ||
        engine.state == EngineState.buffering;
    if (!loaded && !_playRequested) {
      _updateCurrentTrack(replacement); // loads when the user presses play
      return;
    }
    await _enqueuePlayTrack(
      replacement,
      doPlay: _playRequested,
      initialPosition: loaded ? engine.position : null,
    );
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
          title: playlist.title, index: newIdx, shuffle: shuffling);

      if (doPlay || shuffling) {
        final track = _queueManager.currentTrack;
        if (track != null) await _enqueuePlayTrack(track, doPlay: true);
      }
    } finally {
      _isAdvancing = false;
    }
  }

  /// Whether the queue is currently playing from the playlist [title].
  bool isQueueFromPlaylist(String title) {
    final current = _queueManager.currentTrack;
    return current != null && _queueManager.queueTitle.value == title;
  }

  /// The library's play button for a playlist: "locked" to that playlist.
  ///
  /// * The playlist is already the queue (its song is current and all of its
  ///   songs are queued): resume. Never reloads or restarts.
  /// * Its song is current but the queue has drifted (songs removed, queue
  ///   cleared, playlist edited since): rebuild the queue from the playlist
  ///   around the current song, then resume it without restarting.
  /// * Anything else (empty queue, another playlist, single songs): replace
  ///   the queue with the playlist and play it from the start.
  Future<void> playOrResumePlaylist(Playlist playlist) async {
    final current = _queueManager.currentTrack;
    switch (decidePlaylistPlay(
      queueTitle: _queueManager.queueTitle.value,
      currentTrackId: current?.id,
      queuedTrackIds: _queueManager.tracks.map((t) => t.id),
      playlist: playlist,
    )) {
      case PlaylistPlayAction.resume:
        await play();
      case PlaylistPlayAction.resyncAndResume:
        final idx = playlist.tracks.indexWhere((t) => t.id == current!.id);
        // doPlay: false keeps the engine on the current song; only the queue
        // around it is rebuilt.
        await loadPlaylist(playlist, idx: idx, doPlay: false);
        await play();
      case PlaylistPlayAction.load:
        await loadPlaylist(playlist, doPlay: true);
    }
  }

  @visibleForTesting
  static PlaylistPlayAction decidePlaylistPlay({
    required String queueTitle,
    required String? currentTrackId,
    required Iterable<String> queuedTrackIds,
    required Playlist playlist,
  }) {
    if (playlist.tracks.isEmpty) return PlaylistPlayAction.load;
    final playlistIds = {for (final t in playlist.tracks) t.id};
    final ownsCurrent = queueTitle == playlist.title &&
        currentTrackId != null &&
        playlistIds.contains(currentTrackId);
    if (!ownsCurrent) return PlaylistPlayAction.load;
    return queuedTrackIds.toSet().containsAll(playlistIds)
        ? PlaylistPlayAction.resume
        : PlaylistPlayAction.resyncAndResume;
  }

  /// "Add to queue" for a whole playlist.
  ///
  /// With nothing queued, the playlist becomes the queue (not started), so
  /// its play button then resumes it instead of loading it again. Otherwise
  /// its songs are appended in one step, skipping ones already queued.
  Future<void> addPlaylistToQueue(Playlist playlist) async {
    if (playlist.tracks.isEmpty) return;
    if (_queueManager.tracks.isEmpty) {
      await loadPlaylist(playlist, doPlay: false);
    } else {
      _queueManager.addTracks(playlist.tracks);
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mi) async =>
      _queueManager.addTrack(mediaItemToTrack(mi));

  /// "Add to queue". Returns false if [track] is current or already upcoming.
  Future<bool> addQueueTrack(Track track) async =>
      _queueManager.addTrack(track);

  @override
  Future<void> addQueueItems(List<MediaItem> items) async =>
      _queueManager.addTracks(items.map(mediaItemToTrack));

  Future<void> updateQueueTracks(List<Track> tracks,
      {bool doPlay = false, int startIndex = 0, String? title}) async {
    _queueManager.loadTracks(tracks,
        index: startIndex, title: title ?? 'Queue');
    if (doPlay) {
      final t = _queueManager.currentTrack;
      if (t != null) await _enqueuePlayTrack(t, doPlay: true);
    }
  }

  /// "Play next". Returns false if [track] is the current track.
  Future<bool> addPlayNextTrack(Track track) async =>
      _queueManager.addPlayNext(track);

  @override
  Future<void> insertQueueItem(int index, MediaItem mi) async =>
      _queueManager.insertTrack(index, mediaItemToTrack(mi));

  /// The current track cannot be removed; skip it instead.
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
  Future<void> updateQueue(List<MediaItem> newQueue) =>
      updateQueueTracks(newQueue.map(mediaItemToTrack).toList());

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
