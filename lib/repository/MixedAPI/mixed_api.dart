import 'dart:developer';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;
import 'package:fuzzywuzzy/ratios/partial_ratio.dart';
import 'package:fuzzywuzzy/ratios/simple_ratio.dart';

class MixedAPI {
  bool selectBestString(String source, String first, String second) {
    final int a = fw.ratio(source, first);
    final int b = fw.ratio(source, second);
    log("Confidence for string-1($first): $a and string-2($second): $b",
        name: "MixedAPI");
    return (b > a) ? false : true;
  }

  Future<MediaItemModel?> getYtTrackByMeta(String songName,
      {useStringMatcher = true}) async {
    final ytItems = await YTMusic().searchYtm(songName, type: "songs");
    if (ytItems == null) return null;
    List<MediaItemModel> mediaItems =
        ytmMapList2MediaItemList(ytItems['songs'] as List);
    if (mediaItems.length == 1) {
      return mediaItems[0];
    }
    if (mediaItems.isNotEmpty) {
      if (useStringMatcher) {
        if (mediaItems.length > 2) {
          mediaItems = mediaItems.sublist(0, 2);
        }
        List<String> titles = List.empty(growable: true);
        for (var item in mediaItems) {
          titles.add("${item.title} ${item.artist}".trim());
        }
        final r1 = fw
            .extractOne(
              query: songName,
              choices: titles,
              ratio: PartialRatio(),
            )
            .score;
        final r2 = fw
            .extractOne(
              query: songName,
              choices: titles,
              ratio: SimpleRatio(),
            )
            .score;

        final idx = (r1 > r2)
            ? fw
                .extractOne(
                  query: songName,
                  choices: titles,
                  ratio: PartialRatio(),
                )
                .index
            : fw
                .extractOne(
                  query: songName,
                  choices: titles,
                  ratio: SimpleRatio(),
                )
                .index;
        log(fw.partialRatio(songName, titles[idx]).toString(),
            name: "MixedAPI");
        log(fw.ratio(songName, titles[idx]).toString(), name: "MixedAPI");
        if (fw.ratio(songName.trim(), titles[idx]) > 80 ||
            fw.partialRatio(songName.trim(), titles[idx]) > 80) {
          return mediaItems[idx];
        }
      } else {
        return mediaItems[0];
      }
    }
    return null;
  }

  Future<MediaItemModel?> getTrackMixed(String songName) async {
    final ytItems = await YTMusic().searchYtm(songName, type: "songs");
    // log(ytItems.toString());
    final jsItems = await SaavnAPI()
        .fetchSongSearchResults(searchQuery: songName, count: 2);
    String? ytTitle;
    String? jsTitle;

    if (ytItems == null &&
        ytItems?['songs'].isEmpty &&
        (jsItems.isEmpty || jsItems['songs'].toList().isEmpty)) {
      log("No results found!", name: "MixedAPI");
      return null;
    }

    var jsItem;
    var ytItem;
    int idx = 0;
    if (ytItems != null && ytItems["songs"].isNotEmpty) {
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
