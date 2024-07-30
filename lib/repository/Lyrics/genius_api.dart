import 'dart:convert';
import 'dart:developer';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:Bloomee/model/lyrics_models.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

Future<LyricsSearchResults> searchGeniusLyrics(
    String title, String artist) async {
  LyricsSearchResults results = LyricsSearchResults(
      lyrics: List.empty(growable: true), query: '$title by $artist');

  await searchGenius("$title $artist", 1).then((value) async {
    // log(value.toString(), name: "Genius API");
    if (value.isNotEmpty) {
      int? idx = fw
          .extractOne(
              query: title,
              choices: value.map((e) => e['title'].toString()).toList())
          .index;
      Lyrics _lyrics = Lyrics(
          artist: value[idx]['artist'] ?? "",
          title: value[idx]['title'] ?? "",
          lyrics: "lyrics",
          img: value[idx]['image'] ?? "",
          id: value[idx]['id'].toString(),
          url: value[idx]['path'] ?? "",
          provider: LyricsProvider.genius);

      await geniusTrackLyrics(value[idx]['path']).then((lyrics) {
        _lyrics = Lyrics(
            artist: value[idx]['artist'] ?? "",
            title: value[idx]['title'] ?? "",
            lyrics: lyrics,
            img: value[idx]['image'] ?? "",
            id: value[idx]['id'].toString(),
            url: value[idx]['path'] ?? "",
            provider: LyricsProvider.genius);
      });
      results.lyrics!.add(_lyrics);
    } else {
      if (artist.isNotEmpty) {
        log("Researching results found for $title by $artist",
            name: "Genius API");
        LyricsSearchResults _t = await searchGeniusLyrics(title, "");
        if (_t.lyrics!.isNotEmpty) {
          log("Results found for $title by $artist", name: "Genius API");
          results.lyrics!.addAll(_t.lyrics!);
        } else {
          log("No results found again for $title by $artist",
              name: "Genius API");
        }
      }
    }
  });
  return results;
}

Future<List<Map<String, dynamic>>> searchGenius(
    String searchQuery, int page) async {
  log("searching for $searchQuery", name: "Genius API");
  final url =
      'https://genius.com/api/search/song?page=${page}&q=${searchQuery.replaceAll(' ', '+')}';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    final songs = data['response']['sections'][0]['hits'];

    return songs.map<Map<String, dynamic>>((i) {
      return {
        'id': i['result']['id'],
        'title': i['result']['title'],
        'artist': i['result']['artist_names'],
        'image': i['result']['header_image_thumbnail_url'],
        'path': i['result']['path']
      };
    }).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

Future<String> geniusTrackLyrics(String path) async {
  final response = await http.get(Uri.parse("https://genius.com$path"));

  if (response.statusCode == 200) {
    final document = parser.parse(utf8.decode(response.bodyBytes));
    final lyricsElements =
        document.querySelectorAll('div[data-lyrics-container="true"]');

    final lyrics = lyricsElements.map((element) {
      // replace all <br>, <br/>, <br /> tags from element with new line
      element.querySelectorAll('br').forEach((br) {
        br.replaceWith(dom.Text('\n'));
      });
      return element.text;
    }).join('\n');

    return lyrics;
  } else {
    throw Exception('Failed to load lyrics');
  }
}
