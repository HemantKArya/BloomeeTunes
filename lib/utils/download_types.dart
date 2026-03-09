/// Shared domain types for the download subsystem.
///
/// These are the Dart-side view types used by the cubit state and the UI.
/// The actual download work is done by the Rust DownloadManager exposed via FRB.
import 'package:Bloomee/core/models/exported.dart';

/// Mirrors the states of the Rust `DownloadTaskState` enum but expressed in
/// Dart terms that the UI can switch on.
enum DownloadState {
  queued,
  resolving,
  downloading,
  paused,
  retrying,
  fetchingMetadata,
  completed,
  failed,
  cancelled,
}

/// A snapshot of the current progress and state for a single download.
class DownloadStatus {
  final DownloadState state;
  final double progress;
  final String? message;
  final String? filePath;

  const DownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.message,
    this.filePath,
  });
}

/// Lightweight task descriptor held by the cubit state and the UI.
///
/// This is intentionally minimal – the full truth lives in the Rust manager.
/// The `taskId` is the opaque ID returned by `enqueue` and used for
/// pause/resume/cancel calls.
class DownloadTask {
  /// Opaque ID from the Rust download manager. Empty until the task is queued.
  final String taskId;

  /// The track being downloaded. Used for display and library writes.
  final Track song;

  /// The media ID (`pluginId::localId`) of the track. Used to match incoming
  /// events against in-progress downloads.
  final String mediaId;

  /// Final file name (populated once stream resolution completes).
  final String fileName;

  /// Absolute path to the completed file (empty while in progress).
  final String targetPath;

  const DownloadTask({
    required this.taskId,
    required this.song,
    required this.mediaId,
    this.fileName = '',
    this.targetPath = '',
  });
}
