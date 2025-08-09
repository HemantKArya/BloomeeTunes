part of 'library_items_cubit.dart';

sealed class LibraryItemsState extends Equatable {
  final List<PlaylistItemProperties> playlists;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<PlaylistOnlModel> playlistsOnl;

  const LibraryItemsState({
    this.playlists = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlistsOnl = const [],
  });

  @override
  List<Object?> get props => [playlists, artists, albums, playlistsOnl];

  // copyWith allows for updating state without creating entirely new objects
  LibraryItemsState copyWith({
    List<PlaylistItemProperties>? playlists,
    List<ArtistModel>? artists,
    List<AlbumModel>? albums,
    List<PlaylistOnlModel>? playlistsOnl,
  }) {
    return LibraryItemsLoaded(
      playlists: playlists ?? this.playlists,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      playlistsOnl: playlistsOnl ?? this.playlistsOnl,
    );
  }
}

// State for when the library is being loaded for the first time
final class LibraryItemsLoading extends LibraryItemsState {}

// State for when data is successfully loaded
final class LibraryItemsLoaded extends LibraryItemsState {
  const LibraryItemsLoaded({
    required super.playlists,
    required super.artists,
    required super.albums,
    required super.playlistsOnl,
  });
}

// State for handling any errors during data fetch
final class LibraryItemsError extends LibraryItemsState {
  final String message;
  const LibraryItemsError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Keep PlaylistItemProperties as it is ---
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
