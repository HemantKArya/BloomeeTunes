import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:io' show Platform;
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<AudioOnlyStreamInfo> getStreamInfoBG(
    String videoId, RootIsolateToken? token, String quality) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
  final ytExplode = YoutubeExplode();
  final manifest = await ytExplode.videos.streams.getManifest(videoId,
      requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
  // Prefer platform-supported codecs (iOS/macOS cannot play webm/opus).
  final allStreams = manifest.audioOnly.sortByBitrate();
  List<AudioOnlyStreamInfo> platformPreferred = allStreams;
  if (Platform.isIOS || Platform.isMacOS) {
    final mp4 = allStreams
        .where((s) => (s.codec.mimeType.toLowerCase().contains('audio/mp4')))
        .toList();
    if (mp4.isNotEmpty) platformPreferred = mp4;
  }
  final audioStream = quality == 'high'
      ? platformPreferred.lastOrNull
      : platformPreferred.firstOrNull;
  if (audioStream == null) {
    throw Exception('No audio stream available for this video.');
  }
  return audioStream;
}

class YouTubeAudioSource extends StreamAudioSource {
  final String videoId;
  final String quality; // 'high' or 'low'
  final YoutubeExplode ytExplode;

  YouTubeAudioSource({
    required this.videoId,
    required this.quality,
    super.tag,
  }) : ytExplode = YoutubeExplode();

  Future<AudioOnlyStreamInfo> getStreamInfo() async {
    final cachedStreams = await getStreamFromCache(videoId);
    if (cachedStreams != null) {
      final fromCache = quality == 'high' ? cachedStreams[1] : cachedStreams[0];
      // Validate codec support for platform; if unsupported, fetch fresh.
      if (!(Platform.isIOS || Platform.isMacOS) ||
          fromCache.codec.mimeType.toLowerCase().contains('audio/mp4')) {
        return fromCache;
      }
    }
    final vidId = videoId;
    final qlty = quality;
    final token = RootIsolateToken.instance;
    final audioStream =
        await Isolate.run(() => getStreamInfoBG(vidId, token, qlty));
    return audioStream;
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    try {
      // final t1 = DateTime.now().millisecondsSinceEpoch;
      final audioStream = await getStreamInfo();
      // final t2 = DateTime.now().millisecondsSinceEpoch;

      // Normalize and clamp the requested byte range to the source size.
      final int total = audioStream.size.totalBytes;
      final int startOffset = (start ?? 0).clamp(0, total);
      final int effectiveEnd = (end == null)
          ? (total == 0 ? 0 : total - 1)
          : end.clamp(0, total == 0 ? 0 : total - 1);

      // HTTP range is inclusive, so bytes to send = (end - start + 1).
      int bytesToSend = total == 0
          ? 0
          : (effectiveEnd >= startOffset
              ? (effectiveEnd - startOffset + 1)
              : 0);

      // Base stream from the start (we'll slice locally to ensure
      // emitted bytes exactly match contentLength and offset semantics).
      final baseStream = ytExplode.videos.streams.get(audioStream);


      // Build a ranged stream that skips 'startOffset' bytes and then limits
      // to 'bytesToSend'. This guarantees we don't exceed contentLength.
      final Stream<List<int>> rangedStream =
          (startOffset == 0 && bytesToSend == total)
              ? baseStream
              : _limitStream(_skipBytes(baseStream, startOffset), bytesToSend);

      // dev.log('Time taken to get stream: ${t2 - t1}ms', name: 'YTStream');
      return StreamAudioResponse(
        sourceLength: total,
        contentLength: bytesToSend,
        offset: startOffset,
        stream: rangedStream,
        contentType: audioStream.codec.mimeType,
      );
    } catch (e) {
      throw Exception('Failed to load audio: $e');
    }
  }
}

// Caps the emitted bytes from `source` to at most `maxBytes`.
Stream<List<int>> _limitStream(Stream<List<int>> source, int maxBytes) {
  int remaining = maxBytes;
  final controller = StreamController<List<int>>(sync: true);
  late StreamSubscription<List<int>> sub;

  void close() {
    controller.close();
  }

  sub = source.listen(
    (chunk) {
      if (remaining <= 0) {
        sub.cancel();
        close();
        return;
      }
      final int toSend = chunk.length <= remaining ? chunk.length : remaining;
      if (toSend == chunk.length) {
        controller.add(chunk);
      } else {
        // Slice the chunk to not exceed remaining budget
        controller.add(Uint8List.fromList(chunk.sublist(0, toSend)));
      }
      remaining -= toSend;
      if (remaining == 0) {
        sub.cancel();
        close();
      }
    },
    onError: controller.addError,
    onDone: close,
    cancelOnError: true,
  );

  controller.onCancel = () async {
    await sub.cancel();
  };

  return controller.stream;
}

