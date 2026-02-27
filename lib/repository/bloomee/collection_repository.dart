import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/services/db/dao/collection_dao.dart';

/// Repository for saved online collections (artists, albums, playlists).
///
/// Wraps [CollectionDAO] and provides a typed interface for managing
/// the user's saved/followed online collections.
class CollectionRepository {
  final CollectionDAO _collectionDao;

  const CollectionRepository(this._collectionDao);

  // --------------- Save ---------------

  Future<void> saveArtist(ArtistModel artist) =>
      _collectionDao.putOnlArtistModel(artist);

  Future<void> saveAlbum(AlbumModel album) =>
      _collectionDao.putOnlAlbumModel(album);

  Future<void> savePlaylist(PlaylistOnlModel playlist) =>
      _collectionDao.putOnlPlaylistModel(playlist);

  // --------------- Query ---------------

  /// Returns a mixed list of [ArtistModel], [AlbumModel], and
  /// [PlaylistOnlModel] that the user has saved.
  Future<List> getSavedCollections() =>
      _collectionDao.getSavedCollections();

  Future<bool> isSaved(String sourceID) =>
      _collectionDao.isInSavedCollections(sourceID);

  // --------------- Remove ---------------

  Future<void> remove(String sourceID) =>
      _collectionDao.removeFromSavedCollecs(sourceID);

  // --------------- Watch ---------------

  Future<Stream<void>> watchCollections() =>
      _collectionDao.getSavedCollecsWatcher();
}
