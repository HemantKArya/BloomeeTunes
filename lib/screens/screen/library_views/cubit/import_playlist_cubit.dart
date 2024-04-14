import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';

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

//------------------------------------------------------------------------------
class ImportPlaylistCubit extends Cubit<ImportPlaylistState> {
  BehaviorSubject<ImportPlaylistState> importYtPlaylistBS =
      BehaviorSubject.seeded(ImportPlaylistStateInitial());

  ImportPlaylistCubit() : super(ImportPlaylistStateInitial());
  Future<void> fetchYtPlaylistByID(
    String ytPlaylistID,
    BloomeeDBCubit BloomeeDBCubit,
  ) async {
    importYtPlaylistBS.add(ImportPlaylistStateInitial());
    // try {
    final result = await YouTubeServices().fetchPlaylistItems(ytPlaylistID);
    print("1 ${result.toString()}");
    final playlist = (result[0]["items"] as List);
    print("2 ${playlist.toString()}");
    if (playlist.isNotEmpty) {
      print("3");
      for (int i = 0; i < playlist.length; i++) {
        print("4 ${result[0]["metadata"]}");
        print(playlist[i].toString());
        importYtPlaylistBS.add(ImportPlaylistState(
            playlistName: result[0]["metadata"].title,
            itemName: playlist[i]["title"],
            totalLength: playlist.length,
            currentItem: i));
        // print("${result[0]["metadata"]["title"]} added!!");
        // print("5 ${playlist[i].toString()}");
        MediaItemModel mediaItemModel = fromYtVidSongMap2MediaItem(playlist[i]);
        print("5 ${mediaItemModel.toString()}");
        BloomeeDBCubit.addMediaItemToPlaylist(mediaItemModel,
            MediaPlaylistDB(playlistName: result[0]["metadata"].title));
      }
    }
    // } catch (e) {
    //   print("Error while getting playlist items!! $e");
    // }
    importYtPlaylistBS.add(ImportPlaylistStateComplete());
    await Future.delayed(const Duration(milliseconds: 2000));
    importYtPlaylistBS.add(ImportPlaylistStateInitial());
  }

  @override
  Future<void> close() async {
    importYtPlaylistBS.close();
    super.close();
  }
}
