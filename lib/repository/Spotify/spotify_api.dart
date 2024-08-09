import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart';

class SpotifyApi {
  final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  final String clientID = '4ede44382bf14ac3ba1d97ad753b233f';
  final String clientSecret = 'fb01ad204aff4c12bbcb3ca7ac617990';
  final String redirectUrl = '127.0.0.1';
  final String spotifyApiUrl = 'https://accounts.spotify.com/api';
  final String spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  final String spotifyUserPlaylistEndpoint = '/me/playlists';
  final String spotifyPlaylistTrackEndpoint = '/playlists';
  final String spotifyRegionalChartsEndpoint = '/views/charts-regional';
  final String spotifyFeaturedPlaylistsEndpoint = '/browse/featured-playlists';
  final String spotifyBaseUrl = 'https://accounts.spotify.com';
  final String requestToken = 'https://accounts.spotify.com/api/token';

  String requestAuthorization() =>
      'https://accounts.spotify.com/authorize?client_id=$clientID&response_type=code&redirect_uri=$redirectUrl&scope=${_scopes.join('%20')}';

  Future<String> getAccessTokenCC() async {
    final token = await BloomeeDBService.getApiTokenDB(
        GlobalStrConsts.spotifyAccessToken);
    if (token != null) {
      log('Access token: $token', name: 'SpotifyAPI');
      return token;
    }
    var response;
    final tokenUrl = Uri.parse('https://accounts.spotify.com/api/token');
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$clientID:$clientSecret'))}';
    try {
      response = await post(
        tokenUrl,
        headers: {
          'Authorization': basicAuth,
        },
        body: {
          'grant_type': 'client_credentials',
        },
      );
    } catch (e) {
      log('Error in getting spotify access token: $e', name: "spotifyAPI");
    }

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['access_token'];
      await BloomeeDBService.putApiTokenDB(GlobalStrConsts.spotifyAccessToken,
          accessToken, responseBody['expires_in'].toString());
      log('Got new access token!', name: 'SpotifyAPI2');
      return accessToken;
    } else {
      throw Exception('Failed to get access token');
    }
  }

  Future<List<String>> getAccessToken({
    String? code,
    String? refreshToken,
  }) async {
    final Map<String, String> headers = {
      'Authorization':
          "Basic ${base64.encode(utf8.encode("$clientID:$clientSecret"))}",
    };

    Map<String, String>? body;
    if (code != null) {
      body = {'grant_type': 'authorization_code', 'redirect_uri': redirectUrl};
    } else if (refreshToken != null) {
      body = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };
    }

    if (body == null) {
      return [];
    }

    try {
      final Uri path = Uri.parse(requestToken);
      final response = await post(path, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body) as Map;
        return <String>[
          result['access_token'].toString(),
          result['refresh_token'].toString(),
          result['expires_in'].toString(),
        ];
      } else {
        log(
          'Error in getAccessToken, called: $path, returned: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      log('Error in getting spotify access token: $e');
    }
    return [];
  }

  Future<List> getUserPlaylists(String accessToken) async {
    try {
      final Uri path =
          Uri.parse('$spotifyApiBaseUrl$spotifyUserPlaylistEndpoint?limit=50');

      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List playlists = result['items'] as List;
        return playlists;
      } else {
        log(
          'Error in getUserPlaylists, called: $path, returned: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      log('Error in getting spotify user playlists: $e', name: "spotifyAPI");
    }
    return [];
  }

  Future<Map<String, Object>> getAllTracksOfPlaylist(
    String accessToken,
    String playlistId,
  ) async {
    final List tracks = [];
    int totalTracks = 100;
    String playlistName = "Liked";
    String? imgUrl;
    String url = 'https://open.spotify.com/playlist/$playlistId';
    String? description;

    final Map data = await getHundredTracksOfPlaylist(
      accessToken,
      playlistId,
      0,
    );

    try {
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl$spotifyPlaylistTrackEndpoint/$playlistId',
      );

      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final result = await jsonDecode(response.body);
        imgUrl = (result["images"] as List).first["url"];
        url = result['external_urls']['spotify'];
        playlistName = result["name"] ?? "Liked";
        description = result["description"];
      } else {
        log(
          'Error in getHundredTracksOfPlaylist, called: $path, returned: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      log('Error in getting spotify playlist tracks: $e');
    }

    totalTracks = data['total'] as int;
    tracks.addAll(data['tracks'] as List);

    if (totalTracks > 100) {
      for (int i = 1; i * 100 <= totalTracks; i++) {
        final Map data = await getHundredTracksOfPlaylist(
          accessToken,
          playlistId,
          i * 100,
        );
        tracks.addAll(data['tracks'] as List);
      }
    }
    return {
      'tracks': tracks,
      'playlistName': playlistName,
      'url': url,
      'imgUrl': imgUrl ?? "",
      'description': description ?? "",
    };
  }

  Future<Map> getHundredTracksOfPlaylist(
    String accessToken,
    String playlistId,
    int offset,
  ) async {
    try {
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl$spotifyPlaylistTrackEndpoint/$playlistId/tracks?limit=100&offset=$offset',
      );

      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final result = await jsonDecode(response.body);
        // log(result.toString(), name: "SpotifyAPI");
        final List tracks = result['items'] as List;
        final int total = result['total'] as int;

        return {'tracks': tracks, 'total': total};
      } else {
        log(
          'Error in getHundredTracksOfPlaylist, called: $path, returned: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e) {
      log('Error in getting spotify playlist tracks: $e', name: "spotifyAPI");
    }
    return {};
  }

  Future<Map> searchTrack({
    required String accessToken,
    required String query,
    int limit = 10,
    String type = 'track',
  }) async {
    final Uri path = Uri.parse(
      '$spotifyApiBaseUrl/search?q=$query&type=$type&limit=$limit',
    );

    final response = await get(
      path,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map;
      return result as Map<String, dynamic>;
    } else {
      log(
        'Error in searchTrack, called: $path, returned: ${response.statusCode}',
        error: response.body,
      );
    }
    return {"error": response.body};
  }

  Future<Map> getTrackDetails(String accessToken, String trackId) async {
    final Uri path = Uri.parse(
      '$spotifyApiBaseUrl/tracks/$trackId',
    );
    final response = await get(
      path,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map;
      return result;
    } else {
      log(
        'Error in getTrackDetails, called: $path, returned: ${response.statusCode}',
        error: response.body,
      );
    }
    return {};
  }

  Future<List<Map>> getFeaturedPlaylists(String accessToken,
      {int limit = 20, offset = 0}) async {
    try {
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl/browse/featured-playlists?offset=$offset&limit=$limit,',
      );
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );
      final List<Map> songsData = [];
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // log(result.toString(), name: "spotifyApi");
        for (var element in result['playlists']['items']) {
          songsData.add({
            'name': element['name'],
            'id': element['id'],
            'image': element['images'][0]['url'],
            'description': element['description'],
            'externalUrl': element['external_urls']['spotify'],
            'tracks': await SpotifyApi().getAllTracksOfPlaylist(
              accessToken,
              element['id'].toString(),
            ),
          });
        }
      } else {
        log(
          'Error in getFeaturedPlaylists, called: $path, returned: ${response.statusCode}',
          error: response.body,
        );
      }
      return songsData;
    } catch (e) {
      log('Error in getting spotify featured playlists: $e',
          name: "spotifyAPI");
      return List.empty();
    }
  }

  Future<List<String>> getSearchQueriesFromSpotify(
    String query,
    String? accessToken, {
    int limit = 10,
    String type = 'track',
  }) async {
    List<String> queries = [];

    if (accessToken != null) {
      Map<dynamic, dynamic> results = await searchTrack(
        accessToken: accessToken,
        query: query,
        limit: limit,
        type: type,
      );
      // log(results["tracks"]["items"]);
      String tempQuery;
      if (results["tracks"] != null) {
        for (var e in (results["tracks"]["items"] as List)) {
          tempQuery = e["name"].toString();
          for (var element in (e["artists"] as List)) {
            tempQuery = '$tempQuery ${element["name"]}';
          }
          queries.add(tempQuery);
        }
        return queries;
      }
    }
    return [query];
  }

  Future<List<Map>> get50AlbumTracks(String accessToken, String albumId,
      {int offset = 0, int limit = 50}) async {
    try {
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl/albums/$albumId/tracks?offset=$offset&limit=$limit',
      );
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );
      final List<Map> songsData = [];
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        for (var element in result['items']) {
          songsData.add({
            'name': element['name'],
            'id': element['id'],
            'externalUrl': element['external_urls']['spotify'],
            'artists': element['artists'],
          });
        }
      } else {
        log(
          'Error in get50AlbumTracks, called: ${path.toString()}, returned: ${response.statusCode}',
          error: response.body,
        );
      }
      return songsData;
    } catch (e) {
      log('Error in getting spotify album tracks: $e', name: "spotifyAPI");
      return List.empty();
    }
  }

  Future<Map<String, Object>> getAllAlbumTracks(
      String accessToken, String albumId) async {
    try {
      int totalItems = 0;
      String albumName = "";
      String? imgUrl;
      String url = 'https://open.spotify.com/album/$albumId';
      String? description;
      String? artists;
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl/albums/$albumId',
      );
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );
      final List<Map> songsData = [];
      if (response.statusCode == 200) {
        totalItems = jsonDecode(response.body)['total_tracks'] as int;
        albumName = jsonDecode(response.body)['name'];
        imgUrl = (jsonDecode(response.body)["images"] as List).first["url"];
        url = jsonDecode(response.body)['external_urls']['spotify'];
        description = jsonDecode(response.body)['album_type'];
        List<String> _artists = [];
        for (var e in (jsonDecode(response.body)['artists'] as List)) {
          _artists.add(e['name']);
        }
        artists = _artists.join(", ");
        final result = jsonDecode(response.body);
        for (var element in result['tracks']['items']) {
          songsData.add({
            'name': element['name'],
            'id': element['id'],
            'externalUrl': element['external_urls']['spotify'],
            'artists': element['artists'],
          });
        }
        if (totalItems > 50) {
          for (int i = 1; i * 50 <= totalItems; i++) {
            songsData.addAll(
                await get50AlbumTracks(accessToken, albumId, offset: i * 50));
          }
        }
      } else {
        log(
          'Error in getAllAlbumTracks, called: ${path.toString()}, returned: ${response.statusCode}',
          error: response.body,
        );
      }
      return {
        "tracks": songsData,
        "total": totalItems,
        "albumName": albumName,
        "url": url,
        "imgUrl": imgUrl ?? "",
        "description": description ?? "",
        "artists": artists ?? "",
      };
    } catch (e) {
      log('Error in getting spotify album tracks: $e', name: "spotifyAPI");
      return {"tracks": List.empty(), "total": 0, "error": e, 'albumName': ""};
    }
  }
}
