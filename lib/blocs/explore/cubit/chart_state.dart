part of 'chart_cubit.dart';

class ChartState {
  ChartModel chart;
  String coverImg;
  ChartState({
    required this.chart,
    required this.coverImg,
  });

  ChartState copyWith({
    ChartModel? chart,
    String? coverImg,
  }) {
    return ChartState(
      chart: chart ?? this.chart,
      coverImg: coverImg ?? this.coverImg,
    );
  }
}

class ChartInitial extends ChartState {
  ChartInitial()
      : super(
            chart: ChartModel(
              chartName: "",
              chartItems: [],
            ),
            coverImg: "");
}

class FetchChartState {
  final bool isFetched;

  FetchChartState({this.isFetched = false});

  FetchChartState copyWith({bool? isFetched}) {
    return FetchChartState(isFetched: isFetched ?? this.isFetched);
  }
}

class FetchChartInitial extends FetchChartState {
  FetchChartInitial() : super(isFetched: false);
}
