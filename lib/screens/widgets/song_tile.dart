// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:audio_service/audio_service.dart';

import 'package:Bloomee/screens/screen/common_views/song_info_screen.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart' hide MediaItem;
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/load_image.dart';

class SongCardWidget extends StatelessWidget {
  final Track song;
  final int? index; // Elegantly handles album/playlist numbering
  final bool showOptions;
  final bool showInfoBtn;
  final bool showPlayBtn;
  final bool showCopyBtn;
  final bool delDownBtn;
  final bool isWide;
  final String? subtitleOverride;
  final VoidCallback? onOptionsTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onDelDownTap;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SongCardWidget({
    super.key,
    required this.song,
    this.index,
    this.showOptions = true,
    this.showInfoBtn = false,
    this.showPlayBtn = false,
    this.delDownBtn = false,
    this.onOptionsTap,
    this.onInfoTap,
    this.onPlayTap,
    this.onTap,
    this.onDelDownTap,
    this.showCopyBtn = false,
    this.isWide = false,
    this.subtitleOverride,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BloomeePlayerCubit>();

    // Isolated StreamBuilder: Rebuilds ONLY this specific card when its playing state changes,
    // ensuring 120fps scrolling performance for massive playlists.
    return StreamBuilder<MediaItem?>(
      stream: playerCubit.bloomeePlayer.mediaItem,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.id == song.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: 66, // Sleek, breathable modern height
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isPlaying
                ? Default_Theme.accentColor2.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.06),
              highlightColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.03),
              onTap: onTap,
              onLongPress: onOptionsTap, // Native UX feel
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    // ── Smooth Index / Playing Indicator Transition ──
                    if (index != null || isPlaying)
                      SizedBox(
                        width: 36,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                  scale: animation, child: child),
                            ),
                            child: isPlaying
                                ? const Icon(
                                    MingCute.music_3_fill, // Audio wave icon
                                    key: ValueKey('playing_icon'),
                                    color: Default_Theme.accentColor2,
                                    size: 18,
                                  )
                                : Text(
                                    index.toString(),
                                    key: const ValueKey('index_text'),
                                    style: TextStyle(
                                      color: Default_Theme.primaryColor2
                                          .withValues(alpha: 0.5),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                    // ── Thumbnail ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: isWide ? 86 : 50,
                        height: 50,
                        child: LoadImageCached(
                          imageUrl: song.thumbnail.urlLow ?? song.thumbnail.url,
                          fallbackUrl:
                              song.thumbnail.urlLow ?? song.thumbnail.url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // ── Animated Title & Subtitle ──
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              color: isPlaying
                                  ? Default_Theme.accentColor2
                                  : Colors.white.withValues(alpha: 0.75),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              fontFamily:
                                  Default_Theme.secondoryTextStyle.fontFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: Text(song.title),
                          ),
                          const SizedBox(height: 3),
                          if (subtitleOverride != null)
                            Text(
                              subtitleOverride!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.65),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          else
                            TrackMetadataLinks(
                              track: song,
                              style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.65),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ── Actions ──
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showPlayBtn)
                          _ActionButton(
                            icon: MingCute.play_circle_fill,
                            onTap: onPlayTap,
                            iconSize: 24,
                          ),
                        if (showCopyBtn)
                          _ActionButton(
                            icon: MingCute.copy_2_line,
                            tooltip: "Copy to clipboard",
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "${song.title} by ${song.artists.map((a) => a.name).join(', ')}"));
                              SnackbarService.showMessage(
                                  "Copied to clipboard");
                            },
                          ),
                        if (showInfoBtn)
                          _ActionButton(
                            icon: MingCute.information_line,
                            tooltip: "Song Info",
                            onTap: () {
                              if (onInfoTap != null) {
                                onInfoTap!();
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SongInfoScreen(song: song)));
                              }
                            },
                          ),
                        if (delDownBtn)
                          _ActionButton(
                            icon: MingCute.delete_2_line,
                            iconColor: Colors.redAccent.withValues(alpha: 0.9),
                            onTap: () {
                              try {
                                if (playerCubit.bloomeePlayer.currentMedia.id !=
                                    song.id) {
                                  context
                                      .read<DownloaderCubit>()
                                      .removeDownload(song);
                                  SnackbarService.showMessage(
                                      "Removed ${song.title}");
                                } else {
                                  SnackbarService.showMessage(
                                      "Cannot delete currently playing song");
                                }
                              } catch (e) {
                                context
                                    .read<DownloaderCubit>()
                                    .removeDownload(song);
                                SnackbarService.showMessage(
                                    "Removed ${song.title}");
                              }
                            },
                          ),
                        if (showOptions)
                          _ActionButton(
                            icon: MingCute.more_2_fill,
                            onTap: onOptionsTap,
                          ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Ultra-compact, hit-box optimized action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? iconColor;
  final double iconSize;

  const _ActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    this.iconColor,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.1),
        highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ??
                Default_Theme.primaryColor1.withValues(alpha: 0.65),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        textStyle: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(6)),
        child: button,
      );
    }
    return button;
  }
}
