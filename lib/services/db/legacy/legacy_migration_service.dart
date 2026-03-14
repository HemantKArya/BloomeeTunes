library;

import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/core/models/exported.dart' as models;
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/library_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/legacy/legacy_db_opener.dart'
    as legacy_opener;
import 'package:Bloomee/services/db/legacy/legacy_global_db.dart' as legacy;
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

const _pluginJisSaavn = 'content-resolver.bloomfactory.jisaavn';
const _pluginYtMusic = 'content-resolver.bloomfactory.ytmusic';
const _pluginYtVideo = 'content-resolver.bloomfactory.ytvideo';
const _likedPlaylistName = 'Liked';
const _skipPlaylistNames = {
  '_DOWNLOADS',
  'recently_played',
  _likedPlaylistName,
};
const _lfmStringKeys = [
  'lastFMKey',
  'lastFMSession',
  'lastFMSecret',
  'lastFMUIPicks',
  'lastFMUsernames',
  'lastFMTrackedCacheForFutureScrobble',
];
const _lfmBoolKeys = ['lastFMScrobble'];

typedef MigrationProgressCallback = void Function(String step, double progress);

class LegacyDbLocation {
  const LegacyDbLocation({
    required this.directory,
    required this.filePath,
  });

  final String directory;
  final String filePath;
}

LegacyDbLocation? findLegacyDbLocation({
  required String appSuppDir,
  required String appDocDir,
}) {
  final candidates = <LegacyDbLocation>[];
  final seenPaths = <String>{};

  void addCandidate(String dir) {
    final filePath = p.join(dir, 'default.isar');
    if (!seenPaths.add(filePath)) return;
    if (File(filePath).existsSync()) {
      candidates.add(LegacyDbLocation(directory: dir, filePath: filePath));
    }
  }

  addCandidate(appSuppDir);
  addCandidate(appDocDir);

  if (candidates.isEmpty) return null;

  candidates.sort((a, b) {
    final aStat = File(a.filePath).statSync();
    final bStat = File(b.filePath).statSync();
    final modified = bStat.modified.compareTo(aStat.modified);
    if (modified != 0) return modified;
    final size = bStat.size.compareTo(aStat.size);
    if (size != 0) return size;
    if (a.directory == appSuppDir && b.directory != appSuppDir) return -1;
    if (b.directory == appSuppDir && a.directory != appSuppDir) return 1;
    return a.filePath.compareTo(b.filePath);
  });

  return candidates.first;
}

bool needsMigration(String appSuppDir, String appDocDir) =>
    findLegacyDbLocation(appSuppDir: appSuppDir, appDocDir: appDocDir) != null;

Future<MigrationResult> runMigration({
  required String appSuppDir,
  required String appDocDir,
  MigrationProgressCallback? onProgress,
}) async {
  final result = MigrationResult();
  LegacyDbLocation? legacyLocation;
  var legacyClosed = false;

  void report(String step, double progress) {
    final normalized = progress.clamp(0.0, 1.0);
    log('[$step] ${(normalized * 100).toStringAsFixed(0)}%',
        name: 'LegacyMigration');
    onProgress?.call(step, normalized);
  }

  try {
    legacyLocation = findLegacyDbLocation(
      appSuppDir: appSuppDir,
      appDocDir: appDocDir,
    );
    if (legacyLocation == null) {
      result.success = true;
      result.statusMessage = 'No legacy database found.';
      report('No legacy database found', 1.0);
      return result;
    }

    result.legacyDbPath = legacyLocation.filePath;
    report('Opening legacy database', 0.02);
    final legacyIsar =
        await legacy_opener.openLegacyDB(legacyLocation.directory);

    report('Scanning legacy data', 0.08);
    final plan = await _buildMigrationPlan(legacyIsar);
    result._applyCountsFromPlan(plan);

    report('Migrating playlists', 0.12);
    await _migratePlaylists(plan, result, report);

    report('Migrating liked tracks', 0.46);
    await _migrateLikedTracks(plan, result, report);

    report('Migrating downloads', 0.50);
    await _migrateDownloads(plan, result, report);

    report('Migrating library collections', 0.70);
    await _migrateCollections(plan, result, report);

    report('Migrating Last.fm settings', 0.84);
    await _migrateSettings(plan, result, report);

    report('Validating migrated data', 0.94);
    await _validateMigration(plan);

    await legacy_opener.closeLegacyDB();
    legacyClosed = true;
    _renameLegacyFiles(legacyLocation.filePath);

    result.success = true;
    result.statusMessage = result.totalSourceItems == 0
        ? 'Legacy database was empty.'
        : 'Legacy data migrated successfully.';
    report('Migration complete', 1.0);
  } catch (e, stack) {
    log('Migration failed',
        error: e, stackTrace: stack, name: 'LegacyMigration');
    result.success = false;
    result.error = e.toString();
    result.statusMessage = 'Migration failed before validation completed.';
  } finally {
    if (!legacyClosed) {
      try {
        await legacy_opener.closeLegacyDB();
      } catch (_) {}
    }
  }

  return result;
}

