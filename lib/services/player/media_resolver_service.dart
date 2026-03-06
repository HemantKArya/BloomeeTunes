import 'dart:developer';

import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

class ResolvedMediaSource {
  final Uri uri;
  final bool isOffline;
  final Map<String, String>? headers;

  const ResolvedMediaSource({
    required this.uri,
    required this.isOffline,
    this.headers,
  });
}

/// Resolves a [Track] into a playable [Uri].
///
/// Resolution order:
/// 1. Local downloaded file (offline).
/// 2. Plugin system — asks the owning plugin for stream URIs via [GetStreams].
class MediaResolverService {
  final DownloadDAO _downloadDao;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;

  MediaResolverService({
    required DownloadDAO downloadDao,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _downloadDao = downloadDao,
        _settingsDao = settingsDao,
        _pluginService = pluginService;

  /// Factory that creates its own DAO instances from [DBProvider.db].
  factory MediaResolverService.create(PluginService pluginService) {
    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    return MediaResolverService(
      downloadDao: DownloadDAO(DBProvider.db, trackDao, playlistDao),
      settingsDao: SettingsDAO(DBProvider.db),
      pluginService: pluginService,
    );
  }

  /// Resolve [track] into a playable URI.
  Future<ResolvedMediaSource> resolve(Track track) async {
    // 1. Check for an offline/downloaded version.
    try {
      final down = await _downloadDao.getDownloadRecord(track.id);
      if (down != null) {
        log('Playing Offline: ${track.title}', name: 'MediaResolverService');
        return ResolvedMediaSource(
          uri: Uri.file('${down.filePath}/${down.fileName}'),
          isOffline: true,
        );
      }
    } catch (e) {
      log('Download check failed: $e', name: 'MediaResolverService');
      // Non-fatal — continue to online resolution
    }

    // 2. Plugin-based stream resolution.
    final parts = tryParseMediaId(track.id);
    if (parts == null) {
      GlobalEventBus.instance.emitError(
        AppError.malformedMediaId(rawId: track.id),
      );
      throw Exception(
        'Cannot resolve stream for "${track.title}" — '
        'malformed media ID: "${track.id}"',
      );
    }

    log(
        'Resolving streams for "${track.title}" '
        '(plugin: ${parts.pluginId}, id: ${parts.localId})',
        name: 'MediaResolverService');

    PluginResponse response;
    try {
      response = await _pluginService.execute(
        pluginId: parts.pluginId,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getStreams(id: parts.localId),
        ),
      );
    } on PluginException catch (e) {
      if (e is PluginNotLoadedException) {
        GlobalEventBus.instance.emitError(
          AppError.pluginNotLoaded(pluginId: parts.pluginId, mediaId: track.id),
        );
      } else {
        GlobalEventBus.instance.emitError(
          AppError.pluginError(
            pluginId: parts.pluginId,
            message: e.message,
          ),
        );
      }
      rethrow;
    }

    return response.when(
      streams: (streams) async {
        if (streams.isEmpty) {
          throw Exception('No streams returned for "${track.title}"');
        }

        final storedQuality = await _settingsDao.getSettingStr(
          SettingKeys.strmQuality,
          defaultValue: AudioStreamQualityPreference.medium.label,
        );
        final preference = AudioStreamQualityPreferenceX.fromStored(
          storedQuality,
        );
        final selectedStream = StreamQualitySelector.selectPlaybackStream(
          streams,
          preference: preference,
        );
        final streamUrl = selectedStream?.url.trim();

        if (streamUrl == null || streamUrl.isEmpty) {
          throw Exception(
            'Streams returned for "${track.title}" contain no playable URL',
          );
        }

        final uri = Uri.tryParse(streamUrl);
        if (uri == null ||
            uri.scheme.isEmpty ||
            (uri.scheme != 'http' &&
                uri.scheme != 'https' &&
                uri.scheme != 'file')) {
          throw Exception(
            'Invalid stream URL for "${track.title}": $streamUrl',
          );
        }

        log('Resolved stream: $streamUrl', name: 'MediaResolverService');
        return ResolvedMediaSource(
          uri: uri,
          isOffline: false,
          headers: selectedStream == null
              ? null
              : streamHeadersToMap(selectedStream.headers),
        );
      },
      albumDetails: (_) =>
          throw Exception('Unexpected response type: albumDetails'),
      artistDetails: (_) =>
          throw Exception('Unexpected response type: artistDetails'),
      playlistDetails: (_) =>
          throw Exception('Unexpected response type: playlistDetails'),
      search: (_) => throw Exception('Unexpected response type: search'),
      moreTracks: (_) =>
          throw Exception('Unexpected response type: moreTracks'),
      moreAlbums: (_) =>
          throw Exception('Unexpected response type: moreAlbums'),
      homeSections: (_) =>
          throw Exception('Unexpected response type: homeSections'),
      loadMoreItems: (_) =>
          throw Exception('Unexpected response type: loadMoreItems'),
      charts: (_) => throw Exception('Unexpected response type: charts'),
      chartDetails: (_) =>
          throw Exception('Unexpected response type: chartDetails'),
      ack: () => throw Exception('Unexpected response type: ack'),
    );
  }
}
