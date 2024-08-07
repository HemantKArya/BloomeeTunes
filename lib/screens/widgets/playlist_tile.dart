// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:Bloomee/theme_data/default.dart';

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
