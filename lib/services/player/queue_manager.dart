import 'dart:developer';

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

  // ─── Queue Mutations ──────────────────────────────────────────────────────

  /// Replace the queue with a new playlist.
  void loadTracks(
    List<Track> tracks, {
    String playlistName = 'Queue',
    int idx = 0,
    bool shuffling = false,
  }) {
    _queue.add(tracks);
    queueTitle.add(playlistName);

    final shouldShuffle = shuffling || shuffleMode.value;
    shuffleMode.add(shouldShuffle);

    if (shouldShuffle && tracks.isNotEmpty) {
      _shuffleList = generateRandomIndices(tracks.length);
      if (shuffling) {
        _shuffleIndex = 0;
        _currentIndex = _shuffleList[0];
      } else {
        _shuffleIndex = _shuffleList.indexOf(idx);
        if (_shuffleIndex == -1) _shuffleIndex = 0;
        _currentIndex = idx;
      }
    } else {
      _shuffleList = [];
      _shuffleIndex = 0;
      _currentIndex = idx.clamp(0, tracks.isEmpty ? 0 : tracks.length - 1);
    }
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

  /// Add a track to the end of the queue. Skips duplicates (by id).
  void addTrack(Track track) {
    if (_queue.value.any((t) => t.id == track.id)) return;
    queueTitle.add('Queue');
    final newQueue = List<Track>.from(_queue.value)..add(track);
    final newIdx = newQueue.length - 1;
    _queue.add(newQueue);
    if (shuffleMode.value && _shuffleList.isNotEmpty) {
      _shuffleList.add(newIdx);
    }
  }

  /// Add multiple tracks to the queue.
  void addTracks(List<Track> tracks, {bool atLast = false}) {
    if (atLast) {
      final newQueue = List<Track>.from(_queue.value)..addAll(tracks);
      _queue.add(newQueue);
    } else {
      for (final track in tracks) {
        addTrack(track);
      }
    }
  }

  /// Insert a track to play next (after current).
  void addPlayNext(Track track) {
    if (_queue.value.isEmpty) {
      _queue.add([track]);
      _currentIndex = 0;
      return;
    }
    if (_queue.value.any((t) => t.id == track.id)) return;

    final insertIdx = _currentIndex + 1;
    final newQueue = List<Track>.from(_queue.value)..insert(insertIdx, track);
    _queue.add(newQueue);

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

  /// Replace the entire queue with new tracks.
  void updateQueue(List<Track> tracks, {int startIndex = 0}) {
    _queue.add(tracks);
    _currentIndex = startIndex.clamp(0, tracks.isEmpty ? 0 : tracks.length - 1);
    if (shuffleMode.value && tracks.isNotEmpty) {
      _shuffleList = generateRandomIndices(tracks.length);
      _shuffleIndex = 0;
    } else {
      _shuffleList = [];
      _shuffleIndex = 0;
    }
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

  void dispose() {
    _queue.close();
    shuffleMode.close();
    queueTitle.close();
  }
}
