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
  bool? isDownloaded =
      context.read<DownloaderCubit>().isDownloaded(song.id) ? true : false;
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        return Container(
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
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 8, left: 5, right: 4),
                child: SongCardWidget(
                  song: song,
                  showOptions: false,
                  showCopyBtn: true,
                  showInfoBtn: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: Opacity(
                  opacity: 0.5,
                  child: Divider(
                    thickness: 2,
                    color: Default_Theme.primaryColor1,
                  ),
                ),
              ),
              (showSinglePlay)
                  ? ListTile(
                      leading: const Icon(
                        MingCute.play_circle_fill,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Play with Mix',
                        style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontFamily: "Unageo",
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .updateQueueTracks([song], doPlay: true);
                        SnackbarService.showMessage("Playing ${song.title}",
                            duration: const Duration(seconds: 2));
                      },
                    )
                  : const SizedBox.shrink(),
              (showPlayNext)
                  ? ListTile(
                      leading: const Icon(
                        MingCute.square_arrow_right_line,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Play Next',
                        style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontFamily: "Unageo",
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .addPlayNextTrack(song);
                        SnackbarService.showMessage("Added to Next in Queue",
                            duration: const Duration(seconds: 2));
                      },
                    )
                  : const SizedBox.shrink(),
              (showAddToQueue)
                  ? ListTile(
                      leading: const Icon(
                        MingCute.playlist_2_line,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Add to Queue',
                        style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontFamily: "Unageo",
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .addQueueTracks([song]);
                        SnackbarService.showMessage("Added to Queue",
                            duration: const Duration(seconds: 2));
                      },
                    )
                  : const SizedBox.shrink(),
              ListTile(
                leading: const Icon(
                  MingCute.heart_fill,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Add to Favorites',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<LibraryItemsCubit>().setTrackLiked(song, true);
                  SnackbarService.showMessage(
                      "${song.title} is added to Liked!!");
                  // SnackbarService.showMessage("Added to Favorites",
                  //     duration: const Duration(seconds: 2));
                },
              ),
              ListTile(
                leading: const Icon(
                  MingCute.add_circle_fill,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AddToPlaylistCubit>().setTrack(song);
                  context.pushNamed(RoutePaths.addToPlaylistScreen);
                },
              ),
              ListTile(
                leading: const Icon(
                  MingCute.search_2_line,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Smart Replace',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showSmartReplaceDialog(context, song);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.share,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Share',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  SnackbarService.showMessage(
                      "Preparing ${song.title} for share.");
                  // TODO: Implement Track-based export
                  // final tmpPath = await ImportExportService.exportMediaItem(...);
                  // tmpPath != null ? Share.shareXFiles([XFile(tmpPath)]) : null;
                  if (song.url != null && song.url!.isNotEmpty) {
                    Share.share(song.url!);
                  }
                },
              ),
              (isDownloaded == true)
                  ? ListTile(
                      leading: const Icon(
                        Icons.offline_pin_rounded,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Available Offline',
                        style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontFamily: "Unageo",
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // context.read<DownloaderCubit>().downloadSong(song);
                      },
                    )
                  : ListTile(
                      leading: const Icon(
                        MingCute.download_2_fill,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Download',
                        style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontFamily: "Unageo",
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<DownloaderCubit>().downloadSong(song);
                      },
                    ),
              // : const SizedBox.shrink(),
              ListTile(
                leading: const Icon(
                  MingCute.external_link_line,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Open original link',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse(song.url ?? ''));
                },
              ),
              Visibility(
                visible: showDelete,
                child: ListTile(
                  leading: const Icon(
                    MingCute.delete_2_fill,
                    color: Default_Theme.primaryColor1,
                    size: 28,
                  ),
                  title: const Text(
                    'Delete',
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontFamily: "Unageo",
                        fontSize: 17,
                        fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (onDelete != null) onDelete();
                  },
                ),
              ),
            ],
          ),
        );
      });
}
