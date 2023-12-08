import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

class SpotifyApi {
  final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  /// You can signup for spotify developer account and get your own clientID and clientSecret incase you don't want to use these
  final String clientID = dotenv.env['CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
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

  Future<String> getAccessToken2() async {
    final tokenUrl = Uri.parse('https://accounts.spotify.com/api/token');
    final response = await post(
      tokenUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['access_token'];
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
        Logger.root.severe(
          'Error in getAccessToken, called: $path, returned: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      Logger.root.severe('Error in getting spotify access token: $e');
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
        Logger.root.severe(
          'Error in getUserPlaylists, called: $path, returned: ${response.statusCode}',
          response.body,
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

    final Map data = await SpotifyApi().getHundredTracksOfPlaylist(
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

        playlistName = result["name"] ?? "Liked";
      } else {
        Logger.root.severe(
          'Error in getHundredTracksOfPlaylist, called: $path, returned: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      Logger.root.severe('Error in getting spotify playlist tracks: $e');
    }

    totalTracks = data['total'] as int;
    tracks.addAll(data['tracks'] as List);

    if (totalTracks > 100) {
      for (int i = 1; i * 100 <= totalTracks; i++) {
        final Map data = await SpotifyApi().getHundredTracksOfPlaylist(
          accessToken,
          playlistId,
          i * 100,
        );
        tracks.addAll(data['tracks'] as List);
      }
    }
    return {'tracks': tracks, 'playlistName': playlistName};
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
        log(result, name: "SpotifyAPI");
        final List tracks = result['items'] as List;
        final int total = result['total'] as int;

        return {'tracks': tracks, 'total': total};
      } else {
        Logger.root.severe(
          'Error in getHundredTracksOfPlaylist, called: $path, returned: ${response.statusCode}',
          response.body,
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
      Logger.root.severe(
        'Error in searchTrack, called: $path, returned: ${response.statusCode}',
        response.body,
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
      Logger.root.severe(
        'Error in getTrackDetails, called: $path, returned: ${response.statusCode}',
        response.body,
      );
    }
    return {};
  }

  Future<List<Map>> getFeaturedPlaylists(String accessToken) async {
    try {
      final Uri path = Uri.parse(
        '$spotifyApiBaseUrl/browse/featured-playlists',
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
        await for (final element in result['playlists']['items'] as Stream) {
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
        Logger.root.severe(
          'Error in getFeaturedPlaylists, called: $path, returned: ${response.statusCode}',
          response.body,
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
        (results["tracks"]["items"] as List).forEach((e) {
          tempQuery = e["name"].toString();
          (e["artists"] as List).forEach((element) {
            tempQuery = '$tempQuery ${element["name"]}';
          });
          queries.add(tempQuery);
        });
        return queries;
      }
    }
    return [query];
  }
}
