import 'package:Bloomee/services/audio_service_initializer.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/services/bloomee_player.dart';
part 'bloomee_player_state.dart';

enum PlayerInitState { initializing, initialized, intial }

class BloomeePlayerCubit extends Cubit<BloomeePlayerState> {
  late BloomeeMusicPlayer bloomeePlayer;
  PlayerInitState playerInitState = PlayerInitState.intial;
  late Stream<ProgressBarStreams> progressStreams;

  BloomeePlayerCubit() : super(BloomeePlayerInitial()) {
    setupPlayer().then((value) => emit(BloomeePlayerState(isReady: true)));
  }

  void switchShowLyrics({bool? value}) {
    emit(BloomeePlayerState(
        isReady: true, showLyrics: value ?? !state.showLyrics));
  }

  Future<void> setupPlayer() async {
    playerInitState = PlayerInitState.initializing;
    bloomeePlayer = await PlayerInitializer().getBloomeeMusicPlayer();
    playerInitState = PlayerInitState.initialized;
    _setupProgressStreams();
  }

  void _setupProgressStreams() {
    progressStreams = Rx.defer(
      () => Rx.combineLatest4(
          bloomeePlayer.engine.positionStream,
          bloomeePlayer.engine.durationStream,
          bloomeePlayer.engine.bufferedStream,
          bloomeePlayer.engine.playingStream,
          (Duration position, Duration duration, Duration buffered,
                  bool playing) =>
              ProgressBarStreams(
                  position: position,
                  duration: duration,
                  buffered: buffered,
                  isPlaying: playing)),
      reusable: true,
    );
  }

  @override
  Future<void> close() {
    if (playerInitState == PlayerInitState.initialized) {
      bloomeePlayer.stop();
    }
    return super.close();
  }
}
