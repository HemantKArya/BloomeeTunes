import 'dart:async';

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
    // Must stay connected for the cubit's lifetime. Do NOT use
    // shareValueSeeded()/refCount(): the mini player and the full player hand
    // the stream over in the same frame (see PlayerViewActivity), so the
    // listener count briefly hits zero, and refCount() then cancels the source
    // and closes the subject for good. Every later listener only gets the
    // last cached value: the progress bar freezes while audio keeps playing.
    final connectable = Rx.combineLatest4(
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
    ).publishValueSeeded(
      ProgressBarStreams(
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        isPlaying: false,
      ),
    );
    _progressConnection = connectable.connect();
    progressStreams = connectable;
  }

  StreamSubscription<ProgressBarStreams>? _progressConnection;

  @override
  Future<void> close() async {
    // Intentionally does NOT stop the player.
    // The AudioService foreground service manages its own lifecycle via
    // onTaskRemoved() / onNotificationDeleted().
    await _progressConnection?.cancel();
    return super.close();
  }
}
