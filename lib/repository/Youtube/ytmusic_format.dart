import 'dart:developer';
import 'dart:io';

Future<String> getSongUrl(
  String id,
) async {
  String quality = 'Medium';

  id = id.replaceFirst('youtube', '');
  return 'http://${InternetAddress.loopbackIPv4.host}:8080?id=$id&q=$quality';
}

List formatChartItems(List itemsList) {
  try {
    final List result = itemsList.map((e) {
      return {
        'title': e['gridPlaylistRenderer']['title']['runs'][0]['text'],
        'type': 'chart',
        'subtitle': e['gridPlaylistRenderer']['shortBylineText']['runs'][0]
            ['text'],
        'count': e['gridPlaylistRenderer']['videoCountText']['runs'][0]['text'],
        'id':
            'youtube${e['gridPlaylistRenderer']['navigationEndpoint']['watchEndpoint']['playlistId']}',
        'firstItemId':
            'youtube${e['gridPlaylistRenderer']['navigationEndpoint']['watchEndpoint']['videoId']}',
        'image': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]['url'],
        'images': e['gridPlaylistRenderer']['thumbnail']['thumbnails']
            .map((e) => e['url'])
            .toList(),
        'provider': 'youtube',
      };
    }).toList();

    return result;
  } catch (e) {
    log('Error in formatChartItems: $e');
    return List.empty();
  }
}

List formatItems(List itemsList) {
  try {
    final List result = itemsList.map((e) {
      return {
        'title': e['compactStationRenderer']['title']['simpleText'],
        'type': 'playlist',
        'subtitle': e['compactStationRenderer']['description']['simpleText'],
        'count': e['compactStationRenderer']['videoCountText']['runs'][0]
            ['text'],
        'id':
            'youtube${e['compactStationRenderer']['navigationEndpoint']['watchEndpoint']['playlistId']}',
        'firstItemId':
            'youtube${e['compactStationRenderer']['navigationEndpoint']['watchEndpoint']['videoId']}',
        'image': e['compactStationRenderer']['thumbnail']['thumbnails'][0]
            ['url'],
        'images': [
          e['compactStationRenderer']['thumbnail']['thumbnails'][0]['url'],
          e['compactStationRenderer']['thumbnail']['thumbnails'][1]['url'],
          e['compactStationRenderer']['thumbnail']['thumbnails'][2]['url'],
        ],
        'provider': 'youtube'
      };
    }).toList();

    return result;
  } catch (e) {
    log('Error in formatItems: $e');
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
        'id':
            'youtube${e['defaultPromoPanelRenderer']['navigationEndpoint']['watchEndpoint']['videoId']}',
        'firstItemId':
            'youtube${e['defaultPromoPanelRenderer']['navigationEndpoint']['watchEndpoint']['videoId']}',
        'image': e['defaultPromoPanelRenderer']
                        ['largeFormFactorBackgroundThumbnail']
                    ['thumbnailLandscapePortraitRenderer']['landscape']
                ['thumbnails']
            .last['url'],
        'images': e['defaultPromoPanelRenderer']
                        ['largeFormFactorBackgroundThumbnail']
                    ['thumbnailLandscapePortraitRenderer']['landscape']
                ['thumbnails']
            .map((e) => e['url'])
            .toList(),
        'provider': 'youtube'
      };
    }).toList();

    return result;
  } catch (e) {
    log('Error in formatHeadItems: $e');
    return List.empty();
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
        'id': 'youtube${e['gridVideoRenderer']['videoId']}',
        'firstItemId': 'youtube${e['gridVideoRenderer']['videoId']}',
        'image': e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
        'images': e['gridVideoRenderer']['thumbnail']['thumbnails']
            .map((e) => e['url'])
            .toList(),
        'provider': 'youtube'
      };
    }).toList();

    return result;
  } catch (e) {
    log('Error in formatVideoItems: $e');
    return List.empty();
  }
}

