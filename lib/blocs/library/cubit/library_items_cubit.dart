// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/services/db/dao/library_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/db/mappers/media_item_mapper.dart';
import 'package:Bloomee/services/db/mappers/playlist_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

/// Manages the user's library: local playlists and saved remote collections.
///
/// Combines data from [PlaylistDAO] (user playlists) and [LibraryDAO] (saved
/// remote collections). Emits view-model state using only domain types — no
/// DB types leak into the state layer.
class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  StreamSubscription? _playlistWatcher;
  final PlaylistDAO _playlistDao;
  final LibraryDAO _libraryDao;

  LibraryItemsCubit({
    required PlaylistDAO playlistDao,
    required LibraryDAO libraryDao,
  })  : _playlistDao = playlistDao,
        _libraryDao = libraryDao,
        super(LibraryItemsLoading()) {
    _initialize();
  }

  @override
  Future<void> close() {
    _playlistWatcher?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    await _playlistDao.purgeBrokenPlaylistEntries();
    await _fetchPlaylists();
    _setupWatchers();
  }

  Future<void> _setupWatchers() async {
    _playlistWatcher = (await _playlistDao.watchAllPlaylists()).listen((_) {
      _fetchPlaylists();
    });
  }

  /// Fetch all playlists (user + remote collections) and emit as domain items.
  Future<void> _fetchPlaylists() async {
    try {
      final allPlaylists = await _playlistDao.getAllPlaylists();
      final items = await _toItemProperties(allPlaylists);
      emit(state.copyWith(playlists: items));
    } catch (e) {
      log('Error fetching playlists: $e', name: 'LibraryItemsCubit');
      emit(const LibraryItemsError('Failed to load your playlists.'));
    }
  }

  /// Convert DB rows to view-model items using only domain types.
  Future<List<PlaylistItemProperties>> _toItemProperties(
      List<PlaylistDB> dbs) async {
    final items = <PlaylistItemProperties>[];

    for (final p in dbs) {
      // Map using the playlist mapper to get a domain Playlist.
      final domainPlaylist = playlistDBToPlaylist(p);

      String? subtitle;
      if (domainPlaylist.subtitle != null &&
          domainPlaylist.subtitle!.trim().isNotEmpty) {
        subtitle = domainPlaylist.subtitle!.trim();
      } else if (domainPlaylist.type == PlaylistType.userPlaylist) {
        final trackCount = (await _playlistDao.getPlaylistTracks(p.id)).length;
        subtitle = '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}';
      }

      final coverUrl = await _resolveCoverUrl(p);

      items.add(
        PlaylistItemProperties(
          playlistName: domainPlaylist.title,
          subTitle: subtitle,
          coverImgUrl: coverUrl,
          type: domainPlaylist.type,
        ),
      );
    }

    return items;
  }

  /// Resolve a cover image URL: direct thumbnail for remote, first track for user.
  Future<String?> _resolveCoverUrl(PlaylistDB playlist) async {
    // Try direct thumbnail first (works for all types).
    final thumb = playlist.thumbnail;
    if (thumb != null && thumb.url.isNotEmpty) {
      return thumb.url;
    }

    // For artists, try embedded artist thumbnail.
    if (playlist.type == PlaylistTypeDB.artist &&
        playlist.artists != null &&
        playlist.artists!.isNotEmpty) {
      final artistThumb = playlist.artists!.first.thumbnail;
      if (artistThumb != null && artistThumb.url.isNotEmpty) {
        return artistThumb.url;
      }
    }

    // For user playlists, use first track's artwork.
    if (playlist.type == PlaylistTypeDB.userPlaylist) {
      final tracks = await _playlistDao.getPlaylistTracks(playlist.id);
      if (tracks.isNotEmpty) {
        final trackUrl = tracks.first.thumbnail?.url;
        if (trackUrl != null && trackUrl.isNotEmpty) return trackUrl;
      }
    }

    return null;
  }

  // ── Playlist CRUD ──────────────────────────────────────────────────────────

  /// Create a new empty playlist.
  Future<void> createPlaylist(String name) async {
    await _playlistDao.createPlaylist(name);
    SnackbarService.showMessage("Playlist '$name' created!");
  }

  /// Delete a playlist by its Isar id.
  void removePlaylistById(int playlistId) {
    _playlistDao.deletePlaylist(playlistId);
    SnackbarService.showMessage('Playlist removed');
  }

  /// Delete a playlist by name.
  void removePlaylistByName(String name) {
    if (name.isNotEmpty && name != 'Null') {
      _playlistDao.deletePlaylistByName(name);
      SnackbarService.showMessage('Playlist "$name" removed');
    }
  }

  // ── Track management ───────────────────────────────────────────────────────

  /// Add a [Track] to a named playlist.
  Future<void> addToPlaylist(Track track, String playlistName,
      {bool showSnackbar = true}) async {
    if (playlistName == 'Null' || playlistName.isEmpty) return;
    try {
      await _playlistDao.addTrackToPlaylistByName(playlistName, track);
      if (showSnackbar) {
        SnackbarService.showMessage('${track.title} added to $playlistName');
      }
    } catch (e) {
      log('Failed to add "${track.title}" to "$playlistName": $e',
          name: 'LibraryItemsCubit');
      if (showSnackbar) {
        SnackbarService.showMessage(
            'Failed to add to playlist: ${e.toString().split('\n').first}');
      }
    }
  }

  /// Remove a [Track] from a named playlist.
  Future<void> removeFromPlaylist(Track track, String playlistName,
      {bool showSnackbar = true}) async {
    if (playlistName == 'Null' || playlistName.isEmpty) return;
    final playlist = await _playlistDao.getPlaylistByName(playlistName);
    if (playlist == null) return;
    await _playlistDao.removeTrackFromPlaylist(playlist.id, track.id);
    if (showSnackbar) {
      SnackbarService.showMessage('${track.title} removed from $playlistName');
    }
  }

  /// Get all tracks in a named playlist.
  Future<List<Track>?> getPlaylistTracks(String playlistName) async {
    try {
      final playlist = await _playlistDao.getPlaylistByName(playlistName);
      if (playlist == null) return null;
      final trackDBs = await _playlistDao.getPlaylistTracks(playlist.id);
      return trackDBs.map(trackDBToTrack).toList();
    } catch (e) {
      log('Error getting playlist: $e', name: 'LibraryItemsCubit');
      return null;
    }
  }

  // ── Like helpers ───────────────────────────────────────────────────────────

  /// Check if a track is in the "Liked" playlist.
  Future<bool> isTrackLiked(Track track) async {
    return _playlistDao.isTrackLiked(track.id);
  }

  /// Like or unlike a track.
  Future<void> setTrackLiked(Track track, bool liked) async {
    await _playlistDao.setTrackLiked(track, liked);
  }

  /// Get all playlist names containing a given track.
  Future<Set<String>> getPlaylistsContainingTrack(String mediaId) async {
    final names = await _playlistDao.getPlaylistsContainingTrack(mediaId);
    return names.toSet();
  }

  /// Load a full [Playlist] domain model by name.
  Future<Playlist?> getPlaylistByName(String name) async {
    final playlistDB = await _playlistDao.getPlaylistByName(name);
    if (playlistDB == null) return null;
    return _playlistDao.loadPlaylist(name);
  }

  // ── Remote collection save (delegates to LibraryDAO) ───────────────────────

  Future<void> saveRemoteArtist(
      {required ArtistSummary artist,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveArtist(artist, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage('Artist "${artist.name}" saved to library');
    }
  }

  Future<void> saveRemoteAlbum(
      {required AlbumSummary album,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveAlbum(album, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage('Album "${album.title}" saved to library');
    }
  }

  Future<void> saveRemotePlaylist(
      {required PlaylistSummary playlist,
      required String sourceName,
      bool showSnackbar = true}) async {
    await _libraryDao.saveRemotePlaylist(playlist, sourceName: sourceName);
    if (showSnackbar) {
      SnackbarService.showMessage(
          'Playlist "${playlist.title}" saved to library');
    }
  }

  /// Check if a remote collection is already saved (by mediaId).
  Future<bool> isRemoteSaved(String mediaId, PlaylistType type) {
    return _libraryDao.isSaved(mediaId, type);
  }

  /// Remove a saved remote collection by mediaId.
  Future<void> removeRemoteSaved(String mediaId, PlaylistType type) async {
    final dbType = playlistTypeToPlaylistTypeDB(type);
    await _libraryDao.removeByMediaId(mediaId, dbType);
    SnackbarService.showMessage('Removed from library');
  }

  // ── Navigation target resolution ──────────────────────────────────────────

  /// Resolve a library item by name into a domain [Playlist] for navigation.
  ///
  /// The returned [Playlist] carries embedded artist/album/remotePlaylist
  /// domain objects. Returns null if not found.
  Future<Playlist?> resolveLibraryItem(String name) {
    return _libraryDao.resolveByName(name);
  }

  // ── Search helper for LibrarySearchCubit ──────────────────────────────────

  /// Search tracks by query, returning domain [Track] objects.
  ///
  /// This is a callback-compatible function signature that can be passed
  /// to [LibrarySearchCubit] so it doesn't need to import DAOs directly.
  Future<List<Track>> searchTracks(String query) async {
    final results = await _playlistDao.searchLibrary(query);
    return results.map((r) => trackDBToTrack(r.$1)).toList();
  }
}
