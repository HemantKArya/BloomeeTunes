import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/services/scrobble/lastfm_api.dart';
import 'package:Bloomee/services/scrobble/playback_session_tracker.dart';
import 'package:Bloomee/services/scrobble/scrobble_provider.dart';
import 'package:Bloomee/services/scrobble/scrobble_queue.dart';
import 'package:Bloomee/services/scrobble/scrobble_status.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/meta_resolver/chart_item_resolver.dart';
import 'package:Bloomee/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:url_launcher/url_launcher.dart';

part 'lastdotfm_state.dart';

class LastdotfmCubit extends Cubit<LastdotfmState> {
  LastFmAPI lastFmAPI = LastFmAPI();
  BloomeePlayerCubit playerCubit;
  final CacheDAO _cacheDao;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;

  final ScrobbleProvider _provider = LastFmProvider();
  late final ScrobbleQueue _queue;
  late final PlaybackSessionTracker<Track> _tracker;
  final List<StreamSubscription> _subs = [];

  LastdotfmCubit({
    required this.playerCubit,
    required CacheDAO cacheDao,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _cacheDao = cacheDao,
        _settingsDao = settingsDao,
        _pluginService = pluginService,
        super(LastdotfmInitial()) {
    _queue = ScrobbleQueue(cacheDao: cacheDao, provider: _provider);
    _tracker = PlaybackSessionTracker<Track>(
      keyOf: (t) => isTrackNull(t) ? '' : '${t.id}|${t.title}',
      durationSecOf: _trackDurationSec,
      onNowPlaying: _sendNowPlaying,
      onScrobble: _onScrobble,
    );
    initializeFromDB();
    _wirePlayerEvents();
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      s.cancel();
    }
    _tracker.dispose();
    _queue.dispose();
    return super.close();
  }

  /// Event driven: sample the player only when something relevant changes.
  void _wirePlayerEvents() {
    final player = playerCubit.bloomeePlayer;
    final engine = player.engine;
    void sample() {
      final t = player.currentMedia;
      _tracker.update(
        track: isTrackNull(t) ? null : t,
        playing: engine.playing,
      );
    }

    _subs
      ..add(engine.playingStream.listen((_) => sample()))
      ..add(engine.stateStream.listen((_) => sample()))
      ..add(engine.durationStream.listen((_) => sample()))
      ..add(engine.completionStream.listen((_) {
        sample();
        _tracker.onCompleted();
      }))
      ..add(Connectivity().onConnectivityChanged.listen((r) {
        if (!r.contains(ConnectivityResult.none)) _queue.kick();
      }));
    sample();
  }

  /// Live scrobble pipeline status (queued / last sent / last error).
  ValueListenable<ScrobbleStatus> get scrobbleStatus => _queue.status;

  /// Retry delivery right now.
  void syncNow() => _queue.kick();

  Future<void> clearScrobbleQueue() => _queue.clear();

  String _artistOf(Track t) =>
      t.artists.map((a) => a.name).join(', ').ifEmpty('Unknown');

  ScrobbleTrack _entry(Track t, {int startedAt = 0}) {
    final d = _trackDurationSec(t);
    return ScrobbleTrack(
      artist: _artistOf(t),
      trackName: t.title,
      album: t.album?.title,
      duration: d > 0 ? d : null,
      timestamp: startedAt,
      chosenByUser: false,
    );
  }

  Future<bool> _enabled() async =>
      await _settingsDao.getSettingBool(CacheKeys.lFMScrobbleSetting,
          defaultValue: false) ==
      true;

  Future<void> _sendNowPlaying(Track track) async {
    if (!_provider.isReady || !await _enabled()) return;
    try {
      await _provider.nowPlaying(_entry(track));
    } catch (e) {
      log('nowPlaying error: $e', name: 'Last.FM');
    }
  }

  Future<void> _onScrobble(Track track, int startedAt) async {
    if (!await _enabled()) return;
    log('Scrobbling: ${track.title}', name: 'Last.FM');
    await _queue.enqueue(_entry(track, startedAt: startedAt));
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
    await _queue.migrateLegacy();
    _queue.kick();
    await _queue.refreshPending();
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
        _queue.kick();
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

  int _trackDurationSec(Track t) {
    final ms = t.durationMs?.toInt();
    return ms != null ? ms ~/ 1000 : 0;
  }

  /// Fetches the user's Last.fm recommended tracks and resolves each one
  /// to a playable [Track] via the plugin resolver system.
  ///
  /// [resolverPluginIds] — ordered list of content-resolver plugin IDs to use.
  /// Returns an empty list when Last.fm is not initialised or no resolvers are
  /// available.
  Future<List<Track>> getRecommendedTracks({
    List<String> resolverPluginIds = const [],
  }) async {
    if (!LastFmAPI.initialized) return [];
    if (resolverPluginIds.isEmpty) return [];

    final Map<String, dynamic> response;
    try {
      response = await LastFmAPI.getUserRecommendedList();
    } catch (e) {
      log('Failed to fetch Last.fm recommended list: $e', name: 'Last.FM');
      return [];
    }

    final playlist = response['playlist'] as List? ?? [];
    if (playlist.isEmpty) return [];

    final resolver = ChartItemResolver(
      resolver: CrossPluginResolver(pluginService: _pluginService),
    );
    final tracks = <Track>[];

    // Resolve up to 10 tracks (API can return many; avoid over-fetching).
    for (final raw in playlist.take(10)) {
      final item = raw as Map<String, dynamic>? ?? {};
      final title = (item['name'] as String? ?? '').trim();
      if (title.isEmpty) continue;

      final artists = (item['artists'] as List? ?? [])
          .map((a) => (a as Map<String, dynamic>?)?['name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      // Build a minimal synthetic Track so ChartItemResolver can search for it.
      final syntheticTrack = Track(
        id: '',
        title: title,
        artists:
            artists.map((name) => ArtistSummary(id: '', name: name)).toList(),
        thumbnail: const Artwork(
          url: '',
          layout: ImageLayout.square,
        ),
        isExplicit: false,
      );
      final chartItem = ChartItem(
        item: MediaItem_Track(syntheticTrack),
        rank: 0,
        trend: Trend.unknown,
      );

      try {
        final result = await resolver.resolve(
          chartItem: chartItem,
          resolverPluginIds: resolverPluginIds,
        );
        if (result != null) tracks.add(result.resolvedTrack);
      } catch (e) {
        log('Failed to resolve Last.fm track "$title": $e', name: 'Last.FM');
      }
    }

    return tracks;
  }

  Future<String?> getApiToken(String key) async {
    return _cacheDao.getApiToken(key);
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
