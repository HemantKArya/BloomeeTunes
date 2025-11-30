// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  StreamSubscription? playlistWatcherDB;
  StreamSubscription? savedCollecsWatcherDB;
  final BloomeeDBCubit bloomeeDBCubit;

  LibraryItemsCubit({
    required this.bloomeeDBCubit,
  }) : super(LibraryItemsLoading()) {
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
    playlistWatcherDB =
        (await BloomeeDBService.getPlaylistsWatcher()).listen((_) {
      getAndEmitPlaylists();
    });
    savedCollecsWatcherDB =
        (await BloomeeDBService.getSavedCollecsWatcher()).listen((_) {
      getAndEmitSavedOnlCollections();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    try {
      final mediaPlaylists = await BloomeeDBService.getPlaylists4Library();
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
      final collections = await BloomeeDBService.getSavedCollections();
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
      BloomeeDBService.removePlaylist(mediaPlaylistDB);
      // The watcher will automatically trigger a state update.
      SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} removed");
    }
  }

  Future<void> addToPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB,
      {bool showSnackbar = true}) async {
    if (mediaPlaylistDB.playlistName != "Null") {
      await bloomeeDBCubit.addMediaItemToPlaylist(mediaItem, mediaPlaylistDB,
          showSnackbar: showSnackbar);
      // The watcher will automatically trigger a state update.
    }
  }

  void removeFromPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB,
      {bool showSnackbar = true}) {
    if (mediaPlaylistDB.playlistName != "Null") {
      bloomeeDBCubit.removeMediaFromPlaylist(mediaItem, mediaPlaylistDB,
          showSnackbar: showSnackbar);
      // The watcher will automatically trigger a state update.
    }
  }

  Future<List<MediaItemModel>?> getPlaylist(String playlistName) async {
    try {
      final playlist =
          await BloomeeDBService.getPlaylistItemsByName(playlistName);

      return playlist?.map((e) => MediaItemDB2MediaItem(e)).toList();
    } catch (e) {
      log("Error in getting playlist: $e", name: "libItemCubit");
      return null;
    }
  }
}
