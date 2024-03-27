// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';

enum LoadingState { initial, loading, loaded, noInternet }

enum SourceEngine { eng_YTM, eng_YTV, eng_JIS }

class LastSearch {
  String query;
  int page = 1;
  final SourceEngine sourceEngine;
  bool hasReachedMax = false;
  List<MediaItemModel> mediaItemList = List.empty(growable: true);
  LastSearch({required this.query, required this.sourceEngine});
}

class FetchSearchResultsState {
  LoadingState loadingState;
  List<MediaItemModel> mediaItems;
  String albumName;
  bool hasReachedMax;
  FetchSearchResultsState(
      {required this.mediaItems,
      required this.albumName,
      required this.loadingState,
      required this.hasReachedMax});

  @override
  bool operator ==(covariant FetchSearchResultsState other) {
    if (identical(this, other)) return true;

    return other.loadingState == loadingState &&
        listEquals(other.mediaItems, mediaItems) &&
        other.albumName == albumName &&
        other.hasReachedMax == hasReachedMax;
  }

  @override
  int get hashCode {
    return loadingState.hashCode ^
        mediaItems.hashCode ^
        albumName.hashCode ^
        hasReachedMax.hashCode;
  }

  FetchSearchResultsState copyWith({
    LoadingState? loadingState,
    List<MediaItemModel>? mediaItems,
    String? albumName,
    bool? hasReachedMax,
  }) {
    return FetchSearchResultsState(
      loadingState: loadingState ?? this.loadingState,
      mediaItems: mediaItems ?? this.mediaItems,
      albumName: albumName ?? this.albumName,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

final class FetchSearchResultsInitial extends FetchSearchResultsState {
  FetchSearchResultsInitial()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.initial,
            hasReachedMax: false);
}

final class FetchSearchResultsLoading extends FetchSearchResultsState {
  FetchSearchResultsLoading()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.loading,
            hasReachedMax: false);
}

final class FetchSearchResultsLoaded extends FetchSearchResultsState {
  FetchSearchResultsLoaded()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.loaded,
            hasReachedMax: false);
}
//------------------------------------------------------------------------

class FetchSearchResultsCubit extends Cubit<FetchSearchResultsState> {
  FetchSearchResultsCubit() : super(FetchSearchResultsInitial());

  LastSearch last_YTM_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_YTM);
  LastSearch last_YTV_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_YTV);
  LastSearch last_JIS_search =
      LastSearch(query: "", sourceEngine: SourceEngine.eng_JIS);

  List<MediaItemModel> _mediaItemList = List.empty(growable: true);

  Future<void> searchYTM(String query) async {
    log("Youtube Music Search", name: "FetchSearchRes");

    last_YTM_search.query = query;
    emit(FetchSearchResultsLoading());
    final searchResults = await YtMusicService().search(query, filter: "songs");
    last_YTM_search.mediaItemList =
        fromYtSongMapList2MediaItemList(searchResults[0]['items']);
    emit(FetchSearchResultsState(
        mediaItems: last_YTM_search.mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded,
        hasReachedMax: true));
    log("got all searches ${last_YTM_search.mediaItemList.length}",
        name: "FetchSearchRes");
  }

  Future<void> searchYTV(String query) async {
    log("Youtube Video Search", name: "FetchSearchRes");

    last_YTV_search.query = query;
    emit(FetchSearchResultsLoading());

    final searchResults = await YouTubeServices().fetchSearchResults(query);
    last_YTV_search.mediaItemList =
        (fromYtVidSongMapList2MediaItemList(searchResults[0]['items']));
    emit(FetchSearchResultsState(
        mediaItems: last_YTV_search.mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded,
        hasReachedMax: true));
    log("got all searches ${last_YTV_search.mediaItemList.length}",
        name: "FetchSearchRes");
  }

  Future<void> searchJIS(String query, {bool loadMore = false}) async {
    if (!loadMore) {
      emit(FetchSearchResultsLoading());
      last_JIS_search.query = query;
      last_JIS_search.mediaItemList.clear();
      last_JIS_search.hasReachedMax = false;
      last_JIS_search.page = 1;
    }
    log("JIOSaavn Search", name: "FetchSearchRes");
    final searchResults = await SaavnAPI()
        .fetchSongSearchResults(searchQuery: query, page: last_JIS_search.page);
    last_JIS_search.page++;
    _mediaItemList = fromSaavnSongMapList2MediaItemList(searchResults['songs']);
    if (_mediaItemList.length < 20) {
      last_JIS_search.hasReachedMax = true;
    }
    last_JIS_search.mediaItemList.addAll(_mediaItemList);

    emit(FetchSearchResultsState(
      mediaItems: List<MediaItemModel>.from(last_JIS_search.mediaItemList),
      albumName: "Search",
      loadingState: LoadingState.loaded,
      hasReachedMax: last_JIS_search.hasReachedMax,
    ));

    log("got all searches ${last_JIS_search.mediaItemList.length}",
        name: "FetchSearchRes");
    // log(" Results ${searchResults}", name: "FetchSearchRes");
  }

  Future<void> search(String query,
      {SourceEngine sourceEngine = SourceEngine.eng_YTM}) async {
    if (sourceEngine == SourceEngine.eng_YTM) {
      searchYTM(query);
    } else if (sourceEngine == SourceEngine.eng_YTV) {
      searchYTV(query);
    } else if (sourceEngine == SourceEngine.eng_JIS) {
      searchJIS(query);
    } else {
      log("Invalid Source Engine", name: "FetchSearchRes");
      searchYTM(query);
    }
  }

  void clearSearch() {
    emit(FetchSearchResultsInitial());
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    List<String> searchSuggestions;
    try {
      searchSuggestions = await YouTubeServices()
          .getSearchSuggestions(query: query) as List<String>;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
