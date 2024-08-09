import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/offline/offline_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OfflineCubit(libraryItemsCubit: context.read<LibraryItemsCubit>()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            customDiscoverBar(context), //AppBar
            SliverList(
                delegate: SliverChildListDelegate([
              BlocBuilder<OfflineCubit, OfflineState>(
                  builder: (context, state) {
                if (state is OfflineInitial) {
                  return const CircularProgressIndicator();
                } else if (state is OfflineEmpty) {
                  return const SignBoardWidget(
                    message: "No Downloads",
                    icon: FontAwesome.download_solid,
                  );
                } else {
                  return Column(
                    children: state.songs
                        .map((e) => SongCardWidget(
                              song: e,
                              showOptions: true,
                              delDownBtn: true,
                              onTap: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .loadPlaylist(
                                        MediaPlaylist(
                                            mediaItems: state.songs,
                                            playlistName: "Offline"),
                                        idx: state.songs.indexOf(e),
                                        doPlay: true);
                              },
                              onOptionsTap: () {
                                showMoreBottomSheet(context, e,
                                    showDelete: false);
                              },
                            ))
                        .toList(),
                  );
                }
              })
            ]))
          ],
        ),
        backgroundColor: Default_Theme.themeColor,
      ),
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Offline",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          // IconButton(
          //     onPressed: () {
          //       context.read<OfflineCubit>().getSongs();
          //     },
          //     icon: const Icon(MingCute.refresh_1_line)),
        ],
      ),
    );
  }
}
