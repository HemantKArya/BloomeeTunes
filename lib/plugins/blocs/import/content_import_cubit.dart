import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';

const int _kResolutionConcurrency = 5;
const Duration _kPluginTimeout = Duration(seconds: 10);
const double _kMinConfidence = 0.45;
const int _kMaxCandidatesPerTrack = 5;

class ContentImportCubit extends Cubit<ContentImportState> {
  final PluginService _pluginService;
  final CrossPluginResolver _resolver;
  final PlaylistDAO _playlistDao;

  bool _cancelRequested = false;

  ContentImportCubit({
    PluginService? pluginService,
    CrossPluginResolver? resolver,
    PlaylistDAO? playlistDao,
  })  : _pluginService = pluginService ?? ServiceLocator.pluginService,
        _resolver = resolver ??
            CrossPluginResolver(
              pluginService: pluginService ?? ServiceLocator.pluginService,
            ),
        _playlistDao = playlistDao ?? _defaultPlaylistDao(),
        super(const ContentImportState());

  static PlaylistDAO _defaultPlaylistDao() {
    final trackDao = TrackDAO(DBProvider.db);
    return PlaylistDAO(DBProvider.db, trackDao);
  }

  // ── Step 1: Check URL ────────────────────────────────────────────────────

  Future<void> checkUrl(String pluginId, String url) async {
    _cancelRequested = false;
    emit(state.copyWith(
      phase: ImportPhase.checkingUrl,
      pluginId: pluginId,
      url: url,
      clearError: true,
    ));

    try {
      final response = await _pluginService
          .execute(
            pluginId: pluginId,
            request: PluginRequest.contentImporter(
              ContentImporterCommand.canHandleUrl(url: url),
            ),
          )
          .timeout(_kPluginTimeout);

      if (response is PluginResponse_CanHandle && response.field0) {
        await _fetchCollectionInfo(pluginId, url);
      } else {
        emit(state.copyWith(
          phase: ImportPhase.error,
          error: 'This plugin cannot handle the provided URL.',
        ));
      }
    } on TimeoutException {
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Plugin timed out while checking URL.',
      ));
    } catch (e) {
      log('checkUrl failed: $e', name: 'ContentImportCubit');
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Failed to check URL: $e',
      ));
    }
  }

  // ── Step 2: Fetch Collection Info ────────────────────────────────────────

  Future<void> _fetchCollectionInfo(String pluginId, String url) async {
    emit(state.copyWith(phase: ImportPhase.fetchingInfo));

    try {
      final response = await _pluginService
          .execute(
            pluginId: pluginId,
            request: PluginRequest.contentImporter(
              ContentImporterCommand.getCollectionInfo(url: url),
            ),
          )
          .timeout(_kPluginTimeout);

      if (response is PluginResponse_CollectionInfo) {
        emit(state.copyWith(
          collectionInfo: response.field0,
          phase: ImportPhase.fetchingTracks,
        ));
        await _fetchTracks(pluginId, url);
      } else {
        emit(state.copyWith(
          phase: ImportPhase.error,
          error: 'Unexpected response when fetching collection info.',
        ));
      }
    } on TimeoutException {
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Timed out fetching collection info.',
      ));
    } catch (e) {
      log('_fetchCollectionInfo failed: $e', name: 'ContentImportCubit');
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Failed to fetch collection info: $e',
      ));
    }
  }

  // ── Step 3: Fetch Tracks ─────────────────────────────────────────────────

  Future<void> _fetchTracks(String pluginId, String url) async {
    try {
      final response = await _pluginService
          .execute(
            pluginId: pluginId,
            request: PluginRequest.contentImporter(
              ContentImporterCommand.getTracks(url: url),
            ),
          )
          .timeout(_kPluginTimeout);

      if (response is PluginResponse_ImportTracks) {
        final entries = response.field0
            .map((t) => ImportTrackEntry(sourceTrack: t))
            .toList();
        emit(state.copyWith(
          tracks: List.unmodifiable(entries),
          phase: ImportPhase.resolving,
        ));
        await _resolveTracks();
      } else {
        emit(state.copyWith(
          phase: ImportPhase.error,
          error: 'Unexpected response when fetching tracks.',
        ));
      }
    } on TimeoutException {
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Timed out fetching tracks.',
      ));
    } catch (e) {
      log('_fetchTracks failed: $e', name: 'ContentImportCubit');
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Failed to fetch tracks: $e',
      ));
    }
  }

  // ── Step 4: Resolve Tracks ───────────────────────────────────────────────

  Future<void> _resolveTracks() async {
    final resolverPluginIds = await _getContentResolverPluginIds();
    if (resolverPluginIds.isEmpty) {
      log('No content-resolver plugins loaded; skipping resolution.',
          name: 'ContentImportCubit');
      emit(state.copyWith(phase: ImportPhase.review));
      return;
    }

    final tracks = List<ImportTrackEntry>.from(state.tracks);
    final semaphore = Semaphore(_kResolutionConcurrency);
    final futures = <Future<void>>[];

    for (var i = 0; i < tracks.length; i++) {
      final index = i;
      futures.add(
        semaphore.run(() => _resolveOneEntry(
              tracks: tracks,
              index: index,
              pluginIds: resolverPluginIds,
            )),
      );
    }

    await Future.wait(futures);

    if (!isClosed && !_cancelRequested) {
      final counts = _recount(tracks);
      log(
        'Resolution complete: ${counts.resolved} resolved, '
        '${counts.failed} failed out of ${tracks.length}',
        name: 'ContentImportCubit',
      );
      emit(state.copyWith(
        tracks: List.unmodifiable(tracks),
        resolvedCount: counts.resolved,
        failedCount: counts.failed,
        phase: ImportPhase.review,
      ));
    }
  }

  Future<void> _resolveOneEntry({
    required List<ImportTrackEntry> tracks,
    required int index,
    required List<String> pluginIds,
  }) async {
    if (isClosed || _cancelRequested) return;

    final entry = tracks[index];

    // Mark as resolving.
    tracks[index] = entry.copyWith(status: TrackResolutionStatus.resolving);
    if (!isClosed) {
      emit(state.copyWith(tracks: List.unmodifiable(tracks)));
    }

    try {
      final target = TrackMatchTarget.fromImport(
        title: entry.sourceTrack.title,
        artists: entry.sourceTrack.artists,
        durationMs: entry.sourceTrack.durationMs?.toInt(),
      );

      // Use the shared resolver — parallel across plugins, scored, with
      // early-exit on high confidence.
      final candidates = await _resolver.resolveTrack(
        target: target,
        pluginIds: pluginIds,
        sequential: false,
        minConfidence: _kMinConfidence,
        earlyAcceptThreshold: 0.93,
        limit: _kMaxCandidatesPerTrack,
      );

      if (isClosed || _cancelRequested) return;

      if (candidates.isNotEmpty) {
        tracks[index] = entry.copyWith(
          status: TrackResolutionStatus.resolved,
          resolvedTrack: candidates.first.track,
          candidates: candidates.map((c) => c.track).toList(growable: false),
        );
      } else {
        tracks[index] = entry.copyWith(
          status: TrackResolutionStatus.failed,
          candidates: const [],
        );
      }
    } catch (e) {
      log(
        'Failed to resolve "${entry.sourceTrack.title}": $e',
        name: 'ContentImportCubit',
      );
      if (!isClosed && !_cancelRequested) {
        tracks[index] = entry.copyWith(
          status: TrackResolutionStatus.failed,
          candidates: const [],
        );
      }
    }

    // Emit progress.
    if (!isClosed && !_cancelRequested) {
      final counts = _recount(tracks);
      emit(state.copyWith(
        tracks: List.unmodifiable(tracks),
        resolvedCount: counts.resolved,
        failedCount: counts.failed,
      ));
    }
  }

  // ── Cancellation ─────────────────────────────────────────────────────────

  void cancelResolution() {
    if (state.phase != ImportPhase.resolving) return;
    _cancelRequested = true;
    log('Resolution cancelled by user.', name: 'ContentImportCubit');

    final counts = _recount(state.tracks);
    emit(state.copyWith(
      phase: ImportPhase.review,
      resolvedCount: counts.resolved,
      failedCount: counts.failed,
    ));
  }

  // ── User candidate selection ─────────────────────────────────────────────

  void pickCandidate(int trackIndex, int? candidateIdx) {
    final tracks = List<ImportTrackEntry>.from(state.tracks);
    if (trackIndex < 0 || trackIndex >= tracks.length) return;

    tracks[trackIndex] = tracks[trackIndex].copyWith(
      selectedCandidateIndex: candidateIdx,
    );

    final counts = _recount(tracks);
    emit(state.copyWith(
      tracks: List.unmodifiable(tracks),
      resolvedCount: counts.resolved,
      failedCount: counts.failed,
    ));
  }

  // ── Step 5: Save to Library ──────────────────────────────────────────────

  Future<void> saveToLibrary({String? customName}) async {
    final info = state.collectionInfo;
    if (info == null) return;

    emit(state.copyWith(phase: ImportPhase.saving));

    try {
      final rawName = customName?.trim().isNotEmpty == true
          ? customName!.trim()
          : info.title.trim();
      final playlistName = rawName.isNotEmpty ? rawName : 'Imported Playlist';

      final playlistId = await _playlistDao.ensurePlaylist(playlistName);

      final thumbUrl = info.thumbnailUrl;
      if (thumbUrl != null && thumbUrl.isNotEmpty) {
        await _playlistDao.updatePlaylistThumbnail(playlistId, thumbUrl);
      }

      var savedCount = 0;
      for (final entry in state.tracks) {
        final track = entry.effectiveTrack;
        if (track != null) {
          await _playlistDao.addTrackToPlaylist(playlistId, track);
          savedCount++;
        }
      }

      log('Saved $savedCount tracks to "$playlistName".',
          name: 'ContentImportCubit');

      emit(state.copyWith(
        phase: ImportPhase.done,
        resolvedCount: savedCount,
      ));
    } catch (e) {
      log('saveToLibrary failed: $e', name: 'ContentImportCubit');
      emit(state.copyWith(
        phase: ImportPhase.error,
        error: 'Failed to save playlist: $e',
      ));
    }
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    _cancelRequested = false;
    emit(const ContentImportState());
  }

  // ── M3U Import ────────────────────────────────────────────────────────────

  /// Directly loads tracks parsed from an M3U file and starts resolution.
  ///
  /// Bypasses the URL-check / collection-info / fetch-tracks plugin steps.
  /// The [summary] provides playlist metadata (title, kind, trackCount).
  Future<void> loadFromM3U(
    List<ImportTrackItem> tracks,
    ImportCollectionSummary summary,
  ) async {
    _cancelRequested = false;
    emit(state.copyWith(
      phase: ImportPhase.resolving,
      collectionInfo: summary,
      tracks: List.unmodifiable(
        tracks.map((t) => ImportTrackEntry(sourceTrack: t)).toList(),
      ),
      clearError: true,
    ));
    await _resolveTracks();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns only loaded content-resolver plugin IDs.
  Future<List<String>> _getContentResolverPluginIds() async {
    final available = await _pluginService.getAvailablePlugins();
    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    return available
        .where((p) =>
            p.pluginType == PluginType.contentResolver &&
            loadedIds.contains(p.manifest.id))
        .map((p) => p.manifest.id)
        .toList(growable: false);
  }

  /// Single source of truth for resolved/failed counts.
  ({int resolved, int failed}) _recount(List<ImportTrackEntry> tracks) {
    var resolved = 0;
    var failed = 0;
    for (final t in tracks) {
      if (t.isSkipped) {
        failed++;
      } else if (t.effectiveTrack != null) {
        resolved++;
      } else if (t.status != TrackResolutionStatus.pending &&
          t.status != TrackResolutionStatus.resolving) {
        failed++;
      }
    }
    return (resolved: resolved, failed: failed);
  }
}
