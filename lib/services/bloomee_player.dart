import 'dart:developer';
import 'dart:async';
import 'dart:convert';

import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/model/media_playlist_model.dart';
import 'package:Bloomee/core/constants/app_constants.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/media_resolver_service.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/player/player_error_handler.dart';
import 'package:Bloomee/services/player/queue_manager.dart';
import 'package:Bloomee/services/player/related_songs_manager.dart';
import 'package:Bloomee/services/player/recently_played_tracker.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:async/async.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

/// Main music player — extends [BaseAudioHandler] for OS notification / media
/// controls and orchestrates [PlayerEngine],[QueueManager],
/// and [PlayerErrorHandler].
///
/// ## Industry Standard Architecture
/// - **CancelableCompleters**: Guarantees zero unhandled futures and prevents
///   zombie network calls if the user skips tracks rapidly.
/// - **Optimized OS Sync**: Avoids 60Hz position stream broadcasting. Only updates
///   the OS on state changes, allowing native iOS/Android to interpolate time natively.
/// - **Deterministic Transitions**: Consumes sealed [EngineResult] to prevent
///   swallowed errors from breaking playback state.
class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late PlayerEngine engine;
  final SettingsRepository _settingsRepo;

  // Modular components
  late PlayerErrorHandler _errorHandler;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late RecentlyPlayedTracker _recentlyPlayedTracker;
  late MediaResolverService _resolver;

  // State subjects (Kept alive indefinitely to avoid orphaning UI StreamBuilders)
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);

  bool _isDisposed = false;

  // ── Concurrency & Cancellation Tokens ──
  CancelableCompleter<void>? _playCompleter;
  CancelableOperation<(Uri, bool)>? _preResolveOp;
  CancelableOperation<(Uri, bool)>? _currentResolveOp;
  bool _isAdvancing = false;
  bool _checkingRelated = false;

  // Preload identity tracking
  String? _preloadedTrackId;
  bool _preloadedTrackOffline = false;

  // Stream subscriptions
  StreamSubscription? _engineStateSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _queueSyncSub;
  Timer? _relatedSongTimer;
  StreamSubscription<AudioInterruptionEvent>? _audioInterruptionSub;
  StreamSubscription<void>? _audioNoisySub;

  AudioSession? _audioSession;
  double? _volumeBeforeDuck;
  bool _resumeAfterInterruption = false;

  // Expose from modular components
  BehaviorSubject<bool> get shuffleMode => _queueManager.shuffleMode;
  BehaviorSubject<PlayerError?> get lastError => _errorHandler.lastError;
  BehaviorSubject<List<MediaItem>> get relatedSongs =>
      _relatedSongsManager.relatedSongs;

  @override
  BehaviorSubject<String> get queueTitle => _queueManager.queueTitle;

  // Currently playing track
  MediaItemModel _currentTrack = mediaItemModelNull;

  BloomeeMusicPlayer(this._settingsRepo) {
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
      await session.configure(const AudioSessionConfiguration.music());
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
      log('Failed to initialize audio session: $e', name: 'BloomeeMusicPlayer');
    }
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
      final cfSeconds = int.tryParse(cfStr ?? '0') ?? 0;
      engine.crossfadeDuration = Duration(seconds: cfSeconds);

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
    _relatedSongsManager = RelatedSongsManager();
    _resolver = MediaResolverService.fromRepo(_settingsRepo);

    _errorHandler.onSkipToNext = () => skipToNext();
    _errorHandler.onRetryCurrentTrack = () => _retryCurrentTrack();

    _relatedSongsManager.onAddQueueItems =
        (items, {bool atLast = false}) => addQueueItems(items, atLast: atLast);

    _recentlyPlayedTracker = RecentlyPlayedTracker(
      engine,
      () => mediaItem.value,
    );
  }

  void _initSubscriptions() {
    // Exclude position from combineLatest to prevent 60Hz OS battery drain.
    // distinct() prevents identical tuples from spamming the lock screen.
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
      queue.add(List<MediaItem>.from(tracks));
    });

    _relatedSongTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isDisposed && engine.playing) _checkRelatedSongs();
    });
  }

  // ─── State Broadcasting ────────────────────────────────────────────────────

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
      updatePosition: position, // Captured at the moment of state change
      updateTime: DateTime.now(), // OS will natively interpolate the rest
      playing: playing,
      bufferedPosition: buffered,
      speed: speed,
    ));

    // Throttle Discord RPC — max once per second during rapid state changes.
    EasyThrottle.throttle(
      'discord_rpc',
      const Duration(milliseconds: 1000),
      () {
        DiscordService.updatePresence(
          mediaItem: currentMedia,
          isPlaying: playing,
        );
      },
    );
  }

  // ─── Current Track ─────────────────────────────────────────────────────────

  MediaItemModel get currentMedia {
    return _queueManager.currentTrack ?? mediaItemModelNull;
  }

  // ─── Playback Control ──────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_isDisposed) return;
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
    // 1. MUST cancel in-flight intents FIRST to prevent Zombie playbacks
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

  /// Enqueue a play request. Cancels any in-flight request immediately.
  /// Does NOT complete with an error so callers (like skipToNext) don't crash the app.
  Future<void> _enqueuePlayTrack(MediaItemModel track,
      {bool doPlay = true, Duration? initialPosition}) {
    if (_isDisposed) return Future.value();

    // Atomically cancel previous, create new completer.
    final prev = _playCompleter;
    final completer = CancelableCompleter<void>(
      onCancel: () =>
          log('Canceled: ${track.title}', name: 'BloomeeMusicPlayer'),
    );
    _playCompleter = completer;
    prev?.operation.cancel();

    _doPlay(track, completer, doPlay: doPlay, initialPosition: initialPosition);

    // .valueOrCancellation catches nothing by design because errors are
    // handled internally. Guarantees no Unhandled Futures crash the app!
    return completer.operation.valueOrCancellation().then((_) {});
  }

  /// Core play routine. Consumes [EngineResult] sealed class to enforce deterministic
  /// error states and prevent "swallowed error" data corruption.
  Future<void> _doPlay(
    MediaItemModel track,
    CancelableCompleter<void> token, {
    bool doPlay = true,
    Duration? initialPosition,
  }) async {
    bool alive() => !token.isCanceled && !_isDisposed;

    void done() {
      // NEVER completeError! We handle errors gracefully via UI overlay.
      if (!token.isCompleted && !token.isCanceled) token.complete();
    }

    if (!alive()) return;

    final crossfadeEnabled = engine.crossfadeDuration > Duration.zero;
    final canUsePreloaded = engine.isPreloaded &&
        _preloadedTrackId != null &&
        _preloadedTrackId == track.id;

    try {
      if (doPlay) {
        final granted = await _activateAudioSession();
        if (!alive()) return;
        if (!granted) {
          SnackbarService.showMessage(
              'Audio focus denied. Cannot start playback.');
          return done();
        }
      }

      // 1. MUST cancel previous network resolves FIRST
      _currentResolveOp?.cancel();

      _updateCurrentTrack(track);
      engine.setLoadingState();

      EngineResult transitionResult;

      if (!crossfadeEnabled) {
        // ─── NO CROSSFADE ───
        if (canUsePreloaded) {
          isOffline.add(_preloadedTrackOffline);
          transitionResult = await engine.activatePreloaded(autoPlay: doPlay);
          _clearPreloadedMarker();
        } else {
          // FIX: Stop the old track IMMEDIATELY to give instant auditory feedback.
          // This ensures the old song dies the millisecond the user presses "Skip".
          await engine.stop(keepLoadingState: true);
          if (!alive()) return;

          // Now wait for the network. User hears silence and sees the loading UI.
          _currentResolveOp = CancelableOperation.fromFuture(
              _resolver.resolve(track).timeout(const Duration(seconds: 15)));

          final result = await _currentResolveOp!.valueOrCancellation();
          if (result == null || !alive()) return;
          final (uri, offline) = result;

          isOffline.add(offline);
          transitionResult = await engine.openDirect(uri, autoPlay: doPlay);
        }
      } else {
        // ─── CROSSFADE ENABLED ───
        if (canUsePreloaded) {
          isOffline.add(_preloadedTrackOffline);
          transitionResult =
              await engine.crossfadeToPreloaded(engine.crossfadeDuration);
          _clearPreloadedMarker();
        } else {
          // FIX: If not preloaded, it's a manual skip to an unresolved track.
          // You CANNOT crossfade over an unknown network delay.
          // Stop immediately for instant feedback.
          await engine.stop(keepLoadingState: true);
          if (!alive()) return;

          _currentResolveOp = CancelableOperation.fromFuture(
              _resolver.resolve(track).timeout(const Duration(seconds: 15)));

          final result = await _currentResolveOp!.valueOrCancellation();
          if (result == null || !alive()) return;
          final (uri, offline) = result;

          isOffline.add(offline);
          transitionResult = await engine.openDirect(uri, autoPlay: doPlay);
        }
      }

      if (!alive()) return;

      // Deterministic Error Evaluation
      if (transitionResult is EngineFailure) {
        final err = transitionResult.error;
        final type = _errorHandler.categorizeError(err);
        _errorHandler.handleError(type, err.toString(), track, err);
        return done(); // Halt execution cleanly
      }

      // Transition Success Setup
      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      _errorHandler.clearError();
      _errorHandler.clearRetryAttempts(track.id);
      _preResolveNextTrack();
      await _checkRelatedSongs();

      log('Now playing: ${track.title}', name: 'BloomeeMusicPlayer');
      done();
    } on TimeoutException catch (e) {
      if (!alive()) return;
      log('Timeout loading ${track.title}: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
          PlayerErrorType.networkError, 'Network timeout', track, e);
      done();
    } catch (e) {
      if (!alive()) return;
      log('Failed to play ${track.title}: $e', name: 'BloomeeMusicPlayer');
      final type = _errorHandler.categorizeError(e);
      _errorHandler.handleError(type, e.toString(), track, e);
      done();
    }
  }

  void _updateCurrentTrack(MediaItemModel track) {
    final artUriStr =
        formatImgURL(track.artUri?.toString() ?? '', ImageQuality.medium);
    if (_currentTrack.artUri?.toString() != artUriStr) {
      _currentTrack = MediaItemModel(
        id: track.id,
        title: track.title,
        album: track.album,
        artUri: Uri.tryParse(artUriStr),
        artist: track.artist,
        extras: track.extras,
        genre: track.genre,
        duration: track.duration,
      );
    } else {
      _currentTrack = track;
    }
    mediaItem.add(_currentTrack);
  }

  // ─── Preload ───────────────────────────────────────────────────────────────

  /// Pre-resolve and prebuffer the next track. Uses [CancelableOperation].
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

      // force: true prevents crossfade _isTransitioning flag from blocking the preload
      await engine.preloadNext(result.$1, force: true);

      if (!_isDisposed && engine.isPreloaded) {
        _preloadedTrackId = expectedId;
        _preloadedTrackOffline = result.$2;
      }
    }).catchError((e) {
      log('Pre-resolve failed: $e', name: 'BloomeeMusicPlayer');
      _clearPreloadedMarker();
      unawaited(engine.clearPreload());
    });
  }

  // ─── Auto-next / Completion ────────────────────────────────────────────────

  void _onTrackCompleted() {
    // Rely on simple Mutex lock rather than EasyThrottle's time-based race conditions.
    if (loopMode.value == LoopMode.one || _isAdvancing) return;
    _isAdvancing = true;

    Future.microtask(() async {
      try {
        final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
        if (advanced) {
          final next = _queueManager.currentTrack;
          if (next != null) await _enqueuePlayTrack(next, doPlay: true);
        } else {
          // If queue ended natively, ensure cleanly stopped state.
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
    // Mutex prevents concurrent duplicate song generation
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

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  // ─── Queue Operations (BaseAudioHandler interface) ────────────────────────

  @override
  Future<void> playMediaItem(MediaItem mediaItem,
      {bool doPlay = true, Duration? initialPosition}) async {
    final track = mediaItem2MediaItemModel(mediaItem);
    await _enqueuePlayTrack(track,
        doPlay: doPlay, initialPosition: initialPosition);
  }

  @override
  Future<void> skipToNext() async {
    // If an auto-advance is mid-flight, wait or skip doing it again.
    // To keep it simple and robust, cancel whatever is happening and advance
    _isAdvancing = true;
    try {
      final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
      if (advanced) {
        final next = _queueManager.currentTrack;
        if (next != null) await _enqueuePlayTrack(next, doPlay: true);
      } else {
        // Cancel previous intents to avoid ghost playback
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
    _isAdvancing = true;
    try {
      final advanced =
          _queueManager.advanceToPrevious(loopMode: loopMode.value);
      if (advanced) {
        final prev = _queueManager.currentTrack;
        if (prev != null) await _enqueuePlayTrack(prev, doPlay: true);
      } else {
        // Cancel previous intents to avoid ghost playback
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
    _queueManager.jumpTo(index);
    final track = _queueManager.currentTrack;
    if (track != null) await _enqueuePlayTrack(track, doPlay: true);
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    fromPlaylist.add(true);
    _relatedSongsManager.clearRelatedSongs();

    final tracks =
        mediaList.mediaItems.map((m) => mediaItem2MediaItemModel(m)).toList();

    _queueManager.loadTracks(
      tracks,
      playlistName: mediaList.playlistName,
      idx: idx,
      shuffling: shuffling,
    );
    queueTitle.add(mediaList.playlistName);

    if (doPlay || shuffling) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queueManager.addTrack(mediaItem2MediaItemModel(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = 'Queue', bool atLast = false}) async {
    final tracks = mediaItems.map((m) => mediaItem2MediaItemModel(m)).toList();
    _queueManager.addTracks(tracks, atLast: atLast);
  }

  Future<void> addPlayNextItem(MediaItem item) async {
    _queueManager.addPlayNext(mediaItem2MediaItemModel(item));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    _queueManager.insertTrack(index, mediaItem2MediaItemModel(mediaItem));
    try {
      await super.insertQueueItem(index, mediaItem);
    } catch (e) {
      log('Error syncing insertQueueItem: $e', name: 'BloomeeMusicPlayer');
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    _queueManager.removeTrackAt(index);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    _queueManager.moveTrack(oldIndex, newIndex);
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue,
      {bool doPlay = false}) async {
    final tracks = newQueue.map((m) => mediaItem2MediaItemModel(m)).toList();
    _queueManager.updateQueue(tracks);
    if (doPlay) {
      final track = _queueManager.currentTrack;
      if (track != null) await _enqueuePlayTrack(track, doPlay: true);
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onTaskRemoved() async {
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
    await _audioInterruptionSub?.cancel();
    await _audioNoisySub?.cancel();

    _errorHandler.dispose();
    _queueManager.dispose();
    _relatedSongsManager.dispose();
    await _recentlyPlayedTracker.dispose();

    DiscordService.clearPresence();

    try {
      await engine.dispose();
    } catch (e) {
      log('Error disposing engine: $e', name: 'BloomeeMusicPlayer');
    }

    await _deactivateAudioSession();

    // Do NOT close UI-bound subjects! Resets them safely instead.
    fromPlaylist.add(false);
    isOffline.add(false);
    loopMode.add(LoopMode.off);

    await super.stop();
  }
}
