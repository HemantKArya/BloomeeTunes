import 'package:Bloomee/services/db/GlobalDB.dart';

class ChartModel {
  final String chartName;
  final String? url;
  List<ChartItemModel>? chartItems = List.empty(growable: true);
  DateTime? lastUpdated = DateTime.now();

  ChartModel(
      {required this.chartName, this.chartItems, this.lastUpdated, this.url});
}

class ChartItemModel {
  final String? name;
  final String? imageUrl;
  final String? subtitle;

  ChartItemModel({
    required this.name,
    required this.imageUrl,
    required this.subtitle,
  });
}

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
