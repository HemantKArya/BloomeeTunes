// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:Bloomee/model/chart_model.dart';

typedef ChartFunction = Future<ChartModel> Function(ChartURL url);

class ChartURL {
  final String url;
  final String title;
  ChartURL({required this.url, required this.title});
}

class ChartInfo {
  final ChartFunction chartFunction;
  final String title;
  String imgUrl;
  final ChartURL url;
  bool show;

  ChartInfo({
    required this.chartFunction,
    required this.title,
    required this.imgUrl,
    required this.url,
    this.show = true,
  });

  ChartInfo copyWith({
    ChartFunction? chartFunction,
    String? title,
    String? imgUrl,
    ChartURL? url,
    bool? show,
  }) {
    return ChartInfo(
      chartFunction: chartFunction ?? this.chartFunction,
      title: title ?? this.title,
      imgUrl: imgUrl ?? this.imgUrl,
      url: url ?? this.url,
      show: show ?? this.show,
    );
  }
}

class RandomIMGs {
  final List<String> imgURLs;
  RandomIMGs({required this.imgURLs});

  String getImage() {
    final random = Random();
    return imgURLs[random.nextInt(imgURLs.length)];
  }
}