Future<List> formatHomeSections(List items) async {
  List result = [];
  try {
    for (Map v in items) {
      final e = v['richItemRenderer']['content'];
      if (e['lockupViewModel'] != null) {
        result.add({
          'title': e['lockupViewModel']['metadata']['lockupMetadataViewModel']
              ['title']['content'],
          'type': 'playlist',
          'subtitle': e['lockupViewModel']['metadata']
                      ['lockupMetadataViewModel']['metadata']
                  ['contentMetadataViewModel']['metadataRows'][0]
              ['metadataParts'][0]['text']['content'],
          'count': e['lockupViewModel']['contentImage']
                          ['collectionThumbnailViewModel']['primaryThumbnail']
                      ['thumbnailViewModel']['overlays'][0]
                  ['thumbnailOverlayBadgeViewModel']['thumbnailBadges'][0]
              ['thumbnailBadgeViewModel']['text'],
          'id': 'youtube${e['lockupViewModel']['contentId']}',
          // 'firstItemId':
          //     'youtube${e['lockupViewModel']['navigationEndpoint']['watchPlaylistEndpoint']['videoId']}',
          'image': e['lockupViewModel']['contentImage']
                  ['collectionThumbnailViewModel']['primaryThumbnail']
              ['thumbnailViewModel']['image']['sources'][0]['url'],
          'isWide': (e['lockupViewModel']['contentImage']
                          ['collectionThumbnailViewModel']['primaryThumbnail']
                      ['thumbnailViewModel']['image']['sources'][0]['width'] !=
                  e['lockupViewModel']['contentImage']
                          ['collectionThumbnailViewModel']['primaryThumbnail']
                      ['thumbnailViewModel']['image']['sources'][0]['height'])
              ? true
              : false,
          'images': e['lockupViewModel']['contentImage']
                      ['collectionThumbnailViewModel']['primaryThumbnail']
                  ['thumbnailViewModel']['image']['sources']
              .map((e) => e['url'])
              .toList(),
          'provider': 'youtube'
        });
      } else if (e['gridPlaylistRenderer'] != null) {
        result.add({
          'title': e['gridPlaylistRenderer']['title']['runs'][0]['text'],
          'type': 'chart',
          'subtitle': e['gridPlaylistRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridPlaylistRenderer']['videoCountText']['runs'][0]
              ['text'],
          'id':
              'youtube${e['gridPlaylistRenderer']['navigationEndpoint']['watchEndpoint']['playlistId']}',
          'firstItemId':
              'youtube${e['gridPlaylistRenderer']['navigationEndpoint']['watchEndpoint']['videoId']}',
          'image': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'images': e['gridPlaylistRenderer']['thumbnail']['thumbnails']
              .map((e) => e['url'])
              .toList(),
          'provider': 'youtube',
        });
      } else if (e['gridVideoRenderer'] != null) {
        result.add({
          'title': e['gridVideoRenderer']['title']['simpleText'],
          'type': 'video',
          'isWide': true,
          'subtitle': e['gridVideoRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'artist': e['gridVideoRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridVideoRenderer']['shortViewCountText']['simpleText'],
          'id': 'youtube${e['gridVideoRenderer']['videoId']}',
          'firstItemId': 'youtube${e['gridVideoRenderer']['videoId']}',
          'image':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
          'images': e['gridVideoRenderer']['thumbnail']['thumbnails']
              .map((e) => e['url'])
              .toList(),
          'url':
              await getSongUrl('youtube${e['gridVideoRenderer']['videoId']}'),
          'provider': 'youtube'
        });
      }
    }
  } catch (e) {
    log('Error in formatHomeSections: $e');
  }

  return result;
}

String decodeHexEscapeSequences(String input) {
  return input.replaceAllMapped(RegExp(r'\\x([0-9A-Fa-f]{2})'), (match) {
    String hexCode = match.group(1)!;
    int charCode = int.parse(hexCode, radix: 16);
    return String.fromCharCode(charCode);
  });
}

String decodeUnicode(String input) {
  return input.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'), (match) {
    var hexCode = match.group(1);
    return String.fromCharCode(int.parse(hexCode!, radix: 16));
  });
}