Future<_MigrationPlan> _buildMigrationPlan(Isar legacyIsar) async {
  final mediaItems =
      legacyIsar.collection<legacy.MediaItemDB>().where().findAllSync();
  final mediaById = <int, legacy.MediaItemDB>{
    for (final item in mediaItems)
      if (item.id != null) item.id!: item,
  };
  final mediaByLegacyMediaId = <String, legacy.MediaItemDB>{};
  for (final item in mediaItems) {
    if (item.mediaID.isEmpty) continue;
    mediaByLegacyMediaId.putIfAbsent(item.mediaID, () => item);
  }

  final playlistInfos =
      legacyIsar.collection<legacy.PlaylistsInfoDB>().where().findAllSync();
  final playlistInfoByName = <String, legacy.PlaylistsInfoDB>{
    for (final info in playlistInfos) info.playlistName: info,
  };

  final playlistPlans = <_PlaylistPlan>[];
  final likedTracksById = <String, models.Track>{};
  var skippedTracks = 0;

  final legacyPlaylists =
      legacyIsar.collection<legacy.MediaPlaylistDB>().where().findAllSync();
  for (var index = 0; index < legacyPlaylists.length; index++) {
    final playlist = legacyPlaylists[index];
    await playlist.mediaItems.load();

    final playlistName = playlist.playlistName.trim();
    final orderedItems = _resolveOrdered(playlist, mediaById);
    final plannedTracks = <models.Track>[];
    final seenTrackIds = <String>{};

    for (final item in orderedItems) {
      final track = _legacyItemToTrack(item);
      if (track == null) {
        skippedTracks++;
        continue;
      }

      if (playlistName == _likedPlaylistName) {
        likedTracksById.putIfAbsent(track.id, () => track);
        continue;
      }

      if (_skipPlaylistNames.contains(playlistName) || playlistName.isEmpty) {
        continue;
      }

      if (seenTrackIds.add(track.id)) {
        plannedTracks.add(track);
      }
    }

    if (!_skipPlaylistNames.contains(playlistName) &&
        playlistName.isNotEmpty &&
        plannedTracks.isNotEmpty) {
      final info = playlistInfoByName[playlistName];
      playlistPlans.add(
        _PlaylistPlan(
          name: playlistName,
          tracks: plannedTracks,
          artworkUrl: info?.artURL,
          description: info?.description,
          subtitle: info?.artists,
        ),
      );
    }

    await _yieldIfNeeded(index);
  }

  for (var index = 0; index < mediaItems.length; index++) {
    final item = mediaItems[index];
    if (!item.isLiked) continue;
    final track = _legacyItemToTrack(item);
    if (track == null) {
      skippedTracks++;
      continue;
    }
    likedTracksById.putIfAbsent(track.id, () => track);
    await _yieldIfNeeded(index);
  }

  final downloadPlans = <_DownloadPlan>[];
  final seenDownloadIds = <String>{};
  var skippedDownloads = 0;
  final legacyDownloads =
      legacyIsar.collection<legacy.DownloadDB>().where().findAllSync();
  for (var index = 0; index < legacyDownloads.length; index++) {
    final download = legacyDownloads[index];
    final mediaItem = mediaByLegacyMediaId[download.mediaId];
    final newMediaId = mediaItem != null
        ? _buildNewMediaId(
            download.mediaId,
            mediaItem.source ?? '',
            permaUrl: mediaItem.permaURL,
          )
        : _coerceExistingMediaId(download.mediaId);

    if (newMediaId == null) {
      skippedDownloads++;
      continue;
    }

    if (!seenDownloadIds.add(newMediaId)) {
      continue;
    }

    final track = mediaItem != null
        ? _buildTrack(mediaItem, newMediaId)
        : _dummyTrack(newMediaId);
    downloadPlans.add(
      _DownloadPlan(
        fileName: download.fileName,
        filePath: download.filePath,
        lastDownloaded: download.lastDownloaded,
        track: track,
      ),
    );

    await _yieldIfNeeded(index);
  }

  final collectionPlans = <_CollectionPlan>[];
  var skippedCollections = 0;
  final legacyCollections =
      legacyIsar.collection<legacy.SavedCollectionsDB>().where().findAllSync();
  for (var index = 0; index < legacyCollections.length; index++) {
    final collection = legacyCollections[index];
    final type = collection.type.toLowerCase();
    if (type != 'artist' && type != 'album') continue;

    final pluginId = _collectionSourceToPluginId(collection.source);
    final mediaId = _buildCollectionMediaId(collection.sourceId, pluginId);
    if (mediaId == null) {
      skippedCollections++;
      continue;
    }

    collectionPlans.add(
      _CollectionPlan(
        type: type == 'artist' ? PlaylistTypeDB.artist : PlaylistTypeDB.album,
        mediaId: mediaId,
        title: collection.title,
        subtitle: collection.subtitle,
        coverUrl: collection.coverArt,
        sourceUrl: collection.sourceURL,
        sourceDisplayName: _sourceDisplayName(pluginId),
      ),
    );

    await _yieldIfNeeded(index);
  }

  final stringSettings = <_StringSettingPlan>[];
  final strCollection = legacyIsar.collection<legacy.AppSettingsStrDB>();
  for (final key in _lfmStringKeys) {
    final row = strCollection.filter().settingNameEqualTo(key).findFirstSync();
    if (row != null && row.settingValue.isNotEmpty) {
      stringSettings.add(_StringSettingPlan(key: key, value: row.settingValue));
    }
  }

  final boolSettings = <_BoolSettingPlan>[];
  final boolCollection = legacyIsar.collection<legacy.AppSettingsBoolDB>();
  for (final key in _lfmBoolKeys) {
    final row = boolCollection.filter().settingNameEqualTo(key).findFirstSync();
    if (row != null) {
      boolSettings.add(_BoolSettingPlan(key: key, value: row.settingValue));
    }
  }

  return _MigrationPlan(
    playlists: playlistPlans,
    likedTracks: likedTracksById.values.toList(growable: false),
    downloads: downloadPlans,
    collections: collectionPlans,
    stringSettings: stringSettings,
    boolSettings: boolSettings,
    skippedTracks: skippedTracks,
    skippedDownloads: skippedDownloads,
    skippedCollections: skippedCollections,
  );
}

