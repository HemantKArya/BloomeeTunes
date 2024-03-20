import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<List<Map<String, dynamic>>>> fetchTrendingVideos() async {
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
        "gl": "AR",
        "experimentIds": [],
        "experimentsToken": "",
        "theme": "MUSIC"
      },
      "capabilities": {},
      "request": {"internalExperimentFlags": []}
    },
    "browseId": "FEmusic_analytics_charts_home",
    "query": "perspective=CHART_HOME&chart_params_country_code=global"
  };

  // Make the POST request
  response = await http.post(
    Uri.parse(
        'https://charts.youtube.com/youtubei/v1/browse?alt=json&key=$apiKey'),
    headers: headers,
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    // Parse the JSON response
    // return json.decode(response.body);
    List<dynamic> data = json.decode(response.body)["contents"]
            ['sectionListRenderer']["contents"][0]
        ['musicAnalyticsSectionRenderer']['content']['videos'];

    List<List<Map<String, dynamic>>> playlists = [];

    for (var types in data) {
      List<Map<String, dynamic>> playlist = [];
      for (var i in types['videoViews']) {
        String title = i['title'];
        String views = i['viewCount'];
        String id = i['id'];
        String img = i['thumbnail']['thumbnails'][0]['url'];
        List<String> artists = [];
        for (var artist in i['artists']) {
          artists.add(artist['name']);
        }
        playlist.add({
          'title': title,
          'views': views,
          'id': id,
          'img': img,
          'artists': artists
        });
      }
      playlists.add(playlist);
    }
    return playlists;
  } else {
    throw Exception('Failed to load data: ${response.statusCode}');
  }
}
