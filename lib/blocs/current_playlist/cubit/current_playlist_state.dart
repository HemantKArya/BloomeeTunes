// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_playlist_cubit.dart';

enum CurrentPlaylistLoadStatus {
  initial,
  loading,
  partial,
  success,
  error,
}

class CurrentPlaylistState extends Equatable {
  final bool isFetched;
  final Playlist playlist;
  final CurrentPlaylistLoadStatus status;
  final int totalTracks;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const CurrentPlaylistState({
    required this.isFetched,
    required this.playlist,
    this.status = CurrentPlaylistLoadStatus.initial,
    this.totalTracks = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  CurrentPlaylistState copyWith({
    bool? isFetched,
    Playlist? playlist,
    CurrentPlaylistLoadStatus? status,
    int? totalTracks,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return CurrentPlaylistState(
      isFetched: isFetched ?? this.isFetched,
      playlist: playlist ?? this.playlist,
      status: status ?? this.status,
      totalTracks: totalTracks ?? this.totalTracks,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isFetched,
        playlist,
        playlist.title,
        status,
        totalTracks,
        hasMore,
        isLoadingMore,
        errorMessage,
      ];
}

final class CurrentPlaylistInitial extends CurrentPlaylistState {
  const CurrentPlaylistInitial()
      : super(
          isFetched: false,
          playlist: const Playlist(tracks: [], title: ''),
          status: CurrentPlaylistLoadStatus.initial,
        );
}

final class CurrentPlaylistLoading extends CurrentPlaylistState {
  const CurrentPlaylistLoading()
      : super(
          isFetched: false,
          playlist: const Playlist(tracks: [], title: 'loading'),
          status: CurrentPlaylistLoadStatus.loading,
        );
}
