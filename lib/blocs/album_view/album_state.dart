// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'album_cubit.dart';

class AlbumState extends Equatable {
  const AlbumState({required this.album});
  final AlbumModel album;
  @override
  List<Object> get props => [album, album.songs];

  AlbumState copyWith({
    AlbumModel? album,
  }) {
    return AlbumState(
      album: album ?? this.album,
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
  const AlbumLoaded({required AlbumModel album}) : super(album: album);
}
