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
import 'package:easy_debounce/easy_throttle.dart';
import 'package:rxdart/rxdart.dart';

/// Main music player — extends [BaseAudioHandler] for OS notification / media
/// controls and orchestrates [PlayerEngine], [QueueManager],
/// and [PlayerErrorHandler].
///
/// ## Key design decisions
/// - **Stop-before-load**: When switching tracks, old audio is stopped
///   immediately before the new track loads, preventing audible bleed.
/// - **Completion-based auto-next**: Uses the engine's [completionStream]
///   instead of position-based polling for reliable track advancement.
/// - **Gapless playback**: Pre-resolves the next track's URI while the
///   current track plays, enabling near-instant transition on completion.
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
  bool _isTransitioning = false; // Prevents cascading play calls

  // Stream subscriptions
  StreamSubscription? _engineStateSub;
  StreamSubscription? _completionSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _queueSyncSub;
  StreamSubscription? _positionSub;

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
    _restoreEngineSettings();
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initEngine() {
    _isDisposed = false;
    engine = PlayerEngine();
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

    // Position-based related songs check
    _positionSub = engine.positionStream.listen((_) {
      EasyThrottle.throttle('loadRelatedSongs', const Duration(seconds: 5),
          () async => _checkRelatedSongs());
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
    await engine.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    final dur = engine.duration;
    if (dur >= engine.position + n) {
      await engine.seek(engine.position + n);
    } else {
      await engine.seek(dur);
    }
  }

  Future<void> seekNSecBackward(Duration n) async {
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
    DiscordService.clearPresence();
    await super.stop();
  }

  @override
  Future<void> rewind() async {
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
  Future<void> _playTrack(MediaItemModel track,
      {bool doPlay = true, Duration? initialPosition}) async {
    if (_isDisposed || _isTransitioning) return;
    _isTransitioning = true;

    try {
      // 1. Stop current audio immediately — no overlap.
      await engine.stop();

      // 2. Update notification with new track info (shows "loading").
      final artUriStr =
          formatImgURL(track.artUri?.toString() ?? '', ImageQuality.medium);
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
      mediaItem.add(_currentTrack);

      // 3. Resolve audio source URI.
      final (uri, offline) =
          await _resolveUri(track).timeout(const Duration(seconds: 15));
      isOffline.add(offline);

      // 4. Open in engine (auto-plays if doPlay).
      await engine.open(uri, autoPlay: doPlay);

      // 5. Seek if needed.
      if (initialPosition != null && initialPosition > Duration.zero) {
        await engine.seek(initialPosition);
      }

      // 6. Clear errors on success.
      _errorHandler.clearError();
      _errorHandler.clearRetryAttempts(track.id);

      // 7. Pre-resolve next track for gapless playback.
      _preResolveNextTrack();

      // 8. Check for related songs.
      await _checkRelatedSongs();

      log('Now playing: ${track.title}', name: 'BloomeeMusicPlayer');
    } on TimeoutException catch (e) {
      log('Timeout loading ${track.title}: $e', name: 'BloomeeMusicPlayer');
      _errorHandler.handleError(
        PlayerErrorType.networkError,
        'Network timeout',
        track,
        e,
      );
    } catch (e) {
      log('Failed to play ${track.title}: $e', name: 'BloomeeMusicPlayer');
      final type = _errorHandler.categorizeError(e);
      _errorHandler.handleError(type, e.toString(), track, e);
    } finally {
      _isTransitioning = false;
    }
  }

  /// Resolves a [MediaItemModel] into a playable [Uri].
  /// Returns (Uri, isOffline). Checks offline downloads first, then resolves
  /// YouTube or Saavn stream URLs.
  Future<(Uri, bool)> _resolveUri(MediaItemModel track) async {
    // Check for offline/downloaded version first.
    final down = await DownloadDAO(DBProvider.db).getDownloadDB(track);
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
      final quality = await SettingsDAO(DBProvider.db)
              .getSettingStr(SettingKeys.ytStrmQuality) ??
          'high';
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

  /// Pre-resolve the next track's URL so transition is near-instant.
  void _preResolveNextTrack() {
    final nextTrack = _queueManager.peekNext(loopMode: loopMode.value);
    if (nextTrack == null) {
      engine.clearPreload();
      return;
    }
    _resolveUri(nextTrack).then((result) {
      engine.preloadNext(result.$1);
    }).catchError((e) {
      log('Pre-resolve failed: $e', name: 'BloomeeMusicPlayer');
      engine.clearPreload();
    });
  }

  /// Called when a track finishes naturally via [completionStream].
  void _onTrackCompleted() {
    if (_isTransitioning) return;
    if (loopMode.value == LoopMode.one) return; // Engine handles loop-one.

    EasyThrottle.throttle(
      'autoNext',
      const Duration(milliseconds: 1000),
      () async {
        final advanced = _queueManager.advanceToNext(loopMode: loopMode.value);
        if (advanced) {
          final next = _queueManager.currentTrack;
          if (next != null) {
            await _playTrack(next, doPlay: true);
          }
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
    final queueItems = List<MediaItem>.from(_queueManager.tracks);

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
    await stop();
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

    await _engineStateSub?.cancel();
    await _completionSub?.cancel();
    await _errorSub?.cancel();
    await _queueSyncSub?.cancel();
    await _positionSub?.cancel();

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

    try {
      await fromPlaylist.close();
      await isOffline.close();
      await loopMode.close();
    } catch (e) {
      log('Error closing subjects: $e', name: 'BloomeeMusicPlayer');
    }

    await super.stop();
  }
}
