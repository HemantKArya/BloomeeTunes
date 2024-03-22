// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'explore_cubits.dart';

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

class RecentlyCubitState {
  MediaPlaylist mediaPlaylist;
  RecentlyCubitState({
    required this.mediaPlaylist,
  });

  RecentlyCubitState copyWith({
    MediaPlaylist? mediaPlaylist,
  }) {
    return RecentlyCubitState(
      mediaPlaylist: mediaPlaylist ?? this.mediaPlaylist,
    );
  }
}

class RecentlyCubitInitial extends RecentlyCubitState {
  RecentlyCubitInitial()
      : super(mediaPlaylist: MediaPlaylist(albumName: "", mediaItems: []));
}

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
