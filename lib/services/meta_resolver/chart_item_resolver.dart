import 'dart:developer';
import 'dart:math' as math;

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

class ChartResolveResult {
  final Track resolvedTrack;
  final String resolverPluginId;

  /// Confidence in [0, 100] range (kept for backward compat with UI).
  final double confidence;

  const ChartResolveResult({
    required this.resolvedTrack,
    required this.resolverPluginId,
    required this.confidence,
  });
}

class ChartItemResolver {
  final CrossPluginResolver _resolver;

  static const double _kMinViable = 45;
  static const double _kCorroborationBonus = 6.0;

  const ChartItemResolver({required CrossPluginResolver resolver})
      : _resolver = resolver;

  factory ChartItemResolver.create(PluginService pluginService) =>
      ChartItemResolver(
        resolver: CrossPluginResolver(
          pluginService: pluginService,
          pluginTimeout: const Duration(seconds: 12),
          maxResultsPerQuery: 15,
        ),
      );

  String fallbackQuery(ChartItem chartItem) {
    final target = _targetFromChartItem(chartItem);
    if (target != null) {
      return _resolver.joinNonEmpty([target.title, target.allArtists]);
    }
    return _rawFallback(chartItem);
  }

  bool isStrongTrackMatch({
    required ChartItem chartItem,
    required Track resolvedTrack,
  }) {
    final target = _targetFromChartItem(chartItem);
    if (target == null) return false;
    return _resolver.isStrongMatch(target, resolvedTrack);
  }

  Future<ChartResolveResult?> resolve({
    required ChartItem chartItem,
    required Iterable<String> resolverPluginIds,
  }) async {
    final pluginIds = resolverPluginIds.toList(growable: false);
    if (pluginIds.isEmpty) return null;

    // Track-type items use the shared resolver directly.
    final target = _targetFromChartItem(chartItem);
    if (target != null) {
      return _resolveTrackItem(target, pluginIds);
    }

    // Non-track types use searchMedia with custom scoring.
    return _resolveNonTrackItem(chartItem, pluginIds);
  }

  // ── Track resolution (Phase 1 → 2 → 3) ─────────────────────────────────

  Future<ChartResolveResult?> _resolveTrackItem(
    TrackMatchTarget target,
    List<String> pluginIds,
  ) async {
    // Phase 1: sequential, typed filter, high early-accept bar.
    var candidates = await _resolver.resolveTrack(
      target: target,
      pluginIds: pluginIds,
      sequential: true,
      earlyAcceptThreshold: 0.94,
      minConfidence: _kMinViable / 100,
      limit: 30,
    );

    // Phase 2: if nothing viable, broaden with ContentSearchFilter.all.
    final best1 = candidates.isEmpty ? 0.0 : candidates.first.confidence;
    if (best1 < _kMinViable / 100) {
      log('Phase 1 best ${(best1 * 100).toStringAsFixed(1)}%. Broadening.',
          name: 'ChartItemResolver');

      final fallback =
          _resolver.joinNonEmpty([target.title, target.allArtists]);
      if (fallback.isNotEmpty) {
        final phase2 = await _resolver.resolveTrack(
          target: target,
          pluginIds: pluginIds,
          sequential: false,
          minConfidence: _kMinViable / 100,
          queries: [fallback],
          searchFilter: ContentSearchFilter.all,
          limit: 30,
        );
        candidates = _mergeLists(candidates, phase2);
      }
    }

    // Phase 3: cross-plugin corroboration.
    _applyCorroboration(candidates);

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    if (candidates.isEmpty) return null;

    final winner = candidates.first;
    final conf100 = winner.confidence * 100;
    if (conf100 < _kMinViable) {
      log('No viable: best ${conf100.toStringAsFixed(1)}%',
          name: 'ChartItemResolver');
      return null;
    }

    log('Resolved ${conf100.toStringAsFixed(1)}% from ${winner.pluginId}',
        name: 'ChartItemResolver');
    return ChartResolveResult(
      resolvedTrack: winner.track,
      resolverPluginId: winner.pluginId,
      confidence: conf100,
    );
  }

