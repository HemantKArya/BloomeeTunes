import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityCubit() : super(ConnectivityState.disconnected) {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        emit(ConnectivityState.disconnected);
      } else {
        emit(ConnectivityState.connected);
      }
    });
  }
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
