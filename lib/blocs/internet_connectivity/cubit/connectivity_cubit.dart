import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(ConnectivityState.disconnected) {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      log('Connectivity changed: $event', name: 'ConnectivityCubit');
      if (event.contains(ConnectivityResult.wifi) ||
          event.contains(ConnectivityResult.mobile) ||
          event.contains(ConnectivityResult.ethernet) ||
          event.contains(ConnectivityResult.bluetooth) ||
          event.contains(ConnectivityResult.vpn)) {
        emit(ConnectivityState.connected);
        log('Network connectivity detected', name: 'ConnectivityCubit');
      } else {
        emit(ConnectivityState.disconnected);
        log('Disconnected from network: $event', name: 'ConnectivityCubit');
      }
    });

    // Initial connectivity check
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      log('Initial connectivity check: $result', name: 'ConnectivityCubit');
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.bluetooth) ||
          result.contains(ConnectivityResult.vpn)) {
        emit(ConnectivityState.connected);
        log('Initial network connectivity detected', name: 'ConnectivityCubit');
      }
    } catch (e) {
      log('Initial connectivity check failed: $e', name: 'ConnectivityCubit');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
