import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/services/local_music_service.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

part 'local_music_state.dart';

class LocalMusicCubit extends Cubit<LocalMusicState> {
  final LocalMusicService _service;

  LocalMusicCubit({LocalMusicService? service})
      : _service = service ?? LocalMusicService.create(),
        super(const LocalMusicInitial());

  /// Loads persisted tracks from DB, checks permission on Android, and
  /// auto-triggers a background scan if no tracks are cached yet.
  /// Always resolves to LocalMusicLoaded (or error/no-permission).
  Future<void> load() async {
    if (state is LocalMusicScanning) return;
    emit(const LocalMusicLoading());
    try {
      if (LocalMusicService.isMobile) {
        final granted = await _service.requestPermission();
        if (!granted) {
          emit(const LocalMusicNoPermission());
          return;
        }
      }
      final tracks = await _service.getLocalTracks();
      final folders = await _service.getFolders();
      emit(LocalMusicLoaded(tracks: tracks, folders: folders));
      if (tracks.isEmpty) scan();
    } catch (e, stack) {
      log('load failed: $e\n$stack', name: 'LocalMusicCubit');
      emit(LocalMusicError(e.toString()));
    }
  }

  Future<void> scan() async {
    if (LocalMusicService.isMobile) {
      final granted = await _service.ensureScanPermission();
      if (!granted) {
        emit(const LocalMusicNoPermission());
        return;
      }
    }

    if (state is LocalMusicScanning) return;
    final folders = await _service.getFolders();
    emit(LocalMusicScanning(folders: folders));
    try {
      final tracks = await _service.scanAndPersist();
      emit(LocalMusicLoaded(
        tracks: tracks,
        folders: await _service.getFolders(),
      ));
    } catch (e, stack) {
      log('scan failed: $e\n$stack', name: 'LocalMusicCubit');
      emit(LocalMusicError(e.toString()));
    }
  }

  Future<void> addFolderViaPicker() async {
    // Folder management only makes sense on desktop platforms.
    if (LocalMusicService.isMobile || Platform.isIOS) return;
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    await _service.addFolder(result);
    await scan();
  }

  Future<void> removeFolder(String path) async {
    await _service.removeFolder(path);
    await scan();
  }

  /// Add a folder to the scan list (desktop only).
  Future<void> addFolder(String path) async {
    await _service.addFolder(path);
  }

  /// Get the current list of scan folders.
  Future<List<String>> getFolders() => _service.getFolders();

  Future<void> resolvePermissionAction() async {
    if (!LocalMusicService.isMobile) {
      await load();
      return;
    }

    final granted =
        await _service.requestPermission(openSettingsIfDenied: true);
    if (granted) {
      await load();
      return;
    }

    emit(const LocalMusicNoPermission());
  }

  /// Delete a track and refresh the loaded list.
  Future<void> deleteTrack(Track track) async {
    await _service.deleteTrack(track);
    await _refreshLoadedTracks();
  }

  Future<List<String>> getUserPlaylistsContainingTrack(String mediaId) {
    return _service.getUserPlaylistsContainingTrack(mediaId);
  }

  /// Refresh without rescanning — just reload from DB.
  Future<void> _refreshLoadedTracks() async {
    final tracks = await _service.getLocalTracks();
    final folders = await _service.getFolders();
    emit(LocalMusicLoaded(tracks: tracks, folders: folders));
  }

  Future<bool> shouldConfirmDelete() => _service.shouldConfirmDelete();

  Future<void> setConfirmDelete(bool value) => _service.setConfirmDelete(value);

  Future<bool> getAutoScan() => _service.getAutoScan();

  Future<void> setAutoScan(bool value) => _service.setAutoScan(value);

  Future<String> getLastScan() => _service.getLastScan();

  /// Clean up artwork files not referenced by any track.
  Future<void> cleanOrphanedArtwork() => _service.cleanOrphanedArtwork();
}
