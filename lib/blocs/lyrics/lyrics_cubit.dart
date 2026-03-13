import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/exported.dart' hide Lyrics;
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsDAO _lyricsDao;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;
  final CrossPluginResolver _resolver;
  StreamSubscription? _mediaItemSubscription;

  static const double _kLyricsSearchMinConfidence = 0.56;

  LyricsCubit(
    BloomeePlayerCubit playerCubit, {
    required LyricsDAO lyricsDao,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _lyricsDao = lyricsDao,
        _settingsDao = settingsDao,
        _pluginService = pluginService,
        _resolver = CrossPluginResolver(
          pluginService: pluginService,
          pluginTimeout: const Duration(seconds: 10),
          maxResultsPerQuery: 15,
        ),
        super(LyricsInitial()) {
    _mediaItemSubscription =
        playerCubit.bloomeePlayer.mediaItem.stream.listen((item) {
      if (item != null) {
        getLyrics(mediaItemToTrack(item));
      }
    });
  }

  String _artistStr(Track track) =>
      track.artists.map((artist) => artist.name).join(', ');

  Future<void> getLyrics(Track track) async {
    if (state.track.id == track.id && state is LyricsLoaded) {
      return;
    }

    emit(LyricsLoading(track));

    // 1) Cache first.
    final cached = await _lyricsDao.getLyrics(track.id);
    if (cached != null && cached.mediaID == track.id) {
      emit(LyricsLoaded(cached, track));
      log('Lyrics loaded for ID: ${track.id} [Offline]', name: 'LyricsCubit');
      return;
    }

    // 2) Providers in priority order.
    final priority = await _loadPriority();
    if (priority.isEmpty) {
      emit(LyricsNoPlugin(track));
      return;
    }

    final profile = _buildTrackProfile(track);

    for (final pluginId in priority) {
      try {
        final direct = await _tryGetLyricsByMetadataVariants(
          pluginId: pluginId,
          profile: profile,
          track: track,
        );
        if (direct != null) {
          emit(LyricsLoaded(direct, track));
          _autoSave(direct);
          log(
            'Lyrics loaded for ID: ${track.id} [Plugin: $pluginId/direct]',
            name: 'LyricsCubit',
          );
          return;
        }

        final searched = await _tryGetLyricsViaSearchFallback(
          pluginId: pluginId,
          profile: profile,
          track: track,
        );
        if (searched != null) {
          emit(LyricsLoaded(searched, track));
          _autoSave(searched);
          log(
            'Lyrics loaded for ID: ${track.id} [Plugin: $pluginId/search]',
            name: 'LyricsCubit',
          );
          return;
        }
      } catch (e) {
        log('Plugin $pluginId failed: $e', name: 'LyricsCubit');
      }
    }

    emit(LyricsError(track));
  }

  Future<Lyrics?> _tryGetLyricsByMetadataVariants({
    required String pluginId,
    required _LyricsTrackProfile profile,
    required Track track,
  }) async {
    for (final metadata in profile.metadataVariants) {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.lyricsProvider(
          LyricsProviderCommand.getLyrics(metadata: metadata),
        ),
      );

      if (response is PluginResponse_LyricsResult && response.field0 != null) {
        final result = response.field0!;
        return pluginLyricsToLyrics(
          result.$1,
          artist: _artistStr(track),
          title: track.title,
          album: track.album?.title,
          durationMs: track.durationMs,
          mediaID: track.id,
        );
      }
    }

    return null;
  }

  Future<Lyrics?> _tryGetLyricsViaSearchFallback({
    required String pluginId,
    required _LyricsTrackProfile profile,
    required Track track,
  }) async {
    final candidatesById = <String, _LyricsSearchCandidate>{};

    for (final query in profile.searchQueries) {
      PluginResponse response;
      try {
        response = await _pluginService.execute(
          pluginId: pluginId,
          request: PluginRequest.lyricsProvider(
            LyricsProviderCommand.search(query: query),
          ),
        );
      } catch (e) {
        log(
          'Lyrics search failed for $pluginId query "$query": $e',
          name: 'LyricsCubit',
        );
        continue;
      }

      if (response is! PluginResponse_LyricsSearchResults) {
        continue;
      }

      for (final match in response.field0) {
        final score = _scoreLyricsMatch(profile.target, match);
        if (score < _kLyricsSearchMinConfidence) continue;

        final existing = candidatesById[match.id];
        if (existing == null || score > existing.confidence) {
          candidatesById[match.id] = _LyricsSearchCandidate(
            match: match,
            confidence: score,
          );
        }
      }
    }

    if (candidatesById.isEmpty) return null;

    final sorted = candidatesById.values.toList(growable: false)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final winner = sorted.first;

    final byIdResponse = await _pluginService.execute(
      pluginId: pluginId,
      request: PluginRequest.lyricsProvider(
        LyricsProviderCommand.getLyricsById(id: winner.match.id),
      ),
    );

    if (byIdResponse is! PluginResponse_LyricsById) return null;

    return pluginLyricsToLyrics(
      byIdResponse.field0,
      artist: _artistStr(track),
      title: track.title,
      album: track.album?.title,
      durationMs: track.durationMs,
      mediaID: track.id,
    );
  }

  double _scoreLyricsMatch(
    TrackMatchTarget target,
    plugin_models.LyricsMatch match,
  ) {
    final simplifiedTargetTitle = _resolver.simplifyTitle(target.title);
    final simplifiedMatchTitle = _resolver.simplifyTitle(match.title);
    final targetArtists = target.artistNames;
    final matchArtists = _splitArtistNames(match.artist);

    final titleScore =
        _resolver.blendedTextSimilarity(target.title, match.title);
    final simpleTitleScore = _resolver.blendedTextSimilarity(
      simplifiedTargetTitle,
      simplifiedMatchTitle,
    );
    final artistScore =
        _resolver.artistNamesSimilarity(targetArtists, matchArtists);
    final albumScore =
        _resolver.blendedTextSimilarity(target.albumTitle, match.album);
    final durationScore = _resolver.durationSimilarity(
      target.durationMs,
      match.durationMs,
    );

    var score = titleScore * 0.38 +
        simpleTitleScore * 0.20 +
        artistScore * 0.26 +
        albumScore * 0.08 +
        durationScore * 0.08;

    final tNorm = _resolver.normalized(target.title);
    final mNorm = _resolver.normalized(match.title);
    if (tNorm.isNotEmpty && tNorm == mNorm) {
      score += 0.06;
    }

    if (simplifiedTargetTitle.isNotEmpty &&
        simplifiedMatchTitle.isNotEmpty &&
        simplifiedTargetTitle == simplifiedMatchTitle) {
      score += 0.05;
    }

    if (match.syncType != plugin_models.LyricsSyncType.none) {
      score += 0.03;
    }

    return score.clamp(0.0, 1.0);
  }

  _LyricsTrackProfile _buildTrackProfile(Track track) {
    final artistNames = track.artists
        .map((artist) => artist.name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final normalizedArtists = _sanitizeArtistNames(artistNames);
    final sanitizedTitle = _sanitizeTitle(
      rawTitle: track.title,
      artistNames: normalizedArtists,
      album: track.album?.title,
    );
    final simplifiedTitle = _resolver.simplifyTitle(sanitizedTitle);

    final target = TrackMatchTarget(
      title: sanitizedTitle,
      artistNames: normalizedArtists,
      albumTitle: track.album?.title,
      durationMs: track.durationMs,
    );

    final primaryArtist =
        normalizedArtists.isEmpty ? '' : normalizedArtists.first;

    final metadataVariants = <plugin_models.TrackMetadata>[
      plugin_models.TrackMetadata(
        title: sanitizedTitle,
        artist: normalizedArtists.join(', '),
        album: track.album?.title,
        durationMs: track.durationMs,
      ),
      if (primaryArtist.isNotEmpty)
        plugin_models.TrackMetadata(
          title: sanitizedTitle,
          artist: primaryArtist,
          album: track.album?.title,
          durationMs: track.durationMs,
        ),
      if (simplifiedTitle.isNotEmpty)
        plugin_models.TrackMetadata(
          title: simplifiedTitle,
          artist: normalizedArtists.join(', '),
          album: track.album?.title,
          durationMs: track.durationMs,
        ),
    ];

    final searchQueries = _resolver.uniqueQueries([
      _resolver.joinNonEmpty([sanitizedTitle, normalizedArtists.join(' ')]),
      _resolver.joinNonEmpty([simplifiedTitle, primaryArtist]),
      _resolver.joinNonEmpty([sanitizedTitle, primaryArtist]),
      sanitizedTitle,
      simplifiedTitle,
      if ((track.album?.title ?? '').trim().isNotEmpty)
        _resolver.joinNonEmpty([sanitizedTitle, track.album?.title]),
    ]);

    return _LyricsTrackProfile(
      target: target,
      metadataVariants: metadataVariants,
      searchQueries: searchQueries,
    );
  }

  List<String> _sanitizeArtistNames(List<String> artists) {
    return artists
        .map((name) => name
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(
              RegExp(r'\b(feat\.?|ft\.?|featuring)\b.*$', caseSensitive: false),
              '',
            )
            .trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _splitArtistNames(String artistField) {
    return artistField
        .split(
          RegExp(
            r'\s*(?:,|&|/|;|\band\b|\bfeat\.?\b|\bft\.?\b|\bfeaturing\b)\s*',
            caseSensitive: false,
          ),
        )
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  String _sanitizeTitle({
    required String rawTitle,
    required List<String> artistNames,
    String? album,
  }) {
    var title = rawTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty) return rawTitle;

    final parts = title
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: true);

    if (parts.length >= 2 && RegExp(r'^(?:19|20)\d{2}$').hasMatch(parts.last)) {
      parts.removeLast();
    }

    if ((album ?? '').trim().isNotEmpty &&
        parts.isNotEmpty &&
        _equalsIgnoreCase(parts.last, album!.trim())) {
      parts.removeLast();
    }

    title = parts.join(' ').trim();

    for (final artist in artistNames) {
      title = _removeTrailingTokenIgnoreCase(title, artist);
    }

    title = title
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[,\-\|\s]+'), '')
        .replaceAll(RegExp(r'[,\-\|\s]+$'), '')
        .trim();

    return title.isEmpty ? rawTitle.trim() : title;
  }

  bool _equalsIgnoreCase(String left, String right) {
    return left.toLowerCase() == right.toLowerCase();
  }

  String _removeTrailingTokenIgnoreCase(String input, String token) {
    final normalizedInput = input.trimRight();
    final normalizedToken = token.trim();
    if (normalizedInput.isEmpty || normalizedToken.isEmpty) {
      return normalizedInput;
    }

    final lowerInput = normalizedInput.toLowerCase();
    final lowerToken = normalizedToken.toLowerCase();
    if (!lowerInput.endsWith(lowerToken)) {
      return normalizedInput;
    }

    final cutIndex = normalizedInput.length - normalizedToken.length;
    var trimmed = normalizedInput.substring(0, cutIndex).trimRight();
    while (trimmed.isNotEmpty && ',-|'.contains(trimmed[trimmed.length - 1])) {
      trimmed = trimmed.substring(0, trimmed.length - 1).trimRight();
    }
    return trimmed;
  }

  Future<List<String>> _loadPriority() async {
    final raw = await _settingsDao.getSettingStr(SettingKeys.lyricsPriority);
    List<String> stored = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        stored = List<String>.from(jsonDecode(raw) as List);
      } catch (_) {
        stored = [];
      }
    }

    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final active = stored.where(loadedIds.contains).toList();
    if (active.isNotEmpty) return active;

    try {
      final available = await _pluginService.getAvailablePlugins();
      return available
          .where((plugin) =>
              plugin.pluginType == PluginType.lyricsProvider &&
              loadedIds.contains(plugin.manifest.id))
          .map((plugin) => plugin.manifest.id)
          .toList();
    } catch (e) {
      log('Failed to enumerate lyrics plugins: $e', name: 'LyricsCubit');
      return [];
    }
  }

  void _autoSave(Lyrics lyrics) {
    _settingsDao.getSettingBool(SettingKeys.autoSaveLyrics).then((enabled) {
      if ((enabled ?? false)) {
        _lyricsDao.putLyrics(lyrics);
        log('Lyrics saved for ID: ${lyrics.mediaID}', name: 'LyricsCubit');
      }
    });
  }

  void setLyricsToDB(Lyrics lyrics, String mediaID, {int? offset}) {
    final updated = lyrics.copyWith(mediaID: mediaID, offset: offset);
    _lyricsDao.putLyrics(updated, offset: offset).then((_) {
      emit(LyricsLoaded(updated, state.track));
    });
    log('Lyrics updated for ID: ${updated.mediaID} (offset: $offset)',
        name: 'LyricsCubit');
  }

  void deleteLyricsFromDB(Track track) {
    _lyricsDao.removeLyricsById(track.id).then((_) {
      emit(LyricsInitial());
      getLyrics(track);
      log('Lyrics deleted for ID: ${track.id}', name: 'LyricsCubit');
    });
  }

  @override
  Future<void> close() {
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}

class _LyricsTrackProfile {
  final TrackMatchTarget target;
  final List<plugin_models.TrackMetadata> metadataVariants;
  final List<String> searchQueries;

  const _LyricsTrackProfile({
    required this.target,
    required this.metadataVariants,
    required this.searchQueries,
  });
}

class _LyricsSearchCandidate {
  final plugin_models.LyricsMatch match;
  final double confidence;

  const _LyricsSearchCandidate({
    required this.match,
    required this.confidence,
  });
}
