import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/main.dart';
import 'package:Bloomee/utils/ticker.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 0;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker, required BloomeePlayerCubit bloomeePlayer})
      : _ticker = ticker,
        super(const TimerInitial(_duration)) {
    on<TimerStarted>(_onTimerStarted);
    on<_TimerTicked>(_onTimerTicked);
    on<TimerPaused>(onTimerPaused);
    on<TimerResumed>(onTimerResumed);
    on<TimerReset>(onTimerReset);
    on<TimerStopped>(onTimerStopped);
  }

  void _onTimerStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: event.duration).listen((duration) {
      add(_TimerTicked(duration: duration));
    });
  }

  void onTimerPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void onTimerResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void onTimerReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  void onTimerStopped(TimerStopped event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerRunStopped());
  }

  void _onTimerTicked(_TimerTicked event, Emitter<TimerState> emit) {
    // emit(event.duration > 0
    //     ? TimerRunInProgress(event.duration)
    //     : const TimerRunComplete());
    if (event.duration > 0) {
      emit(TimerRunInProgress(event.duration));
    } else {
      emit(const TimerRunComplete());
      try {
        bloomeePlayerCubit.bloomeePlayer.pause();
      } catch (e) {
        log(e.toString(), name: "TimerBloc");
      }
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
