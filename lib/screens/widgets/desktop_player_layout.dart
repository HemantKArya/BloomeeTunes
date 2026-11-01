import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Desktop composition: sleeve and existing player controls sit side by side
/// as soon as the stage has room for both, independently of the queue width.
class DesktopPlayerLayout extends StatelessWidget {
  final Widget artwork;
  final Widget controls;

  const DesktopPlayerLayout({
    super.key,
    required this.artwork,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final gap = constraints.maxWidth >= 900 ? 48.0 : 32.0;
      final controlArea = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: controls,
      );
      if (constraints.maxWidth >= 680) {
        final artSize = math.min(
          constraints.maxHeight * 0.86,
          math.min(constraints.maxWidth * 0.48, 640.0),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(dimension: artSize, child: artwork),
            SizedBox(width: gap),
            Flexible(
              child: SingleChildScrollView(child: controlArea),
            ),
          ],
        );
      }

      final artSize = math.min(
        constraints.maxWidth,
        (constraints.maxHeight - 300).clamp(200.0, 360.0),
      );
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(dimension: artSize, child: artwork),
              const SizedBox(height: 28),
              controlArea,
            ],
          ),
        ),
      );
    });
  }
}
