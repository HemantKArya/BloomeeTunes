import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

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

class _LikeBtnWidgetState extends State<LikeBtnWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _setupAnimation();
    if (widget.isPlaying) {
      _colorController.value = 1.0;
    }
  }

  void _setupAnimation() {
    _colorAnimation = ColorTween(
      begin: Default_Theme.accentColor2, // Pink (paused)
      end: Default_Theme.accentColor1, // Sky Blue (playing)
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant LikeBtnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorController,
      builder: (context, child) {
        return IconButton(
          onPressed: () {
            setState(() {
              widget.isLiked = !widget.isLiked;
              if (widget.isLiked) {
                widget.onLiked?.call();
                log("Liked");
              } else {
                widget.onDisliked?.call();
                log("DisLiked");
              }
            });
          },
          icon: Icon(
            widget.isLiked ? AntDesign.heart_fill : AntDesign.heart_outline,
            color: _colorAnimation.value,
            size: widget.iconSize,
          ),
        );
      },
    );
  }
}
