import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/db/global_db.dart';

/// Maps between [LyricsDB] (Isar entity) and [Lyrics] (domain).

Lyrics? lyricsDBToLyrics(LyricsDB? lyricsDB) {
  if (lyricsDB == null) return null;
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

LyricsDB lyricsToLyricsDB(Lyrics lyrics, {int? offset}) {
  return LyricsDB(
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
  );
}
