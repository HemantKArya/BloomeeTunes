import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:rxdart/rxdart.dart';

enum PlayerErrorType {
  networkDropped,
  sourceExpired,
  sourceError,
  playbackError,
  bufferingError,
  permissionError,
  unknownError,
}

class PlayerError {
  final PlayerErrorType type;
  final String message;
  final dynamic originalError;
  final DateTime timestamp;
  final Track? failedTrack;

  PlayerError({
    required this.type,
    required this.message,
    this.originalError,
    this.failedTrack,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'PlayerError(type: $type, message: $message)';
}

class RetryConfig {
  final int maxRetriesPerTrack;
  final int maxConsecutiveTrackFailures;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetriesPerTrack = 3,
    this.maxConsecutiveTrackFailures = 4,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });
}

class PlayerErrorHandler {
  final BehaviorSubject<PlayerError?> lastError =
      BehaviorSubject<PlayerError?>.seeded(null);
  final RetryConfig _retryConfig = const RetryConfig();

  Timer? _reconnectionTimer;

  // --- Deterministic State Machine Tracking ---
  int _currentAttemptSequence = 0;
  int _handledFailureSequence = -1;

  int _currentTrackRetries = 0;
  int _consecutiveTrackFailures = 0;
  String? _currentTrackId;
  bool _currentTrackHadPlay = false;

  Function()? onSkipToNext;
  Function()? onRetryCurrentTrack;
  Function()? onStopPlayback;
  Function(String?)? onClearCachedSource;

  /// Called strictly before the engine commands a play/open.
  /// Generates a new sequence ID to deterministically isolate error bursts.
  void registerAttempt(String trackId) {
    _currentAttemptSequence++;

    if (_currentTrackId != trackId) {
      _currentTrackId = trackId;
      _currentTrackRetries = 0;
      _currentTrackHadPlay = false;
    }
  }

  PlayerErrorType categorizeError(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('403') ||
        msg.contains('forbidden') ||
        msg.contains('expired') ||
        msg.contains('410')) {
      return PlayerErrorType.sourceExpired;
    } else if (msg.contains('eof') ||
        msg.contains('broken pipe') ||
        msg.contains('reset') ||
        msg.contains('timeout') ||
        msg.contains('unreachable') ||
        msg.contains('socket') ||
        msg.contains('abnormal eof') ||
        error is SocketException ||
        error is TimeoutException) {
      return PlayerErrorType.networkDropped;
    } else if (msg.contains('404') ||
        msg.contains('not found') ||
        msg.contains('format') ||
        msg.contains('unrecognized') ||
        msg.contains('decode') ||
        msg.contains('demuxer')) {
      return PlayerErrorType.sourceError;
    } else if (msg.contains('permission') || msg.contains('access denied')) {
      return PlayerErrorType.permissionError;
    } else if (msg.contains('buffer')) {
      return PlayerErrorType.bufferingError;
    }
    return PlayerErrorType.unknownError;
  }

  void handleError(PlayerErrorType type, String message, Track? track,
      [dynamic originalError]) {
    if (track == null) return;

    // STATE GATE: Guarantee we only process exactly ONE failure per attempt sequence.
    // This perfectly eliminates race conditions from libmpv spamming 10 errors for one crash.
    if (_handledFailureSequence == _currentAttemptSequence) {
      dev.log(
          'Suppressed cascading error for attempt $_currentAttemptSequence: $message',
          name: 'PlayerErrorHandler');
      return;
    }

    _handledFailureSequence = _currentAttemptSequence;

    final error = PlayerError(
      type: type,
      message: message,
      failedTrack: track,
      originalError: originalError,
    );

    lastError.add(error);
    dev.log('Player error processed: $error', name: 'PlayerErrorHandler');

    if (type == PlayerErrorType.permissionError) {
      _handleTrackTotalFailure(track);
      return;
    }

    if (type == PlayerErrorType.sourceError ||
        type == PlayerErrorType.sourceExpired) {
      onClearCachedSource?.call(track.id);
    }

    if (_currentTrackRetries < _retryConfig.maxRetriesPerTrack) {
      _currentTrackRetries++;
      final delay = _calculateRetryDelay(_currentTrackRetries - 1);

      SnackbarService.showMessage(
          '${_getUserFriendlyErrorMessage(type, message)} (Retry $_currentTrackRetries/${_retryConfig.maxRetriesPerTrack})',
          duration: const Duration(seconds: 3));

      _reconnectionTimer?.cancel();
      _reconnectionTimer = Timer(delay, () {
        dev.log(
            'Retrying playback for ${track.title} (attempt $_currentTrackRetries)',
            name: 'PlayerErrorHandler');
        onRetryCurrentTrack?.call();
      });
    } else {
      _handleTrackTotalFailure(track);
    }
  }

  void _handleTrackTotalFailure(Track track,
      {bool countTowardsCircuitBreaker = true}) {
    if (!_currentTrackHadPlay && countTowardsCircuitBreaker) {
      _consecutiveTrackFailures++;
    }
    _currentTrackHadPlay = false;

    if (countTowardsCircuitBreaker &&
        _consecutiveTrackFailures >= _retryConfig.maxConsecutiveTrackFailures) {
      dev.log('Circuit breaker tripped.', name: 'PlayerErrorHandler');
      SnackbarService.showMessage(
          'Playback stopped due to continuous errors. Please check your connection.',
          duration: const Duration(seconds: 5));
      onStopPlayback?.call();
    } else {
      dev.log('Track completely failed, skipping: ${track.title}',
          name: 'PlayerErrorHandler');
      SnackbarService.showMessage(
          'Failed to play "${track.title}". Skipping to next...',
          duration: const Duration(seconds: 3));
      onSkipToNext?.call();
    }
  }

  String _getUserFriendlyErrorMessage(PlayerErrorType type, String message) {
    switch (type) {
      case PlayerErrorType.sourceExpired:
        return 'Link expired, refreshing source...';
      case PlayerErrorType.networkDropped:
        return 'Connection dropped, reconnecting...';
      case PlayerErrorType.sourceError:
        return 'Song format unsupported or corrupted.';
      case PlayerErrorType.playbackError:
        return 'Playback issue detected.';
      case PlayerErrorType.bufferingError:
        return 'Buffering problem.';
      case PlayerErrorType.permissionError:
        return 'Permission denied.';
      default:
        return 'Unexpected network or playback error.';
    }
  }

  Duration _calculateRetryDelay(int attempts) {
    final delay = _retryConfig.initialDelay *
        (pow(_retryConfig.backoffMultiplier, attempts));
    return delay > _retryConfig.maxDelay ? _retryConfig.maxDelay : delay;
  }

  void markTrackSuccess(String mediaId) {
    if (_currentTrackId == mediaId) {
      _currentTrackHadPlay = true;
      _currentTrackRetries = 0;
      _consecutiveTrackFailures = 0;
    }
  }

  void resetCircuitBreaker() {
    _currentTrackId = null;
    _currentTrackRetries = 0;
    _consecutiveTrackFailures = 0;
    _currentTrackHadPlay = false;
    lastError.add(null);
  }

  void clearError() => lastError.add(null);

  void dispose() {
    _reconnectionTimer?.cancel();
    lastError.close();
  }
}
