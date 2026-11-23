import 'dart:developer';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:rxdart/rxdart.dart';

class RelatedSongsManager {
  final BehaviorSubject<List<Track>> relatedSongs =
      BehaviorSubject<List<Track>>.seeded([]);
  final PluginService _pluginService;
  final Set<String> _fetchedTrackIds = <String>{};

  String? _referenceTrackId;
  String? _referenceLocalId;
  String? _pluginId;
  String? _nextPageToken;
  bool _isFetching = false;
  bool _isExhausted = false;

  /// Appends tracks to the queue (skipping ones already queued).
  void Function(List<Track> items)? onAddQueueItems;

  RelatedSongsManager(this._pluginService);

  /// Tops the queue up with radio tracks for [currentMedia] when it is about
  /// to run out. [remaining] counts the tracks after the current one; it is
  /// read again after each fetch because the queue can change meanwhile.
  Future<void> checkForRelatedSongs({
    required Track currentMedia,
    required int Function() remaining,
    required LoopMode loopMode,
  }) async {
    if (loopMode == LoopMode.all || remaining() > 0) return;

    final autoPlay =
        await SettingsDAO(DBProvider.db).getSettingBool(SettingKeys.autoPlay);
    if (autoPlay != null && !autoPlay) return;

    final parts = tryParseMediaId(currentMedia.id);
    if (parts == null) {
      return;
    }

    if (parts.pluginId == kLocalPluginId) {
      clearRelatedSongs();
      return;
    }

    _syncReferenceState(
      trackId: currentMedia.id,
      pluginId: parts.pluginId,
      localId: parts.localId,
    );

    if (relatedSongs.value.isEmpty) {
      await _fetchNextRadioPage();
    }
    _appendBuffered(remaining);

    if (relatedSongs.value.isEmpty) {
      await _fetchNextRadioPage();
      _appendBuffered(remaining);
    }
  }

  void _appendBuffered(int Function() remaining) {
    if (relatedSongs.value.isNotEmpty && remaining() < 2) {
      onAddQueueItems?.call(relatedSongs.value);
      relatedSongs.add([]);
    }
  }

  void clearRelatedSongs() {
    relatedSongs.add([]);
    _fetchedTrackIds.clear();
    _referenceTrackId = null;
    _referenceLocalId = null;
    _pluginId = null;
    _nextPageToken = null;
    _isFetching = false;
    _isExhausted = false;
  }

  void _syncReferenceState({
    required String trackId,
    required String pluginId,
    required String localId,
  }) {
    if (_referenceTrackId == trackId && _pluginId == pluginId) {
      return;
    }

    relatedSongs.add([]);
    _fetchedTrackIds.clear();
    _referenceTrackId = trackId;
    _referenceLocalId = localId;
    _pluginId = pluginId;
    _nextPageToken = null;
    _isFetching = false;
    _isExhausted = false;
  }

  Future<void> _fetchNextRadioPage() async {
    if (_isFetching ||
        _isExhausted ||
        _pluginId == null ||
        _referenceLocalId == null) {
      return;
    }

    _isFetching = true;
    try {
      final response = await _pluginService.execute(
        pluginId: _pluginId!,
        request: PluginRequest.contentResolver(
          ContentResolverCommand.getRadioTracks(
            id: _referenceLocalId!,
            pageToken: _nextPageToken,
          ),
        ),
      );

      response.when(
        moreTracks: (pagedTracks) {
          final uniqueTracks = pagedTracks.items.where((track) {
            return _fetchedTrackIds.add(track.id);
          }).toList(growable: false);

          if (uniqueTracks.isNotEmpty) {
            relatedSongs.add([...relatedSongs.value, ...uniqueTracks]);
            log(
              'Buffered ${uniqueTracks.length} related songs',
              name: 'RelatedSongsManager',
            );
          }

          _nextPageToken = pagedTracks.nextPageToken;
          _isExhausted =
              pagedTracks.nextPageToken == null && uniqueTracks.isEmpty;
        },
        trackDetails: (_) {},
        albumDetails: (_) {},
        artistDetails: (_) {},
        playlistDetails: (_) {},
        streams: (_) {},
        search: (_) {},
        moreAlbums: (_) {},
        homeSections: (_) {},
        loadMoreItems: (_) {},
        charts: (_) {},
        chartDetails: (_) {},
        segments: (_) {},
        lyricsResult: (_) {},
        lyricsSearchResults: (_) {},
        lyricsById: (_, __) {},
        suggestions: (_) {},
        canHandle: (_) {},
        collectionInfo: (_) {},
        importTracks: (_) {},
        ack: () {},
      );
    } catch (e) {
      log('Failed to get related songs: $e', name: 'RelatedSongsManager');
    } finally {
      _isFetching = false;
    }
  }

  void dispose() {
    relatedSongs.close();
  }
}
