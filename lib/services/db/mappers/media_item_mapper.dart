import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/services/db/global_db.dart';

/// Maps between [TrackDB] (Isar entity) and [Track] (plugin domain model).
///
/// This file is the single authority for Track ↔ TrackDB conversion.
/// Collection mapper helpers (artwork, artist, album) are re-declared here
/// to avoid cross-mapper imports; collection_mapper.dart provides the full
/// set for playlist-level objects.

// ── Layout helpers ───────────────────────────────────────────────────────────

ImageLayout imageLayoutDBToImageLayout(ImageLayoutDB imageLayoutDB) {
  switch (imageLayoutDB) {
    case ImageLayoutDB.square:
      return ImageLayout.square;
    case ImageLayoutDB.landscape:
      return ImageLayout.landscape;
    case ImageLayoutDB.portrait:
      return ImageLayout.portrait;
    case ImageLayoutDB.banner:
      return ImageLayout.banner;
    case ImageLayoutDB.circular:
      return ImageLayout.circular;
  }
}

ImageLayoutDB imageLayoutToImageLayoutDB(ImageLayout layout) {
  switch (layout) {
    case ImageLayout.square:
      return ImageLayoutDB.square;
    case ImageLayout.banner:
      return ImageLayoutDB.banner;
    case ImageLayout.landscape:
      return ImageLayoutDB.landscape;
    case ImageLayout.portrait:
      return ImageLayoutDB.portrait;
    case ImageLayout.circular:
      return ImageLayoutDB.circular;
  }
}

// ── Artwork ──────────────────────────────────────────────────────────────────

Artwork artworkDBToArtwork(ArtworkDB artworkDB) {
  return Artwork(
    url: artworkDB.url,
    urlLow: artworkDB.urlLow,
    urlHigh: artworkDB.urlHigh,
    layout: imageLayoutDBToImageLayout(artworkDB.layout),
  );
}

ArtworkDB artworkToArtworkDB(Artwork artwork) {
  return ArtworkDB()
    ..url = artwork.url
    ..urlLow = artwork.urlLow
    ..urlHigh = artwork.urlHigh
    ..layout = imageLayoutToImageLayoutDB(artwork.layout);
}

// ── ArtistSummary ─────────────────────────────────────────────────────────────

ArtistSummary artistSummaryDBToArtistSummary(ArtistSummaryDB artistSummaryDB) {
  return ArtistSummary(
    id: artistSummaryDB.mediaId ?? "",
    name: artistSummaryDB.name ?? "Unknown",
    thumbnail: artistSummaryDB.thumbnail != null
        ? artworkDBToArtwork(artistSummaryDB.thumbnail!)
        : null,
    url: artistSummaryDB.url,
    subtitle: artistSummaryDB.subtitle,
  );
}

ArtistSummaryDB artistSummaryToArtistSummaryDB(ArtistSummary artistSummary) {
  return ArtistSummaryDB()
    ..mediaId = artistSummary.id
    ..name = artistSummary.name
    ..subtitle = artistSummary.subtitle
    ..thumbnail = artistSummary.thumbnail != null
        ? artworkToArtworkDB(artistSummary.thumbnail!)
        : null
    ..url = artistSummary.url;
}

// ── AlbumSummary ──────────────────────────────────────────────────────────────

AlbumSummary albumSummaryDBToAlbumSummary(AlbumSummaryDB albumSummaryDB) {
  return AlbumSummary(
    id: albumSummaryDB.mediaId ?? "",
    title: albumSummaryDB.name,
    thumbnail: albumSummaryDB.thumbnail != null
        ? artworkDBToArtwork(albumSummaryDB.thumbnail!)
        : null,
    artists: albumSummaryDB.artists != null
        ? albumSummaryDB.artists!
            .map((a) => artistSummaryDBToArtistSummary(a))
            .toList()
        : [],
    url: albumSummaryDB.url,
    year: int.tryParse(albumSummaryDB.year ?? '') ?? 0,
  );
}

AlbumSummaryDB albumSummaryToAlbumSummaryDB(AlbumSummary albumSummary) {
  return AlbumSummaryDB()
    ..mediaId = albumSummary.id
    ..name = albumSummary.title
    ..thumbnail = albumSummary.thumbnail != null
        ? artworkToArtworkDB(albumSummary.thumbnail!)
        : null
    ..artists = albumSummary.artists
        .map((a) => artistSummaryToArtistSummaryDB(a))
        .toList()
    ..url = albumSummary.url
    ..year = albumSummary.year.toString();
}

// ── RemotePlaylistSummary ─────────────────────────────────────────────────────

PlaylistSummary playlistSummaryDBToPlaylistSummary(
    RemotePlaylistSummaryDB playlistSummaryDB) {
  return PlaylistSummary(
    id: playlistSummaryDB.mediaId ?? "",
    title: playlistSummaryDB.name,
    thumbnail: playlistSummaryDB.thumbnail != null
        ? artworkDBToArtwork(playlistSummaryDB.thumbnail!)
        : const Artwork(url: "", layout: ImageLayout.square),
    url: playlistSummaryDB.url,
    owner: (playlistSummaryDB.artists != null &&
            playlistSummaryDB.artists!.isNotEmpty)
        ? playlistSummaryDB.artists!.map((a) => a.name).join(', ')
        : null,
  );
}

// ── Track ↔ TrackDB ───────────────────────────────────────────────────────────

/// Plugin [Track] (Rust FFI domain model) → [TrackDB] (Isar entity).
///
/// Converts BigInt durationMs to int safely (clamped to max int).
TrackDB trackToTrackDB(Track track) {
  return TrackDB(
    mediaId: track.id,
    title: track.title,
    artists:
        track.artists.map((a) => artistSummaryToArtistSummaryDB(a)).toList(),
    album:
        track.album != null ? albumSummaryToAlbumSummaryDB(track.album!) : null,
    thumbnail: artworkToArtworkDB(track.thumbnail),
    durationMs: track.durationMs?.toInt(),
    isExplicit: track.isExplicit,
  );
}

/// [TrackDB] (Isar entity) → plugin [Track] (domain model).
Track trackDBToTrack(TrackDB trackDB) {
  return Track(
    id: trackDB.mediaId,
    title: trackDB.title,
    artists: trackDB.artists != null
        ? trackDB.artists!
            .map((a) => artistSummaryDBToArtistSummary(a))
            .toList()
        : [],
    album: trackDB.album != null
        ? albumSummaryDBToAlbumSummary(trackDB.album!)
        : null,
    thumbnail: trackDB.thumbnail != null
        ? artworkDBToArtwork(trackDB.thumbnail!)
        : const Artwork(url: "", layout: ImageLayout.square),
    durationMs:
        trackDB.durationMs != null ? BigInt.from(trackDB.durationMs!) : null,
    isExplicit: trackDB.isExplicit,
  );
}
