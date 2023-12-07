// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_playlist_cubit.dart';

class CurrentPlaylistState extends MediaPlaylist {
  bool isFetched;
  late List<MediaItemModel> mediaItem;
  late String albumName;
  CurrentPlaylistState({
    required this.isFetched,
    required this.mediaItem,
    required this.albumName,
  }) : super(albumName: albumName, mediaItems: mediaItem);

  CurrentPlaylistState copyWith({
    bool? isFetched,
    List<MediaItemModel>? mediaItem,
    String? albumName,
  }) {
    return CurrentPlaylistState(
      isFetched: isFetched ?? this.isFetched,
      mediaItem: mediaItem ?? this.mediaItem,
      albumName: albumName ?? this.albumName,
    );
  }
}

final class CurrentPlaylistInitial extends CurrentPlaylistState {
  CurrentPlaylistInitial()
      : super(albumName: "", isFetched: false, mediaItem: []);
}

final class CurrentPlaylistLoading extends CurrentPlaylistState {
  CurrentPlaylistLoading()
      : super(albumName: "Loading", isFetched: false, mediaItem: []);
}
