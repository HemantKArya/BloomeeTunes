import 'dart:io';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void showMoreBottomSheet(
  BuildContext context,
  MediaItemModel song, {
  bool showDelete = false,
  bool showSinglePlay = false,
  bool showAddToQueue = true,
  bool showPlayNext = true,
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
                            .loadPlaylist(MediaPlaylist(mediaItems: [song], playlistName: song.title),
                                doPlay: true);
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
                  context.read<BloomeeDBCubit>().addMediaItemToPlaylist(
                      song, MediaPlaylistDB(playlistName: "Liked"));
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
              // Modified Share option: ask JSON or MP3
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

                  // Ask user which format to share
                  final choice = await showDialog<String?>(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Share as'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'json'),
                          child: const Text('JSON (Bloomee file)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, 'mp3'),
                          child: const Text('MP3 (only if downloaded)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );

                  if (choice == null) return;

                  if (choice == 'json') {
                    SnackbarService.showMessage("Preparing ${song.title} for share.");
                    final tmpPath = await ImportExportService.exportMediaItem(
                        MediaItem2MediaItemDB(song));
                    if (tmpPath != null) {
                      await Share.shareXFiles([XFile(tmpPath)]);
                    } else {
                      SnackbarService.showMessage("Failed to prepare JSON file for sharing.");
                    }
                  } else if (choice == 'mp3') {
                    SnackbarService.showMessage("Preparing ${song.title} for MP3 share.");
                    final download = await BloomeeDBService.getDownloadDB(song);
                    if (download != null) {
                      final fullPath = '${download.filePath}/${download.fileName}';
                      final file = File(fullPath);
                      if (await file.exists()) {
                        await Share.shareXFiles([XFile(fullPath)]);
                      } else {
                        // DB record exists but file missing
                        SnackbarService.showMessage(
                            "MP3 file not found on disk. Try downloading again.");
                      }
                    } else {
                      // Not downloaded — choose whether to trigger download or ask user to download first.
                      final shouldDownload = await showDialog<bool?>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('MP3 not available'),
                          content: const Text(
                              'This song is not downloaded. Download it now and share once complete?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Download'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDownload == true) {
                        // Kick off download (user will be notified when it completes)
                        context.read<DownloaderCubit>().downloadSong(song);
                        SnackbarService.showMessage("Download started. Share after it finishes.");
                      } else {
                        SnackbarService.showMessage("MP3 share cancelled.");
                      }
                    }
                  }
                },
              ),
              (isDownloaded != null && isDownloaded == true)
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
                  final url = song.extras?['perma_url'];
                  if (url != null && url.isNotEmpty) {
                    launchUrl(Uri.parse(url));
                  } else {
                    SnackbarService.showMessage('Original link not available');
                  }
                },
              ),
              // other options may follow...
            ],
          ),
        );
      });
}
