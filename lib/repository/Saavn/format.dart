import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_des/dart_des.dart';
import 'package:logging/logging.dart';
import 'package:Bloomee/utils/extentions.dart';

String getImageUrl(String? imageUrl, {String quality = 'high'}) {
  if (imageUrl == null) return '';
  switch (quality) {
    case 'high':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '500x500')
          .replaceAll('150x150', '500x500');
    case 'medium':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '150x150')
          .replaceAll('500x500', '150x150');
    case 'low':
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('150x150', '50x50')
          .replaceAll('500x500', '50x50');
    default:
      return imageUrl
          .trim()
          .replaceAll('http:', 'https:')
          .replaceAll('50x50', '500x500')
          .replaceAll('150x150', '500x500');
  }
}

String decode(String input) {
  const String key = '38346591';
  final DES desECB = DES(key: key.codeUnits);

  final Uint8List encrypted = base64.decode(input);
  final List<int> decrypted = desECB.decrypt(encrypted);
  final String decoded = utf8
      .decode(decrypted)
      .replaceAll(RegExp(r'\.mp4.*'), '.mp4')
      .replaceAll(RegExp(r'\.m4a.*'), '.m4a');
  return decoded.replaceAll('http:', 'https:');
}

Future<List> formatSongsResponse(
  List responseList,
  String type,
) async {
  // print(responseList);
  final List searchedList = [];
  for (int i = 0; i < responseList.length; i++) {
    Map? response;
    switch (type) {
      case 'song':
      case 'album':
      case 'playlist':
      case 'show':
      case 'mix':
        response = await formatSingleSongResponse(responseList[i] as Map);
        // print(response);
        break;
      default:
        break;
    }

    if (response != null && response.containsKey('Error')) {
      Logger.root.severe(
        'Error at index $i inside FormatSongsResponse: ${response["Error"]}',
      );
    } else {
      if (response != null) {
        searchedList.add(response);
      }
    }
    // print(searchedList);
  }
  return searchedList;
}

Future<Map> formatSingleSongResponse(Map response) async {
  // Map cachedSong = Hive.box('cache').get(response['id']);
  // if (cachedSong != null) {
  //   return cachedSong;
  // }
  try {
    // final List artistNames = [];
    // if (response['artistMap'] == false ||
    //     response['primary_artists'] == null ||
    //     response['primary_artists'].length == 0) {
    //   if (response['artistMap'] == false ||
    //       response['featured_artists'] == null ||
    //       response['featured_artists']?.length == 0) {
    //     if (response['artistMap'] == false ||
    //         response['artists'] == null ||
    //         response['artists']?.length == 0) {
    //       if (response['music'] != null) {
    //         artistNames.add(response['music']);
    //       } else {
    //         artistNames.add('Unknown');
    //       }
    //     } else {
    //       try {
    //         artistNames.add(response['primary_artists_id']);
    //       } catch (e) {
    //         artistNames.add(response['artists']);
    //       }
    //     }
    //   } else {
    //     artistNames.add(response['featured_artists']);
    //   }
    // } else {
    //   artistNames.add(response['primary_artists']);
    // }

    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['album'].toString().unescape(),
      'year': response['year'],
      'duration': response['duration'],
      'language': response['language'].toString().capitalize(),
      'genre': response['language'].toString().capitalize(),
      '320kbps': response['320kbps'],
      'has_lyrics': response['has_lyrics'],
      'lyrics_snippet': response['lyrics_snippet'].toString().unescape(),
      'release_date': response['release_date'],
      'album_id': ['albumid'],
      // 'subtitle': response['subtitle'].toString().unescape(),
      'title': response['song'].toString().unescape(),
      'artist': response['primary_artists'].toString().unescape(),
      // 'album_artist': response['more_info'],
      'image': getImageUrl(response['image'].toString()),
      'perma_url': response['perma_url'],
      'url': decode(response['encrypted_media_url'].toString()),
    };
    // Hive.box('cache').put(response['id'].toString(), info);
  } catch (e) {
    Logger.root.severe('Error inside FormatSingleSongResponse: $e');
    return {'Error': e};
  }
}

