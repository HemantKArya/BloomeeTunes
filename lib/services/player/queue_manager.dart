import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random, max;

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:rxdart/rxdart.dart';

/// The playback queue: one ordered list of tracks with unique ids, and the
/// index of the current one.
///
/// Shuffle reorders the list itself (current track first, the rest in random
/// order), so the queue the user sees is always the play order and every
/// edit (play next, reorder, remove) means the same thing with shuffle on or
/// off. The order from before shuffling is kept and restored when shuffle is
/// turned off, with the edits made meanwhile carried over.
///
/// Pure data structure: it never touches the audio engine. The player reads
/// [currentTrack] after a navigation call and decides what to play.
class QueueManager {
  QueueManager({Random? random}) : _random = random ?? Random();

  final Random _random;
  final BehaviorSubject<List<Track>> _queue =
      BehaviorSubject.seeded(const <Track>[]);
  final BehaviorSubject<bool> shuffleMode = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> queueTitle = BehaviorSubject.seeded('Queue');

  int _currentIndex = 0;

  /// The order to restore when shuffle is turned off; null while unshuffled.
  List<Track>? _unshuffled;

  /// The list last written by [persistQueueState]. Lists are never mutated
  /// in place, so an identical list means only the index or title changed.
  List<Track>? _persistedTracks;

  /// True while [restoreQueueState] is populating the queue from disk, so
  /// the player does not write back the data just read.
  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  // ─── Getters ───────────────────────────────────────────────────────────────

  /// Unmodifiable; replaced (never mutated) on every change.
  List<Track> get tracks => _queue.value;
  Stream<List<Track>> get tracksStream => _queue.stream;
  int get currentIndex => _currentIndex;
  int get length => _queue.value.length;
  bool get isEmpty => _queue.value.isEmpty;

  Track? get currentTrack {
    final queue = _queue.value;
    return _currentIndex < queue.length ? queue[_currentIndex] : null;
  }

  /// Tracks after the current one.
  int get remaining =>
      _queue.value.isEmpty ? 0 : _queue.value.length - 1 - _currentIndex;

