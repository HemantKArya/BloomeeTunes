import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AutoYouTubeAudioSource {
  final String videoId;
  final String quality; // 'high' or 'low'
  final YoutubeExplode ytExplode;
  final MediaItem mediaItem;
  late final Future<AudioSource> audioSourceFuture;

  AutoYouTubeAudioSource({
    required this.videoId,
    required this.quality,
    required this.mediaItem,
  }) : ytExplode = YoutubeExplode() {
    audioSourceFuture = _initialize();
  }

  Future<AudioSource> _initialize() async {
    AudioOnlyStreamInfo? audioStream;
    final cachedStreams = await getStreamFromCache(videoId);
    // Get the manifest for the video.
    if (cachedStreams == null) {
      StreamManifest manifest =
          await ytExplode.videos.streamsClient.getManifest(
        videoId,
        requireWatchPage: false,
      );
      List<AudioOnlyStreamInfo> supportedStreams =
          manifest.audioOnly.sortByBitrate();
      // Add the streams to cache
      await cacheYtStreams(
        id: videoId,
        hURL: supportedStreams.last,
        lURL: supportedStreams.first,
      );
      // Choose high quality (highest bitrate) or low (lowest bitrate)
      audioStream = quality == 'high'
          ? (supportedStreams.isNotEmpty ? supportedStreams.last : null)
          : (supportedStreams.isNotEmpty ? supportedStreams.first : null);
    } else {
      audioStream = quality == 'high' ? cachedStreams[1] : cachedStreams[0];
    }
    if (audioStream == null) {
      throw Exception('No audio stream available for this video.');
    }
    final kurl = audioStream.url.toString();
    return AudioSource.uri(Uri.parse(kurl), tag: mediaItem);
  }

  Future<AudioSource> getAudioSource() async {
    return audioSourceFuture;
  }
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
      dev.log("Cache found: $id", name: "CacheYtStreams");
      return [
        AudioOnlyStreamInfo.fromJson(jsonDecode(cache.lowQURL!)),
        AudioOnlyStreamInfo.fromJson(jsonDecode(cache.highQURL)),
      ];
    }
  }
  return null;
}
