import 'dart:convert';
import 'dart:developer';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:rxdart/rxdart.dart';

List<int> generateRandomIndices(int length) {
  final indices = List<int>.generate(length, (i) => i);
  indices.shuffle();
  return indices;
}

/// Manages the playback queue (track list, ordering, shuffle, navigation).
///
/// Pure data structure — does NOT control the audio engine.
/// The [BloomeeMusicPlayer] reads [currentTrack] after calling navigation
/// methods and decides what to play.
class QueueManager {
  final BehaviorSubject<List<Track>> _queue = BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> shuffleMode = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> queueTitle = BehaviorSubject.seeded('Queue');

  int _currentIndex = 0;
  int _shuffleIndex = 0;
  List<int> _shuffleList = [];
  // Next insertion index for manual queued items (so multiple manual adds
  // are inserted in FIFO order right after current track).
  int _nextManualInsertIndex = -1;

  /// True while [restoreQueueState] is populating the queue from disk.
  /// [BloomeeMusicPlayer] checks this to skip the persistence listener
  /// and avoid writing back the exact same data we just read.
  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<Track> get tracks => _queue.value;
  Stream<List<Track>> get tracksStream => _queue.stream;
  int get currentIndex => _currentIndex;
  int get length => _queue.value.length;
  bool get isEmpty => _queue.value.isEmpty;
  bool get isNotEmpty => _queue.value.isNotEmpty;

  Track? get currentTrack {
    if (_queue.value.isEmpty || _currentIndex >= _queue.value.length) {
      return null;
    }
    return _queue.value[_currentIndex];
  }

