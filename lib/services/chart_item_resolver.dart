import 'dart:developer';
import 'dart:math' as math;

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

/// Result of resolving a [ChartItem] to a playable [Track] via cross-plugin
/// content resolution.
class ChartResolveResult {
  final Track resolvedTrack;
  final String resolverPluginId;
  final double confidence;

  const ChartResolveResult({
    required this.resolvedTrack,
    required this.resolverPluginId,
    required this.confidence,
  });
}

/// Cross-plugin metadata resolver that bridges chart-provider items to
/// playable tracks via content-resolver plugins.
///
/// Resolution strategy (cascading fallback):
///   Phase 1 — Exact-match pass with typed filter per plugin (high bar).
///   Phase 2 — Broadened search with `ContentSearchFilter.all` if Phase 1
///             produced no viable candidate (confidence ≥ [_kMinViable]).
///   Phase 3 — Cross-plugin corroboration: candidates that appear from
///             multiple independent plugins get a confidence boost.
///
/// Each plugin is wrapped in try-catch so a single failing plugin never
/// prevents the remaining plugins from being tried.
class ChartItemResolver {
  final PluginService _pluginService;

  /// Candidates below this confidence are not considered viable.
  static const double _kMinViable = 45;

  /// Bonus added when multiple plugins independently return the same
  /// normalized title+artist combination.
  static const double _kCorroborationBonus = 6.0;

  const ChartItemResolver({required PluginService pluginService})
      : _pluginService = pluginService;

  /// Resolve a [ChartItem] to a playable [Track].
  ///
  /// Iterates loaded content resolvers in [resolverPluginIds] order.
  /// Returns the highest-confidence match, or `null` if none is viable.
  Future<ChartResolveResult?> resolve({
    required ChartItem chartItem,
    required Iterable<String> resolverPluginIds,
  }) async {
    final profile = _ResolverProfile.fromMediaItem(chartItem.item);
    final pluginIds = resolverPluginIds.toList(growable: false);

    if (pluginIds.isEmpty) {
      log('No resolver plugins provided', name: 'ChartItemResolver');
      return null;
    }

    // ── Phase 1: Typed search per plugin with per-plugin error isolation ──
    final allCandidates = <_ScoredCandidate>[];
    int pluginsSucceeded = 0;
    int pluginsFailed = 0;

    for (final pluginId in pluginIds) {
      try {
        final candidates = await _collectCandidates(
          pluginId: pluginId,
          profile: profile,
          includeAllFilter: false,
        );
        pluginsSucceeded++;
        allCandidates.addAll(candidates);

        // Early exit: accept immediately if confidence exceeds the threshold
        // AND we've tried at least the top-priority plugin.
        final best = candidates.isEmpty ? null : candidates.first;
        if (best != null && best.confidence >= profile.earlyAcceptThreshold) {
          log(
            'Early accept from $pluginId: ${best.confidence.toStringAsFixed(1)}%',
            name: 'ChartItemResolver',
          );
          return _toResolveResult(best);
        }
      } catch (e) {
        pluginsFailed++;
        log(
          'Plugin $pluginId failed during resolution: $e',
          name: 'ChartItemResolver',
        );
      }
    }

    // ── Phase 2: Broadened search if no viable candidate yet ──────────────
    final currentBest = _pickBest(allCandidates);
    if (currentBest == null || currentBest.confidence < _kMinViable) {
      log(
        'Phase 1 yielded no viable match '
        '(best: ${currentBest?.confidence.toStringAsFixed(1) ?? "none"}, '
        'tried: $pluginsSucceeded ok / $pluginsFailed failed). '
        'Broadening search.',
        name: 'ChartItemResolver',
      );

      for (final pluginId in pluginIds) {
        try {
          final candidates = await _collectCandidates(
            pluginId: pluginId,
            profile: profile,
            includeAllFilter: true,
          );
          allCandidates.addAll(candidates);
        } catch (e) {
          log(
            'Plugin $pluginId failed during broadened search: $e',
            name: 'ChartItemResolver',
          );
        }
      }
    }

    // ── Phase 3: Cross-plugin corroboration ───────────────────────────────
    _applyCrossPluginCorroboration(allCandidates, profile);

    // Pick the global best.
    allCandidates.sort(
      (a, b) => b.confidence.compareTo(a.confidence),
    );

    final winner = allCandidates.isEmpty ? null : allCandidates.first;

    if (winner == null) {
      log(
        'No candidate found '
        '(plugins ok: $pluginsSucceeded, failed: $pluginsFailed)',
        name: 'ChartItemResolver',
      );
      return null;
    }

    log(
      'Resolved with ${winner.confidence.toStringAsFixed(1)}% confidence '
      'from ${winner.pluginId}',
      name: 'ChartItemResolver',
    );
    return _toResolveResult(winner);
  }

