import 'package:Bloomee/core/models/chart_model.dart';
import 'package:Bloomee/services/db/global_db.dart';

/// Maps between [ChartsCacheDB] / [ChartItemDB] (Isar entities)
/// and [ChartModel] / [ChartItemModel] (domain).
///
/// Extracted from `chart_model.dart` to keep domain models DB-free.

ChartsCacheDB chartModelToChartCacheDB(ChartModel chartModel) {
  return ChartsCacheDB(
      chartItems: chartModel.chartItems
              ?.map((e) => chartItemModelToChartItemDB(e))
              .toList() ??
          List.empty(growable: true),
      chartName: chartModel.chartName,
      lastUpdated: chartModel.lastUpdated ?? DateTime.now(),
      permaURL: chartModel.url);
}

ChartModel chartCacheDBToChartModel(ChartsCacheDB chartsCacheDB) {
  return ChartModel(
      chartItems: chartsCacheDB.chartItems
          .map((e) => chartItemDBToChartItemModel(e))
          .toList(),
      chartName: chartsCacheDB.chartName,
      lastUpdated: chartsCacheDB.lastUpdated,
      url: chartsCacheDB.permaURL);
}

ChartItemDB chartItemModelToChartItemDB(ChartItemModel chartItemModel) {
  return ChartItemDB()
    ..artURL = chartItemModel.imageUrl
    ..artist = chartItemModel.subtitle
    ..title = chartItemModel.name;
}

ChartItemModel chartItemDBToChartItemModel(ChartItemDB chartItemDB) {
  return ChartItemModel(
      imageUrl: chartItemDB.artURL,
      name: chartItemDB.title,
      subtitle: chartItemDB.artist);
}
