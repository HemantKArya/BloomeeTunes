import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
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

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtistModel artist;
  final SourceEngine sourceEngine;
  final CollectionRepository _collectionRepo;
  ArtistCubit({
    required this.artist,
    required this.sourceEngine,
    required CollectionRepository collectionRepo,
  })  : _collectionRepo = collectionRepo,
        super(ArtistInitial()) {
    emit(ArtistLoading(artist: artist));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI()
            .fetchArtistDetails(Uri.parse(artist.sourceURL).pathSegments.last)
            .then((value) {
          final songs = fromSaavnSongMapList2MediaItemList(value['songs']);
          final albums = saavnMap2Albums({'Albums': value['albums']});
          emit(ArtistLoaded(
            artist: artist.copyWith(
              songs: List<MediaItemModel>.from(songs),
              description: value['subtitle'] ?? artist.description,
              albums: List<AlbumModel>.from(albums),
            ),
            isSavedCollection: state.isSavedCollection,
          ));
        });
        break;
      case SourceEngine.eng_YTM:
        YTMusic().getArtistFull(artist.sourceId).then((value) {
          List<AlbumModel> albums = [];
          List<MediaItemModel> songsFull = [];
          if (value != null) {
            if (value['albums'] != null) {
              albums = ytmMap2Albums(value['albums']);
            }
            if (value['songs'] != null) {
              songsFull = ytmMapList2MediaItemList(value['songs']);
            }
            emit(
              ArtistLoaded(
                artist: artist.copyWith(
                  songs: List<MediaItemModel>.from(songsFull),
                  albums: List<AlbumModel>.from(albums),
                ),
                isSavedCollection: state.isSavedCollection,
              ),
            );
          } else {
            emit(
              ArtistLoaded(
                artist: artist.copyWith(
                  songs: [],
                  albums: [],
                ),
                isSavedCollection: state.isSavedCollection,
              ),
            );
          }
        });
        break;
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }
  Future<void> checkIsSaved() async {
    bool isSaved = await _collectionRepo.isSaved(artist.sourceId);
    if (state.isSavedCollection != isSaved) {
      emit(
        state.copyWith(isSavedCollection: isSaved),
      );
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedCollection) {
      await _collectionRepo.saveArtist(artist);
      SnackbarService.showMessage("Artist added to Library!");
    } else {
      await _collectionRepo.remove(artist.sourceId);
      SnackbarService.showMessage("Artist removed from Library!");
    }
    checkIsSaved();
  }
}
