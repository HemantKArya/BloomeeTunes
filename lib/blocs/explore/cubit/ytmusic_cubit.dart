import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:Bloomee/repository/youtube/yt_music_home.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/utils/country_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ytmusic_state.dart';

Map<String, List<dynamic>> _parseYTMusicData(String source) {
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

/// Cubit for the YTMusic home section on the Explore screen.
///
/// Uses [CacheDAO] for API cache reads/writes.
class YTMusicCubit extends Cubit<YTMusicCubitState> {
  final CacheDAO _cacheDao;

  YTMusicCubit(this._cacheDao) : super(YTMusicCubitInitial()) {
    fetchYTMusicDB();
    fetchYTMusic();
  }

  void fetchYTMusicDB() async {
    final data = await _cacheDao.getAPICache("YTMusic");
    if (data != null) {
      final ytmData = await compute(_parseYTMusicData, data);
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
      _cacheDao.putAPICache("YTMusic", ytChartsJson);
      log("YTMusic Fetched", name: "YTMusic");
    }
  }
}
