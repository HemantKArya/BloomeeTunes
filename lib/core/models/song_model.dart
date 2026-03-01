// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

// Re-export mapper functions for convenience.
// Callers can import song_model.dart and get access to DB mappers.
export 'package:Bloomee/services/db/mappers/media_item_mapper.dart'
    show mediaItemToMediaItemDB, mediaItemDBToMediaItem;

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

  /// Source identifier for this track (e.g. "youtube", "saavn", "youtube_music").
  /// Read from the [extras] map under the key "source".
  String get source => extras?['source'] as String? ?? '';

  /// Raw stream URL. Read from the [extras] map under the key "url".
  String get streamUrl => extras?['url'] as String? ?? '';

  @override
  String toString() =>
      'MediaItemModel(id: $id, title: $title, artist: $artist)';
}

MediaItemModel mediaItem2MediaItemModel(MediaItem mediaItem) {
  return MediaItemModel(
    id: mediaItem.id,
    title: mediaItem.title,
    album: mediaItem.album,
    artUri: mediaItem.artUri,
    artist: mediaItem.artist,
    extras: mediaItem.extras,
    genre: mediaItem.genre,
    duration: mediaItem.duration,
  );
}
