// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ScrobbleTrack {
  final String artist;
  final String trackName;
  int timestamp;
  final String? album;
  final int? duration;
  final bool chosenByUser;

  ScrobbleTrack({
    required this.artist,
    required this.trackName,
    this.timestamp = 0,
    this.album,
    this.duration,
    this.chosenByUser = false,
  }) {
    if (timestamp == 0) {
      timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
  }

  Map<String, String> toParams(int index) {
    Map<String, String> params = {
      'artist[$index]': artist,
      'track[$index]': trackName,
      'timestamp[$index]': timestamp.toString(),
    };
    if (album != null) {
      params['album[$index]'] = album!;
    }
    if (duration != null) {
      params['duration[$index]'] = duration.toString();
    }
    if (!chosenByUser) {
      params['chosenByUser[$index]'] = '0';
    }
    return params;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'artist': artist,
      'trackName': trackName,
      'timestamp': timestamp,
      'album': album,
      'duration': duration,
      'chosenByUser': chosenByUser,
    };
  }

  factory ScrobbleTrack.fromMap(Map<String, dynamic> map) {
    return ScrobbleTrack(
      artist: map['artist'] as String,
      trackName: map['trackName'] as String,
      timestamp: map['timestamp'] as int,
      album: map['album'] != null ? map['album'] as String : null,
      duration: map['duration'] != null ? map['duration'] as int : null,
      chosenByUser: map['chosenByUser'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScrobbleTrack.fromJson(Map source) =>
      ScrobbleTrack.fromMap(source as Map<String, dynamic>);
}

/// Outcome of a `track.scrobble` batch submission.
enum ScrobbleOutcome {
  /// Batch was accepted (individual tracks may still have been ignored).
  success,

  /// Temporary problem (network, 5xx, rate-limit). Keep entries and retry.
  retryable,

  /// Session/credentials are invalid. Keep entries, stop until re-auth.
  authFailed,

  /// Batch is permanently rejected. Entries should be dropped so they don't
  /// block the queue forever.
  rejected,
}

class LastFmAPI {
  static String? apiKey;
  static String? apiSecret;
  static String? sessionKey;
  static String? username;
  static bool initialized = false;
  static const String apiUrl = 'https://ws.audioscrobbler.com/2.0/';
  static const Duration _timeout = Duration(seconds: 20);
  static const String userStation = "https://www.last.fm/player/station/user/";
  static const Map<String, String> userStationEndpoints = {
    "recommended": "/recommended",
    "mix": "/mix",
    "library": "/library",
  };

  // Private constructor
  LastFmAPI._internal() {
    initialize(apiKey: null, apiSecret: null, sessionKey: null);
  }

  // Singleton instance
  static final LastFmAPI _instance = LastFmAPI._internal();

  // Factory constructor to return the singleton instance
  factory LastFmAPI() {
    initialize(
      apiKey: null,
      apiSecret: null,
      sessionKey: null,
    );
    return _instance;
  }

  static void initialize({
    required String? apiKey,
    required String? apiSecret,
    required String? sessionKey,
  }) {
    LastFmAPI.apiKey = apiKey;
    LastFmAPI.apiSecret = apiSecret;
    LastFmAPI.sessionKey = sessionKey;
    initialized = (apiKey != null && apiSecret != null && sessionKey != null);
  }

  static void setAPIKey(String apikey) {
    if (apikey.isNotEmpty) {
      apiKey = apikey;
    }
  }

  static void setAPISecret(String apisecret) {
    if (apisecret.isNotEmpty) {
      apiSecret = apisecret;
    }
  }

  static void setSession(String session) {
    if (session.isNotEmpty) {
      sessionKey = session;
    }
  }

  static void setUsername(String name) {
    if (name.isNotEmpty) {
      username = name;
    }
  }

  static String generateApiSig(Map<String, String> params, String apiSecret) {
    List<String> sortedParams = params.keys.toList()..sort();
    String sortedParamsString =
        sortedParams.map((key) => '$key${params[key]}').join();
    String signature =
        md5.convert(utf8.encode('$sortedParamsString$apiSecret')).toString();
    return signature;
  }

  /// Updates the "Now Playing" status on the user's Last.fm profile.
  static Future<void> updateNowPlaying(ScrobbleTrack track) async {
    if (apiKey == null || apiSecret == null || sessionKey == null) return;

    final params = <String, String>{
      'method': 'track.updateNowPlaying',
      'artist': track.artist,
      'track': track.trackName,
      'api_key': apiKey!,
      'sk': sessionKey!,
    };
    if (track.album != null) params['album'] = track.album!;
    if (track.duration != null) params['duration'] = track.duration.toString();

    params['api_sig'] = generateApiSig(params, apiSecret!);
    params['format'] = 'json';

    try {
      await http.post(Uri.parse(apiUrl), body: params).timeout(_timeout);
    } catch (e) {
      log('updateNowPlaying failed: $e', name: 'LastFM API');
    }
  }

  /// Submits up to 50 tracks. Never throws; the result tells the caller
  /// whether to keep, retry or drop the entries.
  static Future<ScrobbleOutcome> scrobble(List<ScrobbleTrack> tracks) async {
    if (apiKey == null || apiSecret == null || sessionKey == null) {
      return ScrobbleOutcome.authFailed;
    }
    if (tracks.isEmpty) return ScrobbleOutcome.success;
    if (tracks.length > 50) return ScrobbleOutcome.rejected;

    final params = <String, String>{
      'method': 'track.scrobble',
      'api_key': apiKey!,
      'sk': sessionKey!,
    };
    for (int i = 0; i < tracks.length; i++) {
      params.addAll(tracks[i].toParams(i));
    }
    params['api_sig'] = generateApiSig(params, apiSecret!);
    params['format'] = 'json';

    try {
      final response = await http
          .post(Uri.parse(apiUrl), body: params)
          .timeout(_timeout);

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if (response.statusCode == 200 && data != null) {
        if (data.containsKey('error')) {
          return _classifyError(data['error'], data['message']);
        }
        final attr = (data['scrobbles'] as Map?)?['@attr'] as Map?;
        log('Accepted: ${attr?['accepted']}, ignored: ${attr?['ignored']}',
            name: 'LastFM API');
        return ScrobbleOutcome.success;
      }
      if (data != null && data.containsKey('error')) {
        return _classifyError(data['error'], data['message']);
      }
      log('HTTP ${response.statusCode}: ${response.body}', name: 'LastFM API');
      // 5xx / 429 are transient; other 4xx will never succeed.
      final code = response.statusCode;
      return (code >= 500 || code == 429)
          ? ScrobbleOutcome.retryable
          : ScrobbleOutcome.rejected;
    } catch (e) {
      // Timeout, DNS failure, offline, ...
      log('Scrobble request failed: $e', name: 'LastFM API');
      return ScrobbleOutcome.retryable;
    }
  }

  static ScrobbleOutcome _classifyError(dynamic code, dynamic message) {
    final c = code is int ? code : int.tryParse('$code') ?? -1;
    log('API error $c: $message', name: 'LastFM API');
    switch (c) {
      case 4: // invalid auth
      case 9: // invalid session key
      case 10: // invalid api key
      case 14: // unauthorized token
      case 15: // token expired
      case 26: // suspended api key
        return ScrobbleOutcome.authFailed;
      case 8: // operation failed
      case 11: // service offline
      case 16: // temporary error
      case 29: // rate limit
        return ScrobbleOutcome.retryable;
      default:
        return ScrobbleOutcome.rejected;
    }
  }

  static Future<String> fetchRequestToken() async {
    if (apiKey == null || apiSecret == null) {
      throw Exception("LastFM API not initialized.");
    }

    Map<String, String> params = {
      'method': 'auth.getToken',
      'api_key': apiKey!,
    };
    params['api_sig'] = generateApiSig(params, apiSecret!);
    params['format'] = 'json';

    try {
      final response =
          await http.get(Uri.https('ws.audioscrobbler.com', '/2.0/', params));
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token')) {
        return responseData['token'];
      } else {
        throw Exception('Failed to retrieve authentication token');
      }
    } catch (e) {
      log('Error fetching request token: $e', name: 'LastFM API');
      rethrow;
    }
  }

  static String getAuthUrl(String token) {
    if (apiKey == null) {
      throw Exception("LastFM API not initialized.");
    }
    return 'https://www.last.fm/api/auth/?api_key=$apiKey&token=$token';
  }

  static Future<Map<String, String>> fetchSessionKey(String token) async {
    if (apiKey == null || apiSecret == null) {
      throw Exception("LastFM API not initialized.");
    }

    Map<String, String> params = {
      'method': 'auth.getSession',
      'api_key': apiKey!,
      'token': token,
    };
    params['api_sig'] = generateApiSig(params, apiSecret!);
    params['format'] = 'json';

    try {
      final response =
          await http.get(Uri.https('ws.audioscrobbler.com', '/2.0/', params));
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('session')) {
        setSession(responseData['session']['key']);
        setUsername(responseData['session']['name']);
        initialized = true;
        return {
          'name': responseData['session']['name'],
          'key': responseData['session']['key'],
        };
      } else {
        throw Exception('Failed to retrieve session key');
      }
    } catch (e) {
      log('Error fetching session key: $e', name: 'LastFM API');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserRecommendedList() async {
    if (apiKey == null || username == null) {
      throw Exception("LastFM API not initialized.");
    }
    final url = "$userStation$username${userStationEndpoints['recommended']}";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user recommended list');
    }
  }

  static Future<Map<String, dynamic>> getUserMixList() async {
    if (apiKey == null || username == null) {
      throw Exception("LastFM API not initialized.");
    }
    final url = "$userStation$username${userStationEndpoints['mix']}";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user mix list');
    }
  }

  static Future<Map<String, dynamic>> getUserLibraryList() async {
    if (apiKey == null || username == null) {
      throw Exception("LastFM API not initialized.");
    }
    final url = "$userStation$username${userStationEndpoints['library']}";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user library list');
    }
  }
}
