import 'dart:developer';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:rxdart/subjects.dart';

import '../model/MediaPlaylistModel.dart';

class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late AudioPlayer audioPlayer;

  List<MediaItemModel> currentPlaylist = [];
  int currentQueueIdx = 0;
  int currentPlaylistIdx = 0;
  BehaviorSubject<bool> fromPlaylist = BehaviorSubject<bool>.seeded(false);

  BehaviorSubject<bool> isLinkProcessing = BehaviorSubject<bool>.seeded(false);
  int currentPlayingIdx = 0;
  bool isPaused = false;

  CancelableOperation<List<String>> getLinkOperation =
      CancelableOperation.fromFuture(Future.value([]));

  BloomeeMusicPlayer() {
    audioPlayer = AudioPlayer(
      androidOffloadSchedulingEnabled: true,
      handleInterruptions: true,
    );
    audioPlayer.setVolume(1);
    audioPlayer.playbackEventStream.listen(_broadcastPlayerEvent);
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
    await audioPlayer.play();
    isPaused = false;
    // log("playing", name: "bloomeePlayer");
  }

  @override
  Future<void> seek(Duration position) async {
    audioPlayer.seek(position);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    super.mediaItem.add(mediaItem);
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false}) async {
    fromPlaylist.add(true);
    queue.add(mediaList.mediaItems);
    queueTitle.add(mediaList.albumName);
    await prepare4play(idx: idx, doPlay: doPlay);
    // if (doPlay) play();
  }

  @override
  Future<void> pause() async {
    await audioPlayer.pause();
    isPaused = true;
    log("paused", name: "bloomeePlayer");
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem, {bool doPlay = true}) async {
    // log(mediaItem.extras?["url"], name: "bloomeePlayer");
    updateMediaItem(mediaItem);
    if (mediaItem.extras?["source"] == "youtube") {
      isLinkProcessing.add(true);
      audioPlayer.pause();
      audioPlayer.seek(Duration.zero);

      final tempStrmVideo = await YouTubeServices()
          .getVideoFromId(mediaItem.id.replaceAll("youtube", ''));
      if (tempStrmVideo != null) {
        if (!getLinkOperation.isCompleted) {
          getLinkOperation.cancel();
        }

        getLinkOperation = CancelableOperation.fromFuture(
            YouTubeServices().getUri(tempStrmVideo), onCancel: () {
          log("Canceled/Skipped - ${mediaItem.title}", name: "bloomeePlayer");
        });

        getLinkOperation.then((tempStrmLinks) {
          isLinkProcessing.add(false);
          audioPlayer.setUrl(tempStrmLinks.first).then((value) {
            if (super.mediaItem.value?.id == mediaItem.id && !isPaused) {
              audioPlayer.play();
            }
          });
        });
      }
      return;
    }
    await audioPlayer.setUrl(mediaItem.extras?["url"]);
    if (doPlay) play();
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
    if (currentPlayingIdx < (queue.value.length - 1)) {
      currentPlayingIdx++;
      prepare4play(idx: currentPlayingIdx);
      // log("skippingNext-------", name: "bloomeePlayer");
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
    if (currentPlayingIdx > 0) {
      currentPlayingIdx--;
      prepare4play(idx: currentPlayingIdx);
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
      queueTitle.add("Queue");
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
    }
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
