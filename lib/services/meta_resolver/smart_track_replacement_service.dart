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

// ── Pre-compiled RegExp constants ────────────────────────────────────────────

final RegExp _kBracketsEtc = RegExp(r'[$$$$\(\){}]');
final RegExp _kAsciiPunctuation =
    RegExp(r'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]');
final RegExp _kMultiSpace = RegExp(r'\s+');
final RegExp _kParenthetical = RegExp(r'\(.*?\)');
final RegExp _kFeatSuffix = RegExp(r'\b(?:feat|ft|featuring)\b.*$');
final RegExp _kVersionWords =
    RegExp(r'\b(?:remaster(?:ed)?|version|edit|mix|remix)\b');
final RegExp _kEditionWords =
    RegExp(r'\b(?:single|album|deluxe|edition|bonus)\b');

/// Pre-compiled word-boundary patterns for version-tag detection.
final Map<String, List<RegExp>> _kVersionTagPatterns = {
  'live': [
    RegExp(r'\blive\b'),
    RegExp(r'\blive at\b'),
    RegExp(r'\blive from\b'),
    RegExp(r'\blive in\b'),
  ],
  'acoustic': [RegExp(r'\bacoustic\b')],
  'karaoke': [RegExp(r'\bkaraoke\b')],
  'instrumental': [RegExp(r'\binstrumental\b')],
  'remix': [RegExp(r'\bremix\b'), RegExp(r'\bmixed\b'), RegExp(r'\brmx\b')],
  'remaster': [RegExp(r'\bremaster\b'), RegExp(r'\bremastered\b')],
  'clean': [RegExp(r'\bclean\b')],
  'explicit': [RegExp(r'\bexplicit\b')],
  'demo': [RegExp(r'\bdemo\b')],
  'cover': [RegExp(r'\bcover\b')],
  'radio': [RegExp(r'\bradio edit\b'), RegExp(r'\bradio version\b')],
  'extended': [RegExp(r'\bextended\b')],
  'unplugged': [RegExp(r'\bunplugged\b')],
  'stripped': [RegExp(r'\bstripped\b')],
};

// ── Constants ────────────────────────────────────────────────────────────────

/// Minimum confidence threshold for a candidate to be considered viable.
const double _kMinConfidence = 0.45;

/// Confidence above which we accept immediately without querying further.
const double _kEarlyAcceptConfidence = 0.93;

/// Timeout for each individual plugin search call.
const Duration _kPluginTimeout = Duration(seconds: 10);

/// Maximum results to inspect per search query.
const int _kMaxResultsPerQuery = 12;

// ── Public types ─────────────────────────────────────────────────────────────

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

  @override
  String toString() =>
      'Candidate(plugin=$pluginName, confidence=${(confidence * 100).toStringAsFixed(1)}%, '
      'track="${track.title}")';
}

class SmartTrackReplacementApplyResult {
  final List<String> updatedPlaylists;
  final int skippedDuplicates;

  const SmartTrackReplacementApplyResult({
    required this.updatedPlaylists,
    this.skippedDuplicates = 0,
  });
}

// ── Service ──────────────────────────────────────────────────────────────────

class SmartTrackReplacementService {
  final PluginService _pluginService;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;

  /// Cached resolver priority list. Invalidated on each search since it's
  /// cheap to decode and may change between calls.
  List<PluginInfo>? _cachedResolvers;

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

  /// Invalidate cached plugin list (call when plugins are loaded/unloaded).
  void invalidateCache() => _cachedResolvers = null;

  // ── Search ───────────────────────────────────────────────────────────────

  Future<List<SmartTrackReplacementCandidate>> searchCandidates(
    Track originalTrack, {
    int limit = 8,
  }) async {
    if (isLocalMediaId(originalTrack.id)) return const [];

    final availableResolvers = await _getLoadedResolverPlugins();
    if (availableResolvers.isEmpty) return const [];

    final queries = _buildQueries(originalTrack);
    if (queries.isEmpty) return const [];

    final candidates = <String, SmartTrackReplacementCandidate>{};
    SmartTrackReplacementCandidate? earlyWinner;

    // ── Phase 1: Query all plugins in parallel, each plugin runs its
    //    queries sequentially (allows early exit per plugin). ──────────────

    final futures = <Future<void>>[];
    for (final plugin in availableResolvers) {
      futures.add(
        _searchPlugin(
          plugin: plugin,
          queries: queries,
          originalTrack: originalTrack,
          onCandidate: (candidate) {
            final existing = candidates[candidate.track.id];
            if (existing == null ||
                candidate.confidence > existing.confidence) {
              candidates[candidate.track.id] = candidate;
            }
            // Track best for early-exit signal.
            if (candidate.confidence >= _kEarlyAcceptConfidence) {
              earlyWinner ??= candidate;
            }
          },
        ),
      );
    }

    await Future.wait(futures);

    if (earlyWinner != null) {
      log(
        'Early accept: ${earlyWinner!.confidence.toStringAsFixed(3)} '
        'from ${earlyWinner!.pluginName}',
        name: 'SmartTrackReplacementService',
      );
    }

    final sorted = candidates.values.toList(growable: false)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final result = sorted.take(limit).toList(growable: false);

    log(
      'Found ${candidates.length} candidates for "${originalTrack.title}", '
      'returning top ${result.length}',
      name: 'SmartTrackReplacementService',
    );

    return result;
  }

