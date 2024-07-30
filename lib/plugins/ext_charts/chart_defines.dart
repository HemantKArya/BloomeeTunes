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

  ChartInfo({
    required this.chartFunction,
    required this.title,
    required this.imgUrl,
    required this.url,
  });
}

class RandomIMGs {
  final List<String> imgURLs;
  RandomIMGs({required this.imgURLs});

  String getImage() {
    final random = Random();
    return imgURLs[random.nextInt(imgURLs.length)];
  }
}
