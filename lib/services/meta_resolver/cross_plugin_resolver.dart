// cross_plugin_resolver.dart
//
// Cross-plugin resolution: query building and plugin search here; text
// normalisation and all similarity scoring run in Rust (api/matching.rs).
//
// Consumed by:
//   - ChartItemResolver          (chart resolution with multi-phase + corroboration)
//   - SmartTrackReplacementService (track replacement + playlist mutation)
//   - ContentImportCubit          (playlist import with concurrent resolution)

import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/matching.dart' as matching;
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Public data types
// ══════════════════════════════════════════════════════════════════════════════

/// Unified representation of the track we want to match against.
/// Decouples scoring from any specific source type (Track, ImportTrack, etc.).
class TrackMatchTarget {
  final String title;

  /// Artist *names* (not objects) — order matters: first = primary.
  final List<String> artistNames;
  final String? albumTitle;
  final BigInt? durationMs;

  const TrackMatchTarget({
    required this.title,
    required this.artistNames,
    this.albumTitle,
    this.durationMs,
  });

  /// Construct from a plugin [Track] model.
  factory TrackMatchTarget.fromTrack(Track track) => TrackMatchTarget(
        title: track.title,
        artistNames: track.artists
            .map((a) => a.name.trim())
            .where((n) => n.isNotEmpty)
            .toList(growable: false),
        albumTitle: track.album?.title,
        durationMs: track.durationMs,
      );

  /// Construct from raw import data (title + list of artist name strings).
  factory TrackMatchTarget.fromImport({
    required String title,
    required List<String> artists,
    int? durationMs,
  }) =>
      TrackMatchTarget(
        title: title,
        artistNames:
            artists.map((a) => a.trim()).where((a) => a.isNotEmpty).toList(),
        albumTitle: null,
        durationMs: durationMs != null ? BigInt.from(durationMs) : null,
      );

  String get primaryArtist => artistNames.isNotEmpty ? artistNames.first : '';
  String get allArtists => artistNames.join(' ');

  matching.MatchTrack get _match => matching.MatchTrack(
        title: title,
        artists: artistNames,
        album: albumTitle,
        durationMs: durationMs,
      );
}

matching.MatchTrack _matchOf(Track track) => matching.MatchTrack(
      title: track.title,
      artists: [for (final a in track.artists) a.name],
      album: track.album?.title,
      durationMs: track.durationMs,
    );

/// A candidate track returned by resolution, annotated with confidence.
class ScoredTrackCandidate {
  final Track track;
  final String pluginId;

  /// Confidence in range [0.0, 1.0].
  final double confidence;

  const ScoredTrackCandidate({
    required this.track,
    required this.pluginId,
    required this.confidence,
  });

  @override
  String toString() => 'ScoredTrackCandidate(plugin=$pluginId, '
      'confidence=${(confidence * 100).toStringAsFixed(1)}%, '
      'track="${track.title}")';
}

/// Raw search result from [CrossPluginResolver.searchMedia], before scoring.
class MediaSearchResult {
  final MediaItem item;
  final String pluginId;
  final int rank;

