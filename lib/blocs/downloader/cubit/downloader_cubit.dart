import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/download/rust_download_service.dart';
import 'package:Bloomee/src/rust/api/downloader/types.dart';
import 'package:Bloomee/utils/download_types.dart';
import 'package:path/path.dart' as path;
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/repository/bloomee/download_repository.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:async/async.dart';

part 'downloader_state.dart';

class DownloaderCubit extends Cubit<DownloaderState> {
  final ConnectivityCubit connectivityCubit;
  final LibraryItemsCubit libraryItemsCubit;
  final DownloadRepository _downloadRepo;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;
  final RustDownloadService _downloadService = RustDownloadService();
  Future<void>? _serviceInitialization;
  final List<DownloadProgress> _activeDownloads = [];
  StreamSubscription? _librarySubscription;
  Timer? _libraryRefreshDebounce;
  StreamSubscription<DownloadManagerEvent>? _downloadSubscription;
  List<Track> _downloadedSongs = [];
  final Set<String> _persistingTaskIds = <String>{};
  bool _restoredSnapshots = false;
  // Tracks completion of initial downloaded songs load (prevents playback race)
  final CancelableCompleter<void> _initialLoadCompleter =
      CancelableCompleter<void>();

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
    _setupLibrarySubscription();
    _loadDownloadedSongs();
    unawaited(_warmUpDownloadService());
  }

  /// Waits for initial downloaded songs to be loaded from database.
  /// Call this before using [isDownloaded] on first app startup to prevent
  /// race conditions on Android where playback might start before DB load completes.
  Future<void> ensureDownloadsInitialized() async {
    try {
      await _initialLoadCompleter.operation.value;
    } catch (_) {
      // Ignore cancellation; initialization will proceed normally
    }
  }

  Future<void> _warmUpDownloadService() async {
    try {
      await _ensureDownloadServiceReady();
    } catch (error, stackTrace) {
      log(
        'Failed to initialize Rust download service',
        name: 'DownloaderCubit',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _ensureDownloadServiceReady() {
    if (_downloadService.isInitialized && _downloadSubscription != null) {
      return Future.value();
    }

    final inFlight = _serviceInitialization;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _initializeDownloadService();
    _serviceInitialization = future.whenComplete(() {
      if (!_downloadService.isInitialized || _downloadSubscription == null) {
        _serviceInitialization = null;
      }
    });
    return _serviceInitialization!;
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
    _librarySubscription = libraryItemsCubit.stream.listen((_) {
      _libraryRefreshDebounce?.cancel();
      _libraryRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
        if (!isClosed) {
          _loadDownloadedSongs();
        }
      });
    });
  }

  Future<void> _loadDownloadedSongs() async {
    try {
      _downloadedSongs = await _downloadRepo.getDownloadedTracks();
      _emitUpdatedState();
      // Signal that initial load is complete
      if (!_initialLoadCompleter.isCompleted) {
        _initialLoadCompleter.complete();
      }
    } catch (error, stackTrace) {
      // Even on error, mark as attempted to avoid hanging
      if (!_initialLoadCompleter.isCompleted) {
        _initialLoadCompleter.completeError(error, stackTrace);
      }
      rethrow;
    }
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

  Future<void> _initializeDownloadService() async {
    await _pluginService.initialize();

    final supportDirectory = await getApplicationSupportDirectory();
    final tempDirectory = await getTemporaryDirectory();
    await _downloadService.initialize(
      pluginManager: _pluginService.manager,
      stateDir: path.join(supportDirectory.path, 'download_manager'),
      tempDir: path.join(tempDirectory.path, 'bloomee_downloads'),
    );

    _downloadSubscription ??= _downloadService.events.listen(
      _handleDownloadEvent,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'Rust download event stream failed',
          name: 'DownloaderCubit',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    if (_restoredSnapshots) {
      return;
    }

    final snapshots = await _downloadService.restoreTasks();
    _restoredSnapshots = true;
    if (snapshots.isNotEmpty) {
      for (final snapshot in snapshots) {
        _upsertSnapshot(snapshot, emitState: false);
      }
      _emitUpdatedState();
    }
  }

  void _handleDownloadEvent(DownloadManagerEvent event) {
    event.map(
      taskUpdated: (value) {
        final snapshot = value.field0;
        _upsertSnapshot(snapshot);
        if (snapshot.state == DownloadTaskState.failed) {
          SnackbarService.showMessage(
            snapshot.lastError ?? 'Failed to download ${snapshot.track.title}',
          );
        }
      },
      taskCompletedPendingAck: (value) {
        final snapshot = value.field0;
        _upsertSnapshot(snapshot);
        unawaited(_persistCompletedSnapshot(snapshot));
      },
      taskRemoved: (value) {
        _activeDownloads.removeWhere(
          (item) => item.task.taskId == value.taskId,
        );
        _emitUpdatedState();
      },
      recoverySummary: (value) {
        if (value.restored > 0) {
          SnackbarService.showMessage(
            'Restored ${value.restored} download${value.restored == 1 ? '' : 's'} after restart',
          );
        }
      },
    );
  }

  Future<void> _persistCompletedSnapshot(DownloadTaskSnapshot snapshot) async {
    if (!_persistingTaskIds.add(snapshot.taskId)) {
      return;
    }

    try {
      final filePath = snapshot.targetPath;
      if (filePath.isEmpty) {
        throw StateError('Completed download has no target path');
      }

      final fileName = snapshot.fileName.isNotEmpty
          ? snapshot.fileName
          : path.basename(filePath);
      final downloadDirectory = path.dirname(filePath);

      await _downloadRepo.saveDownload(
        fileName: fileName,
        filePath: downloadDirectory,
        lastDownloaded: DateTime.now(),
        track: snapshot.track,
      );
      await _downloadService.acknowledgePersisted(snapshot.taskId);
      SnackbarService.showMessage('Downloaded ${snapshot.track.title}');
      await _loadDownloadedSongs();
    } catch (error, stackTrace) {
      log(
        'Failed to persist completed download ${snapshot.taskId}',
        name: 'DownloaderCubit',
        error: error,
        stackTrace: stackTrace,
      );
      SnackbarService.showMessage(
        'Downloaded file is ready, but saving it to the library failed.',
      );
    } finally {
      _persistingTaskIds.remove(snapshot.taskId);
    }
  }

  void _upsertSnapshot(
    DownloadTaskSnapshot snapshot, {
    bool emitState = true,
  }) {
    final progress = _progressFromSnapshot(snapshot);
    final index = _activeDownloads.indexWhere(
      (item) => item.task.taskId == snapshot.taskId,
    );

    if (index == -1) {
      _activeDownloads.insert(0, progress);
    } else {
      _activeDownloads[index] = progress;
    }

    if (emitState) {
      _emitUpdatedState();
    }
  }

  DownloadProgress _progressFromSnapshot(DownloadTaskSnapshot snapshot) {
    final filePath = snapshot.targetPath.isNotEmpty
        ? snapshot.targetPath
        : snapshot.tempPath;

    final downloadTask = DownloadTask(
      taskId: snapshot.taskId,
      song: snapshot.track,
      mediaId: snapshot.track.id,
      fileName: snapshot.fileName.isNotEmpty
          ? snapshot.fileName
          : path.basename(filePath),
      targetPath: snapshot.targetPath,
    );

    return DownloadProgress(
      task: downloadTask,
      status: DownloadStatus(
        state: _mapDownloadState(snapshot.state),
        progress: snapshot.progress.clamp(0.0, 1.0),
        message: snapshot.message,
        filePath: snapshot.targetPath.isNotEmpty ? snapshot.targetPath : null,
      ),
    );
  }

  DownloadState _mapDownloadState(DownloadTaskState state) {
    switch (state) {
      case DownloadTaskState.queued:
        return DownloadState.queued;
      case DownloadTaskState.resolving:
        return DownloadState.resolving;
      case DownloadTaskState.downloading:
        return DownloadState.downloading;
      case DownloadTaskState.paused:
        return DownloadState.paused;
      case DownloadTaskState.retrying:
        return DownloadState.retrying;
      case DownloadTaskState.writingMetadata:
        return DownloadState.fetchingMetadata;
      case DownloadTaskState.completedPendingAck:
        return DownloadState.completed;
      case DownloadTaskState.failed:
        return DownloadState.failed;
      case DownloadTaskState.cancelled:
        return DownloadState.cancelled;
    }
  }

  DownloadProgress? _findDownloadByMediaId(String mediaId) {
    try {
      return _activeDownloads
          .firstWhere((item) => item.task.mediaId == mediaId);
    } catch (_) {
      return null;
    }
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

  /// The main public method to initiate a new download.
  Future<void> downloadSong(Track song, {bool showSnackbar = true}) async {
    try {
      await _ensureDownloadServiceReady();
    } catch (error, stackTrace) {
      log(
        'Failed to prepare download service for ${song.title}',
        name: 'DownloaderCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (showSnackbar) {
        SnackbarService.showMessage('Error: Download service is unavailable.');
      }
      return;
    }

    if (connectivityCubit.state != ConnectivityState.connected) {
      if (showSnackbar) SnackbarService.showMessage("No internet connection.");
      return;
    }

    // Pre-download checks
    final existingDownload = _findDownloadByMediaId(song.id);
    if (existingDownload != null) {
      if (existingDownload.status.state == DownloadState.paused ||
          existingDownload.status.state == DownloadState.failed) {
        await resumeDownload(existingDownload.task.taskId);
        if (showSnackbar) {
          SnackbarService.showMessage('Resuming ${song.title}...');
        }
      } else if (showSnackbar) {
        SnackbarService.showMessage('${song.title} is already in the queue.');
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

    if (showSnackbar) {
      SnackbarService.showMessage("Preparing download for ${song.title}...");
    }

    try {
      final storedQuality = await _settingsDao.getSettingStr(
        SettingKeys.downQuality,
        defaultValue: 'Medium',
      );
      await _downloadService.enqueue(
        request: EnqueueDownloadRequest(
          track: song,
          downloadDir: directory.path,
          preferredQuality: storedQuality ?? 'Medium',
        ),
      );

      if (showSnackbar) {
        SnackbarService.showMessage('Added ${song.title} to download queue');
      }
    } catch (e, stackTrace) {
      log(
        'Failed to queue download for ${song.title}',
        name: 'DownloaderCubit',
        error: e,
        stackTrace: stackTrace,
      );

      if (showSnackbar) {
        SnackbarService.showMessage('Error: Could not start download.');
      }
    }
  }

  Future<void> pauseDownload(String taskId) async {
    await _ensureDownloadServiceReady();
    await _downloadService.pause(taskId);
  }

  Future<void> resumeDownload(String taskId) async {
    await _ensureDownloadServiceReady();
    await _downloadService.resume(taskId);
  }

  Future<void> cancelDownload(String taskId) async {
    await _ensureDownloadServiceReady();
    await _downloadService.cancel(taskId);
  }

  @override
  Future<void> close() async {
    _libraryRefreshDebounce?.cancel();
    await _librarySubscription?.cancel();
    await _downloadSubscription?.cancel();
    await _downloadService.dispose();
    await super.close();
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