// Skips the first `skipCount` bytes from `source` before emitting.
Stream<List<int>> _skipBytes(Stream<List<int>> source, int skipCount) {
  int remainingToSkip = skipCount;
  if (remainingToSkip <= 0) return source;

  final controller = StreamController<List<int>>(sync: true);
  late StreamSubscription<List<int>> sub;

  void close() {
    controller.close();
  }

  sub = source.listen(
    (chunk) {
      if (remainingToSkip <= 0) {
        controller.add(chunk);
        return;
      }
      if (remainingToSkip >= chunk.length) {
        remainingToSkip -= chunk.length;
        return; // drop entire chunk
      }
      // Skip part of the chunk, emit the rest
      controller.add(Uint8List.fromList(chunk.sublist(remainingToSkip)));
      remainingToSkip = 0;
    },
    onError: controller.addError,
    onDone: close,
    cancelOnError: true,
  );

  controller.onCancel = () async {
    await sub.cancel();
  };

  return controller.stream;
}

Future<void> cacheYtStreams({
  required String id,
  required AudioOnlyStreamInfo hURL,
  required AudioOnlyStreamInfo lURL,
}) async {
  final expireAt = RegExp('expire=(.*?)&')
          .firstMatch(lURL.url.toString())!
          .group(1) ??
      (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 5.5).toString();

  try {
    BloomeeDBService.putYtLinkCache(
      id,
      jsonEncode(lURL.toJson()),
      jsonEncode(hURL.toJson()),
      int.parse(expireAt),
    );
    dev.log("Cached: $id, ExpireAt: $expireAt", name: "CacheYtStreams");
  } catch (e) {
    dev.log(e.toString(), name: "CacheYtStreams");
  }
}

Future<List<AudioOnlyStreamInfo>?> getStreamFromCache(String id) async {
  final cache = await BloomeeDBService.getYtLinkCache(id);
  if (cache != null) {
    final expireAt = cache.expireAt;
    if (expireAt > DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      // dev.log("Cache found: $id", name: "CacheYtStreams");
      return [
        AudioOnlyStreamInfo.fromJson(jsonDecode(cache.lowQURL!)),
        AudioOnlyStreamInfo.fromJson(jsonDecode(cache.highQURL)),
      ];
    }
  }
  return null;
}

/// Returns a direct, platform-compatible YouTube audio URI (no proxy).
/// On iOS/macOS, prefers `audio/mp4` streams for native playback.
Future<Uri> getYouTubeDirectUri(String videoId, String quality) async {
  // Try cache first
  final cached = await getStreamFromCache(videoId);
  AudioOnlyStreamInfo? chosen;
  if (cached != null) {
    final candidate = quality.toLowerCase() == 'high' ? cached[1] : cached[0];
    if (!(Platform.isIOS || Platform.isMacOS) ||
        candidate.codec.mimeType.toLowerCase().contains('audio/mp4')) {
      chosen = candidate;
    }
  }

  if (chosen == null) {
    final ytExplode = YoutubeExplode();
    try {
      final manifest = await ytExplode.videos.streams.getManifest(videoId,
          requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
      final allStreams = manifest.audioOnly.sortByBitrate();
      List<AudioOnlyStreamInfo> platformPreferred = allStreams;
      if (Platform.isIOS || Platform.isMacOS) {
        final mp4 = allStreams
            .where((s) => s.codec.mimeType.toLowerCase().contains('audio/mp4'))
            .toList();
        if (mp4.isNotEmpty) platformPreferred = mp4;
      }
      chosen = quality.toLowerCase() == 'high'
          ? platformPreferred.lastOrNull
          : platformPreferred.firstOrNull;
      if (chosen == null) {
        throw Exception('No compatible audio stream found');
      }
      // Cache for reuse
      await cacheYtStreams(
          id: videoId,
          hURL: platformPreferred.last,
          lURL: platformPreferred.first);
    } finally {
      ytExplode.close();
    }
  }

  return chosen.url;
}
