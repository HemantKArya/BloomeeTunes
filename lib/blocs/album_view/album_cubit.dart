import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final AlbumModel album;
  final SourceEngine sourceEngine;
  AlbumCubit({required this.album, required this.sourceEngine})
      : super(AlbumInitial()) {
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
    bool isSaved = await BloomeeDBService.isInSavedCollections(album.sourceId);
    if (state.isSavedToCollections != isSaved) {
      emit(
        state.copyWith(isSavedToCollections: isSaved),
      );
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedToCollections) {
      await BloomeeDBService.putOnlAlbumModel(album);
      SnackbarService.showMessage("Album added to Library!");
    } else {
      await BloomeeDBService.removeFromSavedCollecs(album.sourceId);
      SnackbarService.showMessage("Album removed from Library!");
    }
    checkIsSaved();
  }
}
