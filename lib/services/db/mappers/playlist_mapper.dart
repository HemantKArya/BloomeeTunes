import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';

/// Maps between [PlaylistDB] (Isar entity) and [Playlist] (domain model).

// ── PlaylistDB → Playlist (domain) ───────────────────────────────────────────

/// Convert [PlaylistDB] to the domain [Playlist].
/// Does NOT populate [Playlist.tracks] — callers must call
/// [PlaylistDAO.getPlaylistTracks] and then [trackDBToTrack] separately,
/// because entries require a separate Isar query.
Playlist playlistDBToPlaylist(PlaylistDB playlistDB) {
  return Playlist(
    tracks: List.empty(growable: true),
    title: playlistDB.name,
    thumbnail: playlistDB.thumbnail != null
        ? artworkDBToArtwork(playlistDB.thumbnail!)
        : null,
    subtitle: playlistDB.subtitle,
    description: playlistDB.description,
    type: playlistTypeDBToPlaylistType(playlistDB.type),
    artists: playlistDB.artists
        ?.map((e) => artistSummaryDBToArtistSummary(e))
        .toList(),
    album: playlistDB.album != null
        ? albumSummaryDBToAlbumSummary(playlistDB.album!)
        : null,
    remotePlaylist: playlistDB.remotePlaylist != null
        ? playlistSummaryDBToPlaylistSummary(playlistDB.remotePlaylist!)
        : null,
    createdAt: playlistDB.createdAt,
    updatedAt: playlistDB.updatedAt,
  );
}

// ── Playlist (domain) → PlaylistDB ───────────────────────────────────────────

/// Convert domain [Playlist] back to [PlaylistDB].
/// Sets [id] to Isar.autoIncrement (0) by default — the DAO will resolve
/// the correct id before saving.
PlaylistDB playlistToPlaylistDB(Playlist playlist) {
  return PlaylistDB(
    name: playlist.title,
    subtitle: playlist.subtitle,
    description: playlist.description,
    thumbnail: playlist.thumbnail != null
        ? artworkToArtworkDB(playlist.thumbnail!)
        : null,
    artists: playlist.artists
        ?.map((a) => artistSummaryToArtistSummaryDB(a))
        .toList(),
    album: playlist.album != null
        ? albumSummaryToAlbumSummaryDB(playlist.album!)
        : null,
    remotePlaylist:
        null, // remote playlist data lives in PlaylistDB.remotePlaylist
    type: playlistTypeToPlaylistTypeDB(playlist.type),
    createdat: playlist.createdAt,
    updatedat: playlist.updatedAt ?? DateTime.now(),
  );
}

// ── PlaylistEntryDB helpers ───────────────────────────────────────────────────

/// Return sorted [TrackDB] objects from already-loaded [PlaylistEntryDB] list.
///
/// Expects entries to be sorted by position ascending; call
/// [trackDBToTrack] on each element to get domain [Track] objects.
List<TrackDB> entriesToTracks(List<PlaylistEntryDB> entries) {
  final result = <TrackDB>[];
  for (final entry in entries) {
    if (entry.track.value != null) {
      result.add(entry.track.value!);
    }
  }
  return result;
}

// ── Internal enum converters ──────────────────────────────────────────────────

PlaylistType playlistTypeDBToPlaylistType(PlaylistTypeDB t) {
  switch (t) {
    case PlaylistTypeDB.album:
      return PlaylistType.album;
    case PlaylistTypeDB.artist:
      return PlaylistType.artist;
    case PlaylistTypeDB.remotePlaylist:
      return PlaylistType.remotePlaylist;
    case PlaylistTypeDB.userPlaylist:
      return PlaylistType.userPlaylist;
  }
}

PlaylistTypeDB playlistTypeToPlaylistTypeDB(PlaylistType t) {
  switch (t) {
    case PlaylistType.album:
      return PlaylistTypeDB.album;
    case PlaylistType.artist:
      return PlaylistTypeDB.artist;
    case PlaylistType.remotePlaylist:
      return PlaylistTypeDB.remotePlaylist;
    case PlaylistType.userPlaylist:
      return PlaylistTypeDB.userPlaylist;
  }
}
