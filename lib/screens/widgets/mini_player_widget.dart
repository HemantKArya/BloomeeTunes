import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';

import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              context.read<BloomeePlayerCubit>().bloomeePlayer.skipToPrevious();
            } else if (details.primaryVelocity! < 0) {
              context.read<BloomeePlayerCubit>().bloomeePlayer.skipToNext();
            }
          }
        },
        child: Container(
          height: 70,
          color: Default_Theme.primaryColor1,
          child: Stack(
            children: [
              SizedBox(
                height: 500,
                width: 500,
                child: StreamBuilder<MediaItem?>(
                    stream: context
                        .watch<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .mediaItem,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? loadImageCached(
                              snapshot.data?.artUri.toString() ?? "")
                          : loadImageCached("");
                    }),
              ),
              Opacity(
                opacity: 0.8,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Default_Theme.themeColor,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    StreamBuilder<MediaItem?>(
                        stream: context
                            .watch<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .mediaItem,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1.5),
                                  child: SizedBox(
                                    width: 70,
                                    child: loadImageCached(
                                        snapshot.data?.artUri.toString()),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (snapshot.data?.title ?? "Unknown")
                                                    .length >
                                                27
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                height: 20,
                                                child: Marquee(
                                                  text: snapshot.data?.title ??
                                                      "Unknown",
                                                  blankSpace: 20.0,
                                                  velocity: 30.0,
                                                  style: Default_Theme
                                                      .secondoryTextStyle
                                                      .merge(const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Default_Theme
                                                              .primaryColor1)),
                                                ),
                                              )
                                            : Text(
                                                snapshot.data?.title ??
                                                    "Unknown",
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: Default_Theme
                                                    .secondoryTextStyle
                                                    .merge(const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Default_Theme
                                                            .primaryColor1)),
                                              ),
                                        Text(
                                          snapshot.data?.artist ?? "Unknown",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: Default_Theme
                                              .secondoryTextStyle
                                              .merge(TextStyle(
                                                  fontSize: 12,
                                                  color: Default_Theme
                                                      .primaryColor1
                                                      .withOpacity(0.7))),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Text("error");
                          }
                        }),
                    const Spacer(),
                    StreamBuilder<PlaybackState>(
                        stream: context
                            .watch<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .playbackState,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              (snapshot.data?.playing ?? false)) {
                            return InkWell(
                              onTap: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .pause(),
                              child: const Icon(
                                FluentIcons.pause_48_filled,
                                size: 30,
                                color: Default_Theme.primaryColor2,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return GestureDetector(
                              onHorizontalDragStart: (details) => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .skipToNext(),
                              onTap: () => context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .play(),
                              child: const Icon(
                                FluentIcons.play_48_filled,
                                size: 30,
                                color: Default_Theme.primaryColor2,
                              ),
                            );
                          } else {
                            return const Wrap();
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () => context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .stop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: Default_Theme.primaryColor2,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
