import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';

/// Repository for playlist domain operations.
///
/// Wraps [PlaylistDAO] and provides high-level playlist orchestration
/// (CRUD, ordering, like, library queries).
class PlaylistRepository {
  final PlaylistDAO _playlistDao;

  const PlaylistRepository(this._playlistDao);

  // --------------- Playlist CRUD ---------------

  Future<int?> createPlaylist(
    String playlistName, {
    String? artURL,
    String? description,
    String? permaURL,
    String? source,
    String? artists,
    bool isAlbum = false,
    List<MediaItemDB> mediaItems = const [],
  }) =>
      _playlistDao.createPlaylist(playlistName,
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum,
          mediaItems: mediaItems);

  Future<MediaPlaylistDB?> getPlaylist(String playlistName) =>
      _playlistDao.getPlaylist(playlistName);

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) =>
      _playlistDao.removePlaylist(mediaPlaylistDB);

  Future<void> removePlaylistByName(String playlistName) =>
      _playlistDao.removePlaylistByName(playlistName);

  // --------------- Items ---------------

  Future<int?> addMediaItem(MediaItemDB mediaItemDB, String playlistName) =>
      _playlistDao.addMediaItem(mediaItemDB, playlistName);

  Future<void> removeMediaItemFromPlaylist(
          MediaItemDB mediaItemDB, MediaPlaylistDB playlistDB) =>
      _playlistDao.removeMediaItemFromPlaylist(mediaItemDB, playlistDB);

  Future<List<MediaItemDB>?> getPlaylistItems(
          MediaPlaylistDB mediaPlaylistDB) =>
      _playlistDao.getPlaylistItems(mediaPlaylistDB);

  Future<List<MediaItemDB>?> getPlaylistItemsByName(String playlistName) =>
      _playlistDao.getPlaylistItemsByName(playlistName);

  Future<List<String>> getPlaylistsContainingSong(String mediaId) =>
      _playlistDao.getPlaylistsContainingSong(mediaId);

  // --------------- Ordering ---------------

  Future<List<int>> getPlaylistItemsRank(MediaPlaylistDB mediaPlaylistDB) =>
      _playlistDao.getPlaylistItemsRank(mediaPlaylistDB);

  Future<List<int>> getPlaylistItemsRankByName(String playlistName) =>
      _playlistDao.getPlaylistItemsRankByName(playlistName);

  Future<void> setPlaylistItemsRank(
          MediaPlaylistDB mediaPlaylistDB, List<int> rankList) =>
      _playlistDao.setPlaylistItemsRank(mediaPlaylistDB, rankList);

  Future<void> updatePltItemsRankByName(
          String playlistName, List<int> rankList) =>
      _playlistDao.updatePltItemsRankByName(playlistName, rankList);

  Future<void> reorderItemPositionInPlaylist(
          MediaPlaylistDB mediaPlaylistDB, int oldIdx, int newIdx) =>
      _playlistDao.reorderItemPositionInPlaylist(
          mediaPlaylistDB, oldIdx, newIdx);

  // --------------- Library ---------------

  Future<List<MediaPlaylist>> getPlaylists4Library() =>
      _playlistDao.getPlaylists4Library();

  Future<Stream<void>> getPlaylistsWatcher() =>
      _playlistDao.getPlaylistsWatcher();

  Future<Stream<void>> getPlaylistWatcher(MediaPlaylistDB mediaPlaylistDB) =>
      _playlistDao.getPlaylistWatcher(mediaPlaylistDB);

  Future<Stream> getStream4MediaList(MediaPlaylistDB mediaPlaylistDB) =>
      _playlistDao.getStream4MediaList(mediaPlaylistDB);

  // --------------- Playlist Info ---------------

  Future<int?> createPlaylistInfo(String playlistName,
          {String? artURL,
          String? description,
          String? permaURL,
          String? source,
          String? artists,
          bool isAlbum = false}) =>
      _playlistDao.createPlaylistInfo(playlistName,
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum);

  Future<int> addPlaylistInfo(PlaylistsInfoDB playlistInfoDB) =>
      _playlistDao.addPlaylistInfo(playlistInfoDB);

  Future<void> updatePlaylistInfo(PlaylistsInfoDB playlistsInfoDB) =>
      _playlistDao.updatePlaylistInfo(playlistsInfoDB);

  Future<PlaylistsInfoDB?> getPlaylistInfo(String playlistName) =>
      _playlistDao.getPlaylistInfo(playlistName);

  Future<List<PlaylistsInfoDB>> getPlaylistsInfo() =>
      _playlistDao.getPlaylistsInfo();

  Future<void> removePlaylistInfoByName(String playlistName) =>
      _playlistDao.removePlaylistInfoByName(playlistName);

  // --------------- Like ---------------

  Future<void> likeMediaItem(MediaItemDB mediaItemDB, {bool isLiked = false}) =>
      _playlistDao.likeMediaItem(mediaItemDB, isLiked: isLiked);

  Future<bool> isMediaLiked(MediaItemDB mediaItemDB) =>
      _playlistDao.isMediaLiked(mediaItemDB);

  // --------------- Search in library ---------------

  Future<List<(MediaItemModel, String)>> searchMediaItemsInLibrary(
          String query) =>
      _playlistDao.searchMediaItemsInLibrary(query);

  // --------------- Purge ---------------

  Future<void> purgeUnassociatedMediaItems() =>
      _playlistDao.purgeUnassociatedMediaItems();
}
