import 'dart:async';
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

EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  final SearchHistoryDAO _searchHistoryDao;
  final PluginService _pluginService;
  final SettingsDAO _settingsDao;
  bool _isDisposed = false;
  int _fetchVersion = 0;

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
        if (_isDisposed) return;
        final version = ++_fetchVersion;
        final query = event.query.trim();
        final pastSearches = await getPastSearches(
          query,
          limit: _historyLimitForQuery(query),
        );
        if (_isDisposed || emit.isDone || version != _fetchVersion) return;

        emit(SearchSuggestionLoaded(
          const [],
          pastSearches,
          isPluginLoading: true,
        ));

        final (queries, entities) = await _getPluginSuggestions(query);
        if (_isDisposed || emit.isDone || version != _fetchVersion) return;

        emit(SearchSuggestionLoaded(
          _dedupePluginQueries(queries, pastSearches),
          pastSearches,
          entitySuggestionList: entities,
          isPluginLoading: false,
        ));
      },
      transformer: _debounceRestartable(const Duration(milliseconds: 250)),
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
            isPluginLoading: state.isPluginLoading,
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
      ).timeout(const Duration(seconds: 5));

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
    } on TimeoutException {
      log("Plugin suggestion timed out", name: "SearchSuggestionBloc");
    } catch (e) {
      log("Plugin suggestion error: $e", name: "SearchSuggestionBloc");
    }
    return (<String>[], <plugin_models.EntitySuggestion>[]);
  }

  int _historyLimitForQuery(String query) {
    return query.isEmpty ? 8 : 5;
  }

  List<String> _dedupePluginQueries(
    List<String> pluginQueries,
    List<Map<String, String>> historyRows,
  ) {
    final seen = <String>{};
    for (final row in historyRows) {
      if (row.values.isNotEmpty) {
        seen.add(_suggestionKey(row.values.first));
      }
    }
    final result = <String>[];

    for (final query in pluginQueries) {
      final normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (normalized.isEmpty) continue;
      if (seen.add(_suggestionKey(normalized))) {
        result.add(normalized);
      }
    }

    return result;
  }

  String _suggestionKey(String value) => value.trim().toLowerCase();

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

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}
