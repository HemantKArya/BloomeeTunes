import 'dart:developer';

import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

class MixedAPI {
  bool selectBestString(String source, String first, String second) {
    final int a = fw.ratio(source, first);
    final int b = fw.ratio(source, second);
    log("Confidence for string-1($first): $a and string-2($second): $b",
        name: "MixedAPI");
    return (b > a) ? false : true;
  }

  Future<MediaItemModel?> getTrackMixed(String songName) async {
    final ytItems = await YtMusicService().search(songName, filter: "songs");
    // log(ytItems.toString());
    final jsItems = await SaavnAPI()
        .fetchSongSearchResults(searchQuery: songName, count: 2);
    String? ytTitle;
    String? jsTitle;
    var jsItem;
    var ytItem;
    int idx = 0;
    if (ytItems.isNotEmpty) {
      ytItem = ytItems[0]["items"][0];

      ytTitle = "${ytItem!['title']} ${ytItem['artist']}";
    }
    if (jsItems["songs"].isNotEmpty) {
      List<String> titles = (jsItems['songs'] as List)
          .map((e) => "${e['title']} ${e['artist']}")
          .toList();
      idx = fw.extractOne(query: songName, choices: titles).index;
      // log("${jsItems.toString()}");
      jsItem = jsItems['songs'][idx];
      jsTitle = "${jsItem!['title']} ${jsItem['artist']}";
    }
    if (jsTitle != null && ytTitle != null) {
      final slct = selectBestString(
          songName, jsTitle.trim().toLowerCase(), ytTitle.trim().toLowerCase());
      log(slct ? "$jsTitle from JIOSaavn" : "$ytTitle from Youtube",
          name: "MixedAPI");
      return slct
          ? fromSaavnSongMap2MediaItem(jsItem!)
          : fromYtSongMap2MediaItem(ytItem!);
    } else {
      if (jsTitle != null) {
        return fromSaavnSongMap2MediaItem(jsItem!);
      } else {
        return fromYtSongMap2MediaItem(ytItem!);
      }
    }
  }
}
