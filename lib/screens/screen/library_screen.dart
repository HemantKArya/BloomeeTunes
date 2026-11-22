import 'dart:ui';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/screens/widgets/create_playlist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
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
  bool _isReordering = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _reorderFocusNode = FocusNode(debugLabel: 'libraryReorder');

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
    _reorderFocusNode.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchQuery.value = query;

    final itemsState = context.read<LibraryItemsCubit>().state;
    context.read<LibrarySearchCubit>().search(query, itemsState);
  }

  void _enterReorder() {
    if (_isReordering) return;
    HapticFeedback.mediumImpact();
    setState(() => _isReordering = true);
    _reorderFocusNode.requestFocus();
  }

  void _exitReorder() {
    if (!_isReordering) return;
    setState(() => _isReordering = false);
  }

  void _openSearch() {
    setState(() {
      _isReordering = false;
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
    // While reordering, Back and Esc leave the mode instead of the screen.
    return PopScope(
      canPop: !_isReordering,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitReorder();
      },
      child: CallbackShortcuts(
        bindings: {
          if (_isReordering)
            const SingleActivator(LogicalKeyboardKey.escape): _exitReorder,
        },
        child: Focus(
          focusNode: _reorderFocusNode,
          child: _buildScaffold(context),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
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
                  SliverFillRemaining(
                    child: Center(
                      child: SignBoardWidget(
                        message:
                            AppLocalizations.of(context)!.libraryEmptyState,
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
                                color: Default_Theme.accentColor1
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isSearching && !hasResults && !isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: SignBoardWidget(
                            message:
                                AppLocalizations.of(context)!.emptyNoResults,
                            icon: MingCute.search_line,
                          ),
                        ),
                      ),
                    if (hasResults) ...[
                      if (filteredSongs.isNotEmpty)
                        _buildSongSearchResults(context, filteredSongs),
                      if (filteredPlaylists.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _ReorderHint(
                            visible: _isReordering && !isSearching,
                            hasPinned: filteredPlaylists.any((p) => p.isPinned),
                          ),
                        ),
                        _ListOfPlaylists(
                          playlists: filteredPlaylists,
                          isReorderable: _isReordering && !isSearching,
                          onEnterReorder: isSearching ? null : _enterReorder,
                        ),
                      ],
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
          color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
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
            hintText: AppLocalizations.of(context)!.searchHintLibrary,
            hintStyle: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                fontSize: 15,
              ),
            ),
            prefixIcon: Icon(
              MingCute.search_line,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
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
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
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
              subtitleOverride:
                  AppLocalizations.of(context)!.libraryIn(result.playlistName),
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
            AppLocalizations.of(context)!.libraryTitle,
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(
                fontSize: 34,
                color: Default_Theme.primaryColor1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _isReordering
                ? _DoneButton(
                    key: const ValueKey('done'),
                    onPressed: _exitReorder,
                  )
                : _headerActions(context),
          ),
        ],
      ),
    );
  }

  Widget _headerActions(BuildContext context) {
    return Row(
      key: const ValueKey('actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
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
          onPressed: () => createPlaylistDialog(context),
          icon: const Icon(MingCute.add_fill,
              size: 25, color: Default_Theme.primaryColor1),
        ),
        IconButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            final importPhase = context.read<ContentImportCubit>().state.phase;
            final isOngoing = importPhase != ImportPhase.idle &&
                importPhase != ImportPhase.done &&
                importPhase != ImportPhase.error;
            if (isOngoing) {
              final pluginId =
                  context.read<ContentImportCubit>().state.pluginId ?? '';
              context.pushNamed(RoutePaths.importProcess,
                  queryParameters: {'pluginId': pluginId});
            } else {
              context.pushNamed(RoutePaths.importMediaFromPlatforms);
            }
          },
          icon: const Icon(FontAwesome.file_import_solid,
              size: 22, color: Default_Theme.primaryColor1),
        ),
      ],
    );
  }
}

/// Header action shown in place of search/add/import while reordering.
class _DoneButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DoneButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Default_Theme.primaryColor1,
          foregroundColor: Default_Theme.themeColor,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const StadiumBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: Default_Theme.secondoryTextStyle.merge(const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          )),
        ),
        child: Text(AppLocalizations.of(context)!.importDone),
      ),
    );
  }
}

