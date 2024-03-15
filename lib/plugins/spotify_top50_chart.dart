import 'dart:convert';
import 'package:Bloomee/plugins/chart_defines.dart';
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

Future<List<Map<String, String>>> getSpotifyTop50Chart(
    {String url =
        "https://charts-spotify-com-service.spotify.com/public/v0/charts"}) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Map<String, String>> playlist = [];
      for (var item in data['chartEntryViewResponses'][0]['entries']) {
        playlist.add({
          "title": item['trackMetadata']['trackName'],
          "label": item['trackMetadata']['artists'][0]['name'],
          "img": item['trackMetadata']['displayImageUri']
        });
      }
      return playlist;
    } else {
      throw Exception('Failed to load chart');
    }
  } catch (e) {
    throw Exception('Something went wrong while parsing the page');
  }
}
