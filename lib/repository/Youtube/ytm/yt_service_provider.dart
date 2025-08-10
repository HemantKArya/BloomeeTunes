import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart';
import 'helpers.dart';

abstract class YTMusicServices {
  // A private Completer to track the initialization status
  late final Future<void> _initFuture;

  YTMusicServices() : super() {
    _initFuture = _init();
  }

  // Make init private and return a Future
  Future<void> _init() async {
    headers = await initializeHeaders();
    context = await initializeContext();

    if (!headers.containsKey('X-Goog-Visitor-Id')) {
      headers['X-Goog-Visitor-Id'] = await getVisitorId(headers) ?? '';
    }
  }

  // Expose the Future so that dependent code can await it
  Future<void> get initializationComplete => _initFuture;

  refreshContext() async {
    context = await initializeContext();
  }

  Future<void> refreshHeaders() async {
    headers = await initializeHeaders();
  }

  Future<void> resetVisitorId() async {
    Map<String, String> newHeaders = Map.from(headers);
    newHeaders.remove('X-Goog-Visitor-Id');
    final response = await sendGetRequest(httpsYtmDomain, newHeaders);
    final reg = RegExp(r'ytcfg\.set\s*\(\s*({.+?})\s*\)\s*;');
    RegExpMatch? matches = reg.firstMatch(response.body);
    String? visitorId;
    if (matches != null) {
      final ytcfg = json.decode(matches.group(1).toString());
      visitorId = ytcfg['VISITOR_DATA']?.toString();
      visitorId != null
          ? await BloomeeDBService.putAPICache("VISITOR_ID", visitorId)
          : null;
    }
    refreshHeaders();
  }

  static const ytmDomain = 'music.youtube.com';
  static const httpsYtmDomain = 'https://music.youtube.com';
  static const baseApiEndpoint = '/youtubei/v1/';
  static const String ytmParams =
      '?alt=json&key=AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';
  static const userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0';

  Map<String, String> headers = {};
  int? signatureTimestamp;
  Map<String, dynamic> context = {};

  Future<Response> sendGetRequest(
    String url,
    Map<String, String>? headers, {
    int retryCount = 3,
  }) async {
    // Ensure initialization is complete before sending a request
    await _initFuture;
    final Uri uri = Uri.parse(url);
    while (retryCount > 0) {
      try {
        final Response response = await get(uri, headers: headers);
        if (response.statusCode == 200) {
          return response;
        } else {
          log('Request failed with status: ${response.statusCode}, body: ${response.body}',
              name: 'YTMusicServices.sendGetRequest');
        }
      } catch (e) {
        log('Request failed with exception: $e',
            name: 'YTMusicServices.sendGetRequest');
      }

      retryCount--;
      if (retryCount > 0) {
        await Future.delayed(
            const Duration(seconds: 2)); // Wait before retrying
      }
    }

    throw Exception('Failed to fetch data after multiple retries');
  }

  Future<Response> addPlayingStats(String videoId, Duration time) async {
    // Ensure initialization is complete before sending a request
    await _initFuture;
    final Uri uri = Uri.parse(
        'https://music.youtube.com/api/stats/watchtime?ns=yt&ver=2&c=WEB_REMIX&cmt=${(time.inMilliseconds / 1000)}&docid=$videoId');
    final Response response = await get(uri, headers: headers);
    return response;
  }

  Future<String?> getVisitorId(Map<String, String>? headers) async {
    final response = await sendGetRequest(httpsYtmDomain, headers);
    final reg = RegExp(r'ytcfg\.set\s*\(\s*({.+?})\s*\)\s*;');
    final matches = reg.firstMatch(response.body);
    String? visitorId;
    if (matches != null) {
      final ytcfg = json.decode(matches.group(1).toString());
      visitorId = ytcfg['VISITOR_DATA']?.toString();
      visitorId != null
          ? await BloomeeDBService.putAPICache("VISITOR_ID", visitorId)
          : null;
    }
    return await BloomeeDBService.getAPICache("VISITOR_ID");
  }

  Future<Map> sendRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    String additionalParams = '',
    int retryCount = 3,
  }) async {
    // Ensure initialization is complete before sending a request
    await _initFuture;
    body = {...body, ...context};
    this.headers.addAll(headers ?? {});
    final Uri uri = Uri.parse(httpsYtmDomain +
        baseApiEndpoint +
        endpoint +
        ytmParams +
        additionalParams);

    while (retryCount > 0) {
      try {
        final response =
            await post(uri, headers: this.headers, body: jsonEncode(body));

        if (response.statusCode == 200) {
          return json.decode(response.body) as Map;
        } else {
          log('Request failed with status: ${response.statusCode}, body: ${response.body}',
              name: 'YTMusicServices.sendRequest');
        }
      } catch (e) {
        log('Request failed with exception: $e',
            name: 'YTMusicServices.sendRequest');
      }

      retryCount--;
      if (retryCount > 0) {
        await Future.delayed(
            const Duration(seconds: 2)); // Wait before retrying
      }
    }

    return {};
  }
}
