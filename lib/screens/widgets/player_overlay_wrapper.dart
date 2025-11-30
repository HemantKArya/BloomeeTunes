import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/screen/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A persistent player overlay that stays mounted in the widget tree.
/// This widget wraps the main content and overlays the full player on top
/// with a slide-up animation when visible, similar to Spotify/YouTube Music.
class PlayerOverlayWrapper extends StatefulWidget {
  final Widget child;

  const PlayerOverlayWrapper({
    super.key,
    required this.child,
  });

  @override
  State<PlayerOverlayWrapper> createState() => _PlayerOverlayWrapperState();
}

class _PlayerOverlayWrapperState extends State<PlayerOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  /// Track if the player has ever been shown so we can keep it mounted
  bool _hasBeenShown = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPlayerVisibilityChanged(bool isVisible) {
    if (isVisible) {
      _hasBeenShown = true;
      // Dismiss keyboard by unfocusing any active text field
      FocusManager.instance.primaryFocus?.unfocus();
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerOverlayCubit, bool>(
      listener: (context, isVisible) {
        _onPlayerVisibilityChanged(isVisible);
      },
      child: Stack(
        children: [
          // Main content (always visible)
          widget.child,

          // Player overlay - once shown, stays mounted for instant reopening
          BlocBuilder<PlayerOverlayCubit, bool>(
            buildWhen: (previous, current) {
              // Only rebuild if we need to first mount the player
              // Once mounted, it stays mounted
              return !_hasBeenShown && current;
            },
            builder: (context, isVisible) {
              if (!_hasBeenShown && !isVisible) {
                return const SizedBox.shrink();
              }

              // Mark that player has been shown
              if (isVisible && !_hasBeenShown) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _hasBeenShown = true;
                    });
                  }
                });
              }

              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Visibility(
                    visible: _animationController.value > 0,
                    maintainState: true, // Keep state when hidden
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: const _PersistentPlayerView(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The persistent player view that stays mounted.
class _PersistentPlayerView extends StatelessWidget {
  const _PersistentPlayerView();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.transparent,
      child: AudioPlayerView(),
    );
  }
}
