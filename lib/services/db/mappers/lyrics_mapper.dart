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
    provider: lyricsDB.source == 'lrcnet' || lyricsDB.source == 'plugin'
        ? LyricsProvider.plugin
        : LyricsProvider.none,
    url: lyricsDB.url,
    mediaID: lyricsDB.mediaID,
    offset: lyricsDB.offset,
  );
}

LyricsDB lyricsToLyricsDB(Lyrics lyrics, {int? offset}) {
  return LyricsDB(
    mediaID: lyrics.mediaID!,
    sourceId: lyrics.id,
    plainLyrics: lyrics.lyricsPlain,
    syncedLyrics: lyrics.lyricsSynced,
    title: lyrics.title,
    source: lyrics.provider == LyricsProvider.plugin ? 'plugin' : 'none',
    artist: lyrics.artist,
    album: lyrics.album,
    duration: double.parse(lyrics.duration ?? "0").toInt(),
    offset: offset ?? lyrics.offset,
    url: lyrics.url,
  );
}
