import 'dart:developer';

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

/// Service that bridges chart-provider items (informational only) to playable
/// tracks via content-resolver plugins using multi-query probabilistic
/// matching.
///
/// Chart items come from chart-provider plugins and have no stream data.
/// This service finds matching tracks from content-resolver plugins.
class ChartItemResolver {
  final PluginService _pluginService;

  const ChartItemResolver({required PluginService pluginService})
      : _pluginService = pluginService;

  /// Resolve a [ChartItem] to a playable [Track].
  ///
  /// Iterates loaded content resolvers and returns the best confident match.
  /// Returns `null` if no match meets the confidence threshold.
  Future<ChartResolveResult?> resolve({
    required ChartItem chartItem,
    required Iterable<String> resolverPluginIds,
  }) async {
    final profile = _ResolverProfile.fromMediaItem(chartItem.item);
    _ScoredCandidate? bestCandidate;

    for (final pluginId in resolverPluginIds) {
      final candidates = await _collectCandidates(
        pluginId: pluginId,
        profile: profile,
      );

      for (final candidate in candidates) {
        if (bestCandidate == null ||
            candidate.confidence > bestCandidate.confidence) {
          bestCandidate = candidate;
        }

        if (candidate.confidence >= profile.earlyAcceptThreshold) {
          return _toResolveResult(candidate);
        }
      }
    }

    if (bestCandidate == null) {
      log(
        'No candidate found for chart item rank ${chartItem.rank}',
        name: 'ChartItemResolver',
      );
      return null;
    }

    return _toResolveResult(bestCandidate);
  }

  String fallbackQuery(ChartItem chartItem) {
    return _ResolverProfile.fromMediaItem(chartItem.item).fallbackQuery;
  }

  ChartResolveResult? _toResolveResult(_ScoredCandidate candidate) {
    final resolvedTrack = switch (candidate.mediaItem) {
      MediaItem_Track(:final field0) => field0,
      _ => null,
    };

    if (resolvedTrack == null) {
      log('Resolved match is not a track', name: 'ChartItemResolver');
      return null;
    }

    return ChartResolveResult(
      resolvedTrack: resolvedTrack,
      resolverPluginId: candidate.pluginId,
      confidence: candidate.confidence,
    );
  }

  Future<List<_ScoredCandidate>> _collectCandidates({
    required String pluginId,
    required _ResolverProfile profile,
  }) async {
    final candidatesById = <String, _CandidateEvidence>{};

    for (final plan in profile.searchPlans) {
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
            final items = field0.items.take(12).toList(growable: false);
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
              evidence.bestRank = evidence.bestRank == null
                  ? index
                  : evidence.bestRank! < index
                      ? evidence.bestRank
                      : index;
              evidence.queries.add(plan.query);
            }
          default:
            continue;
        }
      } catch (_) {
        continue;
      }
    }

    final scored = candidatesById.values
        .map((evidence) => _scoreCandidate(profile, evidence))
        .whereType<_ScoredCandidate>()
        .toList(growable: false)
      ..sort((left, right) => right.confidence.compareTo(left.confidence));

    return scored;
  }
}

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
      earlyAcceptThreshold: 96,
      searchPlans: [
        for (final query in queries)
          _SearchPlan(query: query, filter: ContentSearchFilter.track),
        if (queries.isNotEmpty)
          _SearchPlan(query: queries.first, filter: ContentSearchFilter.all),
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
      earlyAcceptThreshold: 95,
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
      earlyAcceptThreshold: 97,
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
      earlyAcceptThreshold: 94,
      searchPlans: [
        for (final query in queries)
          _SearchPlan(query: query, filter: ContentSearchFilter.playlist),
      ],
    );
  }
}

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
  final repeatBonus = (evidence.hitCount - 1) * 0.025;

  var score = titleScore * 0.36 +
      simplifiedTitleScore * 0.18 +
      artistScore * 0.24 +
      albumScore * 0.07 +
      durationScore * 0.08 +
      rankBonus +
      repeatBonus;

  if (_normalized(target.title) == _normalized(candidate.title)) {
    score += 0.1;
  }
  if (_simplifyTitle(target.title) == _simplifyTitle(candidate.title)) {
    score += 0.08;
  }
  if (_artistKey(target.artists) == _artistKey(candidate.artists) &&
      _artistKey(target.artists).isNotEmpty) {
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
  var score = _blendedTextSimilarity(target.title, candidate.title) * 0.7 +
      _artistSimilarity(target.artists, candidate.artists) * 0.2 +
      _rankBonus(evidence.bestRank) +
      (evidence.hitCount - 1) * 0.03;

  if (target.year != null &&
      candidate.year != null &&
      target.year == candidate.year) {
    score += 0.08;
  }

  return _toConfidence(score);
}

