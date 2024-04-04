import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

void showPlaylistOptsSheet(BuildContext context, String playlistName) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(
                    MingCute.play_circle_fill,
                    color: Default_Theme.primaryColor1,
                    size: 28,
                  ),
                  title: const Text(
                    "Play",
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontFamily: "Unageo",
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final _list = await context
                        .read<LibraryItemsCubit>()
                        .getPlaylist(playlistName);
                    if (_list != null && _list.isNotEmpty) {
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .loadPlaylist(
                              MediaPlaylist(
                                  mediaItems: _list, albumName: playlistName),
                              doPlay: true);
                      SnackbarService.showMessage("Playing $playlistName");
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    MingCute.playlist_2_line,
                    color: Default_Theme.primaryColor1,
                    size: 28,
                  ),
                  title: const Text(
                    "Add Playlist to Queue",
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontFamily: "Unageo",
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final _list = await context
                        .read<LibraryItemsCubit>()
                        .getPlaylist(playlistName);
                    if (_list != null && _list.isNotEmpty) {
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .addQueueItems(_list);
                      SnackbarService.showMessage(
                          "Added $playlistName to Queue");
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    MingCute.share_2_fill,
                    color: Default_Theme.primaryColor1,
                    size: 28,
                  ),
                  title: const Text(
                    "Share Playlist",
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontFamily: "Unageo",
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    SnackbarService.showMessage(
                        "Preparing $playlistName for share");
                    final _tmpPath =
                        await BloomeeFileManager.exportPlaylist(playlistName);
                    _tmpPath != null
                        ? Share.shareXFiles([XFile(_tmpPath)])
                        : null;
                  },
                ),
                ListTile(
                  leading: const Icon(
                    MingCute.delete_2_fill,
                    color: Default_Theme.primaryColor1,
                    size: 28,
                  ),
                  title: const Text(
                    "Delete Playlist",
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontFamily: "Unageo",
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<LibraryItemsCubit>().removePlaylist(
                        MediaPlaylistDB(playlistName: playlistName));
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
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
