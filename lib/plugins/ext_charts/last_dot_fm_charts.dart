import 'dart:developer';

import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
// import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

const List<String> lastfmIMGs = [
  "https://www.last.fm/static/images/lastfm_logo_facebook.15d8133be114.png",
  "https://pbs.twimg.com/profile_images/1090247568427110400/693K40MN_400x400.jpg",
];

const String LASTFM_TOP_20 = 'https://www.last.fm/charts';

final RandomIMGs lastfmRandomIMGs = RandomIMGs(imgURLs: lastfmIMGs);

class LastFMCharts {
  static final ChartURL TOP_TRACKS =
      ChartURL(title: "Last.fm\nTop Tracks", url: LASTFM_TOP_20);
}

Future<ChartModel> getLastFmCharts(ChartURL url) async {
  final client = http.Client();

  try {
    final response = await client.get(Uri.parse(url.url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    });

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final topTracks = document.querySelector('table.globalchart');
      final allTracks = topTracks!.querySelectorAll('tr.globalchart-item');

      // final playlist = <Map<String, String>>[];

      List<ChartItemModel> chartItems = [];

      for (final track in allTracks) {
        final artist = track
            .querySelector('td.globalchart-track-artist-name')
            ?.text
            .trim();
        final title = track.querySelector('td.globalchart-name')?.text.trim();
        final img =
            track.querySelector('td.globalchart-image img')!.attributes['src']!;

        // playlist.add({
        //   'title': title.toString(),
        //   'label': artist.toString(),
        //   'img': img
        // });
        chartItems.add(ChartItemModel(
          name: title.toString(),
          subtitle: artist.toString(),
          imageUrl: img.toString().replaceAll(RegExp(r'avatar70s'), '500x500'),
        ));
      }
      ChartModel lastfmModel = ChartModel(
          chartName: url.title,
          chartItems: chartItems,
          url: url.url,
          lastUpdated: DateTime.now());
      // BloomeeDBService.putChart(lastfmModel);
      log('Last.fm Charts: ${lastfmModel.chartItems!.length} tracks',
          name: "LastFM");

      return lastfmModel;
    } else {
      // final chart = await BloomeeDBService.getChart(url.title);
      // if (chart != null) {
      //   log('LastFM Charts: ${chart.chartItems!.length} tracks loaded from cache',
      //       name: "LastFM");
      //   return chart;
      // }
      throw Exception(
          'Failed to load page with status code: ${response.statusCode}');
    }
  } on Exception catch (e) {
    // final chart = await BloomeeDBService.getChart(url.title);
    // if (chart != null) {
    //   log('LastFM Charts: ${chart.chartItems!.length} tracks loaded from cache',
    //       name: "LastFM");
    //   return chart;
    // }
    throw Exception('Failed to parse page: $e');
  } finally {
    client.close();
  }
}
