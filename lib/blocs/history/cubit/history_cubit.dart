import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  StreamSubscription<void>? watcher;
  HistoryCubit() : super(HistoryInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }
  Future<void> watchRecentlyPlayed() async {
    watcher = (await BloomeeDBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("History Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await BloomeeDBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }
}