  // ── Non-track resolution ────────────────────────────────────────────────

  Future<ChartResolveResult?> _resolveNonTrackItem(
    ChartItem chartItem,
    List<String> pluginIds,
  ) async {
    final queries = _buildNonTrackQueries(chartItem);
    final filter = _filterFor(chartItem);
    if (queries.isEmpty) return null;

    final allResults = <_NonTrackScored>[];

    for (final pluginId in pluginIds) {
      try {
        final results = await _resolver.searchMedia(
          pluginId: pluginId,
          queries: queries,
          filter: filter,
        );
        for (final r in results) {
          if (!_compatibleType(chartItem.item, r.item)) continue;
          final score = _scoreNonTrack(chartItem.item, r.item, r.rank);
          if (score > 0) {
            allResults.add(_NonTrackScored(
              result: r,
              confidence: score,
            ));
          }
        }
      } catch (e) {
        log('Non-track search failed for $pluginId: $e',
            name: 'ChartItemResolver');
      }
    }

    if (allResults.isEmpty) return null;
    allResults.sort((a, b) => b.confidence.compareTo(a.confidence));

    final best = allResults.first;
    final conf100 = best.confidence * 100;
    if (conf100 < _kMinViable) return null;

    // Only return tracks from MediaItem_Track results.
    final track = switch (best.result.item) {
      MediaItem_Track(:final field0) => field0,
      _ => null,
    };
    if (track == null) return null;

    return ChartResolveResult(
      resolvedTrack: track,
      resolverPluginId: best.result.pluginId,
      confidence: conf100,
    );
  }

  // ── Corroboration ───────────────────────────────────────────────────────

  void _applyCorroboration(List<ScoredTrackCandidate> candidates) {
    if (candidates.length < 2) return;
    final fps = <String, Set<String>>{};
    for (final c in candidates) {
      final fp = _trackFingerprint(c.track);
      fps.putIfAbsent(fp, () => {}).add(c.pluginId);
    }

    for (var i = 0; i < candidates.length; i++) {
      final fp = _trackFingerprint(candidates[i].track);
      if ((fps[fp]?.length ?? 0) >= 2) {
        candidates[i] = ScoredTrackCandidate(
          track: candidates[i].track,
          pluginId: candidates[i].pluginId,
          confidence: math.min(
            candidates[i].confidence + _kCorroborationBonus / 100,
            1.0,
          ),
        );
      }
    }
  }

  String _trackFingerprint(Track track) =>
      '${_resolver.normalized(track.title)}||'
      '${_resolver.artistKeyFromSummaries(track.artists)}';

  // ── Non-track scoring ───────────────────────────────────────────────────

  double _scoreNonTrack(MediaItem target, MediaItem candidate, int rank) {
    final rankBonus = (0.08 - rank * 0.006).clamp(0.0, 0.08);

    return switch ((target, candidate)) {
      (
        MediaItem_Album(:final field0),
        MediaItem_Album(field0: final c),
      ) =>
        _scoreAlbum(field0, c, rankBonus),
      (
        MediaItem_Artist(:final field0),
        MediaItem_Artist(field0: final c),
      ) =>
        _scoreArtist(field0, c, rankBonus),
      (
        MediaItem_Playlist(:final field0),
        MediaItem_Playlist(field0: final c),
      ) =>
        _scorePlaylist(field0, c, rankBonus),
      _ => 0,
    };
  }

  double _scoreAlbum(AlbumSummary t, AlbumSummary c, double rankBonus) {
    var s = _resolver.blendedTextSimilarity(t.title, c.title) * 0.65 +
        _resolver.artistSummarySimilarity(t.artists, c.artists) * 0.22 +
        rankBonus;
    if (t.year != null && c.year != null) {
      final d = (t.year! - c.year!).abs();
      s += d == 0 ? 0.08 : (d == 1 ? 0.04 : 0.0);
    }
    final tn = _resolver.normalized(t.title);
    final cn = _resolver.normalized(c.title);
    if (tn.isNotEmpty && tn == cn) s += 0.08;
    return s.clamp(0.0, 1.0);
  }

