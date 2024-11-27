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
  Stream<void>? playlistWatcherDB;
  Stream<void>? savedCollecsWatcherDB;
  List<PlaylistItemProperties> playlistItems = List.empty();
  BloomeeDBCubit bloomeeDBCubit;
  List<MediaPlaylist> mediaPlaylists = [];
  StreamSubscription? strmSubsDB;
  StreamSubscription? strmSubsDB2;
  LibraryItemsCubit({
    required this.bloomeeDBCubit,
  }) : super(LibraryItemsInitial()) {
    getAndEmitPlaylists();
    getAndEmitSavedOnlCollections();
    getDBWatcher();
  }

  @override
  Future<void> close() {
    strmSubsDB?.cancel();
    return super.close();
  }

  Future<void> getDBWatcher() async {
    playlistWatcherDB = await BloomeeDBService.getPlaylistsWatcher();
    strmSubsDB = playlistWatcherDB?.listen((event) {
      getAndEmitPlaylists();
    });
    savedCollecsWatcherDB = await BloomeeDBService.getSavedCollecsWatcher();
    strmSubsDB2 = savedCollecsWatcherDB?.listen((event) {
      getAndEmitSavedOnlCollections();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    mediaPlaylists = await BloomeeDBService.getPlaylists4Library();
    if (mediaPlaylists.isNotEmpty) {
      playlistItems = mediaPlaylistsDB2ItemProperties(mediaPlaylists);

      emit(LibraryItemsState(
        playlists: playlistItems,
        albums: state.albums,
        artists: state.artists,
        playlistsOnl: state.playlistsOnl,
      ));
    } else {
      emit(LibraryItemsInitial());
    }
  }

  Future<void> getAndEmitSavedOnlCollections() async {
    final _collecs = await BloomeeDBService.getSavedCollections();
    List<ArtistModel> _artists = [];
    List<AlbumModel> _albums = [];
    List<PlaylistOnlModel> _playlists = [];
    for (var element in _collecs) {
      switch (element.runtimeType) {
        case ArtistModel:
          _artists.add(element as ArtistModel);
          break;
        case AlbumModel:
          _albums.add(element as AlbumModel);
          break;
        case PlaylistOnlModel:
          _playlists.add(element as PlaylistOnlModel);
          log("${element.runtimeType}");
          break;
        default:
          break;
      }
      emit(LibraryItemsState(
        artists: List<ArtistModel>.from(_artists),
        albums: List<AlbumModel>.from(_albums),
        playlistsOnl: List<PlaylistOnlModel>.from(_playlists),
        playlists: state.playlists,
      ));
    }
  }

  List<PlaylistItemProperties> mediaPlaylistsDB2ItemProperties(
      List<MediaPlaylist> _mediaPlaylists) {
    List<PlaylistItemProperties> _playlists = List.empty(growable: true);
    if (_mediaPlaylists.isNotEmpty) {
      for (var element in _mediaPlaylists) {
        // log(element.playlistName, name: "LibCubit");
        _playlists.add(
          PlaylistItemProperties(
            playlistName: element.playlistName,
            subTitle: "${element.mediaItems.length} Items",
            coverImgUrl: element.imgUrl ??
                (element.mediaItems.isNotEmpty
                    ? element.mediaItems.first.artUri?.toString()
                    : null),
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
      await bloomeeDBCubit.addMediaItemToPlaylist(mediaItem, mediaPlaylistDB);
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

  Future<List<MediaItemModel>?> getPlaylist(String playlistName) async {
    try {
      final _playlist =
          await BloomeeDBService.getPlaylistItemsByName(playlistName);

      if (_playlist != null) {
        final mediaItems =
            _playlist.map((e) => MediaItemDB2MediaItem(e)).toList();
        return mediaItems;
      }
    } catch (e) {
      log("Error in getting playlist: $e", name: "libItemCubit");
      return null;
    }
    return null;
  }
}
