import 'dart:math';
import 'dart:ui';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: state.isVisible
              ? MiniPlayerCard(key: const ValueKey('mini_player'), state: state)
              : const SizedBox.shrink(key: ValueKey('empty')),
        );
      },
    );
  }
}

class MiniPlayerCard extends StatefulWidget {
  final MiniPlayerState state;
  const MiniPlayerCard({super.key, required this.state});

  @override
  State<MiniPlayerCard> createState() => _MiniPlayerCardState();
}

class _MiniPlayerCardState extends State<MiniPlayerCard>
    with TickerProviderStateMixin {
  double _dragOffset = 0;
  double _snapStartOffset = 0;
  late final AnimationController _snapController;
  late final AnimationController _waveController;

  static const double _cardHeight = 72;
  static const double _artworkSize = 52;
  static const double _swipeThreshold = 80;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onSnapTick);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _syncAnimations();
  }

  @override
  void didUpdateWidget(covariant MiniPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.isPlaying != widget.state.isPlaying) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.state.isPlaying) {
      _waveController.repeat();
    } else {
      _waveController.stop();
    }
  }

  void _onSnapTick() {
    setState(() {
      _dragOffset = lerpDouble(
        _snapStartOffset,
        0,
        Curves.easeOutCubic.transform(_snapController.value),
      )!;
    });
  }

  @override
  void dispose() {
    _snapController
      ..removeListener(_onSnapTick)
      ..dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_snapController.isAnimating) _snapController.stop();
    setState(() {
      _dragOffset += details.delta.dx * 0.85;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    if (_dragOffset < -_swipeThreshold || velocity < -600) {
      HapticFeedback.mediumImpact();
      player.skipToNext();
    } else if (_dragOffset > _swipeThreshold || velocity > 600) {
      HapticFeedback.mediumImpact();
      player.skipToPrevious();
    }

    _snapStartOffset = _dragOffset;
    _snapController.forward(from: 0);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < -200) {
      HapticFeedback.lightImpact();
      context.read<PlayerOverlayCubit>().showPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.state.track!;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final thumbUrl = song.thumbnail.urlLow ?? song.thumbnail.url;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<PlayerOverlayCubit>().showPlayer();
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: _cardHeight,
              child: Stack(
                children: [
                  _BlurredBackground(imageUrl: thumbUrl),
                  _GlassOverlay(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        _Artwork(
                          imageUrl: thumbUrl,
                          fallbackUrl: song.thumbnail.url,
                          size: _artworkSize,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TrackInfo(
                            song: song,
                            waveController: _waveController,
                            isPlaying: widget.state.isPlaying,
                          ),
                        ),
                        if (isDesktop)
                          _ControlButton(
                            icon: FontAwesome.backward_step_solid,
                            size: 20,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .skipToPrevious();
                            },
                          ),
                        _PlayPauseButton(state: widget.state),
                        if (isDesktop)
                          _ControlButton(
                            icon: FontAwesome.forward_step_solid,
                            size: 20,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .skipToNext();
                            },
                          ),
                        _ControlButton(
                          icon: FontAwesome.plus_solid,
                          size: 18,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<AddToPlaylistCubit>().setTrack(song);
                            context.pushNamed(RoutePaths.addToPlaylistScreen);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!widget.state.isCompleted) const _GlowingProgressBar(),
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  final String imageUrl;
  const _BlurredBackground({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Transform.scale(
        scale: 1.6,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 40,
            sigmaY: 40,
            tileMode: TileMode.clamp,
          ),
          child: LoadImageCached(imageUrl: imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _GlassOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.60),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final String imageUrl;
  final String fallbackUrl;
  final double size;

  const _Artwork({
    required this.imageUrl,
    required this.fallbackUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LoadImageCached(
          imageUrl: imageUrl,
          fallbackUrl: fallbackUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final dynamic song;
  final AnimationController waveController;
  final bool isPlaying;

  const _TrackInfo({
    required this.song,
    required this.waveController,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isPlaying) ...[
              _NowPlayingWave(controller: waveController),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                song.title,
                style: const TextStyle(
                  fontFamily: 'Unageo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        TrackMetadataLinks(
          track: song,
          style: TextStyle(
            fontFamily: 'Unageo',
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _NowPlayingWave extends StatelessWidget {
  final AnimationController controller;
  const _NowPlayingWave({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(18, 14),
          painter: _WavePainter(
            progress: controller.value,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const barCount = 4;
    final spacing = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final phase = i * 0.8;
      final amplitude = size.height * 0.4;
      final wave = sin((progress * 2 * pi) + phase);
      final barHeight = (amplitude * (wave + 1) / 2) + (size.height * 0.15);

      final x = (i * spacing) + spacing / 2;
      final top = (size.height - barHeight) / 2;
      final bottom = top + barHeight;

      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PlayPauseButton extends StatelessWidget {
  final MiniPlayerState state;
  const _PlayPauseButton({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading || state.isResolving) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    }

    if (state.isCompleted) {
      return _ControlButton(
        icon: FontAwesome.rotate_right_solid,
        size: 22,
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.read<BloomeePlayerCubit>().bloomeePlayer.rewind();
        },
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        state.isPlaying
            ? context.read<BloomeePlayerCubit>().bloomeePlayer.pause()
            : context.read<BloomeePlayerCubit>().bloomeePlayer.play();
      },
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), width: 0.5),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              state.isPlaying
                  ? FontAwesome.pause_solid
                  : FontAwesome.play_solid,
              key: ValueKey(state.isPlaying),
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon,
              size: size, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
    );
  }
}

class _GlowingProgressBar extends StatelessWidget {
  const _GlowingProgressBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 3,
      child: StreamBuilder<ProgressBarStreams>(
        stream: context.watch<BloomeePlayerCubit>().progressStreams,
        builder: (context, snapshot) {
          double fraction = 0;
          if (snapshot.hasData && snapshot.data!.duration != Duration.zero) {
            fraction = (snapshot.data!.position.inMilliseconds /
                    snapshot.data!.duration.inMilliseconds)
                .clamp(0.0, 1.0);
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * fraction;
              return Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: width,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Default_Theme.accentColor2
                                .withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    height: 3,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(2),
                        ),
                        gradient: LinearGradient(colors: [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.6),
                        ]),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
