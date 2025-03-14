import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'online_playlist_state.dart';

class OnlPlaylistCubit extends Cubit<OnlPlaylistState> {
  PlaylistOnlModel playlist;
  SourceEngine sourceEngine;
  OnlPlaylistCubit({
    required this.playlist,
    required this.sourceEngine,
  }) : super(OnlPlaylistInitial()) {
    emit(OnlPlaylistLoading(playlist: playlist));
    checkIsSaved();
    switch (sourceEngine) {
      case SourceEngine.eng_JIS:
        SaavnAPI()
            .fetchPlaylistDetails(
                Uri.parse(playlist.sourceURL).pathSegments.last)
            .then((value) {
          final plst = PlaylistOnlModel(
            name: value['playlistDetails']['album'],
            imageURL: value['playlistDetails']['image'],
            source: 'saavn',
            sourceId: value['playlistDetails']['id'],
            sourceURL: value['playlistDetails']['perma_url'],
            description: value['playlistDetails']['subtitle'],
            artists: value['playlistDetails']['artist'] ?? 'Various Artists',
            language: value['playlistDetails']['language'],
          );
          final songs = fromSaavnSongMapList2MediaItemList(value['songs']);
          emit(OnlPlaylistLoaded(
            playlist: playlist.copyWith(
              name: plst.name,
              imageURL: plst.imageURL,
              source: plst.source,
              sourceId: plst.sourceId,
              sourceURL: plst.sourceURL,
              description: plst.description,
              artists: plst.artists,
              songs: List<MediaItemModel>.from(songs),
            ),
            isSavedCollection: state.isSavedCollection,
          ));
        });
        break;
      case SourceEngine.eng_YTM:
        YTMusic()
            .getPlaylistFull(playlist.sourceId.replaceAll("youtubeVL", ""))
            .then(
          (value) {
            if (value != null && value['songs'] != null) {
              final songs = ytmMapList2MediaItemList(value['songs']);
              emit(OnlPlaylistLoaded(
                playlist: playlist.copyWith(
                  songs: List<MediaItemModel>.from(songs),
                ),
                isSavedCollection: state.isSavedCollection,
              ));
            }
          },
        );
        break;
      case SourceEngine.eng_YTV:
        YouTubeServices().fetchPlaylistItems(playlist.sourceId).then((value) {
          final songs = fromYtVidSongMapList2MediaItemList(value[0]['items']);
          emit(OnlPlaylistLoaded(
            playlist: playlist.copyWith(
              songs: List<MediaItemModel>.from(songs),
              artists: value[0]['metadata'].author,
            ),
            isSavedCollection: state.isSavedCollection,
          ));
        });
        break;
    }
  }

  Future<void> checkIsSaved() async {
    bool isSaved =
        await BloomeeDBService.isInSavedCollections(playlist.sourceId);
    if (state.isSavedCollection != isSaved) {
      emit(
        state.copyWith(isSavedCollection: isSaved),
      );
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedCollection) {
      await BloomeeDBService.putOnlPlaylistModel(playlist);
      SnackbarService.showMessage("Artist added to Library!");
    } else {
      await BloomeeDBService.removeFromSavedCollecs(playlist.sourceId);
      SnackbarService.showMessage("Artist removed from Library!");
    }
    checkIsSaved();
  }
}
