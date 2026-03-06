import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:rxdart/rxdart.dart';

enum PlayerErrorType {
  networkError,
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
    this.maxRetriesPerTrack = 1, // Max times to retry the SAME song
    this.maxConsecutiveTrackFailures =
        2, // Stop completely if 2 consecutive songs fail
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

  // --- Circuit Breaker State ---
  int _currentTrackRetries = 0;
  int _consecutiveTrackFailures = 0;
  String? _currentFailingTrackId;

  // --- Callbacks ---
  Function()? onSkipToNext;
  Function()? onRetryCurrentTrack;
  Function()? onStopPlayback; // Callback to gracefully halt player
  Function(String?)? onClearCachedSource;

  PlayerErrorType categorizeError(dynamic error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return PlayerErrorType.networkError;
    } else if (error is FormatException ||
        error is ArgumentError ||
        error.toString().toLowerCase().contains('format') ||
        error.toString().toLowerCase().contains('source')) {
      return PlayerErrorType.sourceError;
    } else if (error.toString().toLowerCase().contains('permission')) {
      return PlayerErrorType.permissionError;
    } else if (error.toString().toLowerCase().contains('buffer')) {
      return PlayerErrorType.bufferingError;
    }
    return PlayerErrorType.unknownError;
  }

  void handleError(PlayerErrorType type, String message, Track? track,
      [dynamic originalError]) {
    if (track == null) return;

    final error = PlayerError(
      type: type,
      message: message,
      failedTrack: track,
      originalError: originalError,
    );

    lastError.add(error);
    dev.log('Player error: $error', name: 'PlayerErrorHandler');

    // Detect if we moved to a new track that is now failing
    if (_currentFailingTrackId != track.id) {
      _currentTrackRetries = 0;
      _currentFailingTrackId = track.id;
    }

    // Permission errors are fatal immediately, do not retry
    if (type == PlayerErrorType.permissionError) {
      _handleTrackTotalFailure(track);
      return;
    }

    if (type == PlayerErrorType.sourceError) {
      onClearCachedSource?.call(track.id);
    }

    // Standard Retry Loop
    if (_currentTrackRetries < _retryConfig.maxRetriesPerTrack) {
      _currentTrackRetries++;
      final delay = _calculateRetryDelay(_currentTrackRetries - 1);

      // Show user feedback with retry attempt numbers
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
      // Track completely failed
      _handleTrackTotalFailure(track);
    }
  }

  void _handleTrackTotalFailure(Track track) {
    _consecutiveTrackFailures++;

    if (_consecutiveTrackFailures >= _retryConfig.maxConsecutiveTrackFailures) {
      dev.log(
          'Circuit breaker tripped. $_consecutiveTrackFailures consecutive tracks failed.',
          name: 'PlayerErrorHandler');
      SnackbarService.showMessage(
          'Playback stopped due to continuous errors. Please check your connection.',
          duration: const Duration(seconds: 5));
      onStopPlayback
          ?.call(); // Completely halt playback to prevent infinite loop
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
      case PlayerErrorType.networkError:
        return 'Network connection issue.';
      case PlayerErrorType.sourceError:
        return 'Song source unavailable.';
      case PlayerErrorType.playbackError:
        return 'Playback issue detected.';
      case PlayerErrorType.bufferingError:
        return 'Buffering problem.';
      case PlayerErrorType.permissionError:
        return 'Permission denied.';
      default:
        return 'Unexpected error occurred.';
    }
  }

  Duration _calculateRetryDelay(int attempts) {
    final delay = _retryConfig.initialDelay *
        (pow(_retryConfig.backoffMultiplier, attempts));
    return delay > _retryConfig.maxDelay ? _retryConfig.maxDelay : delay;
  }

  /// Called ONLY when a track genuinely starts outputting audio frames.
  void markTrackSuccess(String mediaId) {
    if (_currentFailingTrackId == null && _consecutiveTrackFailures == 0)
      return;

    if (_currentFailingTrackId == mediaId) {
      _currentFailingTrackId = null;
      _currentTrackRetries = 0;
    }
    _consecutiveTrackFailures = 0;
  }

  /// Call this when the user explicitly interacts (e.g. manually pressing skip/play)
  void resetCircuitBreaker() {
    _currentFailingTrackId = null;
    _currentTrackRetries = 0;
    _consecutiveTrackFailures = 0;
    lastError.add(null);
  }

  void clearError() => lastError.add(null);

  void dispose() {
    _reconnectionTimer?.cancel();
    lastError.close();
  }
}
