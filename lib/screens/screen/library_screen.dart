import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/library/search_cubit/library_search_cubit.dart';
import 'package:Bloomee/core/models/library_search_result.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibrarySearchCubit(
        searchTracks: context.read<LibraryItemsCubit>().searchTracks,
      ),
      child: const _LibraryScreenView(),
    );
  }
}

class _LibraryScreenView extends StatefulWidget {
  const _LibraryScreenView();

  @override
  State<_LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends State<_LibraryScreenView> {
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;

    final itemsState = context.read<LibraryItemsCubit>().state;
    context.read<LibrarySearchCubit>().search(query, itemsState);
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    context.read<LibrarySearchCubit>().clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  /// Dismiss keyboard when interacting with search results
  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
          builder: (context, itemsState) {
            if (itemsState is LibraryItemsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (itemsState is LibraryItemsError) {
              return Center(
                child: SignBoardWidget(
                  message: itemsState.message,
                  icon: Icons.error_outline_rounded,
                ),
              );
            }

            if (itemsState.playlists.isEmpty) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  customDiscoverBar(context),
                  const SliverFillRemaining(
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

            return BlocBuilder<LibrarySearchCubit, LibrarySearchState>(
              builder: (context, searchState) {
                final isSearching = searchState is LibrarySearchSuccess;
                final isLoading = searchState is LibrarySearchLoading;

                final filteredPlaylists = isSearching
                    ? searchState.filteredPlaylists
                    : itemsState.playlists;
                final filteredSongs = isSearching
                    ? searchState.songResults
                    : <SongSearchResult>[];

                final hasResults =
                    filteredPlaylists.isNotEmpty || filteredSongs.isNotEmpty;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    customDiscoverBar(context),
                    if (_isSearching)
                      SliverToBoxAdapter(
                        child: _buildSearchBar(),
                      ),
                    if (isLoading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Default_Theme.accentColor1.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isSearching && !hasResults && !isLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: SignBoardWidget(
                            message: "No matches found",
                            icon: MingCute.search_line,
                          ),
                        ),
                      ),
                    if (hasResults) ...[
                      if (filteredSongs.isNotEmpty)
                        _buildSongSearchResults(context, filteredSongs),
                      if (filteredPlaylists.isNotEmpty)
                        _ListOfPlaylists(playlists: filteredPlaylists),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Default_Theme.primaryColor1.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: Default_Theme.secondoryTextStyle.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 15,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'Search library...',
            hintStyle: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withOpacity(0.4),
                fontSize: 15,
              ),
            ),
            prefixIcon: Icon(
              MingCute.search_line,
              color: Default_Theme.primaryColor1.withOpacity(0.5),
              size: 20,
            ),
            suffixIcon: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: query.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : IconButton(
                          key: const ValueKey('clear'),
                          icon: Icon(
                            MingCute.close_fill,
                            color: Default_Theme.primaryColor1.withOpacity(0.5),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSongSearchResults(
      BuildContext context, List<SongSearchResult> songs) {
    return SliverList.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final result = songs[index];
        return AnimatedListItem(
          key: ValueKey('song_${result.song.id}_${result.playlistName}'),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 0),
            child: SongCardWidget(
              song: result.song,
              showOptions: true,
              subtitleOverride: 'in ${result.playlistName}',
              onTap: () async {
                _dismissKeyboard();
                final playlist = await context
                    .read<LibraryItemsCubit>()
                    .getPlaylistByName(result.playlistName);
                if (playlist != null && context.mounted) {
                  final songIdx =
                      playlist.tracks.indexWhere((s) => s.id == result.song.id);
                  context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                        playlist,
                        idx: songIdx >= 0 ? songIdx : 0,
                        doPlay: true,
                      );
                }
              },
              onOptionsTap: () {
                showMoreBottomSheet(context, result.song);
              },
            ),
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
            onPressed: () {
              if (_isSearching) {
                _closeSearch();
              } else {
                _openSearch();
              }
            },
            icon: Icon(
              _isSearching ? MingCute.close_fill : MingCute.search_line,
              size: 24,
              color: _isSearching
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor1,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => createPlaylistBottomSheet(context),
            icon: const Icon(MingCute.add_fill,
                size: 25, color: Default_Theme.primaryColor1),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            onPressed: () =>
                context.pushNamed(RoutePaths.importMediaFromPlatforms),
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

  LibItemTypes _toCardType(PlaylistType type) {
    switch (type) {
      case PlaylistType.artist:
        return LibItemTypes.artist;
      case PlaylistType.album:
        return LibItemTypes.album;
      case PlaylistType.remotePlaylist:
        return LibItemTypes.onlPlaylist;
      case PlaylistType.userPlaylist:
        return LibItemTypes.userPlaylist;
    }
  }

  Future<void> _openLibraryItem(
      BuildContext context, PlaylistItemProperties item) async {
    if (item.type == PlaylistType.userPlaylist) {
      context.read<CurrentPlaylistCubit>().setupPlaylist(item.playlistName);
      context.pushNamed(RoutePaths.playlistView);
      return;
    }

    // For remote collections, resolve via the cubit (domain-level, no DB types).
    final playlist = await context
        .read<LibraryItemsCubit>()
        .resolveLibraryItem(item.playlistName);
    if (!context.mounted || playlist == null) return;

    switch (playlist.type) {
      case PlaylistType.artist:
        if (playlist.artists == null || playlist.artists!.isEmpty) return;
        final artist = playlist.artists!.first;
        final pluginId = pluginIdOf(artist.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistView(artist: artist, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.album:
        if (playlist.album == null) return;
        final album = playlist.album!;
        final pluginId = pluginIdOf(album.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumView(album: album, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.remotePlaylist:
        if (playlist.remotePlaylist == null) return;
        final remote = playlist.remotePlaylist!;
        final pluginId = pluginIdOf(remote.id);
        if (pluginId == null || pluginId.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OnlPlaylistView(playlist: remote, pluginId: pluginId),
          ),
        );
        return;
      case PlaylistType.userPlaylist:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        // Filter out specific playlists directly in the builder
        if (playlist.playlistName == SettingKeys.recentlyPlayedPlaylist ||
            playlist.playlistName == SettingKeys.downloadPlaylist) {
          return const SizedBox.shrink();
        }

        return AnimatedListItem(
          index: index,
          child: LibItemCard(
            onTap: () => _openLibraryItem(context, playlist),
            onSecondaryTap: playlist.type == PlaylistType.userPlaylist
                ? () => showPlaylistOptsExtSheet(context, playlist.playlistName)
                : null,
            onLongPress: playlist.type == PlaylistType.userPlaylist
                ? () => showPlaylistOptsExtSheet(context, playlist.playlistName)
                : null,
            title: playlist.playlistName,
            coverArt: playlist.coverImgUrl ?? '',
            subtitle: playlist.subTitle ?? '',
            type: _toCardType(playlist.type),
          ),
        );
      },
    );
  }
}
