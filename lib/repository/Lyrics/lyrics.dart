import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/repository/Lyrics/genius_api.dart';

class LyricsRepository {
  static Future<LyricsSearchResults> getLyrics(String title, String artist,
      {LyricsProvider provider = LyricsProvider.none}) async {
    LyricsSearchResults results;
    try {
      switch (provider) {
        case LyricsProvider.genius:
          results = await searchGeniusLyrics(title, artist);
          break;
        default:
          results = await searchGeniusLyrics(title, artist);
      }
    } catch (e) {
      return await searchGeniusLyrics(title, artist);
    }
    return results;
  }
}
