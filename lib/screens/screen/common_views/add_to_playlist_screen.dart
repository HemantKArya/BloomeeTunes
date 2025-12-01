import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

class AddToPlaylistScreen extends StatefulWidget {
  const AddToPlaylistScreen({super.key});

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<Set<String>> _songInPlaylists = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load which playlists contain this song after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongPlaylists();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    _songInPlaylists.dispose();
    super.dispose();
  }

  /// Loads which playlists the current song belongs to
  Future<void> _loadSongPlaylists() async {
    final mediaItem = context.read<AddToPlaylistCubit>().state.mediaItemModel;
    if (mediaItem == mediaItemModelNull) {
      return;
    }

    try {
      final playlistNames =
          await BloomeeDBService.getPlaylistsContainingSong(mediaItem.id);
      _songInPlaylists.value = playlistNames.toSet();
    } catch (e) {
      // If error, just continue with empty set
      _songInPlaylists.value = {};
    }
  }

  void _onSearchChanged() {
    _searchQuery.value = _searchController.text.trim();
  }

  List<PlaylistItemProperties> _filterPlaylists(
    List<PlaylistItemProperties> playlists,
    String query,
  ) {
    // Filter out system playlists first
    final userPlaylists = playlists.where((p) {
      return p.playlistName != "recently_played" &&
          p.playlistName != GlobalStrConsts.downloadPlaylist;
    }).toList();

    if (query.isEmpty) return userPlaylists;

    return userPlaylists.where((element) {
      return element.playlistName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _toggleSongInPlaylist(
    BuildContext context,
    MediaItemModel song,
    PlaylistItemProperties playlist,
    bool isInPlaylist,
  ) {
    final playlistDB = MediaPlaylistDB(playlistName: playlist.playlistName);

    if (isInPlaylist) {
      // Remove from playlist - no snackbar, checkbox animation provides feedback
      context.read<LibraryItemsCubit>().removeFromPlaylist(
            song,
            playlistDB,
            showSnackbar: false,
          );
      _songInPlaylists.value = Set.from(_songInPlaylists.value)
        ..remove(playlist.playlistName);
    } else {
      // Add to playlist - no snackbar, checkbox animation provides feedback
      context.read<LibraryItemsCubit>().addToPlaylist(
            song,
            playlistDB,
            showSnackbar: false,
          );
      _songInPlaylists.value = Set.from(_songInPlaylists.value)
        ..add(playlist.playlistName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Default_Theme.themeColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Default_Theme.primaryColor1,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add to Playlist',
          style: Default_Theme.secondoryTextStyleMedium.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              MingCute.add_circle_line,
              color: Default_Theme.accentColor2,
              size: 26,
            ),
            tooltip: 'Create New Playlist',
            onPressed: () => createPlaylistBottomSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
          builder: (context, addToPlaylistState) {
            final mediaItem = addToPlaylistState.mediaItemModel;

            if (mediaItem == mediaItemModelNull) {
              return const Center(
                child: SignBoardWidget(
                  message: "No song selected",
                  icon: MingCute.music_2_line,
                ),
              );
            }

            return Column(
              children: [
                // Song Info Card (Compact)
                _SongInfoCard(mediaItem: mediaItem),

                // Already Added Playlists Stack
                BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                  builder: (context, libraryState) {
                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: _songInPlaylists,
                      builder: (context, songPlaylists, _) {
                        if (songPlaylists.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final playlists = libraryState.playlists
                            .where((p) =>
                                songPlaylists.contains(p.playlistName) &&
                                p.playlistName != "recently_played" &&
                                p.playlistName !=
                                    GlobalStrConsts.downloadPlaylist)
                            .toList();

                        if (playlists.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _StackedPlaylistAvatars(playlists: playlists),
                        );
                      },
                    );
                  },
                ),

                // Search Bar
                _SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  searchQuery: _searchQuery,
                ),

                // Playlists List
                Expanded(
                  child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                    builder: (context, libraryState) {
                      if (libraryState is LibraryItemsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Default_Theme.accentColor2,
                          ),
                        );
                      }

                      return ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder: (context, query, _) {
                          final filteredPlaylists = _filterPlaylists(
                            libraryState.playlists,
                            query,
                          );

                          if (filteredPlaylists.isEmpty) {
                            return Center(
                              child: SignBoardWidget(
                                message: query.isEmpty
                                    ? "No playlists yet.\nCreate one to get started!"
                                    : "No playlists match your search",
                                icon: query.isEmpty
                                    ? MingCute.playlist_line
                                    : MingCute.search_line,
                              ),
                            );
                          }

                          return ValueListenableBuilder<Set<String>>(
                            valueListenable: _songInPlaylists,
                            builder: (context, songPlaylists, _) {
                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 100,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredPlaylists.length,
                                itemBuilder: (context, index) {
                                  final playlist = filteredPlaylists[index];
                                  final isInPlaylist = songPlaylists
                                      .contains(playlist.playlistName);
                                  return AnimatedListItem(
                                    key: ValueKey(playlist.playlistName),
                                    index: index,
                                    child: _PlaylistTile(
                                      playlist: playlist,
                                      isInPlaylist: isInPlaylist,
                                      onTap: () => _toggleSongInPlaylist(
                                        context,
                                        mediaItem,
                                        playlist,
                                        isInPlaylist,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_to_playlist_fab',
        backgroundColor: Default_Theme.accentColor2,
        elevation: 2,
        onPressed: () => createPlaylistBottomSheet(context),
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: Default_Theme.primaryColor1,
        ),
      ),
    );
  }
}

/// Compact song info card showing the song being added
class _SongInfoCard extends StatelessWidget {
  final MediaItemModel mediaItem;

  const _SongInfoCard({required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: LoadImageCached(
                imageUrl: formatImgURL(
                  mediaItem.artUri.toString(),
                  ImageQuality.low,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mediaItem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mediaItem.artist ?? "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar widget with clear button
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<String> searchQuery;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          style: Default_Theme.secondoryTextStyle.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 15,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'Search playlists...',
            hintStyle: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.35),
                fontSize: 15,
              ),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
              size: 22,
            ),
            suffixIcon: ValueListenableBuilder<String>(
              valueListenable: searchQuery,
              builder: (context, query, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: query.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : IconButton(
                          key: const ValueKey('clear'),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.4),
                            size: 20,
                          ),
                          onPressed: () => controller.clear(),
                        ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual playlist tile - clean, minimal design
class _PlaylistTile extends StatelessWidget {
  final PlaylistItemProperties playlist;
  final bool isInPlaylist;
  final VoidCallback onTap;

  const _PlaylistTile({
    required this.playlist,
    required this.isInPlaylist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.08),
        highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.04),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // Playlist Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: LoadImageCached(
                    imageUrl: formatImgURL(
                      playlist.coverImgUrl ?? '',
                      ImageQuality.low,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playlist.playlistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                        const TextStyle(
                          color: Default_Theme.primaryColor1,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      playlist.subTitle ?? 'Playlist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyle.merge(
                        TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Checkmark indicator (only when in playlist)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isInPlaylist
                    ? Container(
                        key: const ValueKey('checked'),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Default_Theme.accentColor1
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Default_Theme.accentColor1,
                          size: 20,
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('unchecked'),
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.add_rounded,
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.4),
                          size: 24,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackedPlaylistAvatars extends StatefulWidget {
  final List<PlaylistItemProperties> playlists;

  const _StackedPlaylistAvatars({required this.playlists});

  @override
  State<_StackedPlaylistAvatars> createState() =>
      _StackedPlaylistAvatarsState();
}

class _StackedPlaylistAvatarsState extends State<_StackedPlaylistAvatars> {
  @override
  Widget build(BuildContext context) {
    final playlists = widget.playlists;
    final totalCount = playlists.length;
    const double avatarSize = 40.0;
    // Overlap amount when collapsed
    const double collapsedOverlap = 20.0;
    // Horizontal padding from screen edges
    const double horizontalPadding = 32.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - horizontalPadding;

    // Calculate how many avatars can fit when collapsed (stacked)
    // Total width = avatarSize + (n-1) * (avatarSize - collapsedOverlap)
    // availableWidth >= avatarSize + (maxCollapsed - 1) * (avatarSize - collapsedOverlap)
    // Solving for maxCollapsed:
    final int maxVisible =
        ((availableWidth - avatarSize) / (avatarSize - collapsedOverlap) + 1)
            .floor()
            .clamp(1, totalCount);

    final bool hasOverflow = maxVisible < totalCount;
    final int displayCount = hasOverflow ? maxVisible : totalCount;

    // Items to display (last one may be the overflow indicator)
    final List<PlaylistItemProperties> visiblePlaylists =
        hasOverflow ? playlists.sublist(0, displayCount - 1) : playlists;

    final int overflowCount = hasOverflow ? totalCount - (displayCount - 1) : 0;
    final List<PlaylistItemProperties> overflowPlaylists =
        hasOverflow ? playlists.sublist(displayCount - 1) : [];

    // Calculate total width for centering
    final int itemsToRender = hasOverflow ? displayCount : totalCount;
    final double totalWidth =
        avatarSize + (itemsToRender - 1) * (avatarSize - collapsedOverlap);

    final double startX = (screenWidth - totalWidth) / 2;

    return SizedBox(
      height: avatarSize + 20, // Add some padding for tooltip/shadow
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Render overflow indicator first (at the bottom of the stack)
          if (hasOverflow)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              left: startX +
                  (displayCount - 1) * (avatarSize - collapsedOverlap) +
                  8, // Offset slightly to the right for visibility
              top: 10,
              child: Tooltip(
                message:
                    overflowPlaylists.map((p) => p.playlistName).join(', '),
                preferBelow: false,
                verticalOffset: 24,
                triggerMode: TooltipTriggerMode.tap,
                child: _OverflowAvatar(
                  count: overflowCount,
                  size: avatarSize,
                ),
              ),
            ),
          // Render visible playlist avatars in reverse order (last to first)
          // so first item ends up on top of the stack
          ...List.generate(visiblePlaylists.length, (index) {
            // Reverse the index for rendering order
            final reverseIndex = visiblePlaylists.length - 1 - index;
            final playlist = visiblePlaylists[reverseIndex];

            final double itemOffset =
                reverseIndex * (avatarSize - collapsedOverlap);

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              left: startX + itemOffset,
              top: 10,
              child: Tooltip(
                message: playlist.playlistName,
                preferBelow: false,
                verticalOffset: 24,
                triggerMode: TooltipTriggerMode.tap,
                child: _PlaylistAvatar(
                  playlist: playlist,
                  size: avatarSize,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Overflow indicator showing "+N" count
class _OverflowAvatar extends StatelessWidget {
  final int count;
  final double size;

  const _OverflowAvatar({
    required this.count,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Default_Theme.accentColor1.withValues(alpha: 0.15),
        border: Border.all(
          color: Default_Theme.themeColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          ' $count+',
          style: Default_Theme.secondoryTextStyleMedium.merge(
            const TextStyle(
              color: Default_Theme.accentColor1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistAvatar extends StatelessWidget {
  final PlaylistItemProperties playlist;
  final double size;

  const _PlaylistAvatar({
    required this.playlist,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Default_Theme.themeColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: LoadImageCached(
          imageUrl: formatImgURL(
            playlist.coverImgUrl ?? '',
            ImageQuality.low,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
