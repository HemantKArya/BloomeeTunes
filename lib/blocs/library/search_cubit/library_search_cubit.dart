import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:Bloomee/model/library_search_result.dart';
import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';

part 'library_search_state.dart';

class LibrarySearchCubit extends Cubit<LibrarySearchState> {
  LibrarySearchCubit() : super(LibrarySearchInitial());

  String _currentQuery = '';

  void search(String query, LibraryItemsState itemsState) {
    _currentQuery = query;

    if (query.isEmpty) {
      EasyDebounce.cancel('library_search');
      emit(LibrarySearchInitial());
      return;
    }

    EasyDebounce.debounce(
      'library_search',
      const Duration(milliseconds: 300),
      () => _performSearch(query, itemsState),
    );
  }

  void clearSearch() {
    _currentQuery = '';
    EasyDebounce.cancel('library_search');
    emit(LibrarySearchInitial());
  }

  @override
  Future<void> close() {
    EasyDebounce.cancel('library_search');
    return super.close();
  }

  Future<void> _performSearch(
      String query, LibraryItemsState itemsState) async {
    emit(LibrarySearchLoading());

    try {
      // 1. Filter in-memory lists
      final filteredPlaylists =
          _filterList(itemsState.playlists, query, (p) => p.playlistName);
      final filteredArtists =
          _filterList(itemsState.artists, query, (a) => a.name);
      final filteredAlbums =
          _filterList(itemsState.albums, query, (a) => a.name);
      final filteredOnlinePlaylists =
          _filterList(itemsState.playlistsOnl, query, (p) => p.name);

      // 2. Async Song Search
      final songResults = await _searchSongs(query);

      // Check if this search is still relevant
      if (_currentQuery != query) return;

      emit(LibrarySearchSuccess(
        query: query,
        songResults: songResults,
        filteredPlaylists: filteredPlaylists,
        filteredArtists: filteredArtists,
        filteredAlbums: filteredAlbums,
        filteredOnlinePlaylists: filteredOnlinePlaylists,
      ));
    } catch (e) {
      if (_currentQuery != query) return;
      emit(const LibrarySearchError("Failed to search library"));
    }
  }

  List<T> _filterList<T>(
      List<T> list, String query, String Function(T) getName) {
    return list.where((item) {
      return getName(item).toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<SongSearchResult>> _searchSongs(String query) async {
    if (query.length < 2) return [];

    final results = await BloomeeDBService.searchMediaItemsInLibrary(query);
    return results
        .map((r) => SongSearchResult(song: r.$1, playlistName: r.$2))
        .toList();
  }
}
