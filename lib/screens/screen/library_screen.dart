import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
          builder: (context, state) {
            // Handle loading and error states first for a clean UI
            if (state is LibraryItemsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LibraryItemsError) {
              return Center(
                child: SignBoardWidget(
                  message: state.message,
                  icon: Icons.error_outline_rounded,
                ),
              );
            }

            // Handle the loaded but completely empty state
            if (state.playlists.isEmpty &&
                state.artists.isEmpty &&
                state.albums.isEmpty &&
                state.playlistsOnl.isEmpty) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  customDiscoverBar(context),
                  const SliverFillRemaining(
                    // Use SliverFillRemaining to center content
                    child: Center(
                      child: SignBoardWidget(
                        message:
                            "Your library is feeling lonely. Add some tunes to brighten it up!",
                        icon: MingCute.playlist_fill,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Main UI when data is loaded and not empty
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                customDiscoverBar(context),
                if (state.playlists.isNotEmpty)
                  _ListOfPlaylists(playlists: state.playlists),
                if (state.artists.isNotEmpty)
                  _buildArtistList(context, state.artists),
                if (state.albums.isNotEmpty)
                  _buildAlbumList(context, state.albums),
                if (state.playlistsOnl.isNotEmpty)
                  _buildOnlinePlaylistList(context, state.playlistsOnl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArtistList(BuildContext context, List<ArtistModel> artists) {
    return SliverList.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return SizedBox(
          height: 80,
          child: LibItemCard(
            title: artist.name,
            coverArt: artist.imageUrl,
            subtitle:
                'Artist - ${artist.source == "ytm" ? SourceEngine.eng_YTM.value : (artist.source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
            type: LibItemTypes.artist,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArtistView(artist: artist)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAlbumList(BuildContext context, List<AlbumModel> albums) {
    return SliverList.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return SizedBox(
          height: 80,
          child: LibItemCard(
            title: album.name,
            coverArt: album.imageURL,
            subtitle:
                'Album - ${album.source == "ytm" ? SourceEngine.eng_YTM.value : (album.source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
            type: LibItemTypes.album,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlbumView(album: album)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOnlinePlaylistList(
      BuildContext context, List<PlaylistOnlModel> playlists) {
    return SliverList.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return SizedBox(
          height: 80,
          child: LibItemCard(
            title: playlist.name,
            coverArt: playlist.imageURL,
            subtitle:
                'Playlist - ${playlist.source == "ytm" ? SourceEngine.eng_YTM.value : (playlist.source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
            type: LibItemTypes.onlPlaylist,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnlPlaylistView(
                    playlist: playlist,
                    sourceEngine: playlist.source == "ytm"
                        ? SourceEngine.eng_YTM
                        : (playlist.source == 'saavn'
                            ? SourceEngine.eng_JIS
                            : SourceEngine.eng_YTV),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false, // Set to false if you don't want it to stick at the top
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        children: [
          Text(
            "Library",
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(
                fontSize: 34,
                color: Default_Theme.primaryColor1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => createPlaylistBottomSheet(context),
            icon: const Icon(MingCute.add_fill,
                size: 25, color: Default_Theme.primaryColor1),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () =>
                context.pushNamed(GlobalStrConsts.ImportMediaFromPlatforms),
            icon: const Icon(FontAwesome.file_import_solid,
                size: 22, color: Default_Theme.primaryColor1),
          ),
        ],
      ),
    );
  }
}

class _ListOfPlaylists extends StatelessWidget {
  final List<PlaylistItemProperties> playlists;
  const _ListOfPlaylists({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        // Filter out specific playlists directly in the builder
        if (playlist.playlistName == BloomeeDBService.recentlyPlayedPlaylist ||
            playlist.playlistName == BloomeeDBService.downloadPlaylist) {
          return const SizedBox.shrink();
        }

        return LibItemCard(
          onTap: () {
            context
                .read<CurrentPlaylistCubit>()
                .setupPlaylist(playlist.playlistName);
            context.pushNamed(GlobalStrConsts.playlistView);
          },
          onSecondaryTap: () =>
              showPlaylistOptsExtSheet(context, playlist.playlistName),
          onLongPress: () {
            showPlaylistOptsExtSheet(context, playlist.playlistName);
          },
          title: playlist.playlistName,
          coverArt: playlist.coverImgUrl.toString(),
          subtitle: playlist.subTitle ?? "Unknown",
        );
      },
    );
  }
}
