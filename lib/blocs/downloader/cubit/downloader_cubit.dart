import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/downloader.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'downloader_state.dart';

class DownTask {
  final String taskId;
  final MediaItemModel song;
  DownTask({required this.taskId, required this.song});
}

class DownloaderCubit extends Cubit<DownloaderState> {
  static bool isInitialized = false;
  static List<DownTask> downloadedSongs = List.empty(growable: true);
  static ReceivePort receivePort = ReceivePort();
  DownloaderCubit() : super(DownloaderInitial()) {
    initDownloader().then((value) => isInitialized = true);
  }

  Future<void> initDownloader() async {
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
      // final int progress = data[2];
      DownTask? _task;
      try {
        _task =
            downloadedSongs.firstWhere((element) => element.taskId == taskId);
      } catch (e) {
        log("Task not found", error: e, name: "DownloaderCubit");
      }
      if (_task != null) {
        if (status == DownloadTaskStatus.complete.index) {
          downloadedSongs.remove(_task);
          log("Downloaded ${_task.song.title}", name: "DownloaderCubit");
          if (_task.song.extras!['source'] != 'youtube') {
            File file = File(
                "${(await getExternalStorageDirectory())!.path}/${_task.song.title} by ${_task.song.artist}.mp4");
            if (file.existsSync()) {
              await file.rename(
                  "${(await getExternalStorageDirectory())!.path}/${_task.song.title} by ${_task.song.artist}.m4a");
              log("Renamed ${_task.song.title} by ${_task.song.artist}.mp4 to ${_task.song.title} by ${_task.song.artist}.m4a",
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
              fileName: "${_task.song.title} by ${_task.song.artist}.m4a",
              filePath: (await getExternalStorageDirectory())!.path,
              isDownloaded: true,
              lastDownloaded: DateTime.now(),
              mediaItem: _task.song);
          SnackbarService.showMessage("Downloaded ${_task.song.title}");
        } else if (status == DownloadTaskStatus.failed.index) {
          downloadedSongs.remove(_task);
          SnackbarService.showMessage("Failed to download ${_task.song.title}");
          log("Failed to download ${_task.song.title}",
              name: "DownloaderCubit");
        } else {}
      }
    });
  }

  Future<void> downloadSong(MediaItemModel song) async {
    final hasStorageAccess =
        Platform.isAndroid ? await Permission.storage.isGranted : true;
    if (!hasStorageAccess) {
      await Permission.storage.request();
      if (!await Permission.storage.isGranted) {
        SnackbarService.showMessage("Storage permission denied!");
        return;
      }
    }
    // check if song is already added to download queue
    if (downloadedSongs
        .any((element) => element.song.extras!['url'] == song.extras!['url'])) {
      log("${song.title} already added to download queue",
          name: "DownloaderCubit");
      SnackbarService.showMessage(
          "${song.title} already added to download queue");
      return;
    }
    final String? taskId = await BloomeeDownloader.downloadSong(song);
    if (taskId != null) {
      SnackbarService.showMessage("Added ${song.title} to download queue");
      downloadedSongs.add(DownTask(taskId: taskId, song: song));
    }
  }
}

@pragma('vm:entry-point')
Future callback(String taskId, int status, int progress) async {
  final SendPort? send = IsolateNameServer.lookupPortByName('download_port');
  send?.send([taskId, status, progress]);
}
