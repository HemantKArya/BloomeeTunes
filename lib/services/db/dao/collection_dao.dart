import 'dart:convert';

import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/collection_mapper.dart';
import 'package:isar_community/isar.dart';

/// DAO for saved online collections (artists, albums, playlists).
class CollectionDAO {
  final Future<Isar> _db;

  const CollectionDAO(this._db);

  Future<void> putOnlArtistModel(ArtistModel artistModel) async {
    Isar isarDB = await _db;
    Map extra = Map.from(artistModel.extra);
    extra["country"] = artistModel.country;

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "artist",
          coverArt: artistModel.imageUrl,
          title: artistModel.name,
          subtitle: artistModel.description,
          source: artistModel.source,
          sourceId: artistModel.sourceId,
          sourceURL: artistModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  Future<void> putOnlAlbumModel(AlbumModel albumModel) async {
    Isar isarDB = await _db;
    Map extra = Map.from(albumModel.extra);
    extra.addEntries([MapEntry("country", albumModel.country)]);
    extra.addEntries([MapEntry("artists", albumModel.artists)]);
    extra.addEntries([MapEntry("genre", albumModel.genre)]);
    extra.addEntries([MapEntry("language", albumModel.language)]);
    extra.addEntries([MapEntry("year", albumModel.year)]);

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "album",
          coverArt: albumModel.imageURL,
          title: albumModel.name,
          subtitle: albumModel.description,
          source: albumModel.source,
          sourceId: albumModel.sourceId,
          sourceURL: albumModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  Future<void> putOnlPlaylistModel(PlaylistOnlModel playlistModel) async {
    Isar isarDB = await _db;
    Map extra = Map.from(playlistModel.extra);
    extra.addEntries([MapEntry("artists", playlistModel.artists)]);
    extra.addEntries([MapEntry("language", playlistModel.language)]);
    extra.addEntries([MapEntry("year", playlistModel.year)]);

    await isarDB.writeTxn(
      () => isarDB.savedCollectionsDBs.put(
        SavedCollectionsDB(
          type: "playlist",
          coverArt: playlistModel.imageURL,
          title: playlistModel.name,
          subtitle: playlistModel.description,
          source: playlistModel.source,
          sourceId: playlistModel.sourceId,
          sourceURL: playlistModel.sourceURL,
          lastUpdated: DateTime.now(),
          extra: jsonEncode(extra),
        ),
      ),
    );
  }

  Future<List> getSavedCollections() async {
    Isar isarDB = await _db;
    final savedCollections = isarDB.savedCollectionsDBs.where().findAllSync();
    List savedList = [];
    for (var element in savedCollections) {
      switch (element.type) {
        case "artist":
          savedList.add(formatSavedArtistOnl(element));
          break;
        case "album":
          savedList.add(formatSavedAlbumOnl(element));
          break;
        case "playlist":
          savedList.add(formatSavedPlaylistOnl(element));
          break;
        default:
          break;
      }
    }
    return savedList;
  }

  Future<void> removeFromSavedCollecs(String sourceID) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(
      () => isarDB.savedCollectionsDBs
          .filter()
          .sourceIdEqualTo(sourceID)
          .deleteAllSync(),
    );
  }

  Future<bool> isInSavedCollections(String sourceID) async {
    Isar isarDB = await _db;
    final item = isarDB.savedCollectionsDBs
        .filter()
        .sourceIdEqualTo(sourceID)
        .findFirstSync();
    return item != null;
  }

  Future<Stream<void>> getSavedCollecsWatcher() async {
    Isar isarDB = await _db;
    return isarDB.savedCollectionsDBs.watchLazy(fireImmediately: true);
  }
}
