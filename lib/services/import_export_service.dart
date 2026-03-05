import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/m3u_processor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Service for importing and exporting playlists and tracks.
///
/// Exports/imports use a JSON format with track data serialized from the
/// new [TrackDB] schema. Old `MediaItemDB` format files are handled via
/// a backward-compatible import path.
class ImportExportService {
  static PlaylistDAO get _playlistDao =>
      PlaylistDAO(DBProvider.db, TrackDAO(DBProvider.db));

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Checks if a playlist with the given name already exists in the library.
  static Future<bool> isPlaylistExists(String playlistName) async {
    final existing = await _playlistDao.getPlaylistByName(playlistName);
    return existing != null;
  }

  /// Serialize a [TrackDB] into a portable JSON map.
  static Map<String, dynamic> _trackDBToMap(TrackDB t) {
    return {
      'mediaId': t.mediaId,
      'title': t.title,
      'artists': t.artists
              ?.map((a) => {
                    'name': a.name,
                    'url': a.url,
                    'mediaId': a.mediaId,
                  })
              .toList() ??
          [],
      'album': t.album != null
          ? {
              'title': t.album!.name,
              'url': t.album!.url,
              'mediaId': t.album!.mediaId,
              'year': t.album!.year,
            }
          : null,
      'thumbnail': t.thumbnail != null
          ? {
              'url': t.thumbnail!.url,
              'urlLow': t.thumbnail!.urlLow,
              'urlHigh': t.thumbnail!.urlHigh,
            }
          : null,
      'durationMs': t.durationMs,
      'genre': t.genre,
      'language': t.language,
      'isExplicit': t.isExplicit,
    };
  }

  /// Deserialize a JSON map into a domain [Track].
  ///
  /// Handles both new format (artists list, thumbnail map) and legacy
  /// `MediaItemDB` format (artist string, artURL, etc.).
  static Track _trackFromMap(Map<String, dynamic> m) {
    // ── New format ───────────────────────────────────────────────────────────
    if (m.containsKey('mediaId') &&
        m.containsKey('artists') &&
        m['artists'] is List) {
      final artistsList = (m['artists'] as List)
          .map((a) => ArtistSummary(
                id: (a['mediaId'] as String?) ?? '',
                name: (a['name'] as String?) ?? '',
                url: a['url'] as String?,
              ))
          .toList();

      AlbumSummary? album;
      if (m['album'] is Map) {
        final a = m['album'] as Map;
        album = AlbumSummary(
          id: (a['mediaId'] as String?) ?? '',
          title: (a['title'] as String?) ?? '',
          artists: const [],
          url: a['url'] as String?,
        );
      }

      Artwork thumbnail = Artwork(url: '', layout: ImageLayout.square);
      if (m['thumbnail'] is Map) {
        final t = m['thumbnail'] as Map;
        thumbnail = Artwork(
          url: (t['url'] as String?) ?? '',
          urlLow: t['urlLow'] as String?,
          urlHigh: t['urlHigh'] as String?,
          layout: ImageLayout.square,
        );
      }

      return Track(
        id: m['mediaId'] as String? ?? '',
        title: m['title'] as String? ?? '',
        artists: artistsList,
        album: album,
        thumbnail: thumbnail,
        durationMs: m['durationMs'] != null
            ? BigInt.from(m['durationMs'] as int)
            : null,
        isExplicit: m['isExplicit'] as bool? ?? false,
      );
    }

    // ── Legacy MediaItemDB format ────────────────────────────────────────────
    final id = (m['permaURL'] as String?) ?? (m['id'] as String?) ?? '';
    final title = (m['title'] as String?) ?? '';
    final artist = (m['artist'] as String?) ?? '';
    final album = (m['album'] as String?) ?? '';
    final artURL = (m['artURL'] as String?) ?? '';
    final durationSec = m['duration'] as num?;

    return Track(
      id: id,
      title: title,
      artists: artist.isNotEmpty
          ? artist
              .split(', ')
              .map((n) => ArtistSummary(id: '', name: n))
              .toList()
          : [],
      album: album.isNotEmpty
          ? AlbumSummary(id: '', title: album, artists: const [])
          : null,
      thumbnail: Artwork(url: artURL, layout: ImageLayout.square),
      durationMs: durationSec != null
          ? BigInt.from((durationSec * 1000).toInt())
          : null,
      isExplicit: false,
    );
  }

  // ── Export ──────────────────────────────────────────────────────────────────

