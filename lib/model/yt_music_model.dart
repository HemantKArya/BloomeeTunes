import 'songModel.dart';

MediaItemModel fromYtSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  String artists = '';
  List<String> _artists = List.empty(growable: true);
  List<String> artistsID = List.empty(growable: true);

  try {
    (songItem['artists'] as List).forEach((element) {
      _artists.add(element["name"]);
      artistsID.add(element["id"]);
    });
    artists = _artists.join(',');
  } catch (e) {
    artists = songItem["artist"] ?? 'Unknown';
  }
  return MediaItemModel(
      id: songItem["id"] ?? 'Unknown',
      title: songItem["title"] ?? 'Unknown',
      album: songItem["album"] ?? 'Unknown',
      artist:
          (songItem['artist'] == null || (songItem['artist'] as String).isEmpty)
              ? artists
              : songItem['artist'],
      artUri: Uri.parse(songItem["image"]),

      // artUri: Uri.parse(
      //     "https://img.youtube.com/vi/${songItem["id"].toString().replaceAll("youtube", '')}/hqdefault.jpg"),
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
        "source": "youtube",
        "perma_url":
            'https://www.youtube.com/watch?v=${songItem["id"].toString().replaceAll("youtube", '')}',
        "language": songItem["language"] ?? 'Unknown',
        "artistsID": artistsID
      });
}

List<MediaItemModel> fromYtSongMapList2MediaItemList(List<dynamic> songList) {
  List<MediaItemModel> mediaList = [];
  mediaList = songList
      .map((e) => fromYtSongMap2MediaItem(e as Map<dynamic, dynamic>))
      .toList();
  return mediaList;
}

MediaItemModel ytmMap2MediaItem(Map song) {
  return MediaItemModel(
      id: song["videoId"],
      title: song["title"],
      album: song["album"],
      artist: song["artists"],
      artUri: Uri.parse(song["thumbnail"]),
      genre: song["type"],
      duration: Duration(seconds: int.parse(song["duration"])),
      extras: {
        "url": song["perma_url"],
        "source": "youtube",
        "perma_url": song["perma_url"],
        "subtitle": song["subtitle"],
        "artists_map": song["artists_map"]
      });
}

List<MediaItemModel> ytmMapList2MediaItemList(List songList) {
  List<MediaItemModel> mediaList = [];
  mediaList = songList.map((e) => ytmMap2MediaItem(e)).toList();
  return mediaList;
}
