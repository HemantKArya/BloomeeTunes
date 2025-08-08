import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/downloader.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/src/foundation/print.dart';
import 'package:device_info_plus/device_info_plus.dart';

part 'downloader_state.dart';

class DownTask {
  final String taskId;
  final MediaItemModel song;
  final String filePath;
  final String fileName;
  DownTask(
      {required this.taskId,
      required this.song,
      required this.filePath,
      required this.fileName});
}

Future<bool> storagePermission() async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  debugPrint('releaseVersion : ${androidInfo.version.release}');
  final int androidVersion = int.parse(androidInfo.version.release);
  bool havePermission = false;

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
      //..... as needed
    ].request(); //import 'package:permission_handler/permission_handler.dart';

    havePermission =
        request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    havePermission = status.isGranted;
  }

  if (!havePermission) {
    // if no permission then open app-setting
    await openAppSettings();
  }

  return havePermission;
}

class DownloaderCubit extends Cubit<DownloaderState> {
  static bool isInitialized = false;
  ConnectivityCubit connectivityCubit;
  static List<DownTask> downloadedSongs = List.empty(growable: true);
  static late String downPath;
  static ReceivePort receivePort = ReceivePort();
  DownloaderCubit({required this.connectivityCubit})
      : super(DownloaderInitial()) {
    if (!isInitialized && Platform.isAndroid) {
      initDownloader().then((value) => isInitialized = true);
    }
  }

  Future<void> initDownPath() async {
    downPath = (await BloomeeDBService.getSettingStr(
        GlobalStrConsts.downPathSetting,
        defaultValue: (await getDownloadsDirectory())!.path))!;
  }

  Future<String> getDownPath() async {
    return (await BloomeeDBService.getSettingStr(
        GlobalStrConsts.downPathSetting,
        defaultValue: (await getDownloadsDirectory())!.path))!;
  }

  Future<void> initDownloader() async {
    await initDownPath();
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );

