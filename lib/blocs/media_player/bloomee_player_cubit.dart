import 'package:Bloomee/services/bloomee_player.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
part 'bloomee_player_state.dart';

class BloomeePlayerCubit extends Cubit<BloomeePlayerState> {
  final BloomeeMusicPlayer bloomeePlayer;
  late ValueStream<ProgressBarStreams> progressStreams;

  BloomeePlayerCubit(this.bloomeePlayer)
      : super(BloomeePlayerState(isReady: true)) {
    bloomeePlayer.syncPublicState();
    _setupProgressStreams();
  }

  void switchShowLyrics({bool? value}) {
    emit(BloomeePlayerState(
        isReady: true, showLyrics: value ?? !state.showLyrics));
  }

  void _setupProgressStreams() {
    progressStreams = Rx.combineLatest4(
      Rx.defer(() => bloomeePlayer.engine.positionStream, reusable: true),
      Rx.defer(() => bloomeePlayer.engine.durationStream, reusable: true),
      Rx.defer(() => bloomeePlayer.engine.bufferedStream, reusable: true),
      Rx.defer(() => bloomeePlayer.engine.playingStream, reusable: true),
      (Duration position, Duration duration, Duration buffered, bool playing) =>
          ProgressBarStreams(
        position: position,
        duration: duration,
        buffered: buffered,
        isPlaying: playing,
      ),
    ).shareValueSeeded(
      ProgressBarStreams(
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> close() {
    // Intentionally does NOT stop the player.
    // The AudioService foreground service manages its own lifecycle via
    // onTaskRemoved() / onNotificationDeleted().
    return super.close();
  }
}
