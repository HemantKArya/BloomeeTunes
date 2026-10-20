import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/src/rust/api/local_music.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// DAO for tracking downloaded media files — accepts domain [Track] models.
///
/// Each download record links a [DownloadDB] row (file path, time) to a
/// [TrackDB] entry and the "_DOWNLOADS" system playlist.
class DownloadDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;
  final PlaylistDAO _playlistDAO;

  static const downloadsPlaylistName = '_DOWNLOADS';

  final DownloadFileResolver _files;
  DownloadDAO(this._db, this._trackDAO, this._playlistDAO,
      {DownloadFileResolver? fileResolver})
      : _files = fileResolver ?? DownloadFileResolver();

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Record a new download (or update an existing one for the same [mediaId]).
  ///
  /// Accepts a domain [Track] model. Upserts it into [TrackDB] and ensures
  /// it is added to the "_DOWNLOADS" system playlist. If a record with the
  /// same [mediaId] already exists its file path and timestamp are updated.
  Future<void> putDownload({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      final playlistId =
          _playlistDAO.ensurePlaylistInTransaction(isar, downloadsPlaylistName);
      _playlistDAO.addTrackInTransaction(isar, playlistId, track);
      final existing =
          isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirstSync();
      final row = DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded ?? DateTime.now(),
          mediaId: track.id);
      if (existing != null) row.id = existing.id;
      isar.downloadDBs.putSync(row);
    });
  }

  /// Remove the download record for [mediaId] and optionally delete the file.
  Future<void> removeDownload(String mediaId, {bool deleteFile = true}) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();

    if (record == null) return;

    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));

    final downloadsPlaylist =
        await _playlistDAO.getPlaylistByName(downloadsPlaylistName);
    if (downloadsPlaylist != null) {
      await _playlistDAO.removeTrackFromPlaylist(downloadsPlaylist.id, mediaId);
    }

    if (deleteFile) {
      try {
        final file = File('${record.filePath}/${record.fileName}');
        if (await file.exists()) {
          await file.delete();
          log('Deleted file: ${record.fileName}', name: 'DownloadDAO');
        }
      } catch (e) {
        log('Failed to delete file: ${record.fileName}',
            error: e, name: 'DownloadDAO');
      }
    }
  }

  /// Record a file mapping without touching any playlist (for local music).
  ///
  /// Unlike [putDownload], this only upserts [TrackDB] + [DownloadDB] rows.
  Future<void> putDownloadRecord({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      _trackDAO.upsertTrackInTransaction(isar, track);
      final existing =
          isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirstSync();
      final row = DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded ?? DateTime.now(),
          mediaId: track.id);
      if (existing != null) row.id = existing.id;
      isar.downloadDBs.putSync(row);
    });
  }

  /// Remove a [DownloadDB] record without deleting the underlying file.
  Future<void> removeDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return;
    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Return the [DownloadDB] record for [mediaId], or null if not found or the
  /// file no longer exists on disk.
  Future<DownloadDB?> getDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return null;
    return _resolveRecord(isar, record);
  }

  Future<DownloadDB?> _resolveRecord(Isar isar, DownloadDB record) async {
    final resolved = await _files.resolve(record.filePath, record.fileName);
    if (resolved == null) return null;
    final directory = p.dirname(resolved);
    if (directory == record.filePath) return record;
    // File checks yield. Do not resurrect a deleted row or overwrite a newer
    // download that finished while we were checking the old path.
    return isar.writeTxnSync(() {
      final current = isar.downloadDBs.getSync(record.id);
      if (current == null) return null;
      if (current.filePath != record.filePath ||
          current.fileName != record.fileName ||
          current.mediaId != record.mediaId ||
          current.lastDownloaded != record.lastDownloaded) {
        return null;
      }
      current.filePath = directory;
      isar.downloadDBs.putSync(current);
      return current;
    });
  }

  /// Return all [DownloadDB] records whose files still exist on disk.
  ///
  /// Missing/inaccessible files never cause record or playlist deletion.
  Future<List<DownloadDB>> getValidDownloads() async {
    final isar = await _db;
    final all = await isar.downloadDBs.where().findAll();
    all.sort((a, b) {
      final aDate = a.lastDownloaded;
      final bDate = b.lastDownloaded;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    final valid = <DownloadDB>[];
    // Bound I/O fan-out for large offline libraries.
    for (var offset = 0; offset < all.length; offset += 32) {
      final resolved = await Future.wait(all
          .skip(offset)
          .take(32)
          .map((record) => _resolveRecord(isar, record)));
      valid.addAll(resolved.whereType<DownloadDB>());
    }

    return valid;
  }

  /// Return downloaded [Track]s using persisted track metadata.
  ///
  /// The order matches [getValidDownloads] (most recent first).
  /// Excludes locally scanned tracks (they have their own playlist).
  /// Falls back to a lightweight track if track metadata is missing.
  Future<List<Track>> getValidDownloadedTracks() async {
    final downloads = (await getValidDownloads())
        .where((record) => !isLocalMediaId(record.mediaId))
        .toList();
    if (downloads.isEmpty) return [];
    final result = <Track>[];
    final tracks =
        await _trackDAO.getTracksByMediaIds(downloads.map((d) => d.mediaId));
    final runtimeArtworkCacheDir = await _runtimeArtworkCacheDir();
    for (var offset = 0; offset < downloads.length; offset += 8) {
      result.addAll(
          await Future.wait(downloads.skip(offset).take(8).map((record) async {
        final track = tracks[record.mediaId];
        if (track != null && runtimeArtworkCacheDir != null) {
          return _resolveEmbeddedArtworkAtRuntime(record, track,
              runtimeArtworkCacheDir: runtimeArtworkCacheDir);
        }
        if (track != null) return track;
        return Track(
          id: record.mediaId,
          title: record.fileName,
          artists: const [],
          thumbnail: const Artwork(url: '', layout: ImageLayout.square),
          isExplicit: false,
        );
      })));
    }

    return result;
  }

  Future<String?> _runtimeArtworkCacheDir() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return p.join(tempDir.path, 'bloomee_runtime_embedded_art');
    } catch (error) {
      log('Artwork cache unavailable; using persisted artwork',
          error: error, name: 'DownloadDAO');
      return null;
    }
  }

  Future<Track> _resolveEmbeddedArtworkAtRuntime(
    DownloadDB record,
    Track track, {
    required String runtimeArtworkCacheDir,
  }) async {
    final currentArtworkUrl = track.thumbnail.url;
    if (await _isExistingLocalImagePath(currentArtworkUrl)) {
      return track;
    }

    try {
      final filePath = p.join(record.filePath, record.fileName);
      final metadata = await readAudioMetadata(
        filePath: filePath,
        coverCacheDir: runtimeArtworkCacheDir,
      );

      final embeddedArtworkPath = metadata.coverArtPath;
      if (embeddedArtworkPath == null || embeddedArtworkPath.isEmpty) {
        return track;
      }

      final artworkFile = File(embeddedArtworkPath);
      if (!(await artworkFile.exists())) {
        return track;
      }

      return Track(
        id: track.id,
        title: track.title,
        artists: track.artists,
        album: track.album,
        durationMs: track.durationMs,
        thumbnail: Artwork(
          url: embeddedArtworkPath,
          urlLow: track.thumbnail.urlLow,
          urlHigh: track.thumbnail.urlHigh,
          layout: track.thumbnail.layout,
        ),
        url: track.url,
        isExplicit: track.isExplicit,
        lyrics: track.lyrics,
      );
    } catch (error) {
      log(
        'Runtime embedded artwork lookup failed for ${track.id}',
        name: 'DownloadDAO',
        error: error,
      );
      return track;
    }
  }

  Future<bool> _isExistingLocalImagePath(String? value) async {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.scheme == 'file') {
        final file = File(uri.toFilePath(windows: Platform.isWindows));
        return await file.exists();
      }
    } catch (_) {}

    return await File(trimmed).exists();
  }

  /// Returns true if [mediaId] has a valid download record and the file exists.
  Future<bool> isDownloaded(String mediaId) async {
    final record = await getDownloadRecord(mediaId);
    return record != null;
  }

  /// Update an existing [DownloadDB] record in-place.
  Future<void> updateDownloadRecord(DownloadDB record) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.downloadDBs.put(record));
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  Future<Stream<void>> watchDownloads() async {
    final isar = await _db;
    return isar.downloadDBs.watchLazy(fireImmediately: true);
  }
}

