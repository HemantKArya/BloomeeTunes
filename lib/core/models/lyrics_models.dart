// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

enum LyricsProvider {
  lrcnet,
  none,
}

class Lyrics {
  final String id;
  final String artist;
  final String title;
  final String lyricsPlain;
  final LyricsProvider provider;
  final String? album;
  final String? lyricsSynced;
  ParsedLyrics? parsedLyrics;
  final String? url;
  final String? img;
  final String? duration;
  final String? mediaID;

  Lyrics({
    required this.artist,
    required this.title,
    required this.lyricsPlain,
    required this.id,
    required this.provider,
    this.url,
    this.img,
    this.lyricsSynced,
    this.album,
    this.duration,
    this.parsedLyrics,
    this.mediaID,
  }) {
    if (lyricsSynced != null) {
      parsedLyrics = ParsedLyrics(
        syncedLyrics: lyricsSynced ?? '',
        duration: duration ?? '',
      );
    }
  }

  @override
  String toString() {
    return 'Lyrics{artist: $artist, title: $title, album: $album, lyrics: ${lyricsPlain.substring(0, 15)}, lyricsSynced: ${lyricsSynced?.substring(0, 15)},duration: $duration, url: $url, id: $id, mediaID: $mediaID provider: $provider}';
  }

  Lyrics copyWith({
    String? id,
    String? artist,
    String? title,
    String? lyricsPlain,
    LyricsProvider? provider,
    String? album,
    String? lyricsSynced,
    ParsedLyrics? parsedLyrics,
    String? url,
    String? img,
    String? duration,
    String? mediaID,
  }) {
    return Lyrics(
      id: id ?? this.id,
      artist: artist ?? this.artist,
      title: title ?? this.title,
      lyricsPlain: lyricsPlain ?? this.lyricsPlain,
      provider: provider ?? this.provider,
      album: album ?? this.album,
      lyricsSynced: lyricsSynced ?? this.lyricsSynced,
      parsedLyrics: parsedLyrics ?? this.parsedLyrics,
      url: url ?? this.url,
      img: img ?? this.img,
      duration: duration ?? this.duration,
      mediaID: mediaID ?? this.mediaID,
    );
  }
}

class LyricsSearchResults {
  final List<Lyrics>? lyrics;
  final String query;

  LyricsSearchResults({
    this.lyrics,
    required this.query,
  });
}

class ParsedLyric {
  String text;
  Duration start;

  ParsedLyric({
    required this.text,
    required this.start,
  });

  @override
  String toString() {
    return '${start.inSeconds} : $text, ';
  }
}

class ParsedLyrics {
  List<ParsedLyric> lyrics = List.empty(growable: true);
  final String syncedLyrics;
  final String duration;

  ParsedLyrics({
    required this.syncedLyrics,
    required this.duration,
  }) {
    parseLyrics(syncedLyrics);
  }

  void parseLyrics(String syncedLyrics) {
    //LRC fromat is [mm:ss.xx] lyrics
    final regex = RegExp(r'\[(\d+):(\d+)\.(\d+)\] (.+)');
    final matches = regex.allMatches(syncedLyrics);

    for (var match in matches) {
      final min = int.parse(match.group(1)!);
      final sec = int.parse(match.group(2)!);
      final milli = int.parse(match.group(3)!);
      final text = match.group(4)!;
      lyrics.add(
        ParsedLyric(
          text: text,
          start: Duration(
            minutes: min,
            seconds: sec.toInt(),
            milliseconds: milli,
          ),
        ),
      );
    }
    log("ParsedLyrics: ${lyrics.length}");
  }

  @override
  String toString() {
    return 'ParsedLyrics{lyrics: $lyrics, duration: $duration}';
  }
}
