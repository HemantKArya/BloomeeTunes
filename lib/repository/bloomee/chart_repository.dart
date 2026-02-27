import 'dart:developer';
import 'dart:isolate';

import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';

/// Repository for chart data — combines chart cache DAO operations.
///
/// Wraps [CacheDAO] chart methods. The actual chart fetching from external
/// sources is done by chart provider plugins; this repository owns
/// the cached data lifecycle.
class ChartRepository {
  final CacheDAO _cacheDao;

  const ChartRepository(this._cacheDao);

  // --------------- Chart cache ---------------

  Future<void> putChart(ChartsCacheDB chartCacheDB) =>
      _cacheDao.putChart(chartCacheDB);

  Future<ChartsCacheDB?> getChart(String chartName) =>
      _cacheDao.getChart(chartName);

  Future<ChartItemDB?> getFirstChartItem(String chartName) =>
      _cacheDao.getFirstChartItem(chartName);

  // --------------- API cache (generic) ---------------

  Future<void> putAPICache(String key, String value) =>
      _cacheDao.putAPICache(key, value);

  Future<String?> getAPICache(String key) => _cacheDao.getAPICache(key);

  Future<void> clearAPICache() => _cacheDao.clearAPICache();

  // --------------- Isolate-based chart refresh ---------------

  /// Fetches all charts from external sources in a background isolate.
  ///
  /// Opens its own Isar instance inside the isolate (required — Isar instances
  /// cannot cross isolate boundaries). Skips charts updated within the last
  /// 16 hours. Returns the list of freshly-fetched [ChartModel]s (empty if
  /// everything was already up-to-date).
  static Future<List<ChartModel>> fetchChartsInIsolate(
      String appSupportPath) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      ServicesBinding.rootIsolateToken!,
    );
    return Isolate.run<List<ChartModel>>(() async {
      log(appSupportPath, name: "ChartRepo Isolate");
      final chartList = <ChartModel>[];
      final db = await Isar.open(
        [ChartsCacheDBSchema],
        directory: appSupportPath,
      );
      for (var i in chartInfoList) {
        final chartCacheDB = db.chartsCacheDBs
            .where()
            .filter()
            .chartNameEqualTo(i.title)
            .findFirstSync();
        final hoursSinceUpdate = chartCacheDB?.lastUpdated
                .difference(DateTime.now())
                .inHours
                .abs() ??
            80;
        log("Last Updated - $hoursSinceUpdate hours ago",
            name: "ChartRepo Isolate");

        if (hoursSinceUpdate > 16) {
          final chart = await i.chartFunction(i.url);
          if (chart.chartItems?.isNotEmpty ?? false) {
            db.writeTxnSync(() =>
                db.chartsCacheDBs.putSync(chartModelToChartCacheDB(chart)));
          }
          log("Chart Fetched - ${chart.chartName}",
              name: "ChartRepo Isolate");
          chartList.add(chart);
        }
      }
      db.close();
      return chartList;
    });
  }
}
