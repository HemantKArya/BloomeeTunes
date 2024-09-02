// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'album_cubit.dart';

class AlbumState extends Equatable {
  const AlbumState({required this.album, this.isSavedToCollections = false});
  final AlbumModel album;
  final bool isSavedToCollections;
  @override
  List<Object> get props => [album, album.songs, isSavedToCollections];

  AlbumState copyWith({
    AlbumModel? album,
    bool? isSavedToCollections,
  }) {
    return AlbumState(
      album: album ?? this.album,
      isSavedToCollections: isSavedToCollections ?? this.isSavedToCollections,
    );
  }
}

final class AlbumInitial extends AlbumState {
  AlbumInitial()
      : super(
            album: AlbumModel(
          name: "",
          imageURL: "",
          source: "",
          sourceId: "",
          artists: "",
          year: "",
          sourceURL: "",
        ));
}

final class AlbumLoading extends AlbumState {
  const AlbumLoading({required AlbumModel album}) : super(album: album);
}

final class AlbumLoaded extends AlbumState {
  const AlbumLoaded(
      {required AlbumModel album, super.isSavedToCollections = false})
      : super(album: album);
}
