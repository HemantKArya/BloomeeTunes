import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/saavn_model.dart';
import 'package:Bloomee/model/song_model.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/bloomee/collection_repository.dart';
import 'package:Bloomee/repository/saavn/saavn_api.dart';
import 'package:Bloomee/repository/youtube/ytm/ytmusic.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final AlbumModel album;
  final SourceEngine sourceEngine;
  final CollectionRepository _collectionRepo;
  AlbumCubit({
    required this.album,
    required this.sourceEngine,
    required CollectionRepository collectionRepo,
  })  : _collectionRepo = collectionRepo,
        super(AlbumInitial()) {
    emit(AlbumLoading(album: album));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI().fetchAlbumDetails(album.extra['token']).then(
          (value) {
            emit(
              AlbumLoaded(
                album: album.copyWith(
                  songs: List<MediaItemModel>.from(
                      fromSaavnSongMapList2MediaItemList(value['songs'])),
                ),
                isSavedToCollections: state.isSavedToCollections,
              ),
            );
          },
        );
        break;
      case SourceEngine.eng_YTM:
        YTMusic().getAlbumFull(album.sourceId.replaceAll("youtube", '')).then(
          (value) {
            if (value != null) {
              final List<MediaItemModel> songs =
                  ytmMapList2MediaItemList(value['songs']);
              emit(
                AlbumLoaded(
                  album: album.copyWith(
                    songs: List<MediaItemModel>.from(songs),
                    artists: value['artists'] ?? album.artists,
                    description: value['subtitle'] ?? album.description,
                  ),
                  isSavedToCollections: state.isSavedToCollections,
                ),
              );
            } else {
              // pass;
            }
          },
        );
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }

  Future<void> checkIsSaved() async {
    bool isSaved = await _collectionRepo.isSaved(album.sourceId);
    if (state.isSavedToCollections != isSaved) {
      emit(
        state.copyWith(isSavedToCollections: isSaved),
      );
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedToCollections) {
      await _collectionRepo.saveAlbum(album);
      SnackbarService.showMessage("Album added to Library!");
    } else {
      await _collectionRepo.remove(album.sourceId);
      SnackbarService.showMessage("Album removed from Library!");
    }
    checkIsSaved();
  }
}
