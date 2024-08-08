// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class SmallPlaylistCard extends StatelessWidget {
  final String playListTitle;
  final coverArt;
  final String playListsubTitle;
  const SmallPlaylistCard({
    Key? key,
    required this.playListTitle,
    required this.coverArt,
    required this.playListsubTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<String>(
              stream:
                  context.watch<BloomeePlayerCubit>().bloomeePlayer.queueTitle,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == playListTitle) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      FontAwesome.chart_simple_solid,
                      color: Default_Theme.primaryColor2.withOpacity(1),
                      size: 15,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SizedBox.square(
              dimension: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: coverArt,
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
                  playListTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Default_Theme.primaryColor1)),
                ),
                Text(
                  playListsubTitle,
                  style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Default_Theme.primaryColor1)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
