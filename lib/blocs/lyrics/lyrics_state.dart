// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'lyrics_cubit.dart';

class LyricsState extends Equatable {
  const LyricsState(
    this.lyrics,
    this.track,
  );

  final Lyrics lyrics;
  final Track track;

  @override
  List<Object> get props => [lyrics, lyrics.id, lyrics.title, track];

  LyricsState copyWith({
    Lyrics? lyrics,
    Track? track,
  }) {
    return LyricsState(
      lyrics ?? this.lyrics,
      track ?? this.track,
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
            Track(
                id: 'Null',
                title: 'Null',
                artists: const [],
                thumbnail: const Artwork(url: '', layout: ImageLayout.square),
                isExplicit: false));
}

final class LyricsLoading extends LyricsState {
  LyricsLoading(Track track)
      : super(
            Lyrics(
                artist: "",
                title: "loading",
                id: "id",
                lyricsPlain: "",
                provider: LyricsProvider.none),
            track);
}

final class LyricsError extends LyricsState {
  LyricsError(Track track)
      : super(
            Lyrics(
                artist: "",
                title: "Error",
                id: "id",
                lyricsPlain: "",
                provider: LyricsProvider.none),
            track);
}

/// Emitted when no lyrics plugin is configured in the priority list.
final class LyricsNoPlugin extends LyricsError {
  LyricsNoPlugin(Track track) : super(track);
}

final class LyricsLoaded extends LyricsState {
  const LyricsLoaded(Lyrics lyrics, Track track) : super(lyrics, track);
}