double _scoreArtistCandidate(
  ArtistSummary target,
  ArtistSummary candidate,
  _CandidateEvidence evidence,
) {
  var score = _blendedTextSimilarity(target.name, candidate.name) * 0.85 +
      _blendedTextSimilarity(target.subtitle, candidate.subtitle) * 0.08 +
      _rankBonus(evidence.bestRank) +
      (evidence.hitCount - 1) * 0.02;

  if (_normalized(target.name) == _normalized(candidate.name)) {
    score += 0.1;
  }

  return _toConfidence(score);
}

double _scorePlaylistCandidate(
  PlaylistSummary target,
  PlaylistSummary candidate,
  _CandidateEvidence evidence,
) {
  var score = _blendedTextSimilarity(target.title, candidate.title) * 0.72 +
      _blendedTextSimilarity(target.owner, candidate.owner) * 0.16 +
      _rankBonus(evidence.bestRank) +
      (evidence.hitCount - 1) * 0.03;

  if (_normalized(target.title) == _normalized(candidate.title)) {
    score += 0.08;
  }

  return _toConfidence(score);
}

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
  return (0.08 - (rank * 0.008)).clamp(0.0, 0.08).toDouble();
}

double _durationProbability(num? targetDuration, num? candidateDuration) {
  if (targetDuration == null || candidateDuration == null) return 0.03;
  final delta =
      (targetDuration.toDouble() - candidateDuration.toDouble()).abs();
  if (delta <= 1500) return 1.0;
  if (delta <= 3000) return 0.75;
  if (delta <= 5000) return 0.45;
  if (delta <= 8000) return 0.2;
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
  return (mismatches * 0.06).clamp(0, 0.24).toDouble();
}

double? _durationAsDouble(BigInt? duration) {
  return duration?.toDouble();
}

Set<String> _versionTags(String value) {
  final normalized = _normalized(value);
  final tags = <String>{};
  const tagMap = {
    'live': [' live ', 'live at'],
    'acoustic': [' acoustic '],
    'karaoke': [' karaoke '],
    'instrumental': [' instrumental '],
    'remix': [' remix ', ' mixed '],
    'remaster': [' remaster ', ' remastered '],
    'clean': [' clean '],
    'explicit': [' explicit '],
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

  double total = 0;
  for (final targetName in targetNames) {
    var best = 0.0;
    for (final candidateName in candidateNames) {
      final similarity = _blendedTextSimilarity(targetName, candidateName);
      if (similarity > best) {
        best = similarity;
      }
    }
    total += best;
  }

  final aggregate = total / targetNames.length;
  final combined =
      _blendedTextSimilarity(targetNames.join(' '), candidateNames.join(' '));
  return (aggregate * 0.7 + combined * 0.3).clamp(0.0, 1.0).toDouble();
}

double _blendedTextSimilarity(String? left, String? right) {
  final normalizedLeft = _normalized(left);
  final normalizedRight = _normalized(right);
  if (normalizedLeft.isEmpty || normalizedRight.isEmpty) return 0;

  final direct = fw.ratio(normalizedLeft, normalizedRight) / 100;
  final simplified = fw.ratio(
        _simplifyTitle(normalizedLeft),
        _simplifyTitle(normalizedRight),
      ) /
      100;
  final sorted = fw.ratio(
        _sortTokens(normalizedLeft),
        _sortTokens(normalizedRight),
      ) /
      100;
  final overlap = _tokenOverlap(normalizedLeft, normalizedRight);

  return (direct * 0.4 + simplified * 0.2 + sorted * 0.2 + overlap * 0.2)
      .clamp(0.0, 1.0)
      .toDouble();
}

double _tokenOverlap(String left, String right) {
  final leftTokens = left.split(' ').where((token) => token.isNotEmpty).toSet();
  final rightTokens =
      right.split(' ').where((token) => token.isNotEmpty).toSet();
  if (leftTokens.isEmpty || rightTokens.isEmpty) return 0;

  final intersection = leftTokens.intersection(rightTokens).length;
  final precision = intersection / rightTokens.length;
  final recall = intersection / leftTokens.length;
  if (precision + recall == 0) return 0;
  return (2 * precision * recall) / (precision + recall);
}

String _sortTokens(String value) {
  final tokens = value.split(' ').where((token) => token.isNotEmpty).toList()
    ..sort();
  return tokens.join(' ');
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
      .replaceAll(RegExp(r'\b(feat|ft|featuring)\b.*$'), '')
      .replaceAll(RegExp(r'\b(remaster(ed)?|version|edit|mix)\b'), ' ')
      .replaceAll(RegExp(r'\b(single|album|deluxe|edition)\b'), ' ')
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
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
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