Future<void> _migratePlaylists(
  _MigrationPlan plan,
  MigrationResult result,
  MigrationProgressCallback report,
) async {
  if (plan.playlists.isEmpty) {
    report('No user playlists to migrate', 0.45);
    return;
  }

  final trackDao = TrackDAO(DBProvider.db);
  final playlistDao = PlaylistDAO(DBProvider.db, trackDao);

  for (var index = 0; index < plan.playlists.length; index++) {
    final playlist = plan.playlists[index];
    final progress = 0.12 + ((index + 1) / plan.playlists.length) * 0.33;
    report('Migrating playlist ${playlist.name}', progress);

    final playlistId = await playlistDao.ensurePlaylist(playlist.name);
    await playlistDao.updatePlaylistMeta(
      playlistId,
      thumbnail: _artworkDbFromUrl(playlist.artworkUrl),
      description: playlist.description,
      subtitle: playlist.subtitle,
    );
    await playlistDao.setPlaylistTracks(playlistId, playlist.tracks);

    result.playlistsMigrated++;
    result.tracksMigrated += playlist.tracks.length;
    await _yieldIfNeeded(index);
  }
}

Future<void> _migrateLikedTracks(
  _MigrationPlan plan,
  MigrationResult result,
  MigrationProgressCallback report,
) async {
  if (plan.likedTracks.isEmpty) {
    report('No liked tracks to migrate', 0.49);
    return;
  }

  final trackDao = TrackDAO(DBProvider.db);
  final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
  final likedId = await playlistDao.ensurePlaylist(_likedPlaylistName);
  await playlistDao.setPlaylistTracks(likedId, plan.likedTracks);
  result.likedTracksMigrated = plan.likedTracks.length;
  report('Migrated liked tracks', 0.49);
}

