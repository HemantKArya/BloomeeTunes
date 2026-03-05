// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'add_to_playlist_cubit.dart';

class AddToPlaylistState {
  final Track track;

  const AddToPlaylistState({required this.track});

  @override
  bool operator ==(covariant AddToPlaylistState other) {
    if (identical(this, other)) return true;
    return other.track == track;
  }

  @override
  int get hashCode => track.hashCode;

  AddToPlaylistState copyWith({Track? track}) {
    return AddToPlaylistState(track: track ?? this.track);
  }
}

final class AddToPlaylistInitial extends AddToPlaylistState {
  AddToPlaylistInitial() : super(track: trackNull);
}
