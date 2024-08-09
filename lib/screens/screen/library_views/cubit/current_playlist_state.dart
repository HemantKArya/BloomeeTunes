// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_playlist_cubit.dart';

class CurrentPlaylistState extends Equatable {
  final bool isFetched;
  final MediaPlaylist mediaPlaylist;
  const CurrentPlaylistState({
    required this.isFetched,
    required this.mediaPlaylist,
  });

  CurrentPlaylistState copyWith({
    bool? isFetched,
    List<MediaItemModel>? mediaItem,
    String? playlistName,
    MediaPlaylist? mediaPlaylist,
  }) {
    return CurrentPlaylistState(
      isFetched: isFetched ?? this.isFetched,
      mediaPlaylist: mediaPlaylist ?? this.mediaPlaylist,
    );
  }

  @override
  List<Object?> get props => [
        isFetched,
        mediaPlaylist,
        mediaPlaylist.playlistName,
        mediaPlaylist.permaURL
      ];
}

final class CurrentPlaylistInitial extends CurrentPlaylistState {
  CurrentPlaylistInitial()
      : super(
            isFetched: false,
            mediaPlaylist: MediaPlaylist(mediaItems: [], playlistName: ""));
}

final class CurrentPlaylistLoading extends CurrentPlaylistState {
  CurrentPlaylistLoading()
      : super(
            isFetched: false,
            mediaPlaylist:
                MediaPlaylist(mediaItems: [], playlistName: "loading"));
}
