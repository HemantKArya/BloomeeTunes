import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  BloomeePlayerCubit bloomeePlayerCubit;
  StreamSubscription? _linkSub;
  StreamSubscription? _playerSub;
  MiniPlayerCubit({required this.bloomeePlayerCubit})
      : super(MiniPlayerInitial()) {
    subscribeToPlayer();
    subscribeLinkProc();
  }

  void subscribeLinkProc() async {
    _linkSub =
        bloomeePlayerCubit.bloomeePlayer.isLinkProcessing.listen((event) {
      if (event) {
        log("MiniPlayerCubit: isLinkProcessing");
        emit(state.copyWith(
          isProcessing: true,
        ));
      }
    });
  }

  void subscribeToPlayer() async {
    _playerSub = bloomeePlayerCubit.bloomeePlayer.playbackState.listen((value) {
      switch (value.processingState) {
        case AudioProcessingState.idle:
          emit(MiniPlayerInitial());
          break;
        case AudioProcessingState.loading:
          if (bloomeePlayerCubit.bloomeePlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  bloomeePlayerCubit.bloomeePlayer.mediaItem.value!),
              isPlaying: false,
              isBuffering: true,
              isProcessing: true,
              isCompleted: false,
            ));
          }
          break;
        case AudioProcessingState.buffering:
          if (bloomeePlayerCubit.bloomeePlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  bloomeePlayerCubit.bloomeePlayer.mediaItem.value!),
              isPlaying: false,
              isBuffering: true,
              isProcessing: false,
              isCompleted: false,
            ));
          }
          break;
        case AudioProcessingState.ready:
          if (bloomeePlayerCubit.bloomeePlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  bloomeePlayerCubit.bloomeePlayer.mediaItem.value!),
              isPlaying: value.playing,
              isBuffering: false,
              isProcessing: false,
              isCompleted: false,
            ));
          }
          break;

        case AudioProcessingState.completed:
          log("MiniPlayerCubit: completed");
          emit(state.copyWith(isCompleted: true));

          break;
        case AudioProcessingState.error:
          emit(MiniPlayerError());
          break;
      }

      if (value.playing) {
        emit(state.copyWith(
          mediaItem: mediaItem2MediaItemModel(
              bloomeePlayerCubit.bloomeePlayer.mediaItem.value!),
          isPlaying: true,
          isBuffering: false,
          isProcessing: false,
          isCompleted: false,
        ));
      } else {
        emit(state.copyWith(
          mediaItem: mediaItem2MediaItemModel(
              bloomeePlayerCubit.bloomeePlayer.mediaItem.value!),
          isPlaying: false,
          isBuffering: false,
          isProcessing: false,
          isCompleted: false,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _playerSub?.cancel();
    _linkSub?.cancel();
    return super.close();
  }
}
