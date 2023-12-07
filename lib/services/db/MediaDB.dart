// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:js_util';

import 'package:isar/isar.dart';

part 'MediaDB.g.dart';

@collection
class MediaPlaylistDB {
  Id get isarId => fastHash(playlistName);
  String playlistName;
  List<int> mediaRanks = List.empty(growable: true);
  MediaPlaylistDB({
    required this.playlistName,
  });
  @Backlink(to: "mediaInPlaylistsDB")
  IsarLinks<MediaItemDB> mediaItems = IsarLinks<MediaItemDB>();

  @override
  bool operator ==(covariant MediaPlaylistDB other) {
    if (identical(this, other)) return true;

    return other.playlistName == playlistName;
  }

  @override
  int get hashCode => playlistName.hashCode;
}

@collection
class MediaItemDB {
  Id? id = Isar.autoIncrement;
  @Index()
  String title;
  String album;
  String artist;
  String artURL;
  String genre;

  String mediaID;
  String streamingURL;
  String? source;
  String permaURL;
  String language;
  bool isLiked = false;

  // @Backlink(to: "mediaItems")
  IsarLinks<MediaPlaylistDB> mediaInPlaylistsDB = IsarLinks<MediaPlaylistDB>();

  // void setLike(bool isliked) {
  //   if (isliked != isLiked) {
  //     isLiked = isliked;
  //     print("object1");
  //     if (isLiked == true) {
  //       print("object2");
  //       if (!mediaInPlaylistsDB
  //           .contains(MediaPlaylistDB(playlistName: "Liked"))) {
  //         print("object3");
  //         mediaInPlaylistsDB.add(MediaPlaylistDB(playlistName: "Liked"));
  //       }
  //     } else {
  //       if (mediaInPlaylistsDB
  //           .contains(MediaPlaylistDB(playlistName: "Liked"))) {
  //         print("object2.5");
  //         mediaInPlaylistsDB.remove(MediaPlaylistDB(playlistName: "Liked"));
  //       }
  //     }
  //   }
  // }

  MediaItemDB({
    this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.artURL,
    required this.genre,
    required this.mediaID,
    required this.streamingURL,
    this.source,
    required this.permaURL,
    required this.language,
    required this.isLiked,
  });

  @override
  bool operator ==(covariant MediaItemDB other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.album == album &&
        other.artist == artist &&
        other.artURL == artURL &&
        other.genre == genre &&
        other.mediaID == mediaID &&
        other.streamingURL == streamingURL &&
        other.source == source &&
        other.permaURL == permaURL &&
        other.language == language;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        album.hashCode ^
        artist.hashCode ^
        artURL.hashCode ^
        genre.hashCode ^
        mediaID.hashCode ^
        streamingURL.hashCode ^
        source.hashCode ^
        permaURL.hashCode ^
        language.hashCode;
  }
}

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
