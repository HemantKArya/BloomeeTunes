import 'dart:developer';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:rxdart/subjects.dart';

import '../model/MediaPlaylistModel.dart';

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
  BehaviorSubject<bool> isLinkProcessing = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<LoopMode> loopMode =
      BehaviorSubject<LoopMode>.seeded(LoopMode.off);
  int currentPlayingIdx = 0;
  int shuffleIdx = 0;
  List<int> shuffleList = [];

  bool isPaused = false;

  CancelableOperation<AudioSource?> getLinkOperation =
      CancelableOperation.fromFuture(Future.value());

  BloomeeMusicPlayer() {
    audioPlayer = AudioPlayer(
      androidOffloadSchedulingEnabled: true,
      handleInterruptions: true,
    );
    audioPlayer.setVolume(1);
    audioPlayer.playbackEventStream.listen(_broadcastPlayerEvent);
    audioPlayer.setShuffleModeEnabled(false);
    audioPlayer.setLoopMode(LoopMode.off);
  }

  void _broadcastPlayerEvent(PlaybackEvent event) {
    bool isPlaying = audioPlayer.playing;
    // log(event.playing.toString(), name: "bloomeePlayer-event");
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
      },
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: audioPlayer.position,
      playing: isPlaying,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      // playing: audioPlayer.playerState.playing,
    ));
  }

  MediaItemModel get currentMedia =>
      mediaItem2MediaItemModel(queue.value[currentPlayingIdx]);

  @override
  Future<void> play() async {
    if (isLinkProcessing.value == false) {
      await audioPlayer.play();
      isPaused = false;
    } else {
      log("Link is in process...", name: "bloomeePlayer");
      SnackbarService.showMessage("Link is in process...");
    }
  }

  @override
  Future<void> seek(Duration position) async {
    audioPlayer.seek(position);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    super.mediaItem.add(mediaItem);
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
    audioPlayer.setShuffleModeEnabled(shuffle);
    if (shuffle) {
      shuffleIdx = 0;
      shuffleList = generateRandomIndices(queue.value.length);
    }
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    fromPlaylist.add(true);
    queue.add(mediaList.mediaItems);
    queueTitle.add(mediaList.albumName);
    shuffle(shuffling);
    if (shuffling) {
      await prepare4play(idx: shuffleList[shuffleIdx], doPlay: doPlay);
    } else {
      await prepare4play(idx: idx, doPlay: doPlay);
    }
    // if (doPlay) play();
  }

  @override
  Future<void> pause() async {
    await audioPlayer.pause();
    isPaused = true;
    log("paused", name: "bloomeePlayer");
  }

  Future<String?> latestYtLink(String id) async {
    final vidInfo = await BloomeeDBService.getYtLinkCache(id);
    if (vidInfo != null) {
      if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
          vidInfo.expireAt) {
        log("Link expired for vidId: $id", name: "bloomeePlayer");
        return await refreshYtLink(id);
      } else {
        log("Link found in cache for vidId: $id", name: "bloomeePlayer");
        String kurl = vidInfo.lowQURL!;
        // await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality)
        //     .then((value) {
        //   log("Play quality: $value", name: "bloomeePlayer");
        //   if (value != null) {
        //     if (value == "High") {
        //       kurl = vidInfo.highQURL;
        //     } else {
        //       kurl = vidInfo.lowQURL!;
        //     }
        //   }
        // });
        return kurl;
      }
    } else {
      log("No cache found for vidId: $id", name: "bloomeePlayer");
      return await refreshYtLink(id);
    }
  }

  Future<String?> refreshYtLink(String id) async {
    // String quality = "Low";
    await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality)
        .then((value) {
      log('Play quality: $value', name: "bloomeePlayer");
      // if (value != null) {
      //   if (value == "High") {
      //     quality = "High";
      //   } else {
      //     quality = "Low";
      //   }
      // }
    });
    final vidMap = await YouTubeServices().refreshLink(id, quality: "Low");
    if (vidMap != null) {
      return vidMap["url"] as String;
    } else {
      return null;
    }
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem) async {
    final _down = await BloomeeDBService.getDownloadDB(
        mediaItem2MediaItemModel(mediaItem));
    if (_down != null) {
      log("Playing Offline", name: "bloomeePlayer");
      SnackbarService.showMessage("Playing Offline",
          duration: const Duration(seconds: 1));
      isOffline.add(true);
      return AudioSource.uri(Uri.file('${_down.filePath}/${_down.fileName}'));
    } else {
      isOffline.add(false);
      log("Playing online", name: "bloomeePlayer");
      if (mediaItem.extras?["source"] == "youtube") {
        final id = mediaItem.id.replaceAll("youtube", '');
        final tempStrmLink = await latestYtLink(id);
        if (tempStrmLink != null) {
          return AudioSource.uri(Uri.parse(tempStrmLink));
        }
      }
      String? kurl = await getJsQualityURL(mediaItem.extras?["url"]);
      log('Playing: $kurl', name: "bloomeePlayer");
      return AudioSource.uri(Uri.parse(kurl!));
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem, {bool doPlay = true}) async {
    updateMediaItem(mediaItem);

    isLinkProcessing.add(true);
    audioPlayer.pause();
    audioPlayer.seek(Duration.zero);

    if (!getLinkOperation.isCompleted) {
      await getLinkOperation.cancel();
    }
    getLinkOperation = CancelableOperation.fromFuture(
      getAudioSource(mediaItem),
      onCancel: () {
        log("skipping....", name: "bloomeePlayer");
        return;
      },
    );

    getLinkOperation.then((value) async {
      if (value != null) {
        try {
          await audioPlayer.setAudioSource(value).then((value) {
            isLinkProcessing.add(false);
            if (!isPaused || doPlay) play();
          });
        } catch (e) {
          isLinkProcessing.add(false);
          log("Error: $e", name: "bloomeePlayer");
          SnackbarService.showMessage("Error in playing this song: $e");
        }
      }
    });
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
    if (!audioPlayer.shuffleModeEnabled) {
      if (currentPlayingIdx < (queue.value.length - 1)) {
        currentPlayingIdx++;
        prepare4play(idx: currentPlayingIdx);
      } else if (loopMode.value == LoopMode.all) {
        currentPlayingIdx = 0;
        prepare4play(idx: currentPlayingIdx);
      }
    } else {
      if (shuffleIdx < (queue.value.length - 1)) {
        shuffleIdx++;
        if (shuffleIdx >= shuffleList.length) {
          shuffleIdx = 0;
        }
        prepare4play(idx: shuffleList[shuffleIdx]);
      } else if (loopMode.value == LoopMode.all) {
        shuffleIdx = 0;
        prepare4play(idx: shuffleList[shuffleIdx]);
      }
    }
  }

  @override
  Future<void> stop() async {
    // log("Called Stop!!");
    audioPlayer.stop();
    super.stop();
  }

  @override
  Future<void> skipToPrevious() async {
    if (!audioPlayer.shuffleModeEnabled) {
      if (currentPlayingIdx > 0) {
        currentPlayingIdx--;
        prepare4play(idx: currentPlayingIdx);
      }
    } else {
      if (shuffleIdx > 0) {
        shuffleIdx--;
        prepare4play(idx: shuffleList[shuffleIdx]);
      }
    }
  }

  @override
  Future<void> onTaskRemoved() {
    super.stop();
    audioPlayer.dispose();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() {
    audioPlayer.dispose();
    audioPlayer.stop();
    super.stop();

    return super.onNotificationDeleted();
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    if (index < queue.value.length) {
      queue.value.insert(index, mediaItem);
    } else {
      queue.add(queue.value..add(mediaItem));
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem,
      {bool doPlay = true, bool atLast = false}) async {
    if (fromPlaylist.value) {
      fromPlaylist.add(false);
      if (!doPlay) {
        queue.add([currentMedia, mediaItem]);
        currentPlayingIdx = 0;
        if (audioPlayer.processingState == ProcessingState.completed) {
          queue.add([mediaItem]);
          await prepare4play(idx: 0, doPlay: doPlay);
        }
      } else {
        queue.add([mediaItem]);
        await prepare4play(idx: 0, doPlay: doPlay);
      }
    } else {
      if (atLast) {
        queue.add(queue.value..add(mediaItem));
      } else if (currentPlayingIdx >= queue.value.length - 1 ||
          queue.value.isEmpty) {
        queue.add(queue.value..add(mediaItem));
        if (doPlay) {
          await prepare4play(idx: queue.value.length - 1, doPlay: doPlay);
        } else if (audioPlayer.processingState == ProcessingState.completed ||
            queue.value.length == 1) {
          await prepare4play(idx: queue.value.length - 1, doPlay: doPlay);
        }
      } else {
        queue.add(queue.value..insert(currentPlayingIdx + 1, mediaItem));
        if (doPlay) {
          await prepare4play(idx: currentPlayingIdx + 1, doPlay: true);
        }
      }
      shuffle(audioPlayer.shuffleModeEnabled);
    }
    queueTitle.add("Queue");
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = "Queue"}) async {
    for (var mediaItem in mediaItems) {
      await addQueueItem(
        mediaItem,
        atLast: true,
      );
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    queue.value.removeAt(index);
  }
}
