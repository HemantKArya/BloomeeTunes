// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'mediaItemOptions_bottomsheet.dart';

class HorizontalSongCardWidget extends StatelessWidget {
  final MediaPlaylist? mediaPlaylist;
  final int index;
  final bool showLiked;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  final double boxWidth;
  final bool isLiked;
  final bool showOptions;
  const HorizontalSongCardWidget({
    Key? key,
    required this.mediaPlaylist,
    required this.index,
    this.showLiked = false,
    this.onLiked,
    this.onDisliked,
    this.boxWidth = 0.86,
    this.isLiked = false,
    this.showOptions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Default_Theme.accentColor2.withOpacity(0.1),
      // focusColor: Default_Theme.accentColor2,
      hoverColor: Default_Theme.accentColor2.withOpacity(0.1),
      highlightColor: Default_Theme.accentColor2.withOpacity(0.1),
      onLongPress: () {
        if (mediaPlaylist != null) {
          showMediaItemOptions(context, mediaPlaylist!.mediaItems[index]);
        }
      },
      onTap: () {
        if (mediaPlaylist != null) {
          if (!listEquals(
              context.read<BloomeePlayerCubit>().bloomeePlayer.currentPlaylist,
              mediaPlaylist?.mediaItems)) {
            context
                .read<BloomeePlayerCubit>()
                .bloomeePlayer
                .loadPlaylist(mediaPlaylist!, idx: index, doPlay: true);
            // context.read<BloomeePlayerCubit>().bloomeePlayer.play();
          } else if (context
                  .read<BloomeePlayerCubit>()
                  .bloomeePlayer
                  .currentMedia !=
              mediaPlaylist!.mediaItems[index]) {
            context
                .read<BloomeePlayerCubit>()
                .bloomeePlayer
                .prepare4play(idx: index, doPlay: true);
            // context.read<BloomeePlayerCubit>().bloomeePlayer.play();
          }

          context.push('/MusicPlayer');
        }
      },
      child: SizedBox(
        // color: Colors.white.withOpacity(0.3),
        width: MediaQuery.of(context).size.width * boxWidth,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                  width: 55,
                  height: 55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: loadImageCached(mediaPlaylist
                        ?.mediaItems[index].artUri
                        .toString()
                        .replaceAll("w400-h400", "w150-h150")),
                  )),
            ),
            Expanded(
              flex: 15,
              // width: MediaQuery.of(context).size.width * boxWidth,
              child: StreamBuilder<MediaItem?>(
                  stream: context
                      .read<BloomeePlayerCubit>()
                      .bloomeePlayer
                      .mediaItem,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data == mediaPlaylist?.mediaItems[index]) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mediaPlaylist?.mediaItems[index].title ?? "Unknown",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Default_Theme.tertiaryTextStyle.merge(
                                const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Default_Theme.accentColor1light,
                                    fontSize: 14)),
                          ),
                          Text(
                              mediaPlaylist?.mediaItems[index].artist ??
                                  "Unknown",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Default_Theme.tertiaryTextStyle
                                  .merge(
                                      TextStyle(
                                          color: Default_Theme.accentColor1
                                              .withOpacity(0.8),
                                          fontSize: 13)))
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mediaPlaylist?.mediaItems[index].title ?? "Unknown",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Default_Theme.tertiaryTextStyle.merge(
                                const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Default_Theme.primaryColor1,
                                    fontSize: 14)),
                          ),
                          Text(
                              mediaPlaylist?.mediaItems[index].artist ??
                                  "Unknown",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Default_Theme.tertiaryTextStyle.merge(
                                  TextStyle(
                                      color: Default_Theme.primaryColor1
                                          .withOpacity(0.8),
                                      fontSize: 13)))
                        ],
                      );
                    }
                  }),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: context
                      .read<MediaDBCubit>()
                      .isLiked(mediaPlaylist!.mediaItems[index]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Visibility(
                        visible: showLiked,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: StreamBuilder<MediaItem?>(
                              stream: context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .mediaItem,
                              builder: (context, snapshot2) {
                                if (snapshot2.hasData &&
                                    (snapshot2.data ==
                                        mediaPlaylist?.mediaItems[index])) {
                                  return LikeBtnWidget(
                                    isLiked: snapshot.data ?? false,
                                    iconSize: 29,
                                    onLiked: () => context
                                        .read<MediaDBCubit>()
                                        .setLike(
                                            mediaPlaylist!.mediaItems[index],
                                            isLiked: true),
                                    isPlaying: true,
                                    onDisliked: () => context
                                        .read<MediaDBCubit>()
                                        .setLike(
                                            mediaPlaylist!.mediaItems[index],
                                            isLiked: false),
                                  );
                                } else {
                                  return LikeBtnWidget(
                                    isLiked: snapshot.data ?? false,
                                    iconSize: 29,
                                    onLiked: () => context
                                        .read<MediaDBCubit>()
                                        .setLike(
                                            mediaPlaylist!.mediaItems[index],
                                            isLiked: true),
                                    onDisliked: () => context
                                        .read<MediaDBCubit>()
                                        .setLike(
                                            mediaPlaylist!.mediaItems[index],
                                            isLiked: false),
                                  );
                                }
                              }),
                        ),
                      );
                    } else {
                      return Visibility(
                        visible: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, bottom: 3, right: 5.0),
                          child: LikeBtnWidget(
                            isLiked: isLiked,
                            iconSize: 29,
                            onLiked: onLiked,
                            onDisliked: onDisliked,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Visibility(
                    visible: showOptions,
                    child: const Icon(MingCute.more_2_fill,
                        color: Default_Theme.accentColor2, size: 30.0)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
