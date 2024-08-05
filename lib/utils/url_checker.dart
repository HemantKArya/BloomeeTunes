import 'dart:developer';

Map<String, dynamic> isSpotifyUrl(String url) {
  Uri uri;
  try {
    uri = Uri.parse(url);
  } on FormatException catch (_) {
    return {'isSpotify': false, 'type': ''};
  }
  if (uri.host != 'open.spotify.com') {
    return {'isSpotify': false, 'type': ''};
  }
  // Check if the path starts with /track/ or /playlist/
  final pathParts = uri.pathSegments;
  if (pathParts.length < 2) {
    return {'isSpotify': false, 'type': ''};
  }
  final type = pathParts[0];
  return {
    'isSpotify': true,
    'type': type == 'track'
        ? 'track'
        : (type == 'playlist')
            ? 'playlist'
            : 'album'
  };
}

bool isYoutubeLink(String link) {
  if (link.contains("youtube.com") || link.contains("youtu.be")) {
    return true;
  } else {
    return false;
  }
}

String? extractVideoId(String url) {
  try {
    Uri uri = Uri.parse(url);
    if (uri.host == 'youtube.com') {
      return uri.queryParameters['v']; // Retrieve video ID from query parameter
    }
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.first; // Retrieve video ID from path
    }
    if (uri.host == 'www.youtube.com' && uri.pathSegments.contains('watch')) {
      return uri.queryParameters['v'];
    }
  } catch (e) {
    log(e.toString());
  }

  return null;
}

String? extractYTMusicId(String url) {
  try {
    Uri uri = Uri.parse(url);
    if (uri.host == 'music.youtube.com') {
      return uri.queryParameters['v']; // Retrieve video ID from query parameter
    }
  } catch (e) {
    log(e.toString());
  }

  return null;
}

String? extractSpotifyPlaylistId(String url) {
  try {
    Uri uri = Uri.parse(url);
    if (uri.host == 'open.spotify.com') {
      final pathParts = uri.pathSegments;
      if (pathParts.length < 2) {
        return null;
      }
      if (pathParts[0] == 'playlist') {
        return pathParts[1];
      }
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}

String? extractSpotifyAlbumId(String url) {
  try {
    Uri uri = Uri.parse(url);
    if (uri.host == 'open.spotify.com') {
      final pathParts = uri.pathSegments;
      if (pathParts.length < 2) {
        return null;
      }
      if (pathParts[0] == 'album') {
        return pathParts[1];
      }
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}

String? extractSpotifyTrackId(String url) {
  try {
    Uri uri = Uri.parse(url);
    if (uri.host == 'open.spotify.com') {
      final pathParts = uri.pathSegments;
      if (pathParts.length < 2) {
        return null;
      }
      if (pathParts[0] == 'track') {
        return pathParts[1];
      }
    }
  } catch (e) {
    log(e.toString(), name: 'extractSpotifyTrackId');
  }
  return null;
}

bool isUrl(String url) {
  try {
    Uri.parse(url);
    return true;
  } catch (e) {
    return false;
  }
}

enum UrlType {
  youtubeVideo,
  youtubePlaylist,
  spotifyTrack,
  spotifyPlaylist,
  spotifyAlbum,
  other
}

UrlType getUrlType(String url) {
  if (isUrl(url)) {
    if (isYoutubeLink(url)) {
      if (url.contains("playlist")) {
        return UrlType.youtubePlaylist;
      } else {
        return UrlType.youtubeVideo;
      }
    } else {
      final spotifyUrl = isSpotifyUrl(url);
      if (spotifyUrl['isSpotify']) {
        if (spotifyUrl['type'] == 'playlist') {
          return UrlType.spotifyPlaylist;
        } else if (spotifyUrl['type'] == 'track') {
          return UrlType.spotifyTrack;
        } else if (spotifyUrl['type'] == 'album') {
          return UrlType.spotifyAlbum;
        }
      }
    }
  }
  return UrlType.other;
}
