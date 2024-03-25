// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';

class SongCardWidget extends StatelessWidget {
  final MediaItemModel song;
  final bool? showOptions;
  final VoidCallback? onOptionsTap;
  final VoidCallback? onTap;

  const SongCardWidget({
    Key? key,
    required this.song,
    this.showOptions,
    this.onOptionsTap,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Default_Theme.accentColor1.withOpacity(0.2),
        hoverColor: Default_Theme.accentColor2.withOpacity(0.1),
        highlightColor: Default_Theme.accentColor2.withOpacity(0.1),
        onTap: () {
          if (onTap != null) onTap!();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 2, top: 4, bottom: 4),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: StreamBuilder<MediaItem?>(
                    stream: context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .mediaItem,
                    builder: (context, snapshot) {
                      return (snapshot.data != null &&
                              snapshot.data?.id == song.id)
                          ? const Icon(
                              FontAwesome.caret_right_solid,
                              color: Default_Theme.accentColor1,
                              size: 25,
                            )
                          : const SizedBox();
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 55,
                    height: 55,
                    child: loadImageCached(song.artUri.toString(),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        song.title,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Default_Theme.tertiaryTextStyle.merge(
                            const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Default_Theme.primaryColor1,
                                fontSize: 14)),
                      ),
                    ),
                    Text(song.artist ?? 'Unknown',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                            color: Default_Theme.primaryColor1.withOpacity(0.8),
                            fontSize: 13))),
                  ],
                ),
              ),
              showOptions ?? false
                  ? const SizedBox()
                  : IconButton(
                      icon: const Icon(
                        MingCute.more_2_fill,
                        color: Default_Theme.primaryColor1,
                      ),
                      onPressed: () {
                        if (onOptionsTap != null) onOptionsTap!();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class SongCardDummyWidget extends StatelessWidget {
  const SongCardDummyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Container(
                      width: 300,
                      height: 17,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
