// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'artist_cubit.dart';

class ArtistState extends Equatable {
  final ArtistModel artist;
  final bool isSavedCollection;
  const ArtistState({required this.artist, this.isSavedCollection = false});

  @override
  List<Object> get props =>
      [artist, artist.sourceId, artist.songs, artist.albums, isSavedCollection];

  ArtistState copyWith({
    ArtistModel? artist,
    bool? isSavedCollection,
  }) {
    return ArtistState(
      artist: artist ?? this.artist,
      isSavedCollection: isSavedCollection ?? this.isSavedCollection,
    );
  }
}

final class ArtistInitial extends ArtistState {
  ArtistInitial()
      : super(
            artist: ArtistModel(
          name: "",
          imageUrl: "",
          source: "",
          sourceId: "",
          sourceURL: "",
          country: "",
          genre: "",
          description: "",
        ));
}

final class ArtistLoading extends ArtistState {
  const ArtistLoading({required ArtistModel artist, super.isSavedCollection})
      : super(artist: artist);
}

final class ArtistLoaded extends ArtistState {
  const ArtistLoaded({required ArtistModel artist, super.isSavedCollection})
      : super(artist: artist);
}

final class ArtistError extends ArtistState {
  const ArtistError({required ArtistModel artist, super.isSavedCollection})
      : super(artist: artist);
}
