library ytmusic;

import 'dart:developer';
import 'mixins/browsing.dart';
import 'mixins/library.dart';
import 'mixins/search.dart';
import 'yt_service_provider.dart';

class YTMusic extends YTMusicServices
    with BrowsingMixin, LibraryMixin, SearchMixin {
  static YTMusic? _instance;
  YTMusic._();

  factory YTMusic() {
    _instance ??= YTMusic._();
    return _instance!;
  }

  Future<List<Map>> getRelatedSongs(String videoId) async {
    final relatedSongs =
        await super.getNextSongList(videoId: videoId, radio: true);
    List<Map> songs = [];
    for (var item in relatedSongs) {
      try {
        songs.add({
          "title": item["title"],
          "album": item["album"]?["name"] ?? "Unknown",
          "artists": item["artists"] != null
              ? item["artists"].map((e) => e["name"]).toList().join(", ")
              : "Unknown",
          "videoId": item["videoId"],
          "thumbnail": item["thumbnails"].first["url"],
          "duration": item["duration"],
          "type": item["type"],
          "artist_map": item['artists'],
          "perma_url": "https://music.youtube.com/watch?v=${item["videoId"]}",
          "subtitle": item["subtitle"],
        });
      } catch (e) {
        log(e.toString(), name: "YTMusic");
      }
    }
    return songs;
  }

  Future<Map?> getPlaylistFull(String playlistId) async {
    final playlistDetails = await super.getPlaylistSongs(playlistId);

    Map? results;

    final List<Map> songs = [];
    for (var item in playlistDetails) {
      if (item['videoId'] == null) continue;
      try {
        songs.add({
          "title": item["title"],
          "album": item["album"]?["name"] ?? "Unknown",
          "artists": item["artists"] != null
              ? item["artists"].map((e) => e["name"]).toList().join(", ")
              : "Unknown",
          "videoId": item["videoId"],
          "thumbnail": item["thumbnails"].first["url"],
          "duration": item["duration"],
          "type": item["type"],
          "perma_url": "https://music.youtube.com/watch?v=${item["videoId"]}",
          "subtitle": item["subtitle"],
        });
      } catch (e) {
        log(e.toString(), name: "YTMusic");
      }
    }
    results = {
      "playlistId": playlistId,
      "perma_url": "https://music.youtube.com/playlist?list=${playlistId}",
      "songs": songs,
    };
    return results;
  }

  Future<Map?> getAlbumFull(String browseId) async {
    final albumDetails = await super.browse(body: {
      "browseId": browseId,
    });

    Map? results;
    try {
      results = {
        "title": albumDetails["header"]["title"],
        "subtitle": albumDetails["header"]["subtitle"],
        "secondSubtitle": albumDetails["header"]["secondSubtitle"],
        "thumbnails": albumDetails["header"]["thumbnails"],
        "playlistId": albumDetails["header"]["playlistId"],
        "browseId": browseId,
        "perma_url":
            "https://music.youtube.com/playlist?list=${albumDetails["header"]["playlistId"]}",
        "artists": albumDetails["header"]["artists"] != null
            ? albumDetails["header"]["artists"]
                .map((e) => e["name"])
                .toList()
                .join("")
            : "Unknown",
      };

      List<Map> songs = [];
      for (var item in albumDetails["sections"].first["contents"]) {
        try {
          songs.add({
            "title": item["title"],
            "subtitle": item["subtitle"],
            "album": albumDetails["header"]["title"],
            "videoId": item["videoId"],
            "type": item["type"],
            "duration": item["duration"],
            "artists": item["artists"] != null
                ? item["artists"].map((e) => e["name"]).toList().join(", ")
                : albumDetails["header"]["artists"] != null
                    ? albumDetails["header"]["artists"]
                        .map((e) => e["name"])
                        .toList()
                        .join("")
                    : "Unknown",
            "thumbnail": item["thumbnails"].first["url"],
            "perma_url": "https://music.youtube.com/watch?v=${item["videoId"]}",
          });
        } catch (e) {
          log(e.toString(), name: "YTMusic");
        }
      }
      results["songs"] = songs;
    } catch (e) {
      log(e.toString(), name: "YTMusic");
    }
    return results;
  }

  Future<Map?> getArtistDetails(String browseId) async {
    final artistDetails = await super.browse(body: {
      "browseId": browseId,
    });

    Map? results;
    try {
      results = {
        "title": artistDetails["header"]["title"],
        "subtitle": artistDetails["header"]["subtitle"],
        "description": artistDetails["header"]["description"],
        "thumbnail": artistDetails["header"]["thumbnails"].first["url"],
        "playlistId": artistDetails["header"]["playlistId"],
        "channelId": artistDetails["header"]["channelId"],
        "browseId": browseId,
        "perma_url":
            "https://music.youtube.com/channel/${artistDetails["header"]["channelId"]}",
      };
    } catch (e) {
      log(e.toString(), name: "YTMusic");
    }
    return results;
  }

  Future<Map?> getArtistFull(String browseId) async {
    final artistDetails = await super.browse(body: {
      "browseId": browseId,
    });

    Map? results;
    try {
      results = {
        "title": artistDetails["header"]["title"],
        "subtitle": artistDetails["header"]["subtitle"],
        "description": artistDetails["header"]["description"],
        "thumbnail": artistDetails["header"]["thumbnails"].first["url"],
        "playlistId": artistDetails["header"]["playlistId"],
        "channelId": artistDetails["header"]["channelId"],
        "browseId": browseId,
        "perma_url":
            "https://music.youtube.com/channel/${artistDetails["header"]["channelId"]}",
      };

      // Get song browse id
      String? songListId;
      try {
        for (var item in artistDetails["sections"]) {
          if (item["title"] == "Songs") {
            if (item["trailing"] == null) continue;
            songListId = item["trailing"]["endpoint"]["browseId"];
            break;
          }
        }
      } catch (e) {
        log(e.toString(), name: "YTMusic");
      }
      // Get songs using browseid
      if (songListId != null) {
        final songs = await super.browse(body: {
          "browseId": songListId,
        });
        List<Map> songsList = [];
        for (var item in songs["sections"].first["contents"]) {
          try {
            songsList.add({
              "title": item["title"],
              "album": item["album"]["name"],
              "artists": item["artists"] != null
                  ? item["artists"].map((e) => e["name"]).toList().join(", ")
                  : "Unknown",
              "artists_map": item["artists"] != null
                  ? item["artists"]
                      .map((e) => {
                            "name": e["name"],
                            "browseId": e["endpoint"]["browseId"],
                          })
                      .toList()
                  : [],
              "videoId": item["videoId"],
              "thumbnail": item["thumbnails"].first["url"],
              "duration": item["duration"],
              "type": item["type"],
              "perma_url":
                  "https://music.youtube.com/watch?v=${item["videoId"]}",
            });
          } catch (e) {
            log(e.toString(), name: "YTMusic");
          }
        }
        results["songs"] = songsList;
      }
      // get albums or singles browse id
      String? albumListId;
      try {
        for (var item in artistDetails["sections"]) {
          if (item["title"].toString().contains("Albums") ||
              item["title"].toString().contains("Singles")) {
            if (item["trailing"] == null) continue;
            albumListId = item["trailing"]["endpoint"]["browseId"];
            break;
          }
        }
      } catch (e) {
        log(e.toString(), name: "YTMusic");
      }

      // Get albums using browseid
      if (albumListId != null) {
        final albums = await super.browse(body: {
          "browseId": albumListId,
        });
        List<Map> albumsList = [];
        for (var item in albums["sections"].first["contents"]) {
          try {
            albumsList.add({
              "title": item["title"],
              "artists": albums['header']['title'],
              "thumbnail": item["thumbnails"].first["url"],
              "type": item["type"],
              "browseId": item["endpoint"]["browseId"],
              "perma_url":
                  "https://music.youtube.com/browse/${item["endpoint"]["browseId"]}",
              "subtitle": item["subtitle"],
            });
          } catch (e) {
            log(e.toString(), name: "YTMusic");
          }
        }
        results["albums"] = albumsList;
      }
    } catch (e) {
      log(e.toString(), name: "YTMusic");
    }
    return results;
  }

  Future<Map?> searchYtm(String query, {String type = 'songs'}) async {
    final searchResults = await super.search(query, filter: type);

    Map? results;
    if (searchResults["sections"].isEmpty) return null;
    final content = searchResults["sections"].first["contents"];
    if (type == "songs") {
      List<Map> songs = [];
      for (var item in content) {
        try {
          songs.add({
            "title": item["title"],
            "album": item["album"]["name"],
            "artists": item["artists"] != null
                ? item["artists"].map((e) => e["name"]).toList().join(", ")
                : "Unknown",
            "artists_map": item["artists"] != null
                ? item["artists"]
                    .map((e) => {
                          "name": e["name"],
                          "browseId": e["endpoint"]["browseId"],
                        })
                    .toList()
                : [],
            "videoId": item["videoId"],
            "thumbnail": item["thumbnails"].first["url"],
            "duration": item["duration"],
            "type": item["type"],
            "perma_url": "https://music.youtube.com/watch?v=${item["videoId"]}",
            "subtitle": item["subtitle"],
          });
          log(songs[0]["duration"].toString());
        } catch (e) {
          log(e.toString(), name: "YTMusic");
        }
      }
      results = {
        "continuation": searchResults["continuation"],
        "songs": songs,
      };
    } else if (type == "artists") {
      List<Map> artists = [];
      for (var item in content) {
        try {
          artists.add({
            "title": item["title"],
            "subtitle": item["subtitle"],
            "thumbnail": item["thumbnails"].first["url"],
            "browseId": item["endpoint"]["browseId"],
            "type": item["type"],
            "perma_url":
                "https://music.youtube.com/browse/${item["endpoint"]["browseId"]}",
          });
        } catch (e) {
          log(e.toString(), name: "YTMusic");
        }
      }
      results = {
        "continuation": searchResults["continuation"],
        "artists": artists,
      };
    } else if (type == "albums") {
      List<Map> albums = [];
      for (var item in content) {
        try {
          albums.add({
            "title": item["title"],
            "artists": item["artists"] != null
                ? item["artists"].map((e) => e["name"]).toList().join(", ")
                : "Unknown",
            "artists_map": item["artists"] != null
                ? item["artists"]
                    .map((e) => {
                          "name": e["name"],
                          "browseId": e["endpoint"]["browseId"],
                        })
                    .toList()
                : [],
            "thumbnail": item["thumbnails"].first["url"],
            "type": item["type"],
            "browseId": item["endpoint"]["browseId"],
            "perma_url":
                "https://music.youtube.com/browse/${item["endpoint"]["browseId"]}",
            "subtitle": item["subtitle"],
          });
        } catch (e) {
          log(e.toString(), name: "YTMusic");
        }
      }
      results = {
        "continuation": searchResults["continuation"],
        "albums": albums,
      };
    } else if (type == "playlists") {
      List<Map> playlists = [];
      for (var item in content) {
        try {
          playlists.add({
            "title": item["title"],
            "subtitle": item["subtitle"],
            "thumbnail": item["thumbnails"].first["url"],
            "type": item["type"],
            "playlistId": item["playlistId"],
            "browseId": item["endpoint"]["browseId"],
            "perma_url":
                "https://music.youtube.com/playlist?list=${item["playlistId"]}",
          });
        } catch (e) {
          log(e.toString(), name: "YTMusic");
        }
      }
      results = {
        "continuation": searchResults["continuation"],
        "playlists": playlists,
      };
    }
    return results;
  }
}
