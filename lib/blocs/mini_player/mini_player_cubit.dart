// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:rxdart/rxdart.dart';

// ─── State ───────────────────────────────────────────────────────────────────

/// Visibility & playback state for the mini-player.
///
/// Intentionally simple — only 2 concrete states instead of 7.
/// The widget reads [isVisible], [isPlaying], and [isLoading] to decide layout.
class MiniPlayerState extends Equatable {
  /// The current track metadata. null → nothing loaded yet.
  final MediaItemModel? track;

  /// Whether audio is actively playing.
  final bool isPlaying;

  /// Whether the engine is loading or buffering (show spinner).
  final bool isLoading;

  /// Whether the track has finished (show replay icon).
  final bool isCompleted;

  /// Whether the engine is in an error state.
  final bool hasError;

  const MiniPlayerState({
    this.track,
    this.isPlaying = false,
    this.isLoading = false,
    this.isCompleted = false,
    this.hasError = false,
  });

  /// Mini player is visible whenever there's a track to show.
  bool get isVisible => track != null && track!.id != 'Null';

  const MiniPlayerState.hidden()
      : track = null,
        isPlaying = false,
        isLoading = false,
        isCompleted = false,
        hasError = false;

  MiniPlayerState copyWith({
    MediaItemModel? track,
    bool? isPlaying,
    bool? isLoading,
    bool? isCompleted,
    bool? hasError,
  }) {
    return MiniPlayerState(
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props =>
      [track, isPlaying, isLoading, isCompleted, hasError];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

/// Drives the mini-player widget.
///
/// Design principles:
/// - **Show instantly**: As soon as [mediaItem] emits a non-null track, the
///   mini-player appears — even if the engine is still loading. This gives
///   the user immediate feedback that their tap registered.
/// - **Survive resizes**: No animations or conditions based on screen size.
///   Visibility is purely data-driven ([isVisible]).
/// - **Minimal state machine**: One [MiniPlayerState] with boolean flags
///   instead of a sealed class hierarchy with 5+ subtypes.
class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  final BloomeePlayerCubit _playerCubit;
  StreamSubscription? _sub;

  MiniPlayerCubit({required BloomeePlayerCubit playerCubit})
      : _playerCubit = playerCubit,
        super(const MiniPlayerState.hidden()) {
    _listen();
  }

  void _listen() {
    // Combine the 3 streams we care about. Emit on any change.
    _sub = Rx.combineLatest3<MediaItem?, EngineState, bool,
        (MediaItem?, EngineState, bool)>(
      _playerCubit.bloomeePlayer.mediaItem,
      _playerCubit.bloomeePlayer.engine.stateStream,
      _playerCubit.bloomeePlayer.engine.playingStream,
      (media, engineState, playing) => (media, engineState, playing),
    ).listen((record) {
      final (media, engineState, playing) = record;

      // No media → hide mini player.
      if (media == null || media.id == 'Null') {
        if (state.isVisible) emit(const MiniPlayerState.hidden());
        return;
      }

      final track = mediaItem2MediaItemModel(media);

      emit(MiniPlayerState(
        track: track,
        isPlaying: playing,
        isLoading: engineState == EngineState.loading ||
            engineState == EngineState.buffering,
        isCompleted: engineState == EngineState.completed,
        hasError: engineState == EngineState.error,
      ));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
