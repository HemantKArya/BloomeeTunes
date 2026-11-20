import 'package:Bloomee/services/scrobble/playback_session_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime clock;
  late List<String> scrobbled;
  late List<int> starts;
  late List<String> nowPlaying;
  late PlaybackSessionTracker<(String, int)> t;

  setUp(() {
    clock = DateTime(2026, 1, 1, 12);
    scrobbled = [];
    starts = [];
    nowPlaying = [];
    t = PlaybackSessionTracker<(String, int)>(
      keyOf: (x) => x.$1,
      durationSecOf: (x) => x.$2,
      onNowPlaying: (x) => nowPlaying.add(x.$1),
      onScrobble: (x, s) {
        scrobbled.add(x.$1);
        starts.add(s);
      },
      now: () => clock,
    );
  });
  tearDown(() => t.dispose());

  void advance(int s) => clock = clock.add(Duration(seconds: s));

  test('scrobbles on skip after half the track, with start timestamp', () {
    t.update(track: ('a', 200), playing: true);
    advance(100);
    t.update(track: ('b', 200), playing: true);
    expect(scrobbled, ['a']);
    expect(starts.single, DateTime(2026, 1, 1, 12).millisecondsSinceEpoch ~/ 1000);
    expect(nowPlaying, ['a', 'b']);
  });

  test('does not scrobble before threshold', () {
    t.update(track: ('a', 200), playing: true);
    advance(60);
    t.update(track: ('b', 200), playing: true);
    expect(scrobbled, isEmpty);
  });

  test('pause time is not counted', () {
    t.update(track: ('a', 200), playing: true);
    advance(60);
    t.update(track: ('a', 200), playing: false);
    advance(500);
    t.update(track: ('a', 200), playing: true);
    advance(30);
    t.update(track: null, playing: false);
    expect(scrobbled, isEmpty);
  });

  test('threshold is capped at 240s for long tracks', () {
    t.update(track: ('long', 1200), playing: true);
    advance(241);
    t.onCompleted();
    expect(scrobbled, ['long']);
  });

  test('tracks of 30s or less never scrobble', () {
    t.update(track: ('short', 30), playing: true);
    advance(30);
    t.onCompleted();
    expect(scrobbled, isEmpty);
  });

  test('repeat-one: completion then replay scrobbles twice', () {
    t.update(track: ('a', 100), playing: true);
    advance(100);
    t.onCompleted();
    t.update(track: ('a', 100), playing: true);
    advance(60);
    t.onCompleted();
    expect(scrobbled, ['a', 'a']);
  });

  test('same key re-sent does not reset timing', () {
    t.update(track: ('a', 200), playing: true);
    advance(60);
    t.update(track: ('a', 200), playing: true);
    advance(50);
    t.onCompleted();
    expect(scrobbled, ['a']);
  });
}
