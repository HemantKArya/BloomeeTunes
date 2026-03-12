import 'package:equatable/equatable.dart';

import 'package:Bloomee/src/rust/api/plugin/models.dart';

enum ImportPhase {
  idle,
  checkingUrl,
  fetchingInfo,
  fetchingTracks,
  resolving,
  review,
  saving,
  done,
  error,
}

/// Resolution status of a single track during import.
enum TrackResolutionStatus {
  pending,
  resolving,
  resolved,
  failed,
}

/// A track from the import source paired with its resolution state.
class ImportTrackEntry extends Equatable {
  final ImportTrackItem sourceTrack;
  final TrackResolutionStatus status;

  /// Best auto-resolved track (first candidate found).
  final Track? resolvedTrack;

  /// Up to 5 candidate tracks from search results.
  final List<Track> candidates;

  /// User-selected candidate index.
  /// - null  → use [resolvedTrack] (auto best)
  /// - >= 0  → use [candidates[selectedCandidateIndex]]
  /// - -1    → user explicitly skipped this track
  final int? selectedCandidateIndex;

  const ImportTrackEntry({
    required this.sourceTrack,
    this.status = TrackResolutionStatus.pending,
    this.resolvedTrack,
    this.candidates = const [],
    this.selectedCandidateIndex,
  });

  /// Whether the user has explicitly chosen to skip this track.
  bool get isSkipped => selectedCandidateIndex == -1;

  /// The track that will be saved (respects user selection / skip).
  Track? get effectiveTrack {
    if (isSkipped) return null;
    final idx = selectedCandidateIndex;
    if (idx != null && idx >= 0 && idx < candidates.length) {
      return candidates[idx];
    }
    return resolvedTrack;
  }

  ImportTrackEntry copyWith({
    TrackResolutionStatus? status,
    Track? resolvedTrack,
    List<Track>? candidates,
    int? selectedCandidateIndex,
    bool clearSelection = false,
  }) {
    return ImportTrackEntry(
      sourceTrack: sourceTrack,
      status: status ?? this.status,
      resolvedTrack: resolvedTrack ?? this.resolvedTrack,
      candidates: candidates ?? this.candidates,
      selectedCandidateIndex: clearSelection
          ? null
          : (selectedCandidateIndex ?? this.selectedCandidateIndex),
    );
  }

  @override
  List<Object?> get props =>
      [sourceTrack, status, resolvedTrack, candidates, selectedCandidateIndex];
}

class ContentImportState extends Equatable {
  final ImportPhase phase;
  final String? pluginId;
  final String? url;
  final ImportCollectionSummary? collectionInfo;
  final List<ImportTrackEntry> tracks;
  final int resolvedCount;
  final int failedCount;
  final String? error;

  const ContentImportState({
    this.phase = ImportPhase.idle,
    this.pluginId,
    this.url,
    this.collectionInfo,
    this.tracks = const [],
    this.resolvedCount = 0,
    this.failedCount = 0,
    this.error,
  });

  ContentImportState copyWith({
    ImportPhase? phase,
    String? pluginId,
    String? url,
    ImportCollectionSummary? collectionInfo,
    List<ImportTrackEntry>? tracks,
    int? resolvedCount,
    int? failedCount,
    String? error,
    bool clearError = false,
  }) {
    return ContentImportState(
      phase: phase ?? this.phase,
      pluginId: pluginId ?? this.pluginId,
      url: url ?? this.url,
      collectionInfo: collectionInfo ?? this.collectionInfo,
      tracks: tracks ?? this.tracks,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      failedCount: failedCount ?? this.failedCount,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalTracks => tracks.length;

  @override
  List<Object?> get props => [
        phase,
        pluginId,
        url,
        collectionInfo,
        tracks,
        resolvedCount,
        failedCount,
        error,
      ];
}
