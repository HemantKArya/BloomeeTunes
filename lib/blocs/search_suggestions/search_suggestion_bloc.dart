import 'dart:developer';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart' as plugin_models;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).asyncExpand(mapper);
}

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  final SearchHistoryDAO _searchHistoryDao;
  final PluginService _pluginService;
  final SettingsDAO _settingsDao;

  SearchSuggestionBloc({
    required SearchHistoryDAO searchHistoryDao,
    required PluginService pluginService,
    required SettingsDAO settingsDao,
  })  : _searchHistoryDao = searchHistoryDao,
        _pluginService = pluginService,
        _settingsDao = settingsDao,
        super(const SearchSuggestionLoading()) {
    on<SearchSuggestionFetch>(
      (event, emit) async {
        final pastSearches = await getPastSearches(event.query, limit: 2);
        final (queries, entities) = await _getPluginSuggestions(event.query);
        emit(SearchSuggestionLoaded(
          queries,
          pastSearches,
          entitySuggestionList: entities,
        ));
      },
      transformer: _debounce(const Duration(milliseconds: 350)),
    );

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
            entitySuggestionList: state.entitySuggestionList,
          ));
        }
      } catch (e) {
        log("Error Clearing Search History: $e", name: "SearchSuggestionBloc");
      }
    });
  }

  /// Returns a tuple of (query strings, entity suggestions) from the plugin.
  Future<(List<String>, List<plugin_models.EntitySuggestion>)>
      _getPluginSuggestions(String query) async {
    final pluginId =
        await _settingsDao.getSettingStr(SettingKeys.suggestionPluginId);
    if (pluginId == null || pluginId.isEmpty) {
      return (<String>[], <plugin_models.EntitySuggestion>[]);
    }

    try {
      final PluginRequest request;
      if (query.isEmpty || query.trim().isEmpty) {
        request = PluginRequest.searchSuggestionProvider(
          SearchSuggestionCommand.getDefaultSuggestions(
            limit: 10,
            includeEntities: true,
          ),
        );
      } else {
        request = PluginRequest.searchSuggestionProvider(
          SearchSuggestionCommand.getSuggestions(
            query: query,
            limit: 10,
            includeEntities: true,
          ),
        );
      }

      final response = await _pluginService.execute(
        pluginId: pluginId,
        request: request,
      );

      if (response is PluginResponse_Suggestions) {
        final queries = <String>[];
        final entities = <plugin_models.EntitySuggestion>[];
        for (final s in response.field0) {
          switch (s) {
            case plugin_models.Suggestion_Query(:final field0):
              queries.add(field0);
            case plugin_models.Suggestion_Entity(:final field0):
              entities.add(field0);
          }
        }
        return (queries, entities);
      }
    } catch (e) {
      log("Plugin suggestion error: $e", name: "SearchSuggestionBloc");
    }
    return (<String>[], <plugin_models.EntitySuggestion>[]);
  }

  Future<List<Map<String, String>>> getPastSearches(String query,
      {int limit = 10}) async {
    List<Map<String, String>> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      List<Map<String, String>> res =
          await _searchHistoryDao.getLastSearches(limit: limit);
      searchSuggestions = res;
      return searchSuggestions;
    }

    try {
      List<Map<String, String>> res =
          await _searchHistoryDao.getSimilarSearches(query);
      searchSuggestions = res.take(limit).toList();
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
