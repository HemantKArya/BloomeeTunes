import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../model/MediaPlaylistModel.dart';

List<int> generateRandomIndices(int length) {
  List<int> indices = List<int>.generate(length, (i) => i);
  indices.shuffle();
  return indices;
}

class QueueManager {
  final BehaviorSubject<List<MediaItem>> queue =
      BehaviorSubject<List<MediaItem>>.seeded([]);
  final BehaviorSubject<bool> shuffleMode = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String> queueTitle =
      BehaviorSubject<String>.seeded("Queue");

  int currentPlayingIdx = 0;
  int shuffleIdx = 0;
  List<int> shuffleList = [];

  // Callbacks
  Function(int idx, bool doPlay)? onPrepareToPlay;

  QueueManager() {
    // Note: We don't auto-regenerate shuffle list on queue changes
    // because it would break mid-playback queue modifications.
    // Shuffle list is explicitly managed in methods that need it.
  }

  Future<void> loadPlaylist(MediaPlaylist mediaList,
      {int idx = 0, bool doPlay = false, bool shuffling = false}) async {
    queue.add([]);
    queue.add(mediaList.mediaItems);
    queueTitle.add(mediaList.playlistName);

    // Enable shuffle mode first if needed
    final shouldShuffle = shuffling || shuffleMode.value;
    shuffleMode.add(shouldShuffle);

    // Generate shuffle list and determine starting index
    int playIdx = idx;
    if (shouldShuffle && mediaList.mediaItems.isNotEmpty) {
      shuffleList = generateRandomIndices(mediaList.mediaItems.length);

      // Only choose a random first song when caller explicitly requested shuffling
      // (e.g., Shuffle & Play button). If the caller provided an index, respect it
      // even when shuffle mode stays enabled for subsequent navigation.
      if (shuffling) {
        shuffleIdx = 0;
        playIdx = shuffleList[0];
      } else {
        // Respect the requested index; align shuffleIdx with it so next/prev follow shuffle order
        shuffleIdx = shuffleList.indexOf(idx);
        if (shuffleIdx == -1) {
          shuffleIdx = 0;
        }
        playIdx = idx;
      }
    }

    await _prepare4play(idx: playIdx, doPlay: doPlay);
  }

  Future<void> shuffle(bool shuffle) async {
    shuffleMode.add(shuffle);
    if (shuffle) {
      if (queue.value.isEmpty) {
        shuffleList = [];
        shuffleIdx = 0;
        return;
      }

      // Generate new shuffle list and position current song at index 0
      shuffleList = generateRandomIndices(queue.value.length);

      // Find current song in the new shuffle and move it to position 0
      // This ensures the currently playing song continues, but future songs are shuffled
      final currentIdx = currentPlayingIdx;
      final posInShuffle = shuffleList.indexOf(currentIdx);
      if (posInShuffle != -1 && posInShuffle != 0) {
        shuffleList.removeAt(posInShuffle);
        shuffleList.insert(0, currentIdx);
      }
      shuffleIdx = 0;
    }
  }

