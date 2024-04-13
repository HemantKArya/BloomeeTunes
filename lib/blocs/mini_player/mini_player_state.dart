part of 'mini_player_bloc.dart';

sealed class MiniPlayerState extends Equatable {
  final MediaItemModel song;
  final bool isPlaying;
  final bool isBuffering;
  const MiniPlayerState({
    required this.song,
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  List<Object> get props => [song, isPlaying, isBuffering];
}

class MiniPlayerInitial extends MiniPlayerState {
  MiniPlayerInitial()
      : super(song: mediaItemModelNull, isPlaying: false, isBuffering: false);
}

class MiniPlayerCompleted extends MiniPlayerState {
  const MiniPlayerCompleted(MediaItemModel song)
      : super(song: song, isPlaying: false, isBuffering: false);
}

class MiniPlayerWorking extends MiniPlayerState {
  const MiniPlayerWorking(MediaItemModel song, bool isPlaying, bool isBuffering)
      : super(song: song, isPlaying: isPlaying, isBuffering: isBuffering);
}

class MiniPlayerError extends MiniPlayerState {
  const MiniPlayerError(MediaItemModel song)
      : super(song: song, isPlaying: false, isBuffering: false);
}

class MiniPlayerProcessing extends MiniPlayerState {
  const MiniPlayerProcessing(
    MediaItemModel song,
  ) : super(song: song, isPlaying: false, isBuffering: false);
}
