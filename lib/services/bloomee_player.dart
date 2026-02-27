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
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/player/player_error_handler.dart';
import 'package:Bloomee/services/player/queue_manager.dart';
import 'package:Bloomee/services/player/related_songs_manager.dart';
import 'package:Bloomee/services/player/recently_played_tracker.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/ytstream_source.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

/// Main music player — extends [BaseAudioHandler] for OS notification / media
/// controls and orchestrates [PlayerEngine], [QueueManager],
/// and [PlayerErrorHandler].
///
/// ## Key design decisions
/// - **Crossfade-aware loading**: Delegates to the engine's crossfade logic
///   when transitioning tracks, enabling smooth dual-player transitions.
/// - **Completion-based auto-next**: Uses the engine's [completionStream]
///   instead of position-based polling for reliable track advancement.
/// - **Gapless playback**: Pre-resolves and prebuffers the next track's URI
///   in the standby player for near-instant transition on completion.
/// - **MediaItemModel as internal type**: Internal queue stores [MediaItemModel];
///   no conversion needed since [MediaItemModel] extends [MediaItem] directly.
class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late PlayerEngine engine;
  final SettingsRepository _settingsRepo;

  // Modular components
  late PlayerErrorHandler _errorHandler;
  late QueueManager _queueManager;
  late RelatedSongsManager _relatedSongsManager;
  late RecentlyPlayedTracker _recentlyPlayedTracker;

  // State subjects
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);

  bool _isDisposed = false;
  Completer<void>? _transitionCancellation; // Cancellable transitions
  DateTime? _lastSkipTime; // For rapid skip detection (700ms threshold)

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

  // Cached DAOs to avoid allocation in hot path
  late final DownloadDAO _downloadDao = DownloadDAO(DBProvider.db);
  late final SettingsDAO _settingsDao = SettingsDAO(DBProvider.db);

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
      await session.configure(AudioSessionConfiguration.music());
      _audioSession = session;

      await _audioInterruptionSub?.cancel();
      _audioInterruptionSub = session.interruptionEventStream.listen((event) {
        _handleInterruption(event);
      });

      await _audioNoisySub?.cancel();
      _audioNoisySub = session.becomingNoisyEventStream.listen((_) async {
        if (_isDisposed) return;
        if (engine.playing) {
          await pause();
        }
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
          if (engine.playing) {
            await pause();
          }
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
          if (granted && !_isDisposed) {
            await play();
          }
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
      if (session != null) {
        await session.setActive(false);
      }
    } catch (e) {
      log('Failed to deactivate audio session: $e', name: 'BloomeeMusicPlayer');
    }
  }

  /// Restore persisted crossfade / equalizer settings on startup.
  Future<void> _restoreEngineSettings() async {
    try {
      final settingsDao = SettingsDAO(DBProvider.db);

      // Crossfade duration
      final cfStr =
          await settingsDao.getSettingStr(SettingKeys.crossfadeDuration);
      final cfSeconds = int.tryParse(cfStr ?? '0') ?? 0;
      engine.crossfadeDuration = Duration(seconds: cfSeconds);

      // Equalizer enabled
      final eqOn =
          await settingsDao.getSettingBool(SettingKeys.eqEnabled) ?? false;

      // Equalizer band gains
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

      // Apply enable state after gains are set (so filter string is correct)
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

    // Error handler callbacks
    _errorHandler.onSkipToNext = () => skipToNext();
    _errorHandler.onRetryCurrentTrack = () => _retryCurrentTrack();

    _relatedSongsManager.onAddQueueItems =
        (items, {bool atLast = false}) => addQueueItems(items, atLast: atLast);

    // Recently played tracker
    _recentlyPlayedTracker = RecentlyPlayedTracker(
      engine,
      () => mediaItem.value,
    );
  }

  void _initSubscriptions() {
    // Engine state → OS playback state notification
    _engineStateSub = Rx.combineLatest2(
      engine.stateStream,
      engine.playingStream,
      (state, playing) => (state, playing),
    ).listen((record) {
      final (state, playing) = record;
      _broadcastPlaybackState(state, playing);
    });

    // Track completion → auto-next
    _completionSub = engine.completionStream.listen((_) {
      _onTrackCompleted();
    });

    // Engine errors
    _errorSub = engine.errorStream.listen((error) {
      log('Engine error: $error', name: 'BloomeeMusicPlayer');
      final track = _queueManager.currentTrack;
      if (track != null) {
        _errorHandler.handleError(
          PlayerErrorType.playbackError,
          error,
          track,
        );
      }
    });

    /// Sync queue to BaseAudioHandler for OS media notification.
    _queueSyncSub = _queueManager.tracksStream.listen((tracks) {
      queue.add(List<MediaItem>.from(tracks));
    });

    // Use a timer for related songs instead of piggybacking on position stream
    // (which fires every ~100ms). Check every 10 seconds during playback.
    _relatedSongTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isDisposed && engine.playing) {
        _checkRelatedSongs();
      }
    });
  }

  // ─── State Broadcasting ────────────────────────────────────────────────────

  void _broadcastPlaybackState(EngineState state, bool playing) {
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
      updatePosition: engine.position,
      playing: playing,
      bufferedPosition: engine.buffered,
      speed: engine.speed,
    ));

    DiscordService.updatePresence(
      mediaItem: currentMedia,
      isPlaying: playing,
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
    // Do NOT deactivate audio session — we still "own" the audio focus while
    // paused. Deactivating signals to the OS that we're done, allowing other
    // apps (Spotify, navigation) to resume immediately, causing overlap.
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
    if (engine.state == EngineState.ready) {
      await engine.seek(Duration.zero);
    } else if (engine.state == EngineState.completed) {
      final track = _queueManager.currentTrack;
      if (track != null) {
        await _playTrack(track, doPlay: true);
      }
    }
  }

  // ─── Loop & Shuffle ────────────────────────────────────────────────────────

  void setLoopMode(LoopMode mode) {
    loopMode.add(mode);
    engine.setLoopMode(mode);
  }

  /// Update crossfade duration (also persisted by SettingsCubit).
  void setCrossfadeDuration(Duration duration) {
    engine.crossfadeDuration = duration;
  }

  Future<void> shuffle(bool enabled) async {
    _queueManager.shuffle(enabled);
  }

  // ─── Track Playing ─────────────────────────────────────────────────────────

  /// Play a [MediaItemModel] by resolving its audio URI and opening the engine.
  ///
  /// ## Decision tree (deterministic, handles all edge cases):
  ///
  /// 1. Cancel any pending transition (CancellationToken pattern)
  /// 2. Detect rapid skip (< 700ms between skips)
  /// 3. Update UI immediately (new track metadata + loading spinner)
  /// 4. Transition based on state:
  ///
  ///    **No crossfade:**
  ///    - Preloaded & not rapid → instant swap to preloaded standby
  ///    - Otherwise → stop all, resolve URI, open direct
  ///
  ///    **Crossfade enabled:**
  ///    - Preloaded & not rapid → smooth crossfade to standby
  ///    - Rapid skip → stop all immediately, resolve URI, open direct
  ///    - Not preloaded & not rapid → fadeout old ∥ resolve URI, then open
  Future<void> _playTrack(MediaItemModel track,
      {bool doPlay = true, Duration? initialPosition}) async {
    if (_isDisposed) return;

    // ── 1. Cancel previous transition (CancellationToken) ──
    _transitionCancellation?.complete();
    _transitionCancellation = Completer<void>();
    final cancel = _transitionCancellation!;

    // ── 2. Rapid skip detection (700ms threshold) ──
    final now = DateTime.now();
    const rapidThreshold = Duration(milliseconds: 700);
    final isRapidSkip = _lastSkipTime != null &&
        now.difference(_lastSkipTime!) < rapidThreshold;
    _lastSkipTime = now;

    // ── 3. Capture transition state BEFORE any async work ──
    final crossfadeEnabled = engine.crossfadeDuration > Duration.zero;
    final preloaded = engine.isPreloaded;

    try {
      // Audio session
      if (doPlay) {
        final granted = await _activateAudioSession();
        if (!granted) {
          SnackbarService.showMessage(
              'Audio focus denied. Cannot start playback.');
          return;
        }
      }
      if (cancel.isCompleted) return;

      // ── Update UI + show spinner ──
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
      engine.setLoadingState();

      // ── 4. Execute transition ──
      if (!crossfadeEnabled) {
        // ─── NO CROSSFADE ───
        if (!isRapidSkip && preloaded) {
          // Best case: instant swap to preloaded standby
          await engine.activatePreloaded(autoPlay: doPlay);
        } else {
          // Stop everything, resolve URI, open fresh
          await engine.stop();
          if (cancel.isCompleted) return;

          final (uri, offline) =
              await _resolveUri(track).timeout(const Duration(seconds: 15));
          if (cancel.isCompleted) return;
          isOffline.add(offline);

          await engine.openDirect(uri, autoPlay: doPlay);
        }
      } else {
        // ─── CROSSFADE ENABLED ───
        if (!isRapidSkip && preloaded) {
          // Smooth crossfade to preloaded standby
          await engine.crossfadeToPreloaded(engine.crossfadeDuration);
        } else if (isRapidSkip) {
          // Rapid skip: hard stop, resolve, open fresh
          await engine.stop();
          if (cancel.isCompleted) return;

          final (uri, offline) =
              await _resolveUri(track).timeout(const Duration(seconds: 15));
          if (cancel.isCompleted) return;
          isOffline.add(offline);

          await engine.openDirect(uri, autoPlay: doPlay);
        } else {
          // Not preloaded, not rapid: fadeout old ∥ resolve URI in parallel
          final fadeoutDone = engine.fadeOutActive(const Duration(seconds: 2));
          final resolveDone =
              _resolveUri(track).timeout(const Duration(seconds: 15));

          // Wait for URI resolution (may finish before fadeout)
          late final (Uri, bool) resolved;
          try {
            resolved = await resolveDone;
          } catch (e) {
            // If resolve fails, still wait for fadeout to prevent orphan loop
            await fadeoutDone;
            rethrow;
          }
          if (cancel.isCompleted) return;

          // Wait for fadeout to finish too
          await fadeoutDone;
          if (cancel.isCompleted) return;

          final (uri, offline) = resolved;
          isOffline.add(offline);

          await engine.openDirect(uri, autoPlay: doPlay);
        }
      }

      // ── 5. Post-transition ──
      if (cancel.isCompleted) return;

      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      _errorHandler.clearError();
      _errorHandler.clearRetryAttempts(track.id);
      _preResolveNextTrack();
      await _checkRelatedSongs();

      log('Now playing: ${track.title}', name: 'BloomeeMusicPlayer');
    } on TimeoutException catch (e) {
      if (cancel.isCompleted) return;
      log('Timeout loading ${track.title}: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
        PlayerErrorType.networkError,
        'Network timeout',
        track,
        e,
      );
    } catch (e) {
      if (cancel.isCompleted) return;
      log('Failed to play ${track.title}: $e', name: 'BloomeeMusicPlayer');
      final type = _errorHandler.categorizeError(e);
      _errorHandler.handleError(type, e.toString(), track, e);
    } finally {
      if (_transitionCancellation == cancel) {
        _transitionCancellation = null;
      }
    }
  }

  /// Resolves a [MediaItemModel] into a playable [Uri].
  /// Returns (Uri, isOffline). Checks offline downloads first, then resolves
  /// YouTube or Saavn stream URLs.
  Future<(Uri, bool)> _resolveUri(MediaItemModel track) async {
    // Check for offline/downloaded version first.
    final down = await _downloadDao.getDownloadDB(track);
    if (down != null) {
      log('Playing Offline: ${track.title}', name: 'BloomeeMusicPlayer');
      SnackbarService.showMessage(
        'Playing Offline',
        duration: const Duration(seconds: 1),
      );
      return (Uri.file('${down.filePath}/${down.fileName}'), true);
    }

    // Resolve stream URL by source.
    if (track.source == 'youtube' || track.source == 'youtube_music') {
      final quality =
          await _settingsDao.getSettingStr(SettingKeys.ytStrmQuality) ?? 'high';
      final videoId = track.id.replaceAll('youtube', '');
      final streamUri = await resolveYoutubeAudioUri(
        videoId: videoId,
        quality: quality.toLowerCase(),
      );
      return (streamUri, false);
    } else {
      // Saavn or other sources.
      final kurl = await _settingsRepo.getJsQualityURL(track.streamUrl);
      if (kurl == null || kurl.isEmpty) {
        throw Exception('Failed to get stream URL for ${track.title}');
      }
      log('Playing: $kurl', name: 'BloomeeMusicPlayer');
      return (Uri.parse(kurl), false);
    }
  }

  /// Pre-resolve and prebuffer the next track for near-instant transition.
  /// Validates that the next track hasn't changed during the async resolution.
  void _preResolveNextTrack() {
    final nextTrack = _queueManager.peekNext(loopMode: loopMode.value);
    if (nextTrack == null) {
      unawaited(engine.clearPreload());
      return;
    }

    final expectedId = nextTrack.id;

    _resolveUri(nextTrack).then((result) async {
      // Verify the next track hasn't changed during resolution (could be
      // seconds for YouTube). If queue changed, discard this preload.
      final stillNext = _queueManager.peekNext(loopMode: loopMode.value);
      if (stillNext?.id != expectedId) {
        log('Next track changed during pre-resolve, discarding',
            name: 'BloomeeMusicPlayer');
        unawaited(engine.clearPreload());
        return;
      }
      // Actually prebuffer by opening in standby player
      await engine.preloadNext(result.$1);
    }).catchError((e) {
      log('Pre-resolve failed: $e', name: 'BloomeeMusicPlayer');
      unawaited(engine.clearPreload());
    });
  }

  /// Called when a track finishes naturally via [completionStream].
  void _onTrackCompleted() {
    if (loopMode.value == LoopMode.one) return; // Engine handles loop-one.

    EasyThrottle.throttle(
      'autoNext',
      const Duration(milliseconds: 1000),
      () async {
        try {
          final advanced =
              _queueManager.advanceToNext(loopMode: loopMode.value);
          if (advanced) {
            final next = _queueManager.currentTrack;
            if (next != null) {
              await _playTrack(next, doPlay: true);
            }
          }
        } catch (e) {
          log('Auto-next failed: $e', name: 'BloomeeMusicPlayer');
        }
      },
    );
  }

  Future<void> _retryCurrentTrack() async {
    final track = _queueManager.currentTrack;
    if (track == null) return;
    final pos = engine.position;
    log('Retrying: ${track.title} at $pos', name: 'BloomeeMusicPlayer');
    try {
      _errorHandler.clearError();
      await _playTrack(track, doPlay: true, initialPosition: pos);
    } catch (e) {
      log('Retry failed: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
          PlayerErrorType.playbackError, 'Retry failed: $e', track, e);
    }
  }

  Future<void> _checkRelatedSongs() async {
    final track = _queueManager.currentTrack;
    if (track == null) return;

    final MediaItem currentMediaItem = track;
    // Use the queue directly without copying to avoid allocation pressure
    final queueItems = _queueManager.tracks;

    await _relatedSongsManager.checkForRelatedSongs(
      currentMedia: currentMediaItem,
      queue: queueItems,
      currentPlayingIdx: _queueManager.currentIndex,
      loopMode: loopMode.value,
    );
  }

  /// Public method for UI to trigger related songs check.
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

  /// Revive a disposed player.
  ///
  /// WARNING: This creates a fresh engine and queue — all playback state,
  /// queue contents, and loop/shuffle settings are lost. If state persistence
  /// is needed, restore from storage after calling this.
  Future<void> revive() async {
    if (!_isDisposed) return;
    log('Reviving BloomeeMusicPlayer...', name: 'BloomeeMusicPlayer');

    if (fromPlaylist.isClosed) {
      fromPlaylist = BehaviorSubject<bool>.seeded(false);
    }
    if (isOffline.isClosed) {
      isOffline = BehaviorSubject<bool>.seeded(false);
    }
    if (loopMode.isClosed) {
      loopMode = BehaviorSubject<LoopMode>.seeded(LoopMode.off);
    }

    _initEngine();
    _initModules();
    _initSubscriptions();
    _initAudioSession();
    _isDisposed = false;

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  // ─── Queue Operations (BaseAudioHandler interface) ────────────────────────

  @override
  Future<void> playMediaItem(MediaItem item,
      {bool doPlay = true, Duration? initialPosition}) async {
    final track = mediaItem2MediaItemModel(item);
    await _playTrack(track, doPlay: doPlay, initialPosition: initialPosition);
  }

  @override
  Future<void> skipToNext() async {
    final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
    if (advanced) {
      final next = _queueManager.currentTrack;
      if (next != null) {
        await _playTrack(next, doPlay: true);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final advanced = _queueManager.advanceToPrevious(loopMode: loopMode.value);
    if (advanced) {
      final prev = _queueManager.currentTrack;
      if (prev != null) {
        await _playTrack(prev, doPlay: true);
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _queueManager.jumpTo(index);
    final track = _queueManager.currentTrack;
    if (track != null) {
      await _playTrack(track, doPlay: true);
    }
    await super.skipToQueueItem(index);
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    fromPlaylist.add(true);
    _relatedSongsManager.clearRelatedSongs();

    // Convert incoming MediaItems to MediaItemModel list
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
      if (track != null) {
        await _playTrack(track, doPlay: true);
      }
    }
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    _queueManager.addTrack(mediaItem2MediaItemModel(item));
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
  Future<void> insertQueueItem(int index, MediaItem item) async {
    _queueManager.insertTrack(index, mediaItem2MediaItemModel(item));
    try {
      await super.insertQueueItem(index, item);
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
      if (track != null) {
        await _playTrack(track, doPlay: true);
      }
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onTaskRemoved() async {
    // _cleanup handles everything including engine stop, dispose, and super.stop()
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

    // Cancel timer and subscriptions
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

    try {
      await fromPlaylist.close();
      await isOffline.close();
      await loopMode.close();
    } catch (e) {
      log('Error closing subjects: $e', name: 'BloomeeMusicPlayer');
    }

    // Single call to super.stop() — avoids double-call from onTaskRemoved
    await super.stop();
  }
}
