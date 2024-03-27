import 'package:Bloomee/services/audio_service_initializer.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/services/bloomeePlayer.dart';
part 'bloomee_player_state.dart';

class BloomeePlayerCubit extends Cubit<BloomeePlayerState> {
  late BloomeeMusicPlayer bloomeePlayer;
  // late AudioSession audioSession;
  late Stream<ProgressBarStreams> progressStreams;
  BloomeePlayerCubit() : super(BloomeePlayerInitial()) {
    setupPlayer().then((value) => emit(BloomeePlayerState(isReady: true)));
  }

  Future<void> setupPlayer() async {
    bloomeePlayer = await PlayerInitializer().getBloomeeMusicPlayer();

    progressStreams = Rx.defer(
      () => Rx.combineLatest3(
          bloomeePlayer.audioPlayer.positionStream,
          bloomeePlayer.audioPlayer.playbackEventStream,
          bloomeePlayer.audioPlayer.playerStateStream,
          (Duration a, PlaybackEvent b, PlayerState c) => ProgressBarStreams(
              currentPos: a, currentPlaybackState: b, currentPlayerState: c)),
      reusable: true,
    );

    bloomeePlayer.audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        //Temp solution(Debouncing) to prevent from subsequent gapless 'completed' event
        EasyThrottle.throttle('skipNext', const Duration(milliseconds: 7000),
            () async => await bloomeePlayer.skipToNext());
        // print("skipping to next->>");
      }
    });
  }

  @override
  Future<void> close() {
    EasyDebounce.cancelAll();
    bloomeePlayer.stop();
    bloomeePlayer.audioPlayer.dispose();
    return super.close();
  }
}
