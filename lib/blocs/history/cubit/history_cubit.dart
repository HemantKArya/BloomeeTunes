import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:Bloomee/model/media_playlist_model.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryDAO _historyDao;
  StreamSubscription<void>? watcher;

  HistoryCubit({required HistoryDAO historyDao})
      : _historyDao = historyDao,
        super(HistoryInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }
  Future<void> watchRecentlyPlayed() async {
    watcher = (await _historyDao.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("History Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await _historyDao.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }
}
