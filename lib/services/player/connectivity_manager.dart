import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class ConnectivityManager {
  final BehaviorSubject<bool> isConnected = BehaviorSubject<bool>.seeded(true);
  Timer? _connectivityTimer;

  // Callbacks
  Function()? onNetworkReconnected;

  ConnectivityManager() {
    _startConnectivityMonitoring();
  }

  void _startConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNetworkConnectivity();
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final wasConnected = isConnected.value;
      final nowConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      isConnected.add(nowConnected);

      if (!wasConnected && nowConnected) {
        log('Network reconnected', name: 'ConnectivityManager');
        onNetworkReconnected?.call();
      }
    } catch (e) {
      isConnected.add(false);
      log('Network connectivity check failed: $e', name: 'ConnectivityManager');
    }
  }

  Future<bool> checkConnectivity() async {
    await _checkNetworkConnectivity();
    return isConnected.value;
  }

  void dispose() {
    _connectivityTimer?.cancel();
    isConnected.close();
  }
}
