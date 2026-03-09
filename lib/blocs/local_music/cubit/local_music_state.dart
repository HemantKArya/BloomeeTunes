part of 'local_music_cubit.dart';

abstract class LocalMusicState extends Equatable {
  const LocalMusicState();
}

class LocalMusicInitial extends LocalMusicState {
  const LocalMusicInitial();

  @override
  List<Object?> get props => [];
}

class LocalMusicLoading extends LocalMusicState {
  const LocalMusicLoading();

  @override
  List<Object?> get props => [];
}

class LocalMusicScanning extends LocalMusicState {
  final List<String> folders;

  const LocalMusicScanning({required this.folders});

  @override
  List<Object?> get props => [folders];
}

class LocalMusicLoaded extends LocalMusicState {
  final List<Track> tracks;
  final List<String> folders;

  const LocalMusicLoaded({required this.tracks, required this.folders});

  @override
  List<Object?> get props => [tracks, folders];
}

class LocalMusicNoPermission extends LocalMusicState {
  const LocalMusicNoPermission();

  @override
  List<Object?> get props => [];
}

class LocalMusicError extends LocalMusicState {
  final String message;

  const LocalMusicError(this.message);

  @override
  List<Object?> get props => [message];
}
