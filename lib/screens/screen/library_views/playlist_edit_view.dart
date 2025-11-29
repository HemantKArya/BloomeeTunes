// Page for editing playlist title,description and reordering playlist items
import 'dart:developer';
import 'dart:ui';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class PlaylistEditView extends StatefulWidget {
  const PlaylistEditView({super.key});

  @override
  State<PlaylistEditView> createState() => _PlaylistEditViewState();
}

class _PlaylistEditViewState extends State<PlaylistEditView> {
  TextEditingController titleController = TextEditingController();
  // ValueNotifier isPlaylistExist = ValueNotifier<bool>(false);
  // ValueNotifier isTitleEmpty = ValueNotifier<bool>(false);
  List<MediaItemModel> mediaItems = [];
  List<int> mediaOrder = [];
  @override
  void initState() {
    // titleController.addListener(() {
    //   isPlaylistExist.value = context
    //       .read<LibraryItemsCubit>()
    //       .state
    //       .playlists
    //       .any((element) =>
    //           element.playlistName.toLowerCase() ==
    //           titleController.text.toLowerCase());
    //   if (titleController.text ==
    //       context.read<CurrentPlaylistCubit>().getTitle()) {
    //     isPlaylistExist.value = false;
    //   }

    //   isTitleEmpty.value = titleController.text.isEmpty;
    // });

    context.read<CurrentPlaylistCubit>().getItemOrder().then((value) {
      mediaOrder = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
        builder: (context, state) {
          titleController.text = state.mediaPlaylist.playlistName;
          mediaItems = state.mediaPlaylist.mediaItems;
          if (state is! CurrentPlaylistInitial &&
                  state is! CurrentPlaylistLoading ||
              state.mediaPlaylist.mediaItems.isNotEmpty) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  centerTitle: true,
                  surfaceTintColor: Default_Theme.themeColor,
                  foregroundColor: Default_Theme.primaryColor1,
                  backgroundColor: Default_Theme.themeColor,
                  title: Text("Edit Playlist",
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                          const TextStyle(
                              fontSize: 16,
                              color: Default_Theme.primaryColor1))),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                          onPressed: () {
                            // check if title is empty or playlist already exist
                            // check if item order is changed or not
                            if (mediaItems.length == mediaOrder.length &&
                                mediaItems.isNotEmpty &&
                                titleController.text.isNotEmpty) {
                              context
                                  .read<CurrentPlaylistCubit>()
                                  .updatePlaylist(
                                    mediaOrder,
                                  );
                              SnackbarService.showMessage("Playlist Updated!");
                            }
                            Navigator.of(context).pop();
                          },
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          icon: const Icon(MingCute.check_fill)),
                    )
                  ],
                ),
                // Text field for playlist title and description
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: TextField(
                //       textAlign: TextAlign.center,
                //       cursorWidth: 4,
                //       controller: titleController,
                //       cursorOpacityAnimates: true,
                //       cursorRadius: const Radius.circular(10),
                //       style: Default_Theme.secondoryTextStyleMedium.merge(
                //           const TextStyle(
                //               fontSize: 22,
                //               color: Default_Theme.primaryColor1)),
                //       decoration: const InputDecoration(
                //         hintText: "Playlist Title",
                //         hintStyle: Default_Theme.secondoryTextStyleMedium,
                //         isDense: true,
                //         labelStyle: Default_Theme.secondoryTextStyleMedium,
                //       ),
                //     ),
                //   ),
                // ),
                // // Text to show if this playlist is already exist or not
                // SliverToBoxAdapter(
                //   child: ValueListenableBuilder(
                //     valueListenable: isPlaylistExist,
                //     builder: (context, value, child) {
                //       return value
                //           ? Text(
                //               "Playlist already exist",
                //               textAlign: TextAlign.center,
                //               style: Default_Theme.secondoryTextStyleMedium
                //                   .merge(const TextStyle(
                //                       fontSize: 14, color: Colors.redAccent)),
                //             )
                //           : const SizedBox();
                //     },
                //   ),
                // ),

                // // Text to show if title is empty
                // SliverToBoxAdapter(
                //   child: ValueListenableBuilder(
                //     valueListenable: isTitleEmpty,
                //     builder: (context, value, child) {
                //       return value
                //           ? Text(
                //               "Title can't be empty",
                //               textAlign: TextAlign.center,
                //               style: Default_Theme.secondoryTextStyleMedium
                //                   .merge(const TextStyle(
                //                       fontSize: 14, color: Colors.redAccent)),
                //             )
                //           : const SizedBox();
                //     },
                //   ),
                // ),
                // Text info about how to reorder the playlist items by long press
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Long press to reorder.",
                      textAlign: TextAlign.left,
                      style: Default_Theme.secondoryTextStyleMedium.merge(
                          TextStyle(
                              fontSize: 14,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.6))),
                    ),
                  ),
                ),
                // Sliver list of playlist items
                SliverPlaylistItems(
                  state: state,
                  updatePlaylistItems: (p0, p1) {
                    if (p0.length == p1.length &&
                        p0.length == mediaItems.length) {
                      mediaItems = p0;
                      mediaOrder = p1;
                      log("New Order: $mediaOrder");
                    }
                  },
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SliverPlaylistItems extends StatefulWidget {
  const SliverPlaylistItems(
      {Key? key, required this.state, this.updatePlaylistItems})
      : super(key: key);

  final CurrentPlaylistState state;
  // Callback function to update the playlistItems
  final Function(List<MediaItemModel>, List<int>)? updatePlaylistItems;

  @override
  State<SliverPlaylistItems> createState() => _SliverPlaylistItemsState();
}

class _SliverPlaylistItemsState extends State<SliverPlaylistItems> {
  List<MediaItemModel> mediaItems = [];
  List<int> mediaOrder = [];

  @override
  void initState() {
    setState(() {
      mediaItems = widget.state.mediaPlaylist.mediaItems;
    });
    context.read<CurrentPlaylistCubit>().getItemOrder().then((value) {
      mediaOrder = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          return ReorderableDelayedDragStartListener(
            key: ValueKey(mediaItems[index].id),
            index: index,
            child: SongCardWidget(
              song: mediaItems[index],
              showOptions: false,
            ),
          );
        },
        itemExtent: 70,
        itemCount: mediaItems.length,
        proxyDecorator: proxyDecorator,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final MediaItemModel item = mediaItems.removeAt(oldIndex);
            mediaItems.insert(newIndex, item);
            final int itemId = mediaOrder.removeAt(oldIndex);
            mediaOrder.insert(newIndex, itemId);
            if (widget.updatePlaylistItems != null) {
              widget.updatePlaylistItems!(mediaItems, mediaOrder);
            }
          });
        },
      ),
    );
  }
}

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: const Color.fromARGB(255, 0, 48, 66),
        borderRadius: BorderRadius.circular(12),
        shadowColor: Default_Theme.themeColor,
        child: child,
      );
    },
    child: child,
  );
}
