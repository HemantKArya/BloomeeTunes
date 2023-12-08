import 'dart:developer';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Bloomee/services/db/MediaDB.dart';

class MediaIsarDBService {
  late Future<Isar> db;

  MediaIsarDBService() {
    db = openDB();
  }

  Future<void> addMediaItem(
      MediaItemDB mediaItemDB, MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    MediaItemDB? _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();
    log(_mediaPlaylistDB.toString(), name: "DB");

    if (_mediaPlaylistDB == null) {
      addPlaylist(mediaPlaylistDB);
    }

    if (_mediaitem != null) {
      log("1", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      log("2", name: "DB");
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem!));
    } else {
      log("3", name: "DB");
      MediaItemDB? _mediaitem = mediaItemDB;
      log("id: ${_mediaitem.id}", name: "DB");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      log("4", name: "DB");
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem));
    }
    _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (_mediaitem?.mediaInPlaylistsDB != null &&
        !(_mediaPlaylistDB?.mediaRanks.contains(_mediaitem!.id) ?? false)) {
      mediaPlaylistDB = _mediaitem!.mediaInPlaylistsDB
          .filter()
          .isarIdEqualTo(mediaPlaylistDB.isarId)
          .findFirstSync()!;

      List<int> _list = mediaPlaylistDB.mediaRanks.toList(growable: true);
      _list.add(_mediaitem.id!);
      mediaPlaylistDB.mediaRanks = _list;
      isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
      log(mediaPlaylistDB.mediaRanks.toString(), name: "DB");
    }

    // isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(mediaItemDB));
  }

  Future<void> removeMediaItem(
      MediaItemDB mediaItemDB, MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    MediaItemDB? _mediaitem = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();

    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaitem != null && _mediaPlaylistDB != null) {
      if (_mediaitem.mediaInPlaylistsDB.contains(mediaPlaylistDB)) {
        _mediaitem.mediaInPlaylistsDB.remove(mediaPlaylistDB);
        log("Removed from playlist", name: "DB");
        isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem));
        if (_mediaPlaylistDB.mediaRanks.contains(_mediaitem.id)) {
          // _mediaPlaylistDB.mediaRanks.indexOf(_mediaitem.id!)

          List<int> _list = _mediaPlaylistDB.mediaRanks.toList(growable: true);
          _list.remove(_mediaitem.id);
          _mediaPlaylistDB.mediaRanks = _list;
          isarDB.writeTxnSync(
              () => isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB));
        }
      }
    }

    // isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(mediaItemDB));
  }

  Future<void> addPlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylist = isarDB.mediaPlaylistDBs
        .filter()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylist == null) {
      isarDB
          .writeTxnSync(() => isarDB.mediaPlaylistDBs.putSync(mediaPlaylistDB));
    } else {
      log("Already created", name: "DB");
    }
  }

  Future<void> likeMediaItem(MediaItemDB mediaItemDB, {isLiked = false}) async {
    Isar isarDB = await db;
    addPlaylist(MediaPlaylistDB(playlistName: "Liked"));
    MediaItemDB? _mediaItem = isarDB.mediaItemDBs
        .filter()
        .titleEqualTo(mediaItemDB.title)
        .and()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (isLiked && _mediaItem != null) {
      addMediaItem(mediaItemDB, MediaPlaylistDB(playlistName: "Liked"));
    } else if (_mediaItem != null) {
      removeMediaItem(mediaItemDB, MediaPlaylistDB(playlistName: "Liked"));
    }
  }

  Future<void> reorderItemPositionInPlaylist(
      MediaPlaylistDB mediaPlaylistDB, int old_idx, int new_idx) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylistDB = isarDB.mediaPlaylistDBs
        .where()
        .isarIdEqualTo(mediaPlaylistDB.isarId)
        .findFirstSync();

    if (_mediaPlaylistDB != null) {
      if (_mediaPlaylistDB.mediaRanks.length > old_idx &&
          _mediaPlaylistDB.mediaRanks.length > new_idx) {
        List<int> _rankList =
            _mediaPlaylistDB.mediaRanks.toList(growable: true);
        int _element = (_rankList.removeAt(old_idx));
        _rankList.insert(new_idx, _element);
        _mediaPlaylistDB.mediaRanks = _rankList;
        isarDB.writeTxnSync(
            () => isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB));
      }
    }
  }

  Future<bool> isMediaLiked(MediaItemDB mediaItemDB) async {
    Isar isarDB = await db;
    MediaItemDB? _mediaItemDB = isarDB.mediaItemDBs
        .filter()
        .permaURLEqualTo(mediaItemDB.permaURL)
        .findFirstSync();
    if (_mediaItemDB != null) {
      return (isarDB.mediaPlaylistDBs
                  .getSync(MediaPlaylistDB(playlistName: "Liked").isarId))
              ?.mediaItems
              .contains(_mediaItemDB) ??
          true;
    } else {
      return false;
    }
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      String _path = (await getApplicationDocumentsDirectory()).path;
      log(_path, name: "DB");
      return await Isar.open([MediaPlaylistDBSchema, MediaItemDBSchema],
          directory: _path);
    }
    return Future.value(Isar.getInstance());
  }

  Future<Stream> getStream4MediaList(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs.watchObject(mediaPlaylistDB.isarId);
  }

  Future<List<int>> getPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs
            .getSync(mediaPlaylistDB.isarId)
            ?.mediaRanks
            .toList() ??
        [];
  }

  Future<void> setPlaylistItemsRank(
      MediaPlaylistDB mediaPlaylistDB, List<int> rankList) async {
    Isar isarDB = await db;
    MediaPlaylistDB? _mediaPlaylistDB =
        isarDB.mediaPlaylistDBs.getSync(mediaPlaylistDB.isarId);
    if (_mediaPlaylistDB != null &&
        _mediaPlaylistDB.mediaItems.length >= rankList.length) {
      isarDB.writeTxnSync(() {
        _mediaPlaylistDB.mediaRanks = rankList;
        isarDB.mediaPlaylistDBs.putSync(_mediaPlaylistDB);
      });
    }
  }

  Future<List<MediaItemDB>?> getPlaylistItems(
      MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    return isarDB.mediaPlaylistDBs
        .getSync(mediaPlaylistDB.isarId)
        ?.mediaItems
        .toList();
  }

  Future<List<MediaPlaylistDB>> getPlaylists4Library() async {
    Isar isarDB = await db;
    return await isarDB.mediaPlaylistDBs.where().findAll();
  }

  Future<void> removePlaylist(MediaPlaylistDB mediaPlaylistDB) async {
    Isar isarDB = await db;
    bool _res = false;
    isarDB.writeTxnSync(() =>
        _res = isarDB.mediaPlaylistDBs.deleteSync(mediaPlaylistDB.isarId));
    if (_res) {
      log("${mediaPlaylistDB.playlistName} is Deleted!!", name: "DB");
    }
  }
}
