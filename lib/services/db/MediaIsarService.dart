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
    print(_mediaPlaylistDB);

    if (_mediaPlaylistDB == null) {
      addPlaylist(mediaPlaylistDB);
    }

    if (_mediaitem != null) {
      print("1");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      print("2");
      isarDB.writeTxnSync(() => isarDB.mediaItemDBs.putSync(_mediaitem!));
    } else {
      print("3");
      MediaItemDB? _mediaitem = mediaItemDB;
      print("id: ${_mediaitem.id}");
      _mediaitem.mediaInPlaylistsDB.add(mediaPlaylistDB);
      print("4");
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
      print(mediaPlaylistDB.mediaRanks);
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
        print("Removed from playlist");
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
      print("Already created");
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
      String _path = (await getApplicationCacheDirectory()).path;
      print(_path);
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
      print("${mediaPlaylistDB.playlistName} is Deleted!!");
    }
  }
}
