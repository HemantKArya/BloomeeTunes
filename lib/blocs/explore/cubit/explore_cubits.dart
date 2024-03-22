// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:bloc/bloc.dart';

import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:Bloomee/repository/Youtube/yt_charts_home.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';

part 'explore_states.dart';

class TrendingCubit extends Cubit<TrendingCubitState> {
  bool isLatest = false;
  TrendingCubit() : super(TrendingCubitInitial()) {
    getTrendingVideosFromDB();
    getTrendingVideos();
  }

  void getTrendingVideos() async {
    final ytCharts = await fetchTrendingVideos();
    emit(state.copyWith(ytCharts: ytCharts));
    isLatest = true;
  }

  void getTrendingVideosFromDB() async {
    final ytChart = await BloomeeDBService.getChart("Trending Videos");
    if ((!isLatest) &&
        ytChart != null &&
        (ytChart.chartItems?.isNotEmpty ?? false)) {
      emit(state.copyWith(ytCharts: [ytChart]));
    }
  }
}

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  late Stream<void> watcher;
  RecentlyCubit() : super(RecentlyCubitInitial()) {
    BloomeeDBService.refreshRecentlyPlayed();
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = await BloomeeDBService.watchRecentlyPlayed();
    watcher.listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await BloomeeDBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}

class ChartCubit extends Cubit<ChartState> {
  ChartInfo chartInfo;
  ChartCubit(
    this.chartInfo,
  ) : super(ChartInitial()) {
    getChartFromDB();
    getChart();
  }

  void getChart() async {
    final chart = await chartInfo.chartFunction(chartInfo.url);
    emit(state.copyWith(
        chart: chart, coverImg: chart.chartItems?.first.imageUrl));
  }

  void getChartFromDB() async {
    final chart = await BloomeeDBService.getChart(chartInfo.title);
    if (chart != null) {
      emit(state.copyWith(
          chart: chart, coverImg: chart.chartItems?.first.imageUrl));
    }
  }
}
