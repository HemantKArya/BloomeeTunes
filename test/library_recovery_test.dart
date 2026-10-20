import 'dart:ffi';
import 'dart:async';
import 'dart:io';
import 'package:Bloomee/repository/backup/backup_repository.dart';
import 'package:Bloomee/services/db/dao/backup_dao.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

Track song(String id, {String? title, String art = ''}) => Track(
    id: id,
    title: title ?? id,
    artists: const [],
    thumbnail: Artwork(url: art, layout: ImageLayout.square),
    isExplicit: false);

class DelayedFileResolver extends DownloadFileResolver {
  final entered = Completer<void>();
  final result = Completer<String?>();
  @override
  Future<String?> resolve(String directory, String name) {
    entered.complete();
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late Isar database;
  late BackupRepository repository;
  late DownloadDAO downloads;
  late PlaylistDAO playlists;
  late TrackDAO tracks;
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
    root = await Directory.systemTemp.createTemp('bloomee_recovery_test_');
    database = await Isar.open(DBProvider.schemas,
        directory: root.path, name: 'test', inspector: false);
    tracks = TrackDAO(Future.value(database));
    playlists = PlaylistDAO(Future.value(database), tracks);
    downloads = DownloadDAO(Future.value(database), tracks, playlists,
        fileResolver: DownloadFileResolver(
            supportPath: root.path, documentsPath: root.path));
    repository = BackupRepository(
        dao: BackupDAO(Future.value(database)),
        database: Future.value(database),
        supportPath: root.path,
        documentsPath: root.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => root.path);
  });
  tearDown(() async {
    if (database.isOpen) await database.close();
    await root.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
  });
  Future<File> retainedSnapshot() async {
    final playlist = await playlists.ensurePlaylist('Retained playlist');
    await playlists
        .addTracksToPlaylist(playlist, [song('old-b'), song('old-a')]);
    await playlists.ensurePlaylist('Retained empty');
    await playlists.setTrackLiked(song('old-a'), true);
    for (final id in ['old-a', 'old-b', 'metadata-only']) {
      await downloads.putDownload(
          fileName: '$id.m4a', filePath: root.path, track: song(id));
    }
    final path = p.join(root.path, 'bloomee_backup_dbv3.isar');
    await database.copyToFile(path);
    await database.writeTxn(() => database.clear());
    return File(path);
  }

  Future<List<String>> ids(String name) async {
    final playlist = await playlists.getPlaylistByName(name);
    return playlist == null
        ? []
        : (await playlists.getPlaylistTracks(playlist.id))
            .map((t) => t.mediaId)
            .toList();
  }

  test(
      'temporary file unavailability never deletes download records or playlist entries',
      () async {
    await downloads.putDownload(
        fileName: 'song.m4a', filePath: root.path, track: song('id'));
    final userPlaylist = await playlists.ensurePlaylist('User playlist');
    await playlists.addTracksToPlaylist(userPlaylist, [song('id')]);
    expect(await downloads.getValidDownloads(), isEmpty);
    expect(await downloads.getDownloadRecord('id'), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(await database.downloadDBs.count(), 1);
    expect(await ids('_DOWNLOADS'), ['id']);
    expect(await ids('User playlist'), ['id']);
    await File(p.join(root.path, 'song.m4a')).writeAsString('audio');
    expect((await downloads.getValidDownloads()).single.mediaId, 'id');
  });

  test('known app-container relocation repairs paths without filename guessing',
      () async {
    final destination =
        await Directory(p.join(root.path, 'Downloads')).create();
    await File(p.join(destination.path, 'song.m4a')).writeAsString('audio');
    await downloads.putDownload(
        fileName: 'song.m4a',
        filePath: '/data/user/0/ls.bloomee.musicplayer/files/Downloads',
        track: song('id'));
    expect(
        (await downloads.getDownloadRecord('id'))!.filePath, destination.path);
    expect((await database.downloadDBs.where().findFirst())!.filePath,
        destination.path);
    final resolver =
        DownloadFileResolver(supportPath: root.path, documentsPath: root.path);
    expect(await resolver.resolve('/unrelated/Downloads', 'song.m4a'), isNull);
    expect(await resolver.resolve('/unrelated/files/Downloads', 'song.m4a'),
        isNull);
    expect(
        await resolver.resolve(
            '/storage/emulated/0/Android/data/app/files/Downloads', 'song.m4a'),
        isNull);
    await File(p.join(root.path, 'root.m4a')).writeAsString('audio');
    expect(
        await resolver.resolve(
            '/data/data/ls.bloomee.musicplayer/app_flutter', 'root.m4a'),
        p.join(root.path, 'root.m4a'));
    expect(
        await resolver.resolve(
            '/var/mobile/Containers/Data/Application/OLD/Documents',
            'root.m4a'),
        p.join(root.path, 'root.m4a'));
    expect(await resolver.resolve(root.path, '../Downloads/song.m4a'), isNull);
    expect(await resolver.resolve('/data/old/files/../../outside', 'song.m4a'),
        isNull);
  });

  test(
      'retained v3 snapshot preserves source bytes, ordering, likes and unavailable mappings',
      () async {
    final source = await retainedSnapshot();
    final hash = sha256.convert(await source.readAsBytes());
    await File(p.join(root.path, 'old-a.m4a')).writeAsString('audio');
    final plan = await repository.prepareLibraryRecovery(source.path);
    expect(plan.downloads, hasLength(3));
    expect(plan.unavailableFiles, 2);
    expect(await database.trackDBs.count(), 0);
    expect((await repository.recoverLibrary(plan))['addedDownloads'], 3);
    expect(await ids('Retained playlist'), ['old-b', 'old-a']);
    expect(await ids('Liked'), ['old-a']);
    expect((await playlists.getPlaylistByName('Retained empty')), isNotNull);
    expect((await repository.recoverLibrary(plan))['addedEntries'], 0);
    expect(await database.downloadDBs.count(), 3);
    expect(await downloads.getValidDownloads(), hasLength(1));
    expect(await database.downloadDBs.count(), 3);
    expect(sha256.convert(await source.readAsBytes()), hash);
  });

  test('snapshot recovery preserves newer metadata and download mappings',
      () async {
    final source = await retainedSnapshot();
    await downloads.putDownload(
        fileName: 'new.m4a',
        filePath: root.path,
        track: song('old-a', title: 'Updated title'));
    final playlist = await playlists.ensurePlaylist('Retained playlist');
    await playlists.addTracksToPlaylist(
        playlist, [song('new-song'), song('old-a', title: 'Updated title')]);
    final plan = await repository.prepareLibraryRecovery(source.path);
    await repository.recoverLibrary(plan);
    expect((await tracks.getTrackByMediaId('old-a'))!.title, 'Updated title');
    expect(await ids('Retained playlist'), ['new-song', 'old-a', 'old-b']);
    expect(
        (await database.downloadDBs
                .filter()
                .mediaIdEqualTo('old-a')
                .findFirst())!
            .fileName,
        'new.m4a');
  });

  test(
      'recovery conflict rolls back all changes and retains protection snapshot',
      () async {
    final source = await retainedSnapshot();
    await database.writeTxn(() => database.playlistDBs.put(
        PlaylistDB(name: 'Retained playlist', type: PlaylistTypeDB.artist)));
    final plan = await repository.prepareLibraryRecovery(source.path);
    await expectLater(repository.recoverLibrary(plan), throwsStateError);
    expect(await database.trackDBs.count(), 0);
    expect(await database.downloadDBs.count(), 0);
    expect(await database.playlistDBs.count(), 1);
    expect(await repository.recoverySnapshots(), hasLength(1));
    expect(database.isOpen, true);
  });

  test('retired pre-v3 database names are not offered or opened for recovery',
      () async {
    final old = await File(p.join(root.path, 'default.isar.migrated'))
        .writeAsString('retired data');
    final sources = await repository.libraryRecoverySources();
    expect(sources.any((s) => s.path == old.path), false);
    await expectLater(
        repository.prepareLibraryRecovery(old.path), throwsFormatException);
    expect(await old.readAsString(), 'retired data');
  });

  test(
      'current database snapshot recovers orphan metadata and reports broken links',
      () async {
    final playlist = await playlists.ensurePlaylist('Broken playlist');
    await playlists.addTracksToPlaylist(playlist, [song('lost-link')]);
    await tracks.upsertTrack(song('orphan'));
    await database.writeTxn(() =>
        database.trackDBs.filter().mediaIdEqualTo('lost-link').deleteAll());
    await downloads.putDownloadRecord(
        fileName: 'old.m4a', filePath: root.path, track: song('download'));
    final livePath = p.join(root.path, 'test.isar');
    final plan = await repository.prepareLibraryRecovery(livePath);
    expect(plan.brokenEntries, 1);
    expect(plan.downloads, hasLength(1));
    expect(
        plan.document
            .rows('playlists')
            .firstWhere((p) => p['name'] == 'Recovered tracks')['entries'],
        ['orphan']);
    await repository.recoverLibrary(plan);
    expect(await ids('_DOWNLOADS'), ['download']);
    expect(await ids('Recovered tracks'), ['orphan']);
    expect(database.isOpen, true);
  });

  test('invalid source cannot mutate the live database', () async {
    final source = await File(p.join(root.path, 'bloomee_backup_dbv3.isar'))
        .writeAsString('not a database');
    await expectLater(
        repository.prepareLibraryRecovery(source.path), throwsA(anything));
    expect(await database.trackDBs.count(), 0);
    expect(await source.readAsString(), 'not a database');
    expect(database.isOpen, true);
  });

  test('recovery keeps local file mappings in Local Music instead of Downloads',
      () async {
    await downloads.putDownloadRecord(
        fileName: 'local.m4a', filePath: root.path, track: song('local::123'));
    await downloads.putDownloadRecord(
        fileName: 'download.m4a', filePath: root.path, track: song('remote'));
    final plan =
        await repository.prepareLibraryRecovery(p.join(root.path, 'test.isar'));
    await repository.recoverLibrary(plan);
    expect(await ids('_LOCAL_MUSIC'), ['local::123']);
    expect(await ids('_DOWNLOADS'), ['remote']);
  });

  for (final remove in [true, false]) {
    test(
        'path checking cannot ${remove ? 'resurrect a removed row' : 'overwrite a concurrent download'}',
        () async {
      await downloads.putDownload(
          fileName: 'old.m4a', filePath: '/old/files', track: song('id'));
      final resolver = DelayedFileResolver();
      final delayed = DownloadDAO(Future.value(database), tracks, playlists,
          fileResolver: resolver);
      final lookup = delayed.getDownloadRecord('id');
      await resolver.entered.future;
      if (remove) {
        await downloads.removeDownloadRecord('id');
      } else {
        await downloads.putDownload(
            fileName: 'new.m4a', filePath: root.path, track: song('id'));
      }
      resolver.result.complete(p.join(root.path, 'old.m4a'));
      expect(await lookup, isNull);
      final row = await database.downloadDBs.where().findFirst();
      if (remove) {
        expect(row, isNull);
      } else {
        expect(row!.fileName, 'new.m4a');
      }
    });
  }

  test('database in the historical documents directory is a recoverable source',
      () async {
    final documents = await Directory(p.join(root.path, 'documents')).create();
    final playlist = await playlists.ensurePlaylist('Documents playlist');
    await playlists.addTracksToPlaylist(playlist, [song('retained')]);
    await database.copyToFile(p.join(documents.path, 'dbv3.isar'));
    await database.writeTxn(() => database.clear());
    final repository = BackupRepository(
        dao: BackupDAO(Future.value(database)),
        database: Future.value(database),
        supportPath: root.path,
        documentsPath: documents.path);
    final source = (await repository.libraryRecoverySources())
        .singleWhere((s) => p.dirname(s.path) == documents.path);
    final plan = await repository.prepareLibraryRecovery(source.path);
    await repository.recoverLibrary(plan);
    expect(await ids('Documents playlist'), ['retained']);
  });

  test('protection snapshot failure prevents all recovery mutations', () async {
    final source = await retainedSnapshot();
    final plan = await repository.prepareLibraryRecovery(source.path);
    await File(p.join(root.path, 'backups'))
        .writeAsString('blocks directory creation');
    await expectLater(
        repository.recoverLibrary(plan), throwsA(isA<FileSystemException>()));
    expect(await database.trackDBs.count(), 0);
    expect(await database.downloadDBs.count(), 0);
    expect(await database.playlistDBs.count(), 0);
  });

  test(
      'large offline library uses bulk metadata without losing download ordering',
      () async {
    final art = await File(p.join(root.path, 'art.jpg')).writeAsString('art');
    final audio =
        await File(p.join(root.path, 'audio.m4a')).writeAsString('audio');
    final songs = List.generate(1001, (i) => song('large-$i', art: art.path));
    await tracks.upsertTracks(songs);
    database.writeTxnSync(() {
      for (var i = 0; i < songs.length; i++) {
        database.downloadDBs.putSync(DownloadDB(
            fileName: p.basename(audio.path),
            filePath: root.path,
            lastDownloaded: DateTime.utc(2024).add(Duration(seconds: i)),
            mediaId: songs[i].id));
      }
    });
    final loaded = await downloads.getValidDownloadedTracks();
    expect(loaded, hasLength(1001));
    expect(loaded.first.id, 'large-1000');
    expect(loaded.last.id, 'large-0');
  });

  test('optional artwork cache failure cannot hide playable downloads',
      () async {
    await File(p.join(root.path, 'song.m4a')).writeAsString('audio');
    await downloads.putDownload(
        fileName: 'song.m4a', filePath: root.path, track: song('id'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => throw PlatformException(code: 'unavailable'));
    expect((await downloads.getValidDownloadedTracks()).single.id, 'id');
  });
}
