import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

/// DAO for tracking downloaded media files — accepts domain [Track] models.
///
/// Each download record links a [DownloadDB] row (file path, time) to a
/// [TrackDB] entry and the "_DOWNLOADS" system playlist.
class DownloadDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;
  final PlaylistDAO _playlistDAO;

  static const downloadsPlaylistName = '_DOWNLOADS';

  const DownloadDAO(this._db, this._trackDAO, this._playlistDAO);

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
    lastDownloaded ??= DateTime.now();

    // Upsert track and ensure the downloads playlist exists.
    await _trackDAO.upsertTrack(track);
    final downloadsId =
        await _playlistDAO.ensurePlaylist(downloadsPlaylistName);
    await _playlistDAO.addTrackToPlaylist(downloadsId, track);

    // Upsert the DownloadDB row.
    final existing =
        await isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirst();

    await isar.writeTxn(() async {
      if (existing != null) {
        existing
          ..fileName = fileName
          ..filePath = filePath
          ..lastDownloaded = lastDownloaded;
        await isar.downloadDBs.put(existing);
        log('Updated download record for ${track.id}', name: 'DownloadDAO');
      } else {
        final record = DownloadDB(
          fileName: fileName,
          filePath: filePath,
          lastDownloaded: lastDownloaded,
          mediaId: track.id,
        );
        await isar.downloadDBs.put(record);
        log('Created download record for ${track.id}', name: 'DownloadDAO');
      }
    });
  }

  /// Remove the download record for [mediaId] and optionally delete the file.
  Future<void> removeDownload(String mediaId, {bool deleteFile = true}) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();

    if (record == null) return;

    // Delete the DownloadDB row.
    await isar.writeTxn(() => isar.downloadDBs.delete(record.id));

    // Remove from _DOWNLOADS playlist.
    final downloadsPlaylist =
        await _playlistDAO.getPlaylistByName(downloadsPlaylistName);
    if (downloadsPlaylist != null) {
      await _playlistDAO.removeTrackFromPlaylist(downloadsPlaylist.id, mediaId);
    }

    // Delete the file from disk if it exists.
    if (deleteFile) {
      try {
        final file = File('${record.filePath}/${record.fileName}');
        if (file.existsSync()) {
          file.deleteSync();
          log('Deleted file: ${record.fileName}', name: 'DownloadDAO');
        }
      } catch (e) {
        log('Failed to delete file: ${record.fileName}',
            error: e, name: 'DownloadDAO');
      }
    }
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Return the [DownloadDB] record for [mediaId], or null if not found or the
  /// file no longer exists on disk.
  Future<DownloadDB?> getDownloadRecord(String mediaId) async {
    final isar = await _db;
    final record =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (record == null) return null;
    final file = File('${record.filePath}/${record.fileName}');
    if (!file.existsSync()) return null;
    return record;
  }

  /// Return all [DownloadDB] records whose files still exist on disk.
  ///
  /// Stale records (missing files) are cleaned up asynchronously.
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
    final stale = <DownloadDB>[];

    for (final record in all) {
      if (File('${record.filePath}/${record.fileName}').existsSync()) {
        valid.add(record);
      } else {
        stale.add(record);
      }
    }

    // Clean up stale records in the background.
    if (stale.isNotEmpty) {
      for (final s in stale) {
        removeDownload(s.mediaId, deleteFile: false);
      }
    }

    return valid;
  }

  /// Return downloaded [Track]s using persisted track metadata.
  ///
  /// The order matches [getValidDownloads] (most recent first).
  /// Falls back to a lightweight track if track metadata is missing.
  Future<List<Track>> getValidDownloadedTracks() async {
    final downloads = await getValidDownloads();
    final result = <Track>[];

    for (final record in downloads) {
      final track = await _trackDAO.getTrackByMediaId(record.mediaId);
      if (track != null) {
        result.add(track);
        continue;
      }

      // Fallback for legacy/missing rows; keep app stable.
      result.add(
        Track(
          id: record.mediaId,
          title: record.fileName,
          artists: const [],
          thumbnail: const Artwork(url: '', layout: ImageLayout.square),
          isExplicit: false,
        ),
      );
    }

    return result;
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
