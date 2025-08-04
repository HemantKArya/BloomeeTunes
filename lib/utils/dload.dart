import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:Bloomee/model/songModel.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'audio_tagger.dart';

/// Enum to represent the various states of a download.
enum DownloadState {
  queued,
  resolving,
  fetchingMetadata,
  downloading,
  completed,
  failed,
  retrying,
  cancelled
}

/// A rich status object to report detailed progress, state, and messages to the UI.
class DownloadStatus {
  final DownloadState state;
  final double progress;
  final String? message;
  final int retryAttempt;
  final String? filePath;

  const DownloadStatus({
    required this.state,
    this.progress = 0.0,
    this.message,
    this.retryAttempt = 0,
    this.filePath,
  });
}

/// A comprehensive class to hold all information for a single download operation.
class DownloadTask {
  final String url;
  final String originalUrl;
  final String fileName;
  final String targetPath;
  final int maxRetries;
  final MediaItemModel song;
  final AudioMetadata? audioMetadata;
  final StreamController<DownloadStatus> statusController =
      StreamController<DownloadStatus>.broadcast();

  DownloadTask({
    required this.url,
    required this.originalUrl,
    required this.fileName,
    required this.targetPath,
    required this.maxRetries,
    required this.song,
    this.audioMetadata,
  }) {
    statusController.add(
        const DownloadStatus(state: DownloadState.queued, message: "In Queue"));
  }

  Stream<DownloadStatus> get statusStream => statusController.stream;
}

/// The core, source-agnostic download engine.
class DownloadEngine {
  static final DownloadEngine _instance = DownloadEngine._internal();
  factory DownloadEngine() => _instance;
  DownloadEngine._internal();

  final List<DownloadTask> _queue = [];
  bool _isProcessing = false;

  Function(DownloadTask)? onTaskAdded;

  void addDownload({
    required String url,
    required String originalUrl,
    required String directory,
    required String fileName,
    required MediaItemModel song,
    int maxRetries = 3,
    AudioMetadata? audioMetadata,
  }) {
    final task = DownloadTask(
      url: url,
      originalUrl: originalUrl,
      fileName: fileName,
      targetPath: path.join(directory, fileName),
      maxRetries: maxRetries,
      audioMetadata: audioMetadata,
      song: song,
    );
    _queue.add(task);
    onTaskAdded?.call(task);
    if (!_isProcessing) {
      _processNext();
    }
  }

