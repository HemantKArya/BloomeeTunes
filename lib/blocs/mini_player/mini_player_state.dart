// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'mini_player_cubit.dart';

class MiniPlayerState {
  final MediaItemModel mediaItem;
  final bool isPlaying;
  final bool isBuffering;
  final bool isProcessing;
  final bool isCompleted;
  const MiniPlayerState({
    required this.mediaItem,
    required this.isPlaying,
    required this.isBuffering,
    required this.isProcessing,
    this.isCompleted = false,
  });

  MiniPlayerState copyWith({
    MediaItemModel? mediaItem,
    bool? isPlaying,
    bool? isBuffering,
    bool? isProcessing,
    bool? isCompleted,
  }) {
    return MiniPlayerState(
      mediaItem: mediaItem ?? this.mediaItem,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(covariant MiniPlayerState other) {
    if (identical(this, other)) return true;

    return other.mediaItem == mediaItem &&
        other.isPlaying == isPlaying &&
        other.isBuffering == isBuffering &&
        other.isProcessing == isProcessing &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return mediaItem.hashCode ^
        isPlaying.hashCode ^
        isBuffering.hashCode ^
        isProcessing.hashCode ^
        isCompleted.hashCode;
  }
}

class MiniPlayerInitial extends MiniPlayerState {
  MiniPlayerInitial()
      : super(
          mediaItem: mediaItemModelNull,
          isPlaying: false,
          isBuffering: false,
          isProcessing: false,
        );
}

class MiniPlayerWorking extends MiniPlayerState {
  const MiniPlayerWorking({
    required MediaItemModel mediaItem,
    required bool isPlaying,
    required bool isBuffering,
    required bool isProcessing,
  }) : super(
          mediaItem: mediaItem,
          isPlaying: isPlaying,
          isBuffering: isBuffering,
          isProcessing: isProcessing,
        );
}

class MiniPlayerError extends MiniPlayerState {
  MiniPlayerError()
      : super(
          mediaItem: mediaItemModelNull,
          isPlaying: false,
          isBuffering: false,
          isProcessing: false,
        );
}

class MiniPlayerCompleted extends MiniPlayerState {
  const MiniPlayerCompleted({required MediaItemModel mediaItemModel})
      : super(
          mediaItem: mediaItemModel,
          isPlaying: false,
          isBuffering: false,
          isProcessing: false,
        );
}
