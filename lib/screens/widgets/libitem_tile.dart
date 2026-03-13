// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

enum LibItemTypes {
  userPlaylist,
  onlPlaylist,
  artist,
  album,
}

class LibItemCard extends StatelessWidget {
  final String title;
  final String coverArt;
  final String subtitle;
  final LibItemTypes type;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final bool isPinned;
  const LibItemCard({
    Key? key,
    required this.title,
    required this.coverArt,
    required this.subtitle,
    this.type = LibItemTypes.userPlaylist,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.isPinned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: InkWell(
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.1),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap ?? () {},
        onSecondaryTap: onSecondaryTap ?? () {},
        onLongPress: onLongPress ?? () {},
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              type == LibItemTypes.userPlaylist
                  ? StreamBuilder<String>(
                      stream: context
                          .watch<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .queueTitle,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == title) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              FontAwesome.chart_simple_solid,
                              color: Default_Theme.primaryColor2
                                  .withValues(alpha: 1),
                              size: 15,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      })
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SizedBox.square(
                  dimension: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: switch (type) {
                      LibItemTypes.userPlaylist => LoadImageCached(
                          imageUrl: coverArt, fallbackUrl: coverArt.toString()),
                      LibItemTypes.onlPlaylist => LoadImageCached(
                          imageUrl: coverArt, fallbackUrl: coverArt.toString()),
                      LibItemTypes.artist => ClipOval(
                          child: LoadImageCached(
                              imageUrl: coverArt,
                              fallbackUrl: coverArt.toString()),
                        ),
                      LibItemTypes.album => LoadImageCached(
                          imageUrl: coverArt, fallbackUrl: coverArt.toString()),
                    },
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Default_Theme.secondoryTextStyle.merge(
                          const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Default_Theme.primaryColor1)),
                    ),
                    Row(
                      children: [
                        if (isPinned) ...[
                          Icon(
                            MingCute.pin_2_fill,
                            size: 12,
                            color: Default_Theme.accentColor2
                                .withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    fontSize: 14,
                                    overflow: TextOverflow.fade,
                                    fontWeight: FontWeight.w500,
                                    color: Default_Theme.primaryColor1)),
                          ),
                        ),
                      ],
                    ),
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
