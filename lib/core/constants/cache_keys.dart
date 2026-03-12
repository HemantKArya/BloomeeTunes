/// Keys for API tokens and service-level cache entries stored in the database.
/// These replace API/cache-key constants previously mixed into [GlobalStrConsts].
class CacheKeys {
  CacheKeys._();

  // ── LastFM ──────────────────────────────────────────────────────────────────
  static const String lFMApiKey = "lastFMKey";
  static const String lFMSession = "lastFMSession";
  static const String lFMSecret = "lastFMSecret";
  static const String lFMUIPicks = "lastFMUIPicks";
  static const String lFMScrobbleSetting = "lastFMScrobble";
  static const String lFMUsername = "lastFMUsernames";

  /// Cache key for unscrobbled tracks to be submitted on next connection.
  static const String lFMTrackedCache = "lastFMTrackedCacheForFutureScrobble";
}
