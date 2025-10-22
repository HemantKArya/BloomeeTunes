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
  // AudioSourceManager without audio source caching

  Future<AudioSource> getAudioSource(MediaItem mediaItem) async {
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
        return audioSource;
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

      return audioSource;
    } catch (e) {
      log('Error getting audio source for ${mediaItem.title}: $e',
          name: "AudioSourceManager");
      rethrow;
    }
  }

  // Cache-related getters removed
}