    bool isSuccess = IsolateNameServer.registerPortWithName(
        receivePort.sendPort, "download_port");
    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping("download_port");
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, "download_port");
    }
    FlutterDownloader.registerCallback(callback);

    receivePort.listen((dynamic data) async {
      final String taskId = data[0];
      final int status = data[1];
      final int progress = data[2];
      print(
          "🔽 DEBUG: Download progress - TaskID: $taskId, Status: $status, Progress: $progress%");
      DownTask? _task;
      try {
        _task =
            downloadedSongs.firstWhere((element) => element.taskId == taskId);
      } catch (e) {
        log("Task not found", error: e, name: "DownloaderCubit");
      }
      if (_task != null) {
        // Emit progress state
        emit(DownloadProgress(
          taskId: taskId,
          songId: _task.song.id,
          progress: progress,
          status: status,
        ));

        if (status == DownloadTaskStatus.complete.index) {
          print("🔽 DEBUG: Download completed for: ${_task.song.title}");
          print("🔽 DEBUG: File path: ${_task.filePath}");
          downloadedSongs.remove(_task);
          log("Downloaded ${_task.song.title}", name: "DownloaderCubit");
          if (_task.song.extras!['source'] != 'youtube') {
            File file = File(_task.filePath);
            if (file.existsSync()) {
              await file.rename(_task.filePath.replaceAll(".mp4", ".m4a"));
              log("Renamed ${_task.fileName} to ${_task.fileName.replaceAll(".mp4", ".m4a")}",
                  name: "DownloaderCubit");
            }
          }
          // try {
          //   await Future.delayed(const Duration(milliseconds: 500), () async {
          //     await BloomeeDownloader.songTagger(_task!.song,
          //         "${(await getExternalStorageDirectory())!.path}/${_task.song.title} by ${_task.song.artist}.m4a");
          //   });
          // } catch (e) {
          //   log("Failed to tag ${_task.song.title}",
          //       error: e, name: "DownloaderCubit");
          // }
          BloomeeDBService.putDownloadDB(
              fileName: _task.fileName,
              filePath: _task.filePath,
              lastDownloaded: DateTime.now(),
              mediaItem: _task.song);
          SnackbarService.showMessage("Downloaded ${_task.song.title}");
          emit(DownloadCompleted(songId: _task.song.id, success: true));
        } else if (status == DownloadTaskStatus.failed.index) {
          print("🔽 DEBUG: Download failed for: ${_task.song.title}");
          print("🔽 DEBUG: Task ID: ${_task.taskId}");
          downloadedSongs.remove(_task);
          emit(DownloadCompleted(songId: _task.song.id, success: false));
          SnackbarService.showMessage("Failed to download ${_task.song.title}");
          log("Failed to download ${_task.song.title}",
              name: "DownloaderCubit");
        } else {}
      }
    });
  }

  Future<void> downloadSong(MediaItemModel song) async {
    print("🔽 DEBUG: DownloaderCubit.downloadSong() called");
    print(
        "🔽 DEBUG: Song details - Title: ${song.title}, Artist: ${song.artist}");
    print("🔽 DEBUG: Song URL: ${song.extras?['url']}");
    print("🔽 DEBUG: Song Source: ${song.extras?['source']}");

    /*final hasStorageAccess =
        Platform.isAndroid ? await Permission.storage.isGranted : true;
    if (!hasStorageAccess) {
      await Permission.storage.request();
      if (!await Permission.storage.isGranted) {
        SnackbarService.showMessage("Storage permission denied!");
        return;
      }
    }
    }*/
    print("🔽 DEBUG: Checking storage permission...");
    final permission = await storagePermission();
    print("🔽 DEBUG: Storage permission result: $permission");
    debugPrint('permission : $permission');
    // check if song is already added to download queue
    print("🔽 DEBUG: Checking download conditions...");
    print("🔽 DEBUG: isInitialized: $isInitialized");
    print("🔽 DEBUG: Connectivity state: ${connectivityCubit.state}");

    if (isInitialized &&
        connectivityCubit.state == ConnectivityState.connected) {
      print("🔽 DEBUG: Download conditions met, proceeding...");

      if (downloadedSongs.any(
          (element) => element.song.extras!['url'] == song.extras!['url'])) {
        print("🔽 DEBUG: Song already in download queue, skipping...");
        log("${song.title} already added to download queue",
            name: "DownloaderCubit");
        SnackbarService.showMessage(
            "${song.title} already added to download queue");
        return;
      }
      print("🔽 DEBUG: Getting download path...");
      downPath = await getDownPath();
      print("🔽 DEBUG: Download path: $downPath");

      String fileName;
      if (song.extras!['source'] != 'youtube') {
        fileName = "${song.title} by ${song.artist}.mp4"
            .replaceAll('?', '-')
            .replaceAll('/', '-');
      } else {
        fileName = "${song.title} by ${song.artist}.m4a"
            .replaceAll('?', '-')
            .replaceAll('/', '-');
      }
      print("🔽 DEBUG: Initial filename: $fileName");

      fileName = await BloomeeDownloader.getValidFileName(fileName, downPath);
      print("🔽 DEBUG: Final filename: $fileName");

      log('downloading $fileName', name: "DownloaderCubit");
      print("🔽 DEBUG: Starting actual download process...");

      final String? taskId = await BloomeeDownloader.downloadSong(song,
          fileName: fileName, filePath: downPath);

      if (taskId != null) {
        print("🔽 DEBUG: Download task created successfully with ID: $taskId");
        SnackbarService.showMessage("Added ${song.title} to download queue");

        downloadedSongs.add(DownTask(
            taskId: taskId,
            song: song,
            filePath: downPath,
            fileName: fileName));
        print(
            "🔽 DEBUG: Download task added to queue. Total tasks: ${downloadedSongs.length}");
      } else {
        print("🔽 DEBUG: Failed to create download task - taskId is null");
      }
    } else {
      print("🔽 DEBUG: Download failed - conditions not met");
      print(
          "🔽 DEBUG: isInitialized: $isInitialized, connectivity: ${connectivityCubit.state}");
      SnackbarService.showMessage(
          "No internet connection or download service not initialized");
    }
  }
}

@pragma('vm:entry-point')
Future callback(String taskId, int status, int progress) async {
  final SendPort? send = IsolateNameServer.lookupPortByName('download_port');
  send?.send([taskId, status, progress]);
}
