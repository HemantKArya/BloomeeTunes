import 'dart:developer';
import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> {
  final ArtistModel artist;
  final SourceEngine sourceEngine;
  ArtistCubit({
    required this.artist,
    required this.sourceEngine,
  }) : super(ArtistInitial()) {
    emit(ArtistLoading(artist: artist));
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
          ));
        });
        break;
      case SourceEngine.eng_YTM:
        YtMusicService().getArtistDetails(artist.sourceId).then((value) {
          log(value['songBrowseId'].toString());
          List<AlbumModel> albums = [];
          if (value['albums'] != null) {
            albums = ytmMap2Albums({
              'albums': value['albums'],
            });
          }
          if (value['songBrowseId'] != null) {
            log('inside more');
            YtMusicService()
                .getPlaylist(
                    value['songBrowseId'].toString().replaceAll('VL', ''))
                .then((v2) {
              final songsFull = fromYtSongMapList2MediaItemList(v2['songs']);
              emit(
                ArtistLoaded(
                  artist: artist.copyWith(
                    songs: List<MediaItemModel>.from(songsFull),
                    albums: List<AlbumModel>.from(albums),
                  ),
                ),
              );
            });
          } else {
            final songs = fromYtSongMapList2MediaItemList(value['songs']);
            emit(
              ArtistLoaded(
                artist: artist.copyWith(
                  songs: List<MediaItemModel>.from(songs),
                  albums: List<AlbumModel>.from(albums),
                ),
              ),
            );
          }
        });
        break;
      case SourceEngine.eng_YTV:
      // TODO: Handle this case.
    }
  }
}
