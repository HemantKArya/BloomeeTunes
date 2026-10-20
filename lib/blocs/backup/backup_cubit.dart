import 'dart:ui' show Rect;
import 'dart:developer';

import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/core/models/backup/recovery_copy.dart';
import 'package:Bloomee/repository/backup/backup_repository.dart';
import 'package:Bloomee/services/backup/backup_files.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackupState {
  final bool busy;
  final bool resetPending;
  const BackupState({this.busy = false, this.resetPending = false});
}

class BackupCubit extends Cubit<BackupState> {
  final BackupRepository repository;
  final BackupFiles files;
  final Future<void> Function()? refreshPreferences;
  String? _stagedPath;
  String? _deliveryId;
  bool _resetPending = false;
  bool get canShareFiles => files.canShareFiles;
  BackupCubit(this.repository, this.files, {this.refreshPreferences})
      : super(const BackupState());

  Future<BackupDocument?> prepare([String? path]) async {
    if (state.busy) {
      throw StateError('Another backup operation is already open.');
    }
    emit(BackupState(busy: true, resetPending: _resetPending));
    try {
      _stagedPath = path ?? await files.pick();
      if (_stagedPath == null) {
        await finish();
        return null;
      }
      _deliveryId = await files.deliveryId(_stagedPath!);
      return await repository.prepare(_stagedPath!);
    } catch (error) {
      await finish();
      rethrow;
    }
  }

  Future<Map<String, int>> apply(
      BackupDocument document, BackupSelection selection) async {
    final result =
        await repository.apply(document, selection, deliveryId: _deliveryId);
    if (selection.settings && refreshPreferences != null) {
      try {
        await refreshPreferences!();
      } catch (error, stack) {
        log('Preferences committed but player refresh failed',
            error: error, stackTrace: stack);
        result['refreshFailed'] = 1;
      }
    }
    return result;
  }

  Future<List<RecoveryCopy>> recoverySnapshots() =>
      repository.recoverySnapshots();

  Future<List<LibraryRecoverySource>> libraryRecoverySources() =>
      repository.libraryRecoverySources();

  Future<LibraryRecoveryPlan> prepareLibraryRecovery(String path) async {
    if (state.busy) {
      throw StateError('Another backup operation is already open.');
    }
    emit(BackupState(busy: true, resetPending: _resetPending));
    try {
      return await repository.prepareLibraryRecovery(path);
    } catch (_) {
      await finish();
      rethrow;
    }
  }

  Future<Map<String, int>> recoverLibrary(LibraryRecoveryPlan plan) =>
      repository.recoverLibrary(plan);

  Future<void> requestReset() async {
    if (state.busy) {
      throw StateError('Another backup operation is already open.');
    }
    emit(BackupState(busy: true, resetPending: _resetPending));
    try {
      await repository.requestReset();
      _resetPending = true;
    } finally {
      if (!isClosed) emit(BackupState(resetPending: _resetPending));
    }
  }

  Future<void> cancelReset() async {
    await repository.cancelReset();
    _resetPending = false;
    if (!isClosed) emit(const BackupState());
  }

  Future<void> finish() async {
    final path = _stagedPath;
    _stagedPath = null;
    _deliveryId = null;
    try {
      if (path != null) await files.release(path);
    } catch (error, stack) {
      log('Could not remove import staging file',
          error: error, stackTrace: stack);
    } finally {
      if (!isClosed) emit(BackupState(resetPending: _resetPending));
    }
  }

  Future<String?> export(
      {bool share = false, String? playlistName, Rect? origin}) async {
    if (state.busy) {
      throw StateError('Another backup operation is already open.');
    }
    emit(BackupState(busy: true, resetPending: _resetPending));
    try {
      final source = await repository.export(playlistName: playlistName);
      if (share && files.canShareFiles) {
        await files.share(source, origin: origin);
        return source;
      }
      return await files.save(source);
    } finally {
      if (!isClosed) emit(BackupState(resetPending: _resetPending));
    }
  }
}