Future<void> _migrateDownloads(
  _MigrationPlan plan,
  MigrationResult result,
  MigrationProgressCallback report,
) async {
  if (plan.downloads.isEmpty) {
    report('No downloads to migrate', 0.68);
    return;
  }

  final trackDao = TrackDAO(DBProvider.db);
  final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
  final downloadDao = DownloadDAO(DBProvider.db, trackDao, playlistDao);

  for (var index = 0; index < plan.downloads.length; index++) {
    final download = plan.downloads[index];
    final progress = 0.50 + ((index + 1) / plan.downloads.length) * 0.18;
    report('Migrating download ${download.fileName}', progress);

    await downloadDao.putDownload(
      fileName: download.fileName,
      filePath: download.filePath,
      track: download.track,
      lastDownloaded: download.lastDownloaded,
    );
    result.downloadsMigrated++;
    await _yieldIfNeeded(index);
  }
}

Future<void> _migrateCollections(
  _MigrationPlan plan,
  MigrationResult result,
  MigrationProgressCallback report,
) async {
  if (plan.collections.isEmpty) {
    report('No library collections to migrate', 0.82);
    return;
  }

  final libraryDao = LibraryDAO(DBProvider.db);

  for (var index = 0; index < plan.collections.length; index++) {
    final collection = plan.collections[index];
    final progress = 0.70 + ((index + 1) / plan.collections.length) * 0.12;
    report('Migrating ${collection.type.name} ${collection.title}', progress);

    if (collection.type == PlaylistTypeDB.artist) {
      await libraryDao.saveArtist(
        models.ArtistSummary(
          id: collection.mediaId,
          name: collection.title,
          thumbnail: _artworkFromUrl(collection.coverUrl),
          subtitle: collection.subtitle,
          url: collection.sourceUrl.isEmpty ? null : collection.sourceUrl,
        ),
        sourceName: collection.sourceDisplayName,
      );
    } else {
      await libraryDao.saveAlbum(
        models.AlbumSummary(
          id: collection.mediaId,
          title: collection.title,
          artists: const [],
          thumbnail: _artworkFromUrl(collection.coverUrl),
          subtitle: collection.subtitle,
          url: collection.sourceUrl.isEmpty ? null : collection.sourceUrl,
        ),
        sourceName: collection.sourceDisplayName,
      );
    }

    result.collectionsMigrated++;
    await _yieldIfNeeded(index);
  }
}

Future<void> _migrateSettings(
  _MigrationPlan plan,
  MigrationResult result,
  MigrationProgressCallback report,
) async {
  final settingsDao = SettingsDAO(DBProvider.db);

  for (var index = 0; index < plan.stringSettings.length; index++) {
    final setting = plan.stringSettings[index];
    await settingsDao.putSettingStr(setting.key, setting.value);
    result.settingsMigrated++;
    await _yieldIfNeeded(index);
  }

  for (var index = 0; index < plan.boolSettings.length; index++) {
    final setting = plan.boolSettings[index];
    await settingsDao.putSettingBool(setting.key, setting.value);
    result.settingsMigrated++;
    await _yieldIfNeeded(index);
  }

  report('Last.fm settings migrated', 0.92);
}

