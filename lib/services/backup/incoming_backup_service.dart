import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Durable Android inbox. Acknowledgement happens only after the UI handles a file.
class IncomingBackupService {
  static const _channel = MethodChannel('ls.bloomee/imports');
  final Future<void> Function(String) onFile;
  final void Function(String) onError;
  final Future<void> Function(String)? onText;
  final bool enabled;
  bool _draining = false;
  bool _again = false;
  bool _disposed = false;

  IncomingBackupService(
      {required this.onFile, required this.onError, this.onText, bool? enabled})
      : enabled = enabled ?? Platform.isAndroid;

  Future<void> start() async {
    if (!enabled) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'available') await _drain();
    });
    await _drain();
  }

  Future<void> _drain() async {
    if (_draining) {
      _again = true;
      return;
    }
    _draining = true;
    try {
      do {
        _again = false;
        final errors = await _channel.invokeListMethod<String>('errors') ?? [];
        for (final error in errors) {
          onError(error);
        }
        final texts = await _channel.invokeListMethod<String>('texts') ?? [];
        for (final text in texts) {
          if (!_disposed && onText != null) await onText!(text);
        }
        final paths = await _channel.invokeListMethod<String>('pending') ?? [];
        for (final path in paths) {
          if (_disposed) return;
          await onFile(path);
          await _channel.invokeMethod<void>('acknowledge', {'path': path});
        }
      } while (_again && !_disposed);
    } catch (error) {
      onError('$error');
    } finally {
      _draining = false;
    }
  }

  void dispose() {
    _disposed = true;
    if (enabled) _channel.setMethodCallHandler(null);
  }
}
