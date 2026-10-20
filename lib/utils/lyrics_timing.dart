import 'package:Bloomee/core/models/lyrics_models.dart';

/// Last line that has actually started, including duplicate timestamps.
/// Before the first timestamp there is deliberately no active lyric.
int lyricIndexAt(List<ParsedLyric> lines, Duration position) {
  var low = 0;
  var high = lines.length;
  while (low < high) {
    final middle = (low + high) >> 1;
    if (lines[middle].start <= position) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low - 1;
}

Duration lyricSeekPosition(Duration start, Duration offset, Duration duration) {
  var position = start - offset;
  if (position.isNegative) position = Duration.zero;
  if (duration > Duration.zero && position > duration) return duration;
  return position;
}
