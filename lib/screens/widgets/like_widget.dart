import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:Bloomee/theme_data/default.dart';

// ignore: must_be_immutable
class LikeBtnWidget extends StatefulWidget {
  bool isLiked;
  final bool isPlaying;
  final double iconSize;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  LikeBtnWidget({
    Key? key,
    this.isLiked = false,
    this.isPlaying = false,
    this.iconSize = 50,
    this.onLiked,
    this.onDisliked,
  }) : super(key: key);

  @override
  State<LikeBtnWidget> createState() => _LikeBtnWidgetState();
}

class _LikeBtnWidgetState extends State<LikeBtnWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          widget.isLiked = !widget.isLiked;
          if (widget.isLiked) {
            widget.onLiked!();
            print("Liked");
          } else {
            widget.onDisliked!();
            print("DisLiked");
          }
        });
      },
      child: SizedBox(
        child: widget.isPlaying
            ? heartIcon(
                color: Default_Theme.accentColor1,
                size: widget.iconSize,
                isliked: widget.isLiked)
            : heartIcon(isliked: widget.isLiked, size: widget.iconSize),
      ),
    );
  }
}

Icon heartIcon(
    {isliked = false, color = Default_Theme.accentColor2, size = 50}) {
  return isliked
      ? Icon(
          FluentIcons.heart_48_filled,
          color: color,
          size: size,
        )
      : Icon(
          FluentIcons.heart_48_regular,
          color: color,
          size: size,
        );
}
