import 'dart:developer';
import 'dart:math' as math;

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fw;

// ── Pre-compiled RegExp constants (created once, reused everywhere) ──────────

final RegExp _kParenthetical = RegExp(r'\(.*?\)');
final RegExp _kFeatSuffix = RegExp(r'\b(?:feat|ft|featuring)\b.*$');
final RegExp _kVersionWords =
    RegExp(r'\b(?:remaster(?:ed)?|version|edit|mix|remix)\b');
final RegExp _kEditionWords =
    RegExp(r'\b(?:single|album|deluxe|edition|bonus)\b');
final RegExp _kBracketsEtc = RegExp(r'[$$$$\(\){}]');
final RegExp _kAsciiPunctuation =
    RegExp(r'[\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]');
final RegExp _kMultiSpace = RegExp(r'\s+');

/// Pre-compiled word-boundary patterns for version-tag detection.
final Map<String, List<RegExp>> _kVersionTagPatterns = {
  'live': [
    RegExp(r'\blive\b'),
    RegExp(r'\blive at\b'),
    RegExp(r'\blive from\b'),
    RegExp(r'\blive in\b')
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

// ── Scoring weight constants ─────────────────────────────────────────────────

/// Track scoring weights when the target has album information.
class _TrackWeights {
  final double title;
  final double simplified;
  final double artist;
  final double album;
  final double duration;

  const _TrackWeights({
    required this.title,
    required this.simplified,
    required this.artist,
    required this.album,
    required this.duration,
  });

  double get sum => title + simplified + artist + album + duration;

  /// With album info: weights sum to 0.90 (remaining 0.10 is exact-match
  /// bonuses and rank/repeat bonuses capped so theoretical max ≈ 1.22).
  static const withAlbum = _TrackWeights(
    title: 0.34,
    simplified: 0.16,
    artist: 0.24,
    album: 0.08,
    duration: 0.08,
  );

  /// Without album info: album weight is redistributed to title+artist+simplified.
  static const withoutAlbum = _TrackWeights(
    title: 0.38,
    simplified: 0.18,
    artist: 0.28,
    album: 0.0,
    duration: 0.08,
  );
}

// ── Public result type ───────────────────────────────────────────────────────

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

  @override
  String toString() => 'ChartResolveResult(plugin=$resolverPluginId, '
      'confidence=${confidence.toStringAsFixed(1)}%, '
      'track="${resolvedTrack.title}")';
}

// ── Main resolver ────────────────────────────────────────────────────────────

/// Cross-plugin metadata resolver that bridges chart-provider items to
/// playable tracks via content-resolver plugins.
///
/// Resolution strategy (cascading fallback):
///   Phase 1 — Exact-match pass with typed filter per plugin (high bar).
///             Sequential execution allows early exit on high-confidence hit.
///   Phase 2 — Broadened search with `ContentSearchFilter.all` if Phase 1
///             produced no viable candidate (confidence ≥ [_kMinViable]).
///             Only runs the *additional* broadened query, not Phase 1 queries
///             again. Plugins are queried in parallel for lower latency.
///   Phase 3 — Cross-plugin corroboration: candidates that appear from
///             multiple independent plugins get a confidence boost.
///
/// Each plugin is wrapped in try-catch so a single failing plugin never
/// prevents the remaining plugins from being tried. All plugin calls are
/// guarded by a per-call timeout.
class ChartItemResolver {
  final PluginService _pluginService;

  /// Candidates below this confidence are not considered viable.
  static const double _kMinViable = 45;

  /// Bonus added when multiple plugins independently return the same
  /// normalized title+artist combination.
  static const double _kCorroborationBonus = 6.0;

  /// Timeout for each individual plugin search call.
  static const Duration _kPluginTimeout = Duration(seconds: 12);

  /// Maximum number of results to consider per search query.
  static const int _kMaxResultsPerQuery = 15;

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

    // ── Phase 1: Typed search, sequential for early-exit ──────────────────
    final allCandidates = <_ScoredCandidate>[];
    int pluginsSucceeded = 0;
    int pluginsFailed = 0;

    for (final pluginId in pluginIds) {
      try {
        final candidates = await _collectCandidates(
          pluginId: pluginId,
          profile: profile,
          plans: profile.searchPlans,
        );
        pluginsSucceeded++;
        allCandidates.addAll(candidates);

        // Early exit: accept immediately if confidence exceeds the threshold.
        final best = candidates.isEmpty ? null : candidates.first;
        if (best != null && best.confidence >= profile.earlyAcceptThreshold) {
          log(
            'Early accept from $pluginId: '
            '${best.confidence.toStringAsFixed(1)}%',
            name: 'ChartItemResolver',
          );
          return _toResolveResult(best);
        }
      } catch (e) {
        pluginsFailed++;
        log(
          'Plugin $pluginId failed during Phase 1: $e',
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

      // Only run the broadened "all" query — do NOT re-run Phase 1 plans.
      final broadenedPlans = <_SearchPlan>[];
      if (profile.fallbackQuery.isNotEmpty) {
        broadenedPlans.add(
          _SearchPlan(
            query: profile.fallbackQuery,
            filter: ContentSearchFilter.all,
          ),
        );
      }

      if (broadenedPlans.isNotEmpty) {
        // Phase 2 queries can run in parallel since there's no early-exit.
        final futures = <Future<List<_ScoredCandidate>>>[];
        for (final pluginId in pluginIds) {
          futures.add(
            _collectCandidates(
              pluginId: pluginId,
              profile: profile,
              plans: broadenedPlans,
            ).catchError((Object e) {
              log(
                'Plugin $pluginId failed during Phase 2: $e',
                name: 'ChartItemResolver',
              );
              return <_ScoredCandidate>[];
            }),
          );
        }

        final phase2Results = await Future.wait(futures);
        for (final batch in phase2Results) {
          allCandidates.addAll(batch);
        }
      }
    }

    // ── Phase 3: Cross-plugin corroboration ───────────────────────────────
    _applyCrossPluginCorroboration(allCandidates);

    // ── Deduplicate before final sort ─────────────────────────────────────
    final deduplicated = _deduplicateCandidates(allCandidates);

    // Pick the global best that meets viability.
    deduplicated.sort(
      (a, b) => b.confidence.compareTo(a.confidence),
    );

    final winner = deduplicated.isEmpty ? null : deduplicated.first;

    if (winner == null || winner.confidence < _kMinViable) {
      log(
        'No viable candidate found '
        '(best: ${winner?.confidence.toStringAsFixed(1) ?? "none"}, '
        'plugins ok: $pluginsSucceeded, failed: $pluginsFailed)',
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

  /// Returns true when [resolvedTrack] is a strong exact/near-exact match
  /// for the track contained in [chartItem].
  bool isStrongTrackMatch({
    required ChartItem chartItem,
    required Track resolvedTrack,
  }) {
    final targetTrack = switch (chartItem.item) {
      MediaItem_Track(:final field0) => field0,
      _ => null,
    };
    if (targetTrack == null) return false;

    final targetNorm = _normalized(targetTrack.title);
    final resolvedNorm = _normalized(resolvedTrack.title);
    final targetSimple = _simplifyTitle(targetTrack.title);
    final resolvedSimple = _simplifyTitle(resolvedTrack.title);

    final titleExact = targetNorm.isNotEmpty &&
        resolvedNorm.isNotEmpty &&
        targetNorm == resolvedNorm;
    final titleNearExact = targetSimple.isNotEmpty &&
        resolvedSimple.isNotEmpty &&
        targetSimple == resolvedSimple;

    if (!titleExact && !titleNearExact) return false;

    final targetArtistNames = _artistNames(targetTrack.artists);
    final resolvedArtistNames = _artistNames(resolvedTrack.artists);
    if (targetArtistNames.trim().isEmpty ||
        resolvedArtistNames.trim().isEmpty) {
      // If either side has no artist info, title match alone is sufficient.
      return true;
    }

    return _artistSimilarity(targetTrack.artists, resolvedTrack.artists) >= 0.7;
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

  /// Deduplicate candidates by media ID, keeping the highest-scoring entry.
  List<_ScoredCandidate> _deduplicateCandidates(
    List<_ScoredCandidate> candidates,
  ) {
    final bestByKey = <String, _ScoredCandidate>{};
    for (final candidate in candidates) {
      final key = '${candidate.pluginId}::${_mediaIdOf(candidate.mediaItem)}';
      final existing = bestByKey[key];
      if (existing == null || candidate.confidence > existing.confidence) {
        bestByKey[key] = candidate;
      }
    }
    return bestByKey.values.toList();
  }

  /// Boost candidates that are corroborated by multiple independent plugins.
  void _applyCrossPluginCorroboration(List<_ScoredCandidate> candidates) {
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

  /// Collect candidates from a single plugin using the given [plans].
  Future<List<_ScoredCandidate>> _collectCandidates({
    required String pluginId,
    required _ResolverProfile profile,
    required List<_SearchPlan> plans,
  }) async {
    final candidatesById = <String, _CandidateEvidence>{};
    int successQueries = 0;
    int failedQueries = 0;

    for (final plan in plans) {
      try {
        final response = await _pluginService
            .execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: plan.query,
                  filter: plan.filter,
                ),
              ),
            )
            .timeout(_kPluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            successQueries++;
            final items =
                field0.items.take(_kMaxResultsPerQuery).toList(growable: false);
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
      } catch (e) {
        failedQueries++;
        log(
          'Query "${plan.query}" failed for plugin $pluginId: $e',
          name: 'ChartItemResolver',
        );
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
        track.artists.isNotEmpty ? track.artists.first.name.trim() : '';
    final albumTitle = track.album?.title.trim() ?? '';

    final queries = _uniqueQueries([
      _joinNonEmpty([title, artistNames]),
      _joinNonEmpty([simplifiedTitle, artistNames]),
      _joinNonEmpty([title, primaryArtist]),
      _joinNonEmpty([simplifiedTitle, primaryArtist]),
      if (albumTitle.isNotEmpty)
        _joinNonEmpty([title, albumTitle, primaryArtist]),
      title,
      if (simplifiedTitle != _normalized(title)) simplifiedTitle,
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

  static _ResolverProfile _artistProfile(
    MediaItem item,
    ArtistSummary artist,
  ) {
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
      MediaItem_Track(field0: final candidate),
    ) =>
      _scoreTrackCandidate(field0, candidate, evidence),
    (
      MediaItem_Album(:final field0),
      MediaItem_Album(field0: final candidate),
    ) =>
      _scoreAlbumCandidate(field0, candidate, evidence),
    (
      MediaItem_Artist(:final field0),
      MediaItem_Artist(field0: final candidate),
    ) =>
      _scoreArtistCandidate(field0, candidate, evidence),
    (
      MediaItem_Playlist(:final field0),
      MediaItem_Playlist(field0: final candidate),
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
  final durationScore = _durationSimilarity(
    _durationAsDouble(target.durationMs),
    _durationAsDouble(candidate.durationMs),
  );
  final versionPenalty = _versionPenalty(
    target.title,
    target.album?.title,
    candidate.title,
    candidate.album?.title,
  );
  final rankBonus = _rankBonus(evidence.bestRank);
  final repeatBonus = math.min((evidence.hitCount - 1) * 0.025, 0.1);

  // Adaptive weights: when target has no album info, redistribute album
  // weight to title + artist + simplified.
  final hasAlbum = (target.album?.title ?? '').trim().isNotEmpty;
  final w = hasAlbum ? _TrackWeights.withAlbum : _TrackWeights.withoutAlbum;

  var score = titleScore * w.title +
      simplifiedTitleScore * w.simplified +
      artistScore * w.artist +
      albumScore * w.album +
      durationScore * w.duration +
      rankBonus +
      repeatBonus;

  // Exact-match bonuses (cumulative, guarded against empty strings).
  final targetNorm = _normalized(target.title);
  final candidateNorm = _normalized(candidate.title);
  if (targetNorm.isNotEmpty &&
      candidateNorm.isNotEmpty &&
      targetNorm == candidateNorm) {
    score += 0.10;
  }

  final targetSimple = _simplifyTitle(target.title);
  final candidateSimple = _simplifyTitle(candidate.title);
  if (targetSimple.isNotEmpty &&
      candidateSimple.isNotEmpty &&
      targetSimple == candidateSimple) {
    score += 0.06;
  }

  final tKey = _artistKey(target.artists);
  final cKey = _artistKey(candidate.artists);
  if (tKey.isNotEmpty && cKey.isNotEmpty && tKey == cKey) {
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

  // Year proximity bonus: exact match gets full bonus, ±1 year gets partial.
  if (target.year != null && candidate.year != null) {
    final yearDiff = (target.year! - candidate.year!).abs();
    if (yearDiff == 0) {
      score += 0.08;
    } else if (yearDiff == 1) {
      score += 0.04;
    }
  }

  final targetNorm = _normalized(target.title);
  final candidateNorm = _normalized(candidate.title);
  if (targetNorm.isNotEmpty &&
      candidateNorm.isNotEmpty &&
      targetNorm == candidateNorm) {
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

  final targetNorm = _normalized(target.name);
  final candidateNorm = _normalized(candidate.name);
  if (targetNorm.isNotEmpty &&
      candidateNorm.isNotEmpty &&
      targetNorm == candidateNorm) {
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

  final targetTitleNorm = _normalized(target.title);
  final candidateTitleNorm = _normalized(candidate.title);
  if (targetTitleNorm.isNotEmpty &&
      candidateTitleNorm.isNotEmpty &&
      targetTitleNorm == candidateTitleNorm) {
    score += 0.10;
  }

  final targetOwnerNorm = _normalized(target.owner);
  final candidateOwnerNorm = _normalized(candidate.owner);
  if (targetOwnerNorm.isNotEmpty &&
      candidateOwnerNorm.isNotEmpty &&
      targetOwnerNorm == candidateOwnerNorm) {
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

/// Duration similarity using both absolute and relative thresholds.
///
/// For short tracks a 5-second difference matters more than for long tracks,
/// so we combine an absolute threshold check with a relative ratio.
double _durationSimilarity(double? targetMs, double? candidateMs) {
  if (targetMs == null || candidateMs == null) return 0.03;
  if (targetMs <= 0 || candidateMs <= 0) return 0.03;

  final delta = (targetMs - candidateMs).abs();
  final maxDuration = math.max(targetMs, candidateMs);
  final relativeError = delta / maxDuration;

  // Absolute component (unchanged thresholds for backward compat).
  final double absScore;
  if (delta <= 1500) {
    absScore = 1.0;
  } else if (delta <= 3000) {
    absScore = 0.80;
  } else if (delta <= 5000) {
    absScore = 0.50;
  } else if (delta <= 8000) {
    absScore = 0.20;
  } else if (delta <= 15000) {
    absScore = 0.08;
  } else {
    absScore = 0.0;
  }

  // Relative component: penalizes proportional deviation.
  final double relScore;
  if (relativeError <= 0.01) {
    relScore = 1.0;
  } else if (relativeError <= 0.03) {
    relScore = 0.85;
  } else if (relativeError <= 0.07) {
    relScore = 0.60;
  } else if (relativeError <= 0.15) {
    relScore = 0.30;
  } else if (relativeError <= 0.30) {
    relScore = 0.10;
  } else {
    relScore = 0.0;
  }

  // Blend absolute and relative (relative matters more for long tracks).
  return (absScore * 0.55 + relScore * 0.45).clamp(0.0, 1.0);
}

/// Asymmetric version penalty: missing target tags in the candidate is penalized
/// more heavily than the candidate having extra tags.
///
/// Rationale: a chart item "Song (Remastered)" matched to "Song" is a
/// worse mismatch than "Song" matched to "Song (Remastered 2023)".
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

  // Tags present in target but missing from candidate → heavier penalty.
  final missingFromCandidate = targetTags.difference(candidateTags).length;
  // Tags present in candidate but missing from target → lighter penalty.
  final extraInCandidate = candidateTags.difference(targetTags).length;

  final penalty = missingFromCandidate * 0.09 + extraInCandidate * 0.05;
  return penalty.clamp(0.0, 0.28);
}

double? _durationAsDouble(BigInt? duration) {
  return duration?.toDouble();
}

/// Extract version/edition tags from a combined title+album string using
/// pre-compiled word-boundary regexes to avoid false positives
/// (e.g. "olive" no longer matches "live").
Set<String> _versionTags(String value) {
  final normalized = _normalized(value);
  if (normalized.isEmpty) return const {};

  final tags = <String>{};
  for (final entry in _kVersionTagPatterns.entries) {
    if (entry.value.any((pattern) => pattern.hasMatch(normalized))) {
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

  // Best-match artist pairing: each target artist finds its closest
  // candidate, then we average.
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

  // Primary artist match bonus.
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

/// Token overlap using F1 score (harmonic mean of precision and recall).
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

/// Simplify a title by removing parenthetical content, featuring suffixes,
/// and version/edition markers.
///
/// NOTE: Parenthetical removal happens *before* normalization so that
/// `(feat. X)` and `(Remastered 2023)` are actually stripped.
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

/// Normalize a string for comparison: lowercase, strip brackets/punctuation,
/// collapse whitespace. Preserves non-ASCII letters and digits so
/// international titles are not erased.
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