/// One quiet line under the header explaining the mode; no card, no colour.
class _ReorderHint extends StatelessWidget {
  final bool visible;
  final bool hasPinned;
  const _ReorderHint({required this.visible, required this.hasPinned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasPinned
                          ? l10n.libraryReorderHintPinned
                          : l10n.libraryReorderHint,
                      style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.55),
                      )),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ListOfPlaylists extends StatelessWidget {
  final List<PlaylistItemProperties> playlists;
  final bool isReorderable;
  final VoidCallback? onEnterReorder;
  const _ListOfPlaylists({
    required this.playlists,
    this.isReorderable = false,
    this.onEnterReorder,
  });

  static LibItemTypes _toCardType(PlaylistType type) {
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

  static Future<void> _openLibraryItem(
      BuildContext context, PlaylistItemProperties item) async {
    if (item.type == PlaylistType.userPlaylist) {
      context.pushNamed(
        RoutePaths.playlistView,
        extra: item.storageKey,
      );
      return;
    }

    // For remote collections, resolve via the cubit (domain-level, no DB types).
    final playlist = await context
        .read<LibraryItemsCubit>()
        .resolveLibraryItem(item.storageKey);
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

  Widget _buildTile(BuildContext context, PlaylistItemProperties playlist) {
    void openMenu() {
      showPlaylistOptsExtSheet(
        context,
        playlist.playlistName,
        playlistId: playlist.playlistId,
        isPinned: playlist.isPinned,
      );
    }

    return LibItemCard(
      onTap: isReorderable ? null : () => _openLibraryItem(context, playlist),
      onSecondaryTap: isReorderable ? null : openMenu,
      onLongPress: isReorderable ? null : (onEnterReorder ?? openMenu),
      onMenuTap: isReorderable ? null : openMenu,
      showMenuButton: !isReorderable,
      title: playlist.playlistName,
      coverArt: playlist.coverImgUrl ?? '',
      subtitle: playlist.subTitle ?? '',
      type: _toCardType(playlist.type),
      isPinned: playlist.isPinned,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isReorderable) {
      return SliverList.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            child: _buildTile(context, playlists[index]),
          );
        },
      );
    }

    // Mouse: drag anywhere on the row straight away. Touch: long-press the
    // row (so scrolling still works) or drag the handle immediately.
    final pointerIsMouse = switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS =>
        true,
      _ => false,
    };
    final pinnedCount = playlists.where((p) => p.isPinned).length;

    return SliverReorderableList(
      itemBuilder: (context, index) {
        final body = AbsorbPointer(
          child: _buildTile(context, playlists[index]),
        );
        final row = Row(
          children: [
            Expanded(
              child: pointerIsMouse
                  ? ReorderableDragStartListener(index: index, child: body)
                  : ReorderableDelayedDragStartListener(
                      index: index, child: body),
            ),
            ReorderableDragStartListener(
              index: index,
              child: SizedBox(
                width: 48,
                height: 80,
                child: Icon(
                  Icons.drag_handle_rounded,
                  size: 22,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.45),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
        return KeyedSubtree(
          key: ValueKey(playlists[index].playlistId),
          child: pointerIsMouse
              ? MouseRegion(cursor: SystemMouseCursors.grab, child: row)
              : row,
        );
      },
      itemExtent: 80,
      itemCount: playlists.length,
      proxyDecorator: _proxyDecorator,
      onReorder: (oldIndex, newIndex) {
        // Pinned items always sort first, so keep each item in its group;
        // a drop across the boundary would be undone on the next load.
        final pinned = playlists[oldIndex].isPinned;
        final target = pinned
            ? newIndex.clamp(0, pinnedCount)
            : newIndex.clamp(pinnedCount, playlists.length);
        context.read<LibraryItemsCubit>().reorderLibrary(oldIndex, target);
      },
    );
  }
}

// Same raised surface as the theme's surfaceContainerHighest.
const _liftedSurface = Color(0xFF1A111B);

/// The lifted row: a slightly raised surface with a soft neutral shadow.
Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      return Transform.scale(
        scale: lerpDouble(1, 1.02, t)!,
        child: Material(
          elevation: lerpDouble(0, 10, t)!,
          color: Color.lerp(Default_Theme.themeColor, _liftedSurface, t),
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    },
    child: child,
  );
}
