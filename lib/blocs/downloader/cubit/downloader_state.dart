part of 'downloader_cubit.dart';

sealed class DownloaderState extends Equatable {
  const DownloaderState();

  @override
  List<Object> get props => [];
}

final class DownloaderInitial extends DownloaderState {}
