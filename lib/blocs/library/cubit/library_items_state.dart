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
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<PlaylistOnlModel> playlistsOnl;
  const LibraryItemsState({
    required this.playlists,
    this.artists = const [],
    this.albums = const [],
    this.playlistsOnl = const [],
  });

  @override
  List<Object?> get props => [playlists, playlistsOnl, albums, artists];

  LibraryItemsState copyWith({
    List<PlaylistItemProperties>? playlists,
    List<ArtistModel>? artists,
    List<AlbumModel>? albums,
    List<PlaylistOnlModel>? playlistsOnl,
  }) {
    return LibraryItemsState(
      playlists: playlists ?? this.playlists,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      playlistsOnl: playlistsOnl ?? this.playlistsOnl,
    );
  }
}

final class LibraryItemsInitial extends LibraryItemsState {
  LibraryItemsInitial() : super(playlists: List.empty());
}
