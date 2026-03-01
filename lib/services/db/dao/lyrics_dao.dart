import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for lyrics cache.
class LyricsDAO {
  final Future<Isar> _db;

  const LyricsDAO(this._db);

  Future<void> putLyrics(Lyrics lyrics, {int? offset}) async {
    if (lyrics.mediaID != null) {
      Isar isarDB = await _db;
      isarDB.writeTxnSync(() => isarDB.lyricsDBs.putSync(LyricsDB(
            mediaID: lyrics.mediaID!,
            sourceId: lyrics.id,
            plainLyrics: lyrics.lyricsPlain,
            syncedLyrics: lyrics.lyricsSynced,
            title: lyrics.title,
            source: "lrcnet",
            artist: lyrics.artist,
            album: lyrics.album,
            duration: double.parse(lyrics.duration ?? "0").toInt(),
            offset: offset,
            url: lyrics.url,
          )));
    }
  }

  Future<Lyrics?> getLyrics(String mediaID) async {
    Isar isarDB = await _db;
    LyricsDB? lyricsDB =
        isarDB.lyricsDBs.filter().mediaIDEqualTo(mediaID).findFirstSync();
    if (lyricsDB != null) {
      return Lyrics(
        id: lyricsDB.sourceId,
        title: lyricsDB.title,
        artist: lyricsDB.artist,
        album: lyricsDB.album,
        duration: lyricsDB.duration.toString(),
        lyricsPlain: lyricsDB.plainLyrics,
        lyricsSynced: lyricsDB.syncedLyrics,
        provider: LyricsProvider.lrcnet,
        url: lyricsDB.url,
        mediaID: lyricsDB.mediaID,
      );
    }
    return null;
  }

  Future<void> removeLyricsById(String mediaID) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() =>
        isarDB.lyricsDBs.filter().mediaIDEqualTo(mediaID).deleteAllSync());
  }
}
