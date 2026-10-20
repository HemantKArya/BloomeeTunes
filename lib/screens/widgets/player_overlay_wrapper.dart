import 'dart:async';

import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/screen/player_screen.dart';
import 'package:Bloomee/screens/widgets/player_view_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Owns player preparation and transitions independently of navigation rebuilds.
/// The screen stays mounted after preparation; only its composited layer moves.
class PlayerOverlayWrapper extends StatefulWidget {
  final Widget child;
  const PlayerOverlayWrapper({super.key, required this.child});

  @override
  State<PlayerOverlayWrapper> createState() => _PlayerOverlayWrapperState();
}

class _PlayerOverlayWrapperState extends State<PlayerOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<Offset> _slide;
  late final PlayerOverlayCubit _overlay;
  final SnapshotController _transitionSnapshot = SnapshotController();
  StreamSubscription<MiniPlayerState>? _miniSubscription;
  bool _prepared = false;
  bool _rendered = false;
  bool _requested = false;
  bool _preparationScheduled = false;
  Timer? _preparationTimer;

  @override
  void initState() {
    super.initState();
    _overlay = context.read<PlayerOverlayCubit>();
    _requested = _overlay.state;
    _prepared = _rendered = _requested;
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _requested ? 1 : 0,
    )..addStatusListener(_onStatus);
    _slide = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_animation);
    final mini = context.read<MiniPlayerCubit>();
    if (mini.state.isVisible) {
      _prepareAfterPlaybackSettles();
    } else {
      _miniSubscription = mini.stream.listen((state) {
        if (state.isVisible) {
          _prepareAfterPlaybackSettles();
          _miniSubscription?.cancel();
          _miniSubscription = null;
        }
      });
    }
  }

  void _prepareAfterPlaybackSettles() {
    if (_prepared || _preparationScheduled) return;
    _preparationScheduled = true;
    // Do not use scheduleTask(Priority.idle): a continuously animated mini
    // player can starve idle tasks. This is one cancellable, bounded warm-up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _prepared) return;
      _preparationTimer = Timer(const Duration(milliseconds: 120), () {
        if (mounted && !_prepared) setState(() => _prepared = true);
      });
    });
  }

  void _onStatus(AnimationStatus status) {
    // Match native route transitions: freeze painting only while moving.
    // In particular, a retained layer is not sufficient on renderers that
    // re-rasterize its children at each fractional translation.
    _transitionSnapshot.allowSnapshotting = !kIsWeb &&
        (status == AnimationStatus.forward ||
            status == AnimationStatus.reverse);
    if (status == AnimationStatus.dismissed && !_requested && _rendered) {
      setState(() => _rendered = false);
    }
  }

  void _onVisibility(bool visible) {
    final wasPrepared = _prepared;
    _preparationTimer?.cancel();
    setState(() {
      _requested = visible;
      if (visible) _prepared = _rendered = true;
    });
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    if (visible) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (!wasPrepared) {
        // Lay out a cold screen before starting its animation, rather than
        // doing both in the first animated frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _requested) _animation.forward();
        });
      } else {
        _animation.forward();
      }
    } else {
      _animation.reverse();
      if (_animation.isDismissed && _rendered) {
        setState(() => _rendered = false);
      }
    }
  }

  @override
  void dispose() {
    _preparationTimer?.cancel();
    _miniSubscription?.cancel();
    _animation.removeStatusListener(_onStatus);
    _animation.dispose();
    _transitionSnapshot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerOverlayCubit, bool>(
      listener: (context, visible) => _onVisibility(visible),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A covered library/mini player must not keep ticking behind the
          // moving screen. Its state and navigation remain intact.
          IgnorePointer(
            ignoring: _rendered,
            child: ExcludeFocus(
              excluding: _rendered,
              child: TickerMode(
                enabled: !_rendered,
                child: PlayerViewActivity(
                  active: !_rendered,
                  child: RepaintBoundary(child: widget.child),
                ),
              ),
            ),
          ),
          if (_prepared)
            Offstage(
              offstage: !_rendered,
              child: IgnorePointer(
                ignoring: !_requested,
                child: ExcludeFocus(
                  excluding: !_requested,
                  child: TickerMode(
                    enabled: _rendered,
                    child: PlayerViewActivity(
                      active: _rendered,
                      child: SlideTransition(
                        position: _slide,
                        // No full-screen opacity layer. The opaque player can
                        // be retained and composited as one translated layer.
                        child: SnapshotWidget(
                          controller: _transitionSnapshot,
                          mode: SnapshotMode.permissive,
                          autoresize: true,
                          child:
                              const RepaintBoundary(child: AudioPlayerView()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