  Future<SmartTrackReplacementCandidate?> findBestReplacement(
    Track originalTrack,
  ) async {
    final candidates = await searchCandidates(originalTrack, limit: 1);
    if (candidates.isEmpty) return null;
    final best = candidates.first;
    return best.confidence >= _kMinConfidence ? best : null;
  }

  /// Search a single plugin with all queries. Queries run sequentially
  /// within a plugin to allow early exit on high-confidence match.
  Future<void> _searchPlugin({
    required PluginInfo plugin,
    required List<String> queries,
    required Track originalTrack,
    required void Function(SmartTrackReplacementCandidate) onCandidate,
  }) async {
    double bestConfidenceThisPlugin = 0;

    for (final query in queries) {
      try {
        final response = await _pluginService
            .execute(
              pluginId: plugin.manifest.id,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: query,
                  filter: ContentSearchFilter.track,
                ),
              ),
            )
            .timeout(_kPluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            for (final item in field0.items.take(_kMaxResultsPerQuery)) {
              final track = switch (item) {
                MediaItem_Track(:final field0) => field0,
                _ => null,
              };
              if (track == null || track.id == originalTrack.id) continue;

              final confidence = _scoreTrackMatch(originalTrack, track);
              if (confidence < _kMinConfidence) continue;

              onCandidate(SmartTrackReplacementCandidate(
                track: track,
                pluginId: plugin.manifest.id,
                pluginName: plugin.name,
                confidence: confidence,
              ));

              if (confidence > bestConfidenceThisPlugin) {
                bestConfidenceThisPlugin = confidence;
              }
            }
          default:
        }

        // Early exit: skip remaining queries for this plugin if we
        // already found an excellent match.
        if (bestConfidenceThisPlugin >= _kEarlyAcceptConfidence) {
          log(
            'Early exit for ${plugin.manifest.id} at '
            '${bestConfidenceThisPlugin.toStringAsFixed(3)}',
            name: 'SmartTrackReplacementService',
          );
          break;
        }
      } catch (e) {
        log(
          'Search query "$query" failed for ${plugin.manifest.id}: $e',
          name: 'SmartTrackReplacementService',
        );
      }
    }
  }

  // ── Apply replacement ────────────────────────────────────────────────────

  Future<SmartTrackReplacementApplyResult> applyReplacement({
    required Track originalTrack,
    required Track replacement,
  }) async {
    final affectedPlaylistNames =
        await _playlistDao.getPlaylistsContainingTrack(originalTrack.id);

    // Filter excluded playlists early, before loading playlist data.
    final eligibleNames = affectedPlaylistNames
        .where((name) => !_excludedPlaylistNames.contains(name))
        .toList(growable: false);

    final updatedPlaylists = <String>[];
    int skippedDuplicates = 0;

    for (final playlistName in eligibleNames) {
      final playlist = await _playlistDao.getPlaylistByName(playlistName);
      if (playlist == null) continue;

      final orderedTracks =
          (await _playlistDao.loadPlaylist(playlistName)).tracks;

      // Check if the replacement already exists in this playlist.
      final replacementAlreadyExists =
          orderedTracks.any((t) => t.id == replacement.id);
      if (replacementAlreadyExists) {
        // Remove the original rather than creating a duplicate.
        final filtered =
            orderedTracks.where((t) => t.id != originalTrack.id).toList();
        if (filtered.length != orderedTracks.length) {
          await _playlistDao.setPlaylistTracks(playlist.id, filtered);
          updatedPlaylists.add(playlistName);
          skippedDuplicates++;
          log(
            'Playlist "$playlistName": removed original (replacement already '
            'present)',
            name: 'SmartTrackReplacementService',
          );
        }
        continue;
      }

      // Replace in-place, preserving order.
      final replacedTracks = orderedTracks
          .map((t) => t.id == originalTrack.id ? replacement : t)
          .toList(growable: false);

      // Verify something actually changed.
      final changed = replacedTracks
          .asMap()
          .entries
          .any((e) => orderedTracks[e.key].id != e.value.id);
      if (!changed) continue;

      await _playlistDao.setPlaylistTracks(playlist.id, replacedTracks);
      updatedPlaylists.add(playlistName);
      log(
        'Playlist "$playlistName": replaced track in-place',
        name: 'SmartTrackReplacementService',
      );
    }

    return SmartTrackReplacementApplyResult(
      updatedPlaylists: updatedPlaylists,
      skippedDuplicates: skippedDuplicates,
    );
  }

  // ── Plugin discovery ─────────────────────────────────────────────────────

  Future<List<PluginInfo>> _getLoadedResolverPlugins() async {
    // Use cached list if available.
    if (_cachedResolvers != null) return _cachedResolvers!;

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

    var priority = const <String>[];
    if (storedPriority != null && storedPriority.isNotEmpty) {
      try {
        priority = (jsonDecode(storedPriority) as List).cast<String>();
      } catch (e) {
        log(
          'Failed to decode resolver priority: $e',
          name: 'SmartTrackReplacementService',
        );
      }
    }

    resolverPlugins.sort((left, right) {
      final leftIndex = priority.indexOf(left.manifest.id);
      final rightIndex = priority.indexOf(right.manifest.id);
      final normLeft = leftIndex == -1 ? 1 << 20 : leftIndex;
      final normRight = rightIndex == -1 ? 1 << 20 : rightIndex;
      if (normLeft != normRight) return normLeft.compareTo(normRight);
      return left.name.compareTo(right.name);
    });

    _cachedResolvers = resolverPlugins;
    return resolverPlugins;
  }

  // ── Query building ───────────────────────────────────────────────────────

  List<String> _buildQueries(Track track) {
    final title = track.title.trim();
    final simplified = _simplifyTitle(title);
    final artists = _artistNames(track.artists);
    final primaryArtist =
        track.artists.isNotEmpty ? track.artists.first.name.trim() : '';
    final album = track.album?.title.trim() ?? '';

    final seen = <String>{};
    final queries = <String>[];

    void addQuery(String query) {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;
      final key = _normalized(trimmed);
      if (key.isEmpty || seen.contains(key)) return;
      seen.add(key);
      queries.add(trimmed);
    }

    // Most specific → least specific.
    addQuery('$title $artists');
    if (simplified != _normalized(title)) {
      addQuery('$simplified $artists');
    }
    addQuery('$title $primaryArtist');
    if (album.isNotEmpty) {
      addQuery('$title $primaryArtist $album');
    }
    addQuery(title);
    if (simplified.isNotEmpty && simplified != _normalized(title)) {
      addQuery(simplified);
    }

    return queries;
  }

  // ── Scoring ──────────────────────────────────────────────────────────────

  double _scoreTrackMatch(Track original, Track candidate) {
    // Fast path: exact normalized title + artist match.
    final origTitleNorm = _normalized(original.title);
    final candTitleNorm = _normalized(candidate.title);
    final origArtistKey = _artistKey(original.artists);
    final candArtistKey = _artistKey(candidate.artists);

    if (origTitleNorm.isNotEmpty &&
        origTitleNorm == candTitleNorm &&
        origArtistKey.isNotEmpty &&
        origArtistKey == candArtistKey) {
      // Near-perfect match, just adjust for duration.
      final dur =
          _durationSimilarity(original.durationMs, candidate.durationMs);
      return (0.92 + dur * 0.08).clamp(0.0, 1.0);
    }

    final title = _blendedTextSimilarity(original.title, candidate.title);
    final simplifiedTitle = _blendedTextSimilarity(
      _simplifyTitle(original.title),
      _simplifyTitle(candidate.title),
    );
    final artists = _artistSimilarity(original.artists, candidate.artists);
    final duration =
        _durationSimilarity(original.durationMs, candidate.durationMs);
    final versionPenalty = _versionPenalty(
      original.title,
      original.album?.title,
      candidate.title,
      candidate.album?.title,
    );

    // Album score: neutral when either side lacks album info.
    final double albumScore;
    final origAlbum = original.album?.title.trim() ?? '';
    final candAlbum = candidate.album?.title.trim() ?? '';
    if (origAlbum.isEmpty || candAlbum.isEmpty) {
      albumScore = 0.0; // No info → no contribution (not a penalty or reward).
    } else {
      albumScore = _blendedTextSimilarity(origAlbum, candAlbum);
    }

    // Adaptive weights: when album info is available, it gets weight;
    // otherwise its weight is redistributed.
    final hasAlbum = origAlbum.isNotEmpty && candAlbum.isNotEmpty;
    final wTitle = hasAlbum ? 0.32 : 0.36;
    final wSimplified = hasAlbum ? 0.12 : 0.14;
    final wArtist = hasAlbum ? 0.28 : 0.32;
    final wAlbum = hasAlbum ? 0.10 : 0.0;
    final wDuration = hasAlbum ? 0.13 : 0.13;

    var score = title * wTitle +
        simplifiedTitle * wSimplified +
        artists * wArtist +
        albumScore * wAlbum +
        duration * wDuration;

    // Exact-match bonuses (guarded against empty strings).
    if (origTitleNorm.isNotEmpty && origTitleNorm == candTitleNorm) {
      score += 0.06;
    }
    final origSimple = _simplifyTitle(original.title);
    final candSimple = _simplifyTitle(candidate.title);
    if (origSimple.isNotEmpty &&
        candSimple.isNotEmpty &&
        origSimple == candSimple) {
      score += 0.04;
    }
    if (origArtistKey.isNotEmpty && origArtistKey == candArtistKey) {
      score += 0.05;
    }

    score -= versionPenalty;

    return score.clamp(0.0, 1.0).toDouble();
  }

  double _artistSimilarity(
    List<ArtistSummary> left,
    List<ArtistSummary> right,
  ) {
    final leftNames = left
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);
    final rightNames = right
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .toList(growable: false);

    if (leftNames.isEmpty || rightNames.isEmpty) {
      return _blendedTextSimilarity(
        _artistNames(left),
        _artistNames(right),
      );
    }

    // Bidirectional best-match pairing.
    double forwardTotal = 0;
    for (final name in leftNames) {
      var best = 0.0;
      for (final other in rightNames) {
        best = math.max(best, _blendedTextSimilarity(name, other));
      }
      forwardTotal += best;
    }
    final forwardAvg = forwardTotal / leftNames.length;

    double reverseTotal = 0;
    for (final name in rightNames) {
      var best = 0.0;
      for (final other in leftNames) {
        best = math.max(best, _blendedTextSimilarity(name, other));
      }
      reverseTotal += best;
    }
    final reverseAvg = reverseTotal / rightNames.length;

    // Combined string comparison for token overlap.
    final combined =
        _blendedTextSimilarity(leftNames.join(' '), rightNames.join(' '));

    // Primary artist bonus.
    final primaryBonus =
        _blendedTextSimilarity(leftNames.first, rightNames.first) > 0.85
            ? 0.05
            : 0.0;

    return (forwardAvg * 0.35 +
            reverseAvg * 0.30 +
            combined * 0.25 +
            primaryBonus)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// Duration similarity using both absolute and relative thresholds.
  double _durationSimilarity(BigInt? left, BigInt? right) {
    if (left == null || right == null) return 0.35;
    final leftMs = left.toDouble();
    final rightMs = right.toDouble();
    if (leftMs <= 0 || rightMs <= 0) return 0.35;

    final diffMs = (leftMs - rightMs).abs();
    final maxMs = math.max(leftMs, rightMs);
    final relativeError = diffMs / maxMs;

    // Absolute component.
    final double absScore;
    if (diffMs <= 1500) {
      absScore = 1.0;
    } else if (diffMs <= 3000) {
      absScore = 0.85;
    } else if (diffMs <= 5000) {
      absScore = 0.55;
    } else if (diffMs <= 10000) {
      absScore = 0.25;
    } else if (diffMs <= 20000) {
      absScore = 0.08;
    } else {
      absScore = 0.0;
    }

    // Relative component.
    final double relScore;
    if (relativeError <= 0.02) {
      relScore = 1.0;
    } else if (relativeError <= 0.05) {
      relScore = 0.85;
    } else if (relativeError <= 0.10) {
      relScore = 0.55;
    } else if (relativeError <= 0.20) {
      relScore = 0.25;
    } else if (relativeError <= 0.35) {
      relScore = 0.08;
    } else {
      relScore = 0.0;
    }

    return (absScore * 0.50 + relScore * 0.50).clamp(0.0, 1.0);
  }

  /// Asymmetric version penalty: missing target tags in the candidate is
  /// penalized more heavily than extra tags in the candidate.
  double _versionPenalty(
    String? targetTitle,
    String? targetAlbum,
    String? candidateTitle,
    String? candidateAlbum,
  ) {
    final targetTags = _versionTags(_joinNonEmpty([targetTitle, targetAlbum]));
    final candidateTags =
        _versionTags(_joinNonEmpty([candidateTitle, candidateAlbum]));

    if (targetTags.isEmpty && candidateTags.isEmpty) return 0;

    final missingFromCandidate = targetTags.difference(candidateTags).length;
    final extraInCandidate = candidateTags.difference(targetTags).length;

    return (missingFromCandidate * 0.08 + extraInCandidate * 0.04)
        .clamp(0.0, 0.25);
  }

  // ── Text utilities ───────────────────────────────────────────────────────

  double _blendedTextSimilarity(String? left, String? right) {
    final normalizedLeft = _normalized(left);
    final normalizedRight = _normalized(right);
    if (normalizedLeft.isEmpty || normalizedRight.isEmpty) return 0;
    if (normalizedLeft == normalizedRight) return 1.0;

    final direct = fw.ratio(normalizedLeft, normalizedRight) / 100;
    final partial = fw.partialRatio(normalizedLeft, normalizedRight) / 100;
    final sorted = fw.tokenSortRatio(normalizedLeft, normalizedRight) / 100;
    final overlap = _tokenOverlap(normalizedLeft, normalizedRight);

    return (direct * 0.35 + partial * 0.20 + sorted * 0.25 + overlap * 0.20)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  String _artistNames(List<ArtistSummary> artists) {
    return artists
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .join(' ');
  }

  /// Sorted, normalized artist key for exact-match comparison.
  String _artistKey(List<ArtistSummary> artists) {
    final names = artists
        .map((a) => _normalized(a.name))
        .where((n) => n.isNotEmpty)
        .toList(growable: false)
      ..sort();
    return names.join('|');
  }

  /// Normalize preserving non-ASCII letters and digits (international titles).
  String _normalized(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return value
        .toLowerCase()
        .replaceAll(_kBracketsEtc, ' ')
        .replaceAll('&', ' and ')
        .replaceAll(_kAsciiPunctuation, ' ')
        .replaceAll(_kMultiSpace, ' ')
        .trim();
  }

  /// Simplify a title by removing parenthetical content, featuring suffixes,
  /// and version/edition markers. Parenthetical removal happens *before*
  /// normalization so `(feat. X)` is actually stripped.
  String _simplifyTitle(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return value
        .trim()
        .replaceAll(_kParenthetical, ' ')
        .toLowerCase()
        .replaceAll(_kFeatSuffix, '')
        .replaceAll(_kVersionWords, ' ')
        .replaceAll(_kEditionWords, ' ')
        .replaceAll(_kAsciiPunctuation, ' ')
        .replaceAll('&', ' and ')
        .replaceAll(_kMultiSpace, ' ')
        .trim();
  }
}

