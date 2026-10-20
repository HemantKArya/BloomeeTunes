import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/repository/backup/backup_repository.dart';
import 'package:Bloomee/services/db/dao/backup_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:Bloomee/blocs/current_playlist/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:flutter/services.dart';

class DelayedPlaylistDAO extends PlaylistDAO {
  String? blockedName;
  final headerGate = Completer<void>();
  Completer<void>? pageGate;
  DelayedPlaylistDAO(Future<Isar> database, TrackDAO tracks)
      : super(database, tracks);

  @override
  Future<PlaylistDB?> getPlaylistByName(String name) async {
    if (name == blockedName) await headerGate.future;
    return super.getPlaylistByName(name);
  }

  @override
  Future<List<TrackDB>> getPlaylistTracksPage(int playlistId,
      {required int offset, required int limit}) async {
    if (pageGate != null) await pageGate!.future;
    return super
        .getPlaylistTracksPage(playlistId, offset: offset, limit: limit);
  }
}

Track song(String id, {String? title}) => Track(
    id: id,
    title: title ?? id,
    artists: const [],
    thumbnail: const Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late Isar isar;
  late TrackDAO tracks;
  late PlaylistDAO playlists;
  late BackupDAO backups;
  late BackupRepository repository;

  setUpAll(() async {
    final configured = Platform.environment['ISAR_TEST_LIBRARY'];
    final built = p.absolute('build/windows/x64/runner/Debug/libisar.dll');
    final path = configured ??
        (Platform.isWindows && File(built).existsSync() ? built : null);
    await Isar.initializeIsarCore(
        libraries: {if (path != null) Abi.current(): path},
        download: path == null);
  });
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bloomee_backup_test_');
    isar = await Isar.open(DBProvider.schemas,
        directory: root.path, name: 'test', inspector: false);
    tracks = TrackDAO(Future.value(isar));
    playlists = PlaylistDAO(Future.value(isar), tracks);
    backups = BackupDAO(Future.value(isar));
    repository = BackupRepository(
        dao: backups, database: Future.value(isar), supportPath: root.path);
  });
  tearDown(() async {
    if (isar.isOpen) await isar.close();
    await root.delete(recursive: true);
  });

  Future<List<String>> ids(String name) async {
    final row = await playlists.getPlaylistByName(name);
    if (row == null) return [];
    return (await playlists.getPlaylistTracks(row.id))
        .map((t) => t.mediaId)
        .toList();
  }

  Future<void> seed() async {
    final first = await playlists.ensurePlaylist('First');
    final second = await playlists.ensurePlaylist('Second');
    await playlists.addTracksToPlaylist(first, [song('a'), song('b')]);
    await playlists.addTracksToPlaylist(second, [song('b'), song('a')]);
    await playlists.setTrackLiked(song('a'), true);
    await SettingsDAO(Future.value(isar))
        .putSettingStr(SettingKeys.languageCode, 'hi');
    await SettingsDAO(Future.value(isar))
        .putSettingStr(SettingKeys.downPathSetting, 'foreign/device/path');
  }

  test('round trip preserves likes and independent playlist order', () async {
    await seed();
    final document = await backups.snapshot();
    expect(document.rows('settings').map((s) => s['key']),
        contains(SettingKeys.languageCode));
    expect(document.rows('settings').map((s) => s['key']),
        isNot(contains(SettingKeys.downPathSetting)));
    await isar.writeTxn(() => isar.clear());
    await backups.apply(document, const BackupSelection());
    expect(await ids('First'), ['a', 'b']);
    expect(await ids('Second'), ['b', 'a']);
    expect(await ids('Liked'), ['a']);
  });

  test('merge is repeatable and preserves existing metadata and row IDs',
      () async {
    await seed();
    final before = await tracks.getTrackDBByMediaId('a');
    final document = await backups.snapshot();
    await tracks.upsertTrack(song('a', title: 'Richer current title'));
    await backups.apply(document, const BackupSelection());
    await backups.apply(document, const BackupSelection());
    expect(await ids('First'), ['a', 'b']);
    final after = await tracks.getTrackDBByMediaId('a');
    expect(after!.id, before!.id);
    expect(after.title, 'Richer current title');
  });

  test('new copy allocates distinct names but merges likes', () async {
    await seed();
    await backups.apply(await backups.snapshot(),
        const BackupSelection(mode: BackupImportMode.newCopy));
    expect(await ids('First (1)'), ['a', 'b']);
    expect(await ids('Liked'), ['a']);
    expect(await playlists.getPlaylistByName('Liked (1)'), isNull);
  });

  test('history-only import leaves library and preferences untouched',
      () async {
    await seed();
    await HistoryDAO(Future.value(isar), tracks).recordPlay(song('history'));
    final document = await backups.snapshot();
    await isar.writeTxn(() => isar.playbackHistoryDBs.clear());
    await SettingsDAO(Future.value(isar))
        .putSettingStr(SettingKeys.languageCode, 'en');
    await backups.apply(
        document, const BackupSelection(library: false, settings: false));
    expect(await ids('First'), ['a', 'b']);
    expect(await isar.playbackHistoryDBs.count(), 1);
    expect(
        await SettingsDAO(Future.value(isar))
            .getSettingStr(SettingKeys.languageCode),
        'en');
  });

  test('conflict rolls back all earlier writes in the same import', () async {
    await playlists.ensurePlaylist('Conflict', type: PlaylistTypeDB.album);
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'backup',
      'tracks': [
        {'mediaId': 'new', 'title': 'New'}
      ],
      'playlists': [
        {
          'name': 'Would be partial',
          'type': 'userPlaylist',
          'entries': ['new']
        },
        {
          'name': 'Conflict',
          'type': 'userPlaylist',
          'entries': ['new']
        },
      ],
    });
    await expectLater(
        backups.apply(document, const BackupSelection()), throwsStateError);
    expect(await playlists.getPlaylistByName('Would be partial'), isNull);
    expect(await tracks.getTrackByMediaId('new'), isNull);
  });

  test('pre-import snapshot is complete and existing DAOs keep working',
      () async {
    await seed();
    final document = await backups.snapshot();
    await repository.apply(document, const BackupSelection());
    final files = Directory(repository.snapshotDirectory)
        .listSync()
        .whereType<File>()
        .toList();
    expect(files, hasLength(1));
    expect(files.single.lengthSync(), greaterThan(0));
    expect(files.single.path.endsWith('.isar'), true);
    expect(isar.isOpen, true);
    expect(await ids('Second'), ['b', 'a']);
    final compatible = await repository.prepare(files.single.path);
    expect(compatible.playlistCount, document.playlistCount);
    expect(isar.isOpen, true);
  });

  test('snapshot failure aborts before mutation', () async {
    await seed();
    final document = await backups.snapshot();
    await File(p.join(root.path, 'backups')).writeAsString('not a directory');
    await expectLater(
        repository.apply(
            document, const BackupSelection(mode: BackupImportMode.replace)),
        throwsA(isA<FileSystemException>()));
    expect(await ids('First'), ['a', 'b']);
  });

  test('automatic snapshots rotate only after completion', () async {
    for (var i = 0; i < 9; i++) {
      await repository.createSnapshot();
    }
    final files = Directory(repository.snapshotDirectory)
        .listSync()
        .whereType<File>()
        .toList();
    expect(files, hasLength(7));
    expect(files.any((f) => f.path.endsWith('.partial')), false);
  });

  test('cleanup keeps history-only tracks and linked tracks', () async {
    await HistoryDAO(Future.value(isar), tracks).recordPlay(song('history'));
    await tracks.purgeOrphanTrack('history');
    expect(await tracks.getTrackByMediaId('history'), isNotNull);
    await seed();
    await tracks.purgeOrphanTracks();
    expect(await ids('First'), ['a', 'b']);
  });

  test('concurrent upserts preserve link identity and avoid duplicate entries',
      () async {
    final id = await playlists.ensurePlaylist('Mix');
    await Future.wait(List.generate(
        20, (_) => playlists.addTrackToPlaylist(id, song('same'))));
    expect(await ids('Mix'), ['same']);
    expect(await isar.trackDBs.count(), 1);
  });

  test(
      'selective replacement preserves device playlists and unselected history/settings',
      () async {
    await seed();
    final snapshot = await backups.snapshot();
    await playlists.ensurePlaylist('Extra');
    final downloads = await playlists.ensurePlaylist('_DOWNLOADS');
    await playlists.addTrackToPlaylist(downloads, song('device'));
    await HistoryDAO(Future.value(isar), tracks).recordPlay(song('history'));
    await SettingsDAO(Future.value(isar))
        .putSettingStr(SettingKeys.languageCode, 'en');
    await backups.apply(
        snapshot,
        const BackupSelection(
            history: false, settings: false, mode: BackupImportMode.replace));
    expect(await playlists.getPlaylistByName('Extra'), isNull);
    expect(await ids('_DOWNLOADS'), ['device']);
    expect(await ids('First'), ['a', 'b']);
    expect(await isar.playbackHistoryDBs.count(), 1);
    expect(
        await SettingsDAO(Future.value(isar))
            .getSettingStr(SettingKeys.languageCode),
        'en');
  });

  test('settings replacement cannot import credentials or device paths',
      () async {
    final settings = SettingsDAO(Future.value(isar));
    await settings.putSettingStr('accountToken', 'keep-secret');
    await settings.putSettingStr(SettingKeys.downPathSetting, 'this-device');
    await settings.putSettingStr(SettingKeys.eqPreset, 'Rock');
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'backup',
      'tracks': [],
      'playlists': [],
      'settings': [
        {'key': SettingKeys.languageCode, 'value': 'hi'},
        {'key': 'accountToken', 'value': 'foreign-secret'},
        {'key': SettingKeys.downPathSetting, 'value': 'foreign-device'},
      ],
    });
    await backups.apply(
        document,
        const BackupSelection(
            library: false, history: false, mode: BackupImportMode.replace));
    expect(await settings.getSettingStr('accountToken'), 'keep-secret');
    expect(await settings.getSettingStr(SettingKeys.downPathSetting),
        'this-device');
    expect(await settings.getSettingStr(SettingKeys.languageCode), 'hi');
    expect(await settings.getSettingStr(SettingKeys.eqPreset), isNull);
  });

  test('history-only selection does not insert unselected library tracks',
      () async {
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'backup',
      'tracks': [
        {'mediaId': 'wanted', 'title': 'Wanted'},
        {'mediaId': 'unselected', 'title': 'Unselected'}
      ],
      'playlists': [
        {
          'name': 'Unselected',
          'type': 'userPlaylist',
          'entries': ['unselected']
        }
      ],
      'history': [
        {'mediaId': 'wanted', 'playedAt': '2026-01-01T00:00:00Z'}
      ],
    });
    await backups.apply(
        document, const BackupSelection(library: false, settings: false));
    expect(await tracks.getTrackByMediaId('wanted'), isNotNull);
    expect(await tracks.getTrackByMediaId('unselected'), isNull);
    expect(await playlists.getPlaylistByName('Unselected'), isNull);
  });

  test('native delivery receipt is committed with data and suppresses replay',
      () async {
    await seed();
    final document = await backups.snapshot();
    final first = await repository.apply(
        document, const BackupSelection(mode: BackupImportMode.newCopy),
        deliveryId: 'native-delivery-one');
    final replay = await repository.apply(
        document, const BackupSelection(mode: BackupImportMode.newCopy),
        deliveryId: 'native-delivery-one');
    expect(first['addedPlaylists'], greaterThan(0));
    expect(replay['addedPlaylists'], 0);
    expect(await playlists.getPlaylistByName('First (2)'), isNull);
    // A later intentional import remains possible.
    await repository.apply(
        document, const BackupSelection(mode: BackupImportMode.newCopy));
    expect(await playlists.getPlaylistByName('First (2)'), isNotNull);
  });

  test('automatic gate serializes checks and records only completed backups',
      () async {
    final settings = SettingsDAO(Future.value(isar));
    await settings.putSettingBool(SettingKeys.autoBackup, true);
    await Future.wait(List.generate(5, (_) => repository.automaticIfDue()));
    expect(Directory(repository.snapshotDirectory).listSync(), hasLength(1));
    expect(
        DateTime.tryParse(
            (await settings.getSettingStr(SettingKeys.lastBackupTimestamp))!),
        isNotNull);
  });

  test('failed automatic backup does not advance its timestamp', () async {
    final settings = SettingsDAO(Future.value(isar));
    await settings.putSettingBool(SettingKeys.autoBackup, true);
    await File(p.join(root.path, 'backups')).writeAsString('blocked');
    await expectLater(
        repository.automaticIfDue(), throwsA(isA<FileSystemException>()));
    expect(
        await settings.getSettingStr(SettingKeys.lastBackupTimestamp), isNull);
  });

  test('scheduled reset can be canceled and blocks intervening imports',
      () async {
    await seed();
    final document = await backups.snapshot();
    await repository.requestReset();
    expect(await ids('First'), ['a', 'b']);
    await expectLater(
        repository.apply(document, const BackupSelection()), throwsStateError);
    await repository.cancelReset();
    await repository.apply(document, const BackupSelection());
    expect(await ids('First'), ['a', 'b']);
  });

  test('canonical open ignores other named instances and old fallback files',
      () async {
    await seed();
    await isar.copyToFile(p.join(root.path, 'bloomee_backup_dbv3.isar'));
    final opened = await DBProvider.init(
        appSupportPath: root.path, appDocumentsPath: root.path);
    try {
      expect(opened.name, 'dbv3');
      expect(identical(opened, isar), false);
      expect(await opened.trackDBs.count(), 0);
      final concurrent =
          await Future.wait(List.generate(5, (_) => DBProvider.openDB()));
      expect(concurrent.every((db) => identical(db, opened)), true);
    } finally {
      await opened.close();
    }
  });

  test(
      'bootstrap consumes explicit reset before services and clears every collection',
      () async {
    var opened = await DBProvider.init(
        appSupportPath: root.path, appDocumentsPath: root.path);
    try {
      await opened.writeTxn(() async {
        await opened.downloadDBs.put(DownloadDB(
            fileName: 'a',
            filePath: 'device',
            lastDownloaded: null,
            mediaId: 'a'));
        await opened.pluginStorageEntitys.put(PluginStorageEntity(
            pluginId: 'plugin',
            key: 'token',
            value: 'secret',
            updatedAt: DateTime.now()));
      });
      final r = BackupRepository(
          dao: BackupDAO(Future.value(opened)),
          database: Future.value(opened),
          supportPath: root.path);
      await r.requestReset();
      expect(await opened.downloadDBs.count(), 1);
      await opened.close();
      opened = await DBProvider.init(
          appSupportPath: root.path, appDocumentsPath: root.path);
      expect(await opened.downloadDBs.count(), 0);
      expect(await opened.pluginStorageEntitys.count(), 0);
      expect(await opened.playlistDBs.count(), 3);
      expect(File(p.join(root.path, 'reset_requested')).existsSync(), false);
      expect(Directory(p.join(root.path, 'backups')).listSync(), isNotEmpty);
    } finally {
      if (opened.isOpen) await opened.close();
    }
  });

  test(
      'queue-only tracks survive cleanup and empty queue removes stale references',
      () async {
    await tracks
        .persistQueueState([song('queued')], currentIndex: 0, title: 'Queue');
    await tracks.purgeOrphanTracks();
    await tracks.purgeOrphanTrack('queued');
    expect(await tracks.getTrackByMediaId('queued'), isNotNull);
    await tracks.persistQueueState([], currentIndex: 0, title: 'Empty');
    await tracks.purgeOrphanTracks();
    expect(await tracks.getTrackByMediaId('queued'), isNull);
    expect(
        await SettingsDAO(Future.value(isar))
            .getSettingStr(SettingKeys.lastQueueState),
        isNull);
  });

  test('malformed saved queue prevents speculative orphan deletion', () async {
    await tracks.upsertTrack(song('unverified'));
    await SettingsDAO(Future.value(isar))
        .putSettingStr(SettingKeys.lastQueueState, 'broken JSON');
    await tracks.purgeOrphanTracks();
    expect(await tracks.getTrackByMediaId('unverified'), isNotNull);
  });

  test(
      'case-insensitive playlist collisions are resolved under the transaction',
      () async {
    final first = await playlists.ensurePlaylist('Mix');
    final same = await playlists.ensurePlaylist('mix');
    expect(same, first);
    await playlists.addTrackToPlaylist(first, song('one'));
    final document = await backups.snapshot(playlistName: 'Mix');
    await backups.apply(
        document, const BackupSelection(mode: BackupImportMode.newCopy));
    expect(await ids('MIX (1)'), ['one']);
  });

  test('history merge preserves repeated events at an identical timestamp',
      () async {
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'backup',
      'tracks': [
        {'mediaId': 'one', 'title': 'One'}
      ],
      'playlists': [],
      'history': [
        {'mediaId': 'one', 'playedAt': '2026-01-01T00:00:00Z'},
        {'mediaId': 'one', 'playedAt': '2026-01-01T00:00:00Z'},
      ],
    });
    await backups.apply(document, const BackupSelection());
    await backups.apply(document, const BackupSelection());
    expect(await isar.playbackHistoryDBs.count(), 2);
  });

  test('playlist subscribers are notified by a merge into an existing playlist',
      () async {
    final id = await playlists.ensurePlaylist('Mix');
    await playlists.addTrackToPlaylist(id, song('one'));
    final document = BackupDocument.fromMap({
      'format': 'bloomee',
      'schemaVersion': 1,
      'kind': 'playlist',
      'tracks': [
        {'mediaId': 'two', 'title': 'Two'}
      ],
      'playlists': [
        {
          'name': 'Mix',
          'type': 'userPlaylist',
          'entries': ['two']
        }
      ],
    });
    final changed =
        isar.playlistDBs.watchLazy().first.timeout(const Duration(seconds: 2));
    await backups.apply(document, const BackupSelection());
    await changed;
    expect(await ids('Mix'), ['one', 'two']);
  });

  test('format recognition uses JSON structure even with a renamed extension',
      () async {
    await seed();
    final document = await backups.snapshot();
    final file = File(p.join(root.path, 'provider-renamed-document.data'));
    await file.writeAsString(jsonEncode(document.data));
    final decoded = await repository.prepare(file.path);
    expect(decoded.playlistCount, document.playlistCount);
    expect(file.existsSync(), true);
  });

  test('late playlist load cannot overwrite a newer selection', () async {
    await seed();
    final delayed = DelayedPlaylistDAO(Future.value(isar), tracks)
      ..blockedName = 'First';
    final cubit = CurrentPlaylistCubit(playlistDao: delayed);
    final old = cubit.openPlaylist('First');
    await cubit.openPlaylist('Second');
    delayed.headerGate.complete();
    await old;
    expect(cubit.state.playlist.title, 'Second');
    expect(cubit.state.playlist.tracks.map((t) => t.id), ['b', 'a']);
    await cubit.close();
  });

  test('play-all waits for an existing page load instead of spinning',
      () async {
    await seed();
    final delayed = DelayedPlaylistDAO(Future.value(isar), tracks)
      ..pageGate = Completer<void>();
    final cubit = CurrentPlaylistCubit(playlistDao: delayed);
    await cubit.openPlaylist('First', deferFirstPage: true);
    final page = cubit.loadMoreTracks();
    final all = cubit.ensureAllTracksLoaded();
    delayed.pageGate!.complete();
    await page;
    expect((await all).tracks.map((t) => t.id), ['a', 'b']);
    await cubit.close();
  });

  test(
      'large shared-track library preserves independent ordering in worker transactions',
      () async {
    final items = List.generate(2000, (i) => song('track-$i'));
    final first = await playlists.ensurePlaylist('Forward');
    final second = await playlists.ensurePlaylist('Reverse');
    await playlists.addTracksToPlaylist(first, items);
    await playlists.addTracksToPlaylist(second, items.reversed.toList());
    final document = await backups.snapshot();
    await backups.apply(
        document, const BackupSelection(mode: BackupImportMode.replace));
    expect(await ids('Forward'), items.map((t) => t.id).toList());
    expect(await ids('Reverse'), items.reversed.map((t) => t.id).toList());
    expect(isar.isOpen, true);
  });

  test(
      'settings reload retains correct field mapping after obsolete backup path removal',
      () async {
    final binding =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    binding.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => root.path);
    final settings = SettingsDAO(Future.value(isar));
    await settings.putSettingBool(SettingKeys.autoBackup, false);
    await settings.putSettingBool(SettingKeys.autoGetCountry, false);
    await settings.putSettingStr(SettingKeys.languageCode, 'hi');
    await settings.putSettingStr(SettingKeys.countryCode, 'IN');
    await settings.putSettingStr(SettingKeys.crossfadeDuration, '4');
    await settings.putSettingStr(SettingKeys.eqPreset, 'Rock');
    await settings.putSettingStr(SettingKeys.eqSource, 'device');
    await settings.putSettingStr(SettingKeys.homePluginId, 'home-plugin');
    final cubit = SettingsCubit(SettingsRepository(settings),
        backupRepository: repository);
    try {
      final state = await cubit.stream
          .firstWhere((s) => s.settingsReady)
          .timeout(const Duration(seconds: 3));
      expect(state.autoBackup, false);
      expect(state.autoGetCountry, false);
      expect(state.languageCode, 'hi');
      expect(state.countryCode, 'IN');
      expect(state.crossfadeDuration, 4);
      expect(state.eqPreset, 'Rock');
      expect(state.eqSource, 'device');
      expect(state.homePluginId, 'home-plugin');
      await cubit.reload();
      expect(cubit.state.languageCode, 'hi');
    } finally {
      await cubit.close();
      binding.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'), null);
    }
  });
}
