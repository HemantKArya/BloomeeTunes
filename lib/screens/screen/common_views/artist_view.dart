import 'package:Bloomee/blocs/artist_view/artist_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/source_engines.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistView extends StatefulWidget {
  final ArtistModel artist;
  const ArtistView({super.key, required this.artist});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late ArtistCubit artistCubit;
  @override
  void initState() {
    artistCubit = ArtistCubit(
      artist: widget.artist,
      sourceEngine: widget.artist.source == 'saavn'
          ? SourceEngine.eng_JIS
          : SourceEngine.eng_YTM,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<ArtistCubit, ArtistState>(
          bloc: artistCubit,
          builder: (context, state) {
            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight:
                        ResponsiveBreakpoints.of(context).isMobile ? 220 : 250,
                    flexibleSpace:
                        LayoutBuilder(builder: (context, constraints) {
                      return FlexibleSpaceBar(
                        background: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 34,
                            bottom: 8,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight,
                              minWidth: 350,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    child: Hero(
                                        tag: widget.artist.sourceId,
                                        child: ClipOval(
                                          child: LoadImageCached(
                                            imageUrl: formatImgURL(
                                                widget.artist.imageUrl,
                                                ImageQuality.medium),
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.artist.name,
                                          maxLines: 3,
                                          style: Default_Theme
                                              .secondoryTextStyleMedium
                                              .merge(
                                            TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 18,
                                              color: Default_Theme.primaryColor1
                                                  .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ),
                                        state.artist.description != null &&
                                                state.artist.description != ''
                                            ? Text(
                                                state.artist.description ?? "",
                                                style: Default_Theme
                                                    .secondoryTextStyle
                                                    .merge(
                                                  TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 13,
                                                    color: Default_Theme
                                                        .primaryColor1
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                OutlinedButton.icon(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: const BorderSide(
                                                      width: 2,
                                                      color: Default_Theme
                                                          .accentColor2,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (context
                                                            .read<
                                                                BloomeePlayerCubit>()
                                                            .bloomeePlayer
                                                            .queueTitle
                                                            .value !=
                                                        widget.artist.name) {
                                                      context
                                                          .read<
                                                              BloomeePlayerCubit>()
                                                          .bloomeePlayer
                                                          .loadPlaylist(
                                                              state.artist
                                                                  .playlist,
                                                              doPlay: true,
                                                              idx: 0);
                                                    } else if (!context
                                                        .read<
                                                            BloomeePlayerCubit>()
                                                        .bloomeePlayer
                                                        .audioPlayer
                                                        .playing) {
                                                      context
                                                          .read<
                                                              BloomeePlayerCubit>()
                                                          .bloomeePlayer
                                                          .play();
                                                    }
                                                  },
                                                  label: const Text(
                                                    "Play",
                                                    style: Default_Theme
                                                        .secondoryTextStyleMedium,
                                                  ),
                                                  icon: const Icon(
                                                    MingCute.play_fill,
                                                    size: 20,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      artistCubit
                                                          .addToSavedCollections();
                                                    },
                                                    icon: state
                                                            .isSavedCollection
                                                        ? const Icon(FontAwesome
                                                            .heart_solid)
                                                        : const Icon(
                                                            FontAwesome.heart),
                                                    color: Default_Theme
                                                        .accentColor2,
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: "Open Original Link",
                                                  child: IconButton(
                                                    onPressed: () {
                                                      SnackbarService.showMessage(
                                                          "Opening original artist page.");
                                                      launchUrl(
                                                          Uri.parse(state.artist
                                                              .sourceURL),
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    },
                                                    icon: const Icon(
                                                      MingCute
                                                          .external_link_line,
                                                      size: 25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SliverToBoxAdapter(
                    child: TabBar(
                      labelColor: Default_Theme.primaryColor1,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Unageo',
                      ),
                      dividerColor: Colors.transparent,
                      unselectedLabelColor:
                          Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      indicatorColor: Default_Theme.primaryColor1,
                      tabs: const [
                        Tab(
                          text: "Top Songs",
                        ),
                        Tab(
                          text: "Top Albums",
                        ),
                      ],
                    ),
                  ),
                ],
                body: (state is ArtistLoaded || (state.artist.songs.isNotEmpty))
                    ? TabBarView(
                        children: [
                          state.artist.songs.isEmpty
                              ? const SignBoardWidget(
                                  message: "No song found!",
                                  icon: MingCute.unhappy_fill,
                                )
                              : ListView.builder(
                                  itemCount: state.artist.songs.length,
                                  itemBuilder: (context, index) {
                                    return SongCardWidget(
                                      song: state.artist.songs[index],
                                      onOptionsTap: () {
                                        showMoreBottomSheet(
                                          context,
                                          state.artist.songs[index],
                                          showDelete: false,
                                          showSinglePlay: true,
                                        );
                                      },
                                      onTap: () {
                                        if (context
                                                    .read<BloomeePlayerCubit>()
                                                    .bloomeePlayer
                                                    .queueTitle
                                                    .value !=
                                                widget.artist.name ||
                                            context
                                                    .read<BloomeePlayerCubit>()
                                                    .bloomeePlayer
                                                    .currentMedia !=
                                                state.artist.songs[index]) {
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .loadPlaylist(
                                                  state.artist.playlist,
                                                  doPlay: true,
                                                  idx: index);
                                        } else if (!context
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .audioPlayer
                                            .playing) {
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .play();
                                        }
                                      },
                                    );
                                  },
                                ),
                          state.artist.albums.isEmpty
                              ? const SignBoardWidget(
                                  message: "No album found!",
                                  icon: MingCute.unhappy_fill,
                                )
                              : ListView.builder(
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AlbumView(
                                                album:
                                                    state.artist.albums[index],
                                              ),
                                            ),
                                          );
                                        },
                                        leading: Hero(
                                          tag: state
                                              .artist.albums[index].sourceId,
                                          child: LoadImageCached(
                                            imageUrl: state
                                                .artist.albums[index].imageURL,
                                          ),
                                        ),
                                        title: Text(
                                          maxLines: 1,
                                          state.artist.albums[index].name,
                                          style: Default_Theme
                                              .secondoryTextStyleMedium
                                              .merge(
                                            TextStyle(
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis,
                                              color: Default_Theme.primaryColor1
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ),
                                        subtitle: Text(
                                          state.artist.albums[index]
                                                  .description ??
                                              "",
                                          maxLines: 1,
                                          style: Default_Theme
                                              .secondoryTextStyleMedium
                                              .merge(
                                            TextStyle(
                                              fontSize: 12,
                                              color: Default_Theme.primaryColor1
                                                  .withValues(alpha: 0.6),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: state.artist.albums.length,
                                )
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