  Future<void> skipToNext({LoopMode loopMode = LoopMode.off}) async {
    if (queue.value.isEmpty) {
      log('Cannot skip to next: queue is empty', name: 'QueueManager');
      return;
    }

    if (!shuffleMode.value) {
      if (currentPlayingIdx < (queue.value.length - 1)) {
        currentPlayingIdx++;
        await _prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else if (loopMode == LoopMode.all) {
        // Loop back to the beginning
        currentPlayingIdx = 0;
        await _prepare4play(idx: currentPlayingIdx, doPlay: true);
      }
    } else {
      if (shuffleList.isEmpty || shuffleList.length != queue.value.length) {
        log('Shuffle list out of sync, regenerating', name: 'QueueManager');
        shuffleList = generateRandomIndices(queue.value.length);
        shuffleIdx = shuffleList.indexOf(currentPlayingIdx);
        if (shuffleIdx == -1) shuffleIdx = 0;
      }

      if (shuffleIdx < (shuffleList.length - 1)) {
        shuffleIdx++;
        final nextIdx = shuffleList[shuffleIdx];
        if (nextIdx >= queue.value.length) {
          log('Shuffle index out of bounds, skipping to next valid',
              name: 'QueueManager');
          shuffleIdx = (shuffleIdx + 1) % shuffleList.length;
          await _prepare4play(
              idx: shuffleList[shuffleIdx].clamp(0, queue.value.length - 1),
              doPlay: true);
        } else {
          await _prepare4play(idx: nextIdx, doPlay: true);
        }
      } else if (loopMode == LoopMode.all) {
        // Loop back to the beginning in shuffle mode
        shuffleIdx = 0;
        await _prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      }
    }
  }

  Future<void> skipToPrevious({LoopMode loopMode = LoopMode.off}) async {
    if (queue.value.isEmpty) {
      log('Cannot skip to previous: queue is empty', name: 'QueueManager');
      return;
    }

    if (!shuffleMode.value) {
      if (currentPlayingIdx > 0) {
        currentPlayingIdx--;
        await _prepare4play(idx: currentPlayingIdx, doPlay: true);
      } else if (loopMode == LoopMode.all) {
        // Loop to the end
        currentPlayingIdx = queue.value.length - 1;
        await _prepare4play(idx: currentPlayingIdx, doPlay: true);
      }
    } else {
      if (shuffleList.isEmpty || shuffleList.length != queue.value.length) {
        log('Shuffle list out of sync, regenerating', name: 'QueueManager');
        shuffleList = generateRandomIndices(queue.value.length);
        shuffleIdx = shuffleList.indexOf(currentPlayingIdx);
        if (shuffleIdx == -1) shuffleIdx = 0;
      }

      if (shuffleIdx > 0) {
        shuffleIdx--;
        final prevIdx = shuffleList[shuffleIdx];
        if (prevIdx >= queue.value.length) {
          log('Shuffle index out of bounds, skipping to previous valid',
              name: 'QueueManager');
          shuffleIdx = (shuffleIdx - 1).clamp(0, shuffleList.length - 1);
          await _prepare4play(
              idx: shuffleList[shuffleIdx].clamp(0, queue.value.length - 1),
              doPlay: true);
        } else {
          await _prepare4play(idx: prevIdx, doPlay: true);
        }
      } else if (loopMode == LoopMode.all) {
        // Loop to the end in shuffle mode
        shuffleIdx = shuffleList.length - 1;
        await _prepare4play(idx: shuffleList[shuffleIdx], doPlay: true);
      }
    }
  }

  Future<void> skipToQueueItem(int index) async {
    if (index >= queue.value.length) {
      log("skipToQueueItem: Invalid index $index, queue length: ${queue.value.length}",
          name: "QueueManager");
      return;
    }

    currentPlayingIdx = index;

    // If shuffle mode is on, update shuffleIdx to maintain shuffle order for next/prev
    if (shuffleMode.value && shuffleList.isNotEmpty) {
      shuffleIdx = shuffleList.indexOf(index);
      if (shuffleIdx == -1) {
        // If song not in shuffle list, add it at current position
        shuffleIdx = 0;
      }
    }

    await _prepare4play(idx: index, doPlay: true);
    log("skipToQueueItem: Moved to index $index", name: "QueueManager");
  }

  Future<void> addQueueItem(MediaItem mediaItem) async {
    if (queue.value.any((e) => e.id == mediaItem.id)) return;
    queueTitle.add("Queue");

    final newQueue = List<MediaItem>.from(queue.value)..add(mediaItem);
    final newItemIndex = newQueue.length - 1;
    queue.add(newQueue);

    // Add to shuffle list if shuffle mode is on
    if (shuffleMode.value && shuffleList.isNotEmpty) {
      // Add new item to shuffle list at a random future position
      shuffleList.add(newItemIndex);
    }

    if (newQueue.length == 1) {
      await _prepare4play(idx: 0, doPlay: true);
    }
  }

  Future<void> updateQueue(List<MediaItem> newQueue,
      {bool doPlay = false}) async {
    queue.add(newQueue);

    // Regenerate shuffle list if shuffle mode is on
    if (shuffleMode.value && newQueue.isNotEmpty) {
      shuffleList = generateRandomIndices(newQueue.length);
      shuffleIdx = 0;
    } else if (newQueue.isEmpty) {
      shuffleList = [];
      shuffleIdx = 0;
    }

    await _prepare4play(idx: 0, doPlay: doPlay);
  }

  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {String queueName = "Queue", bool atLast = false}) async {
    if (!atLast) {
      for (var mediaItem in mediaItems) {
        await addQueueItem(mediaItem);
      }
    } else {
      final newQueue = List<MediaItem>.from(queue.value)..addAll(mediaItems);
      queue.add(newQueue);
      queueTitle.add("Queue");
    }
  }

  Future<void> addPlayNextItem(MediaItem mediaItem) async {
    if (queue.value.isNotEmpty) {
      if (queue.value.any((e) => e.id == mediaItem.id)) return;
      final insertIdx = currentPlayingIdx + 1;
      final newQueue = List<MediaItem>.from(queue.value)
        ..insert(insertIdx, mediaItem);
      queue.add(newQueue);

      // Adjust shuffle list if shuffle mode is on
      if (shuffleMode.value && shuffleList.isNotEmpty) {
        // Increment all indices >= insertIdx in the shuffle list
        for (int i = 0; i < shuffleList.length; i++) {
          if (shuffleList[i] >= insertIdx) {
            shuffleList[i]++;
          }
        }
        // Insert new item right after current position in shuffle
        shuffleList.insert(shuffleIdx + 1, insertIdx);
      }
    } else {
      await updateQueue([mediaItem], doPlay: true);
    }
  }

  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    final currentQueue = List<MediaItem>.from(queue.value);
    final actualIndex =
        index < currentQueue.length ? index : currentQueue.length;