  /// Exports a playlist to a JSON file.
  static Future<String?> exportPlaylist(String playlistName,
      {String? filePath}) async {
    final playlistDB = await _playlistDao.getPlaylistByName(playlistName);
    if (playlistDB == null) {
      log("Playlist not found", name: "FileManager");
      return null;
    }

    try {
      final tracks = await _playlistDao.getPlaylistTracks(playlistDB.id);
      final packageInfo = await PackageInfo.fromPlatform();

      final Map<String, dynamic> playlistMap = {
        '_meta': {
          'generated_by': 'Bloomee - Open Source Music Streaming Application',
          'version':
              'v${packageInfo.version}+${int.parse(packageInfo.buildNumber) % 1000}',
          'exportedAt': DateTime.now().toIso8601String(),
          'format': 'v2',
          'note':
              'This file is automatically generated by Bloomee and is intended solely for importing playlists within the application.',
        },
        'playlistName': playlistDB.name,
        'tracks': tracks.map((t) => _trackDBToMap(t)).toList(),
      };

      final path = await writeToJSON(
          '${playlistDB.name}_BloomeePlaylist.json', playlistMap,
          path: filePath);
      log("Playlist exported successfully", name: "FileManager");
      return path;
    } catch (e) {
      log("Error exporting playlist: $e");
      return null;
    }
  }

