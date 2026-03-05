import 'dart:developer';

import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

/// DAO for track persistence — accepts domain [Track] models.
///
/// Mappers are handled internally; callers work only with domain models.
///
/// All other DAOs that need to persist or look up a track delegate here.
/// [TrackDB] rows are shared across playlists and downloads — the same
/// track is stored once and referenced by many [PlaylistEntryDB] rows.
class TrackDAO {
  final Future<Isar> _db;

  const TrackDAO(this._db);

  // ── Upsert ────────────────────────────────────────────────────────────────

  /// Insert or replace a track (keyed on [Track.mediaId]).
  ///
  /// Accepts a domain [Track] model, maps to [TrackDB] internally.
  /// Returns the Isar internal auto-increment id.
  Future<int> upsertTrack(Track track) async {
    final trackDB = trackToTrackDB(track);
    final isar = await _db;
    return isar.writeTxn(() => isar.trackDBs.put(trackDB));
  }

  /// Insert or replace many tracks in a single transaction.
  ///
  /// More efficient than calling [upsertTrack] N times for bulk imports.
  Future<List<int>> upsertTracks(List<Track> tracks) async {
    if (tracks.isEmpty) return [];
    final trackDBs = tracks.map(trackToTrackDB).toList();
    final isar = await _db;
    return isar.writeTxn(() => isar.trackDBs.putAll(trackDBs));
  }

  /// Internal method: upsert a [TrackDB] directly (for internal DAO use).
  Future<int> upsertTrackDB(TrackDB track) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.trackDBs.put(track));
  }

  // ── Lookup ────────────────────────────────────────────────────────────────

  /// Find a track by its plugin-scoped [mediaId] (e.g. "ytmusic::dQw4…").
  ///
  /// Returns a domain [Track] model, or null if not found.
  Future<Track?> getTrackByMediaId(String mediaId) async {
    final isar = await _db;
    final trackDB =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    return trackDB != null ? trackDBToTrack(trackDB) : null;
  }

  /// Find a track by Isar internal [id].
  ///
  /// Returns a domain [Track] model, or null if not found.
  Future<Track?> getTrackById(int id) async {
    final isar = await _db;
    final trackDB = await isar.trackDBs.get(id);
    return trackDB != null ? trackDBToTrack(trackDB) : null;
  }

  /// Internal: Get TrackDB by mediaId (for internal DAO operations).
  Future<TrackDB?> getTrackDBByMediaId(String mediaId) async {
    final isar = await _db;
    return isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
  }

  /// Bulk lookup by a list of Isar internal ids (used by PlaylistDAO).
  Future<List<TrackDB>> getTracksByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final isar = await _db;
    final results = await isar.trackDBs.getAll(ids);
    return results.whereType<TrackDB>().toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Full-text search by title or artists using Isar's indexed value scan.
  ///
  /// Returns up to [limit] results (default 50). Pass 0 for unlimited.
  Future<List<TrackDB>> searchTracks(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final isar = await _db;
    final q = isar.trackDBs.filter().titleContains(query, caseSensitive: false);
    return limit == 0 ? q.findAll() : q.limit(limit).findAll();
  }

  // ── Purge ─────────────────────────────────────────────────────────────────

  /// Delete a track only when it is no longer referenced by any
  /// [PlaylistEntryDB] or [DownloadDB] row.
  ///
  /// Safe to call after removing a playlist entry.
  Future<void> purgeOrphanTrack(String mediaId) async {
    final isar = await _db;
    final track =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (track == null) return;

    final hasEntry = await isar.playlistEntryDBs
        .filter()
        .playlistIdIsNotNull()
        .and()
        .track((q) => q.mediaIdEqualTo(mediaId))
        .findFirst();
    if (hasEntry != null) return; // still in a playlist

    final hasDownload =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (hasDownload != null) return; // still downloaded

    await isar.writeTxn(() => isar.trackDBs.delete(track.id));
    log('Purged orphan track: $mediaId', name: 'TrackDAO');
  }

  /// Scan all tracks and delete those with no playlist entries and no downloads.
  ///
  /// Run as periodic maintenance (30 s after startup).
  Future<int> purgeOrphanTracks() async {
    final isar = await _db;
    final allTracks = await isar.trackDBs.where().findAll();
    int purged = 0;

    for (final track in allTracks) {
      final hasEntry = await isar.playlistEntryDBs
          .filter()
          .track((q) => q.idEqualTo(track.id))
          .findFirst();
      if (hasEntry != null) continue;

      final hasDownload = await isar.downloadDBs
          .filter()
          .mediaIdEqualTo(track.mediaId)
          .findFirst();
      if (hasDownload != null) continue;

      await isar.writeTxn(() => isar.trackDBs.delete(track.id));
      purged++;
    }

    log('Purged $purged orphan track(s)', name: 'TrackDAO');
    return purged;
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  Future<Stream<void>> watchTracks() async {
    final isar = await _db;
    return isar.trackDBs.watchLazy(fireImmediately: false);
  }
}
