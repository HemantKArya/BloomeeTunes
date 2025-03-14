import 'dart:core';
import 'dart:math';
import '../helpers.dart';
import '../yt_service_provider.dart';
import 'utils.dart';

mixin BrowsingMixin on YTMusicServices {
  Future<Map<String, dynamic>> browse(
      {Map<String, dynamic>? body,
      int limit = 2,
      String additionalParams = ''}) async {
    if (additionalParams != '') {
      return browseContinuation(
          body: body, limit: limit, additionalParams: additionalParams);
    }
    String endpoint = 'browse';
    body ??= {"browseId": "FEmusic_home"};

    var response =
        await sendRequest(endpoint, body, additionalParams: additionalParams);

    Map<String, dynamic> result = {};
    Map<String, dynamic>? contents = response['contents'];

    Map<String, dynamic>? header = response['header'] ??
        nav(response, [
          'contents',
          'twoColumnBrowseResultsRenderer',
          'tabs',
          0,
          'tabRenderer',
          'content',
          'sectionListRenderer',
          'contents',
          0
        ]);

    if (header != null) {
      result['header'] = handlePageHeader(
          header['musicDetailHeaderRenderer'] ??
              header['musicImmersiveHeaderRenderer'] ??
              header['musicResponsiveHeaderRenderer'] ??
              header['musicVisualHeaderRenderer'] ??
              header['musicHeaderRenderer'] ??
              header['musicEditablePlaylistDetailHeaderRenderer']?['header']
                  ?['musicResponsiveHeaderRenderer'] ??
              header['musicEditablePlaylistDetailHeaderRenderer']?['header'],
          editHeader: header['musicEditablePlaylistDetailHeaderRenderer']
              ?['editHeader']?['musicPlaylistEditHeaderRenderer']);
    }

    if (contents != null) {
      Map? tabRenderer = nav(contents,
          ['singleColumnBrowseResultsRenderer', 'tabs', 0, 'tabRenderer']);
      Map? sectionListRenderer =
          nav(tabRenderer, ['content', 'sectionListRenderer']) ??
              nav(contents, [
                'twoColumnBrowseResultsRenderer',
                'secondaryContents',
                'sectionListRenderer'
              ]);
      List? chips =
          nav(sectionListRenderer, ['header', 'chipCloudRenderer', 'chips']);
      if (chips != null) {
        result['chips'] = [];
        result['chips'].addAll(handleChips(chips));
      }
      String? cont = nav(sectionListRenderer,
              ['continuations', 0, 'nextContinuationData', 'continuation']) ??
          nav(sectionListRenderer, [
            'contents',
            0,
            'musicShelfRenderer',
            'continuations',
            0,
            'nextContinuationData',
            'continuation',
          ]) ??
          nav(sectionListRenderer, [
            'contents',
            0,
            'gridRenderer',
            'continuations',
            0,
            'nextContinuationData',
            'continuation',
          ]);

      String? continuationparams;
      if (cont != null) {
        continuationparams = getContinuationString(cont);
        result['continuation'] = continuationparams;
      } else {
        result['continuation'] = null;
      }

      List finalContents = nav(sectionListRenderer, ['contents']);

      result['sections'] = handleOuterContents(finalContents,
          thumbnails: result['header']?['thumbnails']);
      (result['sections'] as List).removeWhere((el) => el['contents'].isEmpty);
      if (result['continuation'] == null &&
          (result['sections'] as List).length == 1) {
        result['continuation'] = result['sections'].first['continuation'];
        continuationparams = result['continuation'];
      }
      if (limit > 1 && continuationparams != null) {
        limit = limit - 1;

        var data = await browseContinuation(
            body: body, limit: limit, additionalParams: continuationparams);
        if (data['sections'] != null) {
          if (data['addToLast'] == true) {
            result['sections']
                .last['contents']
                .addAll(data['sections'].first['contents']);
          } else {
            result['sections']
                .addAll(data['sections'].cast<Map<String, dynamic>>());
          }
        }
        result['continuation'] = data['continuation'];
      }
    } else {
      result['sections'] = List<Map<String, dynamic>>.empty();
    }
    return result;
  }

  Future<Map<String, dynamic>> browseContinuation(
      {Map<String, dynamic>? body,
      int limit = 1,
      String additionalParams = ''}) async {
    print('browseContinuation');
    String endpoint = 'browse';
    body ??= {"browseId": "FEmusic_home"};

    var response =
        await sendRequest(endpoint, body, additionalParams: additionalParams);
    Map<String, dynamic> result = {'sections': []};

    List? contents = nav(response,
            ['continuationContents', 'sectionListContinuation', 'contents']) ??
        nav(response,
            ['continuationContents', 'musicShelfContinuation', 'contents']);

    if (contents == null) return {};
    if (nav(response,
            ['continuationContents', 'musicShelfContinuation', 'contents']) !=
        null) {
      result['sections'].add({'contents': handleContents(contents)});
      result['addToLast'] = true;
    } else {
      result['sections'] = handleOuterContents(contents);
    }

    String? continuations = nav(response, [
          'continuationContents',
          'sectionListContinuation',
          'continuations',
          0,
          'nextContinuationData',
          'continuation'
        ]) ??
        nav(response, [
          'continuationContents',
          'musicShelfContinuation',
          'continuations',
          0,
          'nextContinuationData',
          'continuation'
        ]);
    if (continuations != null) {
      String? continuationparams = getContinuationString(continuations);
      result['continuation'] = continuationparams;
    } else {
      result['continuation'] = null;
    }

    if (limit > 1 && result['continuation'] != null) {
      limit = limit - 1;
      var data = await browse(
          body: body, limit: limit, additionalParams: result['continuation']);
      if (data['sections'] != null) {
        result['sections'].addAll(data['sections']);
      }
      result['continuation'] = data['continuation'];
    }

    return result;
  }

  Future<Map<String, dynamic>> getMoreItems({continuation = ''}) async {
    String endpoint = 'browse';
    Map<String, dynamic>? body = {"browseId": "FEmusic_home"};

    var response =
        await sendRequest(endpoint, body, additionalParams: continuation);
    String? continuationString = nav(response, [
      'continuationContents',
      'musicPlaylistShelfContinuation',
      'continuations',
      0,
      'nextContinuationData',
      'continuation'
    ]);
    List contents = nav(response, [
          'continuationContents',
          'musicPlaylistShelfContinuation',
          'contents'
        ]) ??
        [];
    return {
      'items': handleContents(contents),
      'continuation': continuationString != null
          ? getContinuationString(continuationString)
          : null,
    };
  }

  int getDatestamp() {
    final DateTime now = DateTime.now();
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final Duration difference = now.difference(epoch);
    final int days = difference.inDays;
    return days;
  }

  Future addYoutubeHistory(String videoId) async {
    signatureTimestamp = signatureTimestamp ?? getDatestamp() - 1;
    Map<String, dynamic> body = {};
    body['playbackContext'] = {
      'contentPlaybackContext': {'signatureTimestamp': signatureTimestamp},
    };
    body['video_id'] = videoId;

    final Map response = await sendRequest('player', body);
    String url =
        response['playbackTracking']['videostatsPlaybackUrl']['baseUrl'];
    const String cpna =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_";
    Random rand = Random();

    String generateCpn() {
      return List.generate(16, (index) => cpna[rand.nextInt(64)]).join();
    }

    String cpn = generateCpn();
    Map<String, dynamic> params = {"ver": 2, "c": "WEB_REMIX", "cpn": cpn};
    params.forEach((k, v) {
      url += '&$k=$v';
    });
    await sendGetRequest(url, headers);
  }

  Future<Map<String, dynamic>?> getSongDetails(String videoId) async {
    Map<String, dynamic> body = {"videoId": videoId};
    final Map response = await sendRequest('player', body);
    Map? videoDetails = response['videoDetails'];
    if (videoDetails != null) {
      return {
        'videoId': videoDetails['videoId'],
        'channelId': videoDetails['channelId'],
        'title': videoDetails['title'],
        'subtitle': videoDetails['author'],
        'length': videoDetails['lengthSeconds'],
        'viewCount': videoDetails['viewCount'],
        'thumbnails': videoDetails['thumbnail']['thumbnails'],
        'type': itemCategory[videoDetails['musicVideoType']],
      };
    }
    return null;
  }

  Future<List> getNextSongList({
    String? videoId,
    String? playlistId,
    String? params,
    int limit = 25,
    bool radio = false,
    bool shuffle = false,
  }) async {
    try {
      Map<String, dynamic> body = Map.from(context);
      body['enablePersistentPlaylistPanel'] = true;
      body['isAudioOnly'] = true;
      body['tunerSettingValue'] = 'AUTOMIX_SETTING_NORMAL';

      if (videoId == null && playlistId == null) {
        return [];
      }
      if (videoId != null) {
        body['videoId'] = videoId;
        playlistId ??= 'RDAMVM$videoId';
        if (!(radio || shuffle)) {
          body['watchEndpointMusicSupportedConfigs'] = {
            'watchEndpointMusicConfig': {
              'hasPersistentPlaylistPanel': true,
              'musicVideoType': 'MUSIC_VIDEO_TYPE_ATV;',
            }
          };
        }
      }

      body['playlistId'] = playlistIdTrimmer(playlistId!);

      if (shuffle) body['params'] = 'wAEB8gECKAE%3D';
      if (radio) body['params'] = 'wAEB';
      if (params != null) body['params'] = params;
      final Map response = await sendRequest('next', body);
      dynamic contents = nav(response, [
        'contents',
        'singleColumnMusicWatchNextResultsRenderer',
        'tabbedRenderer',
        'watchNextTabbedResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'musicQueueRenderer',
        'content',
        'playlistPanelRenderer',
        'contents'
      ]);

      List result = handleContents(contents);
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List> getPlaylistSongs(String playlistId) async {
    Map<String, dynamic> body = {
      "browseId": playlistId.startsWith('VL') ? playlistId : 'VL$playlistId'
    };
    var response = await sendRequest('browse', body);

    List contents = nav(response, [
          'contents',
          'singleColumnBrowseResultsRenderer',
          'tabs',
          0,
          'tabRenderer',
          'content',
          'sectionListRenderer',
          'contents',
          0,
          'musicPlaylistShelfRenderer',
          'contents'
        ]) ??
        nav(response, [
          'contents',
          'twoColumnBrowseResultsRenderer',
          'secondaryContents',
          'sectionListRenderer',
          'contents',
          0,
          'musicPlaylistShelfRenderer',
          'contents'
        ]);

    List result = handleContents(contents);

    return result;
  }
}

List handleChips(chips) {
  List resultChips = [];
  for (Map chip in chips) {
    chip = chip['chipCloudChipRenderer'];
    resultChips.add({
      'title': nav(chip, ['text', 'runs', 0, 'text']),
      'selected': nav(chip, ['isSelected']) ?? false,
      'endpoint': nav(chip, ['navigationEndpoint', 'browseEndpoint']),
    });
  }
  return resultChips;
}

List<Map<String, dynamic>> handleOuterContents(List contents,
    {List? thumbnails}) {
  List<Map<String, dynamic>> results = [];
  for (Map content in contents) {
    Map<String, dynamic> result = {};
    result['contents'] = [];
    Map? musicPlaylistShelfRenderer =
        nav(content, ['musicPlaylistShelfRenderer']);
    Map? musicShelfRenderer = nav(content, ['musicShelfRenderer']);
    Map? musicCarouselShelfRenderer =
        nav(content, ['musicCarouselShelfRenderer']);
    Map? gridRenderer = nav(content, ['gridRenderer']);
    if (musicCarouselShelfRenderer != null) {
      results.add(handleMusicCarouselShelfRenderer(musicCarouselShelfRenderer));
      print('musicCarouselShelfRenderer');
    } else if (musicPlaylistShelfRenderer != null) {
      results.add(handleMusicPlaylistShelfRenderer(musicPlaylistShelfRenderer));
      print('musicPlaylistShelfRenderer');
    } else if (musicShelfRenderer != null) {
      print('musicShelfRenderer');
      results.add(
          handleMusicShelfRenderer(musicShelfRenderer, thumbnails: thumbnails));
    } else if (gridRenderer != null) {
      print('gridRenderer');
      results.add(handleGridRenderer(gridRenderer));
    } else {}
    results.add(result);
  }

  return results;
}

handleMusicCarouselShelfRenderer(Map item) {
  Map<String, dynamic> section = {};
  section.addAll(handleHeader(
      nav(item, ['header', 'musicCarouselShelfBasicHeaderRenderer'])));
  if (item['numItemsPerColumn'] != null &&
      (int.parse(item['numItemsPerColumn'] ?? 0)) >= 4) {
    section['viewType'] = 'COLUMN';
  } else {
    section['viewType'] = 'ROW';
  }
  section['thumbnails'] = nav(item, [
    'header',
    'musicCarouselShelfBasicHeaderRenderer',
    'thumbnail',
    'musicThumbnailRenderer',
    'thumbnail',
    'thumbnails'
  ]);
  section['contents'] = [];
  List? contents = nav(item, ['contents']);

  if (contents != null) {
    section['contents'].addAll(handleContents(contents));
  }

  return section;
}

Map<String, dynamic> handleHeader(Map header) {
  Map<String, dynamic> res = {
    'title': nav(header, ['title', 'runs', 0, 'text']),
    'strapline': nav(header, ['strapline', 'runs', 0, 'text']),
    'trailing': nav(header, ['moreContentButton']) != null
        ? {
            'text': nav(header, [
              'moreContentButton',
              'buttonRenderer',
              'text',
              'runs',
              0,
              'text'
            ]),
            'playable': nav(header, [
                  'moreContentButton',
                  'buttonRenderer',
                  'navigationEndpoint',
                  'watchPlaylistEndpoint'
                ]) !=
                null,
            'endpoint': nav(header, [
                  'moreContentButton',
                  'buttonRenderer',
                  'navigationEndpoint',
                  'watchPlaylistEndpoint'
                ]) ??
                nav(header, [
                  'moreContentButton',
                  'buttonRenderer',
                  'navigationEndpoint',
                  'browseEndpoint'
                ]),
          }
        : null,
  };

  res.removeWhere((key, val) => val == null);
  return res;
}

String playlistIdTrimmer(String playlistId) {
  if (playlistId.startsWith('VL')) {
    return playlistId.substring(2);
  } else {
    return playlistId;
  }
}
