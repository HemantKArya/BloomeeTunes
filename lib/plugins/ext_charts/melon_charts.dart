import 'dart:developer';

import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
// import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

const List<String> melonIMGs = [
  "https://cdnimg.melon.co.kr/resource/image/cds/musicstory/imgUrl20240311045333700.jpg",
  "https://cdnimg.melon.co.kr/resource/image/cds/musicstory/imgUrl20240311045344001.jpg",
  "https://cdnimg.melon.co.kr/resource/image/cds/musicstory/imgUrl20240311043032241.jpg",
  "https://cdnimg.melon.co.kr/cm2/artistcrop/images/030/55/146/3055146_20231013113531_org.jpg?0e566ba6e62e36c713375aa363f4b9ef/melon/optimize/90",
  "https://cdnimg.melon.co.kr/resource/image/cds/artist/img_melon_ch_500.jpg/melon/resize/500",
  "https://cdnimg.melon.co.kr/resource/image/cds/musicstory/imgUrl20230509020832655.jpg",
  "https://cdnimg.melon.co.kr/resource/image/cds/musicstory/imgUrl20230628072034417.jpg/melon/optimize/90",
];

final RandomIMGs melonRandomIMGs = RandomIMGs(imgURLs: melonIMGs);

class MelonChartsLinks {
  static const String TOP_100 = 'https://www.melon.com/chart/index.htm';
  static const String HOT_100 = 'https://www.melon.com/chart/hot100/index.htm';
  static const String GENREOMICS_DAILY =
      'https://www.melon.com/chart/day/index.htm?classCd=GN0000';
  static const String DOMESTIC_DAILY =
      'https://www.melon.com/chart/day/index.htm?classCd=DM0000';
  static const String OVERSEAS_DAILY =
      'https://www.melon.com/chart/day/index.htm?classCd=AB0000';
  static const String GENREOMICS_WEEKLY =
      'https://www.melon.com/chart/week/index.htm?classCd=GN0000';
  static const String DOMESTIC_WEEKLY =
      'https://www.melon.com/chart/week/index.htm?classCd=DM0000';
  static const String OVERSEAS_WEEKLY =
      'https://www.melon.com/chart/week/index.htm?classCd=AB0000';
  static const String GENREOMICS_MONTHLY =
      'https://www.melon.com/chart/month/index.htm?classCd=GN0000';
  static const String DOMESTIC_MONTHLY =
      'https://www.melon.com/chart/month/index.htm?classCd=DM0000';
  static const String OVERSEAS_MONTHLY =
      'https://www.melon.com/chart/month/index.htm?classCd=AB0000';
}

class MelonCharts {
  static final ChartURL TOP_100 =
      ChartURL(title: "Melon\nTop 100", url: MelonChartsLinks.TOP_100);
  static final ChartURL HOT_100 =
      ChartURL(title: "Melon\nHot 100", url: MelonChartsLinks.HOT_100);
  static final ChartURL GENREOMICS_DAILY = ChartURL(
      title: "Melon\nGenremics Daily", url: MelonChartsLinks.GENREOMICS_DAILY);
  static final ChartURL DOMESTIC_DAILY = ChartURL(
      title: "Melon\nDomestic Daily", url: MelonChartsLinks.DOMESTIC_DAILY);
  static final ChartURL OVERSEAS_DAILY = ChartURL(
      title: "Melon\nOverseas Daily", url: MelonChartsLinks.OVERSEAS_DAILY);
  static final ChartURL GENREOMICS_WEEKLY = ChartURL(
      title: "Melon\nGenremics Weekly",
      url: MelonChartsLinks.GENREOMICS_WEEKLY);
  static final ChartURL DOMESTIC_WEEKLY = ChartURL(
      title: "Melon\nDomestic Weekly", url: MelonChartsLinks.DOMESTIC_WEEKLY);
  static final ChartURL OVERSEAS_WEEKLY = ChartURL(
      title: "Melon\nOverseas Weekly", url: MelonChartsLinks.OVERSEAS_WEEKLY);
  static final ChartURL GENREOMICS_MONTHLY = ChartURL(
      title: "Melon\nGenremics Monthly",
      url: MelonChartsLinks.GENREOMICS_MONTHLY);
  static final ChartURL DOMESTIC_MONTHLY = ChartURL(
      title: "Melon\nDomestic Monthly", url: MelonChartsLinks.DOMESTIC_MONTHLY);
  static final ChartURL OVERSEAS_MONTHLY = ChartURL(
      title: "Melon\nOverseas Monthly", url: MelonChartsLinks.OVERSEAS_MONTHLY);
}

Future<ChartModel> getMelonChart(ChartURL url) async {
  final client = http.Client();

  try {
    final response = await client.get(Uri.parse(url.url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    });
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final rankList = document.querySelector('#tb_list');
      final allItems50 = rankList!.querySelectorAll('tr.lst50');
      final allItems100 = rankList.querySelectorAll('tr.lst100');
      final allItems = allItems50.toList()..addAll(allItems100);

      List<ChartItemModel> chartItems = [];
      for (final item in allItems) {
        final div = item.querySelector('div.wrap_song_info');
        final title = div!.querySelector('div.ellipsis.rank01 a')?.text.trim();
        final label =
            div.querySelector('div.ellipsis.rank02 span')?.text.trim();
        final img =
            item.querySelector('a.image_typeAll img')!.attributes['src']!;

        chartItems.add(ChartItemModel(
          name: title,
          imageUrl: img.replaceAll(RegExp(r'resize/\d+'), 'resize/350'),
          subtitle: label,
        ));
      }
      final melonChart = ChartModel(
          chartName: url.title,
          chartItems: chartItems,
          url: url.url,
          lastUpdated: DateTime.now());
      // BloomeeDBService.putChart(melonChart);
      log('Melon Charts: ${melonChart.chartItems!.length} tracks',
          name: "Melon");
      return melonChart;
    } else {
      // final chart = await BloomeeDBService.getChart(url.title);
      // if (chart != null) {
      //   log('Melon Charts: ${chart.chartItems!.length} tracks loaded from cache',
      //       name: "Melon");
      //   return chart;
      // }
      throw Exception(
          'Parsing failed with status code: ${response.statusCode}');
    }
  } catch (e) {
    // final chart = await BloomeeDBService.getChart(url.title);
    // if (chart != null) {
    //   log('Melon Charts: ${chart.chartItems!.length} tracks loaded from cache',
    //       name: "Melon");
    //   return chart;
    // }
    throw Exception('Failed to parse page');
  }
}
