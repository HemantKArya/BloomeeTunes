import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show Rect;
import 'dart:convert';
import 'dart:math';

import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Platform document transport. URIs returned by mobile Save As are opaque.
class BackupFiles {
  bool get canShareFiles => !Platform.isLinux;
  final Set<String> _ownedStaging = {};
  Future<String?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withReadStream: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    if (picked.size > BackupDocument.maxBytes * 8) {
      throw const FormatException('Selected file is too large.');
    }
    final dir = await Directory((await getTemporaryDirectory()).path)
        .createTemp('bloomee_import_');
    final target = File(p.join(dir.path, safeName(picked.name)));
    _ownedStaging.add(dir.path);
    try {
      final stream = picked.readStream ??
          (picked.path == null ? null : File(picked.path!).openRead());
      if (stream == null) {
        throw const FileSystemException(
            'The document provider did not provide a readable file.');
      }
      var count = 0;
      final sink = target.openWrite();
      try {
        await sink.addStream(stream.map((chunk) {
          count += chunk.length;
          if (count > BackupDocument.maxBytes * 8) {
            throw const FormatException('Selected file is too large.');
          }
          return chunk;
        }));
      } finally {
        await sink.close();
      }
      return target.path;
    } catch (_) {
      _ownedStaging.remove(dir.path);
      await dir.delete(recursive: true);
      rethrow;
    }
  }

  Future<String?> save(String source) async {
    final file = File(source);
    final destination = await FilePicker.platform.saveFile(
      fileName: p.basename(source), type: FileType.custom,
      allowedExtensions: const ['json'],
      // The installed picker writes these bytes using SAF/UIDocumentPicker.
      bytes: Platform.isAndroid || Platform.isIOS
          ? await file.readAsBytes()
          : null,
    );
    if (destination == null) return null;
    if (!(Platform.isAndroid || Platform.isIOS)) {
      if (p.equals(p.absolute(source), p.absolute(destination))) {
        return destination;
      }
      final pending = File(
          '$destination.bloomee_${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}.partial');
      try {
        await file.copy(pending.path);
        final handle = await pending.open(mode: FileMode.append);
        try {
          await handle.flush();
        } finally {
          await handle.close();
        }
        await pending.rename(destination);
      } finally {
        if (await pending.exists()) await pending.delete();
      }
    }
    return destination;
  }

  Future<void> share(String source, {Rect? origin}) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(source, mimeType: 'application/json')],
      subject: 'Bloomee backup',
      sharePositionOrigin: origin,
    ));
  }

  static String safeName(String name) {
    final cleaned =
        p.basename(name).replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
    if (utf8.encode(cleaned).length > 160) {
      final suffix = p.extension(cleaned);
      final extension = suffix.length <= 16 ? suffix : '';
      final prefix = StringBuffer();
      var bytes = utf8.encode(extension).length;
      for (final rune in p.withoutExtension(cleaned).runes) {
        final character = String.fromCharCode(rune);
        bytes += utf8.encode(character).length;
        if (bytes > 160) break;
        prefix.write(character);
      }
      return '$prefix$extension';
    }
    return cleaned.isEmpty || cleaned == '.' || cleaned == '..'
        ? 'bloomee.json'
        : cleaned;
  }

  static Future<BackupDocument> readJson(String path) => Isolate.run(() async {
        final file = File(path);
        if (await file.length() > BackupDocument.maxBytes) {
          throw const FormatException('JSON exceeds the 32 MB import limit.');
        }
        return BackupDocument.decode(await file.readAsString());
      });

  /// Only delete staging directories owned by this transport, never user files.
  Future<String?> deliveryId(String path) async {
    final dir = File(path).parent;
    final root = (await getTemporaryDirectory()).path;
    if (p.isWithin(root, dir.path) &&
        p.basename(dir.path).startsWith('bloomee_import_') &&
        await File(p.join(dir.path, '.pending')).exists()) {
      return p.basename(dir.path);
    }
    return null;
  }

  Future<void> release(String path) async {
    final root = p.normalize((await getTemporaryDirectory()).path);
    final dir = File(path).parent;
    if (p.isWithin(root, dir.path) &&
        p.basename(dir.path).startsWith('bloomee_import_') &&
        (_ownedStaging.remove(dir.path) ||
            await File(p.join(dir.path, '.pending')).exists())) {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  }
}
