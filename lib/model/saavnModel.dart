import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';

MediaItemModel fromSaavnSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  return MediaItemModel(
      id: songItem["id"] ?? 'Unknown',
      title: songItem["title"] ?? 'Unknown',
      album: songItem["album"] ?? 'Unknown',
      artist: songItem["artist"] ?? 'Unknown',
      artUri: Uri.parse(songItem["image"]),
      genre: songItem["genre"] ?? 'Unknown',
      duration: Duration(
        seconds: (songItem["duration"] == "null" ||
                songItem["duration"] == null ||
                songItem["duration"] == "")
            ? 120
            : int.parse(songItem["duration"]),
      ),
      extras: {
        "url": songItem["url"] ?? 'Unknown',
        "source": "saavn",
        "perma_url": songItem["perma_url"] ?? 'Unknown',
        "language": songItem["language"] ?? 'Unknown',
      });
}

List<MediaItemModel> fromSaavnSongMapList2MediaItemList(
    List<dynamic> songList) {
  List<MediaItemModel> mediaList = [];
  mediaList = songList
      .map((e) => fromSaavnSongMap2MediaItem(e as Map<dynamic, dynamic>))
      .toList();
  return mediaList;
}

Future<String?> getJsQualityURL(String url, {bool isStreaming = true}) async {
  String ops =
      isStreaming ? GlobalStrConsts.strmQuality : GlobalStrConsts.downQuality;
  String? kUrl;
  await BloomeeDBService.getSettingStr(ops).then((value) {
    switch (value) {
      case "96 kbps":
        kUrl = url;
      case "160 kbps":
        kUrl = url.replaceAll('_96', '_160').replaceAll('_320', '_160');
      case "320 kbps":
        kUrl = url.replaceAll('_96', '_320').replaceAll('_160', '_320');
      default:
        kUrl = url.replaceAll('_160', '_96').replaceAll('_320', '_96');
    }
  });
  return kUrl;
}
