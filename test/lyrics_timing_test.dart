import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/utils/lyrics_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lines = [10, 20, 20, 40]
      .map((s) => ParsedLyric(
            text: '$s',
            start: Duration(seconds: s),
          ))
      .toList();

  test('has no active line before playback reaches the first lyric', () {
    expect(lyricIndexAt([], Duration.zero), -1);
    expect(lyricIndexAt(lines, const Duration(seconds: 9)), -1);
    expect(lyricIndexAt(lines, const Duration(seconds: 10)), 0);
  });

  test('finds the latest timestamp and handles backwards seeks', () {
    expect(lyricIndexAt(lines, const Duration(seconds: 20)), 2);
    expect(lyricIndexAt(lines, const Duration(seconds: 50)), 3);
    expect(lyricIndexAt(lines, const Duration(seconds: 15)), 0);
    expect(lyricIndexAt(lines, Duration.zero), -1);
  });

  test('offset-adjusted lyric seeks stay inside the track', () {
    expect(
        lyricSeekPosition(const Duration(seconds: 1),
            const Duration(seconds: 2), const Duration(minutes: 3)),
        Duration.zero);
    expect(
        lyricSeekPosition(const Duration(seconds: 10),
            const Duration(milliseconds: 500), Duration.zero),
        const Duration(milliseconds: 9500));
    expect(
        lyricSeekPosition(const Duration(seconds: 10),
            const Duration(seconds: -2), const Duration(seconds: 11)),
        const Duration(seconds: 11));
  });
}
