import 'package:Bloomee/core/models/playlist_onl_model.dart';
import 'package:Bloomee/core/models/saavn_model.dart';
import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/core/models/source_engines.dart';
import 'package:Bloomee/core/models/youtube_vid_model.dart';
import 'package:Bloomee/core/models/yt_music_model.dart';
import 'package:Bloomee/repository/bloomee/collection_repository.dart';
import 'package:Bloomee/repository/saavn/saavn_api.dart';
import 'package:Bloomee/repository/youtube/youtube_api.dart';
import 'package:Bloomee/repository/youtube/ytm/ytmusic.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'online_playlist_state.dart';

class OnlPlaylistCubit extends Cubit<OnlPlaylistState> {
  PlaylistOnlModel playlist;
  SourceEngine sourceEngine;
  final CollectionRepository _collectionRepo;
  OnlPlaylistCubit({
    required this.playlist,
    required this.sourceEngine,
    required CollectionRepository collectionRepo,
  })  : _collectionRepo = collectionRepo,
        super(OnlPlaylistInitial()) {
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
    bool isSaved = await _collectionRepo.isSaved(playlist.sourceId);
    if (state.isSavedCollection != isSaved) {
      emit(
        state.copyWith(isSavedCollection: isSaved),
      );
    }
  }

  Future<void> addToSavedCollections() async {
    if (!state.isSavedCollection) {
      await _collectionRepo.savePlaylist(playlist);
      SnackbarService.showMessage("Artist added to Library!");
    } else {
      await _collectionRepo.remove(playlist.sourceId);
      SnackbarService.showMessage("Artist removed from Library!");
    }
    checkIsSaved();
  }
}
