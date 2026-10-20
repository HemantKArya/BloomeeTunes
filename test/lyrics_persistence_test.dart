import 'dart:async';

import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart'
    show Track, Artwork, ImageLayout;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/player_test_fixture.dart';

class _Store extends LyricsDAO {
  _Store() : super(Completer<Isar>().future);
  final lookups = <String, Completer<Lyrics?>>{};
  final write = Completer<void>();
  final deletion = Completer<void>();
  @override
  Future<Lyrics?> getLyrics(String mediaID) =>
      lookups.putIfAbsent(mediaID, () => Completer<Lyrics?>()).future;
  @override
  Future<void> putLyrics(Lyrics lyrics, {int? offset}) => write.future;
  @override
  Future<void> removeLyricsById(String mediaID) => deletion.future;
}

class _Settings implements SettingsDAO {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plugins implements PluginService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Lyrics document(String mediaID, String id) => Lyrics(
      id: id,
      mediaID: mediaID,
      title: id,
      artist: '',
      lyricsPlain: id,
      provider: LyricsProvider.plugin,
    );

const nextTrack = Track(
    id: 'next',
    title: 'Next',
    artists: [],
    thumbnail: Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false);

void main() {
  Future<(LyricsCubit, _Store)> setup() async {
    final player = TestMusicPlayer();
    final playerCubit = BloomeePlayerCubit(player);
    final store = _Store();
    final lyrics = LyricsCubit(playerCubit,
        lyricsDao: store, settingsDao: _Settings(), pluginService: _Plugins());
    addTearDown(() async {
      await lyrics.close();
      await playerCubit.close();
      await player.closeStreams();
    });
    await Future<void>.delayed(Duration.zero);
    return (lyrics, store);
  }

  test('saving the previous track never replaces lyrics for the new track',
      () async {
    final (cubit, store) = await setup();
    final original = document('current', 'original');
    store.lookups['current']!.complete(original);
    await Future<void>.delayed(Duration.zero);
    final save = cubit.setLyricsToDB(original, 'current', offset: 50);
    final next = cubit.getLyrics(nextTrack);
    store.write.complete();
    await save;
    expect(cubit.state, isA<LyricsLoading>());
    expect(cubit.state.track.id, 'next');
    store.lookups['next']!.complete(document('next', 'next lyrics'));
    await next;
    expect(cubit.state.lyrics.mediaID, 'next');
  });

  test('a manual choice wins over an older automatic lookup', () async {
    final (cubit, store) = await setup();
    final save = cubit.setLyricsToDB(document('current', 'manual'), 'current');
    store.write.complete();
    await save;
    store.lookups['current']!.complete(document('current', 'old lookup'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.lyrics.id, 'manual');
  });

  test('deleting previous lyrics does not reload the previous track', () async {
    final (cubit, store) = await setup();
    store.lookups['current']!.complete(document('current', 'original'));
    await Future<void>.delayed(Duration.zero);
    final deletion = cubit.deleteLyricsFromDB(cubit.state.track);
    final next = cubit.getLyrics(nextTrack);
    store.deletion.complete();
    await deletion;
    expect(cubit.state.track.id, 'next');
    store.lookups['next']!.complete(document('next', 'next lyrics'));
    await next;
    expect(cubit.state.lyrics.mediaID, 'next');
  });
}
