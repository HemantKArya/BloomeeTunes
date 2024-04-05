class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }

  Stream<int> tickHMS(
      {required int hours,
      required int minutes,
      required int seconds,
      required Function(int) onTick}) {
    final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
    return tick(ticks: totalSeconds);
  }
}
