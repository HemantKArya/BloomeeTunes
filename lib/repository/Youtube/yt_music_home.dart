import 'dart:convert';
import 'package:http/http.dart' as http;

String decodeEscapeSequences(String encodedString) {
  return encodedString.replaceAllMapped(RegExp(r'\\x([0-9a-fA-F]{2})'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)));
}

Future<List<dynamic>> fetchMusicData() async {
  final client = http.Client();
  final headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Sec-Ch-Ua':
        '"Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': '"Windows"',
  };

  final response = await client.get(Uri.parse('https://music.youtube.com/'),
      headers: headers);
  if (response.statusCode == 200) {
    final html = response.body;
    final pattern = RegExp(r"data:\s*'\\x7b(.*?)'");
    final matches = pattern.allMatches(html);
    if (matches.isNotEmpty) {
      final encodedString =
          r'\x7b'.toString() + matches.first.group(1).toString();
      final decodedBytes =
          utf8.decode(decodeEscapeSequences(encodedString).codeUnits);

      final Map<String, dynamic> data = jsonDecode(decodedBytes);
      // log(data.keys.toString(), name: "YT Music Home Data Keys");
      final items = [];
      final contents = data['contents']['singleColumnBrowseResultsRenderer']
              ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'][0]['musicCarouselShelfRenderer']['contents'];

      for (var content in contents) {
        final img = content['musicResponsiveListItemRenderer']['thumbnail']
            ['musicThumbnailRenderer']["thumbnail"]["thumbnails"][0]["url"];
        final title = content['musicResponsiveListItemRenderer']['flexColumns']
                [0]['musicResponsiveListItemFlexColumnRenderer']["text"]["runs"]
            [0]["text"];
        final watchid = content['musicResponsiveListItemRenderer']
                    ['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']["text"]["runs"][0]
            ["navigationEndpoint"]["watchEndpoint"]["videoId"];
        final playlistid = content['musicResponsiveListItemRenderer']
                    ['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']["text"]["runs"][0]
            ["navigationEndpoint"]["watchEndpoint"]["playlistId"];
        var artists = '';
        for (var artist in content['musicResponsiveListItemRenderer']
                ['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ["text"]["runs"]) {
          artists += artist["text"];
        }
        items.add({
          "title": title,
          "img": img,
          "watchid": watchid,
          "playlistid": playlistid,
          "artists": artists
        });
      }

      return items;
    }
  }

  throw Exception('Failed to load');
}
