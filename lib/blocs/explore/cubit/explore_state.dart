// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'explore_cubit.dart';

class ExploreState {
  List<List<Map<String, dynamic>>> ytCharts = List.empty(growable: true);
  ExploreState({
    required this.ytCharts,
  });

  ExploreState copyWith({
    List<List<Map<String, dynamic>>>? ytCharts,
  }) {
    return ExploreState(
      ytCharts: ytCharts ?? this.ytCharts,
    );
  }
}

final class ExploreInitial extends ExploreState {
  ExploreInitial() : super(ytCharts: []);
}
