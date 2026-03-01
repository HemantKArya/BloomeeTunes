// Re-export mapper functions for convenience.
export 'package:Bloomee/services/db/mappers/chart_mapper.dart';

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
