import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';

/// Higher-level collection mappers: compose [ArtistSummary], [AlbumSummary],
/// [PlaylistSummary] <-> [PlaylistDB].
///
/// Low-level artwork / artist / album helpers live in [media_item_mapper.dart].
/// This file imports and uses them directly -- do not redefine them here.

// -- ArtistSummary <-> PlaylistDB -----------------------------------------

/// Wrap an [ArtistSummary] as a [PlaylistDB] row (for library persistence).
PlaylistDB artistSummaryToPlaylistDB(ArtistSummary artistSummary) {
  return PlaylistDB(
    name: artistSummary.name,
    album: null,
    artists: [artistSummaryToArtistSummaryDB(artistSummary)],
    type: PlaylistTypeDB.artist,
    createdat: DateTime.now(),
    thumbnail: artistSummary.thumbnail != null
        ? artworkToArtworkDB(artistSummary.thumbnail!)
        : null,
  );
}

/// Extract the first [ArtistSummary] from an artist-type [PlaylistDB].
ArtistSummary playlistDBToArtistSummary(PlaylistDB playlistDB) {
  final first = playlistDB.artists?.firstOrNull;
  return ArtistSummary(
    id: first?.mediaId ?? '',
    name: first?.name ?? 'Unknown',
    subtitle: first?.subtitle,
    thumbnail:
        first?.thumbnail != null ? artworkDBToArtwork(first!.thumbnail!) : null,
    url: first?.url,
  );
}

// -- AlbumSummary <-> PlaylistDB ------------------------------------------

/// Wrap an [AlbumSummary] as an album-type [PlaylistDB].
PlaylistDB albumSummaryToPlaylistDB(AlbumSummary albumSummary) {
  return PlaylistDB(
    name: albumSummary.title,
    album: albumSummaryToAlbumSummaryDB(albumSummary),
    artists: albumSummary.artists
        .map((a) => artistSummaryToArtistSummaryDB(a))
        .toList(),
    createdat: DateTime.now(),
    type: PlaylistTypeDB.album,
    thumbnail: albumSummary.thumbnail != null
        ? artworkToArtworkDB(albumSummary.thumbnail!)
        : null,
  );
}

/// Reconstruct an [AlbumSummary] from an album-type [PlaylistDB].
AlbumSummary playlistDBToAlbumSummary(PlaylistDB playlistDB) {
  return AlbumSummary(
    id: playlistDB.album?.mediaId ?? '',
    title: playlistDB.name,
    thumbnail: playlistDB.thumbnail != null
        ? artworkDBToArtwork(playlistDB.thumbnail!)
        : null,
    artists: playlistDB.artists != null
        ? playlistDB.artists!
            .map((a) => artistSummaryDBToArtistSummary(a))
            .toList()
        : [],
    url: playlistDB.album?.url,
    year: int.tryParse(playlistDB.album?.year ?? '') ?? 0,
  );
}

// -- PlaylistSummary <-> PlaylistDB ----------------------------------------

/// Build a [RemotePlaylistSummaryDB] embedded object from a [PlaylistSummary].
RemotePlaylistSummaryDB playlistSummaryToRemotePlaylistSummaryDB(
    PlaylistSummary playlistSummary) {
  return RemotePlaylistSummaryDB()
    ..mediaId = playlistSummary.id
    ..name = playlistSummary.title
    ..thumbnail = artworkToArtworkDB(playlistSummary.thumbnail)
    ..artists = playlistSummary.owner != null
        ? [
            ArtistSummaryDB()
              ..name = playlistSummary.owner!
              ..mediaId = ''
              ..subtitle = null
              ..thumbnail = null
              ..url = null,
          ]
        : null
    ..url = playlistSummary.url;
}

/// Wrap a remote [PlaylistSummary] as a remotePlaylist-type [PlaylistDB].
PlaylistDB playlistSummaryToPlaylistDB(PlaylistSummary playlistSummary) {
  return PlaylistDB(
    name: playlistSummary.title,
    remotePlaylist: playlistSummaryToRemotePlaylistSummaryDB(playlistSummary),
    album: null,
    artists: null,
    createdat: DateTime.now(),
    subtitle: playlistSummary.owner,
    description: null,
    thumbnail: artworkToArtworkDB(playlistSummary.thumbnail),
    type: PlaylistTypeDB.remotePlaylist,
    updatedat: null,
  );
}

/// Reconstruct a [PlaylistSummary] from a remotePlaylist-type [PlaylistDB].
PlaylistSummary playlistDBToPlaylistSummary(PlaylistDB playlistDB) {
  return PlaylistSummary(
    id: playlistDB.remotePlaylist?.mediaId ?? '',
    title: playlistDB.name,
    thumbnail: playlistDB.thumbnail != null
        ? artworkDBToArtwork(playlistDB.thumbnail!)
        : const Artwork(url: '', layout: ImageLayout.square),
    url: playlistDB.remotePlaylist?.url,
    owner: (playlistDB.artists != null && playlistDB.artists!.isNotEmpty)
        ? playlistDB.artists!.map((a) => a.name).join(', ')
        : null,
  );
}

/// Convert a [RemotePlaylistSummaryDB] embedded object to [PlaylistSummary].
PlaylistSummary remotePlaylistSummaryDBToPlaylistSummary(
    RemotePlaylistSummaryDB r) {
  return PlaylistSummary(
    id: r.mediaId ?? '',
    title: r.name,
    thumbnail: r.thumbnail != null
        ? artworkDBToArtwork(r.thumbnail!)
        : const Artwork(url: '', layout: ImageLayout.square),
    url: r.url,
    owner: (r.artists != null && r.artists!.isNotEmpty)
        ? r.artists!.map((a) => a.name).join(', ')
        : null,
  );
}
