import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/smallPlaylistCard_widget.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
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
                      child: state.playlists.isNotEmpty
                          ? ListOfPlaylists(
                              state: state,
                            )
                          : Center(
                              child: SizedBox(
                                width: 100,
                                height: 50,
                                child: Text(
                                  "Get started by adding items to library!!",
                                  style: Default_Theme.secondoryTextStyle.merge(
                                      const TextStyle(
                                          color: Default_Theme.primaryColor2)),
                                ),
                              ),
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
          InkWell(
            onTap: () {
              createPlaylistBottomSheet(context);
            },
            child: const Icon(MingCute.add_fill,
                size: 25, color: Default_Theme.primaryColor1),
          ),
          InkWell(
            onTap: () {
              context.pushNamed(GlobalStrConsts.ImportMediaFromPlatforms);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(FontAwesome.file_import_solid,
                  size: 25, color: Default_Theme.primaryColor1),
            ),
          ),
        ],
      ),
    );
  }
}

class ListOfPlaylists extends StatefulWidget {
  LibraryItemsState state;
  ListOfPlaylists({super.key, required this.state});

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
              padding: const EdgeInsets.only(bottom: 8),
              child: Dismissible(
                key: ValueKey(widget.state.playlists[index].playlistName),
                background: Container(
                  color: Colors.red,
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(
                          MingCute.delete_3_line,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (DismissDirection direction) {
                  context.read<LibraryItemsCubit>().removePlaylist(
                      MediaPlaylistDB(
                          playlistName:
                              widget.state.playlists[index].playlistName ??
                                  "Null"));
                  setState(() {
                    widget.state.playlists.removeAt(index);
                  });
                },
                child: InkWell(
                  onTap: () => context
                      .pushNamed(GlobalStrConsts.playlistView, pathParameters: {
                    "playlistName":
                        widget.state.playlists[index].playlistName ?? "Liked"
                  }),
                  child: SmallPlaylistCard(
                      playListTitle:
                          widget.state.playlists[index].playlistName ??
                              "Unknown",
                      coverArt: Image(
                        image: widget.state.playlists[index].imageProvider!,
                        fit: BoxFit.fitHeight,
                      ),
                      playListsubTitle:
                          widget.state.playlists[index].subTitle ?? "Unknown"),
                ),
              ),
            );
          }
        });
  }
}
