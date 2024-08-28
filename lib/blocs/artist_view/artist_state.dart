// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'artist_cubit.dart';

class ArtistState extends Equatable {
  final ArtistModel artist;
  const ArtistState({required this.artist});

  @override
  List<Object> get props =>
      [artist, artist.sourceId, artist.songs, artist.albums];

  ArtistState copyWith({
    ArtistModel? artist,
  }) {
    return ArtistState(
      artist: artist ?? this.artist,
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
  const ArtistLoading({required ArtistModel artist}) : super(artist: artist);
}

final class ArtistLoaded extends ArtistState {
  const ArtistLoaded({required ArtistModel artist}) : super(artist: artist);
}

final class ArtistError extends ArtistState {
  const ArtistError({required ArtistModel artist}) : super(artist: artist);
}
