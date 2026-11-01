import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Filesystem downloads and Android SAF documents share one lifecycle.
/// Rust finishes metadata in private staging; SAF publishes the final file.
/// The destination journal lives beside the staged file so recovery does not
/// depend on the current folder setting or on an in-memory task map.
class DownloadStorage {
  static const channel = MethodChannel('ls.bloomee/download_storage');
  static bool isDocument(String path) => path.startsWith('content://');

  static Uri mediaUri(String directory, String name) => isDocument(directory)
      ? Uri.parse(directory)
      : Uri.file(p.join(directory, name));

  static Future<String?> pickFolder() => channel.invokeMethod<String>('pick');

  static Future<Directory> prepareDirectory(String destination) async {
    if (!Platform.isAndroid || !isDocument(destination)) {
      return Directory(destination);
    }
    final support = await getApplicationSupportDirectory();
    final root = await Directory(p.join(support.path, 'download_staging'))
        .create(recursive: true);
    final dir = await root.createTemp('task_');
    await File(p.join(dir.path, 'destination.json'))
        .writeAsString(jsonEncode({'tree': destination}), flush: true);
    return dir;
  }

  static Future<String> publish(String filePath) async {
    if (!Platform.isAndroid) return p.dirname(filePath);
    final journal = File(p.join(p.dirname(filePath), 'destination.json'));
    if (!await journal.exists()) return p.dirname(filePath);
    return (await channel.invokeMethod<String>('publish', {'path': filePath}))!;
  }

  static Future<bool> exists(String directory, String name) async {
    if (!isDocument(directory)) return File(p.join(directory, name)).exists();
    try {
      return await channel.invokeMethod<bool>('exists', {'uri': directory}) ??
          false;
    } on MissingPluginException {
      // An Android backup can be restored on desktop. Keep the record until
      // its document provider is accessible again.
      return false;
    }
  }

  static Future<void> delete(String directory, String name) async {
    if (isDocument(directory)) {
      await channel.invokeMethod<void>('delete', {'uri': directory});
    } else {
      final file = File(p.join(directory, name));
      if (await file.exists()) await file.delete();
    }
  }

  static Future<void> cleanStaging(String filePath) async {
    if (!Platform.isAndroid) return;
    final support = await getApplicationSupportDirectory();
    final root = p.join(support.path, 'download_staging');
    final dir = p.dirname(filePath);
    if (p.isWithin(root, dir) &&
        p.dirname(dir) == root &&
        await Directory(dir).exists()) {
      await Directory(dir).delete(recursive: true);
    }
  }
}
