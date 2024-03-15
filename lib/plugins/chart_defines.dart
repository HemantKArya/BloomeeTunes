import 'dart:math';

typedef ChartFunction = Future<List<Map<String, String>>> Function(
    {String url});

class ChartURL {
  final String url;
  final String title;
  ChartURL({required this.url, required this.title});
}

class ChartInfo {
  final ChartFunction chartFunction;
  final String title;
  final String url;
  final String imgUrl;

  ChartInfo({
    required this.chartFunction,
    required this.title,
    required this.url,
    required this.imgUrl,
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
