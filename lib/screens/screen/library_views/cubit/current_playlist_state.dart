// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_playlist_cubit.dart';

class CurrentPlaylistState extends Equatable {
  final bool isFetched;
  final List<MediaItemModel> mediaItems;
  final String albumName;
  const CurrentPlaylistState({
    required this.isFetched,
    required this.mediaItems,
    required this.albumName,
  });

  CurrentPlaylistState copyWith({
    bool? isFetched,
    List<MediaItemModel>? mediaItem,
    String? albumName,
  }) {
    return CurrentPlaylistState(
      isFetched: isFetched ?? this.isFetched,
      mediaItems: mediaItem ?? mediaItems,
      albumName: albumName ?? this.albumName,
    );
  }

  @override
  List<Object?> get props => [isFetched, mediaItems, albumName];
}

final class CurrentPlaylistInitial extends CurrentPlaylistState {
  CurrentPlaylistInitial()
      : super(albumName: "", isFetched: false, mediaItems: []);
}

final class CurrentPlaylistLoading extends CurrentPlaylistState {
  CurrentPlaylistLoading()
      : super(albumName: "Loading", isFetched: false, mediaItems: []);
}
