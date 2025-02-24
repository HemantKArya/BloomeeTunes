// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

part 'mini_player_event.dart';
part 'mini_player_state.dart';

class MiniPlayerBloc extends Bloc<MiniPlayerEvent, MiniPlayerState> {
  StreamSubscription? _playerStateSubscription;
  BloomeePlayerCubit playerCubit;
  Stream? combinedStream;
  MiniPlayerBloc({
    required this.playerCubit,
  }) : super(MiniPlayerInitial()) {
    combinedStream = Rx.combineLatest2(
      playerCubit.bloomeePlayer.audioPlayer.playerStateStream,
      playerCubit.bloomeePlayer.mediaItem,
      (PlayerState playerState, MediaItem? mediaItem) =>
          [playerState, mediaItem],
    );
    listenToPlayer();
    on<MiniPlayerPlayedEvent>(played);
    on<MiniPlayerPausedEvent>(paused);
    on<MiniPlayerBufferingEvent>(buffering);
    on<MiniPlayerErrorEvent>(error);
    on<MiniPlayerProcessingEvent>(processing);
    on<MiniPlayerCompletedEvent>(completed);
    on<MiniPlayerInitialEvent>(initial);
  }

  void played(MiniPlayerPlayedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, true, false));
  }

  void paused(MiniPlayerPausedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, false, false));
  }

  void buffering(
      MiniPlayerBufferingEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, false, true));
  }

  void error(MiniPlayerErrorEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerError(event.song));
  }

  void processing(
      MiniPlayerProcessingEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerProcessing(event.song));
  }

  void completed(
      MiniPlayerCompletedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerCompleted(event.song));
  }

  void initial(MiniPlayerInitialEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerInitial());
  }

  void listenToPlayer() {
    _playerStateSubscription =
        combinedStream?.asBroadcastStream().listen((event) {
      var state = event[0] as PlayerState;
      var mediaItem = event[1] as MediaItem?;
      if (mediaItem == null) return;

      var mediaItem2 = mediaItem2MediaItemModel(mediaItem);

      log("$state", name: "MiniPlayer");
      switch (state.processingState) {
        case ProcessingState.idle:
          add(MiniPlayerInitialEvent());
          break;
        case ProcessingState.loading:
          add(MiniPlayerProcessingEvent(mediaItem2));

          break;
        case ProcessingState.buffering:
          try {
            add(MiniPlayerBufferingEvent(mediaItem2));
          } catch (e) {}
          break;
        case ProcessingState.ready:
          try {
            if (state.playing) {
              add(MiniPlayerPlayedEvent(mediaItem2));
            } else {
              add(MiniPlayerPausedEvent(mediaItem2));
            }
          } catch (e) {}
          break;
        case ProcessingState.completed:
          try {
            add(MiniPlayerCompletedEvent(mediaItem2));
          } catch (e) {}
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    return super.close();
  }
}