  String fallbackQuery(ChartItem chartItem) {
    return _ResolverProfile.fromMediaItem(chartItem.item).fallbackQuery;
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  ChartResolveResult? _toResolveResult(_ScoredCandidate candidate) {
    final resolvedTrack = switch (candidate.mediaItem) {
      MediaItem_Track(:final field0) => field0,
      _ => null,
    };
    if (resolvedTrack == null) return null;

    return ChartResolveResult(
      resolvedTrack: resolvedTrack,
      resolverPluginId: candidate.pluginId,
      confidence: candidate.confidence,
    );
  }

  _ScoredCandidate? _pickBest(List<_ScoredCandidate> candidates) {
    if (candidates.isEmpty) return null;
    return candidates.reduce(
      (a, b) => b.confidence > a.confidence ? b : a,
    );
  }

  /// Boost candidates that are corroborated by multiple independent plugins.
  /// If the same normalized (title, artist) pair appears from ≥ 2 different
  /// plugins, each matching candidate gets [_kCorroborationBonus].
  void _applyCrossPluginCorroboration(
    List<_ScoredCandidate> candidates,
    _ResolverProfile profile,
  ) {
    if (candidates.length < 2) return;

    // Group by (normalizedTitle, normalizedArtist) → set of source plugins.
    final fingerprints = <String, Set<String>>{};
    final candidateFingerprints = <int, String>{};

    for (var i = 0; i < candidates.length; i++) {
      final fp = _candidateFingerprint(candidates[i].mediaItem);
      if (fp.isEmpty) continue;
      candidateFingerprints[i] = fp;
      fingerprints
          .putIfAbsent(fp, () => <String>{})
          .add(candidates[i].pluginId);
    }

    for (var i = 0; i < candidates.length; i++) {
      final fp = candidateFingerprints[i];
      if (fp == null) continue;
      final sources = fingerprints[fp];
      if (sources == null || sources.length < 2) continue;

      // Multiple independent plugins agree → boost confidence.
      final boosted = math.min(
        candidates[i].confidence + _kCorroborationBonus,
        100.0,
      );
      candidates[i] = _ScoredCandidate(
        mediaItem: candidates[i].mediaItem,
        pluginId: candidates[i].pluginId,
        confidence: boosted,
      );
    }
  }

  String _candidateFingerprint(MediaItem item) {
    return switch (item) {
      MediaItem_Track(:final field0) =>
        '${_normalized(field0.title)}||${_artistKey(field0.artists)}',
      MediaItem_Album(:final field0) =>
        '${_normalized(field0.title)}||${_artistKey(field0.artists)}',
      MediaItem_Artist(:final field0) => _normalized(field0.name),
      MediaItem_Playlist(:final field0) => _normalized(field0.title),
    };
  }

  /// Collect candidates from a single plugin.
  ///
  /// When [includeAllFilter] is true, an additional `ContentSearchFilter.all`
  /// query is appended to broaden discovery for Phase 2.
  Future<List<_ScoredCandidate>> _collectCandidates({
    required String pluginId,
    required _ResolverProfile profile,
    required bool includeAllFilter,
  }) async {
    final candidatesById = <String, _CandidateEvidence>{};
    int successQueries = 0;
    int failedQueries = 0;

    final plans = includeAllFilter
        ? [
            ...profile.searchPlans,
            if (profile.fallbackQuery.isNotEmpty)
              _SearchPlan(
                query: profile.fallbackQuery,
                filter: ContentSearchFilter.all,
              ),
          ]
        : profile.searchPlans;

    for (final plan in plans) {
      try {
        final response = await _pluginService.execute(
          pluginId: pluginId,
          request: PluginRequest.contentResolver(
            ContentResolverCommand.search(
              query: plan.query,
              filter: plan.filter,
            ),
          ),
        );

        switch (response) {
          case PluginResponse_Search(:final field0):
            successQueries++;
            final items = field0.items.take(15).toList(growable: false);
            for (var index = 0; index < items.length; index++) {
              final mediaItem = items[index];
              if (!_isCompatibleType(profile.target, mediaItem)) continue;

              final mediaId = _mediaIdOf(mediaItem);
              final key = mediaId.isEmpty
                  ? '${plan.query}::$index::${_mediaTypeOf(mediaItem)}'
                  : mediaId;

              final evidence = candidatesById.putIfAbsent(
                key,
                () => _CandidateEvidence(
                  mediaItem: mediaItem,
                  pluginId: _pluginIdOf(mediaItem) ?? pluginId,
                ),
              );

              evidence.hitCount += 1;
              if (evidence.bestRank == null || index < evidence.bestRank!) {
                evidence.bestRank = index;
              }
              evidence.queries.add(plan.query);
            }
          default:
            failedQueries++;
        }
      } catch (_) {
        failedQueries++;
      }
    }

    if (successQueries == 0 && failedQueries > 0) {
      log(
        'All $failedQueries queries failed for plugin $pluginId',
        name: 'ChartItemResolver',
      );
    }

    final scored = candidatesById.values
        .map((evidence) => _scoreCandidate(profile, evidence))
        .whereType<_ScoredCandidate>()
        .toList(growable: false)
      ..sort((left, right) => right.confidence.compareTo(left.confidence));

    return scored;
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _ScoredCandidate {
  final MediaItem mediaItem;
  final String pluginId;
  final double confidence;

  const _ScoredCandidate({
    required this.mediaItem,
    required this.pluginId,
    required this.confidence,
  });
}

class _CandidateEvidence {
  final MediaItem mediaItem;
  final String pluginId;
  final Set<String> queries = <String>{};
  int hitCount = 0;
  int? bestRank;

  _CandidateEvidence({
    required this.mediaItem,
    required this.pluginId,
  });
}

class _SearchPlan {
  final String query;
  final ContentSearchFilter filter;

  const _SearchPlan({
    required this.query,
    required this.filter,
  });
}

// ── Resolver profile ──────────────────────────────────────────────────────────

class _ResolverProfile {
  final MediaItem target;
  final ContentSearchFilter primaryFilter;
  final List<_SearchPlan> searchPlans;
  final String fallbackQuery;
  final double earlyAcceptThreshold;

  const _ResolverProfile({
    required this.target,
    required this.primaryFilter,
    required this.searchPlans,
    required this.fallbackQuery,
    required this.earlyAcceptThreshold,
  });

  factory _ResolverProfile.fromMediaItem(MediaItem item) {
    return switch (item) {
      MediaItem_Track(:final field0) => _trackProfile(item, field0),
      MediaItem_Album(:final field0) => _albumProfile(item, field0),
      MediaItem_Artist(:final field0) => _artistProfile(item, field0),
      MediaItem_Playlist(:final field0) => _playlistProfile(item, field0),
    };
  }

  static _ResolverProfile _trackProfile(MediaItem item, Track track) {
    final title = track.title.trim();
    final simplifiedTitle = _simplifyTitle(title);
    final artistNames = _artistNames(track.artists);
    final primaryArtist =
        track.artists.isNotEmpty ? track.artists.first.name : '';
    final albumTitle = track.album?.title ?? '';

    final queries = _uniqueQueries([
      _joinNonEmpty([title, artistNames]),
      _joinNonEmpty([simplifiedTitle, artistNames]),
      _joinNonEmpty([title, primaryArtist]),
      _joinNonEmpty([simplifiedTitle, primaryArtist]),
      _joinNonEmpty([title, albumTitle, primaryArtist]),
      title,
      simplifiedTitle,
    ]);

    return _ResolverProfile(
      target: item,
      primaryFilter: ContentSearchFilter.track,
      fallbackQuery: _joinNonEmpty([title, artistNames]),
      earlyAcceptThreshold: 94,
      searchPlans: [
        for (final query in queries)
          _SearchPlan(query: query, filter: ContentSearchFilter.track),
      ],
    );
  }

  static _ResolverProfile _albumProfile(MediaItem item, AlbumSummary album) {
    final queries = _uniqueQueries([
      _joinNonEmpty([album.title, _artistNames(album.artists)]),
      album.title,
    ]);

    return _ResolverProfile(
      target: item,
      primaryFilter: ContentSearchFilter.album,
      fallbackQuery: queries.first,
      earlyAcceptThreshold: 93,
      searchPlans: [
        for (final query in queries)
          _SearchPlan(query: query, filter: ContentSearchFilter.album),
      ],
    );
  }

  static _ResolverProfile _artistProfile(MediaItem item, ArtistSummary artist) {
    final query = artist.name.trim();
    return _ResolverProfile(
      target: item,
      primaryFilter: ContentSearchFilter.artist,
      fallbackQuery: query,
      earlyAcceptThreshold: 95,
      searchPlans: [
        _SearchPlan(query: query, filter: ContentSearchFilter.artist),
      ],
    );
  }

  static _ResolverProfile _playlistProfile(
    MediaItem item,
    PlaylistSummary playlist,
  ) {
    final queries = _uniqueQueries([
      _joinNonEmpty([playlist.title, playlist.owner]),
      playlist.title,
    ]);

    return _ResolverProfile(
      target: item,
      primaryFilter: ContentSearchFilter.playlist,
      fallbackQuery: queries.first,
      earlyAcceptThreshold: 92,
      searchPlans: [
        for (final query in queries)
          _SearchPlan(query: query, filter: ContentSearchFilter.playlist),
      ],
    );
  }
}

// ── Scoring ───────────────────────────────────────────────────────────────────

_ScoredCandidate? _scoreCandidate(
  _ResolverProfile profile,
  _CandidateEvidence evidence,
) {
  final score = switch ((profile.target, evidence.mediaItem)) {
    (
      MediaItem_Track(:final field0),
      MediaItem_Track(field0: final candidate)
    ) =>
      _scoreTrackCandidate(field0, candidate, evidence),
    (
      MediaItem_Album(:final field0),
      MediaItem_Album(field0: final candidate)
    ) =>
      _scoreAlbumCandidate(field0, candidate, evidence),
    (
      MediaItem_Artist(:final field0),
      MediaItem_Artist(field0: final candidate)
    ) =>
      _scoreArtistCandidate(field0, candidate, evidence),
    (
      MediaItem_Playlist(:final field0),
      MediaItem_Playlist(field0: final candidate)
    ) =>
      _scorePlaylistCandidate(field0, candidate, evidence),
    _ => null,
  };

  if (score == null || score <= 0) return null;

  return _ScoredCandidate(
    mediaItem: evidence.mediaItem,
    pluginId: evidence.pluginId,
    confidence: score,
  );
}

double _scoreTrackCandidate(
  Track target,
  Track candidate,
  _CandidateEvidence evidence,
) {
  final titleScore = _blendedTextSimilarity(target.title, candidate.title);
  final simplifiedTitleScore = _blendedTextSimilarity(
    _simplifyTitle(target.title),
    _simplifyTitle(candidate.title),
  );
  final artistScore = _artistSimilarity(target.artists, candidate.artists);
  final albumScore = _blendedTextSimilarity(
    target.album?.title,
    candidate.album?.title,
  );
  final durationScore = _durationProbability(
    _durationAsDouble(target.durationMs),
    _durationAsDouble(candidate.durationMs),
  );
  final versionPenalty = _versionPenalty(target.title, target.album?.title,
      candidate.title, candidate.album?.title);
  final rankBonus = _rankBonus(evidence.bestRank);
  final repeatBonus = math.min((evidence.hitCount - 1) * 0.025, 0.1);

  // Weighted feature vector with adaptive album weight: when chart item
  // has no album info, redistribute its weight to title + artist.
  final hasAlbum = (target.album?.title ?? '').trim().isNotEmpty;
  final wTitle = hasAlbum ? 0.34 : 0.38;
  final wSimplified = hasAlbum ? 0.16 : 0.18;
  final wArtist = hasAlbum ? 0.24 : 0.28;
  final wAlbum = hasAlbum ? 0.08 : 0.0;
  const wDuration = 0.08;

  var score = titleScore * wTitle +
      simplifiedTitleScore * wSimplified +
      artistScore * wArtist +
      albumScore * wAlbum +
      durationScore * wDuration +
      rankBonus +
      repeatBonus;

  // Exact-match bonuses (cumulative).
  if (_normalized(target.title) == _normalized(candidate.title)) {
    score += 0.10;
  }
  if (_simplifyTitle(target.title) == _simplifyTitle(candidate.title)) {
    score += 0.06;
  }
  final tKey = _artistKey(target.artists);
  if (tKey.isNotEmpty && tKey == _artistKey(candidate.artists)) {
    score += 0.08;
  }

  score -= versionPenalty;
  return _toConfidence(score);
}

double _scoreAlbumCandidate(
  AlbumSummary target,
  AlbumSummary candidate,
  _CandidateEvidence evidence,
) {
  var score = _blendedTextSimilarity(target.title, candidate.title) * 0.65 +
      _artistSimilarity(target.artists, candidate.artists) * 0.22 +
      _rankBonus(evidence.bestRank) +
      math.min((evidence.hitCount - 1) * 0.03, 0.09);

  if (target.year != null &&
      candidate.year != null &&
      target.year == candidate.year) {
    score += 0.08;
  }
  if (_normalized(target.title) == _normalized(candidate.title)) {
    score += 0.08;
  }

  return _toConfidence(score);
}

double _scoreArtistCandidate(
  ArtistSummary target,
  ArtistSummary candidate,
  _CandidateEvidence evidence,
) {
  var score = _blendedTextSimilarity(target.name, candidate.name) * 0.82 +
      _blendedTextSimilarity(target.subtitle, candidate.subtitle) * 0.08 +
      _rankBonus(evidence.bestRank) +
      math.min((evidence.hitCount - 1) * 0.02, 0.06);

  if (_normalized(target.name) == _normalized(candidate.name)) {
    score += 0.12;
  }

  return _toConfidence(score);
}

double _scorePlaylistCandidate(
  PlaylistSummary target,
  PlaylistSummary candidate,
  _CandidateEvidence evidence,
) {
  var score = _blendedTextSimilarity(target.title, candidate.title) * 0.68 +
      _blendedTextSimilarity(target.owner, candidate.owner) * 0.18 +
      _rankBonus(evidence.bestRank) +
      math.min((evidence.hitCount - 1) * 0.03, 0.09);

  if (_normalized(target.title) == _normalized(candidate.title)) {
    score += 0.10;
  }
  if (_normalized(target.owner) == _normalized(candidate.owner)) {
    score += 0.06;
  }

  return _toConfidence(score);
}

// ── Utility functions ─────────────────────────────────────────────────────────

bool _isCompatibleType(MediaItem target, MediaItem candidate) {
  return switch ((target, candidate)) {
    (MediaItem_Track(), MediaItem_Track()) => true,
    (MediaItem_Album(), MediaItem_Album()) => true,
    (MediaItem_Artist(), MediaItem_Artist()) => true,
    (MediaItem_Playlist(), MediaItem_Playlist()) => true,
    _ => false,
  };
}

double _toConfidence(double score) {
  return (score.clamp(0.0, 1.0) * 100).toDouble();
}

double _rankBonus(int? rank) {
  if (rank == null) return 0;
  return (0.08 - (rank * 0.006)).clamp(0.0, 0.08).toDouble();
}

double _durationProbability(num? targetDuration, num? candidateDuration) {
  if (targetDuration == null || candidateDuration == null) return 0.03;
  final delta =
      (targetDuration.toDouble() - candidateDuration.toDouble()).abs();
  if (delta <= 1500) return 1.0;
  if (delta <= 3000) return 0.80;
  if (delta <= 5000) return 0.50;
  if (delta <= 8000) return 0.20;
  if (delta <= 15000) return 0.08;
  return 0.0;
}

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

  final mismatches = targetTags.difference(candidateTags).length +
      candidateTags.difference(targetTags).length;
  return (mismatches * 0.07).clamp(0, 0.28).toDouble();
}

double? _durationAsDouble(BigInt? duration) {
  return duration?.toDouble();
}

Set<String> _versionTags(String value) {
  final normalized = _normalized(value);
  final tags = <String>{};
  const tagMap = {
    'live': [' live ', 'live at', 'live from', 'live in'],
    'acoustic': [' acoustic '],
    'karaoke': [' karaoke '],
    'instrumental': [' instrumental '],
    'remix': [' remix ', ' mixed ', ' rmx '],
    'remaster': [' remaster ', ' remastered '],
    'clean': [' clean '],
    'explicit': [' explicit '],
    'demo': [' demo '],
    'cover': [' cover '],
    'radio': [' radio edit', ' radio version'],
    'extended': [' extended '],
    'unplugged': [' unplugged '],
    'stripped': [' stripped '],
  };

  for (final entry in tagMap.entries) {
    if (entry.value.any((needle) => ' $normalized '.contains(needle))) {
      tags.add(entry.key);
    }
  }
  return tags;
}

double _artistSimilarity(
  List<ArtistSummary> targetArtists,
  List<ArtistSummary> candidateArtists,
) {
  final targetNames = targetArtists
      .map((artist) => artist.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);
  final candidateNames = candidateArtists
      .map((artist) => artist.name)
      .where((name) => name.trim().isNotEmpty)
      .toList(growable: false);

  if (targetNames.isEmpty || candidateNames.isEmpty) {
    return _blendedTextSimilarity(
      _artistNames(targetArtists),
      _artistNames(candidateArtists),
    );
  }

  // Best-match artist pairing (asymmetric: each target artist finds its
  // closest candidate, then we average).
  double total = 0;
  for (final targetName in targetNames) {
    var best = 0.0;
    for (final candidateName in candidateNames) {
      final similarity = _blendedTextSimilarity(targetName, candidateName);
      if (similarity > best) best = similarity;
    }
    total += best;
  }

  final aggregate = total / targetNames.length;
  final combined =
      _blendedTextSimilarity(targetNames.join(' '), candidateNames.join(' '));

  // Primary artist match bonus: if the first artists match well, boost.
  final primaryBonus =
      _blendedTextSimilarity(targetNames.first, candidateNames.first) > 0.85
          ? 0.05
          : 0.0;

  return (aggregate * 0.65 + combined * 0.30 + primaryBonus)
      .clamp(0.0, 1.0)
      .toDouble();
}

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

double _tokenOverlap(String left, String right) {
  final leftTokens = left.split(' ').where((t) => t.isNotEmpty).toSet();
  final rightTokens = right.split(' ').where((t) => t.isNotEmpty).toSet();
  if (leftTokens.isEmpty || rightTokens.isEmpty) return 0;

  final intersection = leftTokens.intersection(rightTokens).length;
  final precision = intersection / rightTokens.length;
  final recall = intersection / leftTokens.length;
  if (precision + recall == 0) return 0;
  return (2 * precision * recall) / (precision + recall);
}

String _artistNames(List<ArtistSummary> artists) {
  return artists
      .map((artist) => artist.name.trim())
      .where((name) => name.isNotEmpty)
      .join(', ');
}

String _artistKey(List<ArtistSummary> artists) {
  final names = artists
      .map((artist) => _normalized(artist.name))
      .where((name) => name.isNotEmpty)
      .toList(growable: false)
    ..sort();
  return names.join('|');
}

String _simplifyTitle(String? value) {
  final normalized = _normalized(value)
      .replaceAll(RegExp(r'\(.*?\)'), ' ')
      .replaceAll(RegExp(r'\b(feat|ft|featuring)\b.*$'), '')
      .replaceAll(RegExp(r'\b(remaster(ed)?|version|edit|mix|remix)\b'), ' ')
      .replaceAll(RegExp(r'\b(single|album|deluxe|edition|bonus)\b'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return normalized;
}

String _normalized(String? value) {
  if (value == null) return '';
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[\[\]\(\){}]'), ' ')
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

List<String> _uniqueQueries(List<String> values) {
  final seen = <String>{};
  final queries = <String>[];

  for (final value in values) {
    final query = value.trim();
    if (query.isEmpty) continue;
    final key = _normalized(query);
    if (key.isEmpty || seen.contains(key)) continue;
    seen.add(key);
    queries.add(query);
  }

  return queries;
}

String _joinNonEmpty(List<String?> parts) {
  return parts
      .map((part) => part?.trim() ?? '')
      .where((part) => part.isNotEmpty)
      .join(' ');
}

String _mediaIdOf(MediaItem item) {
  return switch (item) {
    MediaItem_Track(:final field0) => field0.id,
    MediaItem_Album(:final field0) => field0.id,
    MediaItem_Artist(:final field0) => field0.id,
    MediaItem_Playlist(:final field0) => field0.id,
  };
}

String _mediaTypeOf(MediaItem item) {
  return switch (item) {
    MediaItem_Track() => 'track',
    MediaItem_Album() => 'album',
    MediaItem_Artist() => 'artist',
    MediaItem_Playlist() => 'playlist',
  };
}

String? _pluginIdOf(MediaItem item) {
  return pluginIdOf(_mediaIdOf(item));
}