/// Resolves exact paths and known app-container relocations. Never searches by
/// basename: different songs can have the same filename.
class DownloadFileResolver {
  final String? supportPath;
  final String? documentsPath;
  Future<List<String?>>? _roots;
  DownloadFileResolver({this.supportPath, this.documentsPath});

  Future<List<String?>> _loadRoots() async {
    try {
      return [
        supportPath ?? (await getApplicationSupportDirectory()).path,
        documentsPath ?? (await getApplicationDocumentsDirectory()).path
      ];
    } catch (_) {
      return [supportPath, documentsPath];
    }
  }

  Future<String?> resolve(String directory, String name) async {
    if (name.isEmpty || p.basename(name) != name) return null;
    if (directory.startsWith('file:')) {
      try {
        directory = Uri.parse(directory).toFilePath();
      } catch (_) {
        return null;
      }
    }
    final candidates = <String>{
      p.join(directory, name),
      if (p.basename(directory) == name) directory
    };
    for (final path in candidates) {
      if (await _exists(path)) return path;
    }
    final roots = await (_roots ??= _loadRoots());
    final normalized =
        (p.basename(directory) == name ? p.dirname(directory) : directory)
            .replaceAll('\\', '/');
    // Restrict rebasing to known private app containers, including files saved
    // directly at the container root. Shared/external folders never rebase to
    // internal storage merely because they contain a folder called "files".
    final android = RegExp(
            r'^/data/(?:data|user(?:_de)?/\d+)/[^/]+/(files|app_flutter)(?:/|$)')
        .firstMatch(normalized);
    final apple = RegExp(
            r'/Containers/Data/Application/[^/]+/(Documents|Library/Application Support)(?:/|$)')
        .firstMatch(normalized);
    final relocations = <(String, String?)>[
      if (android != null)
        (
          normalized.substring(android.end),
          android.group(1) == 'files' ? roots[0] : roots[1]
        ),
      if (apple != null)
        (
          normalized.substring(apple.end),
          apple.group(1) == 'Documents' ? roots[1] : roots[0]
        ),
    ];
    for (final (suffix, root) in relocations) {
      if (root == null) continue;
      final moved = p.normalize(p.join(root, suffix, name));
      if (!p.isWithin(root, moved)) continue;
      if (await _exists(moved)) return moved;
    }
    return null;
  }

  Future<bool> _exists(String path) async {
    try {
      return await File(path).exists();
    } on FileSystemException {
      return false;
    }
  }
}
