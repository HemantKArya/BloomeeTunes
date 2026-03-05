// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/models/exported.dart';
import 'package:equatable/equatable.dart';
// Re-export mapper function for convenience.
export 'package:Bloomee/services/db/mappers/playlist_mapper.dart'
    show playlistDBToPlaylist;

enum PlaylistType { userPlaylist, album, artist, remotePlaylist }

class Playlist extends Equatable {
  final List<Track> tracks;
  final String title;
  final Artwork? thumbnail;
  final String? permaURL;
  final String? subtitle;
  final String? description;
  final List<ArtistSummary>? artists;
  final AlbumSummary? album;
  final PlaylistSummary? remotePlaylist;
  final PlaylistType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Playlist({
    required this.tracks,
    required this.title,
    this.thumbnail,
    this.permaURL,
    this.artists,
    this.album,
    this.remotePlaylist,
    this.subtitle,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.type = PlaylistType.userPlaylist,
  });

  @override
  List<Object> get props => [
        tracks,
        title,
        thumbnail ?? '',
        permaURL ?? '',
        subtitle ?? '',
        description ?? '',
        artists ?? '',
        album ?? '',
        remotePlaylist ?? '',
        type,
        createdAt ?? '',
        updatedAt ?? '',
      ];

  Playlist copyWith({
    List<Track>? tracks,
    String? title,
    Artwork? thumbnail,
    String? permaURL,
    String? description,
    List<ArtistSummary>? artists,
    AlbumSummary? album,
    PlaylistSummary? remotePlaylist,
    PlaylistType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      tracks: tracks ?? this.tracks,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      permaURL: permaURL ?? this.permaURL,
      description: description ?? this.description,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      remotePlaylist: remotePlaylist ?? this.remotePlaylist,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
