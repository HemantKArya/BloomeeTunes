import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;
import 'package:Bloomee/model/lyrics_models.dart';

const String lrcURL = "https://lrclib.net/";
const String lrcSearch = "api/search";
const String lrcGet = "api/get";

// Main function for LRCNetAPI
Future<Lyrics> getLRCNetAPILyrics(
  String title, {
  String? artist,
  String? album,
  String? duration,
  String? id,
}) async {
  Lyrics lyrics;
  if (id != null) {
    lyrics = await getLRCNetLyricsById(id);
  } else {
    try {
      lyrics = await getLRCNetLyrics(title, artist!, album!, duration!);

      if (lyrics.lyricsSynced == null) {
        final temp =
            await searchSingleLRCNetLyrics(title, artist: artist, album: album);
        final ratio = fw.ratio(
            '${lyrics.title} ${lyrics.artist} ${lyrics.album}',
            '${temp.title} ${temp.artist}} ${temp.album}');
        if (ratio <= 90) {
          lyrics = temp;
        }
      }
    } catch (e) {
      log(e.toString(), name: "LRCNetAPI");
      lyrics =
          await searchSingleLRCNetLyrics(title, artist: artist, album: album);
    }
  }
  return lyrics;
}

Future<Lyrics> getLRCNetLyricsById(String id) async {
// [IN]
// Field	    Required	Type	  Description
// id	        true	    number	ID of the lyrics record

// [OUT]
// {
//   "id": 3396226,
//   "trackName": "I Want to Live",
//   "artistName": "Borislav Slavov",
//   "albumName": "Baldur's Gate 3 (Original Game Soundtrack)",
//   "duration": 233,
//   "instrumental": false,
//   "plainLyrics": "I feel your breath upon my neck\n...The clock won't stop and this is what we get\n",
//   "syncedLyrics": "[00:17.12] I feel your breath upon my neck\n...[03:20.31] The clock won't stop and this is what we get\n[03:25.72] "
// }

  final response = await http.get(Uri.parse("$lrcURL$lrcGet/$id"));
  log("LRCLibNet by ID: $id", name: "LRCNetAPI");
  if (response.statusCode == 200) {
    // decode json object response body to map
    final responseUTF = utf8.decode(response.bodyBytes);
    final data = json.decode(responseUTF);

    return Lyrics(
        artist: data['artistName'],
        title: data['trackName'],
        lyricsPlain: data['plainLyrics'],
        lyricsSynced: data["syncedLyrics"],
        id: data['id'].toString(),
        album: data['albumName'],
        duration: data['duration'].toString(),
        provider: LyricsProvider.lrcnet);
  } else {
    throw const HttpException("Failed to get lyrics");
  }
}

Future<Lyrics> getLRCNetLyrics(
    String title, String artist, String album, String duration) async {
// [IN]
// Field	      Required	Type	  Description
// track_name	  true	    string	Title of the track
// artist_name	true	    string	Name of the artist
// album_name	  true	    string	Name of the album
// duration	    true	    number	Track's duration in seconds

// [OUT]
// {
//   "id": 3396226,
//   "trackName": "I Want to Live",
//   "artistName": "Borislav Slavov",
//   "albumName": "Baldur's Gate 3 (Original Game Soundtrack)",
//   "duration": 233,
//   "instrumental": false,
//   "plainLyrics": "I feel your breath upon my neck\n...The clock won't stop and this is what we get\n",
//   "syncedLyrics": "[00:17.12] I feel your breath upon my neck\n...[03:20.31] The clock won't stop and this is what we get\n[03:25.72] "
// }

  log("LRCLibNet by Title/GET: $title", name: "LRCNetAPI");

  final response = await http.get(Uri.parse(
      "$lrcURL$lrcGet?track_name=$title&artist_name=$artist&album_name=$album&duration=$duration"));

  if (response.statusCode == 200) {
    // decode json object response body to map
    final responseUTF = utf8.decode(response.bodyBytes);
    final data = json.decode(responseUTF);

    return Lyrics(
        artist: data['artistName'],
        title: data['trackName'],
        lyricsPlain: data['plainLyrics'],
        lyricsSynced: data["syncedLyrics"],
        id: data['id'].toString(),
        album: data['albumName'],
        duration: data['duration'].toString(),
        provider: LyricsProvider.lrcnet);
  } else {
    throw const HttpException("Failed to get lyrics");
  }
}

