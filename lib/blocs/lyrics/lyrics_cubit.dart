import 'dart:async';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Lyrics/lyrics.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  StreamSubscription? _mediaItemSubscription;
  LyricsCubit(BloomeePlayerCubit playerCubit) : super(LyricsInitial()) {
    _mediaItemSubscription =
        playerCubit.bloomeePlayer.mediaItem.stream.listen((v) {
      if (v != null) {
        getLyrics(mediaItem2MediaItemModel(v));
      }
    });
  }

  void getLyrics(MediaItemModel mediaItem) async {
    if (state.mediaItem == mediaItem && state is LyricsLoaded) {
      return;
    } else {
      emit(LyricsLoading(mediaItem));
      try {
        Lyrics lyrics = await LyricsRepository.getLyrics(
            mediaItem.title, mediaItem.artist ?? "",
            album: mediaItem.album, duration: mediaItem.duration);
        if (lyrics.lyricsSynced == "No Lyrics Found") {
          lyrics = lyrics.copyWith(lyricsSynced: null);
        }
        emit(LyricsLoaded(lyrics, mediaItem));
      } catch (e) {
        emit(LyricsError(mediaItem));
      }
    }
  }

  @override
  Future<void> close() {
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}
