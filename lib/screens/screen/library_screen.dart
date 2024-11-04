import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/libitem_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial && state.artists.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                        itemBuilder: (context, index) => SizedBox(
                          height: 80,
                          child: LibItemCard(
                            title: state.artists[index].name,
                            coverArt: state.artists[index].imageUrl,
                            subtitle:
                                'Artist - ${state.artists[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.artists[index].source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
                            type: LibItemTypes.artist,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArtistView(
                                          artist: state.artists[index],
                                        )),
                              );
                            },
                          ),
                        ),
                        itemCount: state.artists.length,
                      );
              },
            ),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial && state.albums.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                        itemBuilder: (context, index) => SizedBox(
                          height: 80,
                          child: LibItemCard(
                            title: state.albums[index].name,
                            coverArt: state.albums[index].imageURL,
                            subtitle:
                                'Album - ${state.albums[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.albums[index].source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
                            type: LibItemTypes.album,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AlbumView(
                                          album: state.albums[index],
                                        )),
                              );
                            },
                          ),
                        ),
                        itemCount: state.albums.length,
                      );
              },
            ),
            BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                return (state is LibraryItemsInitial &&
                        state.playlistsOnl.isEmpty)
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverList.builder(
                        itemBuilder: (context, index) => SizedBox(
                          height: 80,
                          child: LibItemCard(
                            title: state.playlistsOnl[index].name,
                            coverArt: state.playlistsOnl[index].imageURL,
                            subtitle:
                                'Playlist - ${state.playlistsOnl[index].source == "ytm" ? SourceEngine.eng_YTM.value : (state.playlistsOnl[index].source == 'saavn' ? SourceEngine.eng_JIS.value : SourceEngine.eng_YTV.value)}',
                            type: LibItemTypes.onlPlaylist,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OnlPlaylistView(
                                          playlist: state.playlistsOnl[index],
                                          sourceEngine: state
                                                      .playlistsOnl[index]
                                                      .source ==
                                                  "ytm"
                                              ? SourceEngine.eng_YTM
                                              : (state.playlistsOnl[index]
                                                          .source ==
                                                      'saavn'
                                                  ? SourceEngine.eng_JIS
                                                  : SourceEngine.eng_YTV),
                                        )),
                              );
                            },
                          ),
                        ),
                        itemCount: state.playlistsOnl.length,
                      );
              },
            ),
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
          Text("Library",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          OverflowBar(
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
            return LibItemCard(
                onSecondaryTap: () {
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
                onLongPress: () {
                  showPlaylistOptsExtSheet(
                      context, widget.state.playlists[index].playlistName);
                },
                title: widget.state.playlists[index].playlistName,
                coverArt: widget.state.playlists[index].coverImgUrl.toString(),
                subtitle: widget.state.playlists[index].subTitle ?? "Unknown");
          }
        });
  }
}