  double _scoreArtist(ArtistSummary t, ArtistSummary c, double rankBonus) {
    var s = _resolver.blendedTextSimilarity(t.name, c.name) * 0.82 +
        _resolver.blendedTextSimilarity(t.subtitle, c.subtitle) * 0.08 +
        rankBonus;
    final tn = _resolver.normalized(t.name);
    final cn = _resolver.normalized(c.name);
    if (tn.isNotEmpty && tn == cn) s += 0.12;
    return s.clamp(0.0, 1.0);
  }

  double _scorePlaylist(
    PlaylistSummary t,
    PlaylistSummary c,
    double rankBonus,
  ) {
    var s = _resolver.blendedTextSimilarity(t.title, c.title) * 0.68 +
        _resolver.blendedTextSimilarity(t.owner, c.owner) * 0.18 +
        rankBonus;
    final tt = _resolver.normalized(t.title);
    final ct = _resolver.normalized(c.title);
    if (tt.isNotEmpty && tt == ct) s += 0.10;
    final to = _resolver.normalized(t.owner);
    final co = _resolver.normalized(c.owner);
    if (to.isNotEmpty && to == co) s += 0.06;
    return s.clamp(0.0, 1.0);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  TrackMatchTarget? _targetFromChartItem(ChartItem chartItem) {
    return switch (chartItem.item) {
      MediaItem_Track(:final field0) => TrackMatchTarget.fromTrack(field0),
      _ => null,
    };
  }

  String _rawFallback(ChartItem chartItem) {
    return switch (chartItem.item) {
      MediaItem_Track(:final field0) => _resolver.joinNonEmpty(
          [field0.title, _resolver.artistNamesJoined(field0.artists)]),
      MediaItem_Album(:final field0) => _resolver.joinNonEmpty(
          [field0.title, _resolver.artistNamesJoined(field0.artists)]),
      MediaItem_Artist(:final field0) => field0.name.trim(),
      MediaItem_Playlist(:final field0) =>
        _resolver.joinNonEmpty([field0.title, field0.owner]),
    };
  }

  List<String> _buildNonTrackQueries(ChartItem chartItem) {
    return switch (chartItem.item) {
      MediaItem_Album(:final field0) => _resolver.uniqueQueries([
          _resolver.joinNonEmpty(
              [field0.title, _resolver.artistNamesJoined(field0.artists)]),
          field0.title,
        ]),
      MediaItem_Artist(:final field0) => [field0.name.trim()],
      MediaItem_Playlist(:final field0) => _resolver.uniqueQueries([
          _resolver.joinNonEmpty([field0.title, field0.owner]),
          field0.title,
        ]),
      _ => const [],
    };
  }

  ContentSearchFilter _filterFor(ChartItem chartItem) {
    return switch (chartItem.item) {
      MediaItem_Track() => ContentSearchFilter.track,
      MediaItem_Album() => ContentSearchFilter.album,
      MediaItem_Artist() => ContentSearchFilter.artist,
      MediaItem_Playlist() => ContentSearchFilter.playlist,
    };
  }

  bool _compatibleType(MediaItem t, MediaItem c) => switch ((t, c)) {
        (MediaItem_Track(), MediaItem_Track()) => true,
        (MediaItem_Album(), MediaItem_Album()) => true,
        (MediaItem_Artist(), MediaItem_Artist()) => true,
        (MediaItem_Playlist(), MediaItem_Playlist()) => true,
        _ => false,
      };

  List<ScoredTrackCandidate> _mergeLists(
    List<ScoredTrackCandidate> a,
    List<ScoredTrackCandidate> b,
  ) {
    final map = <String, ScoredTrackCandidate>{};
    for (final c in [...a, ...b]) {
      final existing = map[c.track.id];
      if (existing == null || c.confidence > existing.confidence) {
        map[c.track.id] = c;
      }
    }
    return map.values.toList();
  }
}

class _NonTrackScored {
  final MediaSearchResult result;
  final double confidence;
  const _NonTrackScored({required this.result, required this.confidence});
}
