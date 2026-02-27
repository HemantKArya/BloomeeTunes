import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<AudioOnlyStreamInfo> getStreamInfoBG(
    String videoId, RootIsolateToken? token, String quality) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
  final ytExplode = YoutubeExplode();
  final manifest = await ytExplode.videos.streams.getManifest(videoId,
      requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
  final supportedStreams = manifest.audioOnly.sortByBitrate();
  final audioStream = quality == 'high'
      ? supportedStreams.lastOrNull
      : supportedStreams.firstOrNull;
  if (audioStream == null) {
    throw Exception('No audio stream available for this video.');
  }
  return audioStream;
}

/// Resolves a YouTube video ID into a direct audio stream [Uri].
///
/// Checks the local cache first. Falls back to youtube_explode_dart
/// for fresh resolution and caches the result.
Future<Uri> resolveYoutubeAudioUri({
  required String videoId,
  required String quality,
}) async {
  // Try cache first.
  final cachedStreams = await getStreamFromCache(videoId);
  if (cachedStreams != null) {
    final stream = quality == 'high' ? cachedStreams[1] : cachedStreams[0];
    return stream.url;
  }

  // Resolve from YouTube via background isolate.
  final token = RootIsolateToken.instance;
  final audioStream =
      await Isolate.run(() => getStreamInfoBG(videoId, token, quality));

  // Also resolve the other quality for caching both.
  try {
    final otherQuality = quality == 'high' ? 'low' : 'high';
    final otherStream =
        await Isolate.run(() => getStreamInfoBG(videoId, token, otherQuality));
    final hStream = quality == 'high' ? audioStream : otherStream;
    final lStream = quality == 'high' ? otherStream : audioStream;
    await cacheYtStreams(id: videoId, hURL: hStream, lURL: lStream);
  } catch (_) {
    // Caching the other quality is best-effort.
  }

  return audioStream.url;
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
    CacheDAO(DBProvider.db).putYtLinkCache(
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
  final cache = await CacheDAO(DBProvider.db).getYtLinkCache(id);
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
