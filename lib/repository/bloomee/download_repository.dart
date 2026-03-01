import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';

/// Repository for download operations — orchestrates [DownloadDAO]
/// with cross-DAO callbacks for playlist management.
///
/// Resolves the cross-DAO dependency by providing playlist operations
/// via the injected [PlaylistDAO].
class DownloadRepository {
  final DownloadDAO _downloadDao;
  final PlaylistDAO _playlistDao;

  const DownloadRepository(this._downloadDao, this._playlistDao);

  Future<void> saveDownload({
    required String fileName,
    required String filePath,
    required DateTime lastDownloaded,
    required MediaItemModel mediaItem,
  }) =>
      _downloadDao.putDownloadDB(
        fileName: fileName,
        filePath: filePath,
        lastDownloaded: lastDownloaded,
        mediaItem: mediaItem,
        addMediaItem: _playlistDao.addMediaItem,
      );

  Future<void> removeDownload(MediaItemModel mediaItem) =>
      _downloadDao.removeDownloadDB(
        mediaItem,
        removeMediaItemFromPlaylist: _playlistDao.removeMediaItemFromPlaylist,
      );

  Future<DownloadDB?> getDownload(MediaItemModel mediaItem) =>
      _downloadDao.getDownloadDB(mediaItem);

  Future<void> updateDownload(DownloadDB downloadDB) =>
      _downloadDao.updateDownloadDB(downloadDB);

  Future<List<MediaItemModel>> getDownloadedSongs() =>
      _downloadDao.getDownloadedSongs(
        removeDownload: (mediaItem) => removeDownload(mediaItem),
      );
}
