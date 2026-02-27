import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/repository/lyrics/lyrics.dart' as lyrics_api;
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';

/// Repository for lyrics — combines cached database lookups with
/// remote API fetching via [LyricsRepository] (the static API client).
///
/// Provides a cache-first strategy: checks [LyricsDAO] first, falls
/// back to API, and caches the result.
class LyricsCacheRepository {
  final LyricsDAO _lyricsDao;

  const LyricsCacheRepository(this._lyricsDao);

  // --------------- Cache-first lyrics ---------------

  /// Returns cached lyrics if available, otherwise fetches from the API
  /// and caches the result.
  Future<Lyrics> getLyrics(
    String mediaID,
    String title,
    String artist, {
    String? album,
    Duration? duration,
    LyricsProvider provider = LyricsProvider.none,
  }) async {
    // 1. Try cache
    final cached = await _lyricsDao.getLyrics(mediaID);
    if (cached != null &&
        (cached.lyricsSynced?.isNotEmpty ?? false) &&
        cached.lyricsSynced != 'null') {
      return cached;
    }

    // 2. Fetch from API
    final fetched = await lyrics_api.LyricsRepository.getLyrics(
      title,
      artist,
      album: album,
      duration: duration,
      provider: provider,
    );

    // 3. Cache if successful
    if ((fetched.lyricsSynced?.isNotEmpty ?? false) && fetched.lyricsSynced != 'null') {
      await _lyricsDao.putLyrics(fetched);
    }

    return fetched;
  }

  /// Searches for lyrics across providers (no caching).
  Future<List<Lyrics>> searchLyrics(
    String title,
    String artist, {
    String? album,
    Duration? duration,
    LyricsProvider provider = LyricsProvider.none,
  }) =>
      lyrics_api.LyricsRepository.searchLyrics(
        title,
        artist,
        album: album,
        duration: duration,
        provider: provider,
      );

  // --------------- Direct cache operations ---------------

  Future<Lyrics?> getCachedLyrics(String mediaID) =>
      _lyricsDao.getLyrics(mediaID);

  Future<void> cacheLyrics(Lyrics lyrics, {int? offset}) =>
      _lyricsDao.putLyrics(lyrics, offset: offset);

  Future<void> removeCachedLyrics(String mediaID) =>
      _lyricsDao.removeLyricsById(mediaID);
}
