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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    useSafeArea:
        true, // Prevents overlapping with top notch if it gets too tall
    backgroundColor:
        Colors.transparent, // Let the container handle the gradient
    builder: (sheetContext) {
      return _TrackOptionsBottomSheet(
        song: song,
        showDelete: showDelete,
        showSinglePlay: showSinglePlay,
        showAddToQueue: showAddToQueue,
        showPlayNext: showPlayNext,
        onDelete: onDelete,
        // Pass parent context to ensure we can safely access cubits/routers after pop
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 17, 50),
            Color.fromARGB(255, 5, 0, 24),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 12, 4, 8),
              child: SongCardWidget(
                song: song,
                showOptions: false,
                showCopyBtn: true,
                showInfoBtn: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Opacity(
                opacity: 0.5,
                child:
                    Divider(thickness: 2, color: Default_Theme.primaryColor1),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSinglePlay)
                      _BottomSheetTile(
                        icon: MingCute.play_circle_fill,
                        title: l10n.playerPlayWithMix,
                        onTap: () {
                          player.updateQueueTracks([song], doPlay: true);
                          SnackbarService.showMessage(
                            l10n.snackbarNowPlaying(song.title),
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    if (showPlayNext)
                      _BottomSheetTile(
                        icon: MingCute.square_arrow_right_line,
                        title: l10n.playerPlayNext,
                        onTap: () {
                          player.addPlayNextTrack(song);
                          SnackbarService.showMessage(
                            l10n.snackbarAddedToNextQueue,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    if (showAddToQueue)
                      _BottomSheetTile(
                        icon: MingCute.playlist_2_line,
                        title: l10n.playerAddToQueue,
                        onTap: () {
                          player.addQueueTracks([song]);
                          SnackbarService.showMessage(
                            l10n.snackbarAddedToQueue,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    _BottomSheetTile(
                      icon: MingCute.heart_fill,
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
                      icon: MingCute.add_circle_fill,
                      title: l10n.menuAddToPlaylist,
                      onTap: () {
                        parentContext.read<AddToPlaylistCubit>().setTrack(song);
                        parentContext.pushNamed(RoutePaths.addToPlaylistScreen);
                      },
                    ),
                    _BottomSheetTile(
                      icon: MingCute.search_2_line,
                      title: l10n.menuSmartReplace,
                      onTap: () => showSmartReplaceDialog(parentContext, song),
                    ),
                    _BottomSheetTile(
                      icon: Icons.share,
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

                    // Reactive Download Button
                    BlocBuilder<DownloaderCubit, DownloaderState>(
                      builder: (context, state) {
                        final isDownloaded = context
                            .read<DownloaderCubit>()
                            .isDownloaded(song.id);
                        return _BottomSheetTile(
                          icon: isDownloaded
                              ? Icons.offline_pin_rounded
                              : MingCute.download_2_fill,
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
                      icon: MingCute.external_link_line,
                      title: l10n.menuOpenOriginalLink,
                      onTap: () async {
                        if (song.url?.isEmpty ?? true) return;
                        try {
                          await launchUrl(Uri.parse(song.url!),
                              mode: LaunchMode.externalApplication);
                        } catch (_) {
                          SnackbarService.showMessage(l10n.menuOpenLinkFailed);
                        }
                      },
                    ),
                    if (showDelete)
                      _BottomSheetTile(
                        icon: MingCute.delete_2_fill,
                        title: l10n.menuDeleteTrack,
                        onTap: onDelete ?? () {},
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Icon(
        icon,
        color: Default_Theme.primaryColor1,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Default_Theme.primaryColor1,
          fontFamily: "Unageo",
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
