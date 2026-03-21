import 'package:Bloomee/services/db/dao/search_history_dao.dart';

/// Repository for search operations — history persistence and search
/// suggestions.
///
/// Wraps [SearchHistoryDAO]. API-level search is handled by resolver plugins;
/// this repository handles
/// the cross-cutting concerns of search history and suggestion ranking.
class SearchRepository {
  final SearchHistoryDAO _searchHistoryDao;

  const SearchRepository(this._searchHistoryDao);

  // --------------- Search history ---------------

  Future<void> saveSearchQuery(String query) =>
      _searchHistoryDao.putSearchHistory(query);

  Future<List<Map<String, String>>> getRecentSearches({int limit = 10}) =>
      _searchHistoryDao.getLastSearches(limit: limit);

  Future<List<Map<String, String>>> getSuggestions(String query) =>
      _searchHistoryDao.getSimilarSearches(query);

  Future<void> removeSearchEntry(String id) =>
      _searchHistoryDao.removeSearchHistory(id);

  Future<void> clearSearchHistory() =>
      _searchHistoryDao.clearAllSearchHistory();

  Future<void> trimHistory() => _searchHistoryDao.limitSearchHistory();
}
