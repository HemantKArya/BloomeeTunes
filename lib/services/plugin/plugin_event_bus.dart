import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/src/rust/api/plugin/events.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin.dart';
import 'package:Bloomee/src/rust/api/bridge.dart' as bridge;

/// Connects to the Rust plugin manager's event stream and re-broadcasts
/// [PluginManagerEvent]s to Dart listeners.
///
/// This is a singleton — call [connect] once during app startup after
/// creating the [PluginManager]. All BLoCs and services that need to react
/// to plugin lifecycle events subscribe to [events].
///
/// Lifecycle:
///   1. [PluginEventBus.instance] is created (lazy singleton).
///   2. Call [connect(manager)] once — this opens the Rust → Dart stream.
///   3. Listeners subscribe via [events].
///   4. Call [dispose()] on app shutdown.
class PluginEventBus {
  PluginEventBus._();

  static final PluginEventBus instance = PluginEventBus._();

  final StreamController<PluginManagerEvent> _controller =
      StreamController<PluginManagerEvent>.broadcast();

  StreamSubscription<PluginManagerEvent>? _rustSubscription;

  bool _connected = false;

  /// Whether the bus is connected to the Rust event stream.
  bool get isConnected => _connected;

  /// Broadcast stream of plugin manager events.
  ///
  /// All events from Rust (load/unload/install/storage/error) flow through here.
  Stream<PluginManagerEvent> get events => _controller.stream;

  /// Connect to the Rust plugin manager's event stream.
  ///
  /// Must be called exactly once after [PluginManager] is created.
  /// Throws [StateError] if called more than once.
  void connect(PluginManager manager) {
    if (_connected) {
      log('PluginEventBus already connected — ignoring duplicate connect call',
          name: 'PluginEventBus');
      return;
    }

    final rustStream = bridge.initPluginEventStream(manager: manager);

    _rustSubscription = rustStream.listen(
      (event) {
        log('PluginEvent: $event', name: 'PluginEventBus');
        _controller.add(event);
      },
      onError: (Object error, StackTrace stack) {
        log('PluginEventBus stream error: $error',
            name: 'PluginEventBus', error: error, stackTrace: stack);
      },
      onDone: () {
        log('PluginEventBus: Rust event stream closed', name: 'PluginEventBus');
        _connected = false;
      },
    );

    _connected = true;
    log('PluginEventBus connected to Rust event stream',
        name: 'PluginEventBus');
  }

  /// Clean up. Cancel the Rust stream subscription and close the broadcast controller.
  void dispose() {
    _rustSubscription?.cancel();
    _rustSubscription = null;
    _controller.close();
    _connected = false;
    log('PluginEventBus disposed', name: 'PluginEventBus');
  }
}
