// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';

class AlbumModel {
  String name;
  String imageURL;
  String source;
  String sourceId;
  String artists;
  String? year;
  String? genre;
  String? country;
  String sourceURL;
  String? description;
  String? language;
  Map extra = {};
  List<MediaItemModel> songs = [];

  AlbumModel({
    required this.name,
    required this.imageURL,
    required this.source,
    required this.sourceId,
    required this.artists,
    this.year,
    required this.sourceURL,
    this.genre,
    this.country,
    this.description,
    this.language,
    this.extra = const {},
    this.songs = const [],
  });

  get playlist {
    return MediaPlaylist(
      playlistName: name,
      source: source,
      permaURL: sourceURL,
      imgUrl: imageURL,
      mediaItems: songs,
      artists: artists,
      description: description,
      isAlbum: true,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AlbumModel(name: $name, imageURL: $imageURL, source: $source, sourceId: $sourceId, artists: $artists, year: $year, sourceURL: $sourceURL, extra: $extra)';
  }

  AlbumModel copyWith({
    String? name,
    String? imageURL,
    String? source,
    String? sourceId,
    String? artists,
    String? year,
    String? genre,
    String? country,
    String? sourceURL,
    String? description,
    String? language,
    List<MediaItemModel>? songs,
    Map? extra,
  }) {
    return AlbumModel(
      name: name ?? this.name,
      imageURL: imageURL ?? this.imageURL,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      artists: artists ?? this.artists,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      country: country ?? this.country,
      sourceURL: sourceURL ?? this.sourceURL,
      description: description ?? this.description,
      language: language ?? this.language,
      songs: songs ?? this.songs,
      extra: extra ?? this.extra,
    );
  }
}

List<AlbumModel> saavnMap2Albums(Map<String, dynamic> json) {
  List<AlbumModel> albums = [];
  if (json['Albums'] != null) {
    json['Albums'].forEach((album) {
      albums.add(AlbumModel(
          name: album['title'],
          imageURL: album['image'],
          source: 'saavn',
          sourceId: album['id'],
          artists: (album['artist']?.toString() ??
                  album['album_artist']?.toString()) ??
              '',
          year: album['year'],
          sourceURL: album['perma_url'],
          genre: album['genre'],
          country: album['country'],
          description: album['subtitle'],
          extra: {
            'token': album['token'],
          }));
    });
  }
  return albums;
}

List<AlbumModel> ytmMap2Albums(List<Map> items) {
  List<AlbumModel> albums = [];
  for (var item in items) {
    try {
      albums.add(AlbumModel(
        name: item['title'],
        imageURL: item['thumbnail'],
        source: 'youtube',
        sourceId: item['browseId'],
        artists: item['artists'],
        sourceURL: item['perma_url'],
        description: item['subtitle'],
      ));
    } catch (e) {
      print(e);
    }
  }
  return albums;
}
