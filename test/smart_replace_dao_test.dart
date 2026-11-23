import 'dart:io';

import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'support/isar_test_support.dart';

Track _song(String id) => Track(
    id: id,
    title: id,
    artists: const [],
    thumbnail: const Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false);

void main() {
  late Directory root;
  late Isar database;
  late PlaylistDAO playlists;

  setUpAll(initializeTestIsar);
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bloomee_smart_replace_');
    database = await Isar.open(DBProvider.schemas,
        directory: root.path, name: 'test', inspector: false);
    final db = Future.value(database);
    playlists = PlaylistDAO(db, TrackDAO(db));
  });
  tearDown(() async {
    if (database.isOpen) await database.close();
    await root.delete(recursive: true);
  });

  Future<List<String>> ids(int playlistId) async => [
        for (final t in await playlists.getPlaylistTracks(playlistId)) t.mediaId
      ];

  test('replaces in place across playlists, skipping system ones', () async {
    final mix = await playlists.ensurePlaylist('Mix');
    final chill = await playlists.ensurePlaylist('Chill');
    final system = await playlists.ensurePlaylist('_DOWNLOADS');
    await playlists
        .addTracksToPlaylist(mix, [_song('a'), _song('dead'), _song('c')]);
    await playlists.addTracksToPlaylist(chill, [_song('dead'), _song('z')]);
    await playlists.addTracksToPlaylist(system, [_song('dead')]);

    final result = await playlists.replaceTrackInPlaylists('dead', _song('new'),
        skipPlaylists: {'_DOWNLOADS'});

    expect(result.playlists.toSet(), {'Mix', 'Chill'});
    expect(result.droppedDuplicates, 0);
    expect(await ids(mix), ['a', 'new', 'c']);
    expect(await ids(chill), ['new', 'z']);
    expect(await ids(system), ['dead']);
  });

  test('drops the old entry where the replacement is already present',
      () async {
    final mix = await playlists.ensurePlaylist('Mix');
    await playlists
        .addTracksToPlaylist(mix, [_song('new'), _song('dead'), _song('c')]);

    final result =
        await playlists.replaceTrackInPlaylists('dead', _song('new'));

    expect(result.playlists, ['Mix']);
    expect(result.droppedDuplicates, 1);
    expect(await ids(mix), ['new', 'c']);
  });

  test('unknown track changes nothing', () async {
    final result =
        await playlists.replaceTrackInPlaylists('missing', _song('new'));
    expect(result.playlists, isEmpty);
  });
}
