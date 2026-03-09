import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

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

  const SmartTrackReplacementApplyResult({required this.updatedPlaylists});
}

class SmartTrackReplacementService {
  final PluginService _pluginService;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;

  static const Set<String> _excludedPlaylistNames = {
    SettingKeys.localMusicPlaylist,
    SettingKeys.downloadPlaylist,
    SettingKeys.recentlyPlayedPlaylist,
  };

  SmartTrackReplacementService({
    required PluginService pluginService,
    required PlaylistDAO playlistDao,
    required SettingsDAO settingsDao,
  })  : _pluginService = pluginService,
        _playlistDao = playlistDao,
        _settingsDao = settingsDao;

  factory SmartTrackReplacementService.create(PluginService pluginService) {
    final trackDao = TrackDAO(DBProvider.db);
    return SmartTrackReplacementService(
      pluginService: pluginService,
      playlistDao: PlaylistDAO(DBProvider.db, trackDao),
      settingsDao: SettingsDAO(DBProvider.db),
    );
  }

  Future<List<SmartTrackReplacementCandidate>> searchCandidates(
    Track originalTrack, {
    int limit = 8,
  }) async {
    if (isLocalMediaId(originalTrack.id)) return const [];

    final availableResolvers = await _getLoadedResolverPlugins();
    if (availableResolvers.isEmpty) return const [];

    final queries = _buildQueries(originalTrack);
    final candidates = <String, SmartTrackReplacementCandidate>{};

    for (final plugin in availableResolvers) {
      for (final query in queries) {
        try {
          final response = await _pluginService.execute(
            pluginId: plugin.manifest.id,
            request: PluginRequest.contentResolver(
              ContentResolverCommand.search(
                query: query,
                filter: ContentSearchFilter.track,
              ),
            ),
          );

          switch (response) {
            case PluginResponse_Search(:final field0):
              for (final item in field0.items.take(12)) {
                final track = switch (item) {
                  MediaItem_Track(:final field0) => field0,
                  _ => null,
                };
                if (track == null || track.id == originalTrack.id) continue;

                final confidence = _scoreTrackMatch(originalTrack, track);
                if (confidence < 0.45) continue;

                final existing = candidates[track.id];
                if (existing == null || confidence > existing.confidence) {
                  candidates[track.id] = SmartTrackReplacementCandidate(
                    track: track,
                    pluginId: plugin.manifest.id,
                    pluginName: plugin.name,
                    confidence: confidence,
                  );
                }
              }
            default:
          }
        } catch (e) {
          log(
            'Smart replace search failed for ${plugin.manifest.id}: $e',
            name: 'SmartTrackReplacementService',
          );
        }
      }
    }

    final sorted = candidates.values.toList(growable: false)
      ..sort((left, right) => right.confidence.compareTo(left.confidence));
    return sorted.take(limit).toList(growable: false);
  }

  Future<SmartTrackReplacementCandidate?> findBestReplacement(
    Track originalTrack,
  ) async {
    final candidates = await searchCandidates(originalTrack, limit: 1);
    return candidates.isEmpty ? null : candidates.first;
  }

  Future<SmartTrackReplacementApplyResult> applyReplacement({
    required Track originalTrack,
    required Track replacement,
  }) async {
    final affectedPlaylistNames =
        await _playlistDao.getPlaylistsContainingTrack(
      originalTrack.id,
    );

    final updatedPlaylists = <String>[];
    for (final playlistName in affectedPlaylistNames) {
      if (_excludedPlaylistNames.contains(playlistName)) continue;

      final playlist = await _playlistDao.getPlaylistByName(playlistName);
      if (playlist == null) continue;

      final orderedTracks =
          (await _playlistDao.loadPlaylist(playlistName)).tracks;
      final replacedTracks = _replaceTrackInOrder(
        orderedTracks,
        originalTrack.id,
        replacement,
      );
      final changed = replacedTracks.length != orderedTracks.length ||
          replacedTracks.asMap().entries.any(
                (entry) => orderedTracks[entry.key].id != entry.value.id,
              );
      if (!changed) continue;

      await _playlistDao.setPlaylistTracks(playlist.id, replacedTracks);
      updatedPlaylists.add(playlistName);
    }

    return SmartTrackReplacementApplyResult(updatedPlaylists: updatedPlaylists);
  }

