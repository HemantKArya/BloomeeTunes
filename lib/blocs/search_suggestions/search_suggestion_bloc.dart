import 'dart:developer';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  SearchSuggestionBloc() : super(const SearchSuggestionLoading()) {
    on<SearchSuggestionFetch>((event, emit) async {
      final res1 = await getPastSearches(event.query);
      emit(SearchSuggestionLoaded(state.suggestionList, res1));
      final res2 = await getOnlineSearchSuggestions(event.query);
      emit(SearchSuggestionLoaded(res2, res1));
    });

    on<SearchSuggestionClear>((event, emit) async {
      if (state is SearchSuggestionLoading) {
        return;
      }
      List<Map<String, String>> res = List.from(state.dbSuggestionList);
      try {
        final e = res.firstWhere((element) => element['query'] == event.query);
        if (e['id'] != null) {
          await BloomeeDBService.removeSearchHistory(e['id']!);
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

  Future<List<String>> getOnlineSearchSuggestions(String query) async {
    List<String> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      return [];
    }
    try {
      searchSuggestions = await YouTubeServices()
          .getSearchSuggestions(query: query) as List<String>;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }

  Future<List<Map<String, String>>> getPastSearches(String query) async {
    List<Map<String, String>> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      List<Map<String, String>> res =
          await BloomeeDBService.getLastSearches(limit: 10);
      searchSuggestions = res;
      return searchSuggestions;
    }

    try {
      List<Map<String, String>> res =
          await BloomeeDBService.getSimilarSearches(query);
      searchSuggestions = res;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
