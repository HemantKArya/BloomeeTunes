// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/repository/spotify/spotify_api.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/utils/url_checker.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';

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
  /// Search for a track using loaded content-resolver plugins.
  static Future<Track?> _searchTrackByMeta(String query) async {
    final pluginService = ServiceLocator.pluginService;
    final pluginIds = pluginService.getLoadedPlugins();
    if (pluginIds.isEmpty) {
      log('No plugins loaded', name: 'MediaImporter');
      return null;
    }

    for (final pluginId in pluginIds) {
      try {
        final response = await pluginService.execute(
          pluginId: pluginId,
          request: PluginRequest.contentResolver(
            ContentResolverCommand.search(
              query: query,
              filter: ContentSearchFilter.track,
            ),
          ),
        );

        // Extract first track from search results
        if (response is PluginResponse_Search) {
          for (final item in response.field0.items) {
            if (item is MediaItem_Track) {
              return item.field0;
            }
          }
        }
      } catch (e) {
        // Plugin doesn't support content-resolver search, try next
        continue;
      }
    }
    log('No track found for query: $query', name: 'MediaImporter');
    return null;
  }

  // --------------- YouTube ---------------

  static Stream<ImporterState> ytPlaylistImporter(String url) async* {
    yield ImporterState(
      totalItems: 0,
      importedItems: 0,
      failedItems: 0,
      isDone: false,
      isFailed: true,
      message:
          "YouTube playlist import requires a plugin. Please install a YouTube plugin.",
    );
  }

  static Future<Track?> ytMediaImporter(String url) async {
    SnackbarService.showMessage(
      "YouTube import requires a plugin. Searching...",
      loading: true,
    );
    // Try to extract video title from URL and search
    final videoId = extractVideoId(url);
    if (videoId != null) {
      final track = await _searchTrackByMeta(videoId);
      if (track != null) {
        SnackbarService.showMessage("Found: ${track.title}");
        return track;
      }
    }
    SnackbarService.showMessage("Could not find track");
    return null;
  }

  // --------------- YouTube Music ---------------

  static Stream<ImporterState> ytmPlaylistImporter(String url) async* {
    yield ImporterState(
      totalItems: 0,
      importedItems: 0,
      failedItems: 0,
      isDone: false,
      isFailed: true,
      message:
          "YouTube Music playlist import requires a plugin. Please install a YouTube Music plugin.",
    );
  }

  static Future<Track?> ytmMediaImporter(String url) async {
    SnackbarService.showMessage(
      "YouTube Music import requires a plugin. Searching...",
      loading: true,
    );
    final videoId = extractYTMusicId(url);
    if (videoId != null) {
      final track = await _searchTrackByMeta(videoId);
      if (track != null) {
        SnackbarService.showMessage("Found: ${track.title}");
        return track;
      }
    }
    SnackbarService.showMessage("Could not find track");
    return null;
  }

  // --------------- Spotify ---------------

  static Stream<ImporterState> sfyPlaylistImporter(
      {required String url, String? playlistID}) async* {
    playlistID ??= extractSpotifyPlaylistId(url);
    if (playlistID != null) {
      log("Playlist ID: $playlistID", name: "Playlist Importer");
      final accessToken = await SpotifyApi().getAccessTokenCC();
      try {
        yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: false,
          message: "Getting Spotify playlist...",
        );
        final data =
            await SpotifyApi().getAllTracksOfPlaylist(accessToken, playlistID);
        String playlistTitle = data["playlistName"].toString();
        final tracks = data["tracks"] as List;
        int totalItems = tracks.length;

        if (tracks.isNotEmpty) {
          final trackDao = TrackDAO(DBProvider.db);
          final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
          final playlistId = await playlistDao.ensurePlaylist(playlistTitle);

          int imported = 0;
          for (var (e as Map) in tracks) {
            try {
              final title = (e['track']['name']).toString();
              final artists = (e['track']['artists'] as List)
                  .map((e) => e['name'])
                  .toList()
                  .join(", ");

              if (title.isNotEmpty) {
                final track =
                    await _searchTrackByMeta("$title $artists".trim());
                if (track != null) {
                  await trackDao.upsertTrack(track);
                  await playlistDao.addTrackToPlaylist(
                    playlistId,
                    track,
                  );
                  imported++;
                  yield ImporterState(
                    totalItems: totalItems,
                    importedItems: imported,
                    failedItems: 0,
                    isDone: false,
                    isFailed: false,
                    message: "Importing($imported/$totalItems): ${track.title}",
                  );
                  log("Added: ${track.title}", name: "Playlist Importer");
                }
              }
            } catch (e) {
              log(e.toString());
              continue;
            }
          }
          yield ImporterState(
            totalItems: totalItems,
            importedItems: imported,
            failedItems: 0,
            isDone: true,
            isFailed: false,
            message: "Imported Playlist: $playlistTitle",
          );
          SnackbarService.showMessage("Imported Playlist: $playlistTitle");
        } else {
          yield ImporterState(
            totalItems: 0,
            importedItems: 0,
            failedItems: 0,
            isDone: false,
            isFailed: true,
            message: "Playlist is empty!!",
          );
        }
      } catch (e) {
        yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: true,
          message: "Failed to import Playlist ${e.toString()}",
        );
        log(e.toString(), name: "Playlist Importer");
      }
    } else {
      yield ImporterState(
        totalItems: 0,
        importedItems: 0,
        failedItems: 0,
        isDone: false,
        isFailed: true,
        message: "Invalid Playlist URL",
      );
      SnackbarService.showMessage("Invalid Playlist URL");
    }
  }

  static Future<Track?> sfyMediaImporter(String url) async {
    final accessToken = await SpotifyApi().getAccessTokenCC();
    SnackbarService.showMessage("Getting Spotify track...",
        duration: const Duration(seconds: 1));
    final trackId = extractSpotifyTrackId(url);
    if (trackId != null) {
      try {
        final data = await SpotifyApi().getTrackDetails(accessToken, trackId);
        final artists =
            (data['artists'] as List).map((e) => e['name']).toList().join(", ");
        final title = "${data['name']} $artists".trim().toLowerCase();

        if (title.isNotEmpty) {
          final track = await _searchTrackByMeta(title);
          if (track != null) {
            SnackbarService.showMessage("Got: ${track.title}");
            return track;
          } else {
            SnackbarService.showMessage("Not found or failed to import.");
          }
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      SnackbarService.showMessage("Invalid Spotify URL");
    }
    return null;
  }

  static Stream<ImporterState> sfyAlbumImporter(
      {required String url, String? albumID}) async* {
    albumID ??= extractSpotifyAlbumId(url);
    if (albumID != null) {
      log("Album ID: $albumID", name: "Album Importer");
      final accessToken = await SpotifyApi().getAccessTokenCC();
      try {
        yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: false,
          message: "Getting Spotify album...",
        );
        final data = await SpotifyApi().getAllAlbumTracks(accessToken, albumID);
        String albumTitle = data["albumName"].toString();

        final trackDao = TrackDAO(DBProvider.db);
        final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
        final albumPlaylistId = await playlistDao.ensurePlaylist(albumTitle);

        final tracks = data["tracks"] as List;
        int totalItems = tracks.length;
        int imported = 0;

        if (tracks.isNotEmpty && albumTitle.isNotEmpty) {
          for (var (e as Map) in tracks) {
            final title = (e['name']).toString();
            final artists = (e['artists'] as List)
                .map((e) => e['name'])
                .toList()
                .join(", ");

            if (title.isNotEmpty) {
              final track = await _searchTrackByMeta("$title $artists".trim());
              if (track != null) {
                await trackDao.upsertTrack(track);
                await playlistDao.addTrackToPlaylist(
                  albumPlaylistId,
                  track,
                );
                imported++;
                yield ImporterState(
                  totalItems: totalItems,
                  importedItems: imported,
                  failedItems: 0,
                  isDone: false,
                  isFailed: false,
                  message: "Importing($imported/$totalItems): ${track.title}",
                );
              }
            }
          }
          yield ImporterState(
            totalItems: totalItems,
            importedItems: imported,
            failedItems: 0,
            isDone: true,
            isFailed: false,
            message: "Imported Album: $albumTitle",
          );
          SnackbarService.showMessage("Imported Album: $albumTitle");
        } else {
          yield ImporterState(
            totalItems: 0,
            importedItems: 0,
            failedItems: 0,
            isDone: false,
            isFailed: true,
            message: "Album is empty!!",
          );
        }
      } catch (e) {
        yield ImporterState(
          totalItems: 0,
          importedItems: 0,
          failedItems: 0,
          isDone: false,
          isFailed: true,
          message: "Failed to import Album",
        );
        log(e.toString(), name: "Album Importer");
      }
    } else {
      yield ImporterState(
        totalItems: 0,
        importedItems: 0,
        failedItems: 0,
        isDone: false,
        isFailed: true,
        message: "Invalid Album URL",
      );
      SnackbarService.showMessage("Invalid Album URL");
    }
  }
}
