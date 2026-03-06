import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
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

  Future<void> _loadSongPlaylists() async {
    final mediaItem = context.read<AddToPlaylistCubit>().state.track;
    if (isTrackNull(mediaItem)) {
      return;
    }

    try {
      final playlistNames = await context
          .read<LibraryItemsCubit>()
          .getPlaylistsContainingTrack(mediaItem.id);
      _songInPlaylists.value = playlistNames;
    } catch (e) {
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
    final userPlaylists = playlists.where((p) {
      return p.type == PlaylistType.userPlaylist &&
          p.playlistName != "recently_played" &&
          p.playlistName != SettingKeys.downloadPlaylist;
    }).toList();

    if (query.isEmpty) return userPlaylists;

    return userPlaylists.where((element) {
      return element.playlistName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _toggleSongInPlaylist(
    BuildContext context,
    Track song,
    PlaylistItemProperties playlist,
    bool isInPlaylist,
  ) {
    if (isInPlaylist) {
      context.read<LibraryItemsCubit>().removeFromPlaylist(
            song,
            playlist.playlistName,
            showSnackbar: false,
          );
      _songInPlaylists.value = Set.from(_songInPlaylists.value)
        ..remove(playlist.playlistName);
    } else {
      context.read<LibraryItemsCubit>().addToPlaylist(
            song,
            playlist.playlistName,
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
            final mediaItem = addToPlaylistState.track;

            if (isTrackNull(mediaItem)) {
              return const Center(
                child: SignBoardWidget(
                  message: "No song selected",
                  icon: MingCute.music_2_line,
                ),
              );
            }

            return Column(
              children: [
                _SongInfoCard(mediaItem: mediaItem),
                BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                  builder: (context, libraryState) {
                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: _songInPlaylists,
                      builder: (context, songPlaylists, _) {
                        final playlists = libraryState.playlists
                            .where((p) =>
                                songPlaylists.contains(p.playlistName) &&
                                p.playlistName != "recently_played" &&
                                p.playlistName != SettingKeys.downloadPlaylist)
                            .toList();

                        return _AnimatedAvatarSection(playlists: playlists);
                      },
                    );
                  },
                ),
                _SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  searchQuery: _searchQuery,
                ),
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
                              // +1 for the Create New Playlist tile at top
                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 100,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredPlaylists.length + 1,
                                itemBuilder: (context, index) {
                                  // First item: Create New Playlist
                                  if (index == 0) {
                                    return _CreatePlaylistTile(
                                      onTap: () =>
                                          createPlaylistBottomSheet(context),
                                    );
                                  }

                                  final playlist = filteredPlaylists[index - 1];
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
      // FAB removed — Create New Playlist is now inline in the list
    );
  }
}

// ─────────────────────────────────────────────
// Inline Create New Playlist tile
// ─────────────────────────────────────────────
class _CreatePlaylistTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePlaylistTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Default_Theme.accentColor2.withValues(alpha: 0.08),
          highlightColor: Default_Theme.accentColor2.withValues(alpha: 0.04),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Default_Theme.accentColor2.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Default_Theme.accentColor2.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Default_Theme.accentColor2,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Create New Playlist',
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    const TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Everything below is UNCHANGED from before
// ─────────────────────────────────────────────

class _SongInfoCard extends StatelessWidget {
  final Track mediaItem;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: LoadImageCached(
                imageUrl: mediaItem.thumbnail.urlLow ?? mediaItem.thumbnail.url,
                fallbackUrl:
                    mediaItem.thumbnail.urlLow ?? mediaItem.thumbnail.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  mediaItem.artists.map((a) => a.name).join(', '),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: LoadImageCached(
                    imageUrl: playlist.coverImgUrl ?? "",
                    fallbackUrl: playlist.coverImgUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
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

class _AnimatedAvatarSection extends StatelessWidget {
  final List<PlaylistItemProperties> playlists;

  const _AnimatedAvatarSection({required this.playlists});

  @override
  Widget build(BuildContext context) {
    final bool hasPlaylists = playlists.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        opacity: hasPlaylists ? 1.0 : 0.0,
        child: hasPlaylists
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _StackedPlaylistAvatars(playlists: playlists),
              )
            : const SizedBox(width: double.infinity, height: 0),
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
    const double collapsedOverlap = 20.0;
    const double horizontalPadding = 32.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - horizontalPadding;

    final int maxVisible =
        ((availableWidth - avatarSize) / (avatarSize - collapsedOverlap) + 1)
            .floor()
            .clamp(1, totalCount);

    final bool hasOverflow = maxVisible < totalCount;
    final int displayCount = hasOverflow ? maxVisible : totalCount;

    final List<PlaylistItemProperties> visiblePlaylists =
        hasOverflow ? playlists.sublist(0, displayCount - 1) : playlists;

    final int overflowCount = hasOverflow ? totalCount - (displayCount - 1) : 0;
    final List<PlaylistItemProperties> overflowPlaylists =
        hasOverflow ? playlists.sublist(displayCount - 1) : [];

    final int itemsToRender = hasOverflow ? displayCount : totalCount;
    final double totalWidth =
        avatarSize + (itemsToRender - 1) * (avatarSize - collapsedOverlap);

    final double startX = (screenWidth - totalWidth) / 2;

    return SizedBox(
      height: avatarSize + 20,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (hasOverflow)
            Positioned(
              left: startX +
                  (displayCount - 1) * (avatarSize - collapsedOverlap) +
                  8,
              top: 10,
              child: _StaggeredAvatarEntrance(
                index: displayCount - 1,
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
            ),
          ...List.generate(visiblePlaylists.length, (index) {
            final reverseIndex = visiblePlaylists.length - 1 - index;
            final playlist = visiblePlaylists[reverseIndex];

            final double itemOffset =
                reverseIndex * (avatarSize - collapsedOverlap);

            return Positioned(
              left: startX + itemOffset,
              top: 10,
              child: _StaggeredAvatarEntrance(
                index: reverseIndex,
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
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StaggeredAvatarEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredAvatarEntrance({
    required this.index,
    required this.child,
  });

  @override
  State<_StaggeredAvatarEntrance> createState() =>
      _StaggeredAvatarEntranceState();
}

class _StaggeredAvatarEntranceState extends State<_StaggeredAvatarEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(
      Duration(milliseconds: 60 * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

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
          imageUrl: playlist.coverImgUrl ?? "",
          fallbackUrl: playlist.coverImgUrl ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
