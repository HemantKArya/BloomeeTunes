import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:Bloomee/core/models/library_search_result.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';

part 'library_search_state.dart';

/// Signature for a function that searches tracks by query string.
typedef TrackSearchFn = Future<List<Track>> Function(String query);

class LibrarySearchCubit extends Cubit<LibrarySearchState> {
  final TrackSearchFn _searchTracks;

  LibrarySearchCubit({required TrackSearchFn searchTracks})
      : _searchTracks = searchTracks,
        super(LibrarySearchInitial());

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
      final filteredPlaylists =
          _filterList(itemsState.playlists, query, (p) => p.playlistName);
      final songResults = await _searchSongs(query);

      if (_currentQuery != query) return;

      emit(LibrarySearchSuccess(
        query: query,
        songResults: songResults,
        filteredPlaylists: filteredPlaylists,
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

    final tracks = await _searchTracks(query);
    return tracks
        .map((t) => SongSearchResult(song: t, playlistName: 'Library'))
        .toList();
  }
}
