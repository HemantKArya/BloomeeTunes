import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final AlbumModel album;
  final SourceEngine sourceEngine;
  AlbumCubit({required this.album, required this.sourceEngine})
      : super(AlbumInitial()) {
    emit(AlbumLoading(album: album));
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
              ),
            );
          },
        );
        break;
      case SourceEngine.eng_YTM:
        YtMusicService()
            .getAlbumDetails(album.sourceId.replaceAll("youtube", ''))
            .then(
          (value) {
            final List<MediaItemModel> songs =
                fromYtSongMapList2MediaItemList(value['songs']);
            emit(
              AlbumLoaded(
                album: album.copyWith(
                  songs: List<MediaItemModel>.from(songs),
                  artists: value['artist'] ?? album.artists,
                  description: value['subtitle'] ?? album.description,
                ),
              ),
            );
          },
        );
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }
}
