import 'package:Bloomee/model/songModel.dart';

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
