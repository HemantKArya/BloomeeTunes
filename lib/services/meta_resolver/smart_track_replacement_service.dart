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

class SmartTrackReplacementApplyResult {
  final List<String> updatedPlaylists;
  final int skippedDuplicates;

  const SmartTrackReplacementApplyResult({
    required this.updatedPlaylists,
    this.skippedDuplicates = 0,
  });
}

class SmartTrackReplacementService {
  final CrossPluginResolver _resolver;
  final PluginService _pluginService;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;
  final LyricsDAO _lyricsDao;

  List<PluginInfo>? _cachedResolvers;

  static const Set<String> _excludedPlaylistNames = {
    SettingKeys.localMusicPlaylist,
    SettingKeys.downloadPlaylist,
    SettingKeys.recentlyPlayedPlaylist,
  };

  SmartTrackReplacementService({
    required CrossPluginResolver resolver,
    required PluginService pluginService,
    required PlaylistDAO playlistDao,
    required SettingsDAO settingsDao,
    required LyricsDAO lyricsDao,
  })  : _resolver = resolver,
        _pluginService = pluginService,
        _playlistDao = playlistDao,
        _settingsDao = settingsDao,
        _lyricsDao = lyricsDao;

  factory SmartTrackReplacementService.create(PluginService pluginService) {
    final trackDao = TrackDAO(DBProvider.db);
    return SmartTrackReplacementService(
      resolver: CrossPluginResolver(pluginService: pluginService),
      pluginService: pluginService,
      playlistDao: PlaylistDAO(DBProvider.db, trackDao),
      settingsDao: SettingsDAO(DBProvider.db),
      lyricsDao: LyricsDAO(DBProvider.db),
    );
  }

  void invalidateCache() => _cachedResolvers = null;

  // ── Search ───────────────────────────────────────────────────────────────

  Future<List<SmartTrackReplacementCandidate>> searchCandidates(
    Track originalTrack, {
    int limit = 8,
  }) async {
    if (isLocalMediaId(originalTrack.id)) return const [];

    final plugins = await _getLoadedResolverPlugins();
    if (plugins.isEmpty) return const [];

    final pluginIds = plugins.map((p) => p.manifest.id).toList(growable: false);
    final pluginNameMap = {
      for (final p in plugins) p.manifest.id: p.name,
    };

    final target = TrackMatchTarget.fromTrack(originalTrack);

    final scored = await _resolver.resolveTrack(
      target: target,
      pluginIds: pluginIds,
      sequential: false,
      excludeTrackIds: {originalTrack.id},
      limit: limit,
    );

    return scored
        .map((c) => SmartTrackReplacementCandidate(
              track: c.track,
              pluginId: c.pluginId,
              pluginName: pluginNameMap[c.pluginId] ?? c.pluginId,
              confidence: c.confidence,
            ))
        .toList(growable: false);
  }

  Future<SmartTrackReplacementCandidate?> findBestReplacement(
    Track originalTrack,
  ) async {
    final candidates = await searchCandidates(originalTrack, limit: 1);
    if (candidates.isEmpty) return null;
    return candidates.first.confidence >= 0.45 ? candidates.first : null;
  }

  // ── Apply ────────────────────────────────────────────────────────────────

  Future<SmartTrackReplacementApplyResult> applyReplacement({
    required Track originalTrack,
    required Track replacement,
  }) async {
    final affected = await _playlistDao.getPlaylistsContainingTrack(
      originalTrack.id,
    );

    final eligible = affected
        .where((name) => !_excludedPlaylistNames.contains(name))
        .toList(growable: false);

    final updated = <String>[];
    int skipped = 0;

    for (final name in eligible) {
      final playlist = await _playlistDao.getPlaylistByName(name);
      if (playlist == null) continue;

      final tracks = (await _playlistDao.loadPlaylist(name)).tracks;

      if (tracks.any((t) => t.id == replacement.id)) {
        final filtered = tracks.where((t) => t.id != originalTrack.id).toList();
        if (filtered.length != tracks.length) {
          await _playlistDao.setPlaylistTracks(playlist.id, filtered);
          updated.add(name);
          skipped++;
          log('Playlist "$name": removed original (replacement present)',
              name: 'SmartTrackReplacementService');
        }
        continue;
      }

      final replaced = tracks
          .map((t) => t.id == originalTrack.id ? replacement : t)
          .toList(growable: false);
      final changed =
          replaced.asMap().entries.any((e) => tracks[e.key].id != e.value.id);
      if (!changed) continue;

      await _playlistDao.setPlaylistTracks(playlist.id, replaced);
      updated.add(name);
      log('Playlist "$name": replaced in-place',
          name: 'SmartTrackReplacementService');
    }

    // Replace ID in lyrics DB so existing lyrics (and offsets) map to the new track.
    try {
      await _lyricsDao.updateMediaId(originalTrack.id, replacement.id);
      log('Lyrics mediaID updated from ${originalTrack.id} to ${replacement.id}',
          name: 'SmartTrackReplacementService');
    } catch (e) {
      log('Failed to update lyrics mediaID during smart replace: $e',
          name: 'SmartTrackReplacementService');
    }

    return SmartTrackReplacementApplyResult(
      updatedPlaylists: updated,
      skippedDuplicates: skipped,
    );
  }

  // ── Plugin priority ──────────────────────────────────────────────────────

  Future<List<PluginInfo>> _getLoadedResolverPlugins() async {
    if (_cachedResolvers != null) return _cachedResolvers!;

    final available = await _pluginService.getAvailablePlugins();
    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final resolvers = available
        .where((p) =>
            p.pluginType == PluginType.contentResolver &&
            loadedIds.contains(p.manifest.id))
        .toList();

    var priority = const <String>[];
    try {
      final stored = await _settingsDao.getSettingStr(
        SettingKeys.resolverPriority,
        defaultValue: '[]',
      );
      if (stored != null && stored.isNotEmpty) {
        priority = (jsonDecode(stored) as List).cast<String>();
      }
    } catch (e) {
      log('Failed to decode resolver priority: $e',
          name: 'SmartTrackReplacementService');
    }

    resolvers.sort((a, b) {
      final ai = priority.indexOf(a.manifest.id);
      final bi = priority.indexOf(b.manifest.id);
      final na = ai == -1 ? 1 << 20 : ai;
      final nb = bi == -1 ? 1 << 20 : bi;
      if (na != nb) return na.compareTo(nb);
      return a.name.compareTo(b.name);
    });

    return _cachedResolvers = resolvers;
  }
}
