// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'library_items_cubit.dart';

class PlaylistItemProperties extends Equatable {
  final String playlistName;
  final String? coverImgUrl;
  final String? subTitle;
  const PlaylistItemProperties({
    required this.playlistName,
    required this.coverImgUrl,
    required this.subTitle,
  });

  @override
  List<Object?> get props => [playlistName, coverImgUrl, subTitle];
}

class LibraryItemsState extends Equatable {
  final List<PlaylistItemProperties> playlists;
  const LibraryItemsState({
    required this.playlists,
  });

  LibraryItemsState copyWith({
    List<PlaylistItemProperties>? playlists,
  }) {
    return LibraryItemsState(
      playlists: playlists ?? this.playlists,
    );
  }

  @override
  List<Object?> get props => [playlists];
}

final class LibraryItemsInitial extends LibraryItemsState {
  LibraryItemsInitial() : super(playlists: List.empty());
}
