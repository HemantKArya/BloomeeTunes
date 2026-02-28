import 'dart:developer';

import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/utils/ytstream_source.dart';

/// Resolves a [MediaItemModel] into a playable [Uri].
///
/// Responsibility: locate audio — local file, YouTube stream, or Saavn stream.
/// No knowledge of queue management, transitions, or OS notifications.
///
/// Returns `(Uri, isOffline)`.
class MediaResolverService {
  final DownloadDAO _downloadDao;
  final SettingsDAO _settingsDao;
  final SettingsRepository _settingsRepo;

  MediaResolverService({
    required DownloadDAO downloadDao,
    required SettingsDAO settingsDao,
    required SettingsRepository settingsRepo,
  })  : _downloadDao = downloadDao,
        _settingsDao = settingsDao,
        _settingsRepo = settingsRepo;

  /// Factory that creates its own DAO instances from [DBProvider.db].
  factory MediaResolverService.fromRepo(SettingsRepository settingsRepo) {
    return MediaResolverService(
      downloadDao: DownloadDAO(DBProvider.db),
      settingsDao: SettingsDAO(DBProvider.db),
      settingsRepo: settingsRepo,
    );
  }

  /// Resolve [track] into a playable URI.
  ///
  /// Resolution order:
  /// 1. Local downloaded file
  /// 2. YouTube audio stream
  /// 3. Saavn / other stream URL
  Future<(Uri, bool isOffline)> resolve(MediaItemModel track) async {
    // 1. Check for an offline/downloaded version.
    final down = await _downloadDao.getDownloadDB(track);
    if (down != null) {
      log('Playing Offline: ${track.title}', name: 'MediaResolverService');
      SnackbarService.showMessage(
        'Playing Offline',
        duration: const Duration(seconds: 1),
      );
      return (Uri.file('${down.filePath}/${down.fileName}'), true);
    }

    // 2. YouTube sources.
    if (track.source == 'youtube' || track.source == 'youtube_music') {
      final quality =
          await _settingsDao.getSettingStr(SettingKeys.ytStrmQuality) ?? 'high';
      final videoId = track.id.replaceAll('youtube', '');
      final streamUri = await resolveYoutubeAudioUri(
        videoId: videoId,
        quality: quality.toLowerCase(),
      );
      return (streamUri, false);
    }

    // 3. Saavn / other.
    final kurl = await _settingsRepo.getJsQualityURL(track.streamUrl);
    if (kurl == null || kurl.isEmpty) {
      throw Exception('Failed to get stream URL for ${track.title}');
    }
    log('Resolved stream: $kurl', name: 'MediaResolverService');
    return (Uri.parse(kurl), false);
  }
}
