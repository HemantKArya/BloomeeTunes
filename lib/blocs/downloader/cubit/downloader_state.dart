part of 'downloader_cubit.dart';

sealed class DownloaderState extends Equatable {
  const DownloaderState();

  @override
  List<Object> get props => [];
}

final class DownloaderInitial extends DownloaderState {}

final class DownloadProgress extends DownloaderState {
  final String taskId;
  final String songId;
  final int progress;
  final int status;

  const DownloadProgress({
    required this.taskId,
    required this.songId,
    required this.progress,
    required this.status,
  });

  @override
  List<Object> get props => [taskId, songId, progress, status];
}

final class DownloadCompleted extends DownloaderState {
  final String songId;
  final bool success;

  const DownloadCompleted({
    required this.songId,
    required this.success,
  });

  @override
  List<Object> get props => [songId, success];
}
