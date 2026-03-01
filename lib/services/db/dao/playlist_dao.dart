import 'dart:developer';

import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for playlist + playlist-info CRUD and ordering.
class PlaylistDAO {
  final Future<Isar> _db;

  const PlaylistDAO(this._db);

  // --------------- Playlist CRUD ---------------

  Future<int?> addPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    int? id;
    if (mediaPlaylistDB.playlistName.isEmpty) return null;

    MediaPlaylistDB? existing = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (existing == null) {
      id = isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
    } else {
      log("Already created", name: "DB");
      id = existing.isarId;
    }
    return id;
  }

  Future<int?> createPlaylist(
    String playlistName, {
    String? artURL,
    String? description,
    String? permaURL,
    String? source,
    String? artists,
    bool isAlbum = false,
    List<MediaItemDB> mediaItems = const [],
  }) async {
    if (playlistName.isEmpty) return null;

    int? id;
    MediaPlaylistDB mediaPlaylistDB = MediaPlaylistDB(
      playlistName: playlistName,
      lastUpdated: DateTime.now(),
    );
    id = await addPlaylist(mediaPlaylistDB);
    if (id != null) {
      if (mediaItems.isNotEmpty) {
        for (var element in mediaItems) {
          await addMediaItem(element, playlistName);
        }
      }
      if (artURL != null ||
          description != null ||
          permaURL != null ||
          source != null ||
          artists != null ||
          isAlbum) {
        await createPlaylistInfo(
          playlistName,
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum,
        );
      }
      log("Playlist Created: $playlistName", name: "DB");
    }
    return id;
  }

  Future<MediaPlaylistDB?> getPlaylist(String playlistName) async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    bool res = false;

    MediaPlaylistDB? existing = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    if (existing != null) {
      final mediaItems = existing.mediaItems.map((e) => e).toList();
      isarDB.writeTxnSync(() =>
          res = isarDB.mediaPlaylistDBs.deleteSync(mediaPlaylistDB.isarId));
      if (res) {
        await purgeUnassociatedMediaFromList(mediaItems);
        await removePlaylistByName(mediaPlaylistDB.playlistName);
        log("${mediaPlaylistDB.playlistName} is Deleted!!", name: "DB");
      }
    }
  }

  Future<void> removePlaylistByName(String playlistName) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    if (mediaPlaylistDB != null) {
      await removePlaylist(mediaPlaylistDB);
    }
  }

  // --------------- Playlist item ordering ---------------

  Future<List<int>> getPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs
            .getSync(mediaPlaylistDB.isarId)
            ?.mediaRanks
            .toList() ??
        [];
  }

  Future<List<int>> getPlaylistItemsRankByName(String playlistName) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    return mediaPlaylistDB?.mediaRanks.toList() ?? [];
  }

  Future<void> setPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? existing =
        isarDB.mediaPlaylistDBs.getSync(mediaPlaylistDB.isarId);
    if (existing != null && existing.mediaItems.length >= rankList.length) {
      isarDB.writeTxnSync(() {
        existing.mediaRanks = rankList;
        isarDB.mediaPlaylistDBs.putSync(existing);
      });
    }
  }

  Future<void> updatePltItemsRankByName(
      String playlistName, List<int> rankList) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    if (mediaPlaylistDB != null &&
        mediaPlaylistDB.mediaItems.length >= rankList.length) {
      isarDB.writeTxnSync(() {
        mediaPlaylistDB.mediaRanks = rankList;
        isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB);
      });
    }
  }

  Future<void> reorderItemPositionInPlaylist(
      MediaPlaylistDB mediaPlaylistDB, int oldIdx, int newIdx) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? existing = isarDB.mediaPlaylistDBs
        .where()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (existing != null) {
      if (existing.mediaRanks.length > oldIdx &&
          existing.mediaRanks.length > newIdx) {
        List<int> rankList = existing.mediaRanks.toList(growable: true);
        int element = rankList.removeAt(oldIdx);
        rankList.insert(newIdx, element);
        existing.mediaRanks = rankList;
        isarDB.writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(existing));
      }
    }
  }

  // --------------- Playlist items ---------------

  Future<List<MediaItemDB>?> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs
        .getSync(mediaPlaylistDB.isarId)
        ?.mediaItems
        .toList();
  }

  Future<List<MediaItemDB>?> getPlaylistItemsByName(String playlistName) async {
    Isar isarDB = await _db;
    MediaPlaylistDB? mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
    return mediaPlaylistDB?.mediaItems.toList();
  }

  Future<List<String>> getPlaylistsContainingSong(String mediaId) async {
    Isar isarDB = await _db;
    MediaItemDB? mediaItem =
        isarDB.mediaItemDBs.filter().mediaIDEqualTo(mediaId).findFirstSync();
    if (mediaItem == null) return [];
    final playlists = mediaItem.mediaInPlaylistsDB.toList();
    return playlists.map((p) => p.playlistName).toList();
  }

  Future<List<MediaPlaylist>> getPlaylists4Library() async {
    Isar isarDB = await _db;
    final playlists = await isarDB.mediaPlaylistDBs.where().findAll();
    List<MediaPlaylist> mediaPlaylists = [];
    for (var e in playlists) {
      PlaylistsInfoDB? info = await getPlaylistInfo(e.playlistName);
      mediaPlaylists.add(playlistDBToMediaPlaylist(e, playlistsInfoDB: info));
    }
    return mediaPlaylists;
  }

  Future<Stream<void>> getPlaylistsWatcher() async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs.watchLazy(fireImmediately: true);
  }

  Future<Stream<void>> getPlaylistWatcher(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs.watchObject(mediaPlaylistDB.isarId);
  }

  Future<Stream> getStream4MediaList(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    return isarDB.mediaPlaylistDBs.watchObject(mediaPlaylistDB.isarId);
  }

  // --------------- Playlist info ---------------

  Future<int?> createPlaylistInfo(
    String playlistName, {
    String? artURL,
    String? description,
    String? permaURL,
    String? source,
    String? artists,
    bool isAlbum = false,
  }) async {
    if (playlistName.isNotEmpty) {
      return await addPlaylistInfo(
        PlaylistsInfoDB(
          playlistName: playlistName,
          lastUpdated: DateTime.now(),
          artURL: artURL,
          description: description,
          permaURL: permaURL,
          source: source,
          artists: artists,
          isAlbum: isAlbum,
        ),
      );
    }
    return null;
  }

  Future<int> addPlaylistInfo(PlaylistsInfoDB playlistInfoDB) async {
    Isar isarDB = await _db;
    return isarDB
        .writeTxnSync(() => isarDB.playlistsInfoDBs.putSync(playlistInfoDB));
  }

  Future<void> updatePlaylistInfo(PlaylistsInfoDB playlistsInfoDB) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(() => isarDB.playlistsInfoDBs.putSync(playlistsInfoDB));
  }

  Future<void> removePlaylistInfo(PlaylistsInfoDB playlistsInfoDB) async {
    Isar isarDB = await _db;
    isarDB.writeTxnSync(
        () => isarDB.playlistsInfoDBs.deleteSync(playlistsInfoDB.isarId));
  }

  Future<PlaylistsInfoDB?> getPlaylistInfo(String playlistName) async {
    Isar isarDB = await _db;
    return isarDB.playlistsInfoDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .findFirstSync();
  }

  Future<List<PlaylistsInfoDB>> getPlaylistsInfo() async {
    Isar isarDB = await _db;
    return isarDB.playlistsInfoDBs.where().findAllSync();
  }

  Future<void> removePlaylistInfoByName(String playlistName) async {
    Isar isarDB = await _db;
    int c = isarDB.writeTxnSync(() => isarDB.playlistsInfoDBs
        .filter()
        .playlistNameEqualTo(playlistName)
        .deleteAllSync());
    log("$c items deleted", name: "DB");
  }

  // --------------- Media-item helpers used by playlist ops ---------------

  Future<int?> addMediaItem(
      MediaItemDB mediaItemDB, String playlistName) async {
    int? id;
    Isar isarDB = await _db;
    MediaPlaylistDB mediaPlaylistDB =
        MediaPlaylistDB(playlistName: playlistName);

    MediaItemDB? existingItem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();

    MediaPlaylistDB? existingPlaylist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    log(existingPlaylist.toString(), name: "DB");

    if (existingPlaylist == null) {
      final tmpId = await createPlaylist(playlistName);
      existingPlaylist = isarDB.mediaPlaylistDBs
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync();
      log("${existingPlaylist.toString()} ID: $tmpId", name: "DB");
    }

    if (existingItem != null) {
      existingItem.mediaInPlaylistsDB.add(existingPlaylist!);
      id = existingItem.id;
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(existingItem!));
    } else {
      existingItem = mediaItemDB;
      log("id: ${existingItem.id}", name: "DB");
      existingItem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      isarDB
          .writeTxnSync(() => id = isarDB.mediaItemDBs.putSync(existingItem!));
    }

    if (!(existingPlaylist?.mediaRanks.contains(existingItem.id) ?? false)) {
      mediaPlaylistDB = existingItem.mediaInPlaylistsDB
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync()!;

      List<int> list = mediaPlaylistDB.mediaRanks.toList(growable: true);
      list.add(existingItem.id!);
      mediaPlaylistDB.mediaRanks = list;
      isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
      log(mediaPlaylistDB.mediaRanks.toString(), name: "DB");
    }

    return id;
  }

  Future<void> removeMediaItemFromPlaylist(
      MediaItemDB mediaItemDB, MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await _db;
    MediaItemDB? item = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();

    MediaPlaylistDB? playlist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (item != null && playlist != null) {
      if (item.mediaInPlaylistsDB.contains(mediaPlaylistDB)) {
        item.mediaInPlaylistsDB.remove(mediaPlaylistDB);
        log("Removed from playlist", name: "DB");
        isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(item));
        if (item.mediaInPlaylistsDB.isEmpty) {
          await removeMediaItem(item);
        }
        if (playlist.mediaRanks.contains(item.id)) {
          List<int> list = playlist.mediaRanks.toList(growable: true);
          list.remove(item.id);
          playlist.mediaRanks = list;
          isarDB.writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(playlist));
        }
      }
    } else {
      log("MediaItem or MediaPlaylist is null", name: "DB");
      if (item != null) {
        await purgeUnassociatedMediaItem(item);
      }
    }
  }

  Future<void> removeMediaItem(MediaItemDB mediaItemDB) async {
    Isar isarDB = await _db;
    bool res = false;
    await isarDB.writeTxn(
        () async => res = await isarDB.mediaItemDBs.delete(mediaItemDB.id!));
    if (res) {
      log("${mediaItemDB.title} is Deleted!!", name: "DB");
    }
  }

  Future<void> purgeUnassociatedMediaItem(MediaItemDB mediaItemDB) async {
    if (mediaItemDB.mediaInPlaylistsDB.isEmpty) {
      log("Purging ${mediaItemDB.title}", name: "DB");
      await removeMediaItem(mediaItemDB);
    }
  }

  Future<void> purgeUnassociatedMediaItems() async {
    Isar isarDB = await _db;
    List<MediaItemDB> mediaItems = isarDB.mediaItemDBs.where().findAllSync();
    for (var element in mediaItems) {
      await purgeUnassociatedMediaItem(element);
    }
  }

  Future<void> purgeUnassociatedMediaFromList(
      List<MediaItemDB> mediaItems) async {
    for (var element in mediaItems) {
      await purgeUnassociatedMediaItem(element);
    }
  }

  // --------------- Like helpers ---------------

  Future<void> likeMediaItem(MediaItemDB mediaItemDB, {isLiked = false}) async {
    Isar isarDB = await _db;
    addPlaylist(MediaPlaylistDB(playlistName: "Liked"));
    MediaItemDB? item = isarDB.mediaItemDBs
        .filter()
        .titleEqualTo(mediaItemDB.title)
        .and()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (isLiked && item != null) {
      addMediaItem(mediaItemDB, "Liked");
    } else if (item != null) {
      removeMediaItemFromPlaylist(
          mediaItemDB, MediaPlaylistDB(playlistName: "Liked"));
    }
  }

  Future<bool> isMediaLiked(MediaItemDB mediaItemDB) async {
    Isar isarDB = await _db;
    MediaItemDB? item = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (item != null) {
      return (isarDB.mediaPlaylistDBs
                  .getSync(MediaPlaylistDB(playlistName: "Liked").isarId))
              ?.mediaItems
              .contains(item) ??
          true;
    } else {
      return false;
    }
  }

  // --------------- Search in library ---------------

  /// Convenience: build a full [MediaPlaylist] from a playlist name,
  /// including rank-based reordering (mirrors old BloomeeDBCubit.getPlaylistItems).
  Future<MediaPlaylist> getMediaPlaylist(String playlistName) async {
    final playlistDB = MediaPlaylistDB(playlistName: playlistName);
    MediaPlaylist result =
        MediaPlaylist(mediaItems: [], playlistName: playlistName);

    final existing = await getPlaylist(playlistName);
    final info = await getPlaylistInfo(playlistName);
    if (existing != null) {
      result = playlistDBToMediaPlaylist(playlistDB, playlistsInfoDB: info);

      var items = await getPlaylistItems(playlistDB);
      if (items != null) {
        List<int> rankList = await getPlaylistItemsRank(playlistDB);
        if (rankList.isNotEmpty) {
          items = _reorderByRank(items, rankList);
        }
        result.mediaItems.clear();
        for (var element in items) {
          result.mediaItems.add(mediaItemDBToMediaItem(element));
        }
      }
    }
    return result;
  }

  /// Reorder [orgMediaList] according to [rankIndex] (list of IDs in desired order).
  static List<MediaItemDB> _reorderByRank(
      List<MediaItemDB> orgMediaList, List<int> rankIndex) {
    if (orgMediaList.isEmpty || rankIndex.isEmpty) return orgMediaList;
    if (rankIndex.length != orgMediaList.length) return orgMediaList;
    try {
      final mediaMap = {for (var item in orgMediaList) item.id: item};
      return rankIndex.map((id) {
        if (!mediaMap.containsKey(id)) {
          throw StateError('ID $id not found in orgMediaList.');
        }
        return mediaMap[id]!;
      }).toList();
    } catch (e) {
      log('Error during reordering: $e', name: 'PlaylistDAO');
      return orgMediaList;
    }
  }

  Future<List<(MediaItemModel, String)>> searchMediaItemsInLibrary(
      String query) async {
    if (query.trim().isEmpty) return [];

    Isar isarDB = await _db;
    final lowerQuery = query.toLowerCase();

    final matchingItems = await isarDB.mediaItemDBs
        .filter()
        .group((q) => q
            .titleContains(lowerQuery, caseSensitive: false)
            .or()
            .artistContains(lowerQuery, caseSensitive: false))
        .findAll();

    List<(MediaItemModel, String)> results = [];
    for (final item in matchingItems) {
      await item.mediaInPlaylistsDB.load();
      final playlists = item.mediaInPlaylistsDB.toList();
      if (playlists.isNotEmpty) {
        for (final playlist in playlists) {
          if (playlist.playlistName != 'recently_played' &&
              playlist.playlistName != '_DOWNLOADS') {
            results.add((mediaItemDBToMediaItem(item), playlist.playlistName));
            break;
          }
        }
      }
    }
    return results;
  }
}
