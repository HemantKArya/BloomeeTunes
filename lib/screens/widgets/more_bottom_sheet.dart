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
                      title: Text(
                        AppLocalizations.of(context)!.playerPlayWithMix,
                        style: const TextStyle(
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
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarNowPlaying(song.title),
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
                      title: Text(
                        AppLocalizations.of(context)!.playerPlayNext,
                        style: const TextStyle(
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
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!
                                .snackbarAddedToNextQueue,
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
                      title: Text(
                        AppLocalizations.of(context)!.playerAddToQueue,
                        style: const TextStyle(
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
                        SnackbarService.showMessage(
                            AppLocalizations.of(context)!.snackbarAddedToQueue,
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
                title: Text(
                  AppLocalizations.of(context)!.playerAddToFavorites,
                  style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<LibraryItemsCubit>().setTrackLiked(song, true);
                  SnackbarService.showMessage(AppLocalizations.of(context)!
                      .snackbarAddedToLiked(song.title));
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
                title: Text(
                  AppLocalizations.of(context)!.menuAddToPlaylist,
                  style: const TextStyle(
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
                title: Text(
                  AppLocalizations.of(context)!.menuSmartReplace,
                  style: const TextStyle(
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
                title: Text(
                  AppLocalizations.of(context)!.menuShare,
                  style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  SnackbarService.showMessage(AppLocalizations.of(context)!
                      .menuSharePreparing(song.title));
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
                      title: Text(
                        AppLocalizations.of(context)!.menuAvailableOffline,
                        style: const TextStyle(
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
                      title: Text(
                        AppLocalizations.of(context)!.menuDownload,
                        style: const TextStyle(
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
                title: Text(
                  AppLocalizations.of(context)!.menuOpenOriginalLink,
                  style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: "Unageo",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                onTap: () async {
                  final l10n = AppLocalizations.of(context)!;
                  Navigator.pop(context);
                  final url = song.url;
                  if (url == null || url.isEmpty) return;
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {
                    SnackbarService.showMessage(l10n.menuOpenLinkFailed);
                  }
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
                  title: Text(
                    AppLocalizations.of(context)!.menuDeleteTrack,
                    style: const TextStyle(
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