  /// The track [advanceToNext] would move to, without moving.
  Track? peekNext({LoopMode loopMode = LoopMode.off}) {
    final next = _nextIndex(loopMode);
    return next == null ? null : _queue.value[next];
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  /// Moves to the next track. Returns true if the index changed.
  bool advanceToNext({LoopMode loopMode = LoopMode.off}) {
    final next = _nextIndex(loopMode);
    if (next == null) return false;
    _currentIndex = next;
    return true;
  }

  /// Moves to the previous track. Returns true if the index changed.
  bool advanceToPrevious({LoopMode loopMode = LoopMode.off}) {
    final length = _queue.value.length;
    if (length == 0) return false;
    if (_currentIndex > 0) {
      _currentIndex--;
      return true;
    }
    if (loopMode == LoopMode.all) {
      _currentIndex = length - 1;
      return true;
    }
    return false;
  }

  void jumpTo(int index) {
    if (index < 0 || index >= _queue.value.length) {
      log('jumpTo: index $index out of bounds (len: ${_queue.value.length})',
          name: 'QueueManager');
      return;
    }
    _currentIndex = index;
  }

  int? _nextIndex(LoopMode loopMode) {
    final length = _queue.value.length;
    if (length == 0) return null;
    if (_currentIndex < length - 1) return _currentIndex + 1;
    return loopMode == LoopMode.all ? 0 : null;
  }

  // ─── Loading ───────────────────────────────────────────────────────────────

  /// Replaces the queue with [tracks] (duplicates dropped), current at
  /// [index].
  ///
  /// [shuffle] turns shuffle on and starts from a random track (the shuffle
  /// play button). With shuffle already on, the chosen track plays first and
  /// the rest follow in random order.
  void loadTracks(
    List<Track> tracks, {
    String title = 'Queue',
    int index = 0,
    bool shuffle = false,
  }) {
    final start = index >= 0 && index < tracks.length ? tracks[index] : null;
    final unique = _unique(tracks);
    queueTitle.add(title);
    if (shuffle && !shuffleMode.value) shuffleMode.add(true);

    var current =
        start == null ? 0 : max(0, unique.indexWhere((t) => t.id == start.id));
    if (shuffle && unique.isNotEmpty) current = _random.nextInt(unique.length);

    if (shuffleMode.value) {
      _unshuffled = unique;
      _set(unique.isEmpty ? unique : _shuffledAround(unique, current), 0);
    } else {
      _unshuffled = null;
      _set(unique, current);
    }
  }

  void setShuffle(bool enabled) {
    if (enabled == shuffleMode.value) return;
    shuffleMode.add(enabled);
    final queue = _queue.value;

    if (enabled) {
      _unshuffled = queue;
      if (queue.isNotEmpty) _set(_shuffledAround(queue, _currentIndex), 0);
      return;
    }

    final original = _unshuffled;
    _unshuffled = null;
    if (original == null || queue.isEmpty) return;
    final current = queue[_currentIndex].id;
    // Original order for tracks still queued (as they are now, so replaced
    // or refreshed tracks stay current), then tracks added while shuffled.
    final pending = {for (final t in queue) t.id: t};
    final restored = <Track>[
      for (final t in original)
        if (pending.remove(t.id) case final kept?) kept,
      ...pending.values,
    ];
    _set(restored, restored.indexWhere((t) => t.id == current));
  }

  // ─── Adding ────────────────────────────────────────────────────────────────

  /// "Add to queue": appends [track]. An upcoming copy stays where it is; an
  /// already played one moves to the end so it plays again. Returns false
  /// when nothing changed (it is the current or an upcoming track).
  bool addTrack(Track track) => addTracks([track], requeuePlayed: true) > 0;

  /// Appends [tracks], skipping ones already queued. With [requeuePlayed],
  /// already played ones move to the end instead of being skipped. Returns
  /// how many tracks were appended or moved.
  int addTracks(Iterable<Track> tracks, {bool requeuePlayed = false}) {
    final queue = _queue.value;
    final positions = _positions(queue);
    final seen = <String>{};
    final requeued = <String>{};
    final appended = <Track>[];
    for (final track in tracks) {
      if (!seen.add(track.id)) continue;
      final at = positions[track.id];
      if (at == null) {
        appended.add(track);
      } else if (requeuePlayed && at < _currentIndex) {
        requeued.add(track.id);
        appended.add(track);
      }
    }
    if (appended.isEmpty) return 0;

    final kept = requeued.isEmpty
        ? queue
        : [
            for (final t in queue)
              if (!requeued.contains(t.id)) t
          ];
    // Requeued tracks all came from before the current one.
    _set([...kept, ...appended], _currentIndex - requeued.length);
    return appended.length;
  }

  /// "Play next": puts [track] right after the current one, moving it there
  /// if it is already queued. The latest play-next plays first. Returns
  /// false when [track] is the current track.
  bool addPlayNext(Track track) {
    final queue = _queue.value;
    if (queue.isEmpty) {
      _set([track], 0);
      if (shuffleMode.value) _unshuffled = [track];
      return true;
    }
    final at = queue.indexWhere((t) => t.id == track.id);
    if (at == _currentIndex) return false;

    final list = [...queue];
    var current = _currentIndex;
    if (at != -1) {
      list.removeAt(at);
      if (at < current) current--;
    }
    list.insert(current + 1, track);
    _set(list, current);

    // Keep it next to the current track if shuffle is turned off later.
    final original = _unshuffled;
    if (original != null) {
      final currentId = list[current].id;
      final restored = [
        for (final t in original)
          if (t.id != track.id) t
      ];
      final pos = restored.indexWhere((t) => t.id == currentId);
      restored.insert(pos == -1 ? restored.length : pos + 1, track);
      _unshuffled = restored;
    }
    return true;
  }

  /// Inserts [track] at [index] unless it is already queued.
  void insertTrack(int index, Track track) {
    final queue = _queue.value;
    if (queue.any((t) => t.id == track.id)) return;
    final at = index.clamp(0, queue.length);
    final list = [...queue]..insert(at, track);
    final current = queue.isNotEmpty && at <= _currentIndex
        ? _currentIndex + 1
        : _currentIndex;
    _set(list, current);
  }

  // ─── Editing ───────────────────────────────────────────────────────────────

  /// Removes the track at [index]. The current track cannot be removed (it
  /// is playing; skip it instead). Returns true if a track was removed.
  bool removeTrackAt(int index) {
    final queue = _queue.value;
    if (index < 0 || index >= queue.length || index == _currentIndex) {
      return false;
    }
    final list = [...queue]..removeAt(index);
    _set(list, index < _currentIndex ? _currentIndex - 1 : _currentIndex);
    return true;
  }

  /// Moves a track, with [newIndex] as Flutter's reorder callbacks give it
  /// (the position before the dragged item is taken out).
  void moveTrack(int oldIndex, int newIndex) {
    final queue = _queue.value;
    if (oldIndex < 0 || oldIndex >= queue.length) return;
    if (oldIndex < newIndex) newIndex--;
    newIndex = newIndex.clamp(0, queue.length - 1);
    if (oldIndex == newIndex) return;

    final list = [...queue];
    list.insert(newIndex, list.removeAt(oldIndex));

    var current = _currentIndex;
    if (current == oldIndex) {
      current = newIndex;
    } else if (oldIndex < current && newIndex >= current) {
      current--;
    } else if (oldIndex > current && newIndex <= current) {
      current++;
    }
    _set(list, current);
  }

  /// Replaces the track [oldId] with [replacement] in place (a smart replace
  /// or a metadata refresh). If [replacement] was already queued elsewhere,
  /// that copy is dropped so ids stay unique. Returns true if [oldId] was
  /// queued.
  bool replaceTrack(String oldId, Track replacement) {
    final queue = _queue.value;
    final at = queue.indexWhere((t) => t.id == oldId);
    if (at == -1) return false;
    final dup = oldId == replacement.id
        ? -1
        : queue.indexWhere((t) => t.id == replacement.id);

    final list = [...queue];
    list[at] = replacement;
    var current = _currentIndex;
    if (dup != -1) {
      list.removeAt(dup);
      if (dup == current) {
        current = at > dup ? at - 1 : at;
      } else if (dup < current) {
        current--;
      }
    }
    _set(list, current);

    final original = _unshuffled;
    if (original != null) {
      _unshuffled = _unique([
        for (final t in original) t.id == oldId ? replacement : t,
      ]);
    }
    return true;
  }

  /// Clears the queue except the current track, so playback continues.
  void clearQueue() {
    final current = currentTrack;
    queueTitle.add('Queue');
    final list = current == null ? const <Track>[] : [current];
    _unshuffled = shuffleMode.value ? list : null;
    _set(list, 0);
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _set(List<Track> tracks, int currentIndex) {
    _currentIndex =
        tracks.isEmpty ? 0 : currentIndex.clamp(0, tracks.length - 1);
    _queue.add(List<Track>.unmodifiable(tracks));
  }

  List<Track> _shuffledAround(List<Track> tracks, int current) {
    final rest = [...tracks]..removeAt(current);
    rest.shuffle(_random);
    return [tracks[current], ...rest];
  }

  static List<Track> _unique(Iterable<Track> tracks) {
    final seen = <String>{};
    return [
      for (final t in tracks)
        if (seen.add(t.id)) t
    ];
  }

  static Map<String, int> _positions(List<Track> tracks) =>
      {for (var i = 0; i < tracks.length; i++) tracks[i].id: i};

  // ─── Persistence ───────────────────────────────────────────────────────────

  /// Saves the queue (track ids, index, title) for session restore. Track
  /// rows are only rewritten when the list itself changed.
  Future<void> persistQueueState() async {
    final tracks = _queue.value;
    try {
      await TrackDAO(DBProvider.db).persistQueueState(
        tracks,
        currentIndex: _currentIndex,
        title: queueTitle.value,
        upsertTracks: !identical(tracks, _persistedTracks),
      );
      _persistedTracks = tracks;
    } catch (error) {
      log('Failed to persist queue: $error', name: 'QueueManager');
    }
  }

  /// Restores the saved queue. Returns true if one was restored.
  Future<bool> restoreQueueState() async {
    try {
      final raw = await SettingsDAO(DBProvider.db)
          .getSettingStr(SettingKeys.lastQueueState);
      if (raw == null || raw.isEmpty) return false;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final ids = [
        for (final id in (data['trackIds'] as List?) ?? const [])
          if (id is String && id.isNotEmpty) id
      ];
      if (ids.isEmpty) return false;

      final byId = await TrackDAO(DBProvider.db).getTracksByMediaIds(ids);
      final tracks = [
        for (final id in ids)
          if (byId[id] case final track?) track
      ];
      if (tracks.isEmpty) return false;

      // Find the saved current track by id: tracks missing from the DB
      // shift the indexes.
      final savedIndex = (data['currentIndex'] as int? ?? 0);
      final currentId =
          savedIndex >= 0 && savedIndex < ids.length ? ids[savedIndex] : null;
      final index = max(0, tracks.indexWhere((t) => t.id == currentId));

      _isRestoring = true;
      loadTracks(tracks,
          index: index, title: data['queueTitle'] as String? ?? 'Queue');
      _persistedTracks = _queue.value;
      return true;
    } catch (e) {
      log('Failed to restore queue: $e', name: 'QueueManager');
      return false;
    } finally {
      _isRestoring = false;
    }
  }

  void dispose() {
    _queue.close();
    shuffleMode.close();
    queueTitle.close();
  }
}
