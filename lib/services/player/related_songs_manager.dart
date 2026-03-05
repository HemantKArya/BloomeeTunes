import 'dart:developer';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:rxdart/rxdart.dart';

class RelatedSongsManager {
  final BehaviorSubject<List<Track>> relatedSongs =
      BehaviorSubject<List<Track>>.seeded([]);
  final PluginService _pluginService;

  // Callbacks
  Function(List<Track> items, {bool atLast})? onAddQueueItems;

  RelatedSongsManager(this._pluginService);

  Future<void> checkForRelatedSongs({
    required Track currentMedia,
    required List<Track> queue,
    required int currentPlayingIdx,
    required LoopMode loopMode,
  }) async {
    log("Checking for related songs: ${queue.isNotEmpty && (queue.length - currentPlayingIdx) < 2}",
        name: "RelatedSongsManager");

    final autoPlay =
        await SettingsDAO(DBProvider.db).getSettingBool(SettingKeys.autoPlay);
    if (autoPlay != null && !autoPlay) return;

    if (queue.isNotEmpty &&
        (queue.length - currentPlayingIdx) < 2 &&
        loopMode != LoopMode.all) {
      final parts = tryParseMediaId(currentMedia.id);
      if (parts != null) {
        try {
          final response = await _pluginService.execute(
            pluginId: parts.pluginId,
            request: PluginRequest.contentResolver(
              ContentResolverCommand.getRadioTracks(id: parts.localId),
            ),
          );

          response.when(
            moreTracks: (pagedTracks) {
              if (pagedTracks.items.isNotEmpty) {
                relatedSongs.add(pagedTracks.items);
                log("Related Songs: ${pagedTracks.items.length}",
                    name: "RelatedSongsManager");
              }
            },
            streams: (tracks) {
              if (tracks.isNotEmpty) {
                relatedSongs.add(tracks);
                log("Related Songs (streams): ${tracks.length}",
                    name: "RelatedSongsManager");
              }
            },
            albumDetails: (_) {},
            artistDetails: (_) {},
            playlistDetails: (_) {},
            search: (_) {},
            moreAlbums: (_) {},
            homeSections: (_) {},
            loadMoreItems: (_) {},
            charts: (_) {},
            chartDetails: (_) {},
            ack: () {},
          );
        } catch (e) {
          log("Failed to get related songs: $e", name: "RelatedSongsManager");
        }
      }
    }
    await loadRelatedSongs(
        queue: queue, currentPlayingIdx: currentPlayingIdx, loopMode: loopMode);
  }

  Future<void> loadRelatedSongs({
    required List<Track> queue,
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
