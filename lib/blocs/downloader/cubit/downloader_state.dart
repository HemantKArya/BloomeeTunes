// lib/blocs/downloader/downloader_state.dart

part of 'downloader_cubit.dart';

/// A wrapper class to link a DownloadTask to its live status.
class DownloadProgress with EquatableMixin {
  final DownloadTask task;
  final DownloadStatus status;

  DownloadProgress({required this.task, required this.status});

  @override
  List<Object?> get props => [
        task.taskId.isEmpty ? task.mediaId : task.taskId,
        status.state,
        status.progress,
      ];
}

abstract class DownloaderState extends Equatable {
  final List<DownloadProgress> downloads;
  final List<Track> downloaded;

  const DownloaderState(
      {this.downloads = const [], this.downloaded = const []});

  @override
  List<Object> get props => [downloads, downloaded];
}

/// The initial state of the downloader cubit.
class DownloaderInitial extends DownloaderState {}

/// State when both downloads and downloaded songs are loaded
class DownloaderLoaded extends DownloaderState {
  const DownloaderLoaded({
    required List<DownloadProgress> downloads,
    required List<Track> downloaded,
  }) : super(downloads: downloads, downloaded: downloaded);
}

/// This state is emitted whenever there is an update to any download's
/// status, progress, or when a new download is added.
class DownloaderTasksUpdated extends DownloaderState {
  const DownloaderTasksUpdated(
      List<DownloadProgress> downloads, List<Track> downloaded)
      : super(downloads: downloads, downloaded: downloaded);
}
