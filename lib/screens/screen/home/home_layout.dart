import 'dart:io';

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sizes for the Home page, worked out once per layout from the content
/// width and the window height. The look follows the original Home design;
/// only how it is built changed.
@immutable
class HomeMetrics {
  /// Width of the Home content (the window minus any side rail).
  final double width;
  final double screenHeight;

  const HomeMetrics({required this.width, required this.screenHeight});

  // Same breakpoints as the app (main.dart): mobile ≤ 450, tablet ≤ 800.
  bool get isMobile => width <= 450;
  bool get isTablet => width > 450 && width <= 800;

  /// Album, playlist, artist and track cards.
  static const cardSize = 150.0;

  /// Width of one column of song rows in Recently / Last.fm shelves.
  double get trackColumnWidth =>
      (width - 40) * (isMobile || isTablet ? 0.88 : 0.48);

  /// Chart carousel: share of the width per card, and card height.
  double get chartFraction => isMobile ? 0.65 : (isTablet ? 0.40 : 0.30);
  double get chartHeight =>
      isMobile || isTablet ? (screenHeight * 0.36).clamp(200, 360) : 250;

  /// Mouse-driven desktops get buttons to scroll shelves.
  static bool get showsScrollButtons =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);
}

/// Section title in the original style: pink, bold, left aligned.
class HomeSectionTitle extends StatelessWidget {
  final String title;
  const HomeSectionTitle(this.title, {super.key});

  static const style = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Default_Theme.accentColor2,
  );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 20, top: 5),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      );
}

/// The vertical label beside the Recently and Last.fm shelves.
class HomeCategoryLabel extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const HomeCategoryLabel(this.label, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = SizedBox(
      width: 40,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: RotatedBox(
          quarterTurns: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HomeSectionTitle.style,
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: text),
    );
  }
}

/// Scrolls a shelf by about one screen.
void scrollShelf(ScrollController controller, int direction, {double? step}) {
  if (!controller.hasClients) return;
  final position = controller.position;
  final target =
      (position.pixels + direction * (step ?? position.viewportDimension * 0.8))
          .clamp(position.minScrollExtent, position.maxScrollExtent);
  controller.animateTo(target,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
}

/// A soft placeholder block used while a shelf loads, so the page keeps its
/// shape instead of jumping when content arrives.
class HomeSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const HomeSkeleton(
      {super.key, required this.width, required this.height, this.radius = 15});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
