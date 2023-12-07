import 'package:Bloomee/services/bloomeePlayer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:Bloomee/utils/pallete_generator.dart';

import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  @override
  Widget build(BuildContext context) {
    BloomeeMusicPlayer musicPlayer =
        context.read<BloomeePlayerCubit>().bloomeePlayer;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Enjoying From',
              textAlign: TextAlign.center,
              style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)
                  .merge(Default_Theme.secondoryTextStyle),
            ),
            StreamBuilder<String>(
                stream: context
                    .watch<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .currentQueueName,
                builder: (context, snapshot) {
                  return InkWell(
                    // onTap: () => context.pushNamed(GlobalStrConsts.playlistView,
                    //     pathParameters: {
                    //       "playlistName": snapshot.data ?? "Liked"
                    //     }),
                    child: Text(
                      snapshot.data ?? "Unknown",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 12,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                  );
                }),
          ],
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.5) -
                  (MediaQuery.of(context).size.width * 0.70),
              left: MediaQuery.of(context).size.width * 0.08 * 0.5,
              child: Opacity(
                opacity: 0.2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92,
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: StreamBuilder<MediaItem?>(
                      stream: musicPlayer.mediaItem,
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                            duration: const Duration(seconds: 3),
                            child: _getAmbientShadowWidget(context, snapshot));
                      }),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.5) -
                  (MediaQuery.of(context).size.width * 0.60),
              left: MediaQuery.of(context).size.width * 0.08 * 0.5,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                height: MediaQuery.of(context).size.width * 0.92,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: StreamBuilder<MediaItem?>(
                      stream: context
                          .watch<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .mediaItem,
                      builder: (context, snapshot) {
                        return loadImageCached(
                            (snapshot.data?.artUri ?? "").toString());
                      }),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height * 0.5) +
                  (MediaQuery.of(context).size.width * 0.40),
              left: MediaQuery.of(context).size.width * 0.08 * 0.5,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                // height: MediaQuery.of(context).size.width * 0.92,
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: StreamBuilder<MediaItem?>(
                              stream: context
                                  .watch<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .mediaItem,
                              builder: (context, snapshot) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data?.title ?? "Unknown",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Default_Theme.primaryColor1)),
                                    ),
                                    Text(
                                      snapshot.data?.artist ?? "Unknown",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(TextStyle(
                                              fontSize: 15,
                                              color: Default_Theme.primaryColor1
                                                  .withOpacity(0.7))),
                                    )
                                  ],
                                );
                              }),
                        ),
                        const Spacer(),
                        FutureBuilder(
                          future: context.read<MediaDBCubit>().isLiked(context
                              .read<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .currentMedia),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 3),
                                child: LikeBtnWidget(
                                  isPlaying: true,
                                  isLiked: snapshot.data ?? false,
                                  iconSize: 35,
                                  onLiked: () => context
                                      .read<MediaDBCubit>()
                                      .setLike(
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .currentMedia,
                                          isLiked: true),
                                  onDisliked: () => context
                                      .read<MediaDBCubit>()
                                      .setLike(
                                          context
                                              .read<BloomeePlayerCubit>()
                                              .bloomeePlayer
                                              .currentMedia,
                                          isLiked: false),
                                ),
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 3),
                                child: LikeBtnWidget(
                                  isLiked: false,
                                  isPlaying: true,
                                  iconSize: 35,
                                  onLiked: () {},
                                  onDisliked: () {},
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: StreamBuilder<ProgressBarStreams>(
                          stream: context
                              .watch<BloomeePlayerCubit>()
                              .progressStreams,
                          builder: (context, snapshot) {
                            return ProgressBar(
                              progress:
                                  snapshot.data?.currentPos ?? Duration.zero,
                              total: snapshot
                                      .data?.currentPlaybackState.duration ??
                                  Duration.zero,
                              buffered: snapshot.data?.currentPlaybackState
                                      .bufferedPosition ??
                                  Duration.zero,
                              onSeek: (value) {
                                musicPlayer.seek(value);
                              },
                              timeLabelPadding: 5,
                              timeLabelTextStyle: Default_Theme
                                  .secondoryTextStyle
                                  .merge(TextStyle(
                                      fontSize: 15,
                                      color: Default_Theme.primaryColor1
                                          .withOpacity(0.7))),
                              timeLabelLocation: TimeLabelLocation.above,
                              baseBarColor:
                                  Default_Theme.primaryColor2.withOpacity(0.1),
                              progressBarColor:
                                  snapshot.data?.currentPlayerState.playing ??
                                          false
                                      ? Default_Theme.accentColor1
                                      : Default_Theme.accentColor2,
                              thumbRadius: 0,
                              barHeight: 4,
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () => musicPlayer.rewind(),
                            child: const Icon(
                              FluentIcons.arrow_repeat_1_24_filled,
                              color: Default_Theme.primaryColor1,
                              size: 35,
                            ),
                          ),
                          InkWell(
                            onTap: () => musicPlayer.skipToPrevious(),
                            child: const Icon(
                              FluentIcons.previous_48_filled,
                              color: Default_Theme.primaryColor1,
                              size: 35,
                            ),
                          ),
                          StreamBuilder<PlayerState>(
                              stream: context
                                  .watch<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .audioPlayer
                                  .playerStateStream,
                              builder: (context, snapshot) {
                                return PlayPauseButton(
                                  size: 75,
                                  onPause: () => musicPlayer.pause(),
                                  onPlay: () => musicPlayer.play(),
                                  isPlaying: snapshot.data?.playing ?? false,
                                );
                              }),
                          InkWell(
                            onTap: () => musicPlayer.skipToNext(),
                            child: const Icon(
                              FluentIcons.next_48_filled,
                              color: Default_Theme.primaryColor1,
                              size: 35,
                            ),
                          ),
                          const Icon(
                            FluentIcons.open_48_filled,
                            color: Default_Theme.primaryColor1,
                            size: 35,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _getAmbientShadowWidget(
    BuildContext context, AsyncSnapshot<MediaItem?> snapshot) {
  if (snapshot.hasData) {
    return FutureBuilder(
      future: getPalleteFromImage(context
          .read<BloomeePlayerCubit>()
          .bloomeePlayer
          .currentMedia
          .artUri
          .toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                  color: snapshot.data?.dominantColor?.color ??
                      const Color.fromARGB(255, 68, 252, 255),
                  blurRadius: 120,
                  spreadRadius: 30)
            ]),
          );
        } else {
          return Container(
            decoration:
                const BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(39, 68, 252, 255),
                  blurRadius: 120,
                  spreadRadius: 30)
            ]),
          );
        }
      },
    );
  } else {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent, boxShadow: [
        BoxShadow(
            color: Color.fromARGB(255, 68, 252, 255),
            blurRadius: 120,
            spreadRadius: 30)
      ]),
    );
  }
}
