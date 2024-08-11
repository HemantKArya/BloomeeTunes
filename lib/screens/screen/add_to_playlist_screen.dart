import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/createPlaylist_bottomsheet.dart';
import 'package:Bloomee/screens/widgets/playlist_tile.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/routes_and_consts/global_conts.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

class AddToPlaylistScreen extends StatefulWidget {
  const AddToPlaylistScreen({super.key});

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  List<PlaylistItemProperties> playlistsItems = List.empty(growable: true);

  List<PlaylistItemProperties> filteredPlaylistsItems =
      List.empty(growable: true);
  final TextEditingController _searchController = TextEditingController();

  Future<void> searchFilter(String query) async {
    if (query.length > 0) {
      setState(() {
        filteredPlaylistsItems = playlistsItems.where((element) {
          return element.playlistName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        filteredPlaylistsItems = playlistsItems;
      });
    }
  }

  MediaItemModel currentMediaModel = mediaItemModelNull;
  @override
  Widget build(BuildContext context) {
    // context.read<AddToPlaylistCubit>().getAndEmitPlaylists();
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        title: Text(
          'Add to Playlist',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
            builder: (context, state) {
              if (state is AddToPlaylistInitial) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Default_Theme.accentColor2,
                ));
              } else {
                if (state.mediaItemModel != mediaItemModelNull) {
                  currentMediaModel = state.mediaItemModel;
                  return Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: LoadImageCached(
                                    imageUrl:
                                        state.mediaItemModel.artUri.toString()),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      state.mediaItemModel.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(const TextStyle(
                                              color:
                                                  Default_Theme.primaryColor2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                    ),
                                  ),
                                  Text(
                                    state.mediaItemModel.artist ?? "Unknown",
                                    maxLines: 2,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(TextStyle(
                                            color: Default_Theme.primaryColor2
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        color: Default_Theme.accentColor2,
                        thickness: 3,
                        height: 20,
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                searchFilter(value.toString());
              },
              style: TextStyle(
                  color: Default_Theme.primaryColor1.withOpacity(0.55)),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Default_Theme.primaryColor2.withOpacity(0.07),
                  contentPadding: const EdgeInsets.only(top: 20, left: 15),
                  hintText: "Search you playlist..",
                  hintStyle: TextStyle(
                      color: Default_Theme.primaryColor1.withOpacity(0.4),
                      fontFamily: "Gilroy"),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(50)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Default_Theme.primaryColor1.withOpacity(0.7)),
                      borderRadius: BorderRadius.circular(50))),
            ),
          ),
          Expanded(
            child: BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
              builder: (context, state) {
                if (state is LibraryItemsInitial) {
                  return const SignBoardWidget(
                      message: "No Playlists Yet",
                      icon: MingCute.playlist_line);
                } else {
                  playlistsItems = state.playlists;
                  final finalList = filteredPlaylistsItems.isEmpty ||
                          _searchController.text.isEmpty
                      ? playlistsItems
                      : filteredPlaylistsItems;
                  return ListView.builder(
                    itemCount: finalList.length,
                    itemBuilder: (context, index) {
                      if (finalList[index].playlistName == "recently_played" ||
                          finalList[index].playlistName ==
                              GlobalStrConsts.downloadPlaylist) {
                        return const SizedBox();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, left: 10),
                          child: InkWell(
                            onTap: () {
                              if (currentMediaModel != mediaItemModelNull) {
                                context.read<LibraryItemsCubit>().addToPlaylist(
                                    currentMediaModel,
                                    MediaPlaylistDB(
                                      playlistName:
                                          finalList[index].playlistName,
                                    ));
                                context.pop(context);
                              }
                            },
                            child: SmallPlaylistCard(
                                playListTitle: finalList[index].playlistName,
                                coverArt: LoadImageCached(
                                    imageUrl:
                                        finalList[index].coverImgUrl ?? "null"),
                                playListsubTitle:
                                    finalList[index].subTitle ?? "Unverified"),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        icon: const Icon(
          MingCute.add_fill,
          size: 25,
          color: Default_Theme.primaryColor1,
        ),
        onPressed: () {
          createPlaylistBottomSheet(context);
        },
        label: Text(
          "Create New Playlist",
          style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
              color: Default_Theme.primaryColor1,
              fontWeight: FontWeight.bold,
              fontSize: 15)),
        ),
      ),
    );
  }
}