  Future<void> _processNext() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }
    _isProcessing = true;
    final task = _queue.first;

    try {
      await _downloadWithRetries(task);

      if (task.audioMetadata != null) {
        task.statusController.add(DownloadStatus(
            state: DownloadState.completed,
            progress: 1.0,
            message: "Writing metadata...",
            filePath: task.targetPath));
        await AudioTagger.writeTags(task.targetPath, task.audioMetadata!);
      }

      // --- CHANGE: Attach the final file path to the completion status ---
      task.statusController.add(DownloadStatus(
          state: DownloadState.completed,
          progress: 1.0,
          message: "Download Complete",
          filePath: task.targetPath));
    } catch (e) {
      task.statusController.add(
          DownloadStatus(state: DownloadState.failed, message: e.toString()));
    } finally {
      if (!task.statusController.isClosed) task.statusController.close();
      _queue.removeAt(0);
      _processNext();
    }
  }

  Future<void> _downloadWithRetries(DownloadTask task) async {
    for (int attempt = 0; attempt <= task.maxRetries; attempt++) {
      try {
        await _downloadFile(task, (progress) {
          if (!task.statusController.isClosed) {
            task.statusController.add(DownloadStatus(
                state: DownloadState.downloading, progress: progress));
          }
        });
        return;
      } catch (e) {
        if (attempt < task.maxRetries) {
          if (!task.statusController.isClosed) {
            task.statusController.add(DownloadStatus(
                state: DownloadState.retrying,
                retryAttempt: attempt + 1,
                message: e.toString()));
          }
          final delay = Duration(seconds: pow(2, attempt + 1).toInt());
          await Future.delayed(delay);
        } else {
          throw Exception(
              'Download failed after ${task.maxRetries} retries: $e');
        }
      }
    }
  }

  Future<void> _downloadFile(
      DownloadTask task, Function(double) onProgress) async {
    final uri = Uri.parse(task.url);
    final response = await http.head(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Server responded with status code ${response.statusCode}');
    }
    final contentLengthStr = response.headers['content-length'];
    if (contentLengthStr == null) {
      throw Exception('File size could not be determined from the server.');
    }
    final contentLength = int.parse(contentLengthStr);
    if (contentLength <= 0) {
      throw Exception('File has zero or invalid size.');
    }
    const segmentSize = 1024 * 1024;
    final segmentCount = (contentLength / segmentSize).ceil();
    final segments = <Future<void>>[];
    int totalDownloaded = 0;

    // Get the temporary directory path in the main isolate
    final tempDir = await getTemporaryDirectory();
    final tempDirPath = tempDir.path;

    for (int i = 0; i < segmentCount; i++) {
      final start = i * segmentSize;
      final end = min(start + segmentSize - 1, contentLength - 1);
      final completer = Completer<void>();
      segments.add(completer.future);
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(_downloadSegment, {
        'url': task.url,
        'start': start,
        'end': end,
        'targetPath': task.targetPath,
        'segmentIndex': i,
        'tempDirPath': tempDirPath, // Pass the temp directory path
        'sendPort': receivePort.sendPort,
      });
      receivePort.listen((data) {
        if (data is int) {
          totalDownloaded += data;
          onProgress(min(totalDownloaded / contentLength, 1.0));
        } else if (data == 'done') {
          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          completer.complete();
        } else if (data is String && data.startsWith('Error:')) {
          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          completer.completeError(Exception(data));
        }
      });
    }
    await Future.wait(segments);
    await _mergeFiles(task.targetPath, segmentCount);
  }

  /// The function executed in a separate isolate to download one segment of the file.
  static void _downloadSegment(Map<String, dynamic> args) async {
    final uri = Uri.parse(args['url']);
    final start = args['start'] as int;
    final end = args['end'] as int;
    final sendPort = args['sendPort'] as SendPort;
    final targetPath = args['targetPath'] as String;
    final segmentIndex = args['segmentIndex'] as int;
    final tempDirPath =
        args['tempDirPath'] as String; // Receive the temp directory path

    // Extract only the file name from the targetPath
    final fileName = path.basename(targetPath);

    // Use the passed temp directory path for storing parts
    final tempFile = File('$tempDirPath/$fileName.part$segmentIndex');

    try {
      final request = http.Request('GET', uri);
      request.headers['Range'] = 'bytes=$start-$end';
      final response =
          await request.send().timeout(const Duration(seconds: 60));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'Segment failed with status code ${response.statusCode}');
      }

      final fileSink = tempFile.openWrite();
      response.stream.listen(
        (chunk) {
          fileSink.add(chunk);
          sendPort.send(chunk.length);
        },
        onDone: () async {
          await fileSink.close();
          sendPort.send('done');
        },
        onError: (e) {
          sendPort.send('Error: ${e.toString()}');
        },
        cancelOnError: true,
      );
    } catch (e) {
      sendPort.send('Error: ${e.toString()}');
    }
  }

  /// Merges all the downloaded file segments into a single final file.
  Future<void> _mergeFiles(String targetPath, int segmentCount) async {
    try {
      final targetFile = File(targetPath);
      final writer = targetFile.openWrite();
      final tempDir = (await getTemporaryDirectory()); // Use the temp directory

      // Extract only the file name from the targetPath
      final fileName = path.basename(targetPath);

      for (int i = 0; i < segmentCount; i++) {
        final segmentFile = File('${tempDir.path}/$fileName.part$i');
        if (await segmentFile.exists()) {
          await writer.addStream(segmentFile.openRead());
          await segmentFile.delete();
        } else {
          throw Exception('Missing segment part #$i. The download is corrupt.');
        }
      }
      await writer.close();
    } catch (e) {
      throw Exception('Failed to merge file parts: $e');
    }
  }
}
