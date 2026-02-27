part of 'recently_cubit.dart';

class RecentlyCubitState {
  MediaPlaylist mediaPlaylist;
  RecentlyCubitState({
    required this.mediaPlaylist,
  });

  RecentlyCubitState copyWith({
    MediaPlaylist? mediaPlaylist,
  }) {
    return RecentlyCubitState(
      mediaPlaylist: mediaPlaylist ?? this.mediaPlaylist,
    );
  }
}

class RecentlyCubitInitial extends RecentlyCubitState {
  RecentlyCubitInitial()
      : super(mediaPlaylist: MediaPlaylist(playlistName: "", mediaItems: []));
}
