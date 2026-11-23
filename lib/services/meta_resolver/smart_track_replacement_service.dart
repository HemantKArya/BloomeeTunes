import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';

class SmartTrackReplacementCandidate {
  final Track track;
  final String pluginId;
  final String pluginName;
  final double confidence;

  const SmartTrackReplacementCandidate({
    required this.track,
    required this.pluginId,
    required this.pluginName,
    required this.confidence,
  });
}

/// A replacement written to the library.
class TrackReplacement {
  final Track original;
  final Track replacement;

  /// Names of the playlists that changed.
  final List<String> playlists;

  const TrackReplacement({
    required this.original,
    required this.replacement,
    required this.playlists,
  });
}

/// Finds working copies of tracks whose source is gone, from the loaded
/// resolver plugins, and swaps them into the library.
///
/// Two ways in:
///  * [searchCandidates]: every plugin at once, loose threshold. The Smart
///    Replace dialog, where the user picks.
///  * [findAutoReplacements]: playback fallback. Plugins in the user's
///    priority order, stopping at the first near-certain match, a strict
///    threshold, a time budget, a shared in-flight search and a small cache.
class SmartTrackReplacementService {
  /// Lowest score listed in the dialog.
  static const double listMinConfidence = 0.45;

  /// Lowest score played automatically. A different song by the same artist
  /// scores about 0.42-0.50, a cover about 0.65-0.76; the same song under a
  /// noisier title stays above 0.85.
  static const double autoMinConfidence = 0.8;

  /// Lowest score for which an automatic replacement is also written to the
  /// playlists. An exact title and artist match scores at least 0.92.
  static const double persistMinConfidence = 0.9;

  static const Duration _autoBudget = Duration(seconds: 15);
  static const int _autoQueries = 3;
  static const int _autoLimit = 3;
  static const int _cacheCapacity = 64;
  static const Duration _foundTtl = Duration(minutes: 30);
  static const Duration _notFoundTtl = Duration(minutes: 5);

  static const Set<String> _systemPlaylists = {
    SettingKeys.localMusicPlaylist,
    SettingKeys.downloadPlaylist,
    SettingKeys.recentlyPlayedPlaylist,
  };

  // App-lifetime broadcast: screens showing a playlist listen to apply
  // replacements without reloading.
  static final StreamController<TrackReplacement> _applied =
      StreamController<TrackReplacement>.broadcast();
  static Stream<TrackReplacement> get applied => _applied.stream;

  final CrossPluginResolver _resolver;
  final CrossPluginResolver _autoResolver;
  final PluginService _pluginService;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;
  final LyricsDAO _lyricsDao;

  final LinkedHashMap<String, _CachedSearch> _cache = LinkedHashMap();
  final Map<String, Future<List<SmartTrackReplacementCandidate>>> _inFlight =
      {};

  String? _pluginsKey;
  List<PluginInfo> _plugins = const [];

  SmartTrackReplacementService({
    required PluginService pluginService,
    required PlaylistDAO playlistDao,
    required SettingsDAO settingsDao,
    required LyricsDAO lyricsDao,
  })  : _resolver = CrossPluginResolver(pluginService: pluginService),
        _autoResolver = CrossPluginResolver(
          pluginService: pluginService,
          pluginTimeout: const Duration(seconds: 8),
        ),
        _pluginService = pluginService,
        _playlistDao = playlistDao,
        _settingsDao = settingsDao,
        _lyricsDao = lyricsDao;

  factory SmartTrackReplacementService.create(PluginService pluginService) {
    final trackDao = TrackDAO(DBProvider.db);
    return SmartTrackReplacementService(
      pluginService: pluginService,
      playlistDao: PlaylistDAO(DBProvider.db, trackDao),
      settingsDao: SettingsDAO(DBProvider.db),
      lyricsDao: LyricsDAO(DBProvider.db),
    );
  }

  // ── Search ───────────────────────────────────────────────────────────────

  /// Candidates for the Smart Replace dialog, best first.
  Future<List<SmartTrackReplacementCandidate>> searchCandidates(
    Track original, {
    int limit = 8,
  }) async {
    if (isLocalMediaId(original.id)) return const [];
    final plugins = await _resolverPlugins();
    if (plugins.isEmpty) return const [];

    final scored = await _resolver.resolveTrack(
      target: TrackMatchTarget.fromTrack(original),
      pluginIds: [for (final p in plugins) p.manifest.id],
      minConfidence: listMinConfidence,
      excludeTrackIds: {original.id},
      limit: limit,
    );
    return _withNames(scored, plugins);
  }

  /// Replacements safe to play without asking, best first; empty if none.
  /// Never throws.
  Future<List<SmartTrackReplacementCandidate>> findAutoReplacements(
    Track original,
  ) {
    if (isLocalMediaId(original.id)) return Future.value(const []);

    final cached = _cache.remove(original.id);
    if (cached != null && DateTime.now().isBefore(cached.expires)) {
      _cache[original.id] = cached; // most recently used goes last
      return Future.value(cached.candidates);
    }

    return _inFlight[original.id] ??=
        _searchAuto(original).whenComplete(() => _inFlight.remove(original.id));
  }

