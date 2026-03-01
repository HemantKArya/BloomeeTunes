import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:Bloomee/core/models/song_model.dart';
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
  final MediaItemModel? failedTrack;

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
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });
}

class PlayerErrorHandler {
  final BehaviorSubject<PlayerError?> lastError =
      BehaviorSubject<PlayerError?>.seeded(null);
  final Map<String, int> _retryAttempts = {};
  final Map<String, DateTime> _lastRetryTime = {};
  final RetryConfig _retryConfig = const RetryConfig();
  Timer? _reconnectionTimer;
  // Track whether an automatic skip has already been performed after an error
  // This prevents the player from continuously skipping through the queue
  // after repeated failures. It will be reset when errors/retries are cleared.
  bool _autoSkipPerformed = false;
  int _totalRetryCount = 0;

  // Callbacks for handling different scenarios
  Function()? onSkipToNext;
  Function()? onRetryCurrentTrack;
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
    } else if (error.toString().toLowerCase().contains('loading interrupted') ||
        error
            .toString()
            .toLowerCase()
            .contains('failed to create file cache')) {
      return PlayerErrorType.unknownError;
    }
    return PlayerErrorType.unknownError;
  }

  void handleError(PlayerErrorType type, String message, MediaItemModel? track,
      [dynamic originalError]) {
    final error = PlayerError(
      type: type,
      message: message,
      failedTrack: track,
      originalError: originalError,
    );

    lastError.add(error);
    dev.log('Player error: $error', name: 'PlayerErrorHandler');

    // Show user-friendly error message
    String userMessage = _getUserFriendlyErrorMessage(type, message);
    SnackbarService.showMessage(userMessage,
        duration: const Duration(seconds: 4));

    // Handle specific error types
    switch (type) {
      case PlayerErrorType.networkError:
        _scheduleRetry(track);
        break;
      case PlayerErrorType.sourceError:
        onClearCachedSource?.call(track?.id);
        _scheduleRetry(track);
        break;
      case PlayerErrorType.playbackError:
        _scheduleRetry(track);
        break;
      case PlayerErrorType.bufferingError:
        _scheduleRetry(track);
        break;
      default:
        // For unknown errors (like MPV warnings), don't retry as they might be harmless
        dev.log('Non-retriable error encountered: $error',
            name: 'PlayerErrorHandler');
        break;
    }
  }

  String _getUserFriendlyErrorMessage(PlayerErrorType type, String message) {
    switch (type) {
      case PlayerErrorType.networkError:
        return 'Network connection issue. Retrying...';
      case PlayerErrorType.sourceError:
        return 'Song source unavailable. Trying alternative...';
      case PlayerErrorType.playbackError:
        return 'Playback issue detected. Retrying...';
      case PlayerErrorType.bufferingError:
        return 'Buffering problem. Retrying...';
      case PlayerErrorType.permissionError:
        return 'Permission denied. Please check app permissions.';
      default:
        return 'Unexpected error occurred. Retrying...';
    }
  }

  void _scheduleRetry(MediaItemModel? currentItem) {
    if (currentItem == null) return;

    if (_totalRetryCount >= 10) {
      dev.log(
          'Total retry limit reached (10), skipping to next for ${currentItem.title}',
          name: 'PlayerErrorHandler');
      _skipToNextOnError(currentItem);
      return;
    }

    final itemId = currentItem.id;
    final attempts = _retryAttempts[itemId] ?? 0;

    if (attempts >= _retryConfig.maxRetries) {
      dev.log('Max retry attempts reached for ${currentItem.title}',
          name: 'PlayerErrorHandler');
      _skipToNextOnError(currentItem);
      return;
    }

    final delay = _calculateRetryDelay(attempts);
    _retryAttempts[itemId] = attempts + 1;
    _lastRetryTime[itemId] = DateTime.now();
    _totalRetryCount++;

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, () async {
      dev.log(
          'Retrying playback for ${currentItem.title} (attempt ${attempts + 1})',
          name: 'PlayerErrorHandler');
      onRetryCurrentTrack?.call();
    });
  }

  Duration _calculateRetryDelay(int attempts) {
    // attempts starts at 0 for the first retry. Use pow to ensure > 0 delay.
    // attempt 0: 1s * pow(2, 0) = 1s
    // attempt 1: 1s * pow(2, 1) = 2s
    // attempt 2: 1s * pow(2, 2) = 4s
    final delay = _retryConfig.initialDelay *
        (pow(_retryConfig.backoffMultiplier, attempts));
    return delay > _retryConfig.maxDelay ? _retryConfig.maxDelay : delay;
  }

  Future<void> _skipToNextOnError(MediaItemModel? currentItem) async {
    final title = currentItem?.title ?? 'current song';

    if (_autoSkipPerformed) {
      // Auto-skip already performed; inform the user and stop further automatic skips.
      SnackbarService.showMessage(
          'Unable to auto-skip further after multiple failures. Please check your connection or skip manually.',
          duration: const Duration(seconds: 4));
      return;
    }

    // Perform a single automatic skip and mark it so we don't continuously skip.
    SnackbarService.showMessage(
        'Failed to play "$title". Skipping to next (automatic).',
        duration: const Duration(seconds: 3));
    try {
      onSkipToNext?.call();
    } catch (e) {
      dev.log('Error while calling onSkipToNext: $e',
          name: 'PlayerErrorHandler');
    }
    _autoSkipPerformed = true;
  }

  void clearError() {
    lastError.add(null);
  }

  void clearRetryAttempts(String mediaId) {
    _retryAttempts.remove(mediaId);
    _lastRetryTime.remove(mediaId);
    // If the given mediaId had been skipped previously, allow auto-skip again
    // for future errors once normal playback resumes.
    _autoSkipPerformed = false;
    _totalRetryCount = 0; // Reset total retry count on successful playback
  }

  void dispose() {
    _reconnectionTimer?.cancel();
    lastError.close();
    _retryAttempts.clear();
    _lastRetryTime.clear();
  }
}
