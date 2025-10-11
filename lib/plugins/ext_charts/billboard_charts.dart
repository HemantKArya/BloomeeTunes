import 'dart:developer';

import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
// import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

const List<String> billboardIMGs = [
  "https://www.billboard.com/wp-content/themes/vip/pmc-billboard-2021/assets/app/icons/icon-512x512.png",
  "https://i1.sndcdn.com/avatars-000221247168-sc2fzp-t500x500.jpg",
  "https://i1.sndcdn.com/artworks-000162525636-tvam2d-t500x500.jpg",
  "https://rocknyc.live/wp-content/uploads/2020/12/billboard-charts-logo-2018-billboard-1548-compressed.jpg"
];
RandomIMGs billboardRandomIMGs = RandomIMGs(imgURLs: billboardIMGs);

class BillboardChartLinks {
  static const String HOT_100 = 'https://www.billboard.com/charts/hot-100/';
  static const String BILLBOARD_200 =
      'https://www.billboard.com/charts/billboard-200/';
  static const String SOCIAL_50 = 'https://www.billboard.com/charts/social-50/';
  static const String STREAMING_SONGS =
      'https://www.billboard.com/charts/streaming-songs/';
  static const String DIGITAL_SONG_SALES =
      'https://www.billboard.com/charts/digital-song-sales/';
  static const String RADIO_SONGS =
      'https://www.billboard.com/charts/radio-songs/';
  static const String TOP_ALBUM_SALES =
      'https://www.billboard.com/charts/top-album-sales/';
  static const String CURRENT_ALBUMS =
      'https://www.billboard.com/charts/current-albums/';
  static const String INDEPENDENT_ALBUMS =
      'https://www.billboard.com/charts/independent-albums/';
  static const String CATALOG_ALBUMS =
      'https://www.billboard.com/charts/catalog-albums/';
  static const String SOUNDTRACKS =
      'https://www.billboard.com/charts/soundtracks/';
  static const String VINYL_ALBUMS =
      'https://www.billboard.com/charts/vinyl-albums/';
  static const String HEATSEEKERS_ALBUMS =
      'https://www.billboard.com/charts/heatseekers-albums/';
  static const String WORLD_ALBUMS =
      'https://www.billboard.com/charts/world-albums/';
  static const String CANADIAN_HOT_100 =
      'https://www.billboard.com/charts/canadian-hot-100/';
  static const String JAPAN_HOT_100 =
      'https://www.billboard.com/charts/japan-hot-100/';
  static const String KOREA_100 =
      'https://www.billboard.com/charts/billboard-korea-100/';
  static const String INDIA_SONGS =
      'https://www.billboard.com/charts/india-songs-hotw/';
  static const String BILLBOARD_GLOBAL_200 =
      'https://www.billboard.com/charts/billboard-global-200/';
}

class BillboardCharts {
  static final ChartURL HOT_100 =
      ChartURL(title: "Billboard\nHot 100", url: BillboardChartLinks.HOT_100);
  static final ChartURL BILLBOARD_200 =
      ChartURL(title: "Billboard\n200", url: BillboardChartLinks.BILLBOARD_200);
  static final ChartURL SOCIAL_50 = ChartURL(
      title: "Billboard\nSocial 50", url: BillboardChartLinks.SOCIAL_50);
  static final ChartURL STREAMING_SONGS = ChartURL(
      title: "Billboard\nStreaming Songs",
      url: BillboardChartLinks.STREAMING_SONGS);
  static final ChartURL DIGITAL_SONG_SALES = ChartURL(
      title: "Billboard\nDigital Song Sales",
      url: BillboardChartLinks.DIGITAL_SONG_SALES);
  static final ChartURL RADIO_SONGS = ChartURL(
      title: "Billboard\nRadio Songs", url: BillboardChartLinks.RADIO_SONGS);
  static final ChartURL TOP_ALBUM_SALES = ChartURL(
      title: "Billboard\nTop Album Sales",
      url: BillboardChartLinks.TOP_ALBUM_SALES);
  static final ChartURL CURRENT_ALBUMS = ChartURL(
      title: "Billboard\nCurrent Albums",
      url: BillboardChartLinks.CURRENT_ALBUMS);
  static final ChartURL INDEPENDENT_ALBUMS = ChartURL(
      title: "Billboard\nIndependent Albums",
      url: BillboardChartLinks.INDEPENDENT_ALBUMS);
  static final ChartURL CATALOG_ALBUMS = ChartURL(
      title: "Billboard\nCatalog Albums",
      url: BillboardChartLinks.CATALOG_ALBUMS);
  static final ChartURL SOUNDTRACKS = ChartURL(
      title: "Billboard\nSoundtracks", url: BillboardChartLinks.SOUNDTRACKS);
  static final ChartURL VINYL_ALBUMS = ChartURL(
      title: "Billboard\nVinyl Albums", url: BillboardChartLinks.VINYL_ALBUMS);
  static final ChartURL HEATSEEKERS_ALBUMS = ChartURL(
      title: "Billboard\nHeatseekers Albums",
      url: BillboardChartLinks.HEATSEEKERS_ALBUMS);
  static final ChartURL WORLD_ALBUMS = ChartURL(
      title: "Billboard\nWorld Albums", url: BillboardChartLinks.WORLD_ALBUMS);
  static final ChartURL CANADIAN_HOT_100 = ChartURL(
      title: "Billboard\nCanadian Hot 100",
      url: BillboardChartLinks.CANADIAN_HOT_100);
  static final ChartURL JAPAN_HOT_100 = ChartURL(
      title: "Billboard\nJapan Hot 100",
      url: BillboardChartLinks.JAPAN_HOT_100);
  static final ChartURL KOREA_100 = ChartURL(
      title: "Billboard\nKorea 100", url: BillboardChartLinks.KOREA_100);
  static final ChartURL INDIA_SONGS = ChartURL(
      title: "Billboard\nIndia Songs", url: BillboardChartLinks.INDIA_SONGS);
  static final ChartURL BILLBOARD_GLOBAL_200 = ChartURL(
      title: "Billboard\nGlobal 200",
      url: BillboardChartLinks.BILLBOARD_GLOBAL_200);
}

