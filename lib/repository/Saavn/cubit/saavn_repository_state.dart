// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'saavn_repository_cubit.dart';

class SaavnRepositoryState extends MediaPlaylist {
  SaavnRepositoryState(
      {required super.mediaItems, required super.albumName, super.isLiked});
}

final class SaavnRepositoryInitial extends SaavnRepositoryState {
  SaavnRepositoryInitial()
      : super(mediaItems: [], albumName: 'Empty', isLiked: false);
}

class ImportFromSpotifyState {
  String playlistName;
  String itemName;
  int totalLength;
  int currentItem;
  ImportFromSpotifyState({
    required this.playlistName,
    required this.itemName,
    required this.totalLength,
    required this.currentItem,
  });

  @override
  bool operator ==(covariant ImportFromSpotifyState other) {
    if (identical(this, other)) return true;

    return other.playlistName == playlistName &&
        other.itemName == itemName &&
        other.totalLength == totalLength &&
        other.currentItem == currentItem;
  }

  @override
  int get hashCode {
    return playlistName.hashCode ^
        itemName.hashCode ^
        totalLength.hashCode ^
        currentItem.hashCode;
  }

  ImportFromSpotifyState copyWith({
    String? playlistName,
    String? itemName,
    int? totalLength,
    int? currentItem,
  }) {
    return ImportFromSpotifyState(
      playlistName: playlistName ?? this.playlistName,
      itemName: itemName ?? this.itemName,
      totalLength: totalLength ?? this.totalLength,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

class ImportFromSpotifyStateInitial extends ImportFromSpotifyState {
  ImportFromSpotifyStateInitial()
      : super(
            playlistName: 'Loading',
            itemName: 'Loading',
            totalLength: 1,
            currentItem: 0);
}

class ImportFromSpotifyStateComplete extends ImportFromSpotifyState {
  ImportFromSpotifyStateComplete()
      : super(
            playlistName: 'Complete',
            itemName: 'Complete',
            totalLength: 1,
            currentItem: 1);
}
