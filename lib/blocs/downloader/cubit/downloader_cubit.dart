import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/utils/audio_tagger.dart';
import 'package:Bloomee/utils/dload.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as path;
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/repository/bloomee/download_repository.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'downloader_state.dart';

class DownloaderCubit extends Cubit<DownloaderState> {
  final ConnectivityCubit connectivityCubit;
  final LibraryItemsCubit libraryItemsCubit;
  final DownloadRepository _downloadRepo;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;
  final DownloadEngine _downloadEngine = DownloadEngine();
  final List<DownloadProgress> _activeDownloads = [];
  StreamSubscription? _librarySubscription;
  List<Track> _downloadedSongs = [];

  DownloaderCubit({
    required this.connectivityCubit,
    required this.libraryItemsCubit,
    required DownloadRepository downloadRepo,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _downloadRepo = downloadRepo,
        _settingsDao = settingsDao,
        _pluginService = pluginService,
        super(DownloaderInitial()) {
    _downloadEngine.onTaskAdded = _handleNewTask;
    MetadataGod.initialize();
    _setupLibrarySubscription();
    _loadDownloadedSongs();
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
      return directory;
    }
    final p = await _settingsDao.getSettingStr(SettingKeys.downPathSetting);
    if (p != null) {
      return Directory(p);
    }
    return await getApplicationDocumentsDirectory();
  }

  void _setupLibrarySubscription() {
    _librarySubscription = libraryItemsCubit.stream.listen((event) {
      log("LibraryItemsCubit event: ${event.playlists.length}",
          name: "DownloaderCubit");
      _loadDownloadedSongs();
    });
  }

  Future<void> _loadDownloadedSongs() async {
    _downloadedSongs = await _downloadRepo.getDownloadedTracks();
    _emitUpdatedState();
  }

  void _emitUpdatedState() {
    emit(DownloaderTasksUpdated(
      List.from(_activeDownloads),
      List.from(_downloadedSongs),
    ));
  }

  /// Public method to refresh downloaded songs
  Future<void> refreshDownloadedSongs() async {
    await _loadDownloadedSongs();
  }

  void _handleNewTask(DownloadTask task) {
    final newItem = DownloadProgress(
      task: task,
      status: const DownloadStatus(
          state: DownloadState.queued, message: "In Queue"),
    );
    _activeDownloads.insert(0, newItem);
    _emitUpdatedState();

    task.statusStream.listen((status) {
      final index = _activeDownloads
          .indexWhere((item) => item.task.originalUrl == task.originalUrl);
      if (index != -1) {
        _activeDownloads[index] = DownloadProgress(task: task, status: status);

        if (status.state == DownloadState.completed) {
          _onDownloadComplete(task);
        } else if (status.state == DownloadState.failed) {
          _onDownloadFailed(task);
        }

        _emitUpdatedState();
      }
    });
  }

  void _onDownloadComplete(DownloadTask task) async {
    log("Downloaded ${task.fileName}", name: "DownloaderCubit");
    SnackbarService.showMessage(
        "Downloaded ${task.audioMetadata?.title ?? task.fileName}");

    final downloadDirectory = path.dirname(task.targetPath);
    await _downloadRepo.saveDownload(
        fileName: task.fileName,
        filePath: downloadDirectory,
        lastDownloaded: DateTime.now(),
        track: task.song);
    log("Saved metadata for ${task.fileName} to the database.",
        name: "DownloaderCubit");

    _activeDownloads
        .removeWhere((item) => item.task.originalUrl == task.originalUrl);
    await _loadDownloadedSongs();
  }

  void _onDownloadFailed(DownloadTask task) {
    log("Failed to download ${task.fileName}", name: "DownloaderCubit");
    SnackbarService.showMessage(
        "Failed to download ${task.audioMetadata?.title ?? task.fileName}");
    _activeDownloads
        .removeWhere((item) => item.task.originalUrl == task.originalUrl);
    _emitUpdatedState();
  }

  Future<bool> _isAlreadyDownloaded(Track song) async {
    final dbRecord = await _downloadRepo.getDownload(song.id);
    if (dbRecord != null) {
      final file = File(path.join(dbRecord.filePath, dbRecord.fileName));
      if (await file.exists()) {
        log("${song.title} is already downloaded and file exists.",
            name: "DownloaderCubit");
        return true;
      } else {
        log("Stale DB record found for ${song.title}. Removing.",
            name: "DownloaderCubit");
        await _downloadRepo.removeDownload(song.id);
        return false;
      }
    }
    return false;
  }

  /// Resolve a download stream for [track] via the plugin system.
  Future<StreamSource> _resolveDownloadStream(Track track) async {
    final parts = tryParseMediaId(track.id);
    if (parts == null) {
      if (track.url != null &&
          (track.url!.startsWith('http://') ||
              track.url!.startsWith('https://'))) {
        return StreamSource(
          url: track.url!,
          quality: Quality.high,
          format: _guessExtension(track.url!),
        );
      }
      throw Exception(
        'Cannot resolve download URL for "${track.title}" — '
        'malformed media ID: "${track.id}"',
      );
    }

    final response = await _pluginService.execute(
      pluginId: parts.pluginId,
      request: PluginRequest.contentResolver(
        ContentResolverCommand.getStreams(id: parts.localId),
      ),
    );

    return response.when(
      streams: (streams) async {
        final storedQuality = await _settingsDao.getSettingStr(
          SettingKeys.downQuality,
          defaultValue: AudioStreamQualityPreference.medium.label,
        );
        final preference = AudioStreamQualityPreferenceX.fromStored(
          storedQuality,
        );
        final selectedStream = StreamQualitySelector.selectDownloadStream(
          streams,
          preference: preference,
        );
        final streamUrl = selectedStream?.url.trim() ?? '';
        if (selectedStream == null || streamUrl.isEmpty) {
          throw Exception('No streams returned for "${track.title}"');
        }
        return selectedStream;
      },
      albumDetails: (_) => throw _unexpectedResponse('albumDetails'),
      artistDetails: (_) => throw _unexpectedResponse('artistDetails'),
      playlistDetails: (_) => throw _unexpectedResponse('playlistDetails'),
      search: (_) => throw _unexpectedResponse('search'),
      moreTracks: (_) => throw _unexpectedResponse('moreTracks'),
      moreAlbums: (_) => throw _unexpectedResponse('moreAlbums'),
      homeSections: (_) => throw _unexpectedResponse('homeSections'),
      loadMoreItems: (_) => throw _unexpectedResponse('loadMoreItems'),
      charts: (_) => throw _unexpectedResponse('charts'),
      chartDetails: (_) => throw _unexpectedResponse('chartDetails'),
      ack: () => throw _unexpectedResponse('ack'),
    );
  }

  Exception _unexpectedResponse(String type) =>
      Exception('Unexpected response type: $type for GetStreams');

  String _artistStr(Track track) => track.artists.map((a) => a.name).join(', ');

  String _sanitizeFileComponent(String value, {int maxLength = 80}) {
    final cleaned = value
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(RegExp(r'[. ]+$'), '');

    if (cleaned.isEmpty) return 'unknown';
    if (cleaned.length <= maxLength) return cleaned;
    return cleaned.substring(0, maxLength).trim();
  }

  String _buildDownloadFileName(Track song, String extension) {
    final safeTitle = _sanitizeFileComponent(song.title, maxLength: 70);
    final artistText = _artistStr(song);
    final safeArtist = _sanitizeFileComponent(
      artistText.isEmpty ? 'Unknown Artist' : artistText,
      maxLength: 50,
    );
    final idSuffix = song.id.hashCode.toUnsigned(32).toRadixString(16);
    return '$safeTitle - $safeArtist [$idSuffix].$extension';
  }

  /// The main public method to initiate a new download.
  Future<void> downloadSong(Track song, {bool showSnackbar = true}) async {
    if (connectivityCubit.state != ConnectivityState.connected) {
      if (showSnackbar) SnackbarService.showMessage("No internet connection.");
      return;
    }

    // Pre-download checks
    if (_activeDownloads.any((item) => item.task.originalUrl == song.id)) {
      if (showSnackbar) {
        SnackbarService.showMessage("${song.title} is already in the queue.");
      }
      return;
    }

    if (await _isAlreadyDownloaded(song)) {
      if (showSnackbar) {
        SnackbarService.showMessage("${song.title} is already downloaded.");
      }
      return;
    }

    final directory = await _getDownloadDirectory();
    final tempFileName = '${_sanitizeFileComponent(song.title)}.temp';

    final placeholderTask = DownloadTask(
      url: "placeholder",
      originalUrl: song.id,
      fileName: tempFileName,
      targetPath: path.join(directory.path, tempFileName),
      maxRetries: 3,
      audioMetadata: null,
      song: song,
    );

    final placeholderProgress = DownloadProgress(
      task: placeholderTask,
      status: const DownloadStatus(
        state: DownloadState.resolving,
        message: "Resolving download URL...",
      ),
    );

    _activeDownloads.insert(0, placeholderProgress);
    _emitUpdatedState();

    if (showSnackbar) {
      SnackbarService.showMessage("Preparing download for ${song.title}...");
    }

    try {
      final index = _activeDownloads
          .indexWhere((item) => item.task.originalUrl == song.id);
      if (index != -1) {
        _activeDownloads[index] = DownloadProgress(
          task: placeholderTask,
          status: const DownloadStatus(
            state: DownloadState.fetchingMetadata,
          ),
        );
        _emitUpdatedState();
      }

      final selectedStream = await _resolveDownloadStream(song);
      final downloadUrl = selectedStream.url;
      final headers = streamHeadersToMap(selectedStream.headers);
      final artist = _artistStr(song);
      final ext = _guessExtension(downloadUrl);
      final fileName = _buildDownloadFileName(song, ext);
      final durationMs = song.durationMs;
      final metadata = AudioMetadata(
        title: song.title,
        artist: artist.isNotEmpty ? artist : "Unknown Artist",
        album: song.album?.title ?? "Unknown Album",
        artworkUrl: formatImgURL(song.thumbnail.url, ImageQuality.high),
        duration: durationMs != null
            ? Duration(milliseconds: durationMs.toInt())
            : null,
      );

      // Remove placeholder before adding the real task
      _activeDownloads.removeWhere((item) => item.task.originalUrl == song.id);

      _downloadEngine.addDownload(
        url: downloadUrl,
        originalUrl: song.id,
        directory: directory.path,
        fileName: fileName,
        maxRetries: 3,
        audioMetadata: metadata,
        song: song,
        headers: headers,
      );

      if (showSnackbar) {
        SnackbarService.showMessage("Added ${song.title} to download queue");
      }
    } on PluginException catch (e) {
      log("Plugin error while preparing download for ${song.title}",
          error: e, name: "DownloaderCubit");

      _activeDownloads.removeWhere((item) => item.task.originalUrl == song.id);
      _emitUpdatedState();

      if (e is PluginNotLoadedException && e.pluginId != null) {
        GlobalEventBus.instance
            .emitError(AppError.pluginNotLoaded(pluginId: e.pluginId!));
      }

      if (showSnackbar) {
        SnackbarService.showMessage(e.message);
      }
    } catch (e) {
      log("Failed to prepare download for ${song.title}",
          error: e, name: "DownloaderCubit");

      _activeDownloads.removeWhere((item) => item.task.originalUrl == song.id);
      _emitUpdatedState();

      if (showSnackbar) {
        SnackbarService.showMessage("Error: Could not process URL.");
      }
    }
  }

  /// Guess a file extension from the stream URL.
  String _guessExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final p = uri.path.toLowerCase();
      if (p.endsWith('.m4a')) return 'm4a';
      if (p.endsWith('.mp3')) return 'mp3';
      if (p.endsWith('.ogg')) return 'ogg';
      if (p.endsWith('.opus')) return 'opus';
      if (p.endsWith('.webm')) return 'webm';
      if (p.endsWith('.mp4')) return 'mp4';
    }
    return 'm4a'; // sensible default
  }

  @override
  Future<void> close() {
    _librarySubscription?.cancel();
    return super.close();
  }

  /// Check whether a song is downloaded.
  bool isDownloaded(String mediaId) {
    return _downloadedSongs.any((s) => s.id == mediaId);
  }

  /// Get the download info for a song, if available.
  Future<DownloadDB?> getDownloadInfo(Track song) async {
    return _downloadRepo.getDownload(song.id);
  }

  /// Remove a downloaded song and its file.
  Future<void> removeDownload(Track song) async {
    await _downloadRepo.removeDownload(song.id);
    await _loadDownloadedSongs();
    SnackbarService.showMessage("${song.title} download removed");
  }
}
