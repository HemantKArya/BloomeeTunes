import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeServices {
  // Singleton instance
  static final YouTubeServices _instance = YouTubeServices._internal();
  late String appDocPath;
  late String appSuppPath;

  // Private constructor
  YouTubeServices._internal();

  YouTubeServices get instance => _instance;

  // Factory constructor
  factory YouTubeServices({String? appDocPath, String? appSuppPath}) {
    if (appDocPath != null) {
      _instance.appDocPath = appDocPath;
    }
    if (appSuppPath != null) {
      _instance.appSuppPath = appSuppPath;
    }
    if (appDocPath != null && appSuppPath != null) {
      {
        BloomeeDBService(
          appDocPath: appDocPath,
          appSuppPath: appSuppPath,
        );
      }
    }
    return _instance;
  }

  static const String searchAuthority = 'www.youtube.com';
  static const Map paths = {
    'search': '/results',
    'channel': '/channel',
    'music': '/music',
    'playlist': '/playlist'
  };
  static const Map<String, String> headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0'
  };
  final YoutubeExplode yt = YoutubeExplode();

  Future<List<Video>> getPlaylistSongs(String id) async {
    final List<Video> results = await yt.playlists.getVideos(id).toList();
    return results;
  }

  Future<Video?> getVideoFromId(String id) async {
    try {
      final Video result = await yt.videos.get(id);
      return result;
    } catch (e) {
      log('Error while getting video from id ${e.toString()}',
          name: "YoutubeAPI");
      return null;
    }
  }

  Future<Map?> formatVideoFromId({
    required String id,
    Map? data,
    bool? getUrl,
  }) async {
    final Video? vid = await getVideoFromId(id);
    if (vid == null) {
      return null;
    }
    final Map? response = await formatVideo(
      video: vid,
      quality: await BloomeeDBService.getSettingStr(
            'ytQuality',
            defaultValue: 'Low',
          ) ??
          'Low',
      data: data,
      getUrl: getUrl ?? true,
      // preferM4a: Hive.box(
      //         'settings')
      //     .get('preferM4a',
      //         defaultValue:
      //             true) as bool
    );
    return response;
  }

  Future<Map?> refreshLink(String id, {String quality = 'Low'}) async {
    try {
      final StreamManifest manifest =
          await yt.videos.streamsClient.getManifest(id);
      final List<AudioOnlyStreamInfo> sortedStreamInfo =
          manifest.audioOnly.sortByBitrate();

      Map<String, dynamic> data = {
        'id': id,
        'qurls': [
          true,
          sortedStreamInfo.first.url.toString(),
          sortedStreamInfo.last.url.toString(),
        ],
      };

      return data;
    } catch (e) {
      log('Error in refreshLink: $e', name: "YoutubeAPI");
    }
    return {
      'id': id,
      'qurls': [false, '', ''],
    };
  }

  Future<Playlist> getPlaylistDetails(String id) async {
    final Playlist metadata = await yt.playlists.get(id);
    return metadata;
  }

  Future<Map<String, List>> getMusicHome() async {
    final Uri link = Uri.https(
      searchAuthority,
      paths['music'].toString(),
    );
    try {
      final Response response = await get(link);
      if (response.statusCode != 200) {
        return {};
      }
      final String searchResults =
          RegExp(r'(\"contents\":{.*?}),\"metadata\"', dotAll: true)
              .firstMatch(response.body)![1]!;
      final Map data = json.decode('{$searchResults}') as Map;

      final List result = data['contents']['twoColumnBrowseResultsRenderer']
              ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'] as List;

      final List headResult = data['header']['carouselHeaderRenderer']
          ['contents'][0]['carouselItemRenderer']['carouselItems'] as List;

      final List shelfRenderer = result.map((element) {
        return element['itemSectionRenderer']['contents'][0]['shelfRenderer'];
      }).toList();

      final List finalResult = shelfRenderer.map((element) {
        final playlistItems = element['title']['runs'][0]['text'].trim() ==
                    'Charts' ||
                element['title']['runs'][0]['text'].trim() == 'Classements'
            ? formatChartItems(
                element['content']['horizontalListRenderer']['items'] as List,
              )
            : element['title']['runs'][0]['text']
                        .toString()
                        .contains('Music Videos') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('Nouveaux clips') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('En Musique Avec Moi') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('Performances Uniques')
                ? formatVideoItems(
                    element['content']['horizontalListRenderer']['items']
                        as List,
                  )
                : formatItems(
                    element['content']['horizontalListRenderer']['items']
                        as List,
                  );
        if (playlistItems.isNotEmpty) {
          return {
            'title': element['title']['runs'][0]['text'],
            'playlists': playlistItems,
          };
        } else {
          log("got null in getMusicHome for '${element['title']['runs'][0]['text']}'",
              name: "YoutubeAPI");
          return null;
        }
      }).toList();

      final List finalHeadResult = formatHeadItems(headResult);
      finalResult.removeWhere((element) => element == null);

      return {'body': finalResult, 'head': finalHeadResult};
    } catch (e) {
      log('Error in getMusicHome: $e', name: "YoutubeAPI");
      return {};
    }
  }

  Future<List> getSearchSuggestions({required String query}) async {
    const baseUrl =
        'https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=';
    // 'https://invidious.snopyta.org/api/v1/search/suggestions?q=';
    final Uri link = Uri.parse(baseUrl + query);
    try {
      final Response response = await get(link, headers: headers);
      if (response.statusCode != 200) {
        return [];
      }
      final unescape = HtmlUnescape();
      // final Map res = jsonDecode(response.body) as Map;
      final List res = (jsonDecode(response.body) as List)[1] as List;
      // return (res['suggestions'] as List).map((e) => unescape.convert(e.toString())).toList();
      return res.map((e) => unescape.convert(e.toString())).toList();
    } catch (e) {
      log('Error in getSearchSuggestions: $e', name: "YoutubeAPI");
      return [];
    }
  }

  List formatVideoItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridVideoRenderer']['title']['simpleText'],
          'type': 'video',
          'description': e['gridVideoRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridVideoRenderer']['shortViewCountText']['simpleText'],
          'videoId': e['gridVideoRenderer']['videoId'],
          'firstItemId': e['gridVideoRenderer']['videoId'],
          'image':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
          'imageMin': e['gridVideoRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridVideoRenderer']['thumbnail']['thumbnails'][1]
              ['url'],
          'imageStandard': e['gridVideoRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
          'imageMax':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      log('Error in formatVideoItems: $e', name: "YoutubeAPI");
      return List.empty();
    }
  }

  List formatChartItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridPlaylistRenderer']['title']['runs'][0]['text'],
          'type': 'chart',
          'description': e['gridPlaylistRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridPlaylistRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageStandard': e['gridPlaylistRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageMax': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      log('Error in formatChartItems: $e', name: "YoutubeAPI");
      return List.empty();
    }
  }

  List formatItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['compactStationRenderer']['title']['simpleText'],
          'type': 'playlist',
          'description': e['compactStationRenderer']['description']
              ['simpleText'],
          'count': e['compactStationRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['compactStationRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['compactStationRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageStandard': e['compactStationRenderer']['thumbnail']
              ['thumbnails'][1]['url'],
          'imageMax': e['compactStationRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      log('Error in formatItems: $e', name: "YoutubeAPI");
      return List.empty();
    }
  }

  List formatHeadItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['defaultPromoPanelRenderer']['title']['runs'][0]['text'],
          'type': 'video',
          'description':
              (e['defaultPromoPanelRenderer']['description']['runs'] as List)
                  .map((e) => e['text'])
                  .toList()
                  .join(),
          'videoId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'firstItemId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
          'imageMedium': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][1]['url'],
          'imageStandard': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][2]['url'],
          'imageMax': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      log('Error in formatHeadItems: $e', name: "YoutubeAPI");
      return List.empty();
    }
  }

  Future<Map?> formatVideo({
    required Video video,
    required String quality,
    Map? data,
    bool getUrl = true,
    bool checkCache = true,
    // bool preferM4a = true,
  }) async {
    if (video.duration?.inSeconds == null) return null;
    List<String> urls = [];
    String finalUrl = '';
    String expireAt = '0';
    if (getUrl) {
      // check cache first
      if (checkCache) {
        final ytCache = await BloomeeDBService.getYtLinkCache(video.id.value);
        if (ytCache != null) {
          if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
              ytCache.expireAt) {
            // cache expired
            urls = await getUri(video);
          } else {
            // giving cache link
            log('cache found for ${video.id.value}', name: "YoutubeAPI");
            urls = [
              quality == 'High'
                  ? ytCache.highQURL
                  : (ytCache.lowQURL ?? ytCache.highQURL)
            ];
          }
        } else {
          //cache not present
          urls = await getUri(video);
        }
      } else {
        urls = await getUri(video);
        return {
          'id': video.id.value,
          'perma_url': video.url,
          'url': ((quality == 'High') ? urls.last : urls.first),
        };
      }

      finalUrl = ((quality == 'High') ? urls.last : urls.first);
      expireAt = RegExp('expire=(.*?)&').firstMatch(finalUrl)!.group(1) ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 5.5)
              .toString();

      try {
        BloomeeDBService.putYtLinkCache(
          video.id.value,
          urls.first,
          urls.last,
          int.parse(expireAt),
        );
      } catch (e) {
        log('DB Error in formatVideo,\nError:', error: e, name: "YoutubeAPI");
      }
    }
    return {
      'id': video.id.value,
      'album': (data?['album'] ?? '') != ''
          ? data!['album']
          : video.author.replaceAll('- Topic', '').trim(),
      'duration': video.duration?.inSeconds.toString(),
      'title':
          (data?['title'] ?? '') != '' ? data!['title'] : video.title.trim(),
      'artist': (data?['artist'] ?? '') != ''
          ? data!['artist']
          : video.author.replaceAll('- Topic', '').trim(),
      'image': video.thumbnails.maxResUrl,
      'secondImage': video.thumbnails.highResUrl,
      'language': 'YouTube',
      'genre': 'YouTube',
      'expire_at': expireAt,
      'url': finalUrl,
      'lowUrl': urls.isNotEmpty ? urls.first : '',
      'highUrl': urls.isNotEmpty ? urls.last : '',
      'year': video.uploadDate?.year.toString(),
      '320kbps': 'false',
      'has_lyrics': 'false',
      'release_date': video.publishDate.toString(),
      'album_id': video.channelId.value,
      'subtitle':
          (data?['subtitle'] ?? '') != '' ? data!['subtitle'] : video.author,
      'perma_url': video.url,
    };
  }

  Future<List<Map>> fetchSearchResults(String query,
      {bool playlist = false}) async {
    if (playlist) {
      final List<SearchResult> searchResults =
          await yt.search.searchContent(query, filter: TypeFilters.playlist);
      List<Map> finRes = List.empty(growable: true);
      for (var plt in searchResults) {
        if (plt is SearchPlaylist) {
          finRes.add({
            'title': plt.title,
            'image': plt.thumbnails.first.url.toString(),
            'id': plt.id.toString(),
            'subtitle': '${plt.videoCount} Views',
          });
        }
      }
      return [
        {
          'title': 'Playlists',
          'items': finRes,
        }
      ];
    } else {
      final List<Video> searchResults = await yt.search.search(query);
      final List<Map> videoResult = [];
      for (final Video vid in searchResults) {
        final res =
            await formatVideo(video: vid, quality: 'High', getUrl: false);
        if (res != null) videoResult.add(res);
      }
      return [
        {
          'title': 'Videos',
          'items': videoResult,
        }
      ];
    }
  }

  Future<List<Map>> fetchPlaylistItems(String id) async {
    final vidItems = await getPlaylistSongs(id);
    final vidDetails = await getPlaylistDetails(id);
    final List<Map> videoResult = [];

    for (final Video vid in vidItems) {
      final res = await formatVideo(video: vid, quality: 'High', getUrl: false);
      if (res != null) videoResult.add(res);
    }
    return [
      {
        'title': 'Playlist',
        'metadata': vidDetails,
        'items': videoResult,
      }
    ];
  }

  Future<List<String>> getUri(
    Video video,
    // {bool preferM4a = true}
  ) async {
    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(video.id);
    final List<AudioOnlyStreamInfo> sortedStreamInfo =
        manifest.audioOnly.sortByBitrate();
    if (Platform.isIOS || Platform.isMacOS) {
      final List<AudioOnlyStreamInfo> m4aStreams = sortedStreamInfo
          .where((element) => element.audioCodec.contains('mp4'))
          .toList();

      if (m4aStreams.isNotEmpty) {
        return [
          m4aStreams.first.url.toString(),
          m4aStreams.last.url.toString(),
        ];
      }
    }
    return [
      sortedStreamInfo.first.url.toString(),
      sortedStreamInfo.last.url.toString(),
    ];
  }
}
