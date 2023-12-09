import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Saavn/saavn_api.dart';
import 'package:Bloomee/repository/Spotify/spotify_api.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/services/db/MediaDB.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';

part 'saavn_repository_state.dart';

class SaavnRepositoryCubit extends Cubit<SaavnRepositoryState> {
  late SaavnAPI saavnAPI;

  SaavnRepositoryCubit() : super(SaavnRepositoryInitial()) {
    saavnAPI = SaavnAPI();
  }

  @override
  Future<void> close() async {
    super.close();

    EasyDebounce.cancelAll();
  }

  Future<void> fetchTopResultsfromSaavn() async {
    emit(state);
    final trends = await saavnAPI.getTopSearches();

    List<MediaItemModel> trendings = [];

    for (int i = 0; i < trends.length; i++) {
      final trendingResults = await saavnAPI.fetchSongSearchResults(
          searchQuery: trends[i], count: 2);

      trendings += fromSaavnSongMapList2MediaItemList(trendingResults["songs"]);
    }

    emit(SaavnRepositoryState(mediaItems: trendings, albumName: "Trendings"));
  }
}

class SaavnSearchRepositoryCubit extends Cubit<SaavnRepositoryState> {
  BehaviorSubject<String?> searchQuery = BehaviorSubject<String?>.seeded(null);
  SpotifyApi spotifyApi = SpotifyApi();
  String? accessSpotifyToken;
  MediaDBCubit? mediaDBCubit;
  BehaviorSubject<ImportPlaylistState> importFromSpotifyState =
      BehaviorSubject.seeded(ImportPlaylistStateInitial());

  SaavnSearchRepositoryCubit() : super(SaavnRepositoryInitial()) {
    searchQuery.listen((value) {
      if (value != null) {
        initializeAccessToken();

        EasyDebounce.debounce(
            'search-debouncer',
            const Duration(milliseconds: 2500),
            () async => await fetchSearchResultsFromSaavn(value));
      }
    });
  }

  Future<void> initializeAccessToken() async {
    accessSpotifyToken = await spotifyApi.getAccessToken2();
  }

  Future<void> initializeAccessTokenWithDebounce() async {
    if (accessSpotifyToken != null) {
      EasyDebounce.debounce('initializeTokenDebounce',
          const Duration(milliseconds: 59 * 60 * 1000), () async {
        initializeAccessToken();
        log("initialized from debounce! ${accessSpotifyToken?.length}",
            name: "saavnRepCubit");
      });
      log("token ${accessSpotifyToken?.length}", name: "saavnRepCubit");
    } else {
      initializeAccessToken();
      log("initialized direct ${accessSpotifyToken?.length}",
          name: "saavnRepCubit");
    }
  }

  Future<void> fetchSearchResultsFromSaavn(String query,
      {bool spotify = true}) async {
    List<MediaItemModel> searchResultsList = [];
    List<String> search_queries = [query];
    if (spotify) {
      search_queries = await spotifyApi.getSearchQueriesFromSpotify(
          query, accessSpotifyToken);
      // log(search_queries,name: "saavnRepCubit");
    }

    for (int i = 0; i < search_queries.length; i++) {
      final trendingResults = await SaavnAPI()
          .fetchSongSearchResults(searchQuery: search_queries[i], count: 1);

      searchResultsList +=
          fromSaavnSongMapList2MediaItemList(trendingResults["songs"]);
    }
    searchResultsList.toSet().toList();
    emit(SaavnRepositoryState(
        mediaItems: searchResultsList, albumName: "Search"));
  }

  Future<void> fetchPlaylistFromSpotify(
      MediaDBCubit _mediaDBCubit, String playListID) async {
    mediaDBCubit = _mediaDBCubit;

    String? _playlistID = getPlaylistIdFromSpotifyUrl(playListID);

    if (_playlistID != null) {
      playListID = _playlistID;
      log("Spotify Playlist: ${_playlistID}", name: "saavnRepCubit");
    }

    importFromSpotifyState.add(ImportPlaylistStateInitial());
    if (accessSpotifyToken != null) {
      final _spotifyMap = await spotifyApi.getAllTracksOfPlaylist(
          accessSpotifyToken!, playListID);
      final playlistName = _spotifyMap["playlistName"] as String;
      final _spotifyList = _spotifyMap["tracks"] as List;

      log(_spotifyList.toString(), name: "saavnRepCubit");
      if (_spotifyList.length > 0) {
        for (int k = 0; k < _spotifyList.length; k++) {
          // await Future.delayed(Duration(milliseconds: 20));
          // if (k > 10) break;
          final _title = await _spotifyList[k]["track"]["name"];

          String _artists = "";
          (await _spotifyList[k]["track"]["artists"] as List<dynamic>)
              .forEach((element) {
            _artists = "${_artists} ${element["name"]}";
          });
          final saavnSearchResult = await SaavnAPI().fetchSongSearchResults(
              searchQuery: "${_title} ${_artists}}", count: 1);
          final searchResultsList =
              fromSaavnSongMapList2MediaItemList(saavnSearchResult["songs"]);
          if (searchResultsList.isNotEmpty) {
            importFromSpotifyState.add(ImportPlaylistState(
                playlistName: playlistName,
                itemName: searchResultsList[0].title,
                totalLength: _spotifyList.length - 1,
                currentItem: k));
            _mediaDBCubit.addMediaItemToPlaylist(searchResultsList[0],
                MediaPlaylistDB(playlistName: playlistName));
          }

          log("here5 ${_spotifyList[k]["track"]["name"]} - ${playlistName}",
              name: "saavnRepCubit");
        }
      }
    }
    importFromSpotifyState.add(ImportPlaylistStateComplete());
    await Future.delayed(Duration(milliseconds: 2000));
    importFromSpotifyState.add(ImportPlaylistStateInitial());
    // importFromSpotifyState.close();
  }

  @override
  Future<void> close() {
    importFromSpotifyState.close();
    searchQuery.close();
    return super.close();
  }
}

String? getPlaylistIdFromSpotifyUrl(String url) {
  if (Uri.tryParse(url) == null) {
    return null;
  }

  final uri = Uri.parse(url);
  if (uri.host != 'open.spotify.com') {
    return null;
  }

  final pathSegments = uri.pathSegments;
  if (pathSegments.isEmpty || pathSegments[0] != 'playlist') {
    return null;
  }

  final playlistId = pathSegments[1];
  if (playlistId.isEmpty) {
    return null;
  }

  // Check if the URL contains an additional query parameter for "si"
  // (share identifier) and "pi" (playlist index)
  final queryParams = uri.queryParameters;
  if (queryParams.containsKey('si') || queryParams.containsKey('pi')) {
    // Extract playlist ID before the query parameters
    return playlistId.split('?').first;
  }

  return playlistId;
}

bool isSpotifyPlaylistUrl(String url) {
  return getPlaylistIdFromSpotifyUrl(url) != null;
}
