// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_playlist_cubit.dart';

class CurrentPlaylistState extends Equatable {
  final bool isFetched;
  final Playlist playlist;

  const CurrentPlaylistState({
    required this.isFetched,
    required this.playlist,
  });

  CurrentPlaylistState copyWith({
    bool? isFetched,
    Playlist? playlist,
  }) {
    return CurrentPlaylistState(
      isFetched: isFetched ?? this.isFetched,
      playlist: playlist ?? this.playlist,
    );
  }

  @override
  List<Object?> get props => [isFetched, playlist, playlist.title];
}

final class CurrentPlaylistInitial extends CurrentPlaylistState {
  const CurrentPlaylistInitial()
      : super(
            isFetched: false, playlist: const Playlist(tracks: [], title: ''));
}

final class CurrentPlaylistLoading extends CurrentPlaylistState {
  const CurrentPlaylistLoading()
      : super(
            isFetched: false,
            playlist: const Playlist(tracks: [], title: 'loading'));
}
