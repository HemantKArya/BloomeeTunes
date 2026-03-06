import 'package:Bloomee/core/models/exported.dart';

enum AudioStreamQualityPreference {
  low,
  medium,
  high,
}

extension AudioStreamQualityPreferenceX on AudioStreamQualityPreference {
  String get label {
    switch (this) {
      case AudioStreamQualityPreference.low:
        return 'Low';
      case AudioStreamQualityPreference.medium:
        return 'Medium';
      case AudioStreamQualityPreference.high:
        return 'High';
    }
  }

  static AudioStreamQualityPreference fromStored(String? value) {
    switch (normalizeStoredStreamQualityLabel(value)) {
      case 'Low':
        return AudioStreamQualityPreference.low;
      case 'High':
        return AudioStreamQualityPreference.high;
      default:
        return AudioStreamQualityPreference.medium;
    }
  }
}

String normalizeStoredStreamQualityLabel(
  String? value, {
  String fallback = 'Medium',
}) {
  final normalized = value?.trim().toLowerCase();
  switch (normalized) {
    case 'low':
    case '96 kbps':
    case '96kbps':
    case '64 kbps':
    case '64kbps':
      return AudioStreamQualityPreference.low.label;
    case 'medium':
    case '160 kbps':
    case '160kbps':
    case '128 kbps':
    case '128kbps':
      return AudioStreamQualityPreference.medium.label;
    case 'high':
    case '320 kbps':
    case '320kbps':
    case '256 kbps':
    case '256kbps':
      return AudioStreamQualityPreference.high.label;
    default:
      return fallback;
  }
}

Map<String, String>? streamHeadersToMap(List<(String, String)>? headers) {
  if (headers == null || headers.isEmpty) {
    return null;
  }

  final mapped = <String, String>{};
  for (final (key, value) in headers) {
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      continue;
    }
    mapped[normalizedKey] = value;
  }

  return mapped.isEmpty ? null : mapped;
}

class StreamQualitySelector {
  static const Map<AudioStreamQualityPreference, List<Quality>>
      _streamingFallbackOrder = {
    AudioStreamQualityPreference.low: [
      Quality.low,
      Quality.medium,
      Quality.high,
      Quality.lossless,
    ],
    AudioStreamQualityPreference.medium: [
      Quality.medium,
      Quality.high,
      Quality.low,
      Quality.lossless,
    ],
    AudioStreamQualityPreference.high: [
      Quality.lossless,
      Quality.high,
      Quality.medium,
      Quality.low,
    ],
  };

  static const Map<AudioStreamQualityPreference, List<Quality>>
      _downloadFallbackOrder = {
    AudioStreamQualityPreference.low: [
      Quality.low,
      Quality.medium,
      Quality.high,
      Quality.lossless,
    ],
    AudioStreamQualityPreference.medium: [
      Quality.medium,
      Quality.high,
      Quality.low,
      Quality.lossless,
    ],
    AudioStreamQualityPreference.high: [
      Quality.lossless,
      Quality.high,
      Quality.medium,
      Quality.low,
    ],
  };

  static StreamSource? selectPlaybackStream(
    List<StreamSource> streams, {
    required AudioStreamQualityPreference preference,
  }) {
    return _select(
      streams,
      fallbackOrder: _streamingFallbackOrder[preference]!,
    );
  }

  static StreamSource? selectDownloadStream(
    List<StreamSource> streams, {
    required AudioStreamQualityPreference preference,
  }) {
    return _select(
      streams,
      fallbackOrder: _downloadFallbackOrder[preference]!,
    );
  }

  static StreamSource? _select(
    List<StreamSource> streams, {
    required List<Quality> fallbackOrder,
  }) {
    final usable = streams.where(_isUsableStream).toList(growable: false);
    if (usable.isEmpty) {
      return null;
    }

    for (final quality in fallbackOrder) {
      for (final stream in usable) {
        if (stream.quality == quality) {
          return stream;
        }
      }
    }

    return usable.first;
  }

  static bool _isUsableStream(StreamSource stream) {
    final url = stream.url.trim();
    if (url.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme.isEmpty ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https' &&
            uri.scheme != 'file')) {
      return false;
    }

    final expiresAt = stream.expiresAt;
    if (expiresAt == null) {
      return true;
    }

    final now = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return expiresAt > now;
  }
}
