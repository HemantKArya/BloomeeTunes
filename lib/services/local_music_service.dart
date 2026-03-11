import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/src/rust/api/local_music.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalMusicService {
  final DownloadDAO _downloadDao;
  final PlaylistDAO _playlistDao;
  final SettingsDAO _settingsDao;

  /// Android gets automatic full-library discovery via MediaStore.
  /// All other platforms (iOS, Windows, Linux, macOS) use folder-based scanning.
  static bool get isMobile => Platform.isAndroid;
  static const PermissionRequestOption _audioPermissionRequest =
      PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.audio,
      mediaLocation: false,
    ),
  );
  static const Set<String> _builtInPlaylistNames = {
    SettingKeys.localMusicPlaylist,
    SettingKeys.downloadPlaylist,
    SettingKeys.recentlyPlayedPlaylist,
    PlaylistDAO.likedPlaylist,
  };

  LocalMusicService({
    required DownloadDAO downloadDao,
    required PlaylistDAO playlistDao,
    required SettingsDAO settingsDao,
  })  : _downloadDao = downloadDao,
        _playlistDao = playlistDao,
        _settingsDao = settingsDao;

  factory LocalMusicService.create() {
    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    return LocalMusicService(
      downloadDao: DownloadDAO(DBProvider.db, trackDao, playlistDao),
      playlistDao: playlistDao,
      settingsDao: SettingsDAO(DBProvider.db),
    );
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  /// Request the permissions needed to access audio files on this platform.
  /// Returns `true` if access is granted (desktop always returns true).
  Future<PermissionState> getPermissionState() async {
    if (!isMobile) return PermissionState.authorized;
    return PhotoManager.getPermissionState(
      requestOption: _audioPermissionRequest,
    );
  }

  Future<bool> requestPermission({bool openSettingsIfDenied = false}) async {
    if (!isMobile) return true;

    var permissionState = await getPermissionState();
    if (!permissionState.hasAccess) {
      permissionState = await PhotoManager.requestPermissionExtend(
        requestOption: _audioPermissionRequest,
      );
    }

    if (!permissionState.hasAccess && openSettingsIfDenied) {
      await PhotoManager.openSetting();
    }

    return permissionState.hasAccess;
  }

  Future<void> openPermissionSettings() async {
    if (!isMobile) return;
    await PhotoManager.openSetting();
  }

  Future<bool> ensureScanPermission() async {
    if (!isMobile) return true;

    final permissionState = await getPermissionState();
    if (permissionState.hasAccess) return true;

    return requestPermission();
  }

  // ── Scanning ────────────────────────────────────────────────────────────────

  Future<List<Track>> scanAndPersist() async {
    return isMobile ? _scanMobile() : _scanDesktop();
  }

  /// Android: MediaStore enumeration via photo_manager → Lofty metadata.
  Future<List<Track>> _scanMobile() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      onlyAll: true,
    );
    if (albums.isEmpty) return [];

    final album = albums.first;
    final count = await album.assetCountAsync;
    if (count == 0) return [];

    final coverCacheDir = await _getCoverCacheDir();
    final playlistId =
        await _playlistDao.ensurePlaylist(SettingKeys.localMusicPlaylist);

    final tracks = <Track>[];
    final scannedMediaIds = <String>{};
    const pageSize = 200;

    for (int start = 0; start < count; start += pageSize) {
      final end = (start + pageSize).clamp(0, count);
      final assets = await album.getAssetListRange(start: start, end: end);

      // Parallel platform-channel calls for file paths.
      final fileResults = await Future.wait(assets.map((a) => a.file));

      for (int i = 0; i < assets.length; i++) {
        final asset = assets[i];
        final file = fileResults[i];
        if (file == null) continue;

        final filePath = file.path;
        final mediaId = buildMobileLocalMediaId(asset.id);
        scannedMediaIds.add(mediaId);

        try {
          final meta = await readAudioMetadata(
            filePath: filePath,
            coverCacheDir: coverCacheDir,
          );

          // Fall back to MediaStore thumbnail when embedded art is absent.
          String? artPath = meta.coverArtPath;
          artPath ??= await _cacheMobileThumbnail(
            asset: asset,
            coverCacheDir: coverCacheDir,
          );

          final track = _metaToTrack(meta, mediaId, artPath);
          tracks.add(track);

          await _downloadDao.putDownloadRecord(
            fileName: p.basename(filePath),
            filePath: p.dirname(filePath),
            track: track,
            lastDownloaded: file.lastModifiedSync(),
          );
          await _playlistDao.addTrackToPlaylist(playlistId, track);
        } catch (e) {
          log('Skipping $filePath: $e', name: 'LocalMusicService');
        }
      }
    }

    await _pruneDeletedTracks(playlistId, scannedMediaIds);
    await _settingsDao.putSettingStr(
      SettingKeys.localMusicLastScan,
      DateTime.now().toIso8601String(),
    );
    log('Mobile scan done: ${tracks.length} tracks', name: 'LocalMusicService');
    return tracks;
  }

  /// Desktop: configured folders → Rust/Lofty metadata.
  /// Seeds default Music/Downloads folders on first run (Windows/Linux/macOS).
  Future<List<Track>> _scanDesktop() async {
    var folders = await getFolders();

    if (folders.isEmpty) {
      folders = await _defaultDesktopFolders();
      for (final f in folders) {
        await addFolder(f);
      }
    }

    if (folders.isEmpty) return [];

    final coverCacheDir = await _getCoverCacheDir();
    log('Scanning ${folders.length} folder(s)…', name: 'LocalMusicService');

    final metas = await scanAudioFiles(
      directories: folders,
      coverCacheDir: coverCacheDir,
    );

    final playlistId =
        await _playlistDao.ensurePlaylist(SettingKeys.localMusicPlaylist);

    final tracks = <Track>[];
    final scannedMediaIds = <String>{};

    for (final meta in metas) {
      final mediaId = buildLocalMediaId(meta.filePath);
      scannedMediaIds.add(mediaId);
      final track = _metaToTrack(meta, mediaId, meta.coverArtPath);
      tracks.add(track);

      await _downloadDao.putDownloadRecord(
        fileName: p.basename(meta.filePath),
        filePath: p.dirname(meta.filePath),
        track: track,
        lastDownloaded: _fileLastModified(meta.filePath),
      );
      await _playlistDao.addTrackToPlaylist(playlistId, track);
    }

    await _pruneDeletedTracks(playlistId, scannedMediaIds);
    await _settingsDao.putSettingStr(
      SettingKeys.localMusicLastScan,
      DateTime.now().toIso8601String(),
    );
    log('Desktop scan done: ${tracks.length} tracks',
        name: 'LocalMusicService');
    return tracks;
  }

  // ── Library access ──────────────────────────────────────────────────────────

  Future<List<Track>> getLocalTracks() async {
    final playlist =
        await _playlistDao.loadPlaylist(SettingKeys.localMusicPlaylist);
    return playlist.tracks;
  }

  Future<List<String>> getUserPlaylistsContainingTrack(String mediaId) async {
    final playlistNames =
        await _playlistDao.getPlaylistsContainingTrack(mediaId);
    final userPlaylists = playlistNames
        .where((name) => !_builtInPlaylistNames.contains(name))
        .toList()
      ..sort();
    return userPlaylists;
  }

  // ── Deletion ───────────────────────────────────────────────────────────────

  /// Delete a local track: remove the audio file, its artwork cache, and all
  /// DB records (download record, playlist entry, orphan track row).
  Future<void> deleteTrack(Track track) async {
    final record = await _downloadDao.getDownloadRecord(track.id);

    final deletedFromDevice = await _deleteTrackFromDevice(
      track: track,
      record: record,
    );
    if (!deletedFromDevice) {
      throw FileSystemException(
        'Failed to delete the selected track from device storage.',
      );
    }

    // Clean up cached artwork.
    await _deleteCachedArtwork(track);

    await _removeTrackFromAllPlaylists(track.id);

    // Remove download record (without re-deleting the file).
    await _downloadDao.removeDownloadRecord(track.id);

    log('Deleted local track: ${track.title}', name: 'LocalMusicService');
  }

  Future<bool> _deleteTrackFromDevice({
    required Track track,
    required DownloadDB? record,
  }) async {
    if (isMobile && isLocalMediaId(track.id)) {
      final assetId = localIdOf(track.id);
      if (assetId == null || assetId.isEmpty) {
        return false;
      }
      try {
        final deletedIds = await PhotoManager.editor.deleteWithIds([assetId]);
        final deleted = deletedIds.contains(assetId);
        if (deleted) {
          log('Deleted MediaStore asset: $assetId', name: 'LocalMusicService');
        }
        return deleted;
      } catch (e) {
        log('Failed to delete MediaStore asset $assetId: $e',
            name: 'LocalMusicService');
        return false;
      }
    }

    if (record == null) {
      return false;
    }

    final filePath = p.join(record.filePath, record.fileName);
    return _deleteFile(filePath);
  }

  /// Delete the cached cover art file for a track.
  Future<void> _deleteCachedArtwork(Track track) async {
    final artUrl = track.thumbnail.url;
    if (artUrl.isEmpty) return;

    try {
      final stillReferenced = await _isArtworkStillReferenced(
        deletedTrackId: track.id,
        artworkPath: artUrl,
      );
      if (stillReferenced) {
        return;
      }

      final file = File(artUrl);
      if (await file.exists()) {
        await file.delete();
        log('Deleted artwork cache: $artUrl', name: 'LocalMusicService');
      }
    } catch (e) {
      log('Failed to delete artwork: $e', name: 'LocalMusicService');
    }
  }

  /// Remove orphaned artwork files not referenced by any current local track.
  Future<void> cleanOrphanedArtwork() async {
    final coverDir = Directory(await _getCoverCacheDir());
    if (!coverDir.existsSync()) return;

    final tracks = await getLocalTracks();
    final referencedPaths = <String>{};
    for (final track in tracks) {
      if (track.thumbnail.url.isNotEmpty) {
        referencedPaths.add(track.thumbnail.url);
      }
      if (track.thumbnail.urlLow != null &&
          track.thumbnail.urlLow!.isNotEmpty) {
        referencedPaths.add(track.thumbnail.urlLow!);
      }
    }

    await for (final entity in coverDir.list()) {
      if (entity is File && !referencedPaths.contains(entity.path)) {
        try {
          await entity.delete();
          log('Removed orphan artwork: ${entity.path}',
              name: 'LocalMusicService');
        } catch (e) {
          log('Failed to remove orphan: $e', name: 'LocalMusicService');
        }
      }
    }
  }

  /// Platform-appropriate file deletion.
  Future<bool> _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        log('Deleted file: $filePath', name: 'LocalMusicService');
        return true;
      }
      return false;
    } catch (e) {
      log('Failed to delete file $filePath: $e', name: 'LocalMusicService');
      return false;
    }
  }

  Future<bool> _isArtworkStillReferenced({
    required String deletedTrackId,
    required String artworkPath,
  }) async {
    final localTracks = await getLocalTracks();
    for (final track in localTracks) {
      if (track.id == deletedTrackId) continue;
      if (track.thumbnail.url == artworkPath ||
          track.thumbnail.urlLow == artworkPath ||
          track.thumbnail.urlHigh == artworkPath) {
        return true;
      }
    }
    return false;
  }

  Future<void> _removeTrackFromAllPlaylists(String mediaId) async {
    final playlistNames =
        await _playlistDao.getPlaylistsContainingTrack(mediaId);
    for (final name in playlistNames) {
      final playlist = await _playlistDao.getPlaylistByName(name);
      if (playlist == null) continue;
      await _playlistDao.removeTrackFromPlaylist(playlist.id, mediaId);
    }
  }

  /// Get/set the user preference for whether to confirm before deleting.
  Future<bool> shouldConfirmDelete() async {
    final val = await _settingsDao.getSettingStr(
      SettingKeys.localMusicConfirmDelete,
      defaultValue: 'true',
    );
    return val != 'false';
  }

  Future<void> setConfirmDelete(bool confirm) async {
    await _settingsDao.putSettingStr(
      SettingKeys.localMusicConfirmDelete,
      confirm.toString(),
    );
  }

  Future<bool> getAutoScan() async {
    final val = await _settingsDao.getSettingBool(
      SettingKeys.localMusicAutoScan,
      defaultValue: true,
    );
    return val ?? true;
  }

  Future<void> setAutoScan(bool value) async {
    await _settingsDao.putSettingBool(SettingKeys.localMusicAutoScan, value);
  }

  Future<String> getLastScan() async {
    return await _settingsDao.getSettingStr(
          SettingKeys.localMusicLastScan,
          defaultValue: '',
        ) ??
        '';
  }
  // ── Folder management (desktop only) ───────────────────────────────────────

  Future<List<String>> getFolders() async {
    if (isMobile) return [];
    final json = await _settingsDao.getSettingStr(
      SettingKeys.localMusicFolders,
      defaultValue: '[]',
    );
    try {
      return List<String>.from(jsonDecode(json ?? '[]'));
    } catch (_) {
      return [];
    }
  }

  Future<void> addFolder(String path) async {
    if (isMobile) return;
    final folders = await getFolders();
    if (!folders.contains(path)) {
      folders.add(path);
      await _saveFolders(folders);
    }
  }

  Future<void> removeFolder(String path) async {
    if (isMobile) return;
    final folders = await getFolders();
    folders.remove(path);
    await _saveFolders(folders);
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  Track _metaToTrack(LocalTrackMeta meta, String mediaId, [String? artPath]) {
    final artists =
        meta.artists.map((name) => ArtistSummary(id: '', name: name)).toList();

    AlbumSummary? album;
    if (meta.album != null && meta.album!.isNotEmpty) {
      album = AlbumSummary(
        id: '',
        title: meta.album!,
        artists: artists,
        year: meta.year,
      );
    }

    final artwork = Artwork(
      url: artPath ?? '',
      urlLow: artPath,
      layout: ImageLayout.square,
    );

    return Track(
      id: mediaId,
      title: meta.title ?? p.basenameWithoutExtension(meta.filePath),
      artists: artists,
      album: album,
      durationMs: meta.durationMs,
      thumbnail: artwork,
      isExplicit: false,
    );
  }

  /// Cache a MediaStore thumbnail for an audio asset into our cover-art dir.
  /// Uses `asset.id` as the stable cache key.
  Future<String?> _cacheMobileThumbnail({
    required AssetEntity asset,
    required String coverCacheDir,
  }) async {
    final cacheFile = File(p.join(coverCacheDir, '${asset.id}.jpg'));
    if (cacheFile.existsSync()) return cacheFile.path;

    final data = await asset.thumbnailDataWithSize(
      const ThumbnailSize.square(512),
    );
    if (data == null || data.isEmpty) return null;

    await cacheFile.parent.create(recursive: true);
    await cacheFile.writeAsBytes(data, flush: true);
    return cacheFile.path;
  }

  Future<void> _pruneDeletedTracks(
    int playlistId,
    Set<String> scannedMediaIds,
  ) async {
    final existingTracks = await _playlistDao.getPlaylistTracks(playlistId);
    for (final trackDB in existingTracks) {
      if (!isLocalMediaId(trackDB.mediaId)) continue;
      if (scannedMediaIds.contains(trackDB.mediaId)) continue;

      await _playlistDao.removeTrackFromPlaylist(playlistId, trackDB.mediaId);
      await _downloadDao.removeDownloadRecord(trackDB.mediaId);
      log('Pruned: ${trackDB.title}', name: 'LocalMusicService');
    }
  }

  Future<void> _saveFolders(List<String> folders) async {
    await _settingsDao.putSettingStr(
      SettingKeys.localMusicFolders,
      jsonEncode(folders),
    );
  }

  Future<String> _getCoverCacheDir() async {
    final cacheDir = await getApplicationCacheDirectory();
    return p.join(cacheDir.path, 'local_cover_art');
  }

  DateTime? _fileLastModified(String filePath) {
    try {
      return File(filePath).lastModifiedSync();
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _defaultDesktopFolders() async {
    final dirs = <String>[];
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final music = Directory(p.join(userProfile, 'Music'));
        if (music.existsSync()) dirs.add(music.path);
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final music = Directory(p.join(home, 'Music'));
        if (music.existsSync()) dirs.add(music.path);
      }
    }
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null && downloads.existsSync()) {
        dirs.add(downloads.path);
      }
    } catch (_) {}
    return dirs;
  }
}
