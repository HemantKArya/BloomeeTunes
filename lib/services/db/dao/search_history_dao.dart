import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for search-history CRUD.
class SearchHistoryDAO {
  final Future<Isar> _db;

  const SearchHistoryDAO(this._db);

  Future<void> putSearchHistory(String searchQuery) async {
    Isar isarDB = await _db;
    SearchHistoryDB? existing = isarDB.searchHistoryDBs
        .filter()
        .queryEqualTo(searchQuery)
        .findFirstSync();
    if (existing != null) {
      isarDB.writeTxn(() =>
          isarDB.searchHistoryDBs.put(existing..lastSearched = DateTime.now()));
    } else {
      isarDB.writeTxnSync(() => isarDB.searchHistoryDBs.putSync(SearchHistoryDB(
            query: searchQuery,
            lastSearched: DateTime.now(),
          )));
    }
  }

  Future<List<Map<String, String>>> getLastSearches({int limit = 10}) async {
    Isar isarDB = await _db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .where()
        .sortByLastSearchedDesc()
        .limit(limit)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.id.toString(),
      });
    }
    return searchHistory;
  }

  Future<List<Map<String, String>>> getSimilarSearches(String query) async {
    Isar isarDB = await _db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .queryContains(query)
        .sortByLastSearchedDesc()
        .limit(3)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.id.toString(),
      });
    }
    return searchHistory;
  }

  Future<void> limitSearchHistory() async {
    Isar isarDB = await _db;
    List<SearchHistoryDB> searchHistoryDB =
        isarDB.searchHistoryDBs.where().sortByLastSearchedDesc().findAllSync();
    if (searchHistoryDB.length > 100) {
      final idsToDelete =
          searchHistoryDB.sublist(100).map((e) => e.id).toList();
      isarDB.writeTxn(() => isarDB.searchHistoryDBs.deleteAll(idsToDelete));
    }
  }

  Future<void> removeSearchHistory(String id) async {
    Isar isarDB = await _db;
    isarDB.writeTxn(() => isarDB.searchHistoryDBs.delete(int.parse(id)));
  }

  Future<void> clearAllSearchHistory() async {
    Isar isarDB = await _db;
    isarDB.writeTxn(() => isarDB.searchHistoryDBs.clear());
  }
}
