part of 'trending_cubit.dart';

class TrendingCubitState {
  List<ChartModel>? ytCharts;
  TrendingCubitState({
    required this.ytCharts,
  });

  TrendingCubitState copyWith({
    List<ChartModel>? ytCharts,
  }) {
    return TrendingCubitState(
      ytCharts: ytCharts ?? this.ytCharts,
    );
  }
}

final class TrendingCubitInitial extends TrendingCubitState {
  TrendingCubitInitial() : super(ytCharts: []);
}