  const MediaSearchResult({
    required this.item,
    required this.pluginId,
    required this.rank,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// CrossPluginResolver
// ══════════════════════════════════════════════════════════════════════════════

/// Central cross-plugin resolution engine.
///
/// Provides:
///  - **Scoring utilities** — [scoreTrack], [blendedTextSimilarity],
///    [artistSimilarity], [durationSimilarity], [versionPenalty], etc.
///  - **Query building** — [buildTrackQueries].
///  - **Plugin search** — [resolveTrack] (high-level, returns scored
///    candidates), [searchMedia] (low-level, returns raw results for
///    custom scoring by callers like ChartItemResolver).
///
/// Thread-safety: all public methods are safe to call concurrently. The
/// class holds no mutable state.
class CrossPluginResolver {
  final PluginService _pluginService;

  /// Per-plugin-call timeout.
  final Duration pluginTimeout;

  /// Maximum search results inspected per query.
  final int maxResultsPerQuery;

  const CrossPluginResolver({
    required PluginService pluginService,
    this.pluginTimeout = const Duration(seconds: 10),
    this.maxResultsPerQuery = 12,
  }) : _pluginService = pluginService;

  // ────────────────────────────────────────────────────────────────────────
  // High-level: resolve a track
  // ────────────────────────────────────────────────────────────────────────

  /// Search [pluginIds] for tracks matching [target] and return up to
  /// [limit] scored candidates sorted best-first.
  ///
  /// - [sequential]: if true, plugins are tried in order with early-exit
  ///   when [earlyAcceptThreshold] is met (useful for priority-ordered
  ///   lists). If false, all plugins are queried in parallel.
  /// - [minConfidence]: candidates below this are discarded.
  /// - [excludeTrackIds]: IDs to skip (e.g. the original track's own ID).
  /// - [searchFilter]: defaults to [ContentSearchFilter.track]; pass
  ///   [ContentSearchFilter.all] for broadened Phase-2 style searches.
  /// - [queries]: if provided, overrides [buildTrackQueries]. Useful when
  ///   the caller wants to supply a custom fallback query.
  Future<List<ScoredTrackCandidate>> resolveTrack({
    required TrackMatchTarget target,
    required List<String> pluginIds,
    int limit = 5,
    double minConfidence = 0.45,
    double earlyAcceptThreshold = 0.93,
    bool sequential = false,
    Set<String> excludeTrackIds = const {},
    ContentSearchFilter searchFilter = ContentSearchFilter.track,
    List<String>? queries,
  }) async {
    if (pluginIds.isEmpty) return const [];

    final effectiveQueries = queries ?? buildTrackQueries(target);
    if (effectiveQueries.isEmpty) return const [];

    // Collect candidates keyed by track ID (best confidence wins).
    final candidates = <String, ScoredTrackCandidate>{};

    if (sequential) {
      for (final pluginId in pluginIds) {
        final batch = await _searchOnePlugin(
          pluginId: pluginId,
          target: target,
          queries: effectiveQueries,
          filter: searchFilter,
          minConfidence: minConfidence,
          earlyAcceptThreshold: earlyAcceptThreshold,
          excludeTrackIds: excludeTrackIds,
        );
        _mergeCandidates(candidates, batch);

        // Check early accept across all candidates so far.
        final best = _bestConfidence(candidates);
        if (best >= earlyAcceptThreshold) {
          log(
            'Early accept from $pluginId: '
            '${(best * 100).toStringAsFixed(1)}%',
            name: 'CrossPluginResolver',
          );
          break;
        }
      }
    } else {
      final futures = pluginIds.map((pluginId) => _searchOnePlugin(
            pluginId: pluginId,
            target: target,
            queries: effectiveQueries,
            filter: searchFilter,
            minConfidence: minConfidence,
            earlyAcceptThreshold: earlyAcceptThreshold,
            excludeTrackIds: excludeTrackIds,
          ).catchError((Object e) {
            log('Plugin $pluginId failed: $e', name: 'CrossPluginResolver');
            return <ScoredTrackCandidate>[];
          }));

      final batches = await Future.wait(futures);
      for (final batch in batches) {
        _mergeCandidates(candidates, batch);
      }
    }

    final sorted = candidates.values.toList(growable: false)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return sorted.take(limit).toList(growable: false);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Low-level: raw media search (for non-track types / custom scoring)
  // ────────────────────────────────────────────────────────────────────────

  /// Search a single plugin with [queries] and [filter], returning raw
  /// [MediaSearchResult]s without any scoring. Callers (e.g. ChartItemResolver
  /// for albums/artists/playlists) apply their own scoring.
  Future<List<MediaSearchResult>> searchMedia({
    required String pluginId,
    required List<String> queries,
    required ContentSearchFilter filter,
  }) async {
    final results = <MediaSearchResult>[];

    for (final query in queries) {
      try {
        final response = await _pluginService
            .execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: query,
                  filter: filter,
                ),
              ),
            )
            .timeout(pluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            final items =
                field0.items.take(maxResultsPerQuery).toList(growable: false);
            for (var i = 0; i < items.length; i++) {
              results.add(MediaSearchResult(
                item: items[i],
                pluginId: pluginId,
                rank: i,
              ));
            }
          default:
        }
      } on TimeoutException {
        log('Timeout: plugin=$pluginId query="$query"',
            name: 'CrossPluginResolver');
      } catch (e) {
        log('Search failed: plugin=$pluginId query="$query" error=$e',
            name: 'CrossPluginResolver');
      }
    }

    return results;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Track scoring
  // ────────────────────────────────────────────────────────────────────────

  /// Score [candidate] against [target], returning confidence in [0.0, 1.0].
  double scoreTrack(TrackMatchTarget target, Track candidate) =>
      matching.scoreTracks(target: target._match, candidates: [_matchOf(candidate)])
          .first;

  /// Scores many candidates in one call.
  List<double> scoreTracks(TrackMatchTarget target, List<Track> candidates) =>
      matching.scoreTracks(
        target: target._match,
        candidates: [for (final c in candidates) _matchOf(c)],
      );

  /// True when title and artist match exactly or near-exactly.
  bool isStrongMatch(TrackMatchTarget target, Track candidate) =>
      matching.isStrongMatch(target: target._match, candidate: _matchOf(candidate));

  double blendedTextSimilarity(String? left, String? right) =>
      matching.textSimilarity(left: left ?? '', right: right ?? '');

  /// Bidirectional best-match similarity of two artist name lists.
  double artistNamesSimilarity(List<String> leftNames, List<String> rightNames) =>
      matching.artistSimilarity(left: leftNames, right: rightNames);

  double artistSummarySimilarity(
    List<ArtistSummary> left,
    List<ArtistSummary> right,
  ) =>
      artistNamesSimilarity(
        [for (final a in left) a.name],
        [for (final a in right) a.name],
      );

  double durationSimilarity(BigInt? left, BigInt? right) =>
      matching.durationSimilarity(left: left, right: right);

  /// Lowercase, ASCII punctuation removed, whitespace collapsed; non-ASCII
  /// letters are kept so international titles survive.
  String normalized(String? value) => matching.normalizeText(value: value ?? '');

  /// [normalized] plus parentheticals, "feat." credits and version/edition
  /// words removed.
  String simplifyTitle(String? value) => matching.simplifyTitle(value: value ?? '');

  // ────────────────────────────────────────────────────────────────────────
  // Artist helpers
  // ────────────────────────────────────────────────────────────────────────

  String artistNamesJoined(List<ArtistSummary> artists) {
    return artists
        .map((a) => a.name.trim())
        .where((n) => n.isNotEmpty)
        .join(' ');
  }

  /// Sorted, normalized key for exact artist-set comparison.
  String artistKeyFromSummaries(List<ArtistSummary> artists) {
    return _artistKeyFromNames(
      artists.map((a) => a.name).toList(growable: false),
    );
  }

  String _artistKeyFromNames(List<String> names) {
    final norm = names
        .map((n) => normalized(n))
        .where((n) => n.isNotEmpty)
        .toList(growable: false)
      ..sort();
    return norm.join('|');
  }

  // ────────────────────────────────────────────────────────────────────────
  // Query building
  // ────────────────────────────────────────────────────────────────────────

  /// Build a set of de-duplicated search queries for [target], ordered
  /// from most specific to least specific.
  List<String> buildTrackQueries(TrackMatchTarget target) {
    final title = target.title.trim();
    final simplified = simplifyTitle(title);
    final allArtists = target.allArtists;
    final primary = target.primaryArtist;
    final album = target.albumTitle?.trim() ?? '';

    final seen = <String>{};
    final queries = <String>[];

    void add(String q) {
      final t = q.trim();
      if (t.isEmpty) return;
      final k = normalized(t);
      if (k.isEmpty || !seen.add(k)) return;
      queries.add(t);
    }

    add('$title $allArtists');
    if (simplified != normalized(title)) add('$simplified $allArtists');
    add('$title $primary');
    if (album.isNotEmpty) add('$title $primary $album');
    add(title);
    if (simplified.isNotEmpty && simplified != normalized(title)) {
      add(simplified);
    }

    return queries;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Generic helpers
  // ────────────────────────────────────────────────────────────────────────

  String joinNonEmpty(List<String?> parts) {
    return parts
        .map((p) => p?.trim() ?? '')
        .where((p) => p.isNotEmpty)
        .join(' ');
  }

  List<String> uniqueQueries(List<String> values) {
    final seen = <String>{};
    final queries = <String>[];
    for (final v in values) {
      final q = v.trim();
      if (q.isEmpty) continue;
      final k = normalized(q);
      if (k.isEmpty || !seen.add(k)) continue;
      queries.add(q);
    }
    return queries;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Internal: plugin search
  // ────────────────────────────────────────────────────────────────────────

  Future<List<ScoredTrackCandidate>> _searchOnePlugin({
    required String pluginId,
    required TrackMatchTarget target,
    required List<String> queries,
    required ContentSearchFilter filter,
    required double minConfidence,
    required double earlyAcceptThreshold,
    required Set<String> excludeTrackIds,
  }) async {
    final candidates = <String, ScoredTrackCandidate>{};
    double bestThisPlugin = 0;

    for (final query in queries) {
      // Early exit within this plugin.
      if (bestThisPlugin >= earlyAcceptThreshold) break;

      try {
        final response = await _pluginService
            .execute(
              pluginId: pluginId,
              request: PluginRequest.contentResolver(
                ContentResolverCommand.search(
                  query: query,
                  filter: filter,
                ),
              ),
            )
            .timeout(pluginTimeout);

        switch (response) {
          case PluginResponse_Search(:final field0):
            final tracks = [
              for (final item in field0.items.take(maxResultsPerQuery))
                if (item case MediaItem_Track(:final field0))
                  if (!excludeTrackIds.contains(field0.id)) field0,
            ];
            if (tracks.isEmpty) continue;
            final scores = scoreTracks(target, tracks);
            for (var i = 0; i < tracks.length; i++) {
              final track = tracks[i];
              final confidence = scores[i];
              if (confidence < minConfidence) continue;
              if (confidence > bestThisPlugin) bestThisPlugin = confidence;

              final existing = candidates[track.id];
              if (existing == null || confidence > existing.confidence) {
                candidates[track.id] = ScoredTrackCandidate(
                  track: track,
                  pluginId: pluginId,
                  confidence: confidence,
                );
              }
            }
          default:
        }
      } on TimeoutException {
        log('Timeout: plugin=$pluginId query="$query"',
            name: 'CrossPluginResolver');
      } catch (e) {
        log('Search failed: plugin=$pluginId query="$query" error=$e',
            name: 'CrossPluginResolver');
      }
    }

    return candidates.values.toList(growable: false);
  }

  void _mergeCandidates(
    Map<String, ScoredTrackCandidate> target,
    List<ScoredTrackCandidate> batch,
  ) {
    for (final c in batch) {
      final existing = target[c.track.id];
      if (existing == null || c.confidence > existing.confidence) {
        target[c.track.id] = c;
      }
    }
  }

  double _bestConfidence(Map<String, ScoredTrackCandidate> candidates) {
    if (candidates.isEmpty) return 0;
    return candidates.values
        .map((c) => c.confidence)
        .reduce((a, b) => a > b ? a : b);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Semaphore (used by ContentImportCubit for bounded concurrency)
// ══════════════════════════════════════════════════════════════════════════════

/// Simple counting semaphore to cap concurrent async tasks.
class Semaphore {
  final int maxConcurrent;
  int _active = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this.maxConcurrent);

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= maxConcurrent) {
      final waiter = Completer<void>();
      _queue.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      }
    }
  }
}