  List<Track> _replaceTrackInOrder(
    List<Track> tracks,
    String originalTrackId,
    Track replacement,
  ) {
    final seenIds = <String>{};
    return tracks
        .map((track) => track.id == originalTrackId ? replacement : track)
        .where((track) => seenIds.add(track.id))
        .toList(growable: false);
  }

  Future<List<PluginInfo>> _getLoadedResolverPlugins() async {
    final available = await _pluginService.getAvailablePlugins();
    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final resolverPlugins = available
        .where(
          (plugin) =>
              plugin.pluginType == PluginType.contentResolver &&
              loadedIds.contains(plugin.manifest.id),
        )
        .toList();

    final storedPriority = await _settingsDao.getSettingStr(
      SettingKeys.resolverPriority,
      defaultValue: '[]',
    );
    List<String> priority = const [];
    if (storedPriority != null && storedPriority.isNotEmpty) {
      try {
        priority = (jsonDecode(storedPriority) as List).cast<String>();
      } catch (e) {
        log('Failed to decode resolver priority: $e',
            name: 'SmartTrackReplacementService');
      }
    }

    resolverPlugins.sort((left, right) {
      final leftIndex = priority.indexOf(left.manifest.id);
      final rightIndex = priority.indexOf(right.manifest.id);
      final normalizedLeft = leftIndex == -1 ? 1 << 20 : leftIndex;
      final normalizedRight = rightIndex == -1 ? 1 << 20 : rightIndex;
      if (normalizedLeft != normalizedRight) {
        return normalizedLeft.compareTo(normalizedRight);
      }
      return left.name.compareTo(right.name);
    });

    return resolverPlugins;
  }

  List<String> _buildQueries(Track track) {
    final artists = _artistNames(track.artists);
    final album = track.album?.title.trim() ?? '';
    final queries = <String>{
      track.title.trim(),
      '${track.title} $artists'.trim(),
      if (album.isNotEmpty) '${track.title} $artists $album'.trim(),
    };
    return queries.where((query) => query.isNotEmpty).toList(growable: false);
  }

  double _scoreTrackMatch(Track original, Track candidate) {
    final title = _blendedTextSimilarity(original.title, candidate.title);
    final artists = _artistSimilarity(original.artists, candidate.artists);
    final album = original.album != null && candidate.album != null
        ? _blendedTextSimilarity(original.album!.title, candidate.album!.title)
        : 0.55;
    final duration =
        _durationSimilarity(original.durationMs, candidate.durationMs);

    return (title * 0.46 + artists * 0.29 + album * 0.10 + duration * 0.15)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _artistSimilarity(
    List<ArtistSummary> left,
    List<ArtistSummary> right,
  ) {
    if (left.isEmpty || right.isEmpty) {
      return _blendedTextSimilarity(_artistNames(left), _artistNames(right));
    }

    final leftNames = left.map((artist) => artist.name).toList(growable: false);
    final rightNames =
        right.map((artist) => artist.name).toList(growable: false);

    double total = 0;
    for (final leftName in leftNames) {
      var best = 0.0;
      for (final rightName in rightNames) {
        best = math.max(best, _blendedTextSimilarity(leftName, rightName));
      }
      total += best;
    }

    return (total / leftNames.length).clamp(0.0, 1.0).toDouble();
  }

  double _durationSimilarity(BigInt? left, BigInt? right) {
    if (left == null || right == null) return 0.55;
    final diffMs = (left - right).abs().toDouble();
    if (diffMs <= 2000) return 1.0;
    if (diffMs >= 25000) return 0.0;
    return (1 - (diffMs / 25000)).clamp(0.0, 1.0).toDouble();
  }

  double _blendedTextSimilarity(String? left, String? right) {
    final normalizedLeft = _normalized(left);
    final normalizedRight = _normalized(right);
    if (normalizedLeft.isEmpty || normalizedRight.isEmpty) return 0;
    if (normalizedLeft == normalizedRight) return 1.0;

    final direct = fw.ratio(normalizedLeft, normalizedRight) / 100;
    final partial = fw.partialRatio(normalizedLeft, normalizedRight) / 100;
    final sorted = fw.tokenSortRatio(normalizedLeft, normalizedRight) / 100;

    return (direct * 0.4 + partial * 0.25 + sorted * 0.35)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  String _artistNames(List<ArtistSummary> artists) {
    return artists
        .map((artist) => artist.name.trim())
        .where((name) => name.isNotEmpty)
        .join(' ');
  }

  String _normalized(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
