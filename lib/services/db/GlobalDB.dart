import 'dart:convert';

import 'package:isar/isar.dart';

part 'GlobalDB.g.dart';

@collection
class MediaPlaylistDB {
  Id get isarId => fastHash(playlistName);
  String playlistName;
  List<int> mediaRanks = List.empty(growable: true);
  DateTime? lastUpdated;
  MediaPlaylistDB({
    required this.playlistName,
    this.lastUpdated,
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
class PlaylistsInfoDB {
  Id get isarId => fastHash(playlistName);
  String playlistName;
  bool? isAlbum;
  String? artURL;
  String? description;
  String? permaURL;
  String? source;
  String? artists;
  DateTime lastUpdated;

  PlaylistsInfoDB({
    required this.playlistName,
    required this.lastUpdated,
    this.isAlbum,
    this.artURL,
    this.description,
    this.permaURL,
    this.source,
    this.artists,
  });

  @override
  bool operator ==(covariant PlaylistsInfoDB other) {
    if (identical(this, other)) return true;

    return other.playlistName == playlistName;
  }

  @override
  int get hashCode {
    return playlistName.hashCode;
  }

  @override
  String toString() {
    return 'PlaylistsInfoDB(playlistName: $playlistName, isAlbum: $isAlbum, artURL: $artURL, description: $description, permaURL: $permaURL, source: $source, artists: $artists, lastUpdated: $lastUpdated)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playlistName': playlistName,
      'isAlbum': isAlbum,
      'artURL': artURL,
      'description': description,
      'permaURL': permaURL,
      'source': source,
      'artists': artists,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory PlaylistsInfoDB.fromMap(Map<String, dynamic> map) {
    return PlaylistsInfoDB(
      playlistName: map['playlistName'] as String,
      isAlbum: map['isAlbum'] != null ? map['isAlbum'] as bool : null,
      artURL: map['artURL'] != null ? map['artURL'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      permaURL: map['permaURL'] != null ? map['permaURL'] as String : null,
      source: map['source'] != null ? map['source'] as String : null,
      artists: map['artists'] != null ? map['artists'] as String : null,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaylistsInfoDB.fromJson(String source) =>
      PlaylistsInfoDB.fromMap(json.decode(source) as Map<String, dynamic>);
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
  String? settingValue2;
  DateTime? lastUpdated;
  AppSettingsStrDB({
    required this.settingName,
    required this.settingValue,
    this.settingValue2,
    this.lastUpdated,
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

@collection
class YtLinkCacheDB {
  Id get isarId => fastHash(videoId);
  String videoId;
  String? lowQURL;
  String highQURL;
  int expireAt;
  YtLinkCacheDB({
    required this.videoId,
    required this.lowQURL,
    required this.highQURL,
    required this.expireAt,
  });
}

@collection
class DownloadDB {
  Id? id = Isar.autoIncrement;
  String fileName;
  String filePath;
  DateTime? lastDownloaded;
  String mediaId;
  DownloadDB({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.lastDownloaded,
    required this.mediaId,
  });
}

@collection
class SavedCollectionsDB {
  Id get isarId => fastHash(title);
  String title;
  String sourceId;
  String source;
  String type;
  String coverArt;
  String sourceURL;
  String? subtitle;
  DateTime lastUpdated;
  String? extra;
  SavedCollectionsDB({
    required this.title,
    required this.type,
    required this.coverArt,
    required this.sourceURL,
    required this.sourceId,
    required this.source,
    required this.lastUpdated,
    this.subtitle,
    this.extra,
  });
}

@collection
class NotificationDB {
  Id? id = Isar.autoIncrement;
  String title;
  String body;
  String type;
  String? url;
  String? payload;
  DateTime? time;
  NotificationDB({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.url,
    this.payload,
  });
}

@collection
class LyricsDB {
  Id get isarId => fastHash(mediaID);
  String sourceId;
  String mediaID;
  String plainLyrics;
  String title;
  String artist;
  String source;
  String? album;
  int? offset;
  int? duration;
  String? url;
  String? syncedLyrics;
  LyricsDB({
    required this.sourceId,
    required this.mediaID,
    required this.plainLyrics,
    required this.title,
    required this.artist,
    required this.source,
    this.album,
    this.offset,
    this.duration,
    this.syncedLyrics,
    this.url,
  });
}

@collection
class SearchHistoryDB {
  Id get isarId => fastHash(query);
  String query;
  DateTime lastSearched;
  SearchHistoryDB({
    required this.query,
    required this.lastSearched,
  });
}