Future<void> _validateMigration(_MigrationPlan plan) async {
  final isar = await DBProvider.db;
  final trackDao = TrackDAO(DBProvider.db);
  final playlistDao = PlaylistDAO(DBProvider.db, trackDao);

  for (final playlist in plan.playlists) {
    final playlistDb = await playlistDao.getPlaylistByName(playlist.name);
    if (playlistDb == null) {
      throw StateError('Playlist ${playlist.name} was not written to dbv3.');
    }

    final tracks = await playlistDao.getPlaylistTracks(playlistDb.id);
    final actualIds = tracks.map((track) => track.mediaId).toList();
    final expectedIds = playlist.tracks.map((track) => track.id).toList();
    if (!_sameStringList(actualIds, expectedIds)) {
      throw StateError(
          'Playlist ${playlist.name} order/content mismatch after migration.');
    }
  }

  if (plan.likedTracks.isNotEmpty) {
    final likedDb = await playlistDao.getPlaylistByName(_likedPlaylistName);
    if (likedDb == null) {
      throw StateError('Liked playlist was not written to dbv3.');
    }
    final tracks = await playlistDao.getPlaylistTracks(likedDb.id);
    final actualIds = tracks.map((track) => track.mediaId).toList();
    final expectedIds = plan.likedTracks.map((track) => track.id).toList();
    if (!_sameStringList(actualIds, expectedIds)) {
      throw StateError('Liked playlist content mismatch after migration.');
    }
  }

  final downloadCollection = isar.collection<DownloadDB>();
  for (final download in plan.downloads) {
    final row = downloadCollection
        .filter()
        .mediaIdEqualTo(download.track.id)
        .findFirstSync();
    if (row == null) {
      throw StateError(
          'Download ${download.track.id} missing after migration.');
    }
  }

  final playlistCollection = isar.collection<PlaylistDB>();
  for (final collection in plan.collections) {
    final row = playlistCollection
        .filter()
        .nameEqualTo(collection.mediaId)
        .and()
        .typeIndexEqualTo(collection.type.index)
        .findFirstSync();
    if (row == null) {
      throw StateError(
        '${collection.type.name} ${collection.mediaId} missing after migration.',
      );
    }
  }

  final stringCollection = isar.collection<AppSettingsStrDB>();
  for (final setting in plan.stringSettings) {
    final row = stringCollection
        .filter()
        .settingNameEqualTo(setting.key)
        .findFirstSync();
    if (row?.settingValue != setting.value) {
      throw StateError(
          'String setting ${setting.key} missing after migration.');
    }
  }

  final boolCollection = isar.collection<AppSettingsBoolDB>();
  for (final setting in plan.boolSettings) {
    final row =
        boolCollection.filter().settingNameEqualTo(setting.key).findFirstSync();
    if (row?.settingValue != setting.value) {
      throw StateError('Bool setting ${setting.key} missing after migration.');
    }
  }

  if (plan.totalSourceItems > 0 && plan.totalExpectedWrites == 0) {
    throw StateError(
        'Legacy database contained data but nothing was eligible for migration.');
  }
}

List<legacy.MediaItemDB> _resolveOrdered(
  legacy.MediaPlaylistDB playlist,
  Map<int, legacy.MediaItemDB> mediaById,
) {
  final ordered = <legacy.MediaItemDB>[];
  final ranks = playlist.mediaRanks;

  if (ranks.isEmpty) {
    ordered.addAll(playlist.mediaItems);
    return ordered;
  }

  for (final id in ranks) {
    final item = mediaById[id];
    if (item != null) {
      ordered.add(item);
    }
  }

  final rankedIds = ranks.toSet();
  for (final item in playlist.mediaItems) {
    final id = item.id;
    if (id == null || rankedIds.contains(id)) continue;
    ordered.add(item);
  }

  return ordered;
}

String? _collectionSourceToPluginId(String source) {
  final normalized = source.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  if (normalized.contains('saavn')) return _pluginJisSaavn;
  if (normalized == 'ytvideo' || normalized == 'ytv') return _pluginYtVideo;
  if (normalized.contains('youtube') ||
      normalized.contains('ytmusic') ||
      normalized == 'ytm') {
    return _pluginYtMusic;
  }
  return null;
}

