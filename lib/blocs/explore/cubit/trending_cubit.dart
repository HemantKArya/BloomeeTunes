import 'package:Bloomee/core/models/chart_model.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/repository/youtube/yt_charts_home.dart';

part 'trending_state.dart';

/// Cubit for trending videos on the Explore screen.
///
/// Uses [CacheDAO] for chart cache reads.
class TrendingCubit extends Cubit<TrendingCubitState> {
  final CacheDAO _cacheDao;
  bool isLatest = false;

  TrendingCubit(this._cacheDao) : super(TrendingCubitInitial()) {
    getTrendingVideosFromDB();
    getTrendingVideos();
  }

  void getTrendingVideos() async {
    List<ChartModel> ytCharts = await fetchTrendingVideos();
    ChartModel chart = ytCharts[0]
      ..chartItems = getFirstElements(ytCharts[0].chartItems!, 16);
    emit(state.copyWith(ytCharts: [chart]));
    isLatest = true;
  }

  List<ChartItemModel> getFirstElements(List<ChartItemModel> list, int count) {
    return list.length > count ? list.sublist(0, count) : list;
  }

  void getTrendingVideosFromDB() async {
    final chartCacheDB = await _cacheDao.getChart("Trending Videos");
    if (chartCacheDB == null) return;
    final ytChart = chartCacheDBToChartModel(chartCacheDB);
    if ((!isLatest) && (ytChart.chartItems?.isNotEmpty ?? false)) {
      ChartModel chart = ytChart
        ..chartItems = getFirstElements(ytChart.chartItems!, 16);
      emit(state.copyWith(ytCharts: [chart]));
    }
  }
}
