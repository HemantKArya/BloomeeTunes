// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

class MediaItemModel extends MediaItem {
  late String id;
  late String title;
  String? album;
  Uri? artUri;
  String? artist;
  Map<String, dynamic>? extras;
  String? genre;
  Duration? duration;

  MediaItemModel({
    required this.id,
    required this.title,
    this.album,
    this.artUri,
    this.artist,
    this.extras,
    this.genre,
    this.duration,
  }) : super(
            id: id,
            title: title,
            album: album,
            artUri: artUri,
            artist: artist,
            extras: extras,
            genre: genre,
            duration: duration);

  @override
  bool operator ==(covariant MediaItemModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.album == album &&
        other.artUri == artUri &&
        other.artist == artist &&
        mapEquals(other.extras, extras) &&
        other.genre == genre;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        album.hashCode ^
        artUri.hashCode ^
        artist.hashCode ^
        extras.hashCode ^
        genre.hashCode;
  }
}
