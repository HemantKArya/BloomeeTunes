// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:bloc/bloc.dart';

import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';

enum LoadingState { initial, loading, loaded, noInternet }

enum SourceEngine { eng_YTM, eng_YTV, eng_JIS }

class LastSearch {
  String query;
  final SourceEngine sourceEngine;
  List<MediaItemModel> mediaItemList = List.empty(growable: true);
  LastSearch({required this.query, required this.sourceEngine});
}

class FetchSearchResultsState extends MediaPlaylist {
  LoadingState loadingState = LoadingState.initial;
  FetchSearchResultsState(
      {required super.mediaItems,
      required super.albumName,
      required this.loadingState});

  @override
  bool operator ==(covariant FetchSearchResultsState other) {
    if (identical(this, other)) return true;

    return other.loadingState == loadingState;
  }

  @override
  int get hashCode => loadingState.hashCode;
}

final class FetchSearchResultsInitial extends FetchSearchResultsState {
  FetchSearchResultsInitial()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.initial);
}

final class FetchSearchResultsLoading extends FetchSearchResultsState {
  FetchSearchResultsLoading()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.loading);
}

final class FetchSearchResultsLoaded extends FetchSearchResultsState {
  FetchSearchResultsLoaded()
      : super(
            mediaItems: [],
            albumName: 'Empty',
            loadingState: LoadingState.loaded);
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
        loadingState: LoadingState.loaded));
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
        loadingState: LoadingState.loaded));
    log("got all searches ${last_YTV_search.mediaItemList.length}",
        name: "FetchSearchRes");
  }

  Future<void> searchJIS(String query) async {
    emit(FetchSearchResultsLoading());
    log("JIOSaavn Search", name: "FetchSearchRes");
    final searchResults =
        await SaavnAPI().fetchSongSearchResults(searchQuery: query);
    last_JIS_search.mediaItemList =
        fromSaavnSongMapList2MediaItemList(searchResults['songs']);

    emit(FetchSearchResultsState(
        mediaItems: last_JIS_search.mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded));

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

  Future<void> search2(String query) async {
    emit(FetchSearchResultsLoading());
    final searchResults = await YtMusicService().search(query, filter: "songs");
    _mediaItemList = fromYtSongMapList2MediaItemList(searchResults[0]['items']);
    emit(FetchSearchResultsState(
        mediaItems: _mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded));
    final searchResults2 = await YouTubeServices().fetchSearchResults(query);
    _mediaItemList
        .addAll(fromYtVidSongMapList2MediaItemList(searchResults2[0]['items']));
    emit(FetchSearchResultsState(
        mediaItems: _mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded));
    log("got all searches ${_mediaItemList.length}", name: "FetchSearchRes");
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
