// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'library_items_cubit.dart';

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

class LibraryItemsState {
  List<PlaylistItemProperties> playlists;
  LibraryItemsState({
    required this.playlists,
  });

  LibraryItemsState copyWith({
    List<PlaylistItemProperties>? playlists,
  }) {
    return LibraryItemsState(
      playlists: playlists ?? this.playlists,
    );
  }
}

final class LibraryItemsInitial extends LibraryItemsState {
  LibraryItemsInitial() : super(playlists: List.empty());
}
