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
import 'package:url_launcher/url_launcher.dart';

part 'lastdotfm_state.dart';

class LastdotfmCubit extends Cubit<LastdotfmState> {
  LastFmAPI lastFmAPI = LastFmAPI();
  StreamSubscription? _progressSub;
  BloomeePlayerCubit playerCubit;
  final CacheDAO _cacheDao;
  final SettingsDAO _settingsDao;

  /// The track currently being timed for scrobble eligibility.
  Track _timedTrack = trackNull;

  /// Accumulated play-time for [_timedTrack].
  final Stopwatch _playWatch = Stopwatch();

  /// Whether [_timedTrack] has already been scrobbled in this play session.
  bool _scrobbled = false;

  LastdotfmCubit({
    required this.playerCubit,
    required CacheDAO cacheDao,
    required SettingsDAO settingsDao,
  })  : _cacheDao = cacheDao,
        _settingsDao = settingsDao,
        super(LastdotfmInitial()) {
    initializeFromDB();
    _startTrackingLoop();
  }

  @override
  Future<void> close() async {
    _progressSub?.cancel();
    super.close();
  }

  // ---------------------------------------------------------------------------
  // Track-time tracking
  // ---------------------------------------------------------------------------

  /// Last.fm scrobble rules:
  /// 1. Track must be longer than 30 seconds.
  /// 2. Track is scrobbled when played for >= min(duration * 0.5, 240s).
  Future<void> _startTrackingLoop() async {
    while (playerCubit.playerInitState != PlayerInitState.initialized) {
      await Future.delayed(const Duration(seconds: 2));
    }

    _progressSub = playerCubit.progressStreams.listen((_) {
      _onProgressTick();
    });
  }

  void _onProgressTick() {
    final player = playerCubit.bloomeePlayer;
    final current = player.currentMedia;
    final isPlaying =
        player.engine.playing && player.engine.state == EngineState.ready;

    // Track changed -> reset timing.
    if (current != _timedTrack) {
      _resetTiming(current);
      if (isPlaying) _playWatch.start();
      return;
    }

    // Same track.
    if (isPlaying) {
      if (!_playWatch.isRunning) _playWatch.start();
      if (!_scrobbled && _isScrobbleEligible(current)) {
        _scrobbled = true;
        log('Scrobbling: ${current.title}', name: 'Last.FM');
        _scrobbleTrack(current);
      }
    } else {
      // Paused / buffering - pause the stopwatch but keep accumulated time.
      _playWatch.stop();
    }
  }

  void _resetTiming(Track newTrack) {
    _playWatch
      ..stop()
      ..reset();
    _timedTrack = newTrack;
    _scrobbled = false;
  }

  bool _isScrobbleEligible(Track track) {
    if (isTrackNull(track)) return false;
    final durationSec = _trackDurationSec(track);
    // Track must be > 30 seconds (unknown-duration tracks scrobble after 240s).
    if (durationSec > 0 && durationSec <= 30) return false;

    final elapsed = _playWatch.elapsed.inSeconds;
    if (durationSec > 0) {
      // Scrobble after >= min(50% of track, 240 seconds).
      final threshold = (durationSec * 0.5).ceil().clamp(0, 240);
      return elapsed >= threshold;
    }
    // Unknown duration - scrobble after 4 minutes.
    return elapsed >= 240;
  }

  // ---------------------------------------------------------------------------
  // Scrobble execution
  // ---------------------------------------------------------------------------

  Future<void> _scrobbleTrack(Track track) async {
    final shouldScrobble = await _settingsDao.getSettingBool(
      CacheKeys.lFMScrobbleSetting,
      defaultValue: false,
    );
    if (shouldScrobble != true) return;

    final durationSec = _trackDurationSec(track);
    final entry = ScrobbleTrack(
      artist: track.artists.map((a) => a.name).join(', ').ifEmpty('Unknown'),
      trackName: track.title,
      album: track.album?.title ?? 'Unknown',
      duration: durationSec > 0 ? durationSec : null,
      chosenByUser: false,
    );

    // Append to offline cache first (safe against crashes).
    await _appendToCache(entry);

    // Attempt to flush the entire cache.
    await _flushCache();
  }

  /// Flush all cached scrobble entries to Last.fm.
  Future<void> _flushCache() async {
    if (!LastFmAPI.initialized) return;
    final cached = await _readCache();
    if (cached.isEmpty) return;

    try {
      // Last.fm accepts max 50 tracks per call.
      for (var i = 0; i < cached.length; i += 50) {
        final batch = cached.sublist(i, (i + 50).clamp(0, cached.length));
        final ok = await LastFmAPI.scrobble(batch);
        if (!ok) {
          log('Scrobble batch failed (offset $i)', name: 'Last.FM');
          return; // Keep cache intact for next attempt.
        }
      }
      // All batches succeeded - clear the cache.
      await _clearCache();
      log('Scrobble cache flushed (${cached.length} tracks)', name: 'Last.FM');
    } catch (e) {
      log('Scrobble failed: $e', name: 'Last.FM');
      // Cache stays intact for retry on next scrobble or startup.
    }
  }

  // ---------------------------------------------------------------------------
  // Offline cache helpers (uses toMap/fromMap to avoid double-encoding)
  // ---------------------------------------------------------------------------

  Future<void> _appendToCache(ScrobbleTrack entry) async {
    final cached = await _readCache();
    cached.add(entry);
    await _writeCache(cached);
  }

  Future<List<ScrobbleTrack>> _readCache() async {
    final raw = await _cacheDao.getCacheValue(CacheKeys.lFMTrackedCache);
    if (raw == null || raw.isEmpty || raw == 'null') return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ScrobbleTrack.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Corrupt scrobble cache, clearing: $e', name: 'Last.FM');
      await _clearCache();
      return [];
    }
  }

  Future<void> _writeCache(List<ScrobbleTrack> tracks) async {
    final encoded = jsonEncode(tracks.map((t) => t.toMap()).toList());
    await _cacheDao.putCache(CacheKeys.lFMTrackedCache, encoded);
  }

  Future<void> _clearCache() async {
    await _cacheDao.putCache(CacheKeys.lFMTrackedCache, 'null');
  }

  // ---------------------------------------------------------------------------
  // Initialization & auth
  // ---------------------------------------------------------------------------

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
    // Flush any leftover scrobbles from previous session.
    await _flushCache();
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _trackDurationSec(Track t) {
    final ms = t.durationMs?.toInt();
    return ms != null ? ms ~/ 1000 : 0;
  }

  // TODO: Implement via plugin system (search command) when ready.
  Future<List<Track>> getRecommendedTracks() async {
    if (!LastFmAPI.initialized) {
      while (!LastFmAPI.initialized) {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    return [];
  }

  Future<String?> getApiToken(String key) async {
    return _cacheDao.getApiToken(key);
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
