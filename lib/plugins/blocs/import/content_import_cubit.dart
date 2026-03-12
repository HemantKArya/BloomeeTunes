import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';

/// Cubit managing the full content-import workflow:
///
/// 1. **URL check** — ask the importer plugin if it can handle the URL.
/// 2. **Collection info** — fetch summary (title, thumbnail, track count).
/// 3. **Track list** — fetch all tracks from the source.
/// 4. **Resolution** — for each track, search loaded content-resolver
///    plugins to find a playable match.
/// 5. **Review** — user inspects results before saving.
/// 6. **Save** — persist resolved tracks into a new library playlist.
class ContentImportCubit extends Cubit<ContentImportState> {
  final PluginService _pluginService;

  ContentImportCubit({PluginService? pluginService})
      : _pluginService = pluginService ?? ServiceLocator.pluginService,
        super(const ContentImportState());

  // ── Step 1: Check URL ────────────────────────────────────────────────────

  Future<void> checkUrl(String pluginId, String url) async {
    emit(state.copyWith(
      phase: ImportPhase.checkingUrl,
      pluginId: pluginId,
      url: url,
      clearError: true,
    ));

    try {
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.contentImporter(
          ContentImporterCommand.canHandleUrl(url: url),
        ),
      );

      if (response is PluginResponse_CanHandle && response.field0) {
        await _fetchCollectionInfo(pluginId, url);
      } else {
        emit(state.copyWith(
          phase: ImportPhase.error,
          error: 'This plugin cannot handle the provided URL.',
        ));
      }
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
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.contentImporter(
          ContentImporterCommand.getCollectionInfo(url: url),
        ),
      );

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
      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: PluginRequest.contentImporter(
          ContentImporterCommand.getTracks(url: url),
        ),
      );

      if (response is PluginResponse_ImportTracks) {
        final entries = response.field0
            .map((t) => ImportTrackEntry(sourceTrack: t))
            .toList();
        emit(state.copyWith(
          tracks: entries,
          phase: ImportPhase.resolving,
        ));
        await _resolveTracks();
      } else {
        emit(state.copyWith(
          phase: ImportPhase.error,
          error: 'Unexpected response when fetching tracks.',
        ));
      }
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
    final loadedPlugins = _pluginService.getLoadedPlugins();
    final tracks = List<ImportTrackEntry>.from(state.tracks);
    var resolved = 0;
    var failed = 0;

    for (var i = 0; i < tracks.length; i++) {
      if (isClosed) return;

      final entry = tracks[i];
      tracks[i] = entry.copyWith(status: TrackResolutionStatus.resolving);
      emit(state.copyWith(tracks: List.unmodifiable(tracks)));

      final query =
          '${entry.sourceTrack.title} ${entry.sourceTrack.artists.join(' ')}';
      final candidates = await _searchCandidates(query, loadedPlugins);

      if (candidates.isNotEmpty) {
        tracks[i] = entry.copyWith(
          status: TrackResolutionStatus.resolved,
          resolvedTrack: candidates.first,
          candidates: candidates,
        );
        resolved++;
      } else {
        tracks[i] = entry.copyWith(
          status: TrackResolutionStatus.failed,
          candidates: const [],
        );
        failed++;
      }

      emit(state.copyWith(
        tracks: List.unmodifiable(tracks),
        resolvedCount: resolved,
        failedCount: failed,
      ));
    }

    emit(state.copyWith(phase: ImportPhase.review));
  }

  /// Search for up to [maxResults] candidate tracks across all loaded
  /// content-resolver plugins.
  Future<List<Track>> _searchCandidates(
    String query,
    List<String> pluginIds, {
    int maxResults = 5,
  }) async {
    final results = <Track>[];
    for (final pluginId in pluginIds) {
      if (results.length >= maxResults) break;
      try {
        final response = await _pluginService.execute(
          pluginId: pluginId,
          request: PluginRequest.contentResolver(
            ContentResolverCommand.search(
              query: query,
              filter: ContentSearchFilter.track,
            ),
          ),
        );

        if (response is PluginResponse_Search) {
          for (final item in response.field0.items) {
            if (item is MediaItem_Track && results.length < maxResults) {
              results.add(item.field0);
            }
          }
        }
      } catch (_) {
        continue;
      }
    }
    return results;
  }

  // ── User candidate selection ────────────────────────────────────────────

  /// Let the user explicitly pick a candidate (or skip) for a resolved track.
  ///
  /// [candidateIdx] is the index into [ImportTrackEntry.candidates];
  /// pass -1 to skip the track (exclude from save).
  void pickCandidate(int trackIndex, int? candidateIdx) {
    final tracks = List<ImportTrackEntry>.from(state.tracks);
    if (trackIndex < 0 || trackIndex >= tracks.length) return;

    tracks[trackIndex] =
        tracks[trackIndex].copyWith(selectedCandidateIndex: candidateIdx);

    // Recount from scratch so counts stay accurate.
    final resolved =
        tracks.where((t) => !t.isSkipped && t.effectiveTrack != null).length;
    final failed = tracks
        .where((t) =>
            t.isSkipped ||
            (t.effectiveTrack == null &&
                t.status != TrackResolutionStatus.pending &&
                t.status != TrackResolutionStatus.resolving))
        .length;

    emit(state.copyWith(
      tracks: List.unmodifiable(tracks),
      resolvedCount: resolved,
      failedCount: failed,
    ));
  }

  // ── Step 5: Save to Library ──────────────────────────────────────────────

  Future<void> saveToLibrary({String? customName}) async {
    final info = state.collectionInfo;
    if (info == null) return;

    emit(state.copyWith(phase: ImportPhase.saving));

    try {
      // Use provided name → collection title → fallback.
      final rawName = customName?.trim().isNotEmpty == true
          ? customName!.trim()
          : info.title.trim();
      final playlistName = rawName.isNotEmpty ? rawName : 'Imported Playlist';

      final trackDao = TrackDAO(DBProvider.db);
      final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
      final playlistId = await playlistDao.ensurePlaylist(playlistName);

      // Set thumbnail from collection summary if available.
      final thumbUrl = info.thumbnailUrl;
      if (thumbUrl != null && thumbUrl.isNotEmpty) {
        await playlistDao.updatePlaylistThumbnail(playlistId, thumbUrl);
      }

      var savedCount = 0;
      for (final entry in state.tracks) {
        final track = entry.effectiveTrack;
        if (track != null) {
          await playlistDao.addTrackToPlaylist(playlistId, track);
          savedCount++;
        }
      }

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

  /// Reset the cubit state for a new import.
  void reset() {
    emit(const ContentImportState());
  }
}