// ── Top-level utility functions ──────────────────────────────────────────────

double _tokenOverlap(String left, String right) {
  final leftTokens = left.split(' ').where((t) => t.isNotEmpty).toSet();
  final rightTokens = right.split(' ').where((t) => t.isNotEmpty).toSet();
  if (leftTokens.isEmpty || rightTokens.isEmpty) return 0;

  final intersection = leftTokens.intersection(rightTokens).length;
  if (intersection == 0) return 0;
  final precision = intersection / rightTokens.length;
  final recall = intersection / leftTokens.length;
  return (2 * precision * recall) / (precision + recall);
}

Set<String> _versionTags(String value) {
  if (value.isEmpty) return const {};
  final normalized = value
      .toLowerCase()
      .replaceAll(_kBracketsEtc, ' ')
      .replaceAll(_kAsciiPunctuation, ' ')
      .replaceAll(_kMultiSpace, ' ')
      .trim();
  if (normalized.isEmpty) return const {};

  final tags = <String>{};
  for (final entry in _kVersionTagPatterns.entries) {
    if (entry.value.any((pattern) => pattern.hasMatch(normalized))) {
      tags.add(entry.key);
    }
  }
  return tags;
}

String _joinNonEmpty(List<String?> parts) {
  return parts.map((p) => p?.trim() ?? '').where((p) => p.isNotEmpty).join(' ');
}
