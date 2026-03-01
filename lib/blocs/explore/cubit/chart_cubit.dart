import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/core/models/chart_model.dart';
import 'package:Bloomee/plugins/charts/chart_defines.dart';
import 'package:Bloomee/repository/bloomee/chart_repository.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chart_state.dart';

/// Cubit for an individual chart card on the Explore screen.
///
/// Reads chart data from [CacheDAO].
class ChartCubit extends Cubit<ChartState> {
  final CacheDAO _cacheDao;
  ChartInfo chartInfo;
  StreamSubscription? strm;
  FetchChartCubit fetchChartCubit;

  ChartCubit(
    this._cacheDao,
    this.chartInfo,
    this.fetchChartCubit,
  ) : super(ChartInitial()) {
    getChartFromDB();
    initListener();
  }

  void initListener() {
    strm = fetchChartCubit.stream.listen((state) {
      if (state.isFetched) {
        log("Chart Fetched from Isolate - ${chartInfo.title}",
            name: "Isolate Fetched");
        getChartFromDB();
      }
    });
  }

  Future<void> getChartFromDB() async {
    final chartCacheDB = await _cacheDao.getChart(chartInfo.title);
    if (chartCacheDB != null) {
      final chart = chartCacheDBToChartModel(chartCacheDB);
      emit(state.copyWith(
          chart: chart, coverImg: chart.chartItems?.first.imageUrl));
    }
  }

  @override
  Future<void> close() {
    fetchChartCubit.close();
    strm?.cancel();
    return super.close();
  }
}

/// Cubit that fetches all charts in a background isolate via [ChartRepository].
class FetchChartCubit extends Cubit<FetchChartState> {
  final String _appSupportPath;

  FetchChartCubit(this._appSupportPath) : super(FetchChartInitial()) {
    fetchCharts();
  }

  Future<void> fetchCharts() async {
    final chartList =
        await ChartRepository.fetchChartsInIsolate(_appSupportPath);
    if (chartList.isNotEmpty) {
      emit(state.copyWith(isFetched: true));
    }
  }
}
