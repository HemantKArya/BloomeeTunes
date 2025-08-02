import 'dart:developer';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/ytstream_source.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioSourceManager {
  // Cache for audio sources to avoid repeated network calls
  final Map<String, AudioSource> _audioSourceCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  static const int _maxCacheSize = 50;

  bool _isCacheExpired(String mediaId) {
    final timestamp = _cacheTimestamps[mediaId];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiry;
  }

  void _addToCache(String mediaId, AudioSource source) {
    // Remove oldest entry if cache is full
    if (_audioSourceCache.length >= _maxCacheSize) {
      final oldestEntry = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
      _audioSourceCache.remove(oldestEntry.key);
      _cacheTimestamps.remove(oldestEntry.key);
    }

    _audioSourceCache[mediaId] = source;
    _cacheTimestamps[mediaId] = DateTime.now();
  }

  void clearCachedSource(String? mediaId) {
    if (mediaId != null) {
      _audioSourceCache.remove(mediaId);
      _cacheTimestamps.remove(mediaId);
    }
  }

  void clearAllCache() {
    _audioSourceCache.clear();
    _cacheTimestamps.clear();
  }

  Future<AudioSource> getAudioSource(MediaItem mediaItem,
      {required bool isConnected}) async {
    final mediaId = mediaItem.id;

    // Check cache first (if not expired)
    if (_audioSourceCache.containsKey(mediaId) && !_isCacheExpired(mediaId)) {
      log('Using cached audio source for ${mediaItem.title}',
          name: "AudioSourceManager");
      return _audioSourceCache[mediaId]!;
    }

    try {
      // Check for offline version first
      final _down = await BloomeeDBService.getDownloadDB(
          mediaItem2MediaItemModel(mediaItem));
      if (_down != null) {
        log("Playing Offline: ${mediaItem.title}", name: "AudioSourceManager");
        SnackbarService.showMessage("Playing Offline",
            duration: const Duration(seconds: 1));

        final audioSource = AudioSource.uri(
            Uri.file('${_down.filePath}/${_down.fileName}'),
            tag: mediaItem);

        // Cache offline source (it won't expire)
        _addToCache(mediaId, audioSource);
        return audioSource;
      }

      // Check network connectivity before attempting online playback
      if (!isConnected) {
        throw Exception('No network connection available');
      }

      AudioSource audioSource;

      if (mediaItem.extras?["source"] == "youtube") {
        String? quality =
            await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality);
        quality = quality ?? "high";
        quality = quality.toLowerCase();
        final id = mediaItem.id.replaceAll("youtube", '');

        audioSource =
            YouTubeAudioSource(videoId: id, quality: quality, tag: mediaItem);
      } else {
        String? kurl = await getJsQualityURL(mediaItem.extras?["url"]);
        if (kurl == null || kurl.isEmpty) {
          throw Exception('Failed to get stream URL');
        }

        log('Playing: $kurl', name: "AudioSourceManager");
        audioSource = AudioSource.uri(Uri.parse(kurl), tag: mediaItem);
      }

      // Cache the audio source
      _addToCache(mediaId, audioSource);
      return audioSource;
    } catch (e) {
      log('Error getting audio source for ${mediaItem.title}: $e',
          name: "AudioSourceManager");
      rethrow;
    }
  }

  bool get hasCachedSources => _audioSourceCache.isNotEmpty;
  int get cacheSize => _audioSourceCache.length;
}
