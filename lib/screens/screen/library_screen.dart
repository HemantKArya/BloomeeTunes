import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/playlist_tile.dart';
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
          BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
            builder: (context, state) {
              if (state is LibraryItemsInitial) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is! LibraryItemsInitial) {
                return ListOfPlaylists(state: state);
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: SignBoardWidget(
                      message: "No Playlists Found!",
                      icon: MingCute.playlist_fill,
                    ),
                  ),
                );
              }
            },
          ),
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
    return SliverList.builder(
        // itemExtent: 80,
        itemCount: widget.state.playlists.length,
        itemBuilder: (context, index) {
          if (widget.state.playlists[index].playlistName == "recently_played" ||
              widget.state.playlists[index].playlistName ==
                  GlobalStrConsts.downloadPlaylist) {
            return const SizedBox.shrink();
          } else {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
                left: 8,
                right: 8,
              ),
              child: InkWell(
                onSecondaryTap: () {
                  showPlaylistOptsExtSheet(
                      context, widget.state.playlists[index].playlistName);
                },
                splashColor: Default_Theme.primaryColor2.withOpacity(0.1),
                hoverColor: Colors.white.withOpacity(0.05),
                highlightColor: Default_Theme.primaryColor2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                onLongPress: () {
                  showPlaylistOptsExtSheet(
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
                    coverArt: LoadImageCached(
                        imageUrl: formatImgURL(
                            widget.state.playlists[index].coverImgUrl
                                .toString(),
                            ImageQuality.low)),
                    playListsubTitle:
                        widget.state.playlists[index].subTitle ?? "Unknown"),
              ),
            );
          }
        });
  }
}
