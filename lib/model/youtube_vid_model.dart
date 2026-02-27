import 'song_model.dart';

MediaItemModel fromYtVidSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  return MediaItemModel(
      id: songItem["id"] ?? 'Unknown',
      title: songItem["title"] ?? 'Unknown',
      album: songItem["album"] ?? 'Unknown',
      artist: songItem["artist"] ?? 'Unknown',
      // artUri: Uri.parse(songItem["image"]),
      artUri: Uri.parse(
          "https://img.youtube.com/vi/${songItem["id"].toString().replaceAll("youtube", '')}/hqdefault.jpg"),
      genre: songItem["genre"] ?? 'Unknown',
      duration: Duration(
        seconds:
            (songItem["duration"] == "null" || songItem["duration"] == null)
                ? 120
                : int.parse(songItem["duration"]),
      ),
      extras: {
        "url": songItem["url"] ?? 'Unknown',
        "source": "youtube",
        "perma_url": songItem["perma_url"],
        "language": songItem["language"] ?? 'Unknown',
        "artistsID": songItem["album_id"]
      });
}

List<MediaItemModel> fromYtVidSongMapList2MediaItemList(
    List<dynamic> songList) {
  List<MediaItemModel> mediaList = [];
  mediaList = songList
      .map((e) => fromYtVidSongMap2MediaItem(e as Map<dynamic, dynamic>))
      .toList();
  return mediaList;
}
