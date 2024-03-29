// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:js_util';

import 'dart:convert';
import 'package:isar/isar.dart';

part 'GlobalDB.g.dart';

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
  int? duration;
  String mediaID;
  String streamingURL;
  String? source;
  String permaURL;
  String language;
  bool isLiked = false;

  // @Backlink(to: "mediaItems")
  IsarLinks<MediaPlaylistDB> mediaInPlaylistsDB = IsarLinks<MediaPlaylistDB>();

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
    this.duration,
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
        other.duration == duration &&
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
        duration.hashCode ^
        permaURL.hashCode ^
        language.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': null,
      'title': title,
      'album': album,
      'artist': artist,
      'artURL': artURL,
      'genre': genre,
      'duration': duration,
      'mediaID': mediaID,
      'streamingURL': streamingURL,
      'source': source,
      'permaURL': permaURL,
      'language': language,
      'isLiked': isLiked,
    };
  }

  factory MediaItemDB.fromMap(Map<String, dynamic> map) {
    return MediaItemDB(
      id: null,
      title: map['title'] as String,
      album: map['album'] as String,
      artist: map['artist'] as String,
      artURL: map['artURL'] as String,
      genre: map['genre'] as String,
      duration: map['duration'] != null ? map['duration'] as int : null,
      mediaID: map['mediaID'] as String,
      streamingURL: map['streamingURL'] as String,
      source: map['source'] != null ? map['source'] as String : null,
      permaURL: map['permaURL'] as String,
      language: map['language'] as String,
      isLiked: map['isLiked'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaItemDB.fromJson(String source) =>
      MediaItemDB.fromMap(json.decode(source) as Map<String, dynamic>);
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

@collection
class AppSettingsStrDB {
  Id get isarId => fastHash(settingName);
  String settingName;
  String settingValue;
  AppSettingsStrDB({
    required this.settingName,
    required this.settingValue,
  });

  @override
  bool operator ==(covariant AppSettingsStrDB other) {
    if (identical(this, other)) return true;

    return other.settingName == settingName &&
        other.settingValue == settingValue;
  }

  @override
  int get hashCode => settingName.hashCode ^ settingValue.hashCode;
}

@collection
class AppSettingsBoolDB {
  Id get isarId => fastHash(settingName);
  String settingName;
  bool settingValue;
  AppSettingsBoolDB({
    required this.settingName,
    required this.settingValue,
  });

  @override
  bool operator ==(covariant AppSettingsBoolDB other) {
    if (identical(this, other)) return true;

    return other.settingName == settingName &&
        other.settingValue == settingValue;
  }

  @override
  int get hashCode => settingName.hashCode ^ settingValue.hashCode;
}

@collection
class ChartsCacheDB {
  Id get isarId => fastHash(chartName);
  String chartName;
  DateTime lastUpdated;
  String? permaURL;
  List<ChartItemDB> chartItems;
  ChartsCacheDB({
    required this.chartName,
    required this.lastUpdated,
    required this.chartItems,
    this.permaURL,
  });
}

@embedded
class ChartItemDB {
  String? title;
  String? artist;
  String? artURL;
}

@collection
class RecentlyPlayedDB {
  Id? id;
  DateTime lastPlayed;
  RecentlyPlayedDB({
    this.id,
    required this.lastPlayed,
  });
  IsarLink<MediaItemDB> mediaItem = IsarLink<MediaItemDB>();
}