String? _buildCollectionMediaId(String sourceId, String? pluginId) {
  if (sourceId.isEmpty) return null;
  final cleanedId = sourceId.replaceFirst('youtube', '');
  if (_isPluginScopedMediaId(cleanedId)) return cleanedId;
  if (pluginId == null) return null;
  return '$pluginId::$cleanedId';
}

String _sourceDisplayName(String? pluginId) {
  switch (pluginId) {
    case _pluginJisSaavn:
      return 'JioSaavn';
    case _pluginYtMusic:
      return 'YouTube Music';
    case _pluginYtVideo:
      return 'YouTube';
    default:
      return 'Unknown source';
  }
}

String? _coerceExistingMediaId(String rawId) {
  final cleanedId = rawId.replaceFirst('youtube', '');
  if (_isPluginScopedMediaId(cleanedId)) return cleanedId;
  return null;
}

bool _isPluginScopedMediaId(String value) =>
    value.startsWith('content-resolver.');

String? _buildNewMediaId(
  String rawId,
  String source, {
  String permaUrl = '',
}) {
  if (rawId.isEmpty) return null;
  final cleanedId = rawId.replaceFirst('youtube', '');
  if (_isPluginScopedMediaId(cleanedId)) return cleanedId;

  final normalizedSource = source.trim().toLowerCase();
  if (normalizedSource == 'saavn') {
    return '$_pluginJisSaavn::$cleanedId';
  }
  if (normalizedSource.contains('youtube') ||
      normalizedSource == 'ytm' ||
      normalizedSource == 'ytv') {
    return permaUrl.contains('music.youtube.com')
        ? '$_pluginYtMusic::$cleanedId'
        : '$_pluginYtVideo::$cleanedId';
  }
  return null;
}

models.Track? _legacyItemToTrack(legacy.MediaItemDB item) {
  final newMediaId = _buildNewMediaId(
    item.mediaID,
    item.source ?? '',
    permaUrl: item.permaURL,
  );
  if (newMediaId == null) return null;
  return _buildTrack(item, newMediaId);
}

models.Track _buildTrack(legacy.MediaItemDB item, String newMediaId) {
  final artists = item.artist
      .split(',')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty && name != 'Unknown')
      .map((name) => models.ArtistSummary(id: '', name: name))
      .toList(growable: false);

  models.AlbumSummary? album;
  if (item.album.isNotEmpty && item.album != 'Unknown') {
    album = models.AlbumSummary(
      id: '',
      title: item.album,
      artists: const [],
    );
  }

  final durationMs = (item.duration != null && item.duration! > 0)
      ? BigInt.from(item.duration! * 1000)
      : null;

  return models.Track(
    id: newMediaId,
    title: item.title.isNotEmpty ? item.title : newMediaId,
    artists: artists,
    album: album,
    durationMs: durationMs,
    thumbnail: models.Artwork(
      url: item.artURL,
      layout: models.ImageLayout.square,
    ),
    url: item.permaURL.isEmpty ? null : item.permaURL,
    isExplicit: false,
  );
}

models.Track _dummyTrack(String newMediaId) {
  return models.Track(
    id: newMediaId,
    title: newMediaId,
    artists: const [],
    thumbnail: const models.Artwork(
      url: '',
      layout: models.ImageLayout.square,
    ),
    isExplicit: false,
  );
}

models.Artwork? _artworkFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  return models.Artwork(url: url, layout: models.ImageLayout.square);
}

ArtworkDB? _artworkDbFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  return ArtworkDB()..url = url;
}

Future<void> _yieldIfNeeded(int index) async {
  if (index == 0) return;
  if (index % 4 != 0) return;
  await Future<void>.delayed(Duration.zero);
}

