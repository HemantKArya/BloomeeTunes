import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';

/// Repository for playback history — orchestrates [HistoryDAO] with
/// cross-DAO callbacks for playlist management and settings reads.
///
/// Resolves cross-DAO dependencies by accepting [PlaylistDAO] and
/// [SettingsDAO] for the callback-based operations in [HistoryDAO].
class HistoryRepository {
  final HistoryDAO _historyDao;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;

  const HistoryRepository(
    this._historyDao,
    this._playlistDao,
    this._settingsDao,
  );

  /// Records a media item as recently played.
  Future<void> recordPlay(MediaItemDB mediaItemDB) =>
      _historyDao.putRecentlyPlayed(
        mediaItemDB,
        addMediaItem: _playlistDao.addMediaItem,
      );

  /// Removes entries older than the configured retention period.
  Future<void> refreshHistory() => _historyDao.refreshRecentlyPlayed(
        getSettingStr: _settingsDao.getSettingStr,
        removeMediaItemFromPlaylist: _playlistDao.removeMediaItemFromPlaylist,
      );

  /// Returns recently played items, optionally limited.
  Future<MediaPlaylist> getRecentlyPlayed({int limit = 0}) =>
      _historyDao.getRecentlyPlayed(limit: limit);

  /// Watches the recently-played collection for changes.
  Future<Stream<void>> watchRecentlyPlayed() =>
      _historyDao.watchRecentlyPlayed();
}
