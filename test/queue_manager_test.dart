import 'dart:math';

import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/services/player/queue_manager.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter_test/flutter_test.dart';

Track _t(String id) => Track(
    id: id,
    title: id,
    artists: const [],
    thumbnail: const Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false);

List<Track> _tracks(String ids) => [for (final id in ids.split('')) _t(id)];

QueueManager _queue(String ids, {int index = 0}) =>
    QueueManager(random: Random(7))..loadTracks(_tracks(ids), index: index);

String _ids(QueueManager q) => q.tracks.map((t) => t.id).join();

void main() {
  group('navigation', () {
    test('next/previous stop at the ends unless looping all', () {
      final q = _queue('abc', index: 2);
      expect(q.peekNext(), isNull);
      expect(q.advanceToNext(), isFalse);
      expect(q.peekNext(loopMode: LoopMode.all)?.id, 'a');
      expect(q.advanceToNext(loopMode: LoopMode.all), isTrue);
      expect(q.currentTrack?.id, 'a');
      expect(q.advanceToPrevious(), isFalse);
      expect(q.advanceToPrevious(loopMode: LoopMode.all), isTrue);
      expect(q.currentTrack?.id, 'c');
    });

    test('load drops duplicates and keeps the chosen track current', () {
      final q = QueueManager()
        ..loadTracks(_tracks('abac'), index: 3, title: 'Mix');
      expect(_ids(q), 'abc');
      expect(q.currentTrack?.id, 'c');
      expect(q.queueTitle.value, 'Mix');
    });

    test('remaining counts tracks after the current one', () {
      expect(_queue('abcd', index: 1).remaining, 2);
      expect(QueueManager().remaining, 0);
    });
  });

  group('add to queue', () {
    test('appends a new track', () {
      final q = _queue('abc', index: 1);
      expect(q.addTrack(_t('d')), isTrue);
      expect(_ids(q), 'abcd');
      expect(q.currentTrack?.id, 'b');
    });

    test('leaves current and upcoming tracks where they are', () {
      final q = _queue('abc', index: 1);
      expect(q.addTrack(_t('b')), isFalse);
      expect(q.addTrack(_t('c')), isFalse);
      expect(_ids(q), 'abc');
    });

    test('moves an already played track to the end so it plays again', () {
      final q = _queue('abcd', index: 2);
      expect(q.addTrack(_t('a')), isTrue);
      expect(_ids(q), 'bcda');
      expect(q.currentTrack?.id, 'c');
    });

    test('batch add skips anything already queued', () {
      final q = _queue('abc', index: 2);
      expect(q.addTracks(_tracks('adbe')), 2);
      expect(_ids(q), 'abcde');
      expect(q.currentTrack?.id, 'c');
    });
  });

  group('play next', () {
    test('inserts after the current track, latest first', () {
      final q = _queue('abc');
      q.addPlayNext(_t('x'));
      q.addPlayNext(_t('y'));
      expect(_ids(q), 'ayxbc');
      expect(q.peekNext()?.id, 'y');
    });

    test('moves an already queued track right after the current one', () {
      final upcoming = _queue('abcde', index: 1)..addPlayNext(_t('e'));
      expect(_ids(upcoming), 'abecd');
      expect(upcoming.currentTrack?.id, 'b');

      final played = _queue('abcde', index: 3)..addPlayNext(_t('a'));
      expect(_ids(played), 'bcdae');
      expect(played.currentTrack?.id, 'd');
    });

    test('is a no-op for the current track', () {
      final q = _queue('abc', index: 1);
      expect(q.addPlayNext(_t('b')), isFalse);
      expect(_ids(q), 'abc');
    });

    test('on an empty queue the track becomes current', () {
      final q = QueueManager()..addPlayNext(_t('a'));
      expect(q.currentTrack?.id, 'a');
    });
  });

  group('edit', () {
    test('cannot remove the current track', () {
      final q = _queue('abc', index: 1);
      expect(q.removeTrackAt(1), isFalse);
      expect(q.removeTrackAt(5), isFalse);
      expect(q.removeTrackAt(-1), isFalse);
      expect(_ids(q), 'abc');
    });

    test('removing before the current track keeps it current', () {
      final q = _queue('abcd', index: 2);
      expect(q.removeTrackAt(0), isTrue);
      expect(_ids(q), 'bcd');
      expect(q.currentTrack?.id, 'c');
      expect(q.removeTrackAt(2), isTrue);
      expect(q.currentTrack?.id, 'c');
    });

    test('reorder uses Flutter indexes and follows the current track', () {
      final q = _queue('abcd', index: 1);
      q.moveTrack(0, 3); // a after c
      expect(_ids(q), 'bcad');
      expect(q.currentTrack?.id, 'b');
      q.moveTrack(0, 4); // current b to the end
      expect(_ids(q), 'cadb');
      expect(q.currentTrack?.id, 'b');
      q.moveTrack(2, 0); // d to the top
      expect(_ids(q), 'dcab');
      expect(q.currentTrack?.id, 'b');
    });

    test('clear keeps only the current track', () {
      final q = _queue('abc', index: 1)..clearQueue();
      expect(_ids(q), 'b');
      expect(q.currentTrack?.id, 'b');
    });

    test('insert keeps the current track current', () {
      final q = _queue('abc', index: 1)..insertTrack(0, _t('x'));
      expect(_ids(q), 'xabc');
      expect(q.currentTrack?.id, 'b');
    });
  });

  group('replace', () {
    test('swaps in place', () {
      final q = _queue('abc', index: 1);
      expect(q.replaceTrack('b', _t('x')), isTrue);
      expect(_ids(q), 'axc');
      expect(q.currentTrack?.id, 'x');
      expect(q.replaceTrack('zz', _t('y')), isFalse);
    });

    test('drops the other copy when the replacement is already queued', () {
      final later = _queue('abcd', index: 1)..replaceTrack('b', _t('d'));
      expect(_ids(later), 'adc');
      expect(later.currentTrack?.id, 'd');

      final earlier = _queue('abcd', index: 3)..replaceTrack('c', _t('a'));
      expect(_ids(earlier), 'bad');
      expect(earlier.currentTrack?.id, 'd');

      final current = _queue('abcd', index: 0)..replaceTrack('c', _t('a'));
      expect(_ids(current), 'bad');
      expect(current.currentTrack?.id, 'a');
    });
  });

  group('shuffle', () {
    test('the shown queue is the play order, current first', () {
      final q = _queue('abcdefgh', index: 3)..setShuffle(true);
      expect(q.currentIndex, 0);
      expect(q.currentTrack?.id, 'd');
      expect(q.tracks.map((t) => t.id).toSet(), 'abcdefgh'.split('').toSet());

      final order = <String>[q.currentTrack!.id];
      while (q.advanceToNext()) {
        order.add(q.currentTrack!.id);
      }
      expect(order.join(), _ids(q), reason: 'every track plays, in order');
    });

    test('turning it off restores the order and keeps the current track', () {
      final q = _queue('abcdef', index: 2)..setShuffle(true);
      q.advanceToNext();
      final current = q.currentTrack!.id;
      q.setShuffle(false);
      expect(_ids(q), 'abcdef');
      expect(q.currentTrack?.id, current);
    });

    test('edits made while shuffled carry over when unshuffling', () {
      final q = _queue('abcdef', index: 2)..setShuffle(true);
      q.addTrack(_t('x'));
      q.addPlayNext(_t('y'));
      q.removeTrackAt(q.tracks.indexWhere((t) => t.id == 'e'));
      q.replaceTrack('a', _t('z'));
      q.setShuffle(false);
      expect(_ids(q), 'zbcydfx');
      expect(q.currentTrack?.id, 'c');
    });

    test('loading with shuffle on plays the chosen track first', () {
      final q = QueueManager(random: Random(1))..setShuffle(true);
      q.loadTracks(_tracks('abcdef'), index: 4);
      expect(q.currentIndex, 0);
      expect(q.currentTrack?.id, 'e');
      q.setShuffle(false);
      expect(_ids(q), 'abcdef');
      expect(q.currentTrack?.id, 'e');
    });

    test('shuffle play turns shuffle on and keeps every track', () {
      final q = QueueManager(random: Random(3))
        ..loadTracks(_tracks('abcdef'), shuffle: true);
      expect(q.shuffleMode.value, isTrue);
      expect(q.currentIndex, 0);
      expect(q.length, 6);
    });

    test('lists are never shared or mutable', () {
      final q = _queue('abc');
      final before = q.tracks;
      q.addTrack(_t('d'));
      expect(_ids(q), 'abcd');
      expect(before.length, 3);
      expect(() => q.tracks.add(_t('z')), throwsUnsupportedError);
    });
  });
}
