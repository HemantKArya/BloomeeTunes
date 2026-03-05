part of 'history_cubit.dart';

class HistoryState {
  final List<Track> tracks;

  const HistoryState({required this.tracks});

  HistoryState copyWith({List<Track>? tracks}) {
    return HistoryState(tracks: tracks ?? this.tracks);
  }
}

class HistoryInitial extends HistoryState {
  const HistoryInitial() : super(tracks: const []);
}
