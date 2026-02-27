import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for API cache, API tokens, YouTube link cache, and chart cache.
class CacheDAO {
  final Future<Isar> _db;

  const CacheDAO(this._db);

  // --------------- API response cache ---------------

  Future<void> putAPICache(String key, String value) async {
    Isar isarDB = await _db;
    if (key.isNotEmpty && value.isNotEmpty) {
      isarDB.writeTxnSync(
        () => isarDB.appSettingsStrDBs.putSync(
          AppSettingsStrDB(
            settingName: key,
            settingValue: value,
            settingValue2: "CACHE",
            lastUpdated: DateTime.now(),
          ),
        ),
      );
    }
  }

  Future<String?> getAPICache(String key) async {
    Isar isarDB = await _db;
    final apiCache = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(key)
        .findFirstSync();
    if (apiCache != null) {
      return apiCache.settingValue;
    }
    return null;
  }

  Future<void> clearAPICache() async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(
      () => isarDB.appSettingsStrDBs
          .filter()
          .settingValue2Contains("CACHE")
          .deleteAllSync(),
    );
  }

  // --------------- API tokens ---------------

  Future<void> putApiTokenDB(
      String apiName, String token, String expireIn) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(
      () => isarDB.appSettingsStrDBs.putSync(
        AppSettingsStrDB(
          settingName: apiName,
          settingValue: token,
          settingValue2: expireIn,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<String?> getApiTokenDB(String apiName) async {
    Isar isarDB = await _db;
    final apiToken = isarDB.appSettingsStrDBs
        .filter()
        .settingNameEqualTo(apiName)
        .findFirstSync();
    if (apiToken != null) {
      if ((apiToken.lastUpdated!.difference(DateTime.now()).inSeconds + 30)
                  .abs() <
              int.parse(apiToken.settingValue2!) ||
          apiToken.settingValue2 == "0") {
        return apiToken.settingValue;
      }
    }
    return null;
  }

  // --------------- YouTube link cache ---------------

  Future<void> putYtLinkCache(
      String id, String lowUrl, String highUrl, int expireAt) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.ytLinkCacheDBs.putSync(YtLinkCacheDB(
        videoId: id, lowQURL: lowUrl, highQURL: highUrl, expireAt: expireAt)));
  }

  Future<YtLinkCacheDB?> getYtLinkCache(String id) async {
    Isar isarDB = await _db;
    return isarDB.ytLinkCacheDBs.filter().videoIdEqualTo(id).findFirstSync();
  }

  Future<void> deleteAllYTLinks() async {
    Isar isarDB = await _db;
    isarDB.writeTxn(() => isarDB.ytLinkCacheDBs.clear());
  }

  // --------------- Chart cache ---------------

  Future<void> putChart(ChartsCacheDB chartCacheDB) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.chartsCacheDBs.putSync(chartCacheDB));
  }

  Future<ChartsCacheDB?> getChart(String chartName) async {
    Isar isarDB = await _db;
    return isarDB.chartsCacheDBs
        .filter()
        .chartNameEqualTo(chartName)
        .findFirstSync();
  }

  Future<ChartItemDB?> getFirstChartItem(String chartName) async {
    Isar isarDB = await _db;
    final chartCacheDB = isarDB.chartsCacheDBs
        .filter()
        .chartNameEqualTo(chartName)
        .findFirstSync();
    if (chartCacheDB != null && chartCacheDB.chartItems.isNotEmpty) {
      return chartCacheDB.chartItems.first;
    }
    return null;
  }
}
