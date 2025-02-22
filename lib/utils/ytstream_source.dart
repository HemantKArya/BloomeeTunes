import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeAudioSource extends StreamAudioSource {
  final String videoId;
  final String quality; // 'high' or 'low'
  final YoutubeExplode ytExplode;

  YouTubeAudioSource({
    required this.videoId,
    required this.quality,
    super.tag,
  }) : ytExplode = YoutubeExplode();

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    try {
      // Get the manifest for the video.
      final manifest = await ytExplode.videos.streams.getManifest(
        videoId,
        requireWatchPage: false,
        ytClients: [YoutubeApiClient.android],
      );
      final supportedStreams = manifest.audioOnly.sortByBitrate();

      // Choose high quality (highest bitrate) or low (lowest bitrate)
      final audioStream = quality == 'high'
          ? (supportedStreams.isNotEmpty ? supportedStreams.last : null)
          : (supportedStreams.isNotEmpty ? supportedStreams.first : null);

      if (audioStream == null) {
        throw Exception('No audio stream available for this video.');
      }

      start ??= 0;
      int computedEnd = end ??
          (audioStream.isThrottled
              ? (start + 10379935)
              : audioStream.size.totalBytes);
      if (computedEnd > audioStream.size.totalBytes) {
        computedEnd = audioStream.size.totalBytes;
      }

      // Get the full audio stream.
      final fullStream = ytExplode.videos.streams.get(audioStream);

      // Transform the full stream: skip the first [start] bytes and take only (computedEnd - start) bytes.
      // final adjustedStream = fullStream
      //     .transform(SkipBytesTransformer(start))
      //     .transform(TakeBytesTransformer(computedEnd - start));

      return StreamAudioResponse(
        sourceLength: audioStream.size.totalBytes,
        contentLength: computedEnd - start,
        offset: start,
        stream: fullStream,
        contentType: audioStream.codec.mimeType,
      );
    } catch (e) {
      throw Exception('Failed to load audio: $e');
    }
  }
}

/// Transformer that skips the first [bytesToSkip] bytes from a stream.
class SkipBytesTransformer extends StreamTransformerBase<List<int>, List<int>> {
  final int bytesToSkip;
  SkipBytesTransformer(this.bytesToSkip);

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) async* {
    int remaining = bytesToSkip;
    await for (final chunk in stream) {
      if (remaining > 0) {
        if (chunk.length <= remaining) {
          remaining -= chunk.length;
          continue;
        } else {
          yield chunk.sublist(remaining);
          remaining = 0;
        }
      } else {
        yield chunk;
      }
    }
  }
}

/// Transformer that takes only the first [bytesToTake] bytes from a stream.
class TakeBytesTransformer extends StreamTransformerBase<List<int>, List<int>> {
  final int bytesToTake;
  TakeBytesTransformer(this.bytesToTake);

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) async* {
    int remaining = bytesToTake;
    await for (final chunk in stream) {
      if (remaining <= 0) break;
      if (chunk.length <= remaining) {
        yield chunk;
        remaining -= chunk.length;
      } else {
        yield chunk.sublist(0, remaining);
        remaining = 0;
        break;
      }
    }
  }
}
