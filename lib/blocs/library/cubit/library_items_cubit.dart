// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/album_onl_model.dart';
import 'package:Bloomee/core/models/artist_onl_model.dart';
import 'package:Bloomee/core/models/playlist_onl_model.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/dao/collection_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  StreamSubscription? playlistWatcherDB;
  StreamSubscription? savedCollecsWatcherDB;
  final PlaylistDAO _playlistDao;
  final CollectionDAO _collectionDao;

  LibraryItemsCubit({
    required PlaylistDAO playlistDao,
    required CollectionDAO collectionDao,
  })  : _playlistDao = playlistDao,
        _collectionDao = collectionDao,
        super(LibraryItemsLoading()) {
    // Start with a loading state
    _initialize();
  }

  @override
  Future<void> close() {
    playlistWatcherDB?.cancel();
    savedCollecsWatcherDB?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    // Initial fetch
    await Future.wait([
      getAndEmitPlaylists(),
      getAndEmitSavedOnlCollections(),
    ]);

    // Setup watchers for subsequent updates
    _getDBWatchers();
  }

  Future<void> _getDBWatchers() async {
    playlistWatcherDB = (await _playlistDao.getPlaylistsWatcher()).listen((_) {
      getAndEmitPlaylists();
    });
    savedCollecsWatcherDB =
        (await _collectionDao.getSavedCollecsWatcher()).listen((_) {
      getAndEmitSavedOnlCollections();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    try {
      final mediaPlaylists = await _playlistDao.getPlaylists4Library();
      final playlistItems = mediaPlaylistsDB2ItemProperties(mediaPlaylists);

      // When emitting, copy existing parts of the state to avoid losing data
      emit(state.copyWith(
        playlists: playlistItems,
      ));
    } catch (e) {
      log("Error fetching playlists: $e", name: "LibraryItemsCubit");
      emit(const LibraryItemsError("Failed to load your playlists."));
    }
  }

  Future<void> getAndEmitSavedOnlCollections() async {
    try {
      final collections = await _collectionDao.getSavedCollections();
      final artists = collections.whereType<ArtistModel>().toList();
      final albums = collections.whereType<AlbumModel>().toList();
      final onlinePlaylists =
          collections.whereType<PlaylistOnlModel>().toList();

      emit(state.copyWith(
        artists: artists,
        albums: albums,
        playlistsOnl: onlinePlaylists,
      ));
    } catch (e) {
      log("Error fetching saved collections: $e", name: "LibraryItemsCubit");
      emit(const LibraryItemsError("Failed to load your saved items."));
    }
  }

  List<PlaylistItemProperties> mediaPlaylistsDB2ItemProperties(
      List<MediaPlaylist> mediaPlaylists) {
    return mediaPlaylists
        .map((element) => PlaylistItemProperties(
              playlistName: element.playlistName,
              subTitle: "${element.mediaItems.length} Items",
              coverImgUrl: element.imgUrl ??
                  (element.mediaItems.isNotEmpty
                      ? element.mediaItems.first.artUri?.toString()
                      : null),
            ))
        .toList();
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      _playlistDao.removePlaylist(mediaPlaylistDB);
      // The watcher will automatically trigger a state update.
      SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} removed");
    }
  }

  Future<void> addToPlaylist(MediaItemModel mediaItem, String playlistName,
      {bool showSnackbar = true}) async {
    if (playlistName != "Null") {
      await _playlistDao.addMediaItem(
          mediaItemToMediaItemDB(mediaItem), playlistName);
      if (showSnackbar) {
        SnackbarService.showMessage(
            "${mediaItem.title} is added to $playlistName!!");
      }
    }
  }

  void removeFromPlaylist(MediaItemModel mediaItem, String playlistName,
      {bool showSnackbar = true}) {
    if (playlistName != "Null") {
      _playlistDao
          .removeMediaItemFromPlaylist(mediaItemToMediaItemDB(mediaItem),
              MediaPlaylistDB(playlistName: playlistName))
          .then((_) {
        if (showSnackbar) {
          SnackbarService.showMessage(
              "${mediaItem.title} is removed from $playlistName!!");
        }
      });
    }
  }

  Future<List<MediaItemModel>?> getPlaylist(String playlistName) async {
    try {
      final playlist = await _playlistDao.getPlaylistItemsByName(playlistName);

      return playlist?.map((e) => mediaItemDBToMediaItem(e)).toList();
    } catch (e) {
      log("Error in getting playlist: $e", name: "libItemCubit");
      return null;
    }
  }

  /// Check if a media item is liked.
  Future<bool> isMediaLiked(MediaItemModel mediaItem) async {
    return _playlistDao.isMediaLiked(mediaItemToMediaItemDB(mediaItem));
  }

  /// Like/unlike a media item.
  Future<void> likeMediaItem(MediaItemModel mediaItem, bool isLiked) async {
    await _playlistDao.addMediaItem(mediaItemToMediaItemDB(mediaItem), "Liked");
    await _playlistDao.likeMediaItem(mediaItemToMediaItemDB(mediaItem),
        isLiked: isLiked);
  }

  /// Create a new empty playlist.
  Future<void> createPlaylist(String name) async {
    await _playlistDao.addPlaylist(MediaPlaylistDB(playlistName: name));
    SnackbarService.showMessage("Playlist '$name' created!");
  }

  /// Get all playlist names that contain a given song.
  Future<Set<String>> getPlaylistsContainingSong(String mediaId) async {
    final names = await _playlistDao.getPlaylistsContainingSong(mediaId);
    return names.toSet();
  }

  /// Get a playlist as a MediaPlaylist model by name.
  Future<MediaPlaylist?> getPlaylistByName(String name) async {
    final playlistDB = await _playlistDao.getPlaylist(name);
    if (playlistDB == null) return null;
    return playlistDBToMediaPlaylist(playlistDB);
  }
}
