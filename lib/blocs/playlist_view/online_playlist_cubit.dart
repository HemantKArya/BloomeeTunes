import 'dart:developer';

import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
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
          ));
        });
        break;
      case SourceEngine.eng_YTM:
        YtMusicService()
            .getPlaylist(playlist.sourceId.replaceAll("youtubeVL", ""))
            .then(
          (value) {
            final songs = fromYtSongMapList2MediaItemList(value['songs']);
            emit(OnlPlaylistLoaded(
              playlist: playlist.copyWith(
                songs: List<MediaItemModel>.from(songs),
              ),
            ));
          },
        );
        break;
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }
}
