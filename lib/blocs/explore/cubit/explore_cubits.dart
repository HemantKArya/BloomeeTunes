// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:Bloomee/repository/Youtube/yt_music_home.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/utils/country_info.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
import 'package:Bloomee/repository/Youtube/yt_charts_home.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
part 'explore_states.dart';

class TrendingCubit extends Cubit<TrendingCubitState> {
  bool isLatest = false;
  TrendingCubit() : super(TrendingCubitInitial()) {
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
    ChartModel? ytChart = await BloomeeDBService.getChart("Trending Videos");
    if ((!isLatest) &&
        ytChart != null &&
        (ytChart.chartItems?.isNotEmpty ?? false)) {
      ChartModel chart = ytChart
        ..chartItems = getFirstElements(ytChart.chartItems!, 16);
      emit(state.copyWith(ytCharts: [chart]));
    }
  }
}

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  StreamSubscription<void>? watcher;
  RecentlyCubit() : super(RecentlyCubitInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = (await BloomeeDBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await BloomeeDBService.getRecentlyPlayed(limit: 15);
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}

class ChartCubit extends Cubit<ChartState> {
  ChartInfo chartInfo;
  StreamSubscription? strm;
  FetchChartCubit fetchChartCubit;
  ChartCubit(
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
    final chart = await BloomeeDBService.getChart(chartInfo.title);
    if (chart != null) {
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

Map<String, List<dynamic>> parseYTMusicData(String source) {
  final dynamicMap = jsonDecode(source);

  Map<String, List<dynamic>> listDynamicMap;
  if (dynamicMap is Map) {
    listDynamicMap = dynamicMap.map((key, value) {
      List<dynamic> list = [];
      if (value is List) {
        list = value;
      }
      return MapEntry(key, list);
    });
  } else {
    listDynamicMap = {};
  }
  return listDynamicMap;
}

class FetchChartCubit extends Cubit<FetchChartState> {
  FetchChartCubit() : super(FetchChartInitial()) {
    fetchCharts();
  }

  Future<void> fetchCharts() async {
    String _path = (await getApplicationSupportDirectory()).path;
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      ServicesBinding.rootIsolateToken!,
    );
    await BloomeeDBService.db;
    final chartList = await Isolate.run<List<ChartModel>>(() async {
      log(_path, name: "Isolate Path");
      List<ChartModel> _chartList = List.empty(growable: true);
      ChartModel chart;
      final db = await Isar.open(
        [
          ChartsCacheDBSchema,
        ],
        directory: _path,
      );
      for (var i in chartInfoList) {
        final chartCacheDB = db.chartsCacheDBs
            .where()
            .filter()
            .chartNameEqualTo(i.title)
            .findFirstSync();
        bool _shouldFetch = (chartCacheDB?.lastUpdated
                    .difference(DateTime.now())
                    .inHours
                    .abs() ??
                80) >
            16;
        log("Last Updated - ${(chartCacheDB?.lastUpdated.difference(DateTime.now()).inHours)?.abs()} Hours before ",
            name: "Isolate");

        if (_shouldFetch) {
          chart = await i.chartFunction(i.url);
          if ((chart.chartItems?.isNotEmpty) ?? false) {
            db.writeTxnSync(() =>
                db.chartsCacheDBs.putSync(chartModelToChartCacheDB(chart)));
          }
          log("Chart Fetched - ${chart.chartName}", name: "Isolate");
          _chartList.add(chart);
        }
      }
      db.close();
      return _chartList;
    });

    if (chartList.isNotEmpty) {
      emit(state.copyWith(isFetched: true));
    }
  }
}

class YTMusicCubit extends Cubit<YTMusicCubitState> {
  YTMusicCubit() : super(YTMusicCubitInitial()) {
    fetchYTMusicDB();
    fetchYTMusic();
  }

  void fetchYTMusicDB() async {
    final data = await BloomeeDBService.getAPICache("YTMusic");
    if (data != null) {
      final ytmData = await compute(parseYTMusicData, data);
      if (ytmData.isNotEmpty) {
        emit(state.copyWith(ytmData: ytmData));
      }
    }
  }

  Future<void> fetchYTMusic() async {
    String countryCode = await getCountry();
    final ytCharts =
        await Isolate.run(() => getMusicHome(countryCode: countryCode));
    if (ytCharts.isNotEmpty) {
      emit(state.copyWith(ytmData: Map<String, List<dynamic>>.from(ytCharts)));
      final ytChartsJson = await compute(jsonEncode, ytCharts);
      BloomeeDBService.putAPICache("YTMusic", ytChartsJson);
      log("YTMusic Fetched", name: "YTMusic");
    }
  }
}
