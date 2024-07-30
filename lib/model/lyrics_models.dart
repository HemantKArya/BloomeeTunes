enum LyricsProvider {
  azlyrics,
  genius,
  lyricsfreak,
  lyricsmode,
  metrolyrics,
  musixmatch,
  songlyrics,
  none,
}

class Lyrics {
  final String artist;
  final String title;
  final String lyrics;
  final String url;
  final String? img;
  final String id;
  final LyricsProvider provider;

  Lyrics({
    required this.artist,
    required this.title,
    required this.lyrics,
    required this.url,
    required this.id,
    required this.provider,
    this.img,
  });

  // override method for printing the object
  @override
  String toString() {
    return 'Lyrics{artist: $artist, title: $title, lyrics: $lyrics, url: $url, id: $id, provider: $provider}';
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
