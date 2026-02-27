import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';

/// Repository for import/export operations — orchestrates playlist
/// serialization and file I/O.
///
/// Wraps [PlaylistDAO] for data access and provides JSON/M3U
/// import-export capabilities. UI-level file picking and snackbar
/// feedback should remain in the presentation layer.
class ImportExportRepository {
  final PlaylistDAO _playlistDao;

  const ImportExportRepository(this._playlistDao);

  // --------------- Export ---------------

  /// Exports a playlist to a JSON map.  Returns `null` if not found.
  Future<Map<String, dynamic>?> exportPlaylistAsMap(
      String playlistName) async {
    final playlist = await _playlistDao.getPlaylist(playlistName);
    if (playlist == null) return null;

    final items = await _playlistDao.getPlaylistItems(playlist);
    if (items == null) return null;

    final info = await _playlistDao.getPlaylistInfo(playlistName);

    return {
      'playlistName': playlistName,
      'artURL': info?.artURL ?? '',
      'description': info?.description ?? '',
      'permaURL': info?.permaURL ?? '',
      'source': info?.source ?? '',
      'artists': info?.artists ?? '',
      'isAlbum': info?.isAlbum ?? false,
      'items': items.map((e) => _mediaItemDBToMap(e)).toList(),
    };
  }

  /// Exports a single media item to a JSON map.
  Map<String, dynamic> exportMediaItemAsMap(MediaItemDB mediaItemDB) =>
      _mediaItemDBToMap(mediaItemDB);

  /// Writes a map to a JSON file and returns the path.
  Future<String?> writeJsonFile(
    String fileName,
    Map<String, dynamic> data, {
    String? directoryPath,
  }) async {
    try {
      final dir = directoryPath ?? Directory.systemTemp.path;
      final file = File('$dir/$fileName.json');
      await file.writeAsString(jsonEncode(data));
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // --------------- Import ---------------

  /// Reads a JSON file and returns its content.
  Future<Map<String, dynamic>?> readJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Imports a playlist from JSON data into the database.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> importPlaylistFromMap(Map<String, dynamic> data) async {
    try {
      final playlistName = data['playlistName'] as String;
      final items = (data['items'] as List)
          .map((e) => _mapToMediaItemDB(e as Map<String, dynamic>))
          .toList();

      await _playlistDao.createPlaylist(
        playlistName,
        artURL: data['artURL'] as String?,
        description: data['description'] as String?,
        permaURL: data['permaURL'] as String?,
        source: data['source'] as String?,
        artists: data['artists'] as String?,
        isAlbum: data['isAlbum'] as bool? ?? false,
        mediaItems: items,
      );

      // Add items one by one (preserving order)
      for (final item in items) {
        await _playlistDao.addMediaItem(item, playlistName);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether a playlist already exists in the library.
  Future<bool> isPlaylistExists(String playlistName) async {
    final playlist = await _playlistDao.getPlaylist(playlistName);
    return playlist != null;
  }

  // --------------- Private helpers ---------------

  Map<String, dynamic> _mediaItemDBToMap(MediaItemDB item) => {
        'title': item.title,
        'artist': item.artist,
        'album': item.album,
        'artURL': item.artURL,
        'genre': item.genre,
        'mediaID': item.mediaID,
        'duration': item.duration,
        'permaURL': item.permaURL,
        'source': item.source,
        'language': item.language,
        'isLiked': item.isLiked,
      };

  MediaItemDB _mapToMediaItemDB(Map<String, dynamic> map) => MediaItemDB(
    title: map['title'] as String? ?? '',
    artist: map['artist'] as String? ?? '',
    album: map['album'] as String? ?? '',
    artURL: map['artURL'] as String? ?? '',
    genre: map['genre'] as String? ?? '',
    mediaID: map['mediaID'] as String? ?? '',
    streamingURL: map['streamingURL'] as String? ?? '',
    duration: map['duration'] as int?,
    permaURL: map['permaURL'] as String? ?? '',
    source: map['source'] as String?,
    language: map['language'] as String? ?? '',
    isLiked: map['isLiked'] as bool? ?? false,
  );
}
