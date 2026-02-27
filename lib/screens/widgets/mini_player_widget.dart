import 'dart:ui';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
          child:
              state.isVisible ? MiniPlayerCard(state: state) : const SizedBox(),
        );
      },
    );
  }
}

class MiniPlayerCard extends StatelessWidget {
  final MiniPlayerState state;

  const MiniPlayerCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final song = state.track!;

    return GestureDetector(
      onTap: () {
        context.read<PlayerOverlayCubit>().showPlayer();
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -10) {
          context.read<BloomeePlayerCubit>().bloomeePlayer.skipToNext();
        }
        if (details.primaryVelocity! > 10) {
          context.read<BloomeePlayerCubit>().bloomeePlayer.skipToPrevious();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -10) {
          context.read<PlayerOverlayCubit>().showPlayer();
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
            clipBehavior: Clip.hardEdge,
            children: [
              // Background image with blur applied directly
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 25,
                    sigmaY: 25,
                    tileMode: TileMode.decal,
                  ),
                  child: Container(
                    color: Default_Theme.themeColor,
                    child: LoadImageCached(
                      imageUrl: formatImgURL(
                          song.artUri?.toString() ?? '', ImageQuality.low),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Dark overlay for better contrast
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
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
                              song.artUri?.toString() ?? '', ImageQuality.low),
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
                          song.title,
                          style: Default_Theme.secondoryTextStyle.merge(
                              const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Default_Theme.primaryColor1)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist ?? 'Unknown Artist',
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
                  _buildActionButton(context),
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
                        context
                            .read<AddToPlaylistCubit>()
                            .setMediaItemModel(song);
                        context.pushNamed(RoutePaths.addToPlaylistScreen);
                      },
                      icon: const Icon(FontAwesome.plus_solid, size: 25)),
                ],
              ),
              if (!state.isCompleted)
                Positioned(
                  bottom: 0,
                  left: 8,
                  right: 8,
                  height: 4,
                  child: StreamBuilder<ProgressBarStreams>(
                    stream: context.watch<BloomeePlayerCubit>().progressStreams,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!.duration != Duration.zero) {
                        final progress = snapshot.data!.position;
                        final total = snapshot.data!.duration;
                        final progressFraction = total.inMilliseconds > 0
                            ? progress.inMilliseconds / total.inMilliseconds
                            : 0.0;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progressFraction.clamp(0.0, 1.0),
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Default_Theme.accentColor2,
                            ),
                            minHeight: 4,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              color: Default_Theme.primaryColor1,
            )),
      );
    }

    if (state.isCompleted) {
      return IconButton(
        onPressed: () {
          context.read<BloomeePlayerCubit>().bloomeePlayer.rewind();
        },
        icon: const Icon(FontAwesome.rotate_right_solid, size: 25),
      );
    }

    return IconButton(
      icon: Icon(
        state.isPlaying ? FontAwesome.pause_solid : FontAwesome.play_solid,
        size: 28,
      ),
      onPressed: () {
        state.isPlaying
            ? context.read<BloomeePlayerCubit>().bloomeePlayer.pause()
            : context.read<BloomeePlayerCubit>().bloomeePlayer.play();
      },
    );
  }
}
