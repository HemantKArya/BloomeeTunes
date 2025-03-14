// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';

class PlaylistOnlModel {
  final String source;
  final String sourceId;
  final String name;
  final String imageURL;
  final String artists;
  final String sourceURL;
  final String? year;
  final String? description;
  final String? language;
  final Map extra;
  final List<MediaItemModel> songs;

  PlaylistOnlModel({
    required this.source,
    required this.sourceId,
    required this.name,
    required this.imageURL,
    required this.artists,
    required this.sourceURL,
    this.description,
    this.year,
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
      isAlbum: false,
      lastUpdated: DateTime.now(),
    );
  }

  PlaylistOnlModel copyWith({
    String? source,
    String? sourceId,
    String? name,
    String? imageURL,
    String? artists,
    String? sourceURL,
    String? year,
    String? description,
    String? language,
    Map? extra,
    List<MediaItemModel>? songs,
  }) {
    return PlaylistOnlModel(
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      imageURL: imageURL ?? this.imageURL,
      artists: artists ?? this.artists,
      sourceURL: sourceURL ?? this.sourceURL,
      year: year ?? this.year,
      description: description ?? this.description,
      language: language ?? this.language,
      extra: extra ?? this.extra,
      songs: songs ?? this.songs,
    );
  }

  @override
  String toString() {
    return 'PlaylistOnlModel(name: $name, imageURL: $imageURL, artists: $artists, sourceURL: $sourceURL, year: $year, description: $description, )';
  }
}

List<PlaylistOnlModel> saavnMap2Playlists(Map<String, dynamic> json) {
  List<PlaylistOnlModel> playlists = [];
  if (json['Playlists'] != null) {
    json['Playlists'].forEach((playlist) {
      playlists.add(PlaylistOnlModel(
        name: playlist['title'],
        imageURL: playlist['image'],
        sourceURL: playlist['perma_url'],
        description: playlist['subtitle'],
        artists: playlist['artist'] ?? 'Various Artists',
        source: 'saavn',
        sourceId: playlist['id'],
        year: playlist['year'],
        language: playlist['language'],
      ));
    });
  }
  return playlists;
}

List<PlaylistOnlModel> ytmMap2Playlists(List<Map> items) {
  List<PlaylistOnlModel> playlists = [];
  for (var playlist in items) {
    playlists.add(PlaylistOnlModel(
      source: "youtube",
      sourceId: playlist['playlistId'],
      name: playlist['title'],
      imageURL: playlist['thumbnail'],
      sourceURL: playlist['perma_url'],
      artists: playlist['subtitle'],
    ));
  }
  return playlists;
}

List<PlaylistOnlModel> ytvMap2Playlists(Map<String, dynamic> json) {
  List<PlaylistOnlModel> playlists = [];
  if (json['playlists'] != null) {
    json['playlists'].forEach((playlist) {
      playlists.add(PlaylistOnlModel(
        source: "youtube",
        sourceId: playlist['id'],
        name: playlist['title'],
        imageURL: playlist['image'],
        artists: "Unknown",
        sourceURL: 'https://www.youtube.com/playlist?list=${playlist['id']}',
      ));
    });
  }
  return playlists;
}
