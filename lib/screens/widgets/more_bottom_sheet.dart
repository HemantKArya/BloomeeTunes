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
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/smart_replace_dialog.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/song_metadata_refresh_service.dart';

void showMoreBottomSheet(
  BuildContext context,
  Track song, {
  bool showDelete = false,
  bool showSinglePlay = false,
  bool showAddToQueue = true,
  bool showPlayNext = true,
  VoidCallback? onDelete,
}) {
  final playerCubit = context.read<BloomeePlayerCubit>();
  final libraryCubit = context.read<LibraryItemsCubit>();
  final playlistCubit = context.read<AddToPlaylistCubit>();
  final downloaderCubit = context.read<DownloaderCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    // FIX: Apply max width constraint directly to the bottom sheet
    // so outside tap gestures aren't swallowed by an invisible wide container.
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (sheetContext) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: playerCubit),
          BlocProvider.value(value: libraryCubit),
          BlocProvider.value(value: playlistCubit),
          BlocProvider.value(value: downloaderCubit),
        ],
        child: _TrackOptionsBottomSheet(
          song: song,
          showDelete: showDelete,
          showSinglePlay: showSinglePlay,
          showAddToQueue: showAddToQueue,
          showPlayNext: showPlayNext,
          onDelete: onDelete,
          parentContext: context,
        ),
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
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      // Keep bottom padding so it floats cleanly above the screen edge
      padding: EdgeInsets.fromLTRB(
        10,
        0,
        10,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Default_Theme.themeColor.withValues(alpha: 0.96),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                // FIX: Ensure it only takes needed height so top taps can dismiss
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(
                    onClose: () => Navigator.pop(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: SongCardWidget(
                      song: song,
                      showOptions: false,
                      showCopyBtn: true,
                      showInfoBtn: true,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showSinglePlay ||
                              showPlayNext ||
                              showAddToQueue) ...[
                            _ActionRow(
                              children: [
                                if (showSinglePlay)
                                  _ActionButton(
                                    icon: MingCute.play_circle_fill,
                                    label: l10n.playerPlayWithMix,
                                    accent:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: (ctx) {
                                      ctx
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .updateQueueTracks([song],
                                              doPlay: true);
                                      Navigator.pop(ctx);
                                      SnackbarService.showMessage(
                                          l10n.snackbarNowPlaying(song.title));
                                    },
                                  ),
                                if (showPlayNext)
                                  _ActionButton(
                                    icon: MingCute.square_arrow_right_line,
                                    label: l10n.playerPlayNext,
                                    accent:
                                        Theme.of(context).colorScheme.tertiary,
                                    onTap: (ctx) {
                                      ctx
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .addPlayNextTrack(song);
                                      Navigator.pop(ctx);
                                      SnackbarService.showMessage(
                                          l10n.snackbarAddedToNextQueue);
                                    },
                                  ),
                                if (showAddToQueue)
                                  _ActionButton(
                                    icon: MingCute.playlist_2_line,
                                    label: l10n.playerAddToQueue,
                                    accent:
                                        Theme.of(context).colorScheme.secondary,
                                    onTap: (ctx) {
                                      ctx
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .addQueueTracks([song]);
                                      Navigator.pop(ctx);
                                      SnackbarService.showMessage(
                                          l10n.snackbarAddedToQueue);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          _CompactTile(
                            icon: MingCute.heart_line,
                            title: l10n.playerAddToFavorites,
                            onTap: (ctx) {
                              ctx
                                  .read<LibraryItemsCubit>()
                                  .setTrackLiked(song, true);
                              Navigator.pop(ctx);
                              SnackbarService.showMessage(
                                  l10n.snackbarAddedToLiked(song.title));
                            },
                          ),
                          _CompactTile(
                            icon: MingCute.add_circle_line,
                            title: l10n.menuAddToPlaylist,
                            onTap: (ctx) {
                              final router = GoRouter.of(ctx);
                              ctx.read<AddToPlaylistCubit>().setTrack(song);
                              Navigator.pop(ctx);
                              router.pushNamed(RoutePaths.addToPlaylistScreen);
                            },
                          ),
                          _CompactTile(
                            icon: MingCute.search_2_line,
                            title: l10n.menuSmartReplace,
                            onTap: (ctx) {
                              Navigator.pop(ctx);
                              showSmartReplaceDialog(parentContext, song);
                            },
                          ),

                          // FIX: Moved Metadata Refresh here to blend flawlessly into the UI
                          _CompactTile(
                            icon: MingCute.refresh_3_line,
                            title: l10n.songInfoUpdateMetadata,
                            onTap: (ctx) async {
                              final player =
                                  ctx.read<BloomeePlayerCubit>().bloomeePlayer;
                              Navigator.pop(ctx);

                              final result =
                                  await SongMetadataRefreshService.refreshTrack(
                                song,
                                player: player,
                              );

                              if (result.isSuccess) {
                                SnackbarService.showMessage(
                                    l10n.songInfoMetadataUpdated);
                              } else if (result.status ==
                                      SongMetadataRefreshStatus
                                          .pluginUnavailable ||
                                  result.status ==
                                      SongMetadataRefreshStatus
                                          .invalidMediaId) {
                                SnackbarService.showMessage(
                                    l10n.songInfoMetadataUnavailable);
                              } else {
                                SnackbarService.showMessage(
                                    l10n.songInfoMetadataUpdateFailed);
                              }
                            },
                          ),

                          const SizedBox(height: 8),
                          BlocBuilder<DownloaderCubit, DownloaderState>(
                            builder: (ctx, state) {
                              final isDownloaded = ctx
                                  .read<DownloaderCubit>()
                                  .isDownloaded(song.id);
                              return _CompactTile(
                                icon: isDownloaded
                                    ? Icons.offline_pin_rounded
                                    : MingCute.download_2_line,
                                title: isDownloaded
                                    ? l10n.menuAvailableOffline
                                    : l10n.menuDownload,
                                iconColor: isDownloaded ? Colors.green : null,
                                onTap: (sheetCtx) {
                                  if (!isDownloaded) {
                                    sheetCtx
                                        .read<DownloaderCubit>()
                                        .downloadSong(song);
                                  }
                                  Navigator.pop(sheetCtx);
                                },
                              );
                            },
                          ),
                          _CompactTile(
                            icon: MingCute.share_forward_line,
                            title: l10n.menuShare,
                            onTap: (ctx) {
                              Navigator.pop(ctx);
                              SnackbarService.showMessage(
                                  l10n.menuSharePreparing(song.title));
                              if (song.url?.isNotEmpty ?? false) {
                                SharePlus.instance.share(
                                  ShareParams(
                                      text: song.url!, subject: song.title),
                                );
                              }
                            },
                          ),
                          _CompactTile(
                            icon: MingCute.external_link_line,
                            title: l10n.menuOpenOriginalLink,
                            onTap: (ctx) async {
                              Navigator.pop(ctx);
                              if (song.url?.isEmpty ?? true) return;
                              try {
                                await launchUrl(
                                  Uri.parse(song.url!),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (_) {
                                SnackbarService.showMessage(
                                    l10n.menuOpenLinkFailed);
                              }
                            },
                          ),
                          if (showDelete) ...[
                            const SizedBox(height: 8),
                            _CompactTile(
                              icon: MingCute.delete_2_line,
                              title: l10n.menuDeleteTrack,
                              iconColor: Theme.of(context).colorScheme.error,
                              titleColor: Theme.of(context).colorScheme.error,
                              onTap: (ctx) {
                                Navigator.pop(ctx);
                                onDelete?.call();
                              },
                            ),
                          ],
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
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded,
                color: cs.onSurface.withValues(alpha: 0.72)),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final List<Widget> children;

  const _ActionRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final void Function(BuildContext context) onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final void Function(BuildContext context) onTap;

  const _CompactTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveIconColor =
        iconColor ?? cs.onSurface.withValues(alpha: 0.72);
    final effectiveTitleColor =
        titleColor ?? cs.onSurface.withValues(alpha: 0.90);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: effectiveIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: effectiveTitleColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
