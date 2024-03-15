import 'package:Bloomee/plugins/chart_defines.dart';
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

Future<List<Map<String, String>>> getLastFmCharts(
    {String url = "https://www.last.fm/charts"}) async {
  final client = http.Client();

  try {
    final response = await client.get(Uri.parse(url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    });

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final topTracks = document.querySelector('table.globalchart');
      final allTracks = topTracks!.querySelectorAll('tr.globalchart-item');

      final playlist = <Map<String, String>>[];

      for (final track in allTracks) {
        final artist = track
            .querySelector('td.globalchart-track-artist-name')
            ?.text
            .trim();
        final title = track.querySelector('td.globalchart-name')?.text.trim();
        final img =
            track.querySelector('td.globalchart-image img')!.attributes['src']!;

        playlist.add({
          'title': title.toString(),
          'label': artist.toString(),
          'img': img
        });
      }

      return playlist;
    } else {
      throw Exception(
          'Failed to load page with status code: ${response.statusCode}');
    }
  } on Exception catch (e) {
    throw Exception('Failed to parse page: $e');
  } finally {
    client.close();
  }
}