bool _sameStringList(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

void _renameLegacyFiles(String legacyDbPath) {
  try {
    final source = File(legacyDbPath);
    if (source.existsSync()) {
      source.renameSync('$legacyDbPath.migrated');
    }

    final lockFile = File('$legacyDbPath.lock');
    if (lockFile.existsSync()) {
      lockFile.renameSync('${lockFile.path}.migrated');
    }
  } catch (e) {
    log('Could not rename legacy DB after successful migration',
        error: e, name: 'LegacyMigration');
  }
}

class MigrationResult {
  bool success = false;
  String? error;
  String? statusMessage;
  String? legacyDbPath;

  int sourcePlaylists = 0;
  int sourceTracks = 0;
  int sourceLikedTracks = 0;
  int sourceDownloads = 0;
  int sourceCollections = 0;
  int sourceSettings = 0;

  int playlistsMigrated = 0;
  int tracksMigrated = 0;
  int likedTracksMigrated = 0;
  int downloadsMigrated = 0;
  int collectionsMigrated = 0;
  int settingsMigrated = 0;

  int skippedTracks = 0;
  int skippedDownloads = 0;
  int skippedCollections = 0;

  int get totalSourceItems =>
      sourcePlaylists +
      sourceTracks +
      sourceLikedTracks +
      sourceDownloads +
      sourceCollections +
      sourceSettings;

  void _applyCountsFromPlan(_MigrationPlan plan) {
    sourcePlaylists = plan.playlists.length;
    sourceTracks = plan.playlists.fold<int>(
      0,
      (count, playlist) => count + playlist.tracks.length,
    );
    sourceLikedTracks = plan.likedTracks.length;
    sourceDownloads = plan.downloads.length;
    sourceCollections = plan.collections.length;
    sourceSettings = plan.stringSettings.length + plan.boolSettings.length;
    skippedTracks = plan.skippedTracks;
    skippedDownloads = plan.skippedDownloads;
    skippedCollections = plan.skippedCollections;
  }

  @override
  String toString() {
    return 'MigrationResult(success=$success, playlists=$playlistsMigrated/$sourcePlaylists, '
        'tracks=$tracksMigrated/$sourceTracks, liked=$likedTracksMigrated/$sourceLikedTracks, '
        'downloads=$downloadsMigrated/$sourceDownloads, '
        'collections=$collectionsMigrated/$sourceCollections, '
        'settings=$settingsMigrated/$sourceSettings)';
  }
}

class _MigrationPlan {
  const _MigrationPlan({
    required this.playlists,
    required this.likedTracks,
    required this.downloads,
    required this.collections,
    required this.stringSettings,
    required this.boolSettings,
    required this.skippedTracks,
    required this.skippedDownloads,
    required this.skippedCollections,
  });

  final List<_PlaylistPlan> playlists;
  final List<models.Track> likedTracks;
  final List<_DownloadPlan> downloads;
  final List<_CollectionPlan> collections;
  final List<_StringSettingPlan> stringSettings;
  final List<_BoolSettingPlan> boolSettings;
  final int skippedTracks;
  final int skippedDownloads;
  final int skippedCollections;

  int get totalSourceItems =>
      playlists.length +
      playlists.fold<int>(0, (sum, playlist) => sum + playlist.tracks.length) +
      likedTracks.length +
      downloads.length +
      collections.length +
      stringSettings.length +
      boolSettings.length;

  int get totalExpectedWrites =>
      playlists.length +
      likedTracks.length +
      downloads.length +
      collections.length +
      stringSettings.length +
      boolSettings.length;
}

class _PlaylistPlan {
  const _PlaylistPlan({
    required this.name,
    required this.tracks,
    this.artworkUrl,
    this.description,
    this.subtitle,
  });

  final String name;
  final List<models.Track> tracks;
  final String? artworkUrl;
  final String? description;
  final String? subtitle;
}

class _DownloadPlan {
  const _DownloadPlan({
    required this.fileName,
    required this.filePath,
    required this.lastDownloaded,
    required this.track,
  });

  final String fileName;
  final String filePath;
  final DateTime? lastDownloaded;
  final models.Track track;
}

class _CollectionPlan {
  const _CollectionPlan({
    required this.type,
    required this.mediaId,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.sourceUrl,
    required this.sourceDisplayName,
  });

  final PlaylistTypeDB type;
  final String mediaId;
  final String title;
  final String? subtitle;
  final String coverUrl;
  final String sourceUrl;
  final String sourceDisplayName;
}

class _StringSettingPlan {
  const _StringSettingPlan({required this.key, required this.value});

  final String key;
  final String value;
}

class _BoolSettingPlan {
  const _BoolSettingPlan({required this.key, required this.value});

  final String key;
  final bool value;
}
