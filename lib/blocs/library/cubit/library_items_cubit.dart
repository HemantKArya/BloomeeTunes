// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  Stream<void>? playlistWatcherDB;
  List<PlaylistItemProperties> playlistItems = List.empty();
  BloomeeDBCubit bloomeeDBCubit;
  List<MediaPlaylistDB> mediaPlaylistsDB = [];

  LibraryItemsCubit({
    required this.bloomeeDBCubit,
  }) : super(LibraryItemsInitial()) {
    getAndEmitPlaylists();
    getDBWatcher();
  }

  Future<void> getDBWatcher() async {
    playlistWatcherDB = await BloomeeDBService.getPlaylistsWatcher();
    playlistWatcherDB?.listen((event) {
      getAndEmitPlaylists();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    mediaPlaylistsDB = await BloomeeDBService.getPlaylists4Library();
    if (mediaPlaylistsDB.isNotEmpty) {
      playlistItems = mediaPlaylistsDB2ItemProperties(mediaPlaylistsDB);

      emit(LibraryItemsState(playlists: playlistItems));
    } else {
      emit(LibraryItemsInitial());
    }
  }

  List<PlaylistItemProperties> mediaPlaylistsDB2ItemProperties(
      List<MediaPlaylistDB> _mediaPlaylistsDB) {
    List<PlaylistItemProperties> _playlists = List.empty(growable: true);
    if (_mediaPlaylistsDB.isNotEmpty) {
      for (var element in _mediaPlaylistsDB) {
        log("${element.playlistName}", name: "libItemCubit");
        _playlists.add(
          PlaylistItemProperties(
            playlistName: element.playlistName,
            subTitle: "${element.mediaItems.length} Items",
            coverImgUrl: element.mediaItems.isNotEmpty
                ? element.mediaItems.first.artURL
                : null,
          ),
        );
      }
    }
    return _playlists;
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      BloomeeDBService.removePlaylist(mediaPlaylistDB);
      // getAndEmitPlaylists();
      SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} removed");
    }
  }

  Future<void> addToPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) async {
    if (mediaPlaylistDB.playlistName != "Null") {
      final _tempID = await bloomeeDBCubit.addMediaItemToPlaylist(
          mediaItem, mediaPlaylistDB);
      getAndEmitPlaylists();
      // log("Added to playlist - ${mediaPlaylistDB.playlistName} - $_tempID",
      //     name: "libItemCubit");
      // SnackbarService.showMessage(
      //     "Added ${mediaItem.title} to ${mediaPlaylistDB.playlistName}");
    }
  }

  void removeFromPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      bloomeeDBCubit.removeMediaFromPlaylist(mediaItem, mediaPlaylistDB);
      getAndEmitPlaylists();
      SnackbarService.showMessage(
          "Removed ${mediaItem.title} from ${mediaPlaylistDB.playlistName}");
    }
  }
}