  /// Drops the cached result for [trackId], e.g. after none of its
  /// replacements could be played.
  void forget(String trackId) => _cache.remove(trackId);

  Future<List<SmartTrackReplacementCandidate>> _searchAuto(
    Track original,
  ) async {
    var found = const <SmartTrackReplacementCandidate>[];
    try {
      final plugins = await _resolverPlugins();
      if (plugins.isNotEmpty) {
        final target = TrackMatchTarget.fromTrack(original);
        final scored = await _autoResolver
            .resolveTrack(
              target: target,
              pluginIds: [for (final p in plugins) p.manifest.id],
              sequential: true,
              minConfidence: autoMinConfidence,
              earlyAcceptThreshold: 0.92,
              excludeTrackIds: {original.id},
              limit: _autoLimit,
              queries: _autoResolver
                  .buildTrackQueries(target)
                  .take(_autoQueries)
                  .toList(growable: false),
            )
            .timeout(_autoBudget, onTimeout: () => const []);
        found = _withNames(scored, plugins);
      }
    } catch (e) {
      log('Auto replacement search failed for ${original.id}: $e',
          name: 'SmartTrackReplacementService');
    }

    _cache[original.id] = _CachedSearch(
      found,
      DateTime.now().add(found.isEmpty ? _notFoundTtl : _foundTtl),
    );
    while (_cache.length > _cacheCapacity) {
      _cache.remove(_cache.keys.first);
    }
    return found;
  }

  List<SmartTrackReplacementCandidate> _withNames(
    List<ScoredTrackCandidate> scored,
    List<PluginInfo> plugins,
  ) {
    final names = {for (final p in plugins) p.manifest.id: p.name};
    return [
      for (final c in scored)
        SmartTrackReplacementCandidate(
          track: c.track,
          pluginId: c.pluginId,
          pluginName: names[c.pluginId] ?? c.pluginId,
          confidence: c.confidence,
        ),
    ];
  }

  // ── Apply ────────────────────────────────────────────────────────────────

  /// Replaces [original] with [replacement] in every user playlist (in one
  /// transaction, positions kept) and moves its lyrics over.
  Future<TrackReplacement> applyReplacement({
    required Track original,
    required Track replacement,
  }) async {
    final result = await _playlistDao.replaceTrackInPlaylists(
      original.id,
      replacement,
      skipPlaylists: _systemPlaylists,
    );

    try {
      await _lyricsDao.updateMediaId(original.id, replacement.id);
    } catch (e) {
      log('Failed to move lyrics to ${replacement.id}: $e',
          name: 'SmartTrackReplacementService');
    }

    final applied = TrackReplacement(
      original: original,
      replacement: replacement,
      playlists: result.playlists,
    );
    _applied.add(applied);
    log(
        'Replaced ${original.id} with ${replacement.id} in '
        '${result.playlists.length} playlist(s)',
        name: 'SmartTrackReplacementService');
    return applied;
  }

  // ── Plugins ──────────────────────────────────────────────────────────────

  /// Loaded resolver plugins in the user's priority order. Rebuilt only
  /// when the loaded set or the priority setting changes.
  Future<List<PluginInfo>> _resolverPlugins() async {
    final loaded = _pluginService.getLoadedPlugins();
    if (loaded.isEmpty) return const [];
    final priorityRaw = await _settingsDao.getSettingStr(
          SettingKeys.resolverPriority,
          defaultValue: '[]',
        ) ??
        '[]';
    final key = '${([...loaded]..sort()).join(',')}|$priorityRaw';
    if (key == _pluginsKey) return _plugins;

    var priority = const <String>[];
    try {
      priority = (jsonDecode(priorityRaw) as List).cast<String>();
    } catch (e) {
      log('Failed to decode resolver priority: $e',
          name: 'SmartTrackReplacementService');
    }
    int rank(PluginInfo p) {
      final i = priority.indexOf(p.manifest.id);
      return i == -1 ? priority.length : i;
    }

    final loadedIds = loaded.toSet();
    final resolvers = (await _pluginService.getAvailablePlugins())
        .where((p) =>
            p.pluginType == PluginType.contentResolver &&
            loadedIds.contains(p.manifest.id))
        .toList()
      ..sort((a, b) {
        final byRank = rank(a).compareTo(rank(b));
        return byRank != 0 ? byRank : a.name.compareTo(b.name);
      });

    _pluginsKey = key;
    return _plugins = List.unmodifiable(resolvers);
  }
}

class _CachedSearch {
  final List<SmartTrackReplacementCandidate> candidates;
  final DateTime expires;

  const _CachedSearch(this.candidates, this.expires);
}
