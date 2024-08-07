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
            const double maxExtent = 200;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: (state is! CurrentPlaylistInitial &&
                      state.mediaItems.isNotEmpty)
                  ? CustomScrollView(
                      key: const ValueKey('1'),
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            hoverColor: Colors.black.withOpacity(0.5),
                            highlightColor: Default_Theme.accentColor1,
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
                            return FlexibleSpaceBar(
                              titlePadding: EdgeInsets.only(
                                  left: horizontalPadding,
                                  bottom: isCollapsed ? 16 : 10),
                              title: Text(state.albumName,
                                  maxLines: isCollapsed ? 1 : 2,
                                  style: Default_Theme.secondoryTextStyleMedium
                                      .merge(const TextStyle(
                                          fontSize: 18,
                                          overflow: TextOverflow.ellipsis,
                                          color: Color.fromARGB(
                                              255, 255, 235, 251)))),
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  loadImageCached(
                                      state.mediaItems.first.artUri.toString()),
                                  Positioned(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Default_Theme.themeColor
                                              .withOpacity(0.0),
                                          Default_Theme.themeColor
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
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
