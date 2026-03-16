import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/smart_replace_dialog.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';

void showMoreBottomSheet(
  BuildContext context,
  Track song, {
  bool showDelete = false,
  bool showSinglePlay = false,
  bool showAddToQueue = true,
  bool showPlayNext = true,
  VoidCallback? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent, // Required for pristine blur
    builder: (sheetContext) {
      return _TrackOptionsBottomSheet(
        song: song,
        showDelete: showDelete,
        showSinglePlay: showSinglePlay,
        showAddToQueue: showAddToQueue,
        showPlayNext: showPlayNext,
        onDelete: onDelete,
        parentContext: context,
      );
    },
  );
}

class _TrackOptionsBottomSheet extends StatelessWidget {
  final Track song;
  final bool showDelete;
  final bool showSinglePlay;
  final bool showAddToQueue;
  final bool showPlayNext;
  final VoidCallback? onDelete;
  final BuildContext parentContext;

  const _TrackOptionsBottomSheet({
    required this.song,
    required this.showDelete,
    required this.showSinglePlay,
    required this.showAddToQueue,
    required this.showPlayNext,
    required this.parentContext,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = parentContext.read<BloomeePlayerCubit>().bloomeePlayer;

    return Center(
      // Tighter max-width (400) creates a sharp, focused context menu on Desktop
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Default_Theme.themeColor
                    .withOpacity(0.8), // Deep transparent base
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.08), width: 1),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Ultra-Minimal Drag Handle ---
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 4),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // --- Track Header ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: SongCardWidget(
                        song: song,
                        showOptions: false,
                        showCopyBtn: true,
                        showInfoBtn: true,
                      ),
                    ),

                    // --- Compact, Grouped Options ---
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SECTION 1: Playback
                            if (showSinglePlay ||
                                showPlayNext ||
                                showAddToQueue)
                              _OptionGroup(
                                children: [
                                  if (showSinglePlay)
                                    _BottomSheetTile(
                                      icon: MingCute.play_circle_fill,
                                      iconColor: Default_Theme
                                          .accentColor2, // Semantic highlight
                                      title: l10n.playerPlayWithMix,
                                      onTap: () {
                                        player.updateQueueTracks([song],
                                            doPlay: true);
                                        SnackbarService.showMessage(l10n
                                            .snackbarNowPlaying(song.title));
                                      },
                                    ),
                                  if (showPlayNext)
                                    _BottomSheetTile(
                                      icon: MingCute.square_arrow_right_line,
                                      title: l10n.playerPlayNext,
                                      onTap: () {
                                        player.addPlayNextTrack(song);
                                        SnackbarService.showMessage(
                                            l10n.snackbarAddedToNextQueue);
                                      },
                                    ),
                                  if (showAddToQueue)
                                    _BottomSheetTile(
                                      icon: MingCute.playlist_2_line,
                                      title: l10n.playerAddToQueue,
                                      onTap: () {
                                        player.addQueueTracks([song]);
                                        SnackbarService.showMessage(
                                            l10n.snackbarAddedToQueue);
                                      },
                                    ),
                                ],
                              ),

                            // SECTION 2: Library
                            _OptionGroup(
                              children: [
                                _BottomSheetTile(
                                  icon: MingCute.heart_line,
                                  title: l10n.playerAddToFavorites,
                                  onTap: () {
                                    parentContext
                                        .read<LibraryItemsCubit>()
                                        .setTrackLiked(song, true);
                                    SnackbarService.showMessage(
                                        l10n.snackbarAddedToLiked(song.title));
                                  },
                                ),
                                _BottomSheetTile(
                                  icon: MingCute.add_circle_line,
                                  title: l10n.menuAddToPlaylist,
                                  onTap: () {
                                    parentContext
                                        .read<AddToPlaylistCubit>()
                                        .setTrack(song);
                                    parentContext.pushNamed(
                                        RoutePaths.addToPlaylistScreen);
                                  },
                                ),
                                _BottomSheetTile(
                                  icon: MingCute.search_2_line,
                                  title: l10n.menuSmartReplace,
                                  onTap: () => showSmartReplaceDialog(
                                      parentContext, song),
                                ),
                              ],
                            ),

                            // SECTION 3: External & Destructive
                            _OptionGroup(
                              children: [
                                BlocBuilder<DownloaderCubit, DownloaderState>(
                                  builder: (context, state) {
                                    final isDownloaded = context
                                        .read<DownloaderCubit>()
                                        .isDownloaded(song.id);
                                    return _BottomSheetTile(
                                      icon: isDownloaded
                                          ? Icons.offline_pin_rounded
                                          : MingCute.download_2_line,
                                      iconColor: isDownloaded
                                          ? Colors.green
                                          : null, // Semantic highlight
                                      title: isDownloaded
                                          ? l10n.menuAvailableOffline
                                          : l10n.menuDownload,
                                      onTap: () {
                                        if (!isDownloaded) {
                                          parentContext
                                              .read<DownloaderCubit>()
                                              .downloadSong(song);
                                        }
                                      },
                                    );
                                  },
                                ),
                                _BottomSheetTile(
                                  icon: MingCute.share_forward_line,
                                  title: l10n.menuShare,
                                  onTap: () {
                                    SnackbarService.showMessage(
                                        l10n.menuSharePreparing(song.title));
                                    if (song.url?.isNotEmpty ?? false) {
                                      SharePlus.instance.share(ShareParams(
                                        text: song.url!,
                                        subject: song.title,
                                      ));
                                    }
                                  },
                                ),
                                _BottomSheetTile(
                                  icon: MingCute.external_link_line,
                                  title: l10n.menuOpenOriginalLink,
                                  onTap: () async {
                                    if (song.url?.isEmpty ?? true) return;
                                    try {
                                      await launchUrl(Uri.parse(song.url!),
                                          mode: LaunchMode.externalApplication);
                                    } catch (_) {
                                      SnackbarService.showMessage(
                                          l10n.menuOpenLinkFailed);
                                    }
                                  },
                                ),
                                if (showDelete)
                                  _BottomSheetTile(
                                    icon: MingCute.delete_2_line,
                                    title: l10n.menuDeleteTrack,
                                    iconColor:
                                        Colors.redAccent, // Semantic highlight
                                    titleColor: Colors.redAccent,
                                    onTap: onDelete ?? () {},
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Smart, Borderless Grouping Container ─────────────────────────────────────

class _OptionGroup extends StatelessWidget {
  final List<Widget> children;
  const _OptionGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Tighter margin
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.04), // Borderless "floating glass" shelf
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent, // Ensures ripples display flawlessly
          child: Column(
            children: _buildChildrenWithDividers(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.04), // Extremely subtle separator
            indent: 50, // Perfectly aligns with the start of the text
          ),
        );
      }
    }
    return result;
  }
}

// ── Ultra-Sleek Interactive Tile ─────────────────────────────────────────────

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Optical balancing: Icons should be muted compared to text unless semantically colored
    final effectiveIconColor = iconColor ?? Colors.white.withOpacity(0.55);
    final effectiveTitleColor = titleColor ?? Colors.white.withOpacity(0.9);

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Dismiss sheet first for snap-response
        onTap(); // Execute action
      },
      splashColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Compact, dense padding
        child: Row(
          children: [
            Icon(
              icon,
              color: effectiveIconColor,
              size: 20, // Smaller, tighter icon size
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: effectiveTitleColor,
                  fontSize:
                      14.5, // Reduced from 17 for a much cleaner, professional typography scale
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2, // Tighter tracking looks more modern
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
