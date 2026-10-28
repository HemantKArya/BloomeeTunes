import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Container for the [StatefulShellRoute] branch navigators.
///
/// Same structure as go_router's default IndexedStack container, plus
/// keyboard-inset handling so that typing doesn't stutter:
///
/// * Inactive branches get a frozen [MediaQuery] without view insets. They
///   don't rebuild or relayout while the keyboard animates.
/// * The active branch gets only the part of the keyboard inset that isn't
///   already covered by the shell's bottom bar (mini player + nav bar), so
///   its own Scaffold resizes exactly once, by the right amount.
class ShellBranchContainer extends StatelessWidget {
  const ShellBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final noInsets = mediaQuery.copyWith(viewInsets: EdgeInsets.zero);

    return LayoutBuilder(
      builder: (context, constraints) {
        // The shell body starts at the top of the screen, so whatever is
        // below it (the bottom bar) is the height the keyboard covers first.
        final coveredBelow = constraints.maxHeight.isFinite
            ? math.max(0.0, mediaQuery.size.height - constraints.maxHeight)
            : 0.0;
        final activeInsets = mediaQuery.viewInsets.copyWith(
          bottom: math.max(0.0, mediaQuery.viewInsets.bottom - coveredBelow),
        );
        final activeData = mediaQuery.copyWith(viewInsets: activeInsets);

        return IndexedStack(
          index: currentIndex,
          children: [
            for (var i = 0; i < children.length; i++)
              // Keep the wrapper structure identical for every branch so
              // switching tabs never remounts a branch Navigator.
              Offstage(
                offstage: i != currentIndex,
                child: TickerMode(
                  enabled: i == currentIndex,
                  child: MediaQuery(
                    data: i == currentIndex ? activeData : noInsets,
                    child: children[i],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
