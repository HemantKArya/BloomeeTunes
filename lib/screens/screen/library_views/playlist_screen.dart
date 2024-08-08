import 'dart:io';
import 'dart:ui';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  final double titleScale = 1.5;
  final double titleFontSize = 16;

  Color _adjustColor(Color color, bool darken, {double amount = 0.1}) {
    final hsl = HSLColor.fromColor(color);
    HSLColor adjustedHsl = darken
        ? hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        : hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    if (!darken && adjustedHsl.lightness < 0.75) {
      adjustedHsl = adjustedHsl.withLightness(0.85);
    }
    return adjustedHsl.toColor();
  }

  List<Color> getFBColor(BuildContext context) {
    // get foreground and background color from current playlist pallete
    Color? color = context
        .read<CurrentPlaylistCubit>()
        .getCurrentPlaylistPallete()
        ?.lightVibrantColor
        ?.color;
    Color? bgColor = context
        .read<CurrentPlaylistCubit>()
        .getCurrentPlaylistPallete()
        ?.darkMutedColor
        ?.color;
    if (bgColor != null && color != null) {
      //calculate contrast between two color and bgcolor
      final double contrast =
          bgColor.computeLuminance() / color.computeLuminance();
      if (contrast > 0.05) {
        color = _adjustColor(color, false);
        bgColor = _adjustColor(bgColor, true);
      }
      return [color, bgColor];
    }
    return [Colors.white, Colors.black];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
          builder: (context, state) {
            return StreamBuilder<String>(
                stream: context
                    .watch<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .queueTitle,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == state.albumName) {
                    return StreamBuilder<PlayerState>(
                        stream: context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .audioPlayer
                            .playerStateStream,
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData &&
                              (snapshot2.data?.playing ?? false)) {
                            return PlayPauseButton(
                              onPause: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .pause(),
                              onPlay: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .play(),
                              isPlaying: true,
                              size: 60,
                            );
                          } else {
                            return PlayPauseButton(
                              onPause: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .pause(),
                              onPlay: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .play(),
                              isPlaying: false,
                              size: 60,
                            );
                          }
                        });
                  } else {
                    return PlayPauseButton(
                      onPause: () => context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .pause(),
                      onPlay: () {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .loadPlaylist(MediaPlaylist(
                                mediaItems: state.mediaItems,
                                albumName: state.albumName));
                        context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                      },
                      size: 60,
                    );
                  }
                });
          },
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
          builder: (context, state) {
            const double maxExtent = 300;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: (state is! CurrentPlaylistInitial &&
                      state.mediaItems.isNotEmpty)
                  ? CustomScrollView(
                      key: const ValueKey('1'),
                      physics: const BouncingScrollPhysics(),
                      primary: true,
                      slivers: [
                        SliverAppBar(
                          leading: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                            ),
                            hoverColor: getFBColor(context)[1].withOpacity(0.3),
                            highlightColor:
                                getFBColor(context)[0].withOpacity(0.6),
                            color: getFBColor(context)[0],
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  getFBColor(context)[1].withOpacity(0.1)),
                            ),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          backgroundColor: Default_Theme.themeColor,
                          surfaceTintColor: Default_Theme.themeColor,
                          expandedHeight: maxExtent,
                          floating: false,
                          pinned: true,
                          centerTitle: false,
                          flexibleSpace:
                              LayoutBuilder(builder: (context, constraints) {
                            final double percentage =
                                (constraints.maxHeight - kToolbarHeight) /
                                    (maxExtent - kToolbarHeight);
                            const double startPadding = 20.0;
                            const double endPadding = 60.0;
                            final double horizontalPadding = startPadding +
                                (endPadding - startPadding) *
                                    (1.0 - percentage);
                            final bool isCollapsed = percentage < 0.4;

                            final span = TextSpan(
                              text: state.albumName,
                              style:
                                  Default_Theme.secondoryTextStyleMedium.merge(
                                TextStyle(
                                  fontSize: titleFontSize,
                                  color: getFBColor(context)[0],
                                ),
                              ),
                            );

                            final textPainter = TextPainter(
                                text: span,
                                textDirection: TextDirection.ltr,
                                maxLines: 3,
                                textScaler: TextScaler.linear(titleScale))
                              ..layout(
                                  maxWidth:
                                      constraints.maxWidth - horizontalPadding);

                            final textHeight = textPainter.height;

                            return FlexibleSpaceBar(
                              expandedTitleScale: titleScale,
                              titlePadding: EdgeInsets.only(
                                  left: horizontalPadding,
                                  bottom: isCollapsed ? 16 : 10),
                              title: Text(
                                state.albumName,
                                maxLines: isCollapsed ? 1 : 3,
                                style: Default_Theme.secondoryTextStyleMedium
                                    .merge(
                                  TextStyle(
                                    fontSize: titleFontSize,
                                    overflow: TextOverflow.ellipsis,
                                    color: getFBColor(context)[0],
                                  ),
                                ),
                              ),
                              background: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    loadImageCached(state
                                        .mediaItems.first.artUri
                                        .toString()),
                                    Positioned(
                                        child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            getFBColor(context)[1]
                                                .withOpacity(0.0),
                                            getFBColor(context)[1]
                                                .withOpacity(1),
                                          ],
                                          stops: const [0.5, 1],
                                        ),
                                      ),
                                    )),

                                    // Lower portion with blur
                                    Positioned.fill(
                                      top: MediaQuery.of(context).size.height *
                                          0.6, // Adjust this position as needed
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 30, sigmaY: 30),
                                        child: Container(
                                          color: Colors.black.withOpacity(
                                              0), // Keep the container color transparent
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      top: 10,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: SizedBox(
                                          height: constraints.maxHeight -
                                              (textHeight + 30),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 80, right: 80),
                                              child: loadImageCached(state
                                                  .mediaItems.first.artUri
                                                  .toString()),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    // blur fade effect bottom edge
                                  ],
                                );
                              }),
                            );
                          }),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 16,
                            ),
                            child: Text(
                              "Playlist • ${state.mediaItems.length} Songs \nby You",
                              style: Default_Theme.secondoryTextStyle
                                  .merge(TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withOpacity(0.8),
                                fontSize: 12,
                              )),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Playlist(
                            state: state,
                          ),
                        )
                      ],
                    )
                  : ((state is CurrentPlaylistInitial ||
                          state is CurrentPlaylistLoading)
                      ? const CustomScrollView(
                          key: ValueKey('2'),
                          slivers: [
                            SliverAppBar(),
                            SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ],
                        )
                      : const CustomScrollView(
                          key: ValueKey('3'),
                          slivers: [
                            SliverAppBar(),
                            SliverFillRemaining(
                              child: Center(
                                child: SignBoardWidget(
                                  message: "No Songs Yet!",
                                  icon: MingCute.playlist_line,
                                ),
                              ),
                            )
                          ],
                        )),
            );
          },
        ),
      ),
    );
  }
}

