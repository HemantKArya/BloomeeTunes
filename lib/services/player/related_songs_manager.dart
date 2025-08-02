import 'dart:developer';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// Static method for compute operation
Future<Map> _getRelatedSongs(String songId) async {
  return await SaavnAPI().getRelated(songId);
}

class RelatedSongsManager {
  final BehaviorSubject<List<MediaItem>> relatedSongs =
      BehaviorSubject<List<MediaItem>>.seeded([]);

  // Callbacks
  Function(List<MediaItem> items, {bool atLast})? onAddQueueItems;

  Future<void> checkForRelatedSongs({
    required MediaItem currentMedia,
    required List<MediaItem> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    log("Checking for related songs: ${queue.isNotEmpty && (queue.length - currentPlayingIdx) < 2}",
        name: "RelatedSongsManager");

    final autoPlay =
        await BloomeeDBService.getSettingBool(GlobalStrConsts.autoPlay);
    if (autoPlay != null && !autoPlay) return;

    if (queue.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 2 &&
        loopMode != LoopMode.all) {
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
    await loadRelatedSongs(
        queue: queue, currentPlayingIdx: currentPlayingIdx, loopMode: loopMode);
  }

  Future<void> loadRelatedSongs({
    required List<MediaItem> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    if (relatedSongs.value.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 3 &&
        loopMode != LoopMode.all) {
      onAddQueueItems?.call(relatedSongs.value, atLast: true);
      relatedSongs.add([]);
    }
  }

  void clearRelatedSongs() {
    relatedSongs.add([]);
  }

  void dispose() {
    relatedSongs.close();
  }
}
