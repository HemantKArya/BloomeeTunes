import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
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
  final MediaItem? failedMediaItem;

  PlayerError({
    required this.type,
    required this.message,
    this.originalError,
    this.failedMediaItem,
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
    } else if (error is PlayerException) {
      return PlayerErrorType.playbackError;
    } else if (error.toString().toLowerCase().contains('permission')) {
      return PlayerErrorType.permissionError;
    } else if (error.toString().toLowerCase().contains('buffer')) {
      return PlayerErrorType.bufferingError;
    }
    return PlayerErrorType.unknownError;
  }

  void handleError(PlayerErrorType type, String message, MediaItem? mediaItem,
      [dynamic originalError]) {
    final error = PlayerError(
      type: type,
      message: message,
      failedMediaItem: mediaItem,
      originalError: originalError,
    );

    lastError.add(error);
    log('Player error: $error', name: 'PlayerErrorHandler');

    // Show user-friendly error message
    String userMessage = _getUserFriendlyErrorMessage(type, message);
    SnackbarService.showMessage(userMessage,
        duration: const Duration(seconds: 4));

    // Handle specific error types
    switch (type) {
      case PlayerErrorType.networkError:
        _scheduleRetry(mediaItem);
        break;
      case PlayerErrorType.sourceError:
        onClearCachedSource?.call(mediaItem?.id);
        _scheduleRetry(mediaItem);
        break;
      case PlayerErrorType.playbackError:
        _scheduleRetry(mediaItem);
        break;
      case PlayerErrorType.bufferingError:
        _scheduleRetry(mediaItem);
        break;
      default:
        _scheduleRetry(mediaItem);
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

  void _scheduleRetry(MediaItem? currentItem) {
    if (currentItem == null) return;

    final itemId = currentItem.id;
    final attempts = _retryAttempts[itemId] ?? 0;

    if (attempts >= _retryConfig.maxRetries) {
      log('Max retry attempts reached for ${currentItem.title}',
          name: 'PlayerErrorHandler');
      _skipToNextOnError();
      return;
    }

    final delay = _calculateRetryDelay(attempts);
    _retryAttempts[itemId] = attempts + 1;
    _lastRetryTime[itemId] = DateTime.now();

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, () async {
      log('Retrying playback for ${currentItem.title} (attempt ${attempts + 1})',
          name: 'PlayerErrorHandler');
      onRetryCurrentTrack?.call();
    });
  }

  Duration _calculateRetryDelay(int attempts) {
    final delay =
        _retryConfig.initialDelay * (attempts * _retryConfig.backoffMultiplier);
    return delay > _retryConfig.maxDelay ? _retryConfig.maxDelay : delay;
  }

  void _skipToNextOnError() async {
    SnackbarService.showMessage('Failed to play current song, skipping to next',
        duration: const Duration(seconds: 3));
    onSkipToNext?.call();
  }

  void clearError() {
    lastError.add(null);
  }

  void clearRetryAttempts(String mediaId) {
    _retryAttempts.remove(mediaId);
    _lastRetryTime.remove(mediaId);
  }

  void dispose() {
    _reconnectionTimer?.cancel();
    lastError.close();
    _retryAttempts.clear();
    _lastRetryTime.clear();
  }
}
