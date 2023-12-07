import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';

import '../model/MediaPlaylistModel.dart';

class BloomeeMusicPlayer extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  late AudioPlayer audioPlayer;
  List<MediaItemModel> currentPlaylist = [];
  BehaviorSubject<String> currentQueueName =
      BehaviorSubject<String>.seeded("Empty");
  int currentPlayingIdx = 0;

  BloomeeMusicPlayer() {
    audioPlayer = AudioPlayer(
        androidOffloadSchedulingEnabled: true, handleInterruptions: true);
    audioPlayer.setVolume(1);

    audioPlayer.playerStateStream.listen((event) {
      playbackState.add(PlaybackState(
        // Which buttons should appear in the notification now
        controls: [
          MediaControl.skipToPrevious,
          event.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        // Which other actions should be enabled in the notification
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },

        androidCompactActionIndices: const [0, 1, 3],

        playing: event.playing,
      ));
    });
  }

  MediaItemModel get currentMedia => currentPlaylist[currentPlayingIdx];

  @override
  Future<void> play() async {
    await audioPlayer.play();
    // print("playing");
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
    currentPlaylist = mediaList.mediaItems;
    currentQueueName.add(mediaList.albumName);
    await prepare4play(idx: idx);
    if (doPlay) play();
  }

  @override
  Future<void> pause() async {
    await audioPlayer.pause();
    print("paused");
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    print(mediaItem.extras?["url"]);
    bool isPlaying = audioPlayer.playing;
    updateMediaItem(mediaItem);
    if (mediaItem.extras?["source"] == "youtube") {
      audioPlayer.seek(Duration.zero);
      audioPlayer.stop();
      final tempStrmVideo = await YouTubeServices()
          .getVideoFromId(mediaItem.id.replaceAll("youtube", ''));
      if (tempStrmVideo != null) {
        final tempStrmLink = await YouTubeServices().getUri(tempStrmVideo);

        await audioPlayer.setUrl(tempStrmLink.first).then((value) {
          if (isPlaying) audioPlayer.play();
        });
      }
      return;
    }
    await audioPlayer.setUrl(mediaItem.extras?["url"]);
  }

  Future<void> prepare4play({int idx = 0, bool doPlay = false}) async {
    if (currentPlaylist.isNotEmpty) {
      currentPlayingIdx = idx;
      await playMediaItem(currentMedia);
      if (doPlay) play();
    }
  }

  @override
  Future<void> rewind() async {
    if (audioPlayer.processingState == ProcessingState.ready) {
      await audioPlayer.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (currentPlayingIdx < (currentPlaylist.length - 1)) {
      currentPlayingIdx++;
      prepare4play(idx: currentPlayingIdx);
      print("skippingNext-------");
    }
  }

  @override
  Future<void> stop() async {
    // print("Called Stop!!");
    // audioPlayer.stop();
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
    audioPlayer.stop();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() {
    audioPlayer.stop();

    return super.onNotificationDeleted();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    queue.add([mediaItem]);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    queue.add(mediaItems);
  }
}
