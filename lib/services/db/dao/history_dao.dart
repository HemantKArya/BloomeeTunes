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
    final trackId = await _trackDAO.upsertTrack(track);
    final trackObj = await isar.trackDBs.get(trackId);
    if (trackObj == null) {
      log('recordPlay: track ${track.id} not found after upsert',
          name: 'HistoryDAO');
      return;
    }

    final entry = PlaybackHistoryDB(playedAt: DateTime.now())
      ..track.value = trackObj;

    await isar.writeTxn(() async {
      await isar.playbackHistoryDBs.put(entry);
      await entry.track.save();
    });
    log('Recorded play for ${track.id}', name: 'HistoryDAO');
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Return the most recent [limit] history entries as domain [Track] objects.
  ///
  /// If [limit] is 0 all entries are returned (use with care).
  /// Sorted newest-first.
  Future<List<Track>> getHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();

    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();

    await Future.wait(entries.map((e) => e.track.load()));
    await _cleanupBrokenEntries(entries);

    return entries
        .map((e) => e.track.value)
        .whereType<TrackDB>()
        .map(trackDBToTrack)
        .toList();
  }

  /// Return raw [PlaybackHistoryDB] rows sorted newest-first.
  Future<List<PlaybackHistoryDB>> getRawHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();
    final entries =
        limit > 0 ? await query.limit(limit).findAll() : await query.findAll();
    await Future.wait(entries.map((e) => e.track.load()));
    await _cleanupBrokenEntries(entries);
    return entries;
  }

  /// Remove broken history rows where track link is missing.
  ///
  /// Returns number of deleted rows.
  Future<int> purgeBrokenHistoryEntries() async {
    final isar = await _db;
    final entries = await isar.playbackHistoryDBs.where().findAll();
    await Future.wait(entries.map((e) => e.track.load()));

    final brokenIds = entries
        .where((e) => e.track.value == null)
        .map((e) => e.id)
        .toList(growable: false);

    if (brokenIds.isEmpty) return 0;

    final deleted = await isar.writeTxn(() async {
      return isar.playbackHistoryDBs.deleteAll(brokenIds);
    });

    log('Purged $deleted broken history entries', name: 'HistoryDAO');
    return deleted;
  }

  Future<void> _cleanupBrokenEntries(List<PlaybackHistoryDB> entries) async {
    final brokenIds = entries
        .where((e) => e.track.value == null)
        .map((e) => e.id)
        .toList(growable: false);

    if (brokenIds.isEmpty) return;

    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.playbackHistoryDBs.deleteAll(brokenIds);
    });
    log('Removed ${brokenIds.length} broken history entries',
        name: 'HistoryDAO');
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
