part of 'recently_cubit.dart';

class RecentlyCubitState {
  final List<Track> tracks;

  const RecentlyCubitState({required this.tracks});

  RecentlyCubitState copyWith({List<Track>? tracks}) {
    return RecentlyCubitState(tracks: tracks ?? this.tracks);
  }
}

class RecentlyCubitInitial extends RecentlyCubitState {
  const RecentlyCubitInitial() : super(tracks: const []);
}
