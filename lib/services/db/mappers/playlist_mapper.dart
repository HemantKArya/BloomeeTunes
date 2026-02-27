import 'package:Bloomee/model/media_playlist_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';

/// Maps between [MediaPlaylistDB] (Isar entity) and [MediaPlaylist] (domain).
///
/// Extracted from `media_playlist_model.dart` to keep domain models DB-free.

MediaPlaylist playlistDBToMediaPlaylist(MediaPlaylistDB mediaPlaylistDB,
    {PlaylistsInfoDB? playlistsInfoDB}) {
  MediaPlaylist mediaPlaylist =
      MediaPlaylist(mediaItems: [], playlistName: mediaPlaylistDB.playlistName);
  if (mediaPlaylistDB.mediaItems.isNotEmpty) {
    for (var element in mediaPlaylistDB.mediaItems) {
      mediaPlaylist.mediaItems.add(mediaItemDBToMediaItem(element));
    }
  }
  if (playlistsInfoDB != null) {
    mediaPlaylist = mediaPlaylist.copyWith(
      imgUrl: playlistsInfoDB.artURL,
      permaURL: playlistsInfoDB.permaURL,
      description: playlistsInfoDB.description,
      artists: playlistsInfoDB.artists,
      source: playlistsInfoDB.source,
      lastUpdated: playlistsInfoDB.lastUpdated,
      isAlbum: playlistsInfoDB.isAlbum,
    );
  }
  return mediaPlaylist;
}

