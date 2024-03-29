import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/smallPlaylistCard_widget.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          customDiscoverBar(context), //AppBar
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: state != LibraryItemsInitial()
                          ? ListOfPlaylists(
                              state: state,
                            )
                          : const SignBoardWidget(
                              message: "No Playlists Yet\nCreate One Now!",
                              icon: MingCute.playlist_line,
                            ),
                    );
                  },
                ),
              ),
            )
          ]))
        ],
      ),
      backgroundColor: Default_Theme.themeColor,
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
          Text("Library",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            children: [
              IconButton(
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  onPressed: () {
                    createPlaylistBottomSheet(context);
                  },
                  icon: const Icon(MingCute.add_fill,
                      size: 25, color: Default_Theme.primaryColor1)),
              IconButton(
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  onPressed: () {
                    context.pushNamed(GlobalStrConsts.ImportMediaFromPlatforms);
                  },
                  icon: const Icon(FontAwesome.file_import_solid,
                      size: 25, color: Default_Theme.primaryColor1))
            ],
          ),
        ],
      ),
    );
  }
}

class ListOfPlaylists extends StatefulWidget {
  final LibraryItemsState state;
  const ListOfPlaylists({super.key, required this.state});

  @override
  State<ListOfPlaylists> createState() => _ListOfPlaylistsState();
}

class _ListOfPlaylistsState extends State<ListOfPlaylists> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.state.playlists.length,
        itemBuilder: (context, index) {
          if (widget.state.playlists[index].playlistName == "recently_played") {
            return const SizedBox();
          } else {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: InkWell(
                splashColor: Default_Theme.accentColor1.withOpacity(0.2),
                hoverColor: Default_Theme.accentColor2.withOpacity(0.1),
                highlightColor: Default_Theme.accentColor2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                onLongPress: () {
                  showPlaylistOptsSheet(
                      context, widget.state.playlists[index].playlistName);
                },
                onTap: () {
                  context.read<CurrentPlaylistCubit>().setupPlaylist(
                      widget.state.playlists[index].playlistName);
                  context.pushNamed(
                    GlobalStrConsts.playlistView,
                  );
                },
                child: SmallPlaylistCard(
                    playListTitle: widget.state.playlists[index].playlistName,
                    coverArt: loadImageCached(
                        widget.state.playlists[index].coverImgUrl.toString()),
                    playListsubTitle:
                        widget.state.playlists[index].subTitle ?? "Unknown"),
              ),
            );
          }
        });
  }
}
