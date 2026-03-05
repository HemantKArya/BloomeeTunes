import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:bloc/bloc.dart';

part 'history_state.dart';

/// Cubit for the full playback history screen.
///
/// Uses [HistoryDAO.getHistory] (no limit) to fetch all recorded plays.
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryDAO _historyDao;
  StreamSubscription<void>? _watcher;

  HistoryCubit({required HistoryDAO historyDao})
      : _historyDao = historyDao,
        super(const HistoryInitial()) {
    _fetchHistory();
    _watchHistory();
  }

  Future<void> _watchHistory() async {
    _watcher = (await _historyDao.watchHistory()).listen((_) {
      _fetchHistory();
      log('History Updated', name: 'HistoryCubit');
    });
  }

  Future<void> _fetchHistory() async {
    final tracks = await _historyDao.getHistory(limit: 0);
    emit(state.copyWith(tracks: tracks));
  }

  @override
  Future<void> close() {
    _watcher?.cancel();
    return super.close();
  }
}