// Future<Map> formatHomePageData(Map data) async {
//   try {
//     if (data['new_trending'] != null) {
//       data['new_trending'] =
//           await formatSongsInList(data['new_trending'] as List);
//     }
//     if (data['new_albums'] != null) {
//       data['new_albums'] = await formatSongsInList(data['new_albums'] as List);
//     }
//     if (data['city_mod'] != null) {
//       data['city_mod'] = await formatSongsInList(data['city_mod'] as List);
//     }
//     final List promoList = [];
//     final List promoListTemp = [];
//     data['modules'].forEach((k, v) {
//       if (k.startsWith('promo') as bool) {
//         if (data[k][0]['type'] == 'song' &&
//             (data[k][0]['mini_obj'] as bool? ?? false)) {
//           promoListTemp.add(k.toString());
//         } else {
//           promoList.add(k.toString());
//         }
//       }
//     });
//     for (int i = 0; i < promoList.length; i++) {
//       data[promoList[i]] = await formatSongsInList(data[promoList[i]] as List);
//     }
//     data['collections'] = [
//       'new_trending',
//       'charts',
//       'new_albums',
//       'tag_mixes',
//       'top_playlists',
//       'radio',
//       'city_mod',
//       'artist_recos',
//       ...promoList
//     ];
//     data['collections_temp'] = promoListTemp;
//   } catch (e) {
//     Logger.root.severe('Error inside formatHomePageData: $e');
//   }
//   return data;
// }

Future<Map> formatSingleAlbumResponse(Map response) async {
  try {
    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['title'].toString().unescape(),
      'year': response['more_info']?['year'] ?? response['year'],
      'language': response['more_info']?['language'] == null
          ? response['language'].toString().capitalize()
          : response['more_info']['language'].toString().capitalize(),
      'genre': response['more_info']?['language'] == null
          ? response['language'].toString().capitalize()
          : response['more_info']['language'].toString().capitalize(),
      'album_id': response['id'],
      'subtitle': response['description'] == null
          ? response['subtitle'].toString().unescape()
          : response['description'].toString().unescape(),
      'title': response['title'].toString().unescape(),
      'artist': response['music'] == null
          ? (response['more_info']?['music'] == null)
              ? (response['more_info']?['artistMap']?['primary_artists'] ==
                          null ||
                      (response['more_info']?['artistMap']?['primary_artists']
                              as List)
                          .isEmpty)
                  ? ''
                  : response['more_info']['artistMap']['primary_artists'][0]
                          ['name']
                      .toString()
                      .unescape()
              : response['more_info']['music'].toString().unescape()
          : response['music'].toString().unescape(),
      'album_artist': response['more_info'] == null
          ? response['music']
          : response['more_info']['music'],
      'image': getImageUrl(response['image'].toString()),
      'count': response['more_info']?['song_pids'] == null
          ? 0
          : response['more_info']['song_pids'].toString().split(', ').length,
      'songs_pids': response['more_info']['song_pids'].toString().split(', '),
      'perma_url': response['url'].toString(),
    };
  } catch (e) {
    Logger.root.severe('Error inside formatSingleAlbumResponse: $e');
    return {'Error': e};
  }
}

Future<Map> formatSingleAlbumSongResponse(Map response) async {
  try {
    final List artistNames = [];
    if (response['primary_artists'] == null ||
        response['primary_artists'].toString().trim() == '') {
      if (response['featured_artists'] == null ||
          response['featured_artists'].toString().trim() == '') {
        if (response['singers'] == null ||
            response['singer'].toString().trim() == '') {
          response['singers'].toString().split(', ').forEach((element) {
            artistNames.add(element);
          });
        } else {
          artistNames.add('Unknown');
        }
      } else {
        response['featured_artists'].toString().split(', ').forEach((element) {
          artistNames.add(element);
        });
      }
    } else {
      response['primary_artists'].toString().split(', ').forEach((element) {
        artistNames.add(element);
      });
    }

    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['album'].toString().unescape(),
      // .split('(')
      // .first
      'year': response['year'],
      'duration': response['duration'],
      'language': response['language'].toString().capitalize(),
      'genre': response['language'].toString().capitalize(),
      '320kbps': response['320kbps'],
      'has_lyrics': response['has_lyrics'],
      'lyrics_snippet': response['lyrics_snippet'].toString().unescape(),
      'release_date': response['release_date'],
      'album_id': response['album_id'],
      'subtitle':
          '${response["primary_artists"].toString().trim()} - ${response["album"].toString().trim()}'
              .unescape(),

      'title': response['song'].toString().unescape(),
      // .split('(')
      // .first
      'artist': artistNames.join(', ').unescape(),
      'album_artist': response['more_info'] == null
          ? response['music']
          : response['more_info']['music'],
      'image': getImageUrl(response['image'].toString()),
      'perma_url': response['perma_url'],
      'url': decode(response['encrypted_media_url'].toString())
    };
  } catch (e) {
    Logger.root.severe('Error inside FormatSingleAlbumSongResponse: $e');
    return {'Error': e};
  }
}

