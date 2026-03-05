import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/repository/lastfm/lastfmapi.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:rxdart/subjects.dart';
import 'package:url_launcher/url_launcher.dart';

part 'lastdotfm_state.dart';

class LastdotfmCubit extends Cubit<LastdotfmState> {
  LastFmAPI lastFmAPI = LastFmAPI();
  StreamSubscription? scrobbleSub;
  BloomeePlayerCubit playerCubit;
  final CacheDAO _cacheDao;
  final SettingsDAO _settingsDao;
  Track lastPlayed = trackNull;
  Stopwatch stopwatch = Stopwatch();
  Stream<dynamic>? playerProgres;
  BehaviorSubject<Track> playedMedia = BehaviorSubject<Track>.seeded(trackNull);

  LastdotfmCubit({
    required this.playerCubit,
    required CacheDAO cacheDao,
    required SettingsDAO settingsDao,
  })  : _cacheDao = cacheDao,
        _settingsDao = settingsDao,
        super(LastdotfmInitial()) {
    initializeFromDB();
    songTimeTracker();
  }

  @override
  close() async {
    playedMedia.close();
    scrobbleSub?.cancel();
    super.close();
  }

  /// Helper: extract duration in seconds from a [Track].
  int _trackDurationSec(Track t) {
    final ms = t.durationMs?.toInt();
    return ms != null ? ms ~/ 1000 : 0;
  }

  Duration? _trackDuration(Track t) {
    final ms = t.durationMs?.toInt();
    return ms != null ? Duration(milliseconds: ms) : null;
  }

  Future<void> songTimeTracker() async {
    while (playerCubit.playerInitState != PlayerInitState.initialized) {
      log('Waiting for player to be initialized.', name: 'Last.FM');
      await Future.delayed(const Duration(seconds: 2));
    }

    scrobbleSub = playerCubit.progressStreams.listen((event) {
      final currentTrack = playerCubit.bloomeePlayer.currentMedia;

      if (playerCubit.bloomeePlayer.engine.playing &&
          playerCubit.bloomeePlayer.engine.state == EngineState.ready) {
        if (lastPlayed != currentTrack || !stopwatch.isRunning) {
          if (stopwatch.isRunning) {
            stopwatch.stop();
            stopwatch.reset();
          }
          stopwatch.start();
          lastPlayed = currentTrack;
        } else if ((stopwatch.elapsed.inSeconds > 30 ||
                (stopwatch.elapsed.inSeconds /
                        (_trackDuration(currentTrack) ??
                                const Duration(hours: 1))
                            .inSeconds) >
                    0.5) &&
            currentTrack == lastPlayed &&
            currentTrack != playedMedia.value) {
          playedMedia.add(currentTrack);
          log('Scrobbling: ${currentTrack.title}', name: 'Last.FM');
          scrobble(lastPlayed).then((value) {
            log(value ? 'Scrobble success.' : 'Scrobble failed.',
                name: 'Last.FM');
          });
        }
      } else if (lastPlayed != currentTrack) {
        stopwatch.stop();
        stopwatch.reset();
      } else {
        stopwatch.stop();
      }
    });
  }

  Future<void> initializeFromDB() async {
    log('Getting Last.FM Keys from DB', name: 'Last.FM');
    final username = await _cacheDao.getApiToken(CacheKeys.lFMUsername);
    final apiKey = await _cacheDao.getApiToken(CacheKeys.lFMApiKey);
    final apiSecret = await _cacheDao.getApiToken(CacheKeys.lFMSecret);
    final session = await _cacheDao.getApiToken(CacheKeys.lFMSession);

    if (apiKey != null &&
        apiSecret != null &&
        username != null &&
        apiKey.isNotEmpty &&
        username.isNotEmpty &&
        apiSecret.isNotEmpty) {
      LastFmAPI.setAPIKey(apiKey);
      LastFmAPI.setAPISecret(apiSecret);
      if (session != null && session.isNotEmpty) {
        LastFmAPI.sessionKey = session;
        LastFmAPI.username = username;
        LastFmAPI.initialized = true;
        emit(LastdotfmIntialized(
            apiKey: apiKey,
            apiSecret: apiSecret,
            sessionKey: session,
            username: username));
      }
    }
    startUpCheck();
    log('Last.FM Keys from DB: $apiKey, $apiSecret, $session', name: 'Last.FM');
  }

  Future<void> fetchSessionkey(
      {required String token,
      required String secret,
      required String apiKey}) async {
    try {
      final sessionMap = await LastFmAPI.fetchSessionKey(token);
      final session = sessionMap['key']!;
      final name = sessionMap['name']!;
      _cacheDao.putApiToken(CacheKeys.lFMUsername, name);
      _cacheDao.putApiToken(CacheKeys.lFMSecret, secret);
      _cacheDao.putApiToken(CacheKeys.lFMApiKey, apiKey);
      _cacheDao.putApiToken(CacheKeys.lFMSession, session);
      log('Session Key: $session', name: 'LastFM API');

      if (session.isNotEmpty && apiKey.isNotEmpty && secret.isNotEmpty) {
        LastFmAPI.sessionKey = session;
        LastFmAPI.username = name;
        LastFmAPI.initialized = true;
        emit(LastdotfmIntialized(
          apiKey: apiKey,
          apiSecret: secret,
          sessionKey: session,
          username: name,
        ));
      }
    } catch (e) {
      log('Error: $e', name: 'Last.FM');
      emit(LastdotfmFailed(message: e.toString()));
    }
  }

