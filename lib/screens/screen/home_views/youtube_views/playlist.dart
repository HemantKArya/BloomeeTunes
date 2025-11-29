// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:core';
import 'dart:developer';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/yt_music_model.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
  late Future<Map<dynamic, dynamic>?> data;
  late List<Map<dynamic, dynamic>> items;
  late List<MediaItemModel> mediaitems;

  Future<void> _loadData() async {
    final res = await data;
    if (res == null) {
      mediaitems = [];
      return;
    }
    items = res["songs"] as List<Map<dynamic, dynamic>>;
    mediaitems = ytmMapList2MediaItemList(items);
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
    data = YTMusic().getPlaylistFull(widget.id.replaceAll("youtube", ""));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: state == ConnectivityState.disconnected
              ? Scaffold(
                  appBar: AppBar(),
                  body: const Center(
                    child: SignBoardWidget(
                      message:
                          "No internet connection\nPlease connect to the internet.",
                      icon: MingCute.wifi_off_line,
                    ),
                  ),
                )
              : FutureBuilder(
                  future: _loadData(),
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              appBar: AppBar(),
                              body: const Center(
                                child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CircularProgressIndicator()),
                              ),
                            )
                          : snapshot.hasError
                              ? const CustomScrollView(
                                  slivers: [
                                    SliverAppBar(
                                      backgroundColor: Default_Theme.themeColor,
                                      surfaceTintColor:
                                          Default_Theme.themeColor,
                                    ),
                                    SliverFillRemaining(
                                      child: Center(
                                        child: SignBoardWidget(
                                          message:
                                              "Got Error while loading data",
                                          icon: MingCute.loading_line,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : CustomScrollView(
                                  slivers: [
                                    SliverAppBar(
                                      actions: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: IconButton(
                                            onPressed: () {
                                              Share.share(
                                                  "${widget.title} - ${widget.subtitle} \nhttps://youtube.com/playlist?list=${widget.id.replaceAll("youtube", "")}",
                                                  subject: "Youtube Playlist");
                                            },
                                            padding: const EdgeInsets.all(5),
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              MingCute.share_forward_line,
                                              color:
                                                  Default_Theme.primaryColor1,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ],
                                      backgroundColor: Default_Theme.themeColor,
                                      surfaceTintColor:
                                          Default_Theme.themeColor,
                                      // expandedHeight:
                                      //     (ResponsiveBreakpoints.of(
                                      //                 context)
                                      //             .isMobile
                                      //         ? MediaQuery.of(context)
                                      //                 .size
                                      //                 .height *
                                      //             0.27
                                      //         : MediaQuery.of(context)
                                      //                 .size
                                      //                 .width *
                                      //             0.18),
                                      floating: false,
                                      pinned: true,
                                      // flexibleSpace: FlexibleSpaceBar(
                                      //   background:
                                      // ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // mainAxisSize:
                                            //     MainAxisSize.min,

                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0, right: 8.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: SizedBox.square(
                                                    dimension:
                                                        ResponsiveBreakpoints
                                                                    .of(context)
                                                                .isMobile
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.22
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                    child: LoadImageCached(
                                                        imageUrl: formatImgURL(
                                                            widget.imgPath,
                                                            ImageQuality.low)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          widget.title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Default_Theme
                                                                .primaryColor1,
                                                          ).merge(Default_Theme
                                                                  .secondoryTextStyle),
                                                        ),
                                                      ),
                                                      Text(
                                                        widget.subtitle,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Default_Theme
                                                              .primaryColor2
                                                              .withValues(alpha: 0.8),
                                                        ).merge(Default_Theme
                                                            .secondoryTextStyle),
                                                      ),
                                                      Text(
                                                        "Youtube • ${(widget.type == 'playlist') ? 'Playlist' : 'Album'}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Default_Theme
                                                              .primaryColor2
                                                              .withValues(alpha: 0.8),
                                                        ).merge(Default_Theme
                                                            .secondoryTextStyle),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 6.0,
                                                                bottom: 6.0,
                                                                right: 10),
                                                        child: SizedBox(
                                                          height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height <
                                                                  700
                                                              ? 45
                                                              : MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.07,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.42,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            6.0),
                                                                child: Tooltip(
                                                                  message:
                                                                      "Shuffle & Play All",
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      SnackbarService.showMessage(
                                                                          "Shuffling & Playing All",
                                                                          duration:
                                                                              const Duration(seconds: 2));
                                                                      context
                                                                          .read<
                                                                              BloomeePlayerCubit>()
                                                                          .bloomeePlayer
                                                                          .loadPlaylist(
                                                                            MediaPlaylist(
                                                                              mediaItems: mediaitems,
                                                                              playlistName: "${widget.title} - Youtube",
                                                                            ),
                                                                            doPlay:
                                                                                true,
                                                                            shuffling:
                                                                                true,
                                                                          );
                                                                    },
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                    constraints:
                                                                        const BoxConstraints(),
                                                                    icon:
                                                                        const Icon(
                                                                      MingCute
                                                                          .shuffle_fill,
                                                                      color: Default_Theme
                                                                          .primaryColor1,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Tooltip(
                                                                message:
                                                                    "Play All",
                                                                child: StreamBuilder<
                                                                        String>(
                                                                    stream: context
                                                                        .watch<
                                                                            BloomeePlayerCubit>()
                                                                        .bloomeePlayer
                                                                        .queueTitle,
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .hasData &&
                                                                          snapshot.data ==
                                                                              "${widget.title} - Youtube") {
                                                                        return StreamBuilder<
                                                                                PlayerState>(
                                                                            stream:
                                                                                context.read<BloomeePlayerCubit>().bloomeePlayer.audioPlayer.playerStateStream,
                                                                            builder: (context, snapshot2) {
                                                                              if (snapshot2.hasData && (snapshot2.data?.playing ?? false)) {
                                                                                return PlayPauseButton(
                                                                                  onPause: () => context.read<BloomeePlayerCubit>().bloomeePlayer.pause(),
                                                                                  onPlay: () => context.read<BloomeePlayerCubit>().bloomeePlayer.play(),
                                                                                  isPlaying: true,
                                                                                  size: 45,
                                                                                );
                                                                              } else {
                                                                                return PlayPauseButton(
                                                                                  onPause: () => context.read<BloomeePlayerCubit>().bloomeePlayer.pause(),
                                                                                  onPlay: () => context.read<BloomeePlayerCubit>().bloomeePlayer.play(),
                                                                                  isPlaying: false,
                                                                                  size: 45,
                                                                                );
                                                                              }
                                                                            });
                                                                      } else {
                                                                        return PlayPauseButton(
                                                                          onPause: () => context
                                                                              .read<BloomeePlayerCubit>()
                                                                              .bloomeePlayer
                                                                              .pause(),
                                                                          onPlay:
                                                                              () {
                                                                            context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(MediaPlaylist(
                                                                                mediaItems: mediaitems,
                                                                                playlistName: "${widget.title} - Youtube"));
                                                                            context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                                                                          },
                                                                          size:
                                                                              45,
                                                                        );
                                                                      }
                                                                    }),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  left: 8,
                                                                ),
                                                                child: Tooltip(
                                                                  message:
                                                                      "Add to Library",
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      SnackbarService.showMessage(
                                                                          "Adding to Library",
                                                                          duration:
                                                                              const Duration(seconds: 2));
                                                                      await Future.forEach(
                                                                          mediaitems,
                                                                          (element) {
                                                                        BloomeeDBService.addMediaItem(
                                                                            MediaItem2MediaItemDB(element),
                                                                            "${widget.title} - Youtube");
                                                                      });
                                                                      SnackbarService.showMessage(
                                                                          "Added to Library",
                                                                          duration:
                                                                              const Duration(seconds: 2));
                                                                    },
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            2),
                                                                    constraints:
                                                                        const BoxConstraints(),
                                                                    icon:
                                                                        const Icon(
                                                                      FontAwesome
                                                                          .square_plus,
                                                                      color: Default_Theme
                                                                          .primaryColor1,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
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
                                    SliverPadding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 3),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return SongCardWidget(
                                              song: mediaitems[index],
                                              isWide: true,
                                              onOptionsTap: () {
                                                showMoreBottomSheet(
                                                  context,
                                                  mediaitems[index],
                                                  showSinglePlay: true,
                                                );
                                              },
                                              onTap: () {
                                                context
                                                    .read<BloomeePlayerCubit>()
                                                    .bloomeePlayer
                                                    .loadPlaylist(
                                                        MediaPlaylist(
                                                            mediaItems:
                                                                mediaitems,
                                                            playlistName:
                                                                "${widget.title} - Youtube"),
                                                        idx: index,
                                                        doPlay: true);
                                              },
                                            );
                                          },
                                          childCount: items.length,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    );
                    // }
                  }),
        );
      },
    );
  }
}
