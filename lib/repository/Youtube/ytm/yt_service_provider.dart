import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart';
import 'helpers.dart';

/// Tracks the initialization lifecycle for the service.
enum InitState { uninitialized, initializing, initialized, failed }

/// Lightweight service wrapper for interacting with YouTube Music endpoints.
///
/// Responsibilities:
/// - Initialize and maintain required headers/context.
/// - Send requests with built-in retry/backoff.
/// - Provide helpers like `addPlayingStats` and `getVisitorId`.
class YTMusicServices {
  // API configuration
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

  // Public state and sync helpers
  InitState initState = InitState.uninitialized;
  Completer<void>? _initCompleter;

  /// Initialize headers/context. Safe to call multiple times; concurrent
  /// callers will wait for the same initialization run.
  Future<void> init() async {
    if (initState == InitState.initializing) return _initCompleter?.future;
    if (initState == InitState.initialized) return;

    initState = InitState.initializing;
    _initCompleter = Completer<void>();

    try {
      headers = await initializeHeaders();
      context = await initializeContext();

      if (!headers.containsKey('X-Goog-Visitor-Id')) {
        headers['X-Goog-Visitor-Id'] = await getVisitorId(headers) ?? '';
      }

      initState = InitState.initialized;
      log('YTMusicServices initialized successfully.', name: 'YTMusicServices');
      _initCompleter?.complete();
    } catch (e, stackTrace) {
      initState = InitState.failed;
      log('YTMusicServices initialization failed: $e',
          name: 'YTMusicServices', error: e, stackTrace: stackTrace);
      _initCompleter?.completeError(e);
      rethrow;
    }
  }

  /// Ensure the service is initialized before use.
  Future<void> _ensureInitialized() async {
    if (initState != InitState.initialized) {
      log('Service not initialized. Calling init()...',
          name: 'YTMusicServices');
      await init();
    }
  }

  Future<void> refreshContext() async {
    await _ensureInitialized();
    context = await initializeContext();
  }

  Future<void> refreshHeaders() async {
    await _ensureInitialized();
    headers = await initializeHeaders();
  }

  /// Generic retry with exponential backoff + jitter.
  /// Keeps retries and timing centralized for easier tuning.
  Future<T> _executeWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    String requestName = 'Request',
  }) async {
    int attempt = 1;
    final random = math.Random();

    while (true) {
      try {
        return await action();
      } catch (e) {
        if (attempt > maxRetries) {
          log('Request failed after $maxRetries attempts. Giving up.',
              name: 'YTMusicServices.$requestName');
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s...
        final delayInSeconds = math.pow(2, attempt - 1).toInt();
        // Jitter: Add a random delay (up to 1s) to prevent thundering herd.
        final jitterInMs = random.nextInt(1000);
        final totalDelay =
            Duration(seconds: delayInSeconds, milliseconds: jitterInMs);

        log(
          'Attempt $attempt failed for $requestName. Retrying in ${totalDelay.inSeconds}s...',
          name: 'YTMusicServices',
          error: e,
        );

        await Future.delayed(totalDelay);
        attempt++;
      }
    }
  }

  Future<Response> sendGetRequest(
    String url,
    Map<String, String>? headers,
  ) {
    return _executeWithRetry(() async {
      await _ensureInitialized();
      final Uri uri = Uri.parse(url);
      final response = await get(uri, headers: headers);
      if (response.statusCode >= 400) {
        throw HttpException('HTTP Error: ${response.statusCode}', uri: uri);
      }
      return response;
    }, requestName: 'sendGetRequest($url)');
  }

  Future<Map> sendRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    String additionalParams = '',
  }) {
    return _executeWithRetry(() async {
      await _ensureInitialized();
      final fullBody = {...body, ...context};
      final requestHeaders = {...this.headers, ...(headers ?? {})};

      final Uri uri = Uri.parse(httpsYtmDomain +
          baseApiEndpoint +
          endpoint +
          ytmParams +
          additionalParams);

      final response =
          await post(uri, headers: requestHeaders, body: jsonEncode(fullBody));

      if (response.statusCode >= 400) {
        throw HttpException('HTTP Error: ${response.statusCode}', uri: uri);
      }
      return json.decode(response.body) as Map;
    }, requestName: 'sendRequest($endpoint)');
  }

  /// Send playback stats. This is treated as best-effort (no retries).
  Future<Response> addPlayingStats(String videoId, Duration time) async {
    await _ensureInitialized();
    final uri = Uri.parse(
        'https://music.youtube.com/api/stats/watchtime?ns=yt&ver=2&c=WEB_REMIX&cmt=${(time.inMilliseconds / 1000)}&docid=$videoId');
    return get(uri, headers: headers);
  }

  Future<String?> getVisitorId(Map<String, String>? headers) async {
    final response = await sendGetRequest(httpsYtmDomain, headers);
    final reg = RegExp(r'ytcfg\.set\s*\(\s*({.+?})\s*\)\s*;');
    final matches = reg.firstMatch(response.body);
    String? visitorId;
    if (matches != null) {
      final ytcfg = json.decode(matches.group(1).toString());
      visitorId = ytcfg['VISITOR_DATA']?.toString();
      if (visitorId != null) {
        await BloomeeDBService.putAPICache("VISITOR_ID", visitorId);
      }
    }
    return await BloomeeDBService.getAPICache("VISITOR_ID");
  }
}

// Simple HTTP exception type so callers can inspect the URI and message.
class HttpException implements Exception {
  final String message;
  final Uri? uri;
  HttpException(this.message, {this.uri});

  @override
  String toString() => 'HttpException: $message, Uri: $uri';
}
