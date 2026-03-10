import 'dart:developer';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
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
              "${song.title.toLowerCase()} ${song.artists.map((a) => a.name).join(', ').toLowerCase()}"
                  .contains(query))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      // When closing the search, clear the controller and reset the filter
      if (!_isSearch) {
        _searchController.clear();
        final downloaderState = context.read<DownloaderCubit>().state;
        _filteredSongs = downloaderState.downloaded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<DownloaderCubit, DownloaderState>(
          builder: (context, state) {
            if (_searchController.text.isEmpty) {
              _filteredSongs = state.downloaded;
            }
            return CustomScrollView(
              slivers: [
                customDiscoverSliverBar(context, l10n),
                if (state.downloads.isEmpty && state.downloaded.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: SignBoardWidget(
                        message: l10n.offlineNoDownloads,
                        icon: FontAwesome.download_solid,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        ...state.downloads.map((download) =>
                            DownloadingCardWidget(downloadProgress: download)),
                        ..._filteredSongs.map((song) => SongCardWidget(
                              song: song,
                              showOptions: true,
                              delDownBtn: true,
                              onTap: () {
                                final selectedIndex =
                                    state.downloaded.indexWhere(
                                  (item) => item.id == song.id,
                                );

                                if (selectedIndex < 0 ||
                                    state.downloaded.isEmpty) {
                                  SnackbarService.showMessage(
                                      l10n.offlineOpenFailed);
                                  log(
                                    'Offline play failed: missing track in downloaded list (${song.id})',
                                    name: 'OfflineScreen',
                                  );
                                  return;
                                }

                                try {
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .bloomeePlayer
                                      .loadPlaylist(
                                        Playlist(
                                          tracks: state.downloaded,
                                          title: "Offline",
                                        ),
                                        idx: selectedIndex,
                                        doPlay: true,
                                      );
                                } catch (e, stack) {
                                  log(
                                    'Offline play crashed for ${song.id}',
                                    name: 'OfflineScreen',
                                    error: e,
                                    stackTrace: stack,
                                  );
                                  SnackbarService.showMessage(
                                      l10n.offlinePlayFailed);
                                }
                              },
                              onOptionsTap: () {
                                showMoreBottomSheet(context, song,
                                    showDelete: false);
                              },
                            )),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar customDiscoverSliverBar(
      BuildContext context, AppLocalizations l10n) {
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
        !_isSearch
            ? Tooltip(
                message: l10n.offlineRefreshTooltip,
                child: IconButton(
                  icon: const Icon(MingCute.refresh_2_line),
                  onPressed: () {
                    context.read<DownloaderCubit>().refreshDownloadedSongs();
                  },
                ),
              )
            : const SizedBox.shrink(),
        Tooltip(
          message:
              _isSearch ? l10n.offlineCloseSearch : l10n.offlineSearchTooltip,
          child: IconButton(
            icon: Icon(
              _isSearch ? Icons.close : Icons.search,
              color: Default_Theme.primaryColor1,
            ),
            onPressed: _toggleSearch,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('title'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.offlineTitle,
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
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
          hintStyle: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
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
