part of 'online_playlist_cubit.dart';

sealed class OnlPlaylistState extends Equatable {
  const OnlPlaylistState({required this.playlist});
  final PlaylistOnlModel playlist;
  @override
  List<Object> get props => [playlist, playlist.songs, playlist.sourceId];
}

class OnlPlaylistInitial extends OnlPlaylistState {
  OnlPlaylistInitial()
      : super(
            playlist: PlaylistOnlModel(
          source: '',
          sourceId: '',
          name: '',
          imageURL: '',
          artists: '',
          year: '',
          sourceURL: '',
        ));
}

final class OnlPlaylistLoaded extends OnlPlaylistState {
  const OnlPlaylistLoaded({required PlaylistOnlModel playlist})
      : super(playlist: playlist);
}

final class OnlPlaylistLoading extends OnlPlaylistState {
  const OnlPlaylistLoading({required PlaylistOnlModel playlist})
      : super(playlist: playlist);
}

final class OnlPlaylistError extends OnlPlaylistState {
  const OnlPlaylistError({required PlaylistOnlModel playlist})
      : super(playlist: playlist);
}
