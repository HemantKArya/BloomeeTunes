import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

/// Repository for audio source resolution — manages the link cache
/// and quality settings for playback URL resolution.
///
/// Orchestrates [CacheDAO] (for YouTube link caching) with
/// [SettingsDAO] (for quality preferences). The actual URL resolution
/// is done by the YouTube/Saavn API clients; this repository owns
/// the persistence layer around source resolution.
class AudioSourceRepository {
  final CacheDAO _cacheDao;
  final SettingsDAO _settingsDao;

  const AudioSourceRepository(this._cacheDao, this._settingsDao);

  // --------------- YouTube link cache ---------------

  Future<void> cacheYtLink(
    String id,
    String lowUrl,
    String highUrl,
    int expireAt,
  ) =>
      _cacheDao.putYtLinkCache(id, lowUrl, highUrl, expireAt);

  Future<YtLinkCacheDB?> getYtLinkCache(String id) =>
      _cacheDao.getYtLinkCache(id);

  Future<void> clearYtLinkCache() => _cacheDao.deleteAllYTLinks();

  // --------------- API token cache ---------------

  Future<void> cacheApiToken(
    String apiName,
    String token,
    String expireIn,
  ) =>
      _cacheDao.putApiTokenDB(apiName, token, expireIn);

  Future<String?> getApiToken(String apiName) =>
      _cacheDao.getApiTokenDB(apiName);

  // --------------- Quality settings ---------------

  Future<String> getStreamingQuality() async {
    final quality = await _settingsDao.getSettingStr(
      'ytQuality',
      defaultValue: 'Low',
    );
    return quality ?? 'Low';
  }

  Future<void> setStreamingQuality(String quality) =>
      _settingsDao.putSettingStr('ytQuality', quality);
}
