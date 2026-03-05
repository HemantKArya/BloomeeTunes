import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

class ImportPlaylistState {
  String playlistName;
  String itemName;
  int totalLength;
  int currentItem;
  ImportPlaylistState({
    required this.playlistName,
    required this.itemName,
    required this.totalLength,
    required this.currentItem,
  });

  @override
  bool operator ==(covariant ImportPlaylistState other) {
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

  ImportPlaylistState copyWith({
    String? playlistName,
    String? itemName,
    int? totalLength,
    int? currentItem,
  }) {
    return ImportPlaylistState(
      playlistName: playlistName ?? this.playlistName,
      itemName: itemName ?? this.itemName,
      totalLength: totalLength ?? this.totalLength,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

class ImportPlaylistStateInitial extends ImportPlaylistState {
  ImportPlaylistStateInitial()
      : super(
            playlistName: 'Loading',
            itemName: 'Loading',
            totalLength: 1,
            currentItem: 0);
}

class ImportPlaylistStateComplete extends ImportPlaylistState {
  ImportPlaylistStateComplete()
      : super(
            playlistName: 'Complete',
            itemName: 'Complete',
            totalLength: 1,
            currentItem: 1);
}

/// Cubit for importing playlists from external URLs.
///
/// Uses [ExternalMediaImporter] streams to track import progress.
class ImportPlaylistCubit extends Cubit<ImportPlaylistState> {
  BehaviorSubject<ImportPlaylistState> importPlaylistBS =
      BehaviorSubject.seeded(ImportPlaylistStateInitial());

  ImportPlaylistCubit() : super(ImportPlaylistStateInitial());

  /// Import a Spotify playlist by URL.
  Future<void> importSpotifyPlaylist(String url) async {
    importPlaylistBS.add(ImportPlaylistStateInitial());
    await for (final state
        in ExternalMediaImporter.sfyPlaylistImporter(url: url)) {
      importPlaylistBS.add(ImportPlaylistState(
        playlistName: state.message,
        itemName: state.message,
        totalLength: state.totalItems,
        currentItem: state.importedItems,
      ));
      if (state.isDone || state.isFailed) break;
    }
    importPlaylistBS.add(ImportPlaylistStateComplete());
    await Future.delayed(const Duration(milliseconds: 2000));
    importPlaylistBS.add(ImportPlaylistStateInitial());
  }

  @override
  Future<void> close() async {
    importPlaylistBS.close();
    super.close();
  }
}