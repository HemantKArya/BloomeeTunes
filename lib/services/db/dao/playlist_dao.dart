import 'dart:developer';

import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:isar_community/isar.dart';

/// DAO for playlist CRUD and position-based track ordering.
///
/// Ordering strategy: each [PlaylistEntryDB] carries an integer [position].
/// The compound index `(playlistId, position)` lets Isar serve sorted reads
/// without any Dart-side sorting. Gaps in positions are fine — the relative
/// order is all that matters.
///
/// All write operations that mutate order run inside a single [writeTxn] to
/// prevent races.
class PlaylistDAO {
  final Future<Isar> _db;
  final TrackDAO _trackDAO;

  const PlaylistDAO(this._db, this._trackDAO);

  // ── Playlist CRUD ──────────────────────────────────────────────────────────

  /// Create a user playlist by [name].
  ///
  /// Returns the new playlist's Isar id, or null if [name] is empty or a
  /// playlist with that name already exists.
  Future<int?> createPlaylist(
    String name, {
    ArtworkDB? thumbnail,
    String? description,
    String? subtitle,
  }) async {
    if (name.trim().isEmpty) return null;
    final isar = await _db;

    final existing =
        isar.playlistDBs.filter().nameEqualTo(name).findFirstSync();
    if (existing != null) {
      log('Playlist "$name" already exists (id: ${existing.id})',
          name: 'PlaylistDAO');
      return existing.id;
    }

    final playlist = PlaylistDB(
      name: name,
      subtitle: subtitle,
      description: description,
      thumbnail: thumbnail,
      type: PlaylistTypeDB.userPlaylist,
    );
    final id = await isar.writeTxn(() => isar.playlistDBs.put(playlist));
    log('Created playlist "$name" (id: $id)', name: 'PlaylistDAO');
    return id;
  }

  /// Insert or replace any [PlaylistDB] row (upsert by id).
  Future<int> putPlaylist(PlaylistDB playlist) async {
    final isar = await _db;
    playlist.updatedAt = DateTime.now();
    return isar.writeTxn(() => isar.playlistDBs.put(playlist));
  }

  /// Find a playlist by its case-insensitive [name] (unique index).
  Future<PlaylistDB?> getPlaylistByName(String name) async {
    final isar = await _db;
    return isar.playlistDBs.filter().nameEqualTo(name).findFirst();
  }

  /// Find a playlist by Isar internal [id].
  Future<PlaylistDB?> getPlaylistById(int id) async {
    final isar = await _db;
    return isar.playlistDBs.get(id);
  }

  /// Return all playlists, pinned first, then by sort order.
  Future<List<PlaylistDB>> getAllPlaylists() async {
    final isar = await _db;
    final all = await isar.playlistDBs.where().findAll();
    // Pinned playlists first (by sortOrder), then unpinned (by sortOrder).
    all.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return all;
  }

