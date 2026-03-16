import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/library_views/playlist_edit_view.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/services/import_export_service.dart';

/// Shows options for an internal/local playlist
void showPlaylistOptsInrSheet(BuildContext context, Playlist playlist) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent, // Essential for glass blur
    builder: (sheetContext) => _PlaylistOptionsSheet(
      title: playlist.title,
      isInternal: true,
      onEdit: () {
        Navigator.pop(sheetContext);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PlaylistEditView()));
      },
    ),
  );
}

/// Shows options for an external/remote playlist
void showPlaylistOptsExtSheet(
  BuildContext context,
  String playlistName, {
  int? playlistId,
  bool isPinned = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent, // Essential for glass blur
    builder: (sheetContext) => _PlaylistOptionsSheet(
      title: playlistName,
      playlistId: playlistId,
      isInternal: false,
      isPinned: isPinned,
      parentContext: context, // Needed to read cubits safely after pop
    ),
  );
}

class _PlaylistOptionsSheet extends StatelessWidget {
  final String title;
  final bool isInternal;
  final int? playlistId;
  final bool isPinned;
  final VoidCallback? onEdit;
  final BuildContext? parentContext;

  const _PlaylistOptionsSheet({
    required this.title,
    required this.isInternal,
    this.playlistId,
    this.isPinned = false,
    this.onEdit,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctx = parentContext ?? context;

    return Center(
      // Prevents awkward stretching on desktop
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Default_Theme.themeColor.withOpacity(0.85),
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.08), width: 1)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── iOS Style Drag Handle ──
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // ── Header Title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Options List ──
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SECTION 1: Playback (External Only)
                            if (!isInternal)
                              _OptionGroup(
                                children: [
                                  _BottomSheetTile(
                                    icon: MingCute.play_circle_fill,
                                    iconColor: Default_Theme.accentColor2,
                                    title: l10n.playlistPlay,
                                    onTap: () async {
                                      final list = await ctx
                                          .read<LibraryItemsCubit>()
                                          .getPlaylistTracks(title);
                                      if (list != null && list.isNotEmpty) {
                                        ctx
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .loadPlaylist(
                                                Playlist(
                                                    tracks: list, title: title),
                                                doPlay: true);
                                        SnackbarService.showMessage(
                                            l10n.snackbarNowPlaying(title));
                                      }
                                    },
                                  ),
                                  _BottomSheetTile(
                                    icon: MingCute.playlist_2_line,
                                    title: l10n.playlistAddToQueue,
                                    onTap: () async {
                                      final list = await ctx
                                          .read<LibraryItemsCubit>()
                                          .getPlaylistTracks(title);
                                      if (list != null && list.isNotEmpty) {
                                        ctx
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .addQueueTracks(list);
                                        SnackbarService.showMessage(
                                            l10n.snackbarPlaylistAddedToQueue(
                                                title));
                                      }
                                    },
                                  ),
                                ],
                              ),

                            // SECTION 2: Export & Share
                            _OptionGroup(
                              children: [
                                _BottomSheetTile(
                                  icon: MingCute.share_forward_line,
                                  title: isInternal
                                      ? l10n.playlistShareFile
                                      : l10n.playlistShare,
                                  onTap: () async {
                                    SnackbarService.showMessage(
                                        l10n.snackbarPreparingShare(title));
                                    final tmpPath = await ImportExportService
                                        .exportPlaylist(title);
                                    if (tmpPath != null)
                                      Share.shareXFiles([XFile(tmpPath)]);
                                  },
                                ),
                                if (!Platform.isAndroid)
                                  _BottomSheetTile(
                                    icon: MingCute.file_export_line,
                                    title: l10n.playlistExportFile,
                                    onTap: () async {
                                      String? path = await FilePicker.platform
                                          .getDirectoryPath();
                                      if (path == null || path == "/")
                                        path = (await getDownloadsDirectory())
                                            ?.path
                                            .toString();
                                      SnackbarService.showMessage(
                                          l10n.snackbarPreparingExport(title));
                                      final tmpPath = await ImportExportService
                                          .exportPlaylist(title,
                                              filePath: path);
                                      SnackbarService.showMessage(l10n
                                          .snackbarExportedTo(tmpPath ?? ''));
                                    },
                                  ),
                              ],
                            ),

                            // SECTION 3: Management
                            _OptionGroup(
                              children: [
                                if (isInternal)
                                  _BottomSheetTile(
                                    icon: MingCute.edit_2_line,
                                    title: l10n.playlistEdit,
                                    onTap: onEdit ?? () {},
                                  ),
                                if (!isInternal) ...[
                                  _BottomSheetTile(
                                    icon: isPinned
                                        ? MingCute.unlink_line
                                        : MingCute.pin_2_fill,
                                    iconColor: isPinned
                                        ? null
                                        : Default_Theme.accentColor2,
                                    title: isPinned
                                        ? l10n.playlistUnpin
                                        : l10n.playlistPinToTop,
                                    onTap: () {
                                      if (playlistId != null)
                                        ctx
                                            .read<LibraryItemsCubit>()
                                            .togglePin(playlistId!);
                                    },
                                  ),
                                  _BottomSheetTile(
                                    icon: MingCute.delete_2_line,
                                    title: l10n.playlistDelete,
                                    iconColor: Colors.redAccent,
                                    titleColor: Colors.redAccent,
                                    onTap: () => ctx
                                        .read<LibraryItemsCubit>()
                                        .removePlaylistByName(title),
                                  ),
                                ],
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

// ── Smart "Glass Shelf" Group Container ─────────────────────────────────────

class _OptionGroup extends StatelessWidget {
  final List<Widget> children;
  const _OptionGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04), // Borderless floating card
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
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
            color: Colors.white.withOpacity(0.04), // Ultra subtle separator
            indent: 52, // Perfectly aligns with the start of the text
          ),
        );
      }
    }
    return result;
  }
}

// ── Highly Aesthetic Interactive Tile ────────────────────────────────────────

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
    final effectiveIconColor = iconColor ?? Colors.white.withOpacity(0.55);
    final effectiveTitleColor = titleColor ?? Colors.white.withOpacity(0.9);

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Instant feedback by popping sheet
        onTap();
      },
      splashColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: effectiveIconColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: effectiveTitleColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
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
