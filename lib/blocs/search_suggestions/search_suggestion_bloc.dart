import 'dart:developer';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  final SearchHistoryDAO _searchHistoryDao;

  SearchSuggestionBloc({required SearchHistoryDAO searchHistoryDao})
      : _searchHistoryDao = searchHistoryDao,
        super(const SearchSuggestionLoading()) {
    on<SearchSuggestionFetch>((event, emit) async {
      final pastSearches = await getPastSearches(event.query);
      emit(SearchSuggestionLoaded(const [], pastSearches));
    });

    on<SearchSuggestionSave>((event, emit) async {
      if (event.query.trim().isEmpty) return;
      try {
        await _searchHistoryDao.putSearchHistory(event.query.trim());
      } catch (e) {
        log("Error saving search history: $e", name: "SearchSuggestionBloc");
      }
    });

    on<SearchSuggestionClear>((event, emit) async {
      if (state is SearchSuggestionLoading) {
        return;
      }
      List<Map<String, String>> res = List.from(state.dbSuggestionList);
      try {
        final e = res.firstWhere((element) => element['query'] == event.query);
        if (e['id'] != null) {
          await _searchHistoryDao.removeSearchHistory(e['id']!);
          res.remove(e);
          emit(SearchSuggestionLoaded(
            state.suggestionList,
            List<Map<String, String>>.from(res),
          ));
        }
      } catch (e) {
        log("Error Clearing Search History: $e", name: "SearchSuggestionBloc");
      }
    });
  }

  Future<List<Map<String, String>>> getPastSearches(String query) async {
    List<Map<String, String>> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      List<Map<String, String>> res =
          await _searchHistoryDao.getLastSearches(limit: 10);
      searchSuggestions = res;
      return searchSuggestions;
    }

    try {
      List<Map<String, String>> res =
          await _searchHistoryDao.getSimilarSearches(query);
      searchSuggestions = res;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
