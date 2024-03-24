import 'dart:developer';

import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<ChartModel>> fetchTrendingVideos() async {
  // Fetch the YouTube page to extract the INNERTUBE_API_KEY
  var response = await http
      .get(Uri.parse('https://charts.youtube.com/charts/TrendingVideos/gb'));
  final keyRegex = RegExp(r'"INNERTUBE_API_KEY"\s*:\s*"(.*?)"');
  final apiKey = keyRegex.firstMatch(response.body)?.group(1);

  if (apiKey == null) {
    throw Exception('Failed to extract INNERTUBE_API_KEY');
  }

  // Prepare the headers and data for the POST request
  final headers = {
    'referer': 'https://charts.youtube.com/charts/TrendingVideos/gb',
  };

  final data = {
    "context": {
      "client": {
        "clientName": "WEB_MUSIC_ANALYTICS",
        "clientVersion": "2.0",
        "hl": "en",
        "gl": "IN",
        "experimentIds": [],
        "experimentsToken": "",
        "theme": "MUSIC"
      },
      "capabilities": {},
      "request": {"internalExperimentFlags": []}
    },
    "browseId": "FEmusic_analytics_charts_home",
    "query":
        "perspective=CHART_DETAILS&chart_params_country_code=global&chart_params_chart_type=TRACKS&chart_params_period_type=WEEKLY"
    // "query": "perspective=CHART_HOME&chart_params_country_code=global"
  };

  // Make the POST request
  response = await http.post(
    Uri.parse(
        'https://charts.youtube.com/youtubei/v1/browse?alt=json&key=$apiKey'),
    headers: headers,
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    // List<dynamic> data = json.decode(response.body)["contents"]
    //         ['sectionListRenderer']["contents"][0]
    //     ['musicAnalyticsSectionRenderer']['content']['videos'];
    List<dynamic> data = json.decode(response.body)["contents"]
                ['sectionListRenderer']["contents"][0]
            ['musicAnalyticsSectionRenderer']['content']['trackTypes'][0]
        ["trackViews"];

    // List<List<Map<String, dynamic>>> playlists = [];
    List<ChartItemModel> chartItems = [];
    List<ChartModel> chartModels = [];

    // for (var types in data) {
    chartItems = [];
    String img;
    for (var i in data) {
      String title = i['name'];
      // String views = i['viewCount'];
      // String id = i['id'];
      try {
        img = i['thumbnail']['thumbnails'][0]['url'];
      } catch (e) {
        img = "null";
      }
      List<String> artists = [];
      try {
        for (var artist in i['artists']) {
          artists.add(artist['name']);
        }
      } catch (e) {
        artists.add("Unknown");
      }

      chartItems.add(ChartItemModel(
          name: title, subtitle: artists.join(", "), imageUrl: img));
    }
    chartModels.add(ChartModel(
      chartName: "Trending Videos",
      chartItems: chartItems,
      url: "https://charts.youtube.com/youtubei/v1/browse?alt=json&key=",
      lastUpdated: DateTime.now(),
    ));
    // }
    BloomeeDBService.putChart(chartModels[0]);
    log("Trending Charts: ${chartModels[0].chartItems?.length} items loaded",
        name: "Trending YT Charts");
    return chartModels;
  } else {
    final chart = await BloomeeDBService.getChart("Trending Videos");
    if (chart != null) {
      log("Trending Charts: ${chart.chartItems?.length} items loaded from cache",
          name: "Trending YT Charts");
      return [chart];
    }
    throw Exception('Failed to load data: ${response.statusCode}');
  }
}
