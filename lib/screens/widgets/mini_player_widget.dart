import 'dart:ui';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_bloc.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
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
                isProcessing: state.isBuffering,
              ),
            MiniPlayerError() => const SizedBox(),
            MiniPlayerProcessing() => MiniPlayerCard(
                state: state,
                isProcessing: true,
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
  final bool isProcessing;

  const MiniPlayerCard({
    super.key,
    required this.state,
    this.isCompleted = false,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(GlobalStrConsts.playerScreen);
      },
      onHorizontalDragEnd: (details) {
        // Improved gesture sensitivity and feedback
        if (details.primaryVelocity! < -200) {
          // Swipe left - Next song
          HapticFeedback.mediumImpact();
          context.read<BloomeePlayerCubit>().bloomeePlayer.skipToNext();
          _showGestureHint(context, "Next Song", Icons.skip_next);
        } else if (details.primaryVelocity! > 200) {
          // Swipe right - Previous song
          HapticFeedback.mediumImpact();
          context.read<BloomeePlayerCubit>().bloomeePlayer.skipToPrevious();
          _showGestureHint(context, "Previous Song", Icons.skip_previous);
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -10) {
          context.pushNamed(GlobalStrConsts.playerScreen);
        }
        if (details.primaryVelocity! > 10) {
          // context.read<BloomeePlayerCubit>().bloomeePlayer.stop();
        }
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
                child: LoadImageCached(
                  imageUrl: formatImgURL(
                      state.song.artUri.toString(), ImageQuality.low),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaY: 18,
                    sigmaX: 18,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                        alpha: 0.5), // Keep the container color transparent
                  ),
                ),
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
                        child: LoadImageCached(
                          imageUrl: formatImgURL(
                              state.song.artUri.toString(), ImageQuality.low),
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
                          state.song.title,
                          style: Default_Theme.secondoryTextStyle.merge(
                              const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Default_Theme.primaryColor1)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.song.artist ?? 'Unknown Artist',
                          style: Default_Theme.secondoryTextStyle.merge(
                              TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.7))),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ResponsiveBreakpoints.of(context).isDesktop
                      ? IconButton(
                          icon: const Icon(
                            FontAwesome.backward_step_solid,
                            size: 28,
                          ),
                          onPressed: () {
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .skipToPrevious();
                          },
                        )
                      : const SizedBox.shrink(),
                  (state.isBuffering || isProcessing)
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
                  ResponsiveBreakpoints.of(context).isDesktop
                      ? IconButton(
                          icon: const Icon(
                            FontAwesome.forward_step_solid,
                            size: 28,
                          ),
                          onPressed: () {
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .skipToNext();
                          },
                        )
                      : const SizedBox.shrink(),
                  IconButton(
                      onPressed: () {
                        context.read<AddToPlaylistCubit>().setMediaItemModel(
                            mediaItem2MediaItemModel(state.song));
                        context.pushNamed(GlobalStrConsts.addToPlaylistScreen);
                      },
                      icon: const Icon(FontAwesome.plus_solid, size: 25)),
                ],
              ),
              // Glass-type progress overlay
              isCompleted
                  ? const SizedBox()
                  : StreamBuilder<ProgressBarStreams>(
                      stream:
                          context.watch<BloomeePlayerCubit>().progressStreams,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        final progress =
                            snapshot.data!.currentPos.inMilliseconds;
                        final total = snapshot.data!.currentPlaybackState
                                .duration?.inMilliseconds ??
                            1;
                        final progressRatio = progress / total;

                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            child: Stack(
                              children: [
                                // Glass progress overlay
                                Positioned(
                                  left: 0,
                                  right: MediaQuery.of(context).size.width *
                                      (1 - progressRatio),
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Default_Theme.accentColor1
                                              .withValues(alpha: 0.25),
                                          Default_Theme.accentColor2
                                              .withValues(alpha: 0.18),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Default_Theme.accentColor1
                                                .withValues(alpha: 0.5),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Subtle progress line at bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    child: LinearProgressIndicator(
                                      value: progressRatio,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Default_Theme.accentColor1
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show gesture feedback
void _showGestureHint(BuildContext context, String message, IconData icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Default_Theme.primaryColor1, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: Default_Theme.primaryColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Default_Theme.accentColor2.withValues(alpha: 0.9),
      duration: const Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
