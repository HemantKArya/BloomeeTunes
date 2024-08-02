import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/repository/Lyrics/lrcnet_api.dart';

class LyricsRepository {
  static Future<Lyrics> getLyrics(
    String title,
    String artist, {
    String? album,
    Duration? duration,
    LyricsProvider provider = LyricsProvider.none,
  }) async {
    Lyrics result;
    try {
      switch (provider) {
        case LyricsProvider.lrcnet:
          result = await getLRCNetAPILyrics(
            title,
            artist: artist,
            album: album,
            duration: duration?.inSeconds.toString(),
          );
          break;
        default:
          result = await getLRCNetAPILyrics(
            title,
            artist: artist,
            album: album,
            duration: duration?.inSeconds.toString(),
          );
      }
    } catch (e) {
      result = await getLRCNetAPILyrics(
        title,
        artist: artist,
      );
    }
    return result;
  }
}
