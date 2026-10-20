import 'package:Bloomee/core/models/backup/backup_document.dart';

enum RecoveryReason { automatic, beforeImport, beforeReset }

class RecoveryCopy {
  final String path;
  final DateTime createdAt;
  final RecoveryReason reason;
  const RecoveryCopy(
      {required this.path, required this.createdAt, required this.reason});
}

class LibraryRecoverySource {
  final String path;
  final DateTime modified;
  final int bytes;
  const LibraryRecoverySource(this.path, this.modified, this.bytes);
}

/// Device-local mapping, never accepted from a portable JSON document.
class RecoveredDownload {
  final String mediaId;
  final String fileName;
  final String filePath;
  final DateTime? lastDownloaded;
  const RecoveredDownload(
      {required this.mediaId,
      required this.fileName,
      required this.filePath,
      this.lastDownloaded});
}

class LibraryRecoveryPlan {
  final BackupDocument document;
  final List<RecoveredDownload> downloads;
  final int unavailableFiles;
  final int brokenEntries;
  LibraryRecoveryPlan(
      {required this.document,
      required List<RecoveredDownload> downloads,
      this.unavailableFiles = 0,
      this.brokenEntries = 0})
      : downloads = List.unmodifiable(downloads);
}
