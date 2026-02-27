import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for download tracking.
class DownloadDAO {
  final Future<Isar> _db;

  const DownloadDAO(this._db);

  Future<void> putDownloadDB({
    required String fileName,
    required String filePath,
    required DateTime lastDownloaded,
    required MediaItemModel mediaItem,
    required Future<void> Function(MediaItemDB, String) addMediaItem,
  }) async {
    DownloadDB downloadDB = DownloadDB(
      fileName: fileName,
      filePath: filePath,
      lastDownloaded: lastDownloaded,
      mediaId: mediaItem.id,
    );
    Isar isarDB = await _db;
    DownloadDB? existing = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (existing != null) {
      existing.fileName = fileName;
      existing.filePath = filePath;
      existing.lastDownloaded = lastDownloaded;
      isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(existing));
      log("Updated DownloadDB for ${mediaItem.title}", name: "DB");
      return;
    }
    isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(downloadDB));
    await addMediaItem(
        mediaItemToMediaItemDB(mediaItem), SettingKeys.downloadPlaylist);
  }

  Future<void> removeDownloadDB(
    MediaItemModel mediaItem, {
    required Future<void> Function(MediaItemDB, MediaPlaylistDB)
        removeMediaItemFromPlaylist,
  }) async {
    Isar isarDB = await _db;
    DownloadDB? downloadDB = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (downloadDB != null) {
      isarDB.writeTxnSync(() => isarDB.downloadDBs.deleteSync(downloadDB.id!));
      await removeMediaItemFromPlaylist(mediaItemToMediaItemDB(mediaItem),
          MediaPlaylistDB(playlistName: SettingKeys.downloadPlaylist));
    }

    try {
      File file = File("${downloadDB!.filePath}/${downloadDB.fileName}");
      if (file.existsSync()) {
        file.deleteSync();
        log("File Deleted: ${downloadDB.fileName}", name: "DB");
      }
    } catch (e) {
      log("Failed to delete file: ${downloadDB!.fileName}",
          error: e, name: "DB");
    }
  }

  Future<DownloadDB?> getDownloadDB(MediaItemModel mediaItem) async {
    Isar isarDB = await _db;
    final temp = isarDB.downloadDBs
        .filter()
        .mediaIdEqualTo(mediaItem.id)
        .findFirstSync();
    if (temp != null &&
        File("${temp.filePath}/${temp.fileName}").existsSync()) {
      return temp;
    }
    return null;
  }

  Future<void> updateDownloadDB(DownloadDB downloadDB) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.downloadDBs.putSync(downloadDB));
  }

  Future<List<MediaItemModel>> getDownloadedSongs({
    required Future<void> Function(MediaItemModel) removeDownload,
  }) async {
    Isar isarDB = await _db;
    List<DownloadDB> downloadedSongs =
        isarDB.downloadDBs.where(sort: Sort.desc).findAllSync();
    downloadedSongs.sort((a, b) {
      final aDate = a.lastDownloaded;
      final bDate = b.lastDownloaded;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    List<MediaItemModel> mediaItems = List.empty(growable: true);
    for (var element in downloadedSongs) {
      if (File("${element.filePath}/${element.fileName}").existsSync()) {
        log("File exists", name: "DB");
        mediaItems.add(mediaItemDBToMediaItem(isarDB.mediaItemDBs
            .filter()
            .mediaIDEqualTo(element.mediaId)
            .findFirstSync()!));
      } else {
        log("File not exists ${element.fileName} ", name: "DB");
        removeDownload(mediaItemDBToMediaItem(isarDB.mediaItemDBs
            .filter()
            .mediaIDEqualTo(element.mediaId)
            .findFirstSync()!));
      }
    }
    return mediaItems;
  }
}
