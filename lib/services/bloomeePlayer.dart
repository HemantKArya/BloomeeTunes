import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/ytstream_source.dart';
import 'package:audio_service/audio_service.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import '../model/MediaPlaylistModel.dart';
import 'package:Bloomee/services/discord_service.dart';

// Static method for compute operation
Future<Map> _getRelatedSongs(String songId) async {
  return await SaavnAPI().getRelated(songId);
}

List<int> generateRandomIndices(int length) {
  List<int> indices = List<int>.generate(length, (i) => i);
  indices.shuffle();
  return indices;
}

enum PlayerErrorType {
  networkError,
  sourceError,
  playbackError,
  bufferingError,
  permissionError,
  unknownError,
}

class PlayerError {
  final PlayerErrorType type;
  final String message;
  final dynamic originalError;
  final DateTime timestamp;
  final MediaItem? failedMediaItem;

  PlayerError({
    required this.type,
    required this.message,
    this.originalError,
    this.failedMediaItem,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'PlayerError(type: $type, message: $message)';
}

class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });
}

class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late AudioPlayer audioPlayer;
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> shuffleMode = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isConnected = BehaviorSubject<bool>.seeded(true);
  BehaviorSubject<PlayerError?> lastError =
      BehaviorSubject<PlayerError?>.seeded(null);

  BehaviorSubject<List<MediaItem>> relatedSongs =
      BehaviorSubject<List<MediaItem>>.seeded([]);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);

  int currentPlayingIdx = 0;
  int shuffleIdx = 0;
  List<int> shuffleList = [];
  final _playlist = ConcatenatingAudioSource(children: []);

  // Flag to track if player is disposed
  bool _isDisposed = false;

  // Error handling and retry mechanism
  final Map<String, int> _retryAttempts = {};
  final Map<String, DateTime> _lastRetryTime = {};
  final RetryConfig _retryConfig = const RetryConfig();
  Timer? _reconnectionTimer;
  Timer? _connectivityTimer;

  // Stream subscriptions for proper cleanup
  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _queueSubscription;
  StreamSubscription? _mediaItemSubscription;
  StreamSubscription? _connectivitySubscription;

  // Cache for audio sources to avoid repeated network calls
  final Map<String, AudioSource> _audioSourceCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  static const int _maxCacheSize = 50;

  // final ReceivePort receivePortYt = ReceivePort();
  // SendPort? sendPortYt;

  BloomeeMusicPlayer() {
    audioPlayer = AudioPlayer(
      handleInterruptions: true,
    );
    _initializePlayer();
    _setupErrorHandling();
    _startConnectivityMonitoring();
  }

  void _initializePlayer() {
    audioPlayer.setVolume(1);
    _playbackEventSubscription =
        audioPlayer.playbackEventStream.listen(_broadcastPlayerEvent);
    audioPlayer.setLoopMode(LoopMode.off);
    audioPlayer.setAudioSource(_playlist, preload: false);

    // Enhanced error handling for player events
    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle &&
          state.playing == false &&
          lastError.value != null) {
        _handlePlaybackFailure();
      }
    });

    // Update the current media item when the audio player changes to the next
    _mediaItemSubscription = Rx.combineLatest2(
      audioPlayer.sequenceStream,
      audioPlayer.currentIndexStream,
      (sequence, index) {
        if (sequence == null || sequence.isEmpty) return null;
        return sequence[index ?? 0].tag as MediaItem;
      },
    ).whereType<MediaItem>().listen(mediaItem.add);

    // Trigger skipToNext when the current song ends.
    final endingOffset =
        Platform.isWindows ? 200 : (Platform.isLinux ? 700 : 200);
    _positionSubscription = audioPlayer.positionStream.listen((event) {
      //check if the current queue is empty and if it is, add related songs
      EasyThrottle.throttle('loadRelatedSongs', const Duration(seconds: 5),
          () async => check4RelatedSongs());
      if (((audioPlayer.duration != null &&
              audioPlayer.duration?.inSeconds != 0 &&
              event.inMilliseconds >
                  audioPlayer.duration!.inMilliseconds - endingOffset)) &&
          loopMode.value != LoopMode.one &&
          queue.value.isNotEmpty) {
        // Add safety check for queue
        EasyThrottle.throttle('skipNext', const Duration(milliseconds: 2000),
            () async => skipToNext());
      }
    });

    // Refresh shuffle list when queue changes
    _queueSubscription = queue.listen((e) {
      shuffleList = generateRandomIndices(e.length);
    });
  }

  void _setupErrorHandling() {
    // Listen to audio player errors
    audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.idle &&
          audioPlayer.playing == false &&
          lastError.value?.type == PlayerErrorType.playbackError) {
        _scheduleRetry();
      }
    });
  }

  void _startConnectivityMonitoring() {
    // For now, we'll use a simple network check
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNetworkConnectivity();
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final wasConnected = isConnected.value;
      final nowConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      isConnected.add(nowConnected);

      if (!wasConnected && nowConnected) {
        log('Network reconnected, attempting to resume playback',
            name: 'bloomeePlayer');
        _handleNetworkReconnection();
      }
    } catch (e) {
      isConnected.add(false);
      log('Network connectivity check failed: $e', name: 'bloomeePlayer');
    }
  }

  void _handleNetworkReconnection() {
    if (lastError.value?.type == PlayerErrorType.networkError &&
        queue.value.isNotEmpty) {
      _clearAudioSourceCache();
      _retryCurrentTrack();
    }
  }

  void _clearAudioSourceCache() {
    _audioSourceCache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> _retryCurrentTrack() async {
    if (queue.value.isNotEmpty && currentPlayingIdx < queue.value.length) {
      final currentItem = queue.value[currentPlayingIdx];
      log('Retrying current track: ${currentItem.title}',
          name: 'bloomeePlayer');

      try {
        lastError.add(null); // Clear previous error
        await playMediaItem(currentItem, doPlay: true);
      } catch (e) {
        log('Retry failed: $e', name: 'bloomeePlayer');
        _handleError(
            PlayerErrorType.playbackError, 'Retry failed: $e', currentItem, e);
      }
    }
  }

  void _scheduleRetry() {
    final currentItem =
        queue.value.isNotEmpty ? queue.value[currentPlayingIdx] : null;
    if (currentItem == null) return;

    final itemId = currentItem.id;
    final attempts = _retryAttempts[itemId] ?? 0;

    if (attempts >= _retryConfig.maxRetries) {
      log('Max retry attempts reached for ${currentItem.title}',
          name: 'bloomeePlayer');
      _skipToNextOnError();
      return;
    }

    final delay = _calculateRetryDelay(attempts);
    _retryAttempts[itemId] = attempts + 1;
    _lastRetryTime[itemId] = DateTime.now();

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, () async {
      log('Retrying playback for ${currentItem.title} (attempt ${attempts + 1})',
          name: 'bloomeePlayer');
      await _retryCurrentTrack();
    });
  }

  Duration _calculateRetryDelay(int attempts) {
    final delay =
        _retryConfig.initialDelay * (attempts * _retryConfig.backoffMultiplier);
    return delay > _retryConfig.maxDelay ? _retryConfig.maxDelay : delay;
  }

  void _handlePlaybackFailure() {
    if (queue.value.isNotEmpty && currentPlayingIdx < queue.value.length) {
      final currentItem = queue.value[currentPlayingIdx];
      _handleError(PlayerErrorType.playbackError,
          'Playback failed unexpectedly', currentItem);
    }
  }

  void _skipToNextOnError() async {
    SnackbarService.showMessage('Failed to play current song, skipping to next',
        duration: const Duration(seconds: 3));

    if (queue.value.length > 1) {
      await skipToNext();
    } else {
      await stop();
    }
  }

  void _handleError(PlayerErrorType type, String message, MediaItem? mediaItem,
      [dynamic originalError]) {
    final error = PlayerError(
      type: type,
      message: message,
      failedMediaItem: mediaItem,
      originalError: originalError,
    );

    lastError.add(error);
    log('Player error: $error', name: 'bloomeePlayer');

    // Show user-friendly error message
    String userMessage = _getUserFriendlyErrorMessage(type, message);
    SnackbarService.showMessage(userMessage,
        duration: const Duration(seconds: 4));

    // Handle specific error types
    switch (type) {
      case PlayerErrorType.networkError:
        if (!isConnected.value) {
          userMessage = 'No internet connection. Will retry when connected.';
        } else {
          _scheduleRetry();
        }
        break;
      case PlayerErrorType.sourceError:
        _clearCachedSource(mediaItem?.id);
        _scheduleRetry();
        break;
      case PlayerErrorType.playbackError:
        _scheduleRetry();
        break;
      case PlayerErrorType.bufferingError:
        // Try lower quality or skip
        _scheduleRetry();
        break;
      default:
        _scheduleRetry();
    }
  }

  String _getUserFriendlyErrorMessage(PlayerErrorType type, String message) {
    switch (type) {
      case PlayerErrorType.networkError:
        return 'Network connection issue. Retrying...';
      case PlayerErrorType.sourceError:
        return 'Song source unavailable. Trying alternative...';
      case PlayerErrorType.playbackError:
        return 'Playback issue detected. Retrying...';
      case PlayerErrorType.bufferingError:
        return 'Buffering problem. Retrying...';
      case PlayerErrorType.permissionError:
        return 'Permission denied. Please check app permissions.';
      default:
        return 'Unexpected error occurred. Retrying...';
    }
  }

  void _clearCachedSource(String? mediaId) {
    if (mediaId != null) {
      _audioSourceCache.remove(mediaId);
      _cacheTimestamps.remove(mediaId);
    }
  }

  bool _isCacheExpired(String mediaId) {
    final timestamp = _cacheTimestamps[mediaId];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiry;
  }

  void _addToCache(String mediaId, AudioSource source) {
    // Remove oldest entry if cache is full
    if (_audioSourceCache.length >= _maxCacheSize) {
      final oldestEntry = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
      _audioSourceCache.remove(oldestEntry.key);
      _cacheTimestamps.remove(oldestEntry.key);
    }

    _audioSourceCache[mediaId] = source;
    _cacheTimestamps[mediaId] = DateTime.now();
  }

  void _broadcastPlayerEvent(PlaybackEvent event) {
    bool isPlaying = audioPlayer.playing;
    playbackState.add(PlaybackState(
      // Which buttons should appear in the notification now
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        // MediaControl.stop,
        MediaControl.skipToNext,
      ],
      processingState: switch (event.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      // Which other actions should be enabled in the notification
      systemActions: const {
        MediaAction.skipToPrevious,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: audioPlayer.position,
      playing: isPlaying,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
    ));

    DiscordService.updatePresence(
      mediaItem: currentMedia,
      isPlaying: isPlaying,
    );
  }

  MediaItemModel get currentMedia {
    if (queue.value.isEmpty || currentPlayingIdx >= queue.value.length) {
      return mediaItemModelNull;
    }
    return mediaItem2MediaItemModel(queue.value[currentPlayingIdx]);
  }

  @override
  Future<void> play() async {
    if (_isDisposed) {
      log('Cannot play: player is disposed', name: 'bloomeePlayer');
      return;
    }
    await audioPlayer.play();
  }

  Future<void> check4RelatedSongs() async {
    log("Checking for related songs: ${queue.value.isNotEmpty && (queue.value.length - currentPlayingIdx) < 2}",
        name: "bloomeePlayer");
    final autoPlay =
        await BloomeeDBService.getSettingBool(GlobalStrConsts.autoPlay);
    if (autoPlay != null && !autoPlay) return;
    if (queue.value.isNotEmpty &&
        (queue.value.length - currentPlayingIdx) < 2 &&
        loopMode.value != LoopMode.all) {
      if (currentMedia.extras?["source"] == "saavn") {
        final songs = await compute(_getRelatedSongs, currentMedia.id);
        if (songs['total'] > 0) {
          final List<MediaItem> temp =
              fromSaavnSongMapList2MediaItemList(songs['songs']);
          relatedSongs.add(temp.sublist(1));
          log("Related Songs: ${songs['total']}");
        }
      } else if (currentMedia.extras?["source"].contains("youtube") ?? false) {
        final songs = await YTMusic()
            .getRelatedSongs(currentMedia.id.replaceAll('youtube', ''));
        if (songs.isNotEmpty) {
          final List<MediaItem> temp = ytmMapList2MediaItemList(songs);
          relatedSongs.add(temp.sublist(1));
          log("Related Songs: ${songs.length}");
        }
      }
    }
    loadRelatedSongs();
  }

  Future<void> loadRelatedSongs() async {
    if (relatedSongs.value.isNotEmpty &&
        (queue.value.length - currentPlayingIdx) < 3 &&
        loopMode.value != LoopMode.all) {
      await addQueueItems(relatedSongs.value, atLast: true);
      fromPlaylist.add(false);
      relatedSongs.add([]);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    audioPlayer.seek(position);
  }

  Future<void> seekNSecForward(Duration n) async {
    if ((audioPlayer.duration ?? const Duration(seconds: 0)) >=
        audioPlayer.position + n) {
      await audioPlayer.seek(audioPlayer.position + n);
    } else {
      await audioPlayer
          .seek(audioPlayer.duration ?? const Duration(seconds: 0));
    }
  }

  Future<void> seekNSecBackward(Duration n) async {
    if (audioPlayer.position - n >= const Duration(seconds: 0)) {
      await audioPlayer.seek(audioPlayer.position - n);
    } else {
      await audioPlayer.seek(const Duration(seconds: 0));
    }
  }

  void setLoopMode(LoopMode loopMode) {
    if (loopMode == LoopMode.one) {
      audioPlayer.setLoopMode(LoopMode.one);
    } else {
      audioPlayer.setLoopMode(LoopMode.off);
    }
    this.loopMode.add(loopMode);
  }

  Future<void> shuffle(bool shuffle) async {
    shuffleMode.add(shuffle);
    if (shuffle) {
      shuffleIdx = 0;
      shuffleList = generateRandomIndices(queue.value.length);
    }
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    fromPlaylist.add(true);
    queue.add([]);
    relatedSongs.add([]);
    queue.add(mediaList.mediaItems);
    queueTitle.add(mediaList.playlistName);
    shuffle(shuffling || shuffleMode.value);
    await prepare4play(idx: idx, doPlay: doPlay);
    // if (doPlay) play();
  }

  @override
  Future<void> pause() async {
    await audioPlayer.pause();
    log("paused", name: "bloomeePlayer");
  }

  PlayerErrorType _categorizeError(dynamic error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return PlayerErrorType.networkError;
    } else if (error is FormatException ||
        error is ArgumentError ||
        error.toString().toLowerCase().contains('format') ||
        error.toString().toLowerCase().contains('source')) {
      return PlayerErrorType.sourceError;
    } else if (error is PlayerException) {
      return PlayerErrorType.playbackError;
    } else if (error.toString().toLowerCase().contains('permission')) {
      return PlayerErrorType.permissionError;
    } else if (error.toString().toLowerCase().contains('buffer')) {
      return PlayerErrorType.bufferingError;
    }
    return PlayerErrorType.unknownError;
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem) async {
    final mediaId = mediaItem.id;

    // Check cache first (if not expired)
    if (_audioSourceCache.containsKey(mediaId) && !_isCacheExpired(mediaId)) {
      log('Using cached audio source for ${mediaItem.title}',
          name: "bloomeePlayer");
      return _audioSourceCache[mediaId]!;
    }

    try {
      // Check for offline version first
      final _down = await BloomeeDBService.getDownloadDB(
          mediaItem2MediaItemModel(mediaItem));
      if (_down != null) {
        log("Playing Offline: ${mediaItem.title}", name: "bloomeePlayer");
        SnackbarService.showMessage("Playing Offline",
            duration: const Duration(seconds: 1));
        isOffline.add(true);
        final audioSource = AudioSource.uri(
            Uri.file('${_down.filePath}/${_down.fileName}'),
            tag: mediaItem);

        // Cache offline source (it won't expire)
        _addToCache(mediaId, audioSource);

        return audioSource;
      }

      // Check network connectivity before attempting online playback
      if (!isConnected.value) {
        throw Exception('No network connection available');
      }

      isOffline.add(false);
      AudioSource audioSource;

      if (mediaItem.extras?["source"] == "youtube") {
        String? quality =
            await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality);
        quality = quality ?? "high";
        quality = quality.toLowerCase();
        final id = mediaItem.id.replaceAll("youtube", '');

        audioSource =
            YouTubeAudioSource(videoId: id, quality: quality, tag: mediaItem);
      } else {
        String? kurl = await getJsQualityURL(mediaItem.extras?["url"]);
        if (kurl == null || kurl.isEmpty) {
          throw Exception('Failed to get stream URL');
        }

        log('Playing: $kurl', name: "bloomeePlayer");
        audioSource = AudioSource.uri(Uri.parse(kurl), tag: mediaItem);
      }

      // Cache the audio source
      _addToCache(mediaId, audioSource);

      return audioSource;
    } catch (e) {
      log('Error getting audio source for ${mediaItem.title}: $e',
          name: "bloomeePlayer");

      final errorType = _categorizeError(e);
      String errorMessage;

      switch (errorType) {
        case PlayerErrorType.networkError:
          errorMessage = 'Network error while loading song';
          break;
        case PlayerErrorType.sourceError:
          errorMessage = 'Song source unavailable';
          break;
        case PlayerErrorType.playbackError:
          errorMessage = 'Playback error occurred';
          break;
        case PlayerErrorType.bufferingError:
          errorMessage = 'Buffering error occurred';
          break;
        case PlayerErrorType.permissionError:
          errorMessage = 'Permission denied';
          break;
        default:
          errorMessage = 'Unknown error loading song';
      }

      _handleError(errorType, errorMessage, mediaItem, e);
      rethrow;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= queue.value.length) {
      log("skipToQueueItem: Invalid index $index, queue length: ${queue.value.length}",
          name: "bloomeePlayer");
      return super.skipToQueueItem(index);
    }

    currentPlayingIdx = index;
    await playMediaItem(queue.value[index]);

    log("skipToQueueItem: Moved to index $index", name: "bloomeePlayer");
    return super.skipToQueueItem(index);
  }

  Future<void> playAudioSource({
    required AudioSource audioSource,
    required String mediaId,
  }) async {
    try {
      await pause();
      await seek(Duration.zero);

      if (_playlist.children.isNotEmpty) {
        await _playlist.clear();
      }

      await _playlist.add(audioSource);
      await audioPlayer.load();

      if (!audioPlayer.playing) {
        await play();
      }

      // Clear any previous errors on successful playback
      lastError.add(null);
      _retryAttempts.remove(mediaId);
      _lastRetryTime.remove(mediaId);

      log('Successfully started playback for $mediaId', name: "bloomeePlayer");
    } catch (e) {
      log("Error in playAudioSource: $e", name: "bloomeePlayer");

      PlayerErrorType errorType;
      String errorMessage;

      if (e is PlayerException) {
        if (e.message?.contains('network') == true ||
            e.message?.contains('connection') == true) {
          errorType = PlayerErrorType.networkError;
          errorMessage = 'Network error during playback';
        } else if (e.message?.contains('source') == true ||
            e.message?.contains('format') == true) {
          errorType = PlayerErrorType.sourceError;
          errorMessage = 'Audio source error';
        } else {
          errorType = PlayerErrorType.playbackError;
          errorMessage = 'Playback failed: ${e.message}';
        }

        final currentItem =
            queue.value.isNotEmpty ? queue.value[currentPlayingIdx] : null;
        _handleError(errorType, errorMessage, currentItem, e);

        // For critical errors, try to recover
        if (errorType == PlayerErrorType.sourceError) {
          _clearCachedSource(mediaId);
        }
      } else {
        final currentItem =
            queue.value.isNotEmpty ? queue.value[currentPlayingIdx] : null;
        _handleError(PlayerErrorType.unknownError, 'Unexpected playback error',
            currentItem, e);
      }

      rethrow;
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem, {bool doPlay = true}) async {
    try {
      log('Attempting to play: ${mediaItem.title}', name: "bloomeePlayer");

      final audioSource = await getAudioSource(mediaItem);
      await playAudioSource(audioSource: audioSource, mediaId: mediaItem.id);

      if (doPlay && !audioPlayer.playing) {
        await play();
      }

      await check4RelatedSongs();
    } catch (e) {
      log('Failed to play media item ${mediaItem.title}: $e',
          name: "bloomeePlayer");

      // Don't rethrow here, let the error handling system manage it
      // The error was already handled in getAudioSource or playAudioSource
    }
  }

  Future<void> prepare4play({int idx = 0, bool doPlay = false}) async {
    if (queue.value.isEmpty) {
      log('Cannot prepare4play: queue is empty', name: 'bloomeePlayer');
      return;
    }

    if (idx >= queue.value.length) {
      log('Index $idx is out of bounds, queue length: ${queue.value.length}',
          name: 'bloomeePlayer');
      idx = queue.value.length - 1; // Use last valid index
    }

    currentPlayingIdx = idx;
    await playMediaItem(currentMedia, doPlay: doPlay);
    BloomeeDBService.putRecentlyPlayed(MediaItem2MediaItemDB(currentMedia));
  }

  @override
  Future<void> rewind() async {
    if (audioPlayer.processingState == ProcessingState.ready) {
      await audioPlayer.seek(Duration.zero);
    } else if (audioPlayer.processingState == ProcessingState.completed) {
      await prepare4play(idx: currentPlayingIdx);
    }
  }

  @override
  Future<void> skipToNext() async {
    // Check if queue is valid before proceeding
    if (queue.value.isEmpty) {
      log('Cannot skip to next: queue is empty', name: 'bloomeePlayer');
      return;
    }

    if (!shuffleMode.value) {
      if (currentPlayingIdx < (queue.value.length - 1)) {
        currentPlayingIdx++;
        await prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else if (loopMode.value == LoopMode.all) {
        currentPlayingIdx = 0;
        await prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else {
        // End of queue reached and no loop mode
        log('End of queue reached, no more items to skip to',
            name: 'bloomeePlayer');
        return;
      }
    } else {
      if (shuffleList.isEmpty) {
        log('Cannot skip in shuffle mode: shuffle list is empty',
            name: 'bloomeePlayer');
        return;
      }

      if (shuffleIdx < (shuffleList.length - 1)) {
        shuffleIdx++;
        await prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      } else if (loopMode.value == LoopMode.all) {
        shuffleIdx = 0;
        await prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      } else {
        // End of shuffle list reached and no loop mode
        log('End of shuffle list reached, no more items to skip to',
            name: 'bloomeePlayer');
        return;
      }
    }

    // Only call super.skipToNext() if we have a valid queue and current item
    try {
      if (queue.value.isNotEmpty && currentPlayingIdx < queue.value.length) {
        await super.skipToNext();
      }
    } catch (e) {
      log('Error calling super.skipToNext(): $e', name: 'bloomeePlayer');
      // Don't rethrow as this is just a notification to the audio service
    }
  }

  @override
  Future<void> stop() async {
    // Stop audio player and clear presence, then propagate stop to audio service
    await audioPlayer.stop();
    DiscordService.clearPresence();
    await super.stop();
  }

  @override
  Future<void> skipToPrevious() async {
    // Check if queue is valid before proceeding
    if (queue.value.isEmpty) {
      log('Cannot skip to previous: queue is empty', name: 'bloomeePlayer');
      return;
    }

    if (!shuffleMode.value) {
      if (currentPlayingIdx > 0) {
        currentPlayingIdx--;
        await prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else {
        // Already at the beginning
        log('Already at the beginning of queue', name: 'bloomeePlayer');
        return;
      }
    } else {
      if (shuffleList.isEmpty) {
        log('Cannot skip in shuffle mode: shuffle list is empty',
            name: 'bloomeePlayer');
        return;
      }

      if (shuffleIdx > 0) {
        shuffleIdx--;
        await prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      } else {
        // Already at the beginning of shuffle list
        log('Already at the beginning of shuffle list', name: 'bloomeePlayer');
        return;
      }
    }

    // Only call super.skipToPrevious() if we have a valid queue and current item
    try {
      if (queue.value.isNotEmpty && currentPlayingIdx < queue.value.length) {
        await super.skipToPrevious();
      }
    } catch (e) {
      log('Error calling super.skipToPrevious(): $e', name: 'bloomeePlayer');
      // Don't rethrow as this is just a notification to the audio service
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await _cleanup();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _cleanup();
    return super.onNotificationDeleted();
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return; // Prevent multiple cleanup calls
    _isDisposed = true;

    log('Cleaning up player resources', name: 'bloomeePlayer');

    // Cancel timers and subscriptions
    _reconnectionTimer?.cancel();
    _connectivityTimer?.cancel();

    // Cancel all stream subscriptions
    await _playbackEventSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _queueSubscription?.cancel();
    await _mediaItemSubscription?.cancel();
    await _connectivitySubscription?.cancel();

    // Clear caches
    _clearAudioSourceCache();
    _retryAttempts.clear();
    _lastRetryTime.clear();

    // Clear Discord presence
    DiscordService.clearPresence();

    // Stop and dispose audio player
    try {
      await audioPlayer.stop();
      await audioPlayer.dispose();
    } catch (e) {
      log('Error disposing audio player: $e', name: 'bloomeePlayer');
    }

    // Close behavior subjects
    try {
      await fromPlaylist.close();
      await isOffline.close();
      await shuffleMode.close();
      await isConnected.close();
      await lastError.close();
      await relatedSongs.close();
      await loopMode.close();
    } catch (e) {
      log('Error closing behavior subjects: $e', name: 'bloomeePlayer');
    }

    await super.stop();
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    final currentQueue = List<MediaItem>.from(queue.value);
    if (index < currentQueue.length) {
      currentQueue.insert(index, mediaItem);
    } else {
      currentQueue.add(mediaItem);
    }
    queue.add(currentQueue);

    // Adjust the currentPlayingIdx
    if (currentPlayingIdx >= index) {
      currentPlayingIdx++;
    }

    // Sync with audio service queue
    try {
      await super.insertQueueItem(index, mediaItem);
    } catch (e) {
      log('Error syncing insertQueueItem with audio service: $e',
          name: 'bloomeePlayer');
    }
  }

  @override
  Future<void> addQueueItem(
    MediaItem mediaItem,
  ) async {
    if (queue.value.any((e) => e.id == mediaItem.id)) return;
    queueTitle.add("Queue");

    final newQueue = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(newQueue);

    if (newQueue.length == 1) {
      await prepare4play(idx: 0, doPlay: true);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue,
      {bool doPlay = false}) async {
    queue.add(newQueue);
    await prepare4play(idx: 0, doPlay: doPlay);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = "Queue", bool atLast = false}) async {
    if (!atLast) {
      for (var mediaItem in mediaItems) {
        await addQueueItem(
          mediaItem,
        );
      }
    } else {
      if (fromPlaylist.value) {
        fromPlaylist.add(false);
      }
      final newQueue = List<MediaItem>.from(queue.value)..addAll(mediaItems);
      queue.add(newQueue);
      queueTitle.add("Queue");
    }
  }

  Future<void> addPlayNextItem(MediaItem mediaItem) async {
    if (queue.value.isNotEmpty) {
      // check if mediaItem is already exist return if it is
      if (queue.value.any((e) => e.id == mediaItem.id)) return;
      final newQueue = List<MediaItem>.from(queue.value)
        ..insert(currentPlayingIdx + 1, mediaItem);
      queue.add(newQueue);
    } else {
      updateQueue([mediaItem], doPlay: true);
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < queue.value.length) {
      final newQueue = List<MediaItem>.from(queue.value);
      newQueue.removeAt(index);
      queue.add(newQueue);

      if (currentPlayingIdx == index) {
        if (index < newQueue.length) {
          await prepare4play(idx: index, doPlay: true);
        } else if (index > 0) {
          await prepare4play(idx: index - 1, doPlay: true);
        } else {
          // stop();
        }
      } else if (currentPlayingIdx > index) {
        currentPlayingIdx--;
      }
    }
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    log("Moving from $oldIndex to $newIndex", name: "bloomeePlayer");
    final newQueue = List<MediaItem>.from(queue.value);
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    queue.add(newQueue);

    // update the currentPlayingIdx
    if (currentPlayingIdx == oldIndex) {
      currentPlayingIdx = newIndex;
    } else if (oldIndex < currentPlayingIdx && newIndex >= currentPlayingIdx) {
      currentPlayingIdx--;
    } else if (oldIndex > currentPlayingIdx && newIndex <= currentPlayingIdx) {
      currentPlayingIdx++;
    }
  }
}
