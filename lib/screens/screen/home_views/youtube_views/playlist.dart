// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:core';
import 'dart:developer';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/screens/widgets/import_playlist.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:async/async.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/repository/Youtube/yt_music_api.dart';
import 'package:Bloomee/screens/screen/home_views/youtube_views/yt_song_tile.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';

class YoutubePlaylist extends StatefulWidget {
  final String imgPath;
  final String title;
  final String subtitle;
  final String type;
  final String id;
  const YoutubePlaylist({
    Key? key,
    required this.imgPath,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.id,
  }) : super(key: key);

  @override
  State<YoutubePlaylist> createState() => _YoutubePlaylistState();
}

class _YoutubePlaylistState extends State<YoutubePlaylist> {
  late Future<Map<dynamic, dynamic>> data;
  late List<Map<dynamic, dynamic>> items;
  Map<int, MediaItemModel> songList = {};
  CancelableOperation<MediaItemModel?> getMediaOps =
      CancelableOperation.fromFuture(Future.value());

  Future<void> _loadData() async {
    final res = await data;
    items = res["songs"] as List<Map<dynamic, dynamic>>;
  }

  Future<MediaItemModel?> fetchSong(String id, String imgUrl) async {
    log("Fetching: $id", name: "YoutubePlaylist");
    final song = await YouTubeServices()
        .formatVideoFromId(id: id.replaceAll("youtube", ""));
    if (song != null) {
      return fromYtVidSongMap2MediaItem(song)..artUri = Uri.parse(imgUrl);
    }
    return null;
  }

  @override
  void initState() {
    data = YtMusicService()
        .getPlaylistDetails(widget.id.replaceAll("youtube", ""));
    super.initState();
  }

  @override
  void dispose() {
    getMediaOps.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: state == ConnectivityState.disconnected
              ? const Center(
                  child: SignBoardWidget(
                    message:
                        "No internet connection\nPlease connect to the internet.",
                    icon: MingCute.wifi_off_line,
                  ),
                )
              : FutureBuilder(
                  future: _loadData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      log(snapshot.error.toString());
                      return const Center(
                        child: SignBoardWidget(
                          message: "Error loading data",
                          icon: MingCute.loading_line,
                        ),
                      );
                    } else {
                      return CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            backgroundColor: Default_Theme.themeColor,
                            surfaceTintColor: Default_Theme.themeColor,
                            expandedHeight: 230,
                            floating: false,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                height: 180,
                                                width: 180,
                                                child: loadImageCached(
                                                    widget.imgPath),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                widget.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Default_Theme
                                                      .primaryColor1,
                                                ).merge(Default_Theme
                                                    .secondoryTextStyle),
                                              ),
                                              Text(
                                                widget.subtitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Default_Theme
                                                      .primaryColor2
                                                      .withOpacity(0.8),
                                                ).merge(Default_Theme
                                                    .secondoryTextStyle),
                                              ),
                                              Text(
                                                "Youtube • ${(widget.type == 'playlist') ? 'Playlist' : 'Album'}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Default_Theme
                                                      .primaryColor2
                                                      .withOpacity(0.8),
                                                ).merge(Default_Theme
                                                    .secondoryTextStyle),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, right: 10),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 18,
                                                                vertical: 5),
                                                        backgroundColor:
                                                            Default_Theme
                                                                .accentColor2,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (context) =>
                                                              ImporterDialogWidget(
                                                                  strm: ExternalMediaImporter
                                                                      .ytPlaylistImporter(
                                                            "https://youtube.com/playlist?list=${widget.id.replaceAll("youtube", "")}",
                                                          )),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 6),
                                                            child: Icon(
                                                              size: 20,
                                                              MingCute
                                                                  .bookmark_fill,
                                                              color: Default_Theme
                                                                  .primaryColor2,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Save",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Default_Theme
                                                                  .primaryColor2,
                                                            ).merge(Default_Theme
                                                                    .secondoryTextStyle),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Share.share(
                                                            "${widget.title} - ${widget.subtitle} \nhttps://youtube.com/playlist?list=${widget.id.replaceAll("youtube", "")}",
                                                            subject:
                                                                "Youtube Playlist");
                                                      },
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      constraints:
                                                          const BoxConstraints(),
                                                      icon: const Icon(
                                                        MingCute
                                                            .share_forward_line,
                                                        color: Default_Theme
                                                            .primaryColor1,
                                                        size: 30,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          SliverList.list(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 20, bottom: 5),
                                child: Text("Songs",
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(const TextStyle(
                                            color: Default_Theme.accentColor2,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            height: 1.5))),
                              ),
                            ],
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return YtSongTile(
                                  rectangularImage: true,
                                  title: items[index]["title"]!,
                                  subtitle: items[index]["subtitle"]!,
                                  imgUrl: (items[index]["image"]! as String)
                                      .replaceAll("w400-h400", "w100-h100"),
                                  id: items[index]["id"]!,
                                  permalink: items[index]["perma_url"]!,
                                  onOpts: () {
                                    SnackbarService.showMessage(
                                        "Getting song information...",
                                        loading: true);
                                    fetchSong(items[index]["id"]!,
                                            items[index]["image"]!)
                                        .then((value) {
                                      SnackbarService.showMessage(
                                        "Song information ready!",
                                      );
                                      if (value != null) {
                                        showMoreBottomSheet(context, value);
                                      }
                                    }).onError((error, stackTrace) {
                                      log("Error: $error",
                                          name: "YoutubePlaylist");
                                      SnackbarService.showMessage(
                                          "Error getting song information.");
                                    });
                                  },
                                  onTap: () async {
                                    SnackbarService.showMessage(
                                        "Loading song...",
                                        loading: true);
                                    await getMediaOps.cancel();

                                    if (songList[index] == null) {
                                      getMediaOps =
                                          CancelableOperation.fromFuture(
                                        fetchSong(items[index]["id"]!,
                                            items[index]["image"]!),
                                        onCancel: () {
                                          log("skipping....",
                                              name: "YoutubePlaylist");
                                          return;
                                        },
                                      );
                                      getMediaOps.value.then(
                                        (value) {
                                          SnackbarService.showMessage(
                                            "Song is ready!",
                                          );
                                          if (value != null) {
                                            log("Added: ${value.title}",
                                                name: "YoutubePlaylist");
                                            songList[index] = value;
                                            context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .addQueueItem(value,
                                                    doPlay: true);
                                          }
                                        },
                                      ).onError((error, stackTrace) {
                                        log("Skipped:",
                                            error: error.toString(),
                                            name: "YoutubePlaylist");
                                      });
                                    } else {
                                      SnackbarService.showMessage(
                                        "Playing song.",
                                      );
                                      context
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .addQueueItem(songList[index]!,
                                              doPlay: true);
                                    }
                                  },
                                );
                              },
                              childCount: items.length,
                            ),
                          ),
                        ],
                      );
                    }
                  }),
        );
      },
    );
  }
}
