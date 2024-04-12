import 'dart:developer';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            const begin = Offset(0.0, 2.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            final offsetAnimation = curvedAnimation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          child: switch (state) {
            MiniPlayerInitial() => const SizedBox(),
            MiniPlayerCompleted() => MiniPlayerCard(
                state: state,
                isCompleted: true,
              ),
            MiniPlayerWorking() => MiniPlayerCard(
                state: state,
              ),
            MiniPlayerError() => const SizedBox(),
            MiniPlayerState() => MiniPlayerCard(
                state: state,
                isCompleted: state.isCompleted,
              ),
          },
        );
      },
    );
  }
}

class MiniPlayerCard extends StatelessWidget {
  final MiniPlayerState state;
  final bool isCompleted;
  const MiniPlayerCard({
    super.key,
    required this.state,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    log("MiniPlayerCard: ${state.mediaItem.title} - ${isCompleted}");
    return GestureDetector(
      onTap: () {
        context.pushNamed(GlobalStrConsts.playerScreen);
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox(
          height: 70,
          child: Stack(
            children: [
              Container(
                color: Default_Theme.themeColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: loadImageCached(
                  state.mediaItem.artUri.toString(),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.85),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 4, bottom: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        width: 61,
                        height: 61,
                        child: loadImageCached(
                          state.mediaItem.artUri.toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.mediaItem.title,
                          style: Default_Theme.secondoryTextStyle.merge(
                              const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Default_Theme.primaryColor1)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.mediaItem.artist ?? 'Unknown Artist',
                          style: Default_Theme.secondoryTextStyle.merge(
                              TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Default_Theme.primaryColor1
                                      .withOpacity(0.7))),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .isLinkProcessing
                          .value
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: Default_Theme.primaryColor1,
                              )),
                        )
                      : (isCompleted
                          ? IconButton(
                              onPressed: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .rewind();
                              },
                              icon: const Icon(FontAwesome.rotate_right_solid,
                                  size: 25))
                          : IconButton(
                              icon: Icon(
                                state.isPlaying
                                    ? FontAwesome.pause_solid
                                    : FontAwesome.play_solid,
                                size: 28,
                              ),
                              onPressed: () {
                                state.isPlaying
                                    ? context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .pause()
                                    : context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .play();
                              },
                            )),
                  IconButton(
                      onPressed: () {
                        context.read<AddToPlaylistCubit>().setMediaItemModel(
                            mediaItem2MediaItemModel(state.mediaItem));
                        context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
                      },
                      icon: const Icon(FontAwesome.plus_solid, size: 25)),
                ],
              ),
              isCompleted
                  ? const SizedBox()
                  : Positioned.fill(
                      bottom: 2,
                      left: 8,
                      right: 8,
                      top: 68,
                      child: StreamBuilder<ProgressBarStreams>(
                          stream: context
                              .watch<BloomeePlayerCubit>()
                              .progressStreams,
                          builder: (context, snapshot) {
                            try {
                              if (snapshot.hasData) {
                                return ProgressBar(
                                    thumbRadius: 0,
                                    barHeight: 4,
                                    baseBarColor: Colors.transparent,
                                    timeLabelLocation: TimeLabelLocation.none,
                                    progress: snapshot.data!.currentPos,
                                    total: snapshot
                                        .data!.currentPlaybackState.duration!);
                              }
                            } catch (e) {}
                            return const SizedBox();
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
