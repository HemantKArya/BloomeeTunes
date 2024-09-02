// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'online_playlist_cubit.dart';

class OnlPlaylistState extends Equatable {
  const OnlPlaylistState(
      {required this.playlist, this.isSavedCollection = false});
  final PlaylistOnlModel playlist;
  final bool isSavedCollection;
  @override
  List<Object> get props =>
      [playlist, playlist.songs, playlist.sourceId, isSavedCollection];

  OnlPlaylistState copyWith({
    PlaylistOnlModel? playlist,
    bool? isSavedCollection,
  }) {
    return OnlPlaylistState(
      playlist: playlist ?? this.playlist,
      isSavedCollection: isSavedCollection ?? this.isSavedCollection,
    );
  }
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
  const OnlPlaylistLoaded(
      {required PlaylistOnlModel playlist, super.isSavedCollection})
      : super(playlist: playlist);
}

final class OnlPlaylistLoading extends OnlPlaylistState {
  const OnlPlaylistLoading(
      {required PlaylistOnlModel playlist, super.isSavedCollection})
      : super(playlist: playlist);
}

final class OnlPlaylistError extends OnlPlaylistState {
  const OnlPlaylistError(
      {required PlaylistOnlModel playlist, super.isSavedCollection})
      : super(playlist: playlist);
}