    if (actualIndex < currentQueue.length) {
      currentQueue.insert(actualIndex, mediaItem);
    } else {
      currentQueue.add(mediaItem);
    }
    queue.add(currentQueue);

    // Adjust the currentPlayingIdx
    if (currentPlayingIdx >= actualIndex) {
      currentPlayingIdx++;
    }

    // Adjust shuffle list if shuffle mode is on
    if (shuffleMode.value && shuffleList.isNotEmpty) {
      // Increment all indices >= actualIndex in the shuffle list
      for (int i = 0; i < shuffleList.length; i++) {
        if (shuffleList[i] >= actualIndex) {
          shuffleList[i]++;
        }
      }
      // Insert the new item at a random position in shuffle list
      final insertPosition =
          shuffleIdx + 1 + (shuffleList.length - shuffleIdx - 1) ~/ 2;
      shuffleList.insert(
          insertPosition.clamp(0, shuffleList.length), actualIndex);
    }
  }

  Future<void> removeQueueItemAt(int index) async {
    if (index >= queue.value.length) return;

    final newQueue = List<MediaItem>.from(queue.value);
    newQueue.removeAt(index);
    queue.add(newQueue);

    // Adjust shuffle list if shuffle mode is on
    if (shuffleMode.value && shuffleList.isNotEmpty) {
      // Remove the index from shuffle list
      final posInShuffle = shuffleList.indexOf(index);
      if (posInShuffle != -1) {
        shuffleList.removeAt(posInShuffle);
        // Adjust shuffleIdx if we removed something before current position
        if (posInShuffle < shuffleIdx) {
          shuffleIdx--;
        } else if (posInShuffle == shuffleIdx &&
            shuffleIdx >= shuffleList.length) {
          shuffleIdx = shuffleList.length - 1;
        }
      }

      // Decrement all indices > removed index in the shuffle list
      for (int i = 0; i < shuffleList.length; i++) {
        if (shuffleList[i] > index) {
          shuffleList[i]--;
        }
      }
    }

    // Adjust currentPlayingIdx
    if (currentPlayingIdx == index) {
      if (newQueue.isEmpty) {
        currentPlayingIdx = 0;
      } else if (index < newQueue.length) {
        await _prepare4play(idx: index, doPlay: true);
      } else if (index > 0) {
        await _prepare4play(idx: index - 1, doPlay: true);
      }
    } else if (currentPlayingIdx > index) {
      currentPlayingIdx--;
    }
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    log("Moving from $oldIndex to $newIndex", name: "QueueManager");
    final newQueue = List<MediaItem>.from(queue.value);
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    queue.add(newQueue);

    // Update shuffle list if shuffle mode is on
    if (shuffleMode.value && shuffleList.isNotEmpty) {
      // Update all references to the moved indices
      for (int i = 0; i < shuffleList.length; i++) {
        if (shuffleList[i] == oldIndex) {
          shuffleList[i] = newIndex;
        } else if (oldIndex < newIndex) {
          // Item moved forward: decrement indices in between
          if (shuffleList[i] > oldIndex && shuffleList[i] <= newIndex) {
            shuffleList[i]--;
          }
        } else {
          // Item moved backward: increment indices in between
          if (shuffleList[i] >= newIndex && shuffleList[i] < oldIndex) {
            shuffleList[i]++;
          }
        }
      }
    }

    // update the currentPlayingIdx
    if (currentPlayingIdx == oldIndex) {
      currentPlayingIdx = newIndex;
    } else if (oldIndex < currentPlayingIdx && newIndex >= currentPlayingIdx) {
      currentPlayingIdx--;
    } else if (oldIndex > currentPlayingIdx && newIndex <= currentPlayingIdx) {
      currentPlayingIdx++;
    }
  }

  MediaItem? get currentMediaItem {
    if (queue.value.isEmpty || currentPlayingIdx >= queue.value.length) {
      return null;
    }
    return queue.value[currentPlayingIdx];
  }

  bool get hasNext {
    if (queue.value.isEmpty) return false;
    if (shuffleMode.value) {
      return shuffleList.isNotEmpty && shuffleIdx < (shuffleList.length - 1);
    }
    return currentPlayingIdx < (queue.value.length - 1);
  }

  bool get hasPrevious {
    if (queue.value.isEmpty) return false;
    if (shuffleMode.value) {
      return shuffleList.isNotEmpty && shuffleIdx > 0;
    }
    return currentPlayingIdx > 0;
  }

  Future<void> _prepare4play({int idx = 0, bool doPlay = false}) async {
    if (queue.value.isEmpty) {
      log('Cannot prepare4play: queue is empty', name: 'QueueManager');
      return;
    }

    if (idx >= queue.value.length) {
      log('Index $idx is out of bounds, queue length: ${queue.value.length}',
          name: 'QueueManager');
      idx = queue.value.length - 1;
    }

    currentPlayingIdx = idx;
    onPrepareToPlay?.call(idx, doPlay);
  }

  void dispose() {
    queue.close();
    shuffleMode.close();
    queueTitle.close();
  }
}
