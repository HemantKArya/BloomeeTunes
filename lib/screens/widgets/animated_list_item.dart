import 'package:flutter/material.dart';

/// Reusable animated list item with fade-in and slide-up effect.
///
/// Only the first screenful of items animates, and only while the list is
/// still at its initial scroll position. Items recycled in by scrolling
/// appear immediately instead of replaying the entrance animation.
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  static const int _maxAnimatedIndex = 12;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;
  Animation<Offset>? _offset;

  @override
  void initState() {
    super.initState();
    if (widget.index > AnimatedListItem._maxAnimatedIndex) return;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: 250 + (widget.index * 30).clamp(0, 200).toInt()),
    );
    final curved =
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart);
    _controller = controller;
    _opacity = curved;
    _offset =
        Tween(begin: const Offset(0, 16), end: Offset.zero).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _controller;
    if (controller == null ||
        controller.isAnimating ||
        controller.isCompleted) {
      return;
    }
    final position = Scrollable.maybeOf(context)?.position;
    // During the list's first layout the scroll extents aren't known yet, so
    // check hasContentDimensions before reading minScrollExtent.
    final scrolled = position != null &&
        position.hasPixels &&
        position.hasContentDimensions &&
        position.pixels > position.minScrollExtent + 1;
    if (scrolled) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _opacity;
    final offset = _offset;
    if (opacity == null || offset == null) return widget.child;

    return FadeTransition(
      opacity: opacity,
      child: AnimatedBuilder(
        animation: offset,
        builder: (context, child) =>
            Transform.translate(offset: offset.value, child: child),
        child: widget.child,
      ),
    );
  }
}
