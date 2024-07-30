import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
// import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart' as http;

const List<String> spotifyIMGs = [
  "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/folder_920_201707260845-1.png",
  "https://play-lh.googleusercontent.com/cShys-AmJ93dB0SV8kE6Fl5eSaf4-qMMZdwEDKI5VEmKAXfzOqbiaeAsqqrEBCTdIEs",
  "https://charts-images.scdn.co/assets/locale_en/regional/daily/region_global_default.jpg",
];

final RandomIMGs spotifyRandomIMGs = RandomIMGs(imgURLs: spotifyIMGs);

class SpotifyChartsLinks {
  static const String TOP_50 =
      'https://charts-spotify-com-service.spotify.com/public/v0/charts';
}

class SpotifyCharts {
  static final ChartURL TOP_50 =
      ChartURL(title: "Spotify\nTop 50 Global", url: SpotifyChartsLinks.TOP_50);
}

Future<ChartModel> getSpotifyTop50Chart(ChartURL url) async {
  try {
    final response = await http.get(Uri.parse(url.url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<ChartItemModel> chartItems = [];
      for (var item in data['chartEntryViewResponses'][0]['entries']) {
        chartItems.add(ChartItemModel(
          name: item['trackMetadata']['trackName'],
          subtitle: item['trackMetadata']['artists'][0]['name'],
          imageUrl: item['trackMetadata']['displayImageUri'],
        ));
      }
      final chart = ChartModel(
        chartName: url.title,
        chartItems: chartItems,
        url: url.url,
        lastUpdated: DateTime.now(),
      );
      // BloomeeDBService.putChart(chart);
      log('Spotify Charts: ${chart.chartItems!.length} tracks',
          name: "Spotify");
      return chart;
    } else {
      // final chart = await BloomeeDBService.getChart(url.title);
      // if (chart != null) {
      //   log('Spotify Charts: ${chart.chartItems!.length} tracks loaded from cache',
      //       name: "Spotify");
      //   return chart;
      // }
      throw Exception('Failed to load chart');
    }
  } catch (e) {
    // final chart = await BloomeeDBService.getChart(url.title);
    // if (chart != null) {
    //   log('Spotify Charts: ${chart.chartItems!.length} tracks loaded from cache',
    //       name: "Spotify");
    //   return chart;
    // }
    throw Exception('Something went wrong while parsing the page');
  }
}