  /// Exports a single track to a JSON file.
  static Future<String?> exportTrack(TrackDB trackDB) async {
    try {
      final Map<String, dynamic> trackMap = _trackDBToMap(trackDB);
      final packageInfo = await PackageInfo.fromPlatform();
      trackMap['_meta'] = {
        'generated_by': 'Bloomee - Open Source Music Streaming Application',
        'version':
            'v${packageInfo.version}+${int.parse(packageInfo.buildNumber) % 1000}',
        'exportedAt': DateTime.now().toIso8601String(),
        'format': 'v2',
      };

      final path =
          await writeToJSON('${trackDB.title}_BloomeeSong.json', trackMap);
      log("Track exported successfully", name: "FileManager");
      return path;
    } catch (e) {
      log("Error exporting track: $e", name: "FileManager");
      return null;
    }
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  /// Imports a playlist from a JSON file.
  static Future<bool> importPlaylist(String filePath) async {
    try {
      final playlistMap = await readFromJSON(filePath);
      if (playlistMap == null || playlistMap.isEmpty) return false;

      // Determine format
      final isV2 = playlistMap.containsKey('tracks');
      final isV1 = playlistMap.containsKey('mediaItems');
      if (!isV2 && !isV1) {
        throw const FormatException("Missing 'tracks' or 'mediaItems' key.");
      }

      final String baseName = playlistMap['playlistName'] ?? 'Imported';

      // Deduplicate playlist name.
      String playlistName = baseName;
      int i = 1;
      while (await isPlaylistExists(playlistName)) {
        playlistName = '${baseName}_$i';
        i++;
      }

      final playlistId = await _playlistDao.ensurePlaylist(playlistName);
      final items = (playlistMap[isV2 ? 'tracks' : 'mediaItems'] as List);

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final track = _trackFromMap(item);
          await _playlistDao.addTrackToPlaylist(playlistId, track);
          log("Track imported: ${track.title}", name: "FileManager");
        }
      }

      log("Playlist imported successfully");
      return true;
    } catch (e) {
      log("Invalid file format: $e");
      SnackbarService.showMessage(
          "Invalid file format. Please check the file and try again.");
      return false;
    }
  }

  /// Imports a single track from a JSON file.
  static Future<bool> importMediaItem(String filePath) async {
    try {
      final trackMap = await readFromJSON(filePath);
      if (trackMap == null || trackMap.isEmpty) return false;

      final track = _trackFromMap(trackMap);
      final playlistId = await _playlistDao.ensurePlaylist("Imported");
      await _playlistDao.addTrackToPlaylist(playlistId, track);
      log("Track imported successfully");
      return true;
    } catch (e) {
      log("Invalid file format");
      return false;
    }
  }

  /// Automatically determines the type of JSON file and imports it.
  static Future<bool> importJSON(String filePath) async {
    try {
      final data = await readFromJSON(filePath);
      if (data == null || data.isEmpty) {
        throw const FormatException("Invalid or empty JSON file.");
      }

      if (data.containsKey('playlistName') &&
          (data.containsKey('tracks') || data.containsKey('mediaItems'))) {
        return await importPlaylist(filePath);
      } else if (data.containsKey('title') &&
          (data.containsKey('mediaId') || data.containsKey('duration'))) {
        return await importMediaItem(filePath);
      } else {
        throw const FormatException("Unrecognized JSON structure.");
      }
    } catch (e) {
      log("Error importing JSON file: $e", name: "FileManager");
      SnackbarService.showMessage(
          "Failed to import file. Please check the file and try again.");
      return false;
    }
  }

  // ── M3U Export ─────────────────────────────────────────────────────────────

  /// Export playlist as M3U/M3U8.
  static Future<String?> exportM3UPlaylist(String playlistName) async {
    final playlistDB = await _playlistDao.getPlaylistByName(playlistName);
    if (playlistDB == null) {
      log("Playlist not found", name: "FileManager");
      return null;
    }

    try {
      final tracks = await _playlistDao.getPlaylistTracks(playlistDB.id);
      final packageInfo = await PackageInfo.fromPlatform();

      // Build a legacy-shaped JSON map for the M3U converter.
      final Map<String, dynamic> playlistMap = {
        '_meta': {
          'generated_by': 'Bloomee - Open Source Music Streaming Application',
          'version':
              'v${packageInfo.version}+${int.parse(packageInfo.buildNumber) % 1000}',
          'exportedAt': DateTime.now().toIso8601String(),
        },
        'playlistName': playlistDB.name,
        'mediaItems': tracks.map((t) {
          final artistStr =
              t.artists?.map((a) => a.name ?? '').join(', ') ?? '';
          return {
            'title': t.title,
            'artist': artistStr,
            'album': t.album?.name ?? '',
            'genre': t.genre ?? '',
            'artURL': t.thumbnail?.url ?? '',
            'duration': (t.durationMs ?? 0) ~/ 1000,
            'streamingURL': '',
            'permaURL': t.mediaId,
          };
        }).toList(),
      };

      final String m3uData = convertJsonToM3U(playlistMap);
      final path = await writeToM3U('${playlistDB.name}.m3u', m3uData);
      log("Playlist exported as M3U successfully", name: "FileManager");
      return path;
    } catch (e) {
      log("Error exporting playlist as M3U: $e");
      return null;
    }
  }

  // ── File I/O ───────────────────────────────────────────────────────────────
  static Future<String?> writeToJSON(String fileName, Map<String, dynamic> data,
      {String? path}) async {
    try {
      final filePath = path ?? (await getApplicationCacheDirectory()).path;
      final file = File('$filePath/$fileName');
      await file.writeAsString(jsonEncode(data));
      log("Data written to file: $filePath/$fileName", name: "FileManager");
      return '$filePath/$fileName';
    } catch (e) {
      log("Error writing file:", error: e, name: "FileManager");
      return null;
    }
  }

  /// Reads data from a JSON file and returns it as a map.
  ///
  /// [filePath] - The path of the file to read.
  /// Returns the data as a map, or `null` if an error occurs.
  static Future<Map<String, dynamic>?> readFromJSON(String filePath) async {
    try {
      final file = File(filePath);
      final data = await file.readAsString();
      log("Data read from file: $filePath", name: "FileManager");
      return jsonDecode(data);
    } catch (e) {
      log("Error reading file:", error: e);
      return null;
    }
  }

  /// Validates the structure of a playlist JSON file (supports both v1 and v2).
  static void validatePlaylistJson(Map<String, dynamic> playlistMap) {
    if (!playlistMap.containsKey('playlistName') ||
        playlistMap['playlistName'] == null) {
      throw const FormatException("Invalid JSON: Missing 'playlistName'.");
    }

    final hasV2 = playlistMap.containsKey('tracks');
    final hasV1 = playlistMap.containsKey('mediaItems');
    if (!hasV2 && !hasV1) {
      throw const FormatException(
          "Invalid JSON: Missing 'tracks' or 'mediaItems'.");
    }

    final items = playlistMap[hasV2 ? 'tracks' : 'mediaItems'];
    if (items is! List) {
      throw const FormatException("Invalid JSON: items must be a list.");
    }

    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException("Invalid JSON: Each item must be a map.");
      }
      if (!item.containsKey('title') && !item.containsKey('mediaId')) {
        throw const FormatException(
            "Invalid JSON: item missing 'title' or 'mediaId'.");
      }
    }
  }

  static Future<String?> writeToM3U(String fileName, String data) async {
    try {
      final filePath = (await getApplicationCacheDirectory()).path;
      final file = File('$filePath/$fileName');
      await file.writeAsString(data);
      log("Data written to file: $filePath/$fileName", name: "FileManager");
      return '$filePath/$fileName';
    } catch (e) {
      log("Error writing file:", error: e, name: "FileManager");
      return null;
    }
  }
}