Future<Map> formatSinglePlaylistResponse(Map response) async {
  try {
    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['title'].toString().unescape(),
      'language': response['language'] == null
          ? response['more_info']['language'].toString().capitalize()
          : response['language'].toString().capitalize(),
      'genre': response['language'] == null
          ? response['more_info']['language'].toString().capitalize()
          : response['language'].toString().capitalize(),
      'playlistId': response['id'],
      'subtitle': response['description'] == null
          ? response['subtitle'].toString().unescape()
          : response['description'].toString().unescape(),
      'title': response['title'].toString().unescape(),
      'artist': response['extra'].toString().unescape(),
      'album_artist': response['more_info'] == null
          ? response['music']
          : response['more_info']['music'],
      'image': getImageUrl(response['image'].toString()),
      'perma_url': response['url'].toString(),
    };
  } catch (e) {
    Logger.root.severe('Error inside formatSinglePlaylistResponse: $e');
    return {'Error': e};
  }
}

Future<Map> formatSingleArtistResponse(Map response) async {
  try {
    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['title'] == null
          ? response['name'].toString().unescape()
          : response['title'].toString().unescape(),
      'language': response['language'].toString().capitalize(),
      'genre': response['language'].toString().capitalize(),
      'artistId': response['id'],
      'artistToken': response['url'] == null
          ? response['perma_url'].toString().split('/').last
          : response['url'].toString().split('/').last,
      'subtitle': response['description'] == null
          ? response['role'].toString().capitalize()
          : response['description'].toString().unescape(),
      'title': response['title'] == null
          ? response['name'].toString().unescape()
          : response['title'].toString().unescape(),
      // .split('(')
      // .first
      'perma_url': response['url'].toString(),
      'artist': response['title'].toString().unescape(),
      'album_artist': response['more_info'] == null
          ? response['music']
          : response['more_info']['music'],
      'image': getImageUrl(response['image'].toString()),
    };
  } catch (e) {
    Logger.root.severe('Error inside formatSingleArtistResponse: $e');
    return {'Error': e};
  }
}

Future<Map> formatSingleShowResponse(Map response) async {
  try {
    return {
      'id': response['id'],
      'type': response['type'],
      'album': response['title'].toString().unescape(),
      'subtitle': response['description'] == null
          ? response['subtitle'].toString().unescape()
          : response['description'].toString().unescape(),
      'title': response['title'].toString().unescape(),
      'image': getImageUrl(response['image'].toString()),
    };
  } catch (e) {
    Logger.root.severe('Error inside formatSingleShowResponse: $e');
    return {'Error': e};
  }
}

Future<List<Map>> formatAlbumResponse(
  List responseList,
  String type,
) async {
  final List<Map> searchedAlbumList = [];
  for (int i = 0; i < responseList.length; i++) {
    Map? response;
    switch (type) {
      case 'album':
        response = await formatSingleAlbumResponse(responseList[i] as Map);
        break;
      case 'artist':
        response = await formatSingleArtistResponse(responseList[i] as Map);
        break;
      case 'playlist':
        response = await formatSinglePlaylistResponse(responseList[i] as Map);
        break;
      case 'show':
        response = await formatSingleShowResponse(responseList[i] as Map);
        break;
    }
    if (response!.containsKey('Error')) {
      Logger.root.severe(
        'Error at index $i inside FormatAlbumResponse: ${response["Error"]}',
      );
    } else {
      searchedAlbumList.add(response);
    }
  }
  return searchedAlbumList;
}
