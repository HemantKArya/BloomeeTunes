import 'package:Bloomee/src/rust/api/plugin/commands.dart';

/// Events for [ContentBloc].
sealed class ContentEvent {
  const ContentEvent();
}

/// Search for media items across the active content resolver plugin.
class SearchContent extends ContentEvent {
  final String query;
  final ContentSearchFilter filter;
  final String? pageToken;

  const SearchContent({
    required this.query,
    this.filter = ContentSearchFilter.all,
    this.pageToken,
  });
}

/// Load the next page of the current search results.
class LoadMoreSearchContent extends ContentEvent {
  final String pageToken;

  const LoadMoreSearchContent({required this.pageToken});
}

/// Set the active content resolver plugin.
class SetActiveContentPlugin extends ContentEvent {
  final String pluginId;
  const SetActiveContentPlugin({required this.pluginId});
}

/// Load album details.
class LoadAlbumDetails extends ContentEvent {
  final String pluginId;
  final String albumId;
  const LoadAlbumDetails({required this.pluginId, required this.albumId});
}

/// Load more album tracks (pagination).
class LoadMoreAlbumTracks extends ContentEvent {
  final String pluginId;
  final String albumId;
  final String pageToken;
  const LoadMoreAlbumTracks({
    required this.pluginId,
    required this.albumId,
    required this.pageToken,
  });
}

/// Load artist details.
class LoadArtistDetails extends ContentEvent {
  final String pluginId;
  final String artistId;
  const LoadArtistDetails({required this.pluginId, required this.artistId});
}

/// Load more artist albums (pagination).
class LoadMoreArtistAlbums extends ContentEvent {
  final String pluginId;
  final String artistId;
  final String pageToken;
  const LoadMoreArtistAlbums({
    required this.pluginId,
    required this.artistId,
    required this.pageToken,
  });
}

/// Load playlist details.
class LoadPlaylistDetails extends ContentEvent {
  final String pluginId;
  final String playlistId;
  const LoadPlaylistDetails({required this.pluginId, required this.playlistId});
}

/// Load more playlist tracks (pagination).
class LoadMorePlaylistTracks extends ContentEvent {
  final String pluginId;
  final String playlistId;
  final String pageToken;
  const LoadMorePlaylistTracks({
    required this.pluginId,
    required this.playlistId,
    required this.pageToken,
  });
}

/// Get stream URL(s) for a track.
class GetStreams extends ContentEvent {
  final String pluginId;
  final String trackId;
  const GetStreams({required this.pluginId, required this.trackId});
}

/// Get home page sections from the active content resolver.
class GetHomeSections extends ContentEvent {
  final String? pluginId;
  const GetHomeSections({this.pluginId});
}

/// Load more items for a home section.
class LoadMoreHomeSectionItems extends ContentEvent {
  final String pluginId;
  final String sectionId;
  final String moreLink;
  const LoadMoreHomeSectionItems({
    required this.pluginId,
    required this.sectionId,
    required this.moreLink,
  });
}

/// Get radio tracks.
class GetRadioTracks extends ContentEvent {
  final String pluginId;
  final String trackId;
  final String? pageToken;
  const GetRadioTracks({
    required this.pluginId,
    required this.trackId,
    this.pageToken,
  });
}

/// Clear the current search results.
class ClearSearch extends ContentEvent {
  const ClearSearch();
}

/// Clear album/artist/playlist detail state.
class ClearDetails extends ContentEvent {
  const ClearDetails();
}

/// Clear home sections and reset active plugin.
class ClearHomeSections extends ContentEvent {
  const ClearHomeSections();
}