  /// Return playlists filtered by [type].
  Future<List<PlaylistDB>> getPlaylistsByType(PlaylistTypeDB type) async {
    final isar = await _db;
    return isar.playlistDBs
        .filter()
        .typeIndexEqualTo(type.index)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Delete a playlist by id, cascading to all its [PlaylistEntryDB] rows.
  Future<void> deletePlaylist(int playlistId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .deleteAll();
      await isar.playlistDBs.delete(playlistId);
    });
    _trackDAO.purgeOrphanTracks();
    log('Deleted playlist id=$playlistId', name: 'PlaylistDAO');
  }

  /// Delete a playlist by [name].
  Future<void> deletePlaylistByName(String name) async {
    final playlist = await getPlaylistByName(name);
    if (playlist != null) await deletePlaylist(playlist.id);
  }

  /// Update only metadata fields of an existing playlist.
  Future<void> updatePlaylistMeta(
    int playlistId, {
    String? name,
    ArtworkDB? thumbnail,
    String? description,
    String? subtitle,
  }) async {
    final isar = await _db;
    final playlist = await isar.playlistDBs.get(playlistId);
    if (playlist == null) return;
    if (name != null) playlist.name = name;
    if (thumbnail != null) playlist.thumbnail = thumbnail;
    if (description != null) playlist.description = description;
    if (subtitle != null) playlist.subtitle = subtitle;
    playlist.updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.playlistDBs.put(playlist));
  }

  // ── Track management ───────────────────────────────────────────────────────

  /// Append [track] to the end of playlist [playlistId].
  ///
  /// Accepts a domain [Track] model. Upserts it into [TrackDB] first
  /// (deduplication). Returns the new entry id, or null if already present.
  Future<int?> addTrackToPlaylist(int playlistId, Track track) async {
    final isar = await _db;
    final trackId = await _trackDAO.upsertTrack(track);

    return isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) {
        log('addTrackToPlaylist: playlist $playlistId not found',
            name: 'PlaylistDAO');
        return null;
      }

      // Dedup check.
      final existingEntry = await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .and()
          .track((q) => q.idEqualTo(trackId))
          .findFirst();
      if (existingEntry != null) {
        log('Track ${track.id} already in playlist $playlistId',
            name: 'PlaylistDAO');
        return null;
      }

      // Compute next position.
      final maxPosEntry = await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .sortByPositionDesc()
          .findFirst();
      final nextPos = (maxPosEntry?.position ?? -1) + 1;

      final trackObj = await isar.trackDBs.get(trackId);
      if (trackObj == null) {
        log('addTrackToPlaylist: track ${track.id} not found after upsert',
            name: 'PlaylistDAO');
        return null;
      }

      final entry = PlaylistEntryDB(playlistId: playlistId, position: nextPos)
        ..playlist.value = playlist
        ..track.value = trackObj;

      final entryId = await isar.playlistEntryDBs.put(entry);
      await entry.playlist.save();
      await entry.track.save();

      playlist.updatedAt = DateTime.now();
      await isar.playlistDBs.put(playlist);
      return entryId;
    });
  }

  /// Convenience: Add track to playlist by name instead of ID.
  Future<int?> addTrackToPlaylistByName(
      String playlistName, Track track) async {
    final playlist = await getPlaylistByName(playlistName);
    if (playlist == null) {
      log('Playlist "$playlistName" not found', name: 'PlaylistDAO');
      return null;
    }
    return addTrackToPlaylist(playlist.id, track);
  }

  /// Append multiple tracks in a single transaction.
  ///
  /// Accepts domain [Track] models. Deduplicates automatically.
  Future<void> addTracksToPlaylist(int playlistId, List<Track> tracks) async {
    if (tracks.isEmpty) return;
    final isar = await _db;
    final trackIds = await _trackDAO.upsertTracks(tracks);

    await isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) return;

      final maxPosEntry = await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .sortByPositionDesc()
          .findFirst();
      int nextPos = (maxPosEntry?.position ?? -1) + 1;

      final existingEntries = await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .findAll();
      await Future.wait(existingEntries.map((e) => e.track.load()));
      final existingTrackIds =
          existingEntries.map((e) => e.track.value?.id).toSet();

      final newEntries = <PlaylistEntryDB>[];
      for (final trackId in trackIds) {
        if (existingTrackIds.contains(trackId)) continue;
        final trackObj = await isar.trackDBs.get(trackId);
        if (trackObj == null) continue;
        final entry =
            PlaylistEntryDB(playlistId: playlistId, position: nextPos++)
              ..playlist.value = playlist
              ..track.value = trackObj;
        newEntries.add(entry);
      }

      if (newEntries.isEmpty) return;
      await isar.playlistEntryDBs.putAll(newEntries);
      for (final e in newEntries) {
        await e.playlist.save();
        await e.track.save();
      }

      playlist.updatedAt = DateTime.now();
      await isar.playlistDBs.put(playlist);
    });
  }

  /// Replace the full ordered contents of [playlistId] with [tracks].
  Future<void> setPlaylistTracks(int playlistId, List<Track> tracks) async {
    final isar = await _db;
    final seenIds = <String>{};
    final orderedUniqueTracks =
        tracks.where((track) => seenIds.add(track.id)).toList(growable: false);
    final trackIds = await _trackDAO.upsertTracks(orderedUniqueTracks);

    await isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) return;

      final existingEntries = await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .findAll();
      if (existingEntries.isNotEmpty) {
        await isar.playlistEntryDBs
            .deleteAll(existingEntries.map((entry) => entry.id).toList());
      }

      final newEntries = <PlaylistEntryDB>[];
      for (int index = 0; index < trackIds.length; index++) {
        final trackObj = await isar.trackDBs.get(trackIds[index]);
        if (trackObj == null) continue;
        final entry = PlaylistEntryDB(
          playlistId: playlistId,
          position: index,
        )
          ..playlist.value = playlist
          ..track.value = trackObj;
        newEntries.add(entry);
      }

      if (newEntries.isNotEmpty) {
        await isar.playlistEntryDBs.putAll(newEntries);
        for (final entry in newEntries) {
          await entry.playlist.save();
          await entry.track.save();
        }
      }

      playlist.updatedAt = DateTime.now();
      await isar.playlistDBs.put(playlist);
    });
  }

  /// Remove a specific entry by its [entryId].
  Future<void> removeEntry(int entryId) async {
    final isar = await _db;
    final entry = await isar.playlistEntryDBs.get(entryId);
    if (entry == null) return;
    final playlistId = entry.playlistId;
    await entry.track.load();
    final trackMediaId = entry.track.value?.mediaId;

    await isar.writeTxn(() async {
      await isar.playlistEntryDBs.delete(entryId);
      if (playlistId != null) {
        final playlist = await isar.playlistDBs.get(playlistId);
        if (playlist != null) {
          playlist.updatedAt = DateTime.now();
          await isar.playlistDBs.put(playlist);
        }
      }
    });

    if (trackMediaId != null) {
      await _trackDAO.purgeOrphanTrack(trackMediaId);
    }
  }

  /// Remove a track identified by [mediaId] from a playlist.
  Future<void> removeTrackFromPlaylist(int playlistId, String mediaId) async {
    final isar = await _db;
    final track =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (track == null) return;

    final entry = await isar.playlistEntryDBs
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .track((q) => q.idEqualTo(track.id))
        .findFirst();

    if (entry != null) await removeEntry(entry.id);
  }

  // ── Ordered track retrieval ────────────────────────────────────────────────

  /// Return all tracks of [playlistId] in position order.
  Future<List<TrackDB>> getPlaylistTracks(int playlistId) async {
    final isar = await _db;
    final entries = await isar.playlistEntryDBs
        .where()
        .playlistIdEqualToAnyPosition(playlistId)
        .findAll();
    await Future.wait(entries.map((e) => e.track.load()));

    final brokenEntryIds = entries
        .where((e) => e.track.value == null)
        .map((e) => e.id)
        .toList(growable: false);

    if (brokenEntryIds.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.playlistEntryDBs.deleteAll(brokenEntryIds);
      });
      log('Removed ${brokenEntryIds.length} broken playlist entries from playlist $playlistId',
          name: 'PlaylistDAO');
    }

    return entries.map((e) => e.track.value).whereType<TrackDB>().toList();
  }

  /// Remove broken playlist-entry rows (missing track link or playlistId).
  /// Also deletes user playlists with an empty name (no tracks, no identity).
  ///
  /// Returns number of deleted rows.
  Future<int> purgeBrokenPlaylistEntries() async {
    final isar = await _db;
    final entries = await isar.playlistEntryDBs.where().findAll();
    await Future.wait(entries.map((e) => e.track.load()));

    final brokenIds = entries
        .where((e) => e.track.value == null || e.playlistId == null)
        .map((e) => e.id)
        .toList(growable: false);

    int deleted = 0;
    if (brokenIds.isNotEmpty) {
      deleted = await isar.writeTxn(() async {
        return isar.playlistEntryDBs.deleteAll(brokenIds);
      });
      log('Purged $deleted broken playlist entries', name: 'PlaylistDAO');
    }

    // Also remove user playlists with an empty name (cleanliness guard).
    final emptyNamedPlaylists = await isar.playlistDBs
        .filter()
        .nameEqualTo('')
        .typeEqualTo(PlaylistTypeDB.userPlaylist)
        .findAll();
    if (emptyNamedPlaylists.isNotEmpty) {
      final ids = emptyNamedPlaylists.map((p) => p.id).toList();
      // Remove their entries first, then the playlist rows.
      await isar.writeTxn(() async {
        for (final id in ids) {
          await isar.playlistEntryDBs
              .filter()
              .playlistIdEqualTo(id)
              .deleteAll();
          await isar.playlistDBs.delete(id);
        }
      });
      log('Purged ${ids.length} empty-named playlists', name: 'PlaylistDAO');
    }

    return deleted;
  }

  /// Return all entries of [playlistId] in position order (with links loaded).
  Future<List<PlaylistEntryDB>> getPlaylistEntries(int playlistId) async {
    final isar = await _db;
    final entries = await isar.playlistEntryDBs
        .where()
        .playlistIdEqualToAnyPosition(playlistId)
        .findAll();
    await Future.wait(entries.map((e) async {
      await e.track.load();
      await e.playlist.load();
    }));
    return entries;
  }

  // ── Position / ordering ────────────────────────────────────────────────────

  /// Atomically move a track from [oldPosition] to [newPosition].
  ///
  /// Moving down (old < new): entries in ]old..new] shift up by -1.
  /// Moving up   (old > new): entries in [new..old[ shift down by +1.
  Future<void> reorderTrack(
      int playlistId, int oldPosition, int newPosition) async {
    if (oldPosition == newPosition) return;
    final isar = await _db;

    await isar.writeTxn(() async {
      final entries = await isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .findAll();

      final movedEntry = entries.firstWhere(
        (e) => e.position == oldPosition,
        orElse: () => throw StateError(
            'No entry at position $oldPosition in playlist $playlistId'),
      );

      final List<PlaylistEntryDB> toUpdate = [];

      if (oldPosition < newPosition) {
        for (final e in entries) {
          if (e.position > oldPosition && e.position <= newPosition) {
            e.position -= 1;
            toUpdate.add(e);
          }
        }
      } else {
        for (final e in entries) {
          if (e.position >= newPosition && e.position < oldPosition) {
            e.position += 1;
            toUpdate.add(e);
          }
        }
      }

      movedEntry.position = newPosition;
      toUpdate.add(movedEntry);
      await isar.playlistEntryDBs.putAll(toUpdate);

      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist != null) {
        playlist.updatedAt = DateTime.now();
        await isar.playlistDBs.put(playlist);
      }
    });
  }

  /// Re-number positions to contiguous 0..N-1 (defragmentation).
  Future<void> normalizePositions(int playlistId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final entries = await isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .findAll();
      for (int i = 0; i < entries.length; i++) {
        entries[i].position = i;
      }
      await isar.playlistEntryDBs.putAll(entries);
    });
  }

  /// Bulk-set track order. [newOrder] maps new-position → old-position.
  ///
  /// Example: `[2, 0, 1]` means the track originally at position 2
  /// should now be at position 0, etc.
  Future<void> setTrackOrder(int playlistId, List<int> newOrder) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final entries = await isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .sortByPosition()
          .findAll();

      if (entries.length != newOrder.length) return;

      // Index entries by their current position for O(1) lookup.
      final byPos = {for (final e in entries) e.position: e};

      for (int newPos = 0; newPos < newOrder.length; newPos++) {
        byPos[newOrder[newPos]]!.position = newPos;
      }

      await isar.playlistEntryDBs.putAll(entries);

      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist != null) {
        playlist.updatedAt = DateTime.now();
        await isar.playlistDBs.put(playlist);
      }
    });
  }

  // ── Like helpers ───────────────────────────────────────────────────────────

  static const likedPlaylist = 'Liked';

  /// Add or remove [track] from the "Liked" playlist.
  ///
  /// Accepts a domain [Track] model.
  Future<void> setTrackLiked(Track track, bool liked) async {
    final likedId = await ensurePlaylist(likedPlaylist);
    if (liked) {
      await addTrackToPlaylist(likedId, track);
    } else {
      await removeTrackFromPlaylist(likedId, track.id);
    }
  }

  /// Returns true if [mediaId] is in the "Liked" playlist.
  Future<bool> isTrackLiked(String mediaId) async {
    final isar = await _db;
    final liked =
        isar.playlistDBs.filter().nameEqualTo(likedPlaylist).findFirstSync();
    if (liked == null) return false;
    final track =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (track == null) return false;
    final entry = await isar.playlistEntryDBs
        .filter()
        .playlistIdEqualTo(liked.id)
        .and()
        .track((q) => q.idEqualTo(track.id))
        .findFirst();
    return entry != null;
  }

  /// Return the names of all playlists containing [mediaId].
  Future<List<String>> getPlaylistsContainingTrack(String mediaId) async {
    final isar = await _db;
    final track =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (track == null) return [];

    final entries = await isar.playlistEntryDBs
        .filter()
        .track((q) => q.idEqualTo(track.id))
        .findAll();

    final playlistIds =
        entries.map((e) => e.playlistId).whereType<int>().toSet();
    final playlists = await isar.playlistDBs.getAll(playlistIds.toList());
    return playlists.whereType<PlaylistDB>().map((p) => p.name).toList();
  }

  // ── Library search ─────────────────────────────────────────────────────────

  /// Search track titles across all playlists.
  ///
  /// Returns `(TrackDB, playlistName)` pairs, excluding system playlists.
  Future<List<(TrackDB, String)>> searchLibrary(String query) async {
    if (query.trim().isEmpty) return [];
    final isar = await _db;

    final matchingTracks = await isar.trackDBs
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();

    const systemPlaylists = {'recently_played', '_DOWNLOADS'};
    final results = <(TrackDB, String)>[];

    for (final track in matchingTracks) {
      final entries = await isar.playlistEntryDBs
          .filter()
          .track((q) => q.idEqualTo(track.id))
          .findAll();
      for (final entry in entries) {
        await entry.playlist.load();
        final pName = entry.playlist.value?.name;
        if (pName != null && !systemPlaylists.contains(pName)) {
          results.add((track, pName));
          break;
        }
      }
    }
    return results;
  }

  // ── Full domain model loader ───────────────────────────────────────────────

  /// Load a fully hydrated [Playlist] domain model from the database.
  Future<Playlist> loadPlaylist(String name) async {
    final playlistDB = await getPlaylistByName(name);
    if (playlistDB == null) return Playlist(tracks: [], title: name);
    final tracks = await getPlaylistTracks(playlistDB.id);
    final domainPlaylist = playlistDBToPlaylist(playlistDB);
    return domainPlaylist.copyWith(
      tracks: tracks.map((t) => trackDBToTrack(t)).toList(),
    );
  }

  // ── Watchers ──────────────────────────────────────────────────────────────

  Future<Stream<void>> watchAllPlaylists() async {
    final isar = await _db;
    return isar.playlistDBs.watchLazy(fireImmediately: true);
  }

  Future<Stream<void>> watchPlaylistEntries(int playlistId) async {
    final isar = await _db;
    return isar.playlistEntryDBs
        .filter()
        .playlistIdEqualTo(playlistId)
        .watchLazy(fireImmediately: true);
  }

  Future<Stream<PlaylistDB?>> watchPlaylist(int playlistId) async {
    final isar = await _db;
    return isar.playlistDBs.watchObject(playlistId, fireImmediately: true);
  }

  // ── Standard-playlist helpers ─────────────────────────────────────────────

  /// Ensure a named playlist exists; return its id (creating it if needed).
  Future<int> ensurePlaylist(String name,
      {PlaylistTypeDB type = PlaylistTypeDB.userPlaylist}) async {
    final isar = await _db;
    final existing =
        isar.playlistDBs.filter().nameEqualTo(name).findFirstSync();
    if (existing != null) return existing.id;
    final playlist = PlaylistDB(name: name, type: type);
    return isar.writeTxn(() => isar.playlistDBs.put(playlist));
  }

  /// Update (or set) the thumbnail URL for a playlist.
  Future<void> updatePlaylistThumbnail(int playlistId, String thumbUrl) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) return;
      playlist.thumbnail = ArtworkDB()..url = thumbUrl;
      await isar.playlistDBs.put(playlist);
    });
  }
  // ── Library Ordering ─────────────────────────────────────────────────────

  /// Toggle the pinned state of a playlist.
  Future<void> setPinned(int playlistId, bool pinned) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) return;
      playlist.isPinned = pinned;
      await isar.playlistDBs.put(playlist);
    });
  }

  /// Reorder playlists in the library.
  ///
  /// [orderedIds] is the full list of playlist IDs in their new order.
  /// Each playlist's `sortOrder` is set to its index in the list.
  Future<void> reorderPlaylists(List<int> orderedIds) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final playlist = await isar.playlistDBs.get(orderedIds[i]);
        if (playlist == null) continue;
        playlist.sortOrder = i;
        await isar.playlistDBs.put(playlist);
      }
    });
  }
}
