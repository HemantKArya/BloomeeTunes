// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'mini_player_bloc.dart';

sealed class MiniPlayerEvent extends Equatable {
  final MediaItemModel song;

  const MiniPlayerEvent({
    required this.song,
  });

  @override
  List<Object> get props => [
        song,
      ];
}

class MiniPlayerPlayedEvent extends MiniPlayerEvent {
  const MiniPlayerPlayedEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerPausedEvent extends MiniPlayerEvent {
  const MiniPlayerPausedEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerBufferingEvent extends MiniPlayerEvent {
  const MiniPlayerBufferingEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerErrorEvent extends MiniPlayerEvent {
  const MiniPlayerErrorEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerProcessingEvent extends MiniPlayerEvent {
  const MiniPlayerProcessingEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerCompletedEvent extends MiniPlayerEvent {
  const MiniPlayerCompletedEvent(MediaItemModel song) : super(song: song);
}

class MiniPlayerInitialEvent extends MiniPlayerEvent {
  MiniPlayerInitialEvent() : super(song: mediaItemModelNull);
}
