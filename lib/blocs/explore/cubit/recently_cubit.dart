import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recently_state.dart';

/// Cubit for recently played items on the Explore screen.
///
/// Uses [HistoryDAO] for recently-played reads.
class RecentlyCubit extends Cubit<RecentlyCubitState> {
  final HistoryDAO _historyDao;
  StreamSubscription<void>? watcher;

  RecentlyCubit(this._historyDao) : super(RecentlyCubitInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = (await _historyDao.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await _historyDao.getRecentlyPlayed(limit: 15);
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}
