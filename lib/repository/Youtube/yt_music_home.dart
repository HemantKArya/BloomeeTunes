import 'dart:convert';
import 'package:http/http.dart';
import 'dart:developer' as dev;
import 'ytmusic_format.dart';

String decodeEscapeSequences(String encodedString) {
  return encodedString.replaceAllMapped(RegExp(r'\\x([0-9a-fA-F]{2})'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)));
}

Future<Map<String, List>> getMusicHome({String countryCode = "IN"}) async {
  final Uri link =
      Uri.https('www.youtube.com', '/music', {'hl': 'en', 'gl': countryCode});
  try {
    final Response response = await get(link);
    if (response.statusCode != 200) {
      return {};
    }
    final String searchResults =
        RegExp(r'ytInitialData = (\{[\s\S]*?\});\s*</script>', dotAll: true)
            .firstMatch(response.body)![1]!;
    final Map data = json.decode(searchResults) as Map;
    // dev.log("data: ${json.encode(data)}", name: "YTM");
    final List result = data['contents']['twoColumnBrowseResultsRenderer']
            ['tabs'][0]['tabRenderer']['content']['richGridRenderer']
        ['contents'] as List;
    // dev.log("result: $result", name: "YTM");
    final List headResult = data['header']['carouselHeaderRenderer']['contents']
        [0]['carouselItemRenderer']['carouselItems'] as List;

    final List shelfRenderer = result.map((element) {
      return element['richSectionRenderer']['content']['richShelfRenderer'];
    }).toList();
    // dev.log("${shelfRenderer.first}", name: "YTM");
    final List finalResult = [];

    for (Map element in shelfRenderer) {
      String title = element['title']['runs'][0]['text'].trim();

      try {
        // dev.log("Inside loop: ${title}", name: "YTM");
        List playlistItems = await formatHomeSections(element['contents']);

        if (playlistItems.isNotEmpty) {
          finalResult.add({
            'title': title,
            'items': playlistItems,
          });
        } else {
          dev.log(
              "got null in getMusicHome for '${element['title']['runs'][0]['text']}'",
              name: "YTM");
        }
      } catch (e) {
        dev.log("Error inside HomeFormat getMusicHome: $e", name: "YTM");
      }
    }
    // dev.log("finalResult: $finalResult", name: "YTM");

    final List finalHeadResult = formatHeadItems(headResult);
    // dev.log("finalHeadResult: $finalHeadResult", name: "YTM");
    finalResult.removeWhere((element) => element == null);

    return {'body': finalResult, 'head': finalHeadResult};
  } catch (e) {
    dev.log('Error in getMusicHome: ', error: e, name: "YTM");
    return {};
  }
}