  bool hasNext({LoopMode loopMode = LoopMode.off}) {
    if (_queue.value.isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    if (shuffleMode.value) {
      return _shuffleList.isNotEmpty &&
          _shuffleIndex < (_shuffleList.length - 1);
    }
    return _currentIndex < (_queue.value.length - 1);
  }

  bool hasPrevious({LoopMode loopMode = LoopMode.off}) {
    if (_queue.value.isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    if (shuffleMode.value) {
      return _shuffleList.isNotEmpty && _shuffleIndex > 0;
    }
    return _currentIndex > 0;
  }

  /// Peek at the next track without advancing the index.
  Track? peekNext({LoopMode loopMode = LoopMode.off}) {
    if (_queue.value.isEmpty) return null;

    if (!shuffleMode.value) {
      if (_currentIndex < _queue.value.length - 1) {
        return _queue.value[_currentIndex + 1];
      } else if (loopMode == LoopMode.all) {
        return _queue.value[0];
      }
    } else {
      _ensureShuffleListValid();
      if (_shuffleIndex < _shuffleList.length - 1) {
        final nextIdx = _shuffleList[_shuffleIndex + 1];
        if (nextIdx < _queue.value.length) return _queue.value[nextIdx];
      } else if (loopMode == LoopMode.all && _shuffleList.isNotEmpty) {
        return _queue.value[_shuffleList[0]];
      }
    }
    return null;
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  /// Advance to the next track. Returns true if index changed.
  bool advanceToNext({LoopMode loopMode = LoopMode.off}) {
    if (_queue.value.isEmpty) return false;

    if (!shuffleMode.value) {
      if (_currentIndex < _queue.value.length - 1) {
        _currentIndex++;
        return true;
      } else if (loopMode == LoopMode.all) {
        _currentIndex = 0;
        return true;
      }
    } else {
      _ensureShuffleListValid();
      if (_shuffleIndex < _shuffleList.length - 1) {
        _shuffleIndex++;
        _currentIndex =
            _shuffleList[_shuffleIndex].clamp(0, _queue.value.length - 1);
        return true;
      } else if (loopMode == LoopMode.all) {
        _shuffleIndex = 0;
        _currentIndex =
            _shuffleList[_shuffleIndex].clamp(0, _queue.value.length - 1);
        return true;
      }
    }
    return false;
  }

  /// Go back to the previous track. Returns true if index changed.
  bool advanceToPrevious({LoopMode loopMode = LoopMode.off}) {
    if (_queue.value.isEmpty) return false;

    if (!shuffleMode.value) {
      if (_currentIndex > 0) {
        _currentIndex--;
        return true;
      } else if (loopMode == LoopMode.all) {
        _currentIndex = _queue.value.length - 1;
        return true;
      }
    } else {
      _ensureShuffleListValid();
      if (_shuffleIndex > 0) {
        _shuffleIndex--;
        _currentIndex =
            _shuffleList[_shuffleIndex].clamp(0, _queue.value.length - 1);
        return true;
      } else if (loopMode == LoopMode.all) {
        _shuffleIndex = _shuffleList.length - 1;
        _currentIndex =
            _shuffleList[_shuffleIndex].clamp(0, _queue.value.length - 1);
        return true;
      }
    }
    return false;
  }

  /// Jump directly to a queue index.
  void jumpTo(int index) {
    if (index < 0 || index >= _queue.value.length) {
      log('jumpTo: index $index out of bounds (len: ${_queue.value.length})',
          name: 'QueueManager');
      return;
    }
    _currentIndex = index;
    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      _shuffleIndex = _shuffleList.indexOf(index);
      if (_shuffleIndex == -1) _shuffleIndex = 0;
    }
  }

  List<Track> _pendingManualTracks() {
    if (_queue.value.isEmpty) return [];
    final start = (_currentIndex + 1).clamp(0, _queue.value.length);
    final end = _nextManualInsertIndex.clamp(start, _queue.value.length);
    if (start >= end) return [];
    return _queue.value.sublist(start, end);
  }

  // ─── Queue Mutations ──────────────────────────────────────────────────────

  /// Replace the queue with a new playlist.
  void loadTracks(
    List<Track> tracks, {
    String playlistName = 'Queue',
    int idx = 0,
    bool shuffling = false,
  }) {
    final pendingManualTracks = _pendingManualTracks();

    // Deduplicate by ID, preserving order. We track whether the requested
    // start index needs to be remapped after deduplication.
    final seenIds = <String>{};
    Track? requestedTrack;
    if (idx >= 0 && idx < tracks.length) {
      requestedTrack = tracks[idx];
    }
    final deduped =
        tracks.where((t) => seenIds.add(t.id)).toList(growable: false);

    // Remap idx to the deduplicated list so the right song still starts.
    int remappedIdx = 0;
    if (requestedTrack != null) {
      final pos = deduped.indexWhere((t) => t.id == requestedTrack!.id);
      remappedIdx = pos != -1 ? pos : 0;
    }

    final finalQueue = List<Track>.from(deduped);
    if (pendingManualTracks.isNotEmpty && remappedIdx < finalQueue.length) {
      final insertIdx = (remappedIdx + 1).clamp(0, finalQueue.length);
      finalQueue.insertAll(insertIdx, pendingManualTracks);
    } else if (pendingManualTracks.isNotEmpty) {
      finalQueue.addAll(pendingManualTracks);
    }

    _queue.add(finalQueue);
    queueTitle.add(playlistName);

    final shouldShuffle = shuffling || shuffleMode.value;
    shuffleMode.add(shouldShuffle);

    if (shouldShuffle && finalQueue.isNotEmpty) {
      _shuffleList = generateRandomIndices(finalQueue.length);
      if (shuffling) {
        _shuffleIndex = 0;
        _currentIndex = _shuffleList[0];
      } else {
        _shuffleIndex = _shuffleList.indexOf(remappedIdx);
        if (_shuffleIndex == -1) _shuffleIndex = 0;
        _currentIndex = remappedIdx;
      }
    } else {
      _shuffleList = [];
      _shuffleIndex = 0;
      _currentIndex =
          remappedIdx.clamp(0, finalQueue.isEmpty ? 0 : finalQueue.length - 1);
    }
    // Preserve the pending manual block so future new-song loads keep it.
    _nextManualInsertIndex = (_currentIndex + 1 + pendingManualTracks.length)
        .clamp(0, finalQueue.length);
  }

  /// Toggle shuffle mode.
  void shuffle(bool enabled) {
    shuffleMode.add(enabled);
    if (enabled && _queue.value.isNotEmpty) {
      _shuffleList = generateRandomIndices(_queue.value.length);
      // Put current track at shuffle index 0.
      final pos = _shuffleList.indexOf(_currentIndex);
      if (pos != -1 && pos != 0) {
        _shuffleList.removeAt(pos);
        _shuffleList.insert(0, _currentIndex);
      }
      _shuffleIndex = 0;
    }
  }

  /// Add a track to play next (after current).
  /// For empty queue, starts the track at index 0.
  void addTrack(Track track) {
    queueTitle.add('Queue');
    
    if (_queue.value.isEmpty) {
      _queue.add([track]);
      _currentIndex = 0;
      _nextManualInsertIndex = 1;
      return;
    }

    // Determine insertion index. Use the manual-insert pointer so multiple
    // manual adds appear in FIFO order after the current track.
    var insertIdx = _nextManualInsertIndex;
    final minIdx = _currentIndex + 1;
    if (insertIdx < minIdx || insertIdx > _queue.value.length) insertIdx = minIdx;

    final newQueue = List<Track>.from(_queue.value)..insert(insertIdx, track);
    _queue.add(newQueue);

    // Advance the manual insert pointer so subsequent manual adds come after
    // this newly inserted item.
    _nextManualInsertIndex = (insertIdx + 1).clamp(0, _queue.value.length);

    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] >= insertIdx) _shuffleList[i]++;
      }
      _shuffleList.insert(_shuffleIndex + 1, insertIdx);
    }
  }

  /// Add multiple tracks to the queue.
  void addTracks(List<Track> tracks, {bool atLast = false}) {
    if (atLast) {
      final existingIds = _queue.value.map((t) => t.id).toSet();
      final deduplicated =
          tracks.where((t) => existingIds.add(t.id)).toList(growable: false);
      if (deduplicated.isEmpty) return;
      final startIdx = _queue.value.length;
      final newQueue = List<Track>.from(_queue.value)..addAll(deduplicated);
      _queue.add(newQueue);
      // Append new indices to the shuffle list so the existing shuffle order
      // is preserved. Without this, _ensureShuffleListValid would regenerate
      // the entire order, causing unpredictable jumps.
      if (shuffleMode.value && _shuffleList.isNotEmpty) {
        for (int i = 0; i < deduplicated.length; i++) {
          _shuffleList.add(startIdx + i);
        }
      }
    } else {
      addTracksAfterCurrent(tracks);
    }
  }

  /// Insert multiple tracks to play next (right after current), in order.
  /// Used for manually queued songs. Returns the insertion index.
  void addTracksAfterCurrent(List<Track> tracks) {
    if (_queue.value.isEmpty || tracks.isEmpty) {
      for (final track in tracks) {
        addTrack(track);
      }
      return;
    }

    // Determine insertion index using the manual-insert pointer so bulk
    // manual adds preserve ordering (FIFO) after current track.
    var insertIdx = _nextManualInsertIndex;
    final minIdx = _currentIndex + 1;
    if (insertIdx < minIdx || insertIdx > _queue.value.length) insertIdx = minIdx;

    final newQueue = List<Track>.from(_queue.value);
    for (int i = 0; i < tracks.length; i++) {
      newQueue.insert(insertIdx + i, tracks[i]);
    }
    _queue.add(newQueue);

    // Advance the manual insert pointer by the number of inserted items.
    _nextManualInsertIndex = (insertIdx + tracks.length)
        .clamp(0, _queue.value.length);

    // Update shuffle list indices: shift all indices >= insertIdx
    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] >= insertIdx) {
          _shuffleList[i] += tracks.length;
        }
      }
      // Insert the new track indices right after current in shuffle list
      for (int i = 0; i < tracks.length; i++) {
        _shuffleList.insert(_shuffleIndex + 1 + i, insertIdx + i);
      }
    }
  }

  /// Insert a track to play next (after current).
  void addPlayNext(Track track) {
    if (_queue.value.isEmpty) {
      _queue.add([track]);
      _currentIndex = 0;
      _nextManualInsertIndex = 1;
      return;
    }

    final insertIdx = _currentIndex + 1;
    final newQueue = List<Track>.from(_queue.value)..insert(insertIdx, track);
    _queue.add(newQueue);
    if (_nextManualInsertIndex < 0 || insertIdx <= _nextManualInsertIndex) {
      _nextManualInsertIndex = _nextManualInsertIndex < 0
          ? insertIdx + 1
          : _nextManualInsertIndex + 1;
    }

    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] >= insertIdx) _shuffleList[i]++;
      }
      _shuffleList.insert(_shuffleIndex + 1, insertIdx);
    }
  }

  /// Insert a track at a specific index.
  void insertTrack(int index, Track track) {
    final queue = List<Track>.from(_queue.value);
    final actualIdx = index.clamp(0, queue.length);
    if (actualIdx < queue.length) {
      queue.insert(actualIdx, track);
    } else {
      queue.add(track);
    }
    _queue.add(queue);
    if (_nextManualInsertIndex < 0 || actualIdx <= _nextManualInsertIndex) {
      _nextManualInsertIndex = _nextManualInsertIndex < 0
          ? actualIdx + 1
          : _nextManualInsertIndex + 1;
    }

    if (_currentIndex >= actualIdx) _currentIndex++;

    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] >= actualIdx) _shuffleList[i]++;
      }
      final insertPos =
          (_shuffleIndex + 1 + (_shuffleList.length - _shuffleIndex - 1) ~/ 2)
              .clamp(0, _shuffleList.length);
      _shuffleList.insert(insertPos, actualIdx);
    }
  }

  /// Remove a track by queue index.
  void removeTrackAt(int index) {
    if (index >= _queue.value.length) return;

    final newQueue = List<Track>.from(_queue.value)..removeAt(index);
    _queue.add(newQueue);

    // Adjust shuffle list.
    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      final posInShuffle = _shuffleList.indexOf(index);
      if (posInShuffle != -1) {
        _shuffleList.removeAt(posInShuffle);
        if (posInShuffle < _shuffleIndex) {
          _shuffleIndex--;
        } else if (posInShuffle == _shuffleIndex &&
            _shuffleIndex >= _shuffleList.length) {
          _shuffleIndex =
              (_shuffleList.length - 1).clamp(0, _shuffleList.length);
        }
      }
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] > index) _shuffleList[i]--;
      }
    }

    // Adjust current index.
    if (_currentIndex == index) {
      if (newQueue.isEmpty) {
        _currentIndex = 0;
      } else {
        _currentIndex = _currentIndex.clamp(0, newQueue.length - 1);
      }
    } else if (_currentIndex > index) {
      _currentIndex--;
    }

    if (_nextManualInsertIndex > index) {
      _nextManualInsertIndex--;
    }
  }

  /// Move a track from one position to another.
  void moveTrack(int oldIndex, int newIndex) {
    final queue = List<Track>.from(_queue.value);
    if (oldIndex < newIndex) newIndex--;
    final item = queue.removeAt(oldIndex);
    queue.insert(newIndex, item);
    _queue.add(queue);

    // Update shuffle list.
    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      for (int i = 0; i < _shuffleList.length; i++) {
        if (_shuffleList[i] == oldIndex) {
          _shuffleList[i] = newIndex;
        } else if (oldIndex < newIndex) {
          if (_shuffleList[i] > oldIndex && _shuffleList[i] <= newIndex) {
            _shuffleList[i]--;
          }
        } else {
          if (_shuffleList[i] >= newIndex && _shuffleList[i] < oldIndex) {
            _shuffleList[i]++;
          }
        }
      }
    }

    // Update current index.
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
  }

  /// Clear all tracks from the queue, keeping only the currently playing
  /// track so playback does not stop abruptly.
  void clearQueue() {
    final current = currentTrack;
    if (current == null) {
      _queue.add([]);
      _currentIndex = 0;
    } else {
      _queue.add([current]);
      _currentIndex = 0;
    }
    _shuffleList = [];
    _shuffleIndex = 0;
    _nextManualInsertIndex = _currentIndex + 1;
  }

  /// Replace the entire queue with new tracks.
  void updateQueue(List<Track> tracks, {int startIndex = 0}) {
    final pendingManualTracks = _pendingManualTracks();
    final seenIds = <String>{};
    final deduped =
        tracks.where((t) => seenIds.add(t.id)).toList(growable: false);
    final finalQueue = List<Track>.from(deduped);
    if (pendingManualTracks.isNotEmpty && startIndex < finalQueue.length) {
      final insertIdx = (startIndex + 1).clamp(0, finalQueue.length);
      finalQueue.insertAll(insertIdx, pendingManualTracks);
    } else if (pendingManualTracks.isNotEmpty) {
      finalQueue.addAll(pendingManualTracks);
    }

    _queue.add(finalQueue);
    _currentIndex =
        startIndex.clamp(0, finalQueue.isEmpty ? 0 : finalQueue.length - 1);
    if (shuffleMode.value && finalQueue.isNotEmpty) {
      _shuffleList = generateRandomIndices(finalQueue.length);
      _shuffleIndex = 0;
    } else {
      _shuffleList = [];
      _shuffleIndex = 0;
    }
    // Preserve the pending manual block so future new-song loads keep it.
    _nextManualInsertIndex = (_currentIndex + 1 + pendingManualTracks.length)
        .clamp(0, finalQueue.length);
  }

  bool replaceTrackById(String mediaId, Track replacement) {
    final queue = List<Track>.from(_queue.value);
    var changed = false;
    for (var i = 0; i < queue.length; i++) {
      if (queue[i].id == mediaId) {
        queue[i] = replacement;
        changed = true;
      }
    }
    if (changed) {
      _queue.add(queue);
    }
    return changed;
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _ensureShuffleListValid() {
    if (_shuffleList.isEmpty || _shuffleList.length != _queue.value.length) {
      log('Shuffle list invalid, regenerating', name: 'QueueManager');
      _shuffleList = generateRandomIndices(_queue.value.length);
      _shuffleIndex = _shuffleList.indexOf(_currentIndex);
      if (_shuffleIndex == -1) _shuffleIndex = 0;
    }
  }

  // ─── Queue Persistence ───────────────────────────────────────────────────

  /// Persist current queue state to DB settings for session restore.
  ///
  /// Stores only track IDs + index — the full Track objects are already in
  /// TrackDAO from the normal play/add pipeline. This avoids fragile custom
  /// serialization and keeps the persisted payload tiny.
  ///
  /// Called from [BloomeeMusicPlayer] via a throttled listener on
  /// [tracksStream], and eagerly in [onTaskRemoved] as a last-chance save.
  Future<void> persistQueueState() async {
    final tracks = _queue.value;
    if (tracks.isEmpty) return;
    try {
      // Ensure all tracks exist in TrackDAO (ephemeral tracks from search
      // results or intent handling might not have been saved yet).
      final trackDao = TrackDAO(DBProvider.db);
      await trackDao.upsertTracks(tracks);

      final dao = SettingsDAO(DBProvider.db);
      final queueData = {
        'v': 2, // v2: ID-only persistence
        'trackIds': tracks.map((t) => t.id).toList(),
        'currentIndex': _currentIndex,
        'queueTitle': queueTitle.value,
      };
      await dao.putSettingStr(
          SettingKeys.lastQueueState, jsonEncode(queueData));
    } catch (e) {
      log('Failed to persist queue: $e', name: 'QueueManager');
    }
  }

  /// Restore queue state from DB settings. Returns true if restored.
  ///
  /// Fetches full [Track] objects from [TrackDAO] by their IDs, so every
  /// field (title, artists, artwork, plugin-stamped ID) is correct and
  /// the tracks are immediately resolvable by [MediaResolverService].
  Future<bool> restoreQueueState() async {
    try {
      final dao = SettingsDAO(DBProvider.db);
      final raw = await dao.getSettingStr(SettingKeys.lastQueueState);
      if (raw == null || raw.isEmpty) return false;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Support both v2 (ID-only) and legacy v1 (full track JSON)
      final trackIds = data['trackIds'] as List?;
      if (trackIds == null || trackIds.isEmpty) return false;

      final trackDao = TrackDAO(DBProvider.db);
      final tracks = <Track>[];
      for (final id in trackIds) {
        if (id is! String || id.isEmpty) continue;
        try {
          final track = await trackDao.getTrackByMediaId(id);
          if (track != null) tracks.add(track);
        } catch (e) {
          log('Skipping track $id: $e', name: 'QueueManager');
        }
      }
      if (tracks.isEmpty) return false;

      final idx = (data['currentIndex'] as int?)
              ?.clamp(0, tracks.length - 1) ??
          0;
      _isRestoring = true;
      loadTracks(tracks, idx: idx, playlistName: data['queueTitle'] ?? 'Queue');
      _isRestoring = false;
      return true;
    } catch (e) {
      _isRestoring = false;
      log('Failed to restore queue: $e', name: 'QueueManager');
      return false;
    }
  }

  void dispose() {
    _queue.close();
    shuffleMode.close();
    queueTitle.close();
  }
}