Future<List<Lyrics>> searchLRCNetLyrics(
  String q, {
  String? trackName,
  String? artistName,
  String? albumName,
}) async {
// [IN]
//   Field	    Required	    Type	  Description
//    q	        conditional	  string	Search for keyword present in ANY fields (track's title, artist name or album name)
// track_name	  conditional	  string	Search for keyword in track's title
// artist_name	false	        string	Search for keyword in track's artist name
// album_name	  false	        string	Search for keyword in track's album name

// [OUT]
// JSON array of the lyrics records with the following parameters:
// id, trackName, artistName, albumName, duration, instrumental,
// plainLyrics and syncedLyrics.

  log("LRCLibNet by Search: $q", name: "LRCNetAPI");

  final String fields = (trackName != null ? "track_name=$trackName" : "") +
      (artistName != null ? "&artist_name=$artistName" : "");

  q = "$q $artistName $albumName".replaceAll(" ", "%20");

  final response = await http.get(Uri.parse("$lrcURL$lrcSearch?q=$q&$fields"));

  if (response.statusCode == 200) {
    // decode json object response body to map
    final resUTF = utf8.decode(response.bodyBytes);
    final data = json.decode(resUTF);

    return List<Lyrics>.from(data.map((lyrics) => Lyrics(
        artist: lyrics['artistName'],
        title: lyrics['trackName'],
        lyricsPlain: lyrics['plainLyrics'] ?? "No Lyrics Found!",
        lyricsSynced: lyrics["syncedLyrics"],
        id: lyrics['id'].toString(),
        album: lyrics['albumName'],
        duration: lyrics['duration'].toString(),
        provider: LyricsProvider.lrcnet)));
  } else {
    throw const HttpException("Failed to get lyrics");
  }
}

Future<Lyrics> searchSingleLRCNetLyrics(
  String q, {
  String? track,
  String? artist,
  String? album,
}) async {
  log("LRCLibNet by Search Single: $q", name: "LRCNetAPI");
  Lyrics lyrics;
  Lyrics? _synced;
  final List<Lyrics> lyricsList =
      await searchLRCNetLyrics(q, artistName: artist, albumName: album);

  if (lyricsList.isNotEmpty) {
    String query = '$q $artist';
    if (album != null) {
      query += ' $album';
    }
    final List<Lyrics> _syncedList =
        lyricsList.where((element) => element.lyricsSynced != null).toList();

    if (_syncedList.isNotEmpty) {
      _synced = _syncedList[fw
          .extractOne(
              query: query,
              choices: _syncedList.map((e) {
                return '${e.title} ${e.artist} ${e.album}';
              }).toList())
          .index];

      // log('Synced: ${_synced.toString()}', name: "LRCNetAPI");
    }
    lyrics = lyricsList[fw
        .extractOne(
            query: query,
            choices: lyricsList.map((e) {
              // log('${e.title} ${e.artist} ${e.album}', name: "LRCNetAPI");
              return '${e.title} ${e.artist} ${e.album}';
            }).toList())
        .index];
    if (_synced != null) {
      final _ratio = fw.ratio(
          '${_synced.title} ${_synced.artist} ${_synced.album}',
          '${lyrics.title} ${lyrics.artist} ${lyrics.album}');
      if (_ratio >= 80) {
        lyrics = _synced;
        // log("Ratio: $_ratio - $lyrics", name: "LRCNetAPI");
      }
    }
  } else {
    throw const HttpException("Failed to get lyrics");
  }
  return lyrics;
}
