import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/lyrics_mapper.dart';
import 'package:isar_community/isar.dart';

/// DAO for cached lyrics. Uses [lyricsToLyricsDB] and [lyricsDBToLyrics]
/// from [lyrics_mapper.dart] — no inline mapping.
class LyricsDAO {
  final Future<Isar> _db;

  const LyricsDAO(this._db);

  /// Store or replace lyrics for [lyrics.mediaID].
  Future<void> putLyrics(Lyrics lyrics, {int? offset}) async {
    if (lyrics.mediaID == null || lyrics.mediaID!.isEmpty) return;
    final isar = await _db;
    await isar.writeTxn(
        () => isar.lyricsDBs.put(lyricsToLyricsDB(lyrics, offset: offset)));
  }

  /// Retrieve cached lyrics for [mediaID], or null if not cached.
  Future<Lyrics?> getLyrics(String mediaID) async {
    final isar = await _db;
    final row =
        await isar.lyricsDBs.filter().mediaIDEqualTo(mediaID).findFirst();
    return lyricsDBToLyrics(row);
  }

  /// Delete the cached lyrics entry for [mediaID].
  Future<void> removeLyricsById(String mediaID) async {
    final isar = await _db;
    await isar.writeTxn(
        () => isar.lyricsDBs.filter().mediaIDEqualTo(mediaID).deleteAll());
  }

  /// Delete ALL cached lyrics.
  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.lyricsDBs.clear());
  }

  /// Update the mediaID for an existing lyrics entry.
  Future<void> updateMediaId(String oldMediaId, String newMediaId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final existing =
          await isar.lyricsDBs.filter().mediaIDEqualTo(oldMediaId).findFirst();
      if (existing != null) {
        existing.mediaID = newMediaId;
        await isar.lyricsDBs.put(existing);
      }
    });
  }
}