class Playlist extends StatefulWidget {
  final CurrentPlaylistState state;
  const Playlist({super.key, required this.state});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    final _state = widget.state;
    return ReorderableListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      proxyDecorator: proxyDecorator,
      itemBuilder: (context, index) {
        return SongCardWidget(
          song: _state.mediaItems[index],
          key: ValueKey(_state.mediaItems[index].id),
          trailing: Platform.isAndroid
              ? null
              : ReorderableDragStartListener(
                  index: index,
                  child: SizedBox(
                    child: Icon(
                      Icons.drag_handle,
                      color: Default_Theme.primaryColor1.withOpacity(0.0),
                    ),
                  ),
                ),
          onTap: () {
            if (!listEquals(
                context.read<BloomeePlayerCubit>().bloomeePlayer.queue.value,
                _state.mediaItems)) {
              context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                  MediaPlaylist(
                      mediaItems: _state.mediaItems,
                      albumName: _state.albumName),
                  idx: index,
                  doPlay: true);
              // context.read<BloomeePlayerCubit>().bloomeePlayer.play();
            } else if (context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .currentMedia !=
                _state.mediaItems[index]) {
              context
                  .read<BloomeePlayerCubit>()
                  .bloomeePlayer
                  .prepare4play(idx: index, doPlay: true);
            }

            context.push('/MusicPlayer');
          },
          onOptionsTap: () {
            showMoreBottomSheet(context, _state.mediaItems[index],
                onDelete: () {
              context.read<BloomeeDBCubit>().removeMediaFromPlaylist(
                  _state.mediaItems[index],
                  MediaPlaylistDB(playlistName: _state.albumName));
              setState(() {
                _state.mediaItems.removeAt(index);
              });
            }, showDelete: true);
          },
        );
      },
      itemCount: _state.mediaItems.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final MediaItemModel item = _state.mediaItems.removeAt(oldIndex);
          _state.mediaItems.insert(newIndex, item);
          context
              .read<BloomeeDBCubit>()
              .reorderPositionOfItemInDB(_state.albumName, oldIndex, newIndex);
        });
      },
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
        color: Default_Theme.accentColor2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.transparent,
        child: child,
      );
    },
    child: child,
  );
}
