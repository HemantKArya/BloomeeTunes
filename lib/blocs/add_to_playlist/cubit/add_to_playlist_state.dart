part of 'add_to_playlist_cubit.dart';

class PlaylistItemProperties {
  String? playlistName;
  ImageProvider? imageProvider;
  String? subTitle;
  PlaylistItemProperties({
    required this.playlistName,
    required this.imageProvider,
    required this.subTitle,
  });

  @override
  bool operator ==(covariant PlaylistItemProperties other) {
    if (identical(this, other)) return true;

    return other.playlistName == playlistName &&
        other.imageProvider == imageProvider &&
        other.subTitle == subTitle;
  }

  @override
  int get hashCode =>
      playlistName.hashCode ^ imageProvider.hashCode ^ subTitle.hashCode;
}

class AddToPlaylistState {
  List<PlaylistItemProperties> playlists;
  AddToPlaylistState({
    required this.playlists,
  });

  AddToPlaylistState copyWith({
    List<PlaylistItemProperties>? playlists,
  }) {
    return AddToPlaylistState(
      playlists: playlists ?? this.playlists,
    );
  }
}

final class AddToPlaylistInitial extends AddToPlaylistState {
  AddToPlaylistInitial() : super(playlists: List.empty());
}
