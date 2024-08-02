// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'lyrics_cubit.dart';

class LyricsState extends Equatable {
  const LyricsState(
    this.lyrics,
    this.mediaItem,
  );

  final Lyrics lyrics;
  final MediaItemModel mediaItem;

  @override
  List<Object> get props => [lyrics, lyrics.id, lyrics.title, mediaItem];

  LyricsState copyWith({
    Lyrics? lyrics,
    MediaItemModel? mediaItem,
  }) {
    return LyricsState(
      lyrics ?? this.lyrics,
      mediaItem ?? this.mediaItem,
    );
  }
}

final class LyricsInitial extends LyricsState {
  LyricsInitial()
      : super(
            Lyrics(
                artist: "",
                title: "",
                id: "id",
                lyricsPlain: "",
                provider: LyricsProvider.none),
            mediaItemModelNull);
}

final class LyricsLoading extends LyricsState {
  LyricsLoading(MediaItemModel mediaItem)
      : super(
            Lyrics(
                artist: "",
                title: "loading",
                id: "id",
                lyricsPlain: "",
                provider: LyricsProvider.none),
            mediaItem);
}

final class LyricsError extends LyricsState {
  LyricsError(MediaItemModel mediaItem)
      : super(
            Lyrics(
                artist: "",
                title: "Error",
                id: "id",
                lyricsPlain: "",
                provider: LyricsProvider.none),
            mediaItem);
}

final class LyricsLoaded extends LyricsState {
  const LyricsLoaded(Lyrics lyrics, MediaItemModel mediaItem)
      : super(lyrics, mediaItem);
}
