/// Track↔MediaItem adapter — bridges Rust [Track] and audio_service [MediaItem].
///
/// [MediaItem] is required by `audio_service` for OS notification / lock screen
/// controls. [Track] is the plugin system's domain model.
///
/// All conversions funnel through this file. No other code should construct
/// MediaItem or MediaItemModel directly.
library track_adapter;

import 'dart:io';

import 'package:Bloomee/core/models/exported.dart' hide MediaItem;
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:audio_service/audio_service.dart';

/// Convert a plugin [Track] to an audio_service [MediaItem].
///
/// Used at the player→OS boundary for notifications and lock screen.
MediaItem trackToMediaItem(Track track) {
  final artistStr = track.artists.isNotEmpty
      ? track.artists.map((a) => a.name).join(', ')
      : 'Unknown Artist';

  return MediaItem(
    id: track.id,
    title: track.title,
    album: track.album?.title ?? '',
    // audio_service_win C++ crashes on null album (std::get<std::string> on null variant).
    artist: artistStr,
    artUri: _safeArtUri(track.thumbnail.url),
    duration: track.durationMs != null
        ? Duration(milliseconds: track.durationMs!.toInt())
        : null,
    extras: <String, dynamic>{
      'isExplicit': track.isExplicit,
      'thumbnailUrl': track.thumbnail.url,
      'thumbnailUrlLow': track.thumbnail.urlLow,
      'thumbnailUrlHigh': track.thumbnail.urlHigh,
    },
  );
}

/// Validate a thumbnail URL before creating an [artUri] for MediaItem.
///
/// Accepts HTTP(S) URLs and `file://` URIs (for local track artwork).
/// Raw absolute paths (e.g. `/data/...` or `C:\...`) are converted to
/// `file://` URIs so the platform media session can load them.
/// Returns `null` for empty or malformed strings.
Uri? _safeArtUri(String url) {
  if (url.isEmpty) return null;

  final trimmed = url.trim();

  // Raw absolute path → convert to file URI.
  if (trimmed.startsWith('/') || RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed)) {
    try {
      final file = File(trimmed);
      if (file.existsSync()) return Uri.file(trimmed);
    } catch (_) {}
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  // file:// URI — validate the file exists.
  if (uri.scheme == 'file') {
    try {
      final path = uri.toFilePath();
      if (File(path).existsSync()) return uri;
    } catch (_) {}
    return null;
  }

  // HTTP(S) — require a real host.
  if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
    return uri;
  }

  return null;
}

/// Convert an audio_service [MediaItem] back to a minimal [Track].
///
/// Used when the OS sends a media item back (e.g., queue restore).
/// This is inherently lossy — the Track will lack full artist/album details.
Track mediaItemToTrack(MediaItem mi) {
  final artists = (mi.artist ?? '')
      .split(', ')
      .where((s) => s.isNotEmpty)
      .map((name) => ArtistSummary(id: '', name: name))
      .toList();

  return Track(
    id: mi.id,
    title: mi.title,
    artists: artists,
    album: mi.album != null
        ? AlbumSummary(id: '', title: mi.album!, artists: [])
        : null,
    thumbnail: Artwork(
      url: mi.artUri?.toString() ?? '',
      layout: ImageLayout.square,
    ),
    durationMs:
        mi.duration != null ? BigInt.from(mi.duration!.inMilliseconds) : null,
    isExplicit: mi.extras?['isExplicit'] as bool? ?? false,
  );
}

/// Build a [Playlist] from a list of [Track]s.
///
/// Convenience wrapper used when creating queue playlists, search result
/// collections, or any ad-hoc track grouping that needs a [Playlist] shell.
Playlist tracksToPlaylist(
  String title,
  List<Track> tracks, {
  Artwork? thumbnail,
  String? description,
  PlaylistType type = PlaylistType.userPlaylist,
}) {
  return Playlist(
    title: title,
    tracks: tracks,
    thumbnail: thumbnail,
    description: description,
    type: type,
  );
}
