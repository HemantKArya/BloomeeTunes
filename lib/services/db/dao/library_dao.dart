import 'dart:developer';

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/collection_mapper.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:Bloomee/services/db/mappers/playlist_mapper.dart';
import 'package:isar_community/isar.dart';

/// DAO for the user's saved library: artists, albums, and remote playlists.
///
/// Each saved collection is stored as a [PlaylistDB] row with a typed
/// [PlaylistTypeDB] discriminator. Deduplication uses the embedded mediaId
/// so the same remote entity is never saved twice regardless of display name.
class LibraryDAO {
  final Future<Isar> _db;

  const LibraryDAO(this._db);

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Extract the canonical mediaId from a [PlaylistDB] based on its type.
  String _mediaIdOf(PlaylistDB p) {
    switch (p.type) {
      case PlaylistTypeDB.artist:
        return (p.artists != null && p.artists!.isNotEmpty)
            ? (p.artists!.first.mediaId ?? '')
            : '';
      case PlaylistTypeDB.album:
        return p.album?.mediaId ?? '';
      case PlaylistTypeDB.remotePlaylist:
        return p.remotePlaylist?.mediaId ?? '';
      case PlaylistTypeDB.userPlaylist:
        return '';
    }
  }

  /// Find an existing saved row by mediaId (not name) for the given [type].
  Future<PlaylistDB?> _findByMediaId(
      PlaylistTypeDB type, String mediaId) async {
    if (mediaId.isEmpty) return null;
    final isar = await _db;
    final candidates =
        await isar.playlistDBs.filter().typeIndexEqualTo(type.index).findAll();
    for (final c in candidates) {
      if (_mediaIdOf(c) == mediaId) return c;
    }
    return null;
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  /// Save (or update) an [ArtistSummary] in the library.
  ///
  /// [sourceName] is the human-readable plugin/source name.
  /// Deduplicates by mediaId so re-saving the same artist updates in place.
  Future<int> saveArtist(ArtistSummary artist,
      {required String sourceName}) async {
    final existing = await _findByMediaId(PlaylistTypeDB.artist, artist.id);

    final artistDb = artistSummaryToArtistSummaryDB(artist);
    final row =
        existing ?? PlaylistDB(name: artist.id, type: PlaylistTypeDB.artist);

    row.type = PlaylistTypeDB.artist;
    row.name = artist.id;
    row.subtitle = 'Artist • $sourceName';
    row.thumbnail = artistDb.thumbnail;
    row.description = artist.subtitle;
    row.artists = [artistDb];
    row.album = null;
    row.remotePlaylist = null;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote artist "${artist.name}" (id: $id)', name: 'LibraryDAO');
    return id;
  }

  /// Save (or update) an [AlbumSummary] in the library.
  Future<int> saveAlbum(AlbumSummary album,
      {required String sourceName}) async {
    final existing = await _findByMediaId(PlaylistTypeDB.album, album.id);

    final albumDb = albumSummaryToAlbumSummaryDB(album);
    final row =
        existing ?? PlaylistDB(name: album.id, type: PlaylistTypeDB.album);

    row.type = PlaylistTypeDB.album;
    row.name = album.id;
    row.subtitle = 'Album • $sourceName';
    row.thumbnail = albumDb.thumbnail;
    row.description = album.subtitle;
    row.artists = albumDb.artists;
    row.album = albumDb;
    row.remotePlaylist = null;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote album "${album.title}" (id: $id)', name: 'LibraryDAO');
    return id;
  }

  /// Save (or update) a remote [PlaylistSummary] in the library.
  Future<int> saveRemotePlaylist(PlaylistSummary playlist,
      {required String sourceName}) async {
    final existing =
        await _findByMediaId(PlaylistTypeDB.remotePlaylist, playlist.id);

    final row = existing ??
        PlaylistDB(name: playlist.id, type: PlaylistTypeDB.remotePlaylist);

    final owner = playlist.owner;
    final ownerArtists = (owner != null && owner.trim().isNotEmpty)
        ? [ArtistSummaryDB()..name = owner.trim()]
        : null;

    final remoteSummary = RemotePlaylistSummaryDB(
      title: playlist.title,
      mediaId: playlist.id,
      url: playlist.url,
      thumbnail: playlist.thumbnail.url.isNotEmpty
          ? artworkToArtworkDB(playlist.thumbnail)
          : null,
      artists: ownerArtists,
      subtitle: playlist.owner,
    );

    row.type = PlaylistTypeDB.remotePlaylist;
    row.name = playlist.id;
    row.subtitle = 'Playlist • $sourceName';
    row.thumbnail = remoteSummary.thumbnail;
    row.description = playlist.owner;
    row.artists = ownerArtists;
    row.album = null;
    row.remotePlaylist = remoteSummary;
    row.updatedAt = DateTime.now();

    final isar = await _db;
    final id = await isar.writeTxn(() => isar.playlistDBs.put(row));
    log('Saved remote playlist "${playlist.title}" (id: $id)',
        name: 'LibraryDAO');
    return id;
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Return all saved playlists of a given [type], newest first.
  Future<List<PlaylistDB>> _getSavedByType(PlaylistTypeDB type) async {
    final isar = await _db;
    return isar.playlistDBs
        .filter()
        .typeIndexEqualTo(type.index)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Return saved artists as [ArtistSummary] domain objects.
  Future<List<ArtistSummary>> getSavedArtists() async {
    final rows = await _getSavedByType(PlaylistTypeDB.artist);
    return rows.map(playlistDBToArtistSummary).toList();
  }

  /// Return saved albums as [AlbumSummary] domain objects.
  Future<List<AlbumSummary>> getSavedAlbums() async {
    final rows = await _getSavedByType(PlaylistTypeDB.album);
    return rows.map(playlistDBToAlbumSummary).toList();
  }

  /// Return saved remote playlists as [PlaylistSummary] domain objects.
  Future<List<PlaylistSummary>> getSavedRemotePlaylists() async {
    final rows = await _getSavedByType(PlaylistTypeDB.remotePlaylist);
    return rows.map(playlistDBToPlaylistSummary).toList();
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  /// Remove a saved entry by its [mediaId] and [type].
  Future<bool> removeByMediaId(String mediaId, PlaylistTypeDB type) async {
    final existing = await _findByMediaId(type, mediaId);
    if (existing == null) return false;
    final isar = await _db;
    await isar.writeTxn(() => isar.playlistDBs.delete(existing.id));
    log('Removed saved ${type.name}: $mediaId', name: 'LibraryDAO');
    return true;
  }

  /// Remove a saved entry by its Isar [id].
  Future<void> removeSavedById(int id) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playlistDBs.delete(id));
  }

  // ── Existence check ────────────────────────────────────────────────────────

  /// Check whether a collection with [mediaId] and [type] is saved.
  Future<bool> isSavedByMediaId(String mediaId, PlaylistTypeDB type) async {
    final existing = await _findByMediaId(type, mediaId);
    return existing != null;
  }

  /// Domain-level check using [PlaylistType] (for cubit consumption).
  Future<bool> isSaved(String mediaId, PlaylistType type) async {
    final dbType = playlistTypeToPlaylistTypeDB(type);
    return isSavedByMediaId(mediaId, dbType);
  }

  // ── Resolve navigation target ─────────────────────────────────────────────

  /// Look up a saved collection by its storage key and convert to a domain [Playlist].
  ///
  /// Returns null if not found. The returned [Playlist] carries embedded
  /// artist/album/remotePlaylist domain objects that the cubit can use to
  /// build navigation targets.
  Future<Playlist?> resolveByStorageKey(String storageKey) async {
    final isar = await _db;
    final db =
        await isar.playlistDBs.filter().nameEqualTo(storageKey).findFirst();
    if (db == null) return null;
    return playlistDBToPlaylist(db);
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  /// Stream that emits whenever any saved collection changes.
  Future<Stream<void>> watchSavedCollections() async {
    final isar = await _db;
    return isar.playlistDBs
        .filter()
        .not()
        .typeIndexEqualTo(PlaylistTypeDB.userPlaylist.index)
        .watchLazy(fireImmediately: true);
  }
}
