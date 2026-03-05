import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/core/models/exported.dart' hide Lyrics;
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/repository/lyrics/lyrics.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsDAO _lyricsDao;
  final SettingsDAO _settingsDao;
  StreamSubscription? _mediaItemSubscription;

  LyricsCubit(
    BloomeePlayerCubit playerCubit, {
    required LyricsDAO lyricsDao,
    required SettingsDAO settingsDao,
  })  : _lyricsDao = lyricsDao,
        _settingsDao = settingsDao,
        super(LyricsInitial()) {
    _mediaItemSubscription =
        playerCubit.bloomeePlayer.mediaItem.stream.listen((v) {
      if (v != null) {
        getLyrics(mediaItemToTrack(v));
      }
    });
  }

  String _artistStr(Track track) => track.artists.map((a) => a.name).join(', ');

  Duration? _trackDuration(Track track) => track.durationMs != null
      ? Duration(milliseconds: track.durationMs!.toInt())
      : null;

  void getLyrics(Track track) async {
    if (state.track.id == track.id && state is LyricsLoaded) {
      return;
    } else {
      emit(LyricsLoading(track));
      Lyrics? lyrics = await _lyricsDao.getLyrics(track.id);
      if (lyrics == null) {
        try {
          lyrics = await LyricsRepository.getLyrics(
              track.title, _artistStr(track),
              album: track.album?.title, duration: _trackDuration(track));
          if (lyrics.lyricsSynced == "No Lyrics Found") {
            lyrics = lyrics.copyWith(lyricsSynced: null);
          }
          lyrics = lyrics.copyWith(mediaID: track.id);
          emit(LyricsLoaded(lyrics, track));
          _settingsDao.getSettingBool(SettingKeys.autoSaveLyrics).then((value) {
            if ((value ?? false) && lyrics != null) {
              _lyricsDao.putLyrics(lyrics);
              log("Lyrics saved for ID: ${track.id} Duration: ${lyrics.duration}",
                  name: "LyricsCubit");
            }
          });
          log("Lyrics loaded for ID: ${track.id} Duration: ${lyrics.duration} [Online]",
              name: "LyricsCubit");
        } catch (e) {
          emit(LyricsError(track));
        }
      } else if (lyrics.mediaID == track.id) {
        emit(LyricsLoaded(lyrics, track));
        log("Lyrics loaded for ID: ${track.id} Duration: ${lyrics.duration} [Offline]",
            name: "LyricsCubit");
      }
    }
  }

  void setLyricsToDB(Lyrics lyrics, String mediaID) {
    final l1 = lyrics.copyWith(mediaID: mediaID);
    _lyricsDao.putLyrics(l1).then((v) {
      emit(LyricsLoaded(l1, state.track));
    });
    log("Lyrics updated for ID: ${l1.mediaID} Duration: ${l1.duration}",
        name: "LyricsCubit");
  }

  void deleteLyricsFromDB(Track track) {
    _lyricsDao.removeLyricsById(track.id).then((value) {
      emit(LyricsInitial());
      getLyrics(track);

      log("Lyrics deleted for ID: ${track.id}", name: "LyricsCubit");
    });
  }

  @override
  Future<void> close() {
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}
