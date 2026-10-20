import 'dart:developer';

import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

/// DAO for recording and querying playback history.
///
/// Each play creates a [PlaybackHistoryDB] row linked to a [TrackDB].
/// History entries are indexed by [playedAt] for efficient date-range queries.
class HistoryDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;

  const HistoryDAO(this._db, this._trackDAO);

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Record that [track] was played now.
  ///
  /// Accepts a domain [Track] model. Upserts it into [TrackDB] first,
  /// then writes a new [PlaybackHistoryDB] row. Multiple plays of the
  /// same track each get their own history row (non-deduplicating log).
  Future<void> recordPlay(Track track) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      final id = _trackDAO.upsertTrackInTransaction(isar, track);
      final entry = PlaybackHistoryDB(playedAt: DateTime.now())
        ..track.value = isar.trackDBs.getSync(id);
      isar.playbackHistoryDBs.putSync(entry);
      entry.track.saveSync();
    });
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Return the most recent [limit] history entries as domain [Track] objects.
  ///
  /// If [limit] is 0 all entries are returned (use with care).
  /// Sorted newest-first. Entries with missing track links are skipped
  /// but NOT deleted — broken entry cleanup is a separate maintenance task.
  Future<List<Track>> getHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();

    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();

    await Future.wait(entries.map((e) => e.track.load()));

    final seen = <String>{};
    return entries
        .map((e) => e.track.value)
        .whereType<TrackDB>()
        .where((t) => seen.add(t.mediaId))
        .map(trackDBToTrack)
        .toList();
  }

  /// Return raw [PlaybackHistoryDB] rows sorted newest-first.
  /// Entries with missing track links are included but will have null track.
  Future<List<PlaybackHistoryDB>> getRawHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();
    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();
    await Future.wait(entries.map((e) => e.track.load()));
    return entries;
  }

  // ── Maintenance ───────────────────────────────────────────────────────────

  /// Delete history entries older than [days] days.
  ///
  /// Returns the number of rows deleted.
  Future<int> purgeOldHistory(int days) async {
    if (days <= 0) return 0;
    final isar = await _db;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final count = await isar.writeTxn(() =>
        isar.playbackHistoryDBs.filter().playedAtLessThan(cutoff).deleteAll());
    log('Purged $count history entries older than $days days',
        name: 'HistoryDAO');
    return count;
  }

  /// Delete a single history entry by its Isar [id].
  Future<void> removeHistoryEntry(int id) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playbackHistoryDBs.delete(id));
  }

  /// Delete all history entries.
  Future<void> clearHistory() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playbackHistoryDBs.clear());
    log('Cleared all history', name: 'HistoryDAO');
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  /// Stream that fires whenever the history collection changes.
  Future<Stream<void>> watchHistory() async {
    final isar = await _db;
    return isar.playbackHistoryDBs.watchLazy(fireImmediately: true);
  }
}
