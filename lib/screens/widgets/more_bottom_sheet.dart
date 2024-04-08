import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_card_widget.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void showMoreBottomSheet(
  BuildContext context,
  MediaItemModel song, {
  bool showDelete = false,
  VoidCallback? onDelete,
}) {
  bool? isDownloaded;
  BloomeeDBService.getDownloadDB(song).then((value) {
    if (value != null) {
      isDownloaded = true;
    } else {
      isDownloaded = false;
    }
  });
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
              ListTile(
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
                      .addQueueItem(song, doPlay: false);
                  SnackbarService.showMessage("Added to Next in Queue",
                      duration: const Duration(seconds: 2));
                },
              ),
              ListTile(
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
                      .addQueueItem(song, atLast: true, doPlay: false);
                  SnackbarService.showMessage("Added to Queue",
                      duration: const Duration(seconds: 2));
                },
              ),
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
                  context.read<BloomeeDBCubit>().addMediaItemToPlaylist(
                      song, MediaPlaylistDB(playlistName: "Liked"));
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
                  context.read<AddToPlaylistCubit>().setMediaItemModel(song);
                  context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
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
                  final tmpPath = await BloomeeFileManager.exportMediaItem(
                      MediaItem2MediaItemDB(song));
                  tmpPath != null ? Share.shareXFiles([XFile(tmpPath)]) : null;
                },
              ),
              ListTile(
                leading: const Icon(
                  MingCute.clipboard_line,
                  color: Default_Theme.primaryColor1,
                  size: 28,
                ),
                title: const Text(
                  'Copy to Clipboard',
                  style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(
                      ClipboardData(text: "${song.title} by ${song.artist}"));
                  SnackbarService.showMessage("Copied to clipboard",
                      duration: const Duration(seconds: 2));
                },
              ),
              (isDownloaded != null && isDownloaded == true)
                  ? ListTile(
                      leading: const Icon(
                        MingCute.check_circle_line,
                        color: Default_Theme.primaryColor1,
                        size: 28,
                      ),
                      title: const Text(
                        'Already Downloaded',
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
                  launchUrl(Uri.parse(song.extras?['perma_url']));
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
