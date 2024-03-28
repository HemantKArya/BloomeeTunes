// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';

class ImporterState {
  int totalItems = 0;
  int importedItems = 0;
  int failedItems = 0;
  bool isDone = false;
  bool isFailed = false;
  String message = "";
  ImporterState({
    required this.totalItems,
    required this.importedItems,
    required this.failedItems,
    required this.isDone,
    required this.isFailed,
    required this.message,
  });

  ImporterState copyWith({
    int? totalItems,
    int? importedItems,
    int? failedItems,
    bool? isDone,
    bool? isFailed,
    String? message,
  }) {
    return ImporterState(
      totalItems: totalItems ?? this.totalItems,
      importedItems: importedItems ?? this.importedItems,
      failedItems: failedItems ?? this.failedItems,
      isDone: isDone ?? this.isDone,
      isFailed: isFailed ?? this.isFailed,
      message: message ?? this.message,
    );
  }
}

class ExternalMediaImporter {
  static Stream<ImporterState> ytPlaylistImporter(String url) async* {
    Uri uri = Uri.parse(url);
    int count = 0;
    String? playlistID;
    if (uri.host == 'youtube.com') {
      playlistID = uri.queryParameters['list'];
    }
    if (uri.host == 'youtu.be') {
      playlistID = uri.pathSegments.first;
    }
    if (playlistID != null) {
      log("Playlist ID: $playlistID", name: "Playlist Importer");
      yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: false,
          message: "Importing Playlist...with ID: $playlistID");
      try {
        final playlistMeta = await YoutubeExplode().playlists.get(playlistID);

        log("Playlist Name: ${playlistMeta.title}", name: "Playlist Importer");
        yield ImporterState(
          totalItems: playlistMeta.videoCount ?? 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: false,
          message: "Importing Playlist: ${playlistMeta.title}",
        );

        final _tempStrm = YoutubeExplode().playlists.getVideos(playlistID);
        await for (var video in _tempStrm) {
          {
            var itemMap = await YouTubeServices()
                .formatVideo(video: video, quality: "High", getUrl: false);
            var item = fromYtVidSongMap2MediaItem(itemMap!);
            BloomeeDBService.addMediaItem(MediaItem2MediaItemDB(item),
                MediaPlaylistDB(playlistName: playlistMeta.title));
            log("Added: ${item.title}", name: "Playlist Importer");
            yield ImporterState(
              totalItems: playlistMeta.videoCount ?? 0,
              importedItems: ++count,
              failedItems: 0,
              isDone: false,
              isFailed: false,
              message: "$count/${playlistMeta.videoCount} - ${item.title}",
            );
          }
        }
        yield ImporterState(
          totalItems: playlistMeta.videoCount ?? 0,
          importedItems: count,
          failedItems: 0,
          isDone: true,
          isFailed: false,
          message: "Imported Playlist: ${playlistMeta.title}",
        );
      } catch (e) {
        log(e.toString());
        yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: true,
          message: "Failed to import Playlist",
        );
      }
    }
  }

  void saavnPlaylistImporter() {}
  void sportifyPlaylistImporter() {}
}
