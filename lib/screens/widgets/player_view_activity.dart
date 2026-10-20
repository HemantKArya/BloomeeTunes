import 'package:flutter/widgets.dart';

/// Visibility for continuously updating UI; audio playback is never paused.
/// Directly mounted player screens default to active, outside the overlay.
class PlayerViewActivity extends InheritedWidget {
  final bool active;

  const PlayerViewActivity({
    super.key,
    required this.active,
    required super.child,
  });

  static bool isActive(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PlayerViewActivity>()
          ?.active ??
      true;

  @override
  bool updateShouldNotify(PlayerViewActivity oldWidget) =>
      active != oldWidget.active;
}
