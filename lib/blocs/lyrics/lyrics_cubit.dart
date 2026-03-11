import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/core/models/exported.dart' hide Lyrics;
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsDAO _lyricsDao;
  final SettingsDAO _settingsDao;
  final PluginService _pluginService;
  StreamSubscription? _mediaItemSubscription;

  LyricsCubit(
    BloomeePlayerCubit playerCubit, {
    required LyricsDAO lyricsDao,
    required SettingsDAO settingsDao,
    required PluginService pluginService,
  })  : _lyricsDao = lyricsDao,
        _settingsDao = settingsDao,
        _pluginService = pluginService,
        super(LyricsInitial()) {
    _mediaItemSubscription =
        playerCubit.bloomeePlayer.mediaItem.stream.listen((v) {
      if (v != null) {
        getLyrics(mediaItemToTrack(v));
      }
    });
  }

  String _artistStr(Track track) => track.artists.map((a) => a.name).join(', ');

  void getLyrics(Track track) async {
    if (state.track.id == track.id && state is LyricsLoaded) {
      return;
    } else {
      emit(LyricsLoading(track));

      // 1. Try cache first
      Lyrics? lyrics = await _lyricsDao.getLyrics(track.id);
      if (lyrics != null && lyrics.mediaID == track.id) {
        emit(LyricsLoaded(lyrics, track));
        log("Lyrics loaded for ID: ${track.id} [Offline]", name: "LyricsCubit");
        return;
      }

      // 2. Try plugin providers in priority order
      final priority = await _loadPriority();
      if (priority.isEmpty) {
        emit(LyricsNoPlugin(track));
        return;
      }

      final metadata = plugin_models.TrackMetadata(
        title: track.title,
        artist: _artistStr(track),
        album: track.album?.title,
        durationMs: track.durationMs,
      );

      for (final pluginId in priority) {
        try {
          final response = await _pluginService.execute(
            pluginId: pluginId,
            request: PluginRequest.lyricsProvider(
              LyricsProviderCommand.getLyrics(metadata: metadata),
            ),
          );

          if (response is PluginResponse_LyricsResult &&
              response.field0 != null) {
            final result = response.field0!;
            lyrics = pluginLyricsToLyrics(
              result.$1,
              artist: _artistStr(track),
              title: track.title,
              album: track.album?.title,
              durationMs: track.durationMs,
              mediaID: track.id,
            );
            emit(LyricsLoaded(lyrics, track));
            _autoSave(lyrics);
            log("Lyrics loaded for ID: ${track.id} [Plugin: $pluginId]",
                name: "LyricsCubit");
            return;
          }
        } catch (e) {
          log("Plugin $pluginId failed: $e", name: "LyricsCubit");
        }
      }

      emit(LyricsError(track));
    }
  }

  Future<List<String>> _loadPriority() async {
    final raw = await _settingsDao.getSettingStr(SettingKeys.lyricsPriority);
    List<String> stored = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        stored = List<String>.from(jsonDecode(raw) as List);
      } catch (_) {
        stored = [];
      }
    }

    // Filter to only IDs that are currently loaded, preserving order.
    final loadedIds = _pluginService.getLoadedPlugins().toSet();
    final active = stored.where(loadedIds.contains).toList();
    if (active.isNotEmpty) return active;

    // Fallback: use every loaded LyricsProvider plugin (in arbitrary order).
    // This lets the feature work without requiring explicit configuration.
    try {
      final available = await _pluginService.getAvailablePlugins();
      return available
          .where((p) =>
              p.pluginType == PluginType.lyricsProvider &&
              loadedIds.contains(p.manifest.id))
          .map((p) => p.manifest.id)
          .toList();
    } catch (e) {
      log('Failed to enumerate lyrics plugins: $e', name: 'LyricsCubit');
      return [];
    }
  }

  void _autoSave(Lyrics lyrics) {
    _settingsDao.getSettingBool(SettingKeys.autoSaveLyrics).then((value) {
      if ((value ?? false)) {
        _lyricsDao.putLyrics(lyrics);
        log("Lyrics saved for ID: ${lyrics.mediaID}", name: "LyricsCubit");
      }
    });
  }

  void setLyricsToDB(Lyrics lyrics, String mediaID) {
    final l1 = lyrics.copyWith(mediaID: mediaID);
    _lyricsDao.putLyrics(l1).then((v) {
      emit(LyricsLoaded(l1, state.track));
    });
    log("Lyrics updated for ID: ${l1.mediaID}", name: "LyricsCubit");
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
