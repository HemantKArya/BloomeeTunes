import 'package:Bloomee/repository/LastFM/lastfmapi.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';

/// Repository for Last.fm scrobbling operations.
///
/// Orchestrates [LastFmAPI] (pure HTTP client) with [SettingsDAO]
/// for session/credential persistence. The API client itself has no
/// DB dependencies — this repository handles the persistence bridge.
class ScrobbleRepository {
  final SettingsDAO _settingsDao;

  const ScrobbleRepository(this._settingsDao);

  // --------------- Session management ---------------

  /// Initializes the LastFM API with stored credentials.
  Future<void> initializeFromStorage() async {
    final apiKey = await _settingsDao.getSettingStr(
      CacheKeys.lFMApiKey,
    );
    final apiSecret = await _settingsDao.getSettingStr(
      CacheKeys.lFMSecret,
    );
    final sessionKey = await _settingsDao.getSettingStr(
      CacheKeys.lFMSession,
    );
    final username = await _settingsDao.getSettingStr(
      CacheKeys.lFMUsername,
    );

    LastFmAPI.initialize(
      apiKey: apiKey,
      apiSecret: apiSecret,
      sessionKey: sessionKey,
    );
    if (username != null) {
      LastFmAPI.setUsername(username);
    }
  }

  /// Saves Last.fm session credentials to settings DB.
  Future<void> saveSession({
    required String apiKey,
    required String apiSecret,
    required String sessionKey,
    required String username,
  }) async {
    await _settingsDao.putSettingStr(CacheKeys.lFMApiKey, apiKey);
    await _settingsDao.putSettingStr(CacheKeys.lFMSecret, apiSecret);
    await _settingsDao.putSettingStr(CacheKeys.lFMSession, sessionKey);
    await _settingsDao.putSettingStr(CacheKeys.lFMUsername, username);
  }

  /// Checks whether scrobbling is enabled in settings.
  Future<bool> isScrobblingEnabled() async {
    final enabled = await _settingsDao.getSettingBool(
      CacheKeys.lFMScrobbleSetting,
      defaultValue: false,
    );
    return enabled ?? false;
  }

  /// Clears stored Last.fm session (logout).
  Future<void> clearSession() async {
    await _settingsDao.putSettingStr(CacheKeys.lFMSession, '');
    await _settingsDao.putSettingStr(CacheKeys.lFMUsername, '');
    LastFmAPI.initialize(apiKey: null, apiSecret: null, sessionKey: null);
  }

  // --------------- Scrobble operations ---------------

  /// Scrobbles a list of tracks to Last.fm.
  Future<bool> scrobble(List<ScrobbleTrack> tracks) =>
      LastFmAPI.scrobble(tracks);

  /// Fetches a request token for auth flow.
  Future<String> fetchRequestToken() => LastFmAPI.fetchRequestToken();

  /// Gets the auth URL for user to authorize.
  String getAuthUrl(String token) => LastFmAPI.getAuthUrl(token);

  /// Fetches session key after authorization.
  Future<Map<String, String>> fetchSessionKey(String token) =>
      LastFmAPI.fetchSessionKey(token);

  // --------------- User data ---------------

  Future<Map<String, dynamic>> getUserRecommendedList() =>
      LastFmAPI.getUserRecommendedList();

  Future<Map<String, dynamic>> getUserMixList() => LastFmAPI.getUserMixList();

  Future<Map<String, dynamic>> getUserLibraryList() =>
      LastFmAPI.getUserLibraryList();
}