enum Status { NEW, UP, DOWN, SAME, REENTRY, ERROR }

Status getStatus(Element element) {
  var svg = element.querySelector('svg');
  if (svg != null) {
    var g = svg.querySelector('g');
    if (g != null) {
      var dataName = g.attributes['data-name'];
      if (dataName == 'Group 7171') return Status.DOWN;
      if (dataName == 'Group 7170') return Status.UP;
      if (dataName == 'Group 3') return Status.SAME;
    }
    return Status.ERROR;
  }
  var span = element.querySelector('span');
  if (span != null) {
    var spanText = span.text.trim();
    if (spanText.toLowerCase().contains('new')) return Status.NEW;
    if (spanText.toLowerCase().contains('re-entry')) return Status.REENTRY;
  }
  return Status.ERROR;
}

Future<ChartModel> getBillboardChart(ChartURL url) async {
  var client = http.Client();
  try {
    var response = await client.get(Uri.parse(url.url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    });

    if (response.statusCode == 200) {
      var document = parse(response.body);
      var songs =
          document.querySelectorAll('.o-chart-results-list-row-container');
      // List<Map<String, String>> songList = [];
      List<ChartItemModel> chartItems = [];
      for (var item in songs) {
        var row = item.querySelector('ul.o-chart-results-list-row');
        var attributes = row!.querySelectorAll('li');
        // var rank = row.attributes['data-detail-target'];
        var img = attributes[1].querySelector('img');
        var title = attributes[3].querySelector('h3.c-title');
        var label = attributes[3].querySelector('span.c-label');
        var ttl = title?.text.trim();
        var lbl = label?.text.trim();

        String imgURL =
            img?.attributes['data-lazy-src'] ?? img?.attributes['src'] ?? '';
        if (imgURL.isEmpty || imgURL.contains("lazyload-fallback.gif")) {
          imgURL =
              "https://www.billboard.com/wp-content/themes/vip/pmc-billboard-2021/assets/app/icons/icon-512x512.png";
        } else {
          imgURL = imgURL.replaceAll(RegExp(r'(\d+x\d+)\.jpg$'), '180x180.jpg');
        }
        chartItems
            .add(ChartItemModel(name: ttl, imageUrl: imgURL, subtitle: lbl));
      }
      final chart = ChartModel(
          chartName: url.title,
          chartItems: chartItems,
          url: url.url,
          lastUpdated: DateTime.now());
      // BloomeeDBService.putChart(chart);
      log('Billboard Charts: ${chart.chartItems!.length} tracks',
          name: "Billboard");
      return chart;
    } else {
      // final chart = await BloomeeDBService.getChart(url.title);
      // if (chart != null) {
      //   log('Billboard Charts: ${chart.chartItems!.length} tracks loaded from cache',
      //       name: "Billboard");
      //   return chart;
      // }
      throw Exception("Failed to load page");
    }
  } catch (e) {
    // final chart = await BloomeeDBService.getChart(url.title);
    // if (chart != null) {
    //   log('Billboard Charts: ${chart.chartItems!.length} tracks loaded from cache',
    //       name: "Billboard");
    //   return chart;
    // }
    log('Error while getting data from:${url.url}', name: "Billboard");
    throw Exception("Error: $e");
  }
}
