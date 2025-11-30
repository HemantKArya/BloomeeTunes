part of 'library_search_cubit.dart';

abstract class LibrarySearchState extends Equatable {
  const LibrarySearchState();

  @override
  List<Object> get props => [];
}

class LibrarySearchInitial extends LibrarySearchState {}

class LibrarySearchLoading extends LibrarySearchState {}

class LibrarySearchSuccess extends LibrarySearchState {
  final String query;
  final List<SongSearchResult> songResults;
  final List<PlaylistItemProperties> filteredPlaylists;
  final List<ArtistModel> filteredArtists;
  final List<AlbumModel> filteredAlbums;
  final List<PlaylistOnlModel> filteredOnlinePlaylists;

  const LibrarySearchSuccess({
    required this.query,
    this.songResults = const [],
    this.filteredPlaylists = const [],
    this.filteredArtists = const [],
    this.filteredAlbums = const [],
    this.filteredOnlinePlaylists = const [],
  });

  @override
  List<Object> get props => [
        query,
        songResults,
        filteredPlaylists,
        filteredArtists,
        filteredAlbums,
        filteredOnlinePlaylists,
      ];
}

class LibrarySearchError extends LibrarySearchState {
  final String message;

  const LibrarySearchError(this.message);

  @override
  List<Object> get props => [message];
}
