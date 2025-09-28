import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/utils/audio_tagger.dart';
import 'package:Bloomee/utils/dload.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as path;
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'downloader_state.dart';

class DownloaderCubit extends Cubit<DownloaderState> {
  final ConnectivityCubit connectivityCubit;
  final LibraryItemsCubit libraryItemsCubit;
  final DownloadEngine _downloadEngine = DownloadEngine();
  final List<DownloadProgress> _activeDownloads = [];
  final YoutubeExplode _yt = YoutubeExplode();
  StreamSubscription? _librarySubscription;
  List<MediaItemModel> _downloadedSongs = [];

  DownloaderCubit({
    required this.connectivityCubit,
    required this.libraryItemsCubit,
  }) : super(DownloaderInitial()) {
    _downloadEngine.onTaskAdded = _handleNewTask;
    MetadataGod.initialize();
    _setupLibrarySubscription();
    _loadDownloadedSongs();
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // For Android and iOS, use the internal storage's downloads directory
      final directory = (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
      return directory;
    }
    // For other platforms, use the application documents directory by default
    // This can be adjusted based on your requirements
    final path =
        await BloomeeDBService.getSettingStr(GlobalStrConsts.downPathSetting);
    if (path != null) {
      return Directory(path);
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
    final list = await BloomeeDBService.getDownloadedSongs();
    _downloadedSongs = List<MediaItemModel>.from(list);
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
          // Pass the completed task to the handler
          _onDownloadComplete(task);
        } else if (status.state == DownloadState.failed) {
          _onDownloadFailed(task);
        }

        _emitUpdatedState();
      }
    });
  }

  /// --- NEW: Handles saving metadata to the database after completion ---
  void _onDownloadComplete(DownloadTask task) async {
    log("Downloaded ${task.fileName}", name: "DownloaderCubit");
    SnackbarService.showMessage(
        "Downloaded ${task.audioMetadata?.title ?? task.fileName}");

    // Only save to DB if it was a song with a MediaItemModel
    final downloadDirectory = path.dirname(task.targetPath);
    await BloomeeDBService.putDownloadDB(
        fileName: task.fileName,
        filePath: downloadDirectory,
        lastDownloaded: DateTime.now(),
        mediaItem: task.song);
    log("Saved metadata for ${task.fileName} to the database.",
        name: "DownloaderCubit");

    // Remove the task from the active downloads list
    _activeDownloads
        .removeWhere((item) => item.task.originalUrl == task.originalUrl);

    // Reload downloaded songs to include the newly completed download
    await _loadDownloadedSongs();
  }

  void _onDownloadFailed(DownloadTask task) {
    log("Failed to download ${task.fileName}", name: "DownloaderCubit");
    SnackbarService.showMessage(
        "Failed to download ${task.audioMetadata?.title ?? task.fileName}");

    // Remove the task from the active downloads list
    _activeDownloads
        .removeWhere((item) => item.task.originalUrl == task.originalUrl);
    _emitUpdatedState();
  }

  /// --- NEW: Checks the database and filesystem for an existing download ---
  Future<bool> _isAlreadyDownloaded(MediaItemModel song) async {
    final dbRecord = await BloomeeDBService.getDownloadDB(song);
    if (dbRecord != null) {
      final file = File(path.join(dbRecord.filePath, dbRecord.fileName));
      if (await file.exists()) {
        log("${song.title} is already downloaded and file exists.",
            name: "DownloaderCubit");
        return true; // The download exists in DB and on disk.
      } else {
        // The record is stale (in DB but file is missing), so remove it.
        log("Stale DB record found for ${song.title}. Removing.",
            name: "DownloaderCubit");
        await BloomeeDBService.removeDownloadDB(song);
        return false;
      }
    }
    return false; // No record found in the database.
  }

  /// The main public method to initiate a new download.
  Future<void> downloadSong(MediaItemModel song,
      {bool showSnackbar = true}) async {
    if (connectivityCubit.state != ConnectivityState.connected) {
      if (showSnackbar) SnackbarService.showMessage("No internet connection.");
      return;
    }

    // --- NEW: Perform pre-download checks ---
    if (_activeDownloads
        .any((item) => item.task.originalUrl == song.extras!['perma_url'])) {
      if (showSnackbar)
        SnackbarService.showMessage("${song.title} is already in the queue.");
      return;
    }

    if (await _isAlreadyDownloaded(song)) {
      if (showSnackbar)
        SnackbarService.showMessage("${song.title} is already downloaded.");
      return;
    }

    // Get directory for both placeholder and actual download
    final directory = await _getDownloadDirectory();

    // Create placeholder task immediately to show resolving state
    final sanitizedTitle =
        song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    final tempFileName = "$sanitizedTitle.temp";

    final placeholderTask = DownloadTask(
      url: "placeholder", // Will be filled later
      originalUrl: song.extras!['perma_url'],
      fileName: tempFileName,
      targetPath: path.join(directory.path, tempFileName),
      maxRetries: 3,
      audioMetadata: null, // Will be filled later
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

    if (showSnackbar)
      SnackbarService.showMessage("Preparing download for ${song.title}...");

    try {
      // Update status to fetching metadata
      final index = _activeDownloads.indexWhere(
          (item) => item.task.originalUrl == song.extras!['perma_url']);
      if (index != -1) {
        _activeDownloads[index] = DownloadProgress(
          task: placeholderTask,
          status: const DownloadStatus(
            state: DownloadState.fetchingMetadata,
            // message: "Fetching metadata...",
          ),
        );
        _emitUpdatedState();
      }

      String downloadUrl;
      String fileName;
      AudioMetadata? metadata;

      if (song.extras!['source'] == 'youtube' ||
          (song.extras!['perma_url'].toString()).contains('youtube')) {
        final video = await _yt.videos.get(song.id.replaceAll("youtube", ""));
        var manifest = await _yt.videos.streams.getManifest(video.id,
            requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
        AudioOnlyStreamInfo? audioStreamInfo;
        await BloomeeDBService.getSettingStr(GlobalStrConsts.ytDownQuality)
            .then((quality) {
          if (quality == "High") {
            audioStreamInfo = manifest.audioOnly
                .where(
                  (stream) => stream.container == StreamContainer.mp4,
                )
                .withHighestBitrate();
          } else {
            audioStreamInfo = manifest.audioOnly
                .where(
                  (stream) => stream.container == StreamContainer.mp4,
                )
                .sortByBitrate()
                .first;
          }
        });
        audioStreamInfo ??= manifest.audioOnly.withHighestBitrate();

        if (audioStreamInfo == null) {
          throw Exception("No suitable audio stream found for ${video.title}");
        }

        downloadUrl = audioStreamInfo!.url.toString();
        final sanitizedTitle =
            song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
        fileName =
            '$sanitizedTitle by ${song.artist} - ${song.id}.${audioStreamInfo!.container.name}';
        metadata = AudioMetadata(
          title: song.title,
          artist: song.artist ?? "Unknown Artist",
          album: song.album ?? "Unknown Album",
          artworkUrl: formatImgURL(song.artUri.toString(), ImageQuality.high),
          duration: song.duration,
        );
      } else {
        downloadUrl = song.extras!['url'];
        final quality =
            await BloomeeDBService.getSettingStr(GlobalStrConsts.downQuality);
        if (quality == "High") {
          downloadUrl =
              (await getJsQualityURL(downloadUrl, isStreaming: false))!;
        } else {
          downloadUrl =
              (await getJsQualityURL(downloadUrl, isStreaming: false))!;
        }
        final sanitizedTitle =
            song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
        fileName = '$sanitizedTitle by ${song.artist} - ${song.id}.m4a';
        metadata = AudioMetadata(
          title: song.title,
          artist: song.artist ?? "Unknown Artist",
          album: song.album ?? "Unknown Album",
          artworkUrl: formatImgURL(song.artUri.toString(), ImageQuality.high),
        );
      }

      // Remove the placeholder from active downloads before adding the real task
      _activeDownloads.removeWhere(
          (item) => item.task.originalUrl == song.extras!['perma_url']);

      _downloadEngine.addDownload(
        url: downloadUrl,
        originalUrl: song.extras!['perma_url'],
        directory: directory.path,
        fileName: fileName,
        maxRetries: 3,
        audioMetadata: metadata,
        song: song,
      );

      if (showSnackbar)
        SnackbarService.showMessage("Added ${song.title} to download queue");
    } catch (e) {
      log("Failed to prepare download for ${song.title}",
          error: e, name: "DownloaderCubit");

      // Remove the placeholder on error
      _activeDownloads.removeWhere(
          (item) => item.task.originalUrl == song.extras!['perma_url']);
      _emitUpdatedState();

      if (showSnackbar)
        SnackbarService.showMessage("Error: Could not process URL.");
    }
  }

  @override
  Future<void> close() {
    _librarySubscription?.cancel();
    _yt.close();
    return super.close();
  }
}
