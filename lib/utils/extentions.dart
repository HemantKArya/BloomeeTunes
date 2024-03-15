extension StringExtension on String {
  String capitalize() {
    if (this != '') {
      return '${this[0].toUpperCase()}${substring(1)}';
    } else {
      return '';
    }
  }

  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  String unescape() {
    return replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&quot;', '"')
        .trim();
  }

  String formatToHHMMSS() {
    final int? time = int.tryParse(this);
    if (time != null) {
      final int hours = time ~/ 3600;
      final int seconds = time % 3600;
      final int minutes = seconds ~/ 60;

      final String hoursStr = hours.toString().padLeft(2, '0');
      final String minutesStr = minutes.toString().padLeft(2, '0');
      final String secondsStr = (seconds % 60).toString().padLeft(2, '0');

      if (hours == 0) {
        return '$minutesStr:$secondsStr';
      }
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '';
    }
  }

  String get yearFromEpoch =>
      DateTime.fromMillisecondsSinceEpoch(int.parse(this) * 1000)
          .year
          .toString();

  String get dateFromEpoch {
    final time = DateTime.fromMillisecondsSinceEpoch(int.parse(this) * 1000);
    return '${time.day}/${time.month}/${time.year}';
  }
}

extension DateTimeExtension on int {
  String formatToHHMMSS() {
    if (this != 0) {
      final int hours = this ~/ 3600;
      final int seconds = this % 3600;
      final int minutes = seconds ~/ 60;

      final String hoursStr = hours.toString().padLeft(2, '0');
      final String minutesStr = minutes.toString().padLeft(2, '0');
      final String secondsStr = (seconds % 60).toString().padLeft(2, '0');

      if (hours == 0) {
        return '$minutesStr:$secondsStr';
      }
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '';
    }
  }

  int get yearFromEpoch =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000).year;
}
