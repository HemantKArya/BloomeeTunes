import 'dart:io';

import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/screens/screen/library_views/playlist_edit_view.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void showPlaylistOptsInrSheet(BuildContext context, Playlist playlist) {
  showFloatingModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 7, 17, 50),
                    Color.fromARGB(255, 5, 0, 24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PltOptBtn(
                    title: AppLocalizations.of(context)!.playlistEdit,
                    icon: MingCute.edit_2_line,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlaylistEditView()));
                    },
                  ),
                  // PltOptBtn(
                  //   title: "Sync Playlist",
                  //   icon: MingCute.refresh_1_line,
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     SnackbarService.showMessage(
                  //         "Syncing ${mediaPlaylist.playlistName}");
                  //   },
                  // ),
                  PltOptBtn(
                    icon: MingCute.share_2_line,
                    title: AppLocalizations.of(context)!.playlistShareFile,
                    onPressed: () async {
                      Navigator.pop(context);
                      SnackbarService.showMessage(AppLocalizations.of(context)!
                          .snackbarPreparingShare(playlist.title));
                      final _tmpPath = await ImportExportService.exportPlaylist(
                          playlist.title);
                      _tmpPath != null
                          ? Share.shareXFiles([XFile(_tmpPath)])
                          : null;
                    },
                  ),
                  if (!Platform.isAndroid)
                    PltOptBtn(
                      icon: MingCute.file_export_line,
                      title: AppLocalizations.of(context)!.playlistExportFile,
                      onPressed: () async {
                        Navigator.pop(context);
                        String? path =
                            await FilePicker.platform.getDirectoryPath();
                        if (path == null || path == "/") {
                          path =
                              (await getDownloadsDirectory())?.path.toString();
                        }
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarPreparingExport(playlist.title));
                        final _tmpPath =
                            await ImportExportService.exportPlaylist(
                          playlist.title,
                          filePath: path,
                        );
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarExportedTo(_tmpPath ?? ''));
                      },
                    ),
                ],
              ),
            ),
          )
        ],
      );
    },
  );
}

void showPlaylistOptsExtSheet(
  BuildContext context,
  String playlistName, {
  int? playlistId,
  bool isPinned = false,
}) {
  showFloatingModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 7, 17, 50),
                    Color.fromARGB(255, 5, 0, 24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PltOptBtn(
                    icon: MingCute.play_circle_fill,
                    title: AppLocalizations.of(context)!.playlistPlay,
                    onPressed: () async {
                      Navigator.pop(context);
                      final _list = await context
                          .read<LibraryItemsCubit>()
                          .getPlaylistTracks(playlistName);
                      if (_list != null && _list.isNotEmpty) {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .loadPlaylist(
                                Playlist(tracks: _list, title: playlistName),
                                doPlay: true);
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarNowPlaying(playlistName));
                      }
                    },
                  ),
                  PltOptBtn(
                    title: AppLocalizations.of(context)!.playlistAddToQueue,
                    icon: MingCute.playlist_2_line,
                    onPressed: () async {
                      Navigator.pop(context);
                      final _list = await context
                          .read<LibraryItemsCubit>()
                          .getPlaylistTracks(playlistName);
                      if (_list != null && _list.isNotEmpty) {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .addQueueTracks(_list);
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarPlaylistAddedToQueue(playlistName));
                      }
                    },
                  ),
                  PltOptBtn(
                    icon: MingCute.share_2_fill,
                    title: AppLocalizations.of(context)!.playlistShare,
                    onPressed: () async {
                      Navigator.pop(context);
                      SnackbarService.showMessage(AppLocalizations.of(context)!
                          .snackbarPreparingShare(playlistName));
                      final _tmpPath = await ImportExportService.exportPlaylist(
                          playlistName);
                      _tmpPath != null
                          ? Share.shareXFiles([XFile(_tmpPath)])
                          : null;
                    },
                  ),
                  if (!Platform.isAndroid)
                    PltOptBtn(
                      icon: MingCute.file_export_line,
                      title: AppLocalizations.of(context)!.playlistExportFile,
                      onPressed: () async {
                        Navigator.pop(context);
                        String? path =
                            await FilePicker.platform.getDirectoryPath();
                        if (path == null || path == "/") {
                          path =
                              (await getDownloadsDirectory())?.path.toString();
                        }
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarPreparingExport(playlistName));
                        final _tmpPath =
                            await ImportExportService.exportPlaylist(
                          playlistName,
                          filePath: path,
                        );
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarExportedTo(_tmpPath ?? ''));
                      },
                    ),
                  PltOptBtn(
                    icon: isPinned ? MingCute.unlink_line : MingCute.pin_2_fill,
                    title: isPinned
                        ? AppLocalizations.of(context)!.playlistUnpin
                        : AppLocalizations.of(context)!.playlistPinToTop,
                    onPressed: () {
                      Navigator.pop(context);
                      if (playlistId != null) {
                        context.read<LibraryItemsCubit>().togglePin(playlistId);
                      }
                    },
                  ),
                  PltOptBtn(
                    title: AppLocalizations.of(context)!.playlistDelete,
                    icon: MingCute.delete_2_fill,
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .read<LibraryItemsCubit>()
                          .removePlaylistByName(playlistName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PltOptBtn extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  const PltOptBtn({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Row(
        children: [
          Icon(
            icon,
            color: Default_Theme.primaryColor1,
            size: 25,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
      hoverColor: Default_Theme.primaryColor1.withValues(alpha: 0.04),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      containerWidget: (_, animation, child) => FloatingModal(
            child: child,
          ),
      expand: false);

  return result;
}

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}
