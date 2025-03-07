import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
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

List<int> generateRandomIndices(int length) {
  List<int> indices = List<int>.generate(length, (i) => i);
  indices.shuffle();
  return indices;
}

class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late AudioPlayer audioPlayer;
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> isOffline = BehaviorSubject<bool>.seeded(false);
  // BehaviorSubject<bool> isLinkProcessing = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<bool> shuffleMode = BehaviorSubject<bool>.seeded(false);

  BehaviorSubject<List<MediaItem>> relatedSongs =
      BehaviorSubject<List<MediaItem>>.seeded([]);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);
  int currentPlayingIdx = 0;
  int shuffleIdx = 0;
  List<int> shuffleList = [];
  final _playlist = ConcatenatingAudioSource(children: []);

  // final ReceivePort receivePortYt = ReceivePort();
  // SendPort? sendPortYt;

  BloomeeMusicPlayer() {
    // initBgYt();
    audioPlayer = AudioPlayer(
      handleInterruptions: true,
    );
    audioPlayer.setVolume(1);
    audioPlayer.playbackEventStream.listen(_broadcastPlayerEvent);
    audioPlayer.setLoopMode(LoopMode.off);
    audioPlayer.setAudioSource(_playlist, preload: false);

    // Update the current media item when the audio player changes to the next
    Rx.combineLatest2(
      audioPlayer.sequenceStream,
      audioPlayer.currentIndexStream,
      (sequence, index) {
        if (sequence == null || sequence.isEmpty) return null;
        return sequence[index ?? 0].tag as MediaItem;
      },
    ).whereType<MediaItem>().listen(mediaItem.add);

    // Trigger skipToNext when the current song ends.
    final endingOffset =
        Platform.isWindows ? 200 : (Platform.isLinux ? 700 : 0);
    audioPlayer.positionStream.listen((event) {
      if (audioPlayer.duration != null &&
          audioPlayer.duration?.inSeconds != 0 &&
          event.inMilliseconds >
              audioPlayer.duration!.inMilliseconds - endingOffset &&
          loopMode.value != LoopMode.one) {
        EasyThrottle.throttle('skipNext', const Duration(milliseconds: 2000),
            () async => await skipToNext());
      }
    });

    // Refresh shuffle list when queue changes
    queue.listen((e) {
      shuffleList = generateRandomIndices(e.length);
    });
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
      // playing: audioPlayer.playerState.playing,
    ));
  }

  MediaItemModel get currentMedia => queue.value.isNotEmpty
      ? mediaItem2MediaItemModel(queue.value[currentPlayingIdx])
      : mediaItemModelNull;

  @override
  Future<void> play() async {
    await audioPlayer.play();

    DiscordService.updatePresence(
      mediaItem: currentMedia,
      isPlaying: true,
    );
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
        final songs = await compute(SaavnAPI().getRelated, currentMedia.id);
        if (songs['total'] > 0) {
          final List<MediaItem> temp =
              fromSaavnSongMapList2MediaItemList(songs['songs']);
          relatedSongs.add(temp.sublist(1));
          log("Related Songs: ${songs['total']}");
        }
      } else if (currentMedia.extras?["source"].contains("youtube") ?? false) {
        final songs = await compute(YtMusicService().getRelated,
            currentMedia.id.replaceAll('youtube', ''));
        if (songs['total'] > 0) {
          final List<MediaItem> temp =
              fromYtSongMapList2MediaItemList(songs['songs']);
          relatedSongs.add(temp.sublist(1));
          log("Related Songs: ${songs['total']}");
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
    DiscordService.updatePresence(
      mediaItem: currentMedia,
      isPlaying: false,
    );
    log("paused", name: "bloomeePlayer");
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem) async {
    final _down = await BloomeeDBService.getDownloadDB(
        mediaItem2MediaItemModel(mediaItem));
    if (_down != null) {
      log("Playing Offline", name: "bloomeePlayer");
      SnackbarService.showMessage("Playing Offline",
          duration: const Duration(seconds: 1));
      isOffline.add(true);
      return AudioSource.uri(Uri.file('${_down.filePath}/${_down.fileName}'),
          tag: mediaItem);
    } else {
      isOffline.add(false);
      if (mediaItem.extras?["source"] == "youtube") {
        String? quality =
            await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality);
        quality = quality ?? "high";
        quality = quality.toLowerCase();
        final id = mediaItem.id.replaceAll("youtube", '');
        return YouTubeAudioSource(
            videoId: id, quality: quality, tag: mediaItem);
      }
      String? kurl = await getJsQualityURL(mediaItem.extras?["url"]);
      log('Playing: $kurl', name: "bloomeePlayer");
      return AudioSource.uri(Uri.parse(kurl!), tag: mediaItem);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < queue.value.length) {
      currentPlayingIdx = index;
      await playMediaItem(queue.value[index]);
    } else {
      // await loadRelatedSongs();
      if (index < queue.value.length) {
        currentPlayingIdx = index;
        await playMediaItem(queue.value[index]);
      }
    }

    log("skipToQueueItem", name: "bloomeePlayer");
    return super.skipToQueueItem(index);
  }

  Future<void> playAudioSource({
    required AudioSource audioSource,
    required String mediaId,
  }) async {
    await pause();
    await seek(Duration.zero);
    try {
      if (_playlist.children.isNotEmpty) {
        await _playlist.clear();
      }
      await _playlist.add(audioSource);
      await audioPlayer.load();
      if (!audioPlayer.playing) await play();
    } catch (e) {
      log("Error: $e", name: "bloomeePlayer");
      if (e is PlayerException) {
        SnackbarService.showMessage("Failed to play song: $e");
        await stop();
      }
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem, {bool doPlay = true}) async {
    final audioSource = await getAudioSource(mediaItem);
    await playAudioSource(audioSource: audioSource, mediaId: mediaItem.id);
    await check4RelatedSongs();
  }

  Future<void> prepare4play({int idx = 0, bool doPlay = false}) async {
    if (queue.value.isNotEmpty) {
      currentPlayingIdx = idx;
      await playMediaItem(currentMedia, doPlay: doPlay);
      BloomeeDBService.putRecentlyPlayed(MediaItem2MediaItemDB(currentMedia));
    }
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
    if (!shuffleMode.value) {
      if (currentPlayingIdx < (queue.value.length - 1)) {
        currentPlayingIdx++;
        prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else if (loopMode.value == LoopMode.all) {
        currentPlayingIdx = 0;
        prepare4play(idx: currentPlayingIdx, doPlay: true);
      }
    } else {
      if (shuffleIdx < (queue.value.length - 1)) {
        shuffleIdx++;
        prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      } else if (loopMode.value == LoopMode.all) {
        shuffleIdx = 0;
        prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      }
    }
  }

  @override
  Future<void> stop() async {
    // log("Called Stop!!");
    audioPlayer.stop();
    DiscordService.clearPresence();
    super.stop();
  }

  @override
  Future<void> skipToPrevious() async {
    if (!shuffleMode.value) {
      if (currentPlayingIdx > 0) {
        currentPlayingIdx--;
        prepare4play(idx: currentPlayingIdx, doPlay: true);
      }
    } else {
      if (shuffleIdx > 0) {
        shuffleIdx--;
        prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      }
    }
  }

  @override
  Future<void> onTaskRemoved() {
    DiscordService.clearPresence();
    super.stop();
    audioPlayer.dispose();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() {
    DiscordService.clearPresence();
    audioPlayer.stop();
    audioPlayer.dispose();
    super.stop();
    return super.onNotificationDeleted();
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    List<MediaItem> temp = queue.value;
    if (index < queue.value.length) {
      temp.insert(index, mediaItem);
    } else {
      temp.add(mediaItem);
    }
    queue.add(temp);

    // Adjust the currentPlayingIdx
    if (currentPlayingIdx >= index) {
      currentPlayingIdx++;
    }
  }

  @override
  Future<void> addQueueItem(
    MediaItem mediaItem,
  ) async {
    if (queue.value.any((e) => e.id == mediaItem.id)) return;
    queueTitle.add("Queue");
    queue.add(queue.value..add(mediaItem));
    if (queue.value.length == 1) {
      prepare4play(idx: queue.value.length - 1, doPlay: true);
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
      queue.add(queue.value..addAll(mediaItems));
      queueTitle.add("Queue");
    }
  }

  Future<void> addPlayNextItem(MediaItem mediaItem) async {
    if (queue.value.isNotEmpty) {
      // check if mediaItem is already exist return if it is
      if (queue.value.any((e) => e.id == mediaItem.id)) return;
      queue.add(queue.value..insert(currentPlayingIdx + 1, mediaItem));
    } else {
      updateQueue([mediaItem], doPlay: true);
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < queue.value.length) {
      List<MediaItem> temp = queue.value;
      temp.removeAt(index);
      queue.add(temp);

      if (currentPlayingIdx == index) {
        if (index < queue.value.length) {
          prepare4play(idx: index, doPlay: true);
        } else if (index > 0) {
          prepare4play(idx: index - 1, doPlay: true);
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
    List<MediaItem> temp = queue.value;
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final item = temp.removeAt(oldIndex);
    temp.insert(newIndex, item);
    queue.add(temp);

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
