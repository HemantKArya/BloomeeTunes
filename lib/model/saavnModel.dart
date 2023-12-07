import 'package:Bloomee/model/songModel.dart';

MediaItemModel fromSaavnSongMap2MediaItem(Map<dynamic, dynamic> songItem) {
  return MediaItemModel(
      id: songItem["id"] ?? 'Unknown',
      title: songItem["title"] ?? 'Unknown',
      album: songItem["album"] ?? 'Unknown',
      artist: songItem["artist"] ?? 'Unknown',
      artUri: Uri.parse(songItem["image"]),
      genre: songItem["genre"] ?? 'Unknown',
      extras: {
        "url": songItem["url"] ?? 'Unknown',
        "source": "",
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



// {id: w8LT2jNx,
//  type: , 
//  album: Border, 
//  year: 1999, 
//  duration: 631, 
//  language: Hindi, 
//  genre: Hindi, 
//  320kbps: true, 
//  has_lyrics: true, 
//  lyrics_snippet: Ke ghar kab aaoge? Ke ghar kab aaoge?, 
//  release_date: null, 
//  album_id: [albumid], 
//  title: Sandese Aate Hain, 
//  artist: Anu Malik, Sonu Nigam, Roopkumar Rathod, 
//  image: https://c.saavncdn.com/843/Border-Hindi-1999-20210226141923-500x500.jpg, 
//  perma_url: https://www.jiosaavn.com/song/sandese-aate-hain/B1AnZUZaeUs, 
//  url: https://aac.saavncdn.com/869/ec5e8de3ce4716c1bc1d3bc5fd247b1c_96.mp4
//  }