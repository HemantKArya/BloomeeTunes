import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/downloading_item.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/utils/dload.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<DownloaderCubit, DownloaderState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                customDiscoverSliverBar(context),
                if (state.downloads.isEmpty && state.downloaded.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: SignBoardWidget(
                        message: "No Downloads",
                        icon: FontAwesome.download_solid,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // ...[
                        //   _buildDownloadingItem(
                        //     context,
                        //     DownloadProgress(
                        //       status: DownloadStatus(
                        //         state: DownloadState.completed,
                        //         filePath: "nothing",
                        //         progress: 0.5,
                        //         retryAttempt: 1,
                        //       ),
                        //       task: DownloadTask(
                        //         url: "https:///somthing",
                        //         originalUrl: "https//somthing",
                        //         fileName: "Just a sample title",
                        //         targetPath: "computerpc//",
                        //         maxRetries: 3,
                        //         song: MediaItemModel(
                        //             id: "hi",
                        //             title: "Tere liye u xiya m",
                        //             artUri: Uri.parse(
                        //                 "https://dribbble.com/tags/download-manager")),
                        //       ),
                        //     ),
                        //   )
                        // ],
                        ...state.downloads.map((download) =>
                            DownloadingCardWidget(downloadProgress: download)),
                        ...state.downloaded.map((song) => SongCardWidget(
                              song: song,
                              showOptions: true,
                              delDownBtn: true,
                              onTap: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .loadPlaylist(
                                        MediaPlaylist(
                                            mediaItems: state.downloaded,
                                            playlistName: "Offline"),
                                        idx: state.downloaded.indexOf(song),
                                        doPlay: true);
                              },
                              onOptionsTap: () {
                                showMoreBottomSheet(context, song,
                                    showDelete: false);
                              },
                            )),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar customDiscoverSliverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Offline",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
        ],
      ),
    );
  }
}