  Future<String> startAuth(
      {required String apiKey, required String secret}) async {
    LastFmAPI.setAPIKey(apiKey);
    LastFmAPI.setAPISecret(secret);
    final token = await LastFmAPI.fetchRequestToken();
    final url = LastFmAPI.getAuthUrl(token);
    log('Auth URL: $url', name: 'LastFM API');
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return token;
  }

  Future<void> remove() async {
    LastFmAPI.initialized = false;
    LastFmAPI.sessionKey = null;
    LastFmAPI.apiKey = null;
    LastFmAPI.apiSecret = null;
    LastFmAPI.username = null;
    emit(LastdotfmInitial());
    _cacheDao.putApiToken(CacheKeys.lFMSecret, '');
    _cacheDao.putApiToken(CacheKeys.lFMApiKey, '');
    _cacheDao.putApiToken(CacheKeys.lFMSession, '');
    _cacheDao.putApiToken(CacheKeys.lFMUsername, '');
  }

  startUpCheck() async {
    final lastUnScrobbled = await getLFMTrackedCache();
    if (lastUnScrobbled.isNotEmpty) {
      final isSuccess = await scrobbleTrackList(lastUnScrobbled);
      log("Scrobble ${isSuccess ? 'success' : 'failed'}!", name: 'Last.FM');
      if (!isSuccess) {
        lFMCacheTrack(lastUnScrobbled);
      }
    }
  }

  Future<bool> scrobbleTrackList(List<ScrobbleTrack> trackList) async {
    if (LastFmAPI.initialized) {
      try {
        final response = await LastFmAPI.scrobble(trackList);
        log('Scrobble response: $response', name: 'LastFM API');
        return response;
      } catch (e) {
        log('Scrobble failed: $e', name: 'LastFM API');
        lFMCacheTrack(trackList);
      }
    }
    return false;
  }

  Future<bool> scrobble(Track track) async {
    final shouldScrobble = await _settingsDao
        .getSettingBool(CacheKeys.lFMScrobbleSetting, defaultValue: false);

    final durationSec = _trackDurationSec(track);
    final durationMin = durationSec ~/ 60;

    final scrobbleTrack = ScrobbleTrack(
      artist: track.artists.map((a) => a.name).join(', ').ifEmpty('Unknown'),
      trackName: track.title,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      album: track.album?.title ?? 'Unknown',
      duration: durationSec,
      chosenByUser: false,
    );

    if (shouldScrobble ?? false) {
      List<ScrobbleTrack> trackList = await getLFMTrackedCache();
      trackList.add(scrobbleTrack);
      try {
        if (LastFmAPI.initialized &&
            !isTrackNull(track) &&
            (durationMin < 15 || durationSec == 0) &&
            durationSec > 30) {
          final response = await LastFmAPI.scrobble(trackList);
          log('Scrobble response: $response', name: 'LastFM API');
          return response;
        }
      } catch (e) {
        log('Scrobble failed: $e', name: 'LastFM API');
        lFMCacheTrack(trackList);
      }
    }
    return false;
  }

  void lFMCacheTrack(List<ScrobbleTrack> trackList) {
    final trackListMap = trackList.map((e) => e.toJson()).toList();
    _cacheDao.getCacheValue(CacheKeys.lFMTrackedCache).then((value) {
      if (value != null && value != 'null') {
        log('Cache found: ${trackListMap.toString()}', name: 'Last.FM');
        final trackList2 = jsonDecode(value) as List;
        trackList2.addAll(trackListMap);
        _cacheDao.putCache(CacheKeys.lFMTrackedCache, jsonEncode(trackList2));
      } else {
        log('No cache found', name: 'Last.FM');
        _cacheDao.putCache(CacheKeys.lFMTrackedCache, jsonEncode(trackListMap));
      }
    });
  }

  Future<List<ScrobbleTrack>> getLFMTrackedCache() async {
    final trackList = await _cacheDao.getCacheValue(CacheKeys.lFMTrackedCache);
    await _cacheDao.putCache(CacheKeys.lFMTrackedCache, 'null');
    if (trackList != null && trackList.isNotEmpty && trackList != 'null') {
      final trackListMap = jsonDecode(trackList) as List;
      return trackListMap.map((e) => ScrobbleTrack.fromJson(e)).toList();
    }
    return [];
  }

  // TODO: Implement via plugin system (search command) when ready.
  // For now returns an empty list since MixedAPI is removed.
  Future<List<Track>> getRecommendedTracks() async {
    if (!LastFmAPI.initialized) {
      while (!LastFmAPI.initialized) {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    // Recommendation logic requires a content-resolver plugin search.
    // This will be implemented once the UI wires up ContentBloc.
    return [];
  }

  /// Get a cached API token by key.
  Future<String?> getApiToken(String key) async {
    return _cacheDao.getApiToken(key);
  }
}

/// Extension to provide a fallback for empty strings.
extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
