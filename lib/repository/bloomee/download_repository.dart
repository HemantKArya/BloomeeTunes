import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';

/// Repository for download operations — wraps [DownloadDAO].
class DownloadRepository {
  final DownloadDAO _downloadDao;

  const DownloadRepository(this._downloadDao);

  Future<void> saveDownload({
    required String fileName,
    required String filePath,
    required DateTime lastDownloaded,
    required Track track,
  }) =>
      _downloadDao.putDownload(
        fileName: fileName,
        filePath: filePath,
        track: track,
        lastDownloaded: lastDownloaded,
      );

  Future<void> removeDownload(String mediaId) =>
      _downloadDao.removeDownload(mediaId);

  Future<DownloadDB?> getDownload(String mediaId) =>
      _downloadDao.getDownloadRecord(mediaId);

  Future<void> updateDownload(DownloadDB downloadDB) =>
      _downloadDao.updateDownloadRecord(downloadDB);

  Future<List<DownloadDB>> getDownloadedSongs() =>
      _downloadDao.getValidDownloads();

  Future<List<Track>> getDownloadedTracks() =>
      _downloadDao.getValidDownloadedTracks();

  Future<bool> isDownloaded(String mediaId) =>
      _downloadDao.isDownloaded(mediaId);
}
