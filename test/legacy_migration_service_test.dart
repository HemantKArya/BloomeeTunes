import 'dart:io';

import 'package:Bloomee/services/db/dao/library_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/legacy/legacy_global_db.dart' as legacy;
import 'package:Bloomee/services/db/legacy/legacy_migration_service.dart'
    as migration;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('legacy migration', () {
    late Directory tempRoot;
    late Directory supportDir;
    late Directory docsDir;

    tearDown(() async {
      final currentDb = await DBProvider.db;
      if (currentDb.isOpen) {
        await currentDb.close();
      }

      final defaultDb = Isar.getInstance('default');
      if (defaultDb != null && defaultDb.isOpen) {
        await defaultDb.close();
      }

      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('migrates legacy data into dbv3 and validates visible app state',
        () async {
      tempRoot = await Directory.systemTemp.createTemp(
        'bloomee_legacy_migration_test_',
      );
      supportDir = Directory(p.join(tempRoot.path, 'support'))
        ..createSync(recursive: true);
      docsDir = Directory(p.join(tempRoot.path, 'docs'))
        ..createSync(recursive: true);

      await DBProvider.init(
        appSupportPath: supportDir.path,
        appDocumentsPath: docsDir.path,
      );
      await DBProvider.db;

      final legacyDb = Isar.openSync(
        const [
          legacy.MediaPlaylistDBSchema,
          legacy.MediaItemDBSchema,
          legacy.AppSettingsBoolDBSchema,
          legacy.AppSettingsStrDBSchema,
          legacy.DownloadDBSchema,
          legacy.SavedCollectionsDBSchema,
          legacy.PlaylistsInfoDBSchema,
        ],
        directory: docsDir.path,
        name: 'default',
      );

      final saavnTrack = legacy.MediaItemDB(
        title: 'Saavn Song',
        album: 'Saavn Album',
        artist: 'Singer One',
        artURL: 'https://img.test/saavn.jpg',
        genre: 'Pop',
        mediaID: 'saavn-1',
        streamingURL: 'https://stream.test/saavn',
        source: 'saavn',
        duration: 210,
        permaURL: 'https://www.jiosaavn.com/song/saavn-1',
        language: 'en',
        isLiked: true,
      );
      final ytmTrack = legacy.MediaItemDB(
        title: 'YTM Song',
        album: 'YTM Album',
        artist: 'Singer Two',
        artURL: 'https://img.test/ytm.jpg',
        genre: 'Pop',
        mediaID: 'yt-1',
        streamingURL: 'https://stream.test/ytm',
        source: 'youtube',
        duration: 180,
        permaURL: 'https://music.youtube.com/watch?v=yt-1',
        language: 'en',
        isLiked: false,
      );
      final roadtrip = legacy.MediaPlaylistDB(playlistName: 'Roadtrip');
      final liked = legacy.MediaPlaylistDB(playlistName: 'Liked');

      await legacyDb.writeTxn(() async {
        final saavnId =
            await legacyDb.collection<legacy.MediaItemDB>().put(saavnTrack);
        final ytmId =
            await legacyDb.collection<legacy.MediaItemDB>().put(ytmTrack);
        saavnTrack.id = saavnId;
        ytmTrack.id = ytmId;

        roadtrip.mediaRanks = [ytmId, saavnId];

        await legacyDb.collection<legacy.MediaPlaylistDB>().put(roadtrip);
        await legacyDb.collection<legacy.MediaPlaylistDB>().put(liked);

        saavnTrack.mediaInPlaylistsDB.add(roadtrip);
        saavnTrack.mediaInPlaylistsDB.add(liked);
        ytmTrack.mediaInPlaylistsDB.add(roadtrip);
        await saavnTrack.mediaInPlaylistsDB.save();
        await ytmTrack.mediaInPlaylistsDB.save();

        await legacyDb.collection<legacy.PlaylistsInfoDB>().put(
              legacy.PlaylistsInfoDB(
                playlistName: 'Roadtrip',
                lastUpdated: DateTime(2024, 1, 1),
                artURL: 'https://img.test/roadtrip.jpg',
                description: 'Legacy roadtrip playlist',
                artists: 'Singer One, Singer Two',
              ),
            );

        await legacyDb.collection<legacy.DownloadDB>().put(
              legacy.DownloadDB(
                fileName: 'ytm-song.mp3',
                filePath: 'C:/music/ytm-song.mp3',
                lastDownloaded: DateTime(2024, 2, 2),
                mediaId: 'youtubeyt-1',
              ),
            );

        await legacyDb.collection<legacy.SavedCollectionsDB>().putAll([
          legacy.SavedCollectionsDB(
            title: 'Legacy Artist',
            type: 'artist',
            coverArt: 'https://img.test/artist.jpg',
            sourceURL: 'https://www.jiosaavn.com/artist/legacy-artist',
            sourceId: 'artist-1',
            source: 'saavn',
            lastUpdated: DateTime(2024, 3, 1),
            subtitle: 'Popular artist',
          ),
          legacy.SavedCollectionsDB(
            title: 'Legacy Album',
            type: 'album',
            coverArt: 'https://img.test/album.jpg',
            sourceURL: 'https://music.youtube.com/playlist?list=album-1',
            sourceId: 'youtubealbum-1',
            source: 'youtube',
            lastUpdated: DateTime(2024, 3, 2),
            subtitle: 'Popular album',
          ),
        ]);

        await legacyDb.collection<legacy.AppSettingsStrDB>().putAll([
          legacy.AppSettingsStrDB(
            settingName: 'lastFMKey',
            settingValue: 'legacy-key',
          ),
          legacy.AppSettingsStrDB(
            settingName: 'lastFMSession',
            settingValue: 'legacy-session',
          ),
        ]);
        await legacyDb.collection<legacy.AppSettingsBoolDB>().put(
              legacy.AppSettingsBoolDB(
                settingName: 'lastFMScrobble',
                settingValue: true,
              ),
            );
      });
      await legacyDb.close();

      final result = await migration.runMigration(
        appSuppDir: supportDir.path,
        appDocDir: docsDir.path,
      );

      expect(result.success, isTrue);
      expect(result.playlistsMigrated, 1);
      expect(result.likedTracksMigrated, 1);
      expect(result.downloadsMigrated, 1);
      expect(result.collectionsMigrated, 2);
      expect(result.settingsMigrated, 3);

      expect(File(p.join(docsDir.path, 'default.isar.migrated')).existsSync(),
          isTrue);

      final trackDao = TrackDAO(DBProvider.db);
      final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
      final libraryDao = LibraryDAO(DBProvider.db);
      final currentDb = await DBProvider.db;

      final roadtripDb = await playlistDao.getPlaylistByName('Roadtrip');
      expect(roadtripDb, isNotNull);
      final roadtripTracks =
          await playlistDao.getPlaylistTracks(roadtripDb!.id);
      expect(
        roadtripTracks.map((track) => track.mediaId).toList(),
        equals([
          'content-resolver.bloomfactory.ytmusic::yt-1',
          'content-resolver.bloomfactory.jisaavn::saavn-1',
        ]),
      );

      final likedDb = await playlistDao.getPlaylistByName('Liked');
      expect(likedDb, isNotNull);
      final likedTracks = await playlistDao.getPlaylistTracks(likedDb!.id);
      expect(
        likedTracks.map((track) => track.mediaId).toList(),
        equals(['content-resolver.bloomfactory.jisaavn::saavn-1']),
      );

      final downloadRow = currentDb
          .collection<DownloadDB>()
          .filter()
          .mediaIdEqualTo('content-resolver.bloomfactory.ytmusic::yt-1')
          .findFirstSync();
      expect(downloadRow, isNotNull);
      expect(downloadRow!.fileName, 'ytm-song.mp3');

      final savedArtists = await libraryDao.getSavedArtists();
      expect(
        savedArtists.any(
          (artist) =>
              artist.id == 'content-resolver.bloomfactory.jisaavn::artist-1',
        ),
        isTrue,
      );

      final savedAlbums = await libraryDao.getSavedAlbums();
      expect(
        savedAlbums.any(
          (album) =>
              album.id == 'content-resolver.bloomfactory.ytmusic::album-1',
        ),
        isTrue,
      );

      final lastFmKey = currentDb
          .collection<AppSettingsStrDB>()
          .filter()
          .settingNameEqualTo('lastFMKey')
          .findFirstSync();
      expect(lastFmKey?.settingValue, 'legacy-key');

      final lastFmScrobble = currentDb
          .collection<AppSettingsBoolDB>()
          .filter()
          .settingNameEqualTo('lastFMScrobble')
          .findFirstSync();
      expect(lastFmScrobble?.settingValue, isTrue);
    });
  });
}
