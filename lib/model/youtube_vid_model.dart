import 'songModel.dart';

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
      extras: {
        "url": 'Unknown',
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


// {id: WGgOSfDX1Wo,
//  album: OSR Digital,
// duration: 262,
// title: MG Rodaima - "Hajar Juni Samma" Movie Song || Swastima, Salon, Akhilesh || Rajan Raj, Melina Rai, 
// artist: OSR Digital, 
// image: https://img.youtube.com/vi/WGgOSfDX1Wo/maxresdefault.jpg, 
// secondImage: https://img.youtube.com/vi/WGgOSfDX1Wo/hqdefault.jpg, 
// language: YouTube, 
// genre: YouTube, 
// expire_at: 0, 
// url: , 
// lowUrl: , 
// highUrl: , 
// year: 2019, 
// 320kbps: false, 
// has_lyrics: false, 
// release_date: null, 
// album_id: UCxCoea3ulOukfXiYAm87ZIA, 
// subtitle: OSR Digital, 
// perma_url: https://www.youtube.com/watch?v=WGgOSfDX1Wo}
