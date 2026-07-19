import 'dart:developer';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/widgets/downloading_item.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/screens/screen/offline_views/offline_detail_screens.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:go_router/go_router.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isSearch = false;
  final TextEditingController _searchController = TextEditingController();
  List<Track> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    final downloaderState = context.read<DownloaderCubit>().state;
    _filteredSongs = downloaderState.downloaded;
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSongs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs() {
    final downloaderState = context.read<DownloaderCubit>().state;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs = downloaderState.downloaded
          .where((song) =>
              "${song.title.toLowerCase()} ${song.artists.map((a) => a.name).join(', ').toLowerCase()} ${song.album?.title.toLowerCase() ?? ''}"
                  .contains(query))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (!_isSearch) {
        _searchController.clear();
        final downloaderState = context.read<DownloaderCubit>().state;
        _filteredSongs = downloaderState.downloaded;
      }
    });
  }

  Map<String, List<Track>> _groupSongsByArtist(List<Track> tracks) {
    final Map<String, List<Track>> groups = {};
    for (final track in tracks) {
      if (track.artists.isEmpty) {
        groups.putIfAbsent('Unknown Artist', () => []).add(track);
      } else {
        for (final artist in track.artists) {
          groups.putIfAbsent(artist.name, () => []).add(track);
        }
      }
    }
    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, List<Track>> _groupSongsByAlbum(List<Track> tracks) {
    final Map<String, List<Track>> groups = {};
    for (final track in tracks) {
      final albumName = track.album?.title ?? 'Unknown Album';
      groups.putIfAbsent(albumName, () => []).add(track);
    }
    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Default_Theme.themeColor,
          body: BlocBuilder<DownloaderCubit, DownloaderState>(
            builder: (context, state) {
              if (_searchController.text.isEmpty) {
                _filteredSongs = state.downloaded;
              }

              final artistGroups = _groupSongsByArtist(_filteredSongs);
              final albumGroups = _groupSongsByAlbum(_filteredSongs);

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    customDiscoverSliverBar(context, l10n),
                  ];
                },
                body: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSongsTab(context, state, l10n),
                    _buildArtistsTab(context, artistGroups, l10n),
                    _buildAlbumsTab(context, albumGroups, l10n),
                    _buildPlaylistsTab(context, l10n),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context, DownloaderState state, AppLocalizations l10n) {
    if (state.downloads.isEmpty && state.downloaded.isEmpty) {
      return Center(
        child: SignBoardWidget(
          message: l10n.offlineNoDownloads,
          icon: FontAwesome.download_solid,
        ),
      );
    }
    return CustomScrollView(
      key: const PageStorageKey('offline-songs-tab'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (_filteredSongs.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredSongs.length} songs',
                    style: TextStyle(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  _ActionChipButton(
                    icon: MingCute.shuffle_line,
                    label: 'Shuffle',
                    onTap: () {
                      context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                            Playlist(tracks: _filteredSongs, title: "Offline Songs"),
                            doPlay: true,
                            shuffling: true,
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionChipButton(
                    icon: MingCute.play_fill,
                    label: 'Play All',
                    onTap: () {
                      context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                            Playlist(tracks: _filteredSongs, title: "Offline Songs"),
                            doPlay: true,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ...state.downloads.map((download) => DownloadingCardWidget(downloadProgress: download)),
              ..._filteredSongs.map((song) => SongCardWidget(
                    song: song,
                    showOptions: true,
                    delDownBtn: true,
                    onTap: () {
                      final selectedIndex = state.downloaded.indexWhere((item) => item.id == song.id);
                      if (selectedIndex < 0) {
                        SnackbarService.showMessage(l10n.offlineOpenFailed);
                        return;
                      }
                      context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                            Playlist(tracks: state.downloaded, title: "Offline"),
                            idx: selectedIndex,
                            doPlay: true,
                          );
                    },
                    onOptionsTap: () {
                      showMoreBottomSheet(context, song, showDelete: false);
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtistsTab(BuildContext context, Map<String, List<Track>> groups, AppLocalizations l10n) {
    if (groups.isEmpty) {
      return Center(
        child: SignBoardWidget(
          message: l10n.emptyNoResults,
          icon: MingCute.user_3_line,
        ),
      );
    }
    return ListView.builder(
      key: const PageStorageKey('offline-artists-tab'),
      physics: const BouncingScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final artistName = groups.keys.elementAt(index);
        final artistSongs = groups[artistName]!;
        final firstSong = artistSongs.first;
        final coverUrl = firstSong.thumbnail.urlHigh ?? firstSong.thumbnail.url;

        return LibItemCard(
          title: artistName,
          coverArt: coverUrl,
          subtitle: '${artistSongs.length} songs offline',
          type: LibItemTypes.artist,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfflineArtistDetailScreen(
                  artistName: artistName,
                  songs: artistSongs,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab(BuildContext context, Map<String, List<Track>> groups, AppLocalizations l10n) {
    if (groups.isEmpty) {
      return Center(
        child: SignBoardWidget(
          message: l10n.emptyNoResults,
          icon: MingCute.album_line,
        ),
      );
    }
    return ListView.builder(
      key: const PageStorageKey('offline-albums-tab'),
      physics: const BouncingScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final albumName = groups.keys.elementAt(index);
        final albumSongs = groups[albumName]!;
        final firstSong = albumSongs.first;
        final coverUrl = firstSong.thumbnail.urlHigh ?? firstSong.thumbnail.url;
        final artistName = firstSong.artists.isNotEmpty ? firstSong.artists.first.name : 'Unknown Artist';

        return LibItemCard(
          title: albumName,
          coverArt: coverUrl,
          subtitle: 'By $artistName • ${albumSongs.length} songs',
          type: LibItemTypes.album,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfflineAlbumDetailScreen(
                  albumName: albumName,
                  songs: albumSongs,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
      builder: (context, libraryState) {
        final playlists = libraryState.playlists
            .where((p) => p.type == PlaylistType.userPlaylist)
            .toList();

        return CustomScrollView(
          key: const PageStorageKey('offline-playlists-tab'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${playlists.length} playlists',
                      style: TextStyle(
                        color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    _ActionChipButton(
                      icon: MingCute.add_fill,
                      label: 'Create Playlist',
                      onTap: () => createPlaylistDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            if (playlists.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SignBoardWidget(
                    message: "No playlists found",
                    icon: MingCute.playlist_line,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final playlist = playlists[index];
                    return LibItemCard(
                      title: playlist.playlistName,
                      coverArt: playlist.coverImgUrl ?? '',
                      subtitle: playlist.subTitle ?? '',
                      type: LibItemTypes.userPlaylist,
                      showMenuButton: true,
                      onTap: () {
                        context.pushNamed(
                          RoutePaths.playlistView,
                          extra: playlist.storageKey,
                        );
                      },
                      onMenuTap: () {
                        showPlaylistOptsExtSheet(
                          context,
                          playlist.playlistName,
                          playlistId: playlist.playlistId,
                          isPinned: playlist.isPinned,
                        );
                      },
                    );
                  },
                  childCount: playlists.length,
                ),
              ),
          ],
        );
      },
    );
  }

  SliverAppBar customDiscoverSliverBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: _isSearch ? _buildSearchField(l10n) : _buildTitle(l10n),
      ),
      actions: [
        if (!_isSearch)
          Tooltip(
            message: l10n.offlineRefreshTooltip,
            child: IconButton(
              icon: const Icon(MingCute.refresh_2_line),
              onPressed: () {
                context.read<DownloaderCubit>().refreshDownloadedSongs();
              },
            ),
          ),
        Tooltip(
          message: _isSearch ? l10n.offlineCloseSearch : l10n.offlineSearchTooltip,
          child: IconButton(
            icon: Icon(
              _isSearch ? Icons.close : Icons.search,
              color: Default_Theme.primaryColor1,
            ),
            onPressed: _toggleSearch,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorColor: Default_Theme.accentColor2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: const [
                Tab(text: 'Songs'),
                Tab(text: 'Artists'),
                Tab(text: 'Albums'),
                Tab(text: 'Playlists'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('title'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.offlineTitle,
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(fontSize: 34, color: Default_Theme.primaryColor1),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('search'),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        cursorColor: Default_Theme.primaryColor1,
        decoration: InputDecoration(
          hintText: l10n.offlineSearchHint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
        ),
        style: Default_Theme.secondoryTextStyle.merge(
          const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Default_Theme.accentColor2.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Default_Theme.accentColor2),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Default_Theme.accentColor2,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
