import 'dart:ui';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/services/player/player_engine.dart';

class ShortcutIndicatorOverlay extends StatelessWidget {
  final Widget child;

  const ShortcutIndicatorOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          BlocBuilder<ShortcutIndicatorCubit, ShortcutIndicatorState>(
            builder: (context, state) {
              return _ShortcutIndicator(state: state);
            },
          ),
        ],
      ),
    );
  }
}

class _ShortcutIndicator extends StatefulWidget {
  final ShortcutIndicatorState state;

  const _ShortcutIndicator({required this.state});

  @override
  State<_ShortcutIndicator> createState() => _ShortcutIndicatorState();
}

class _ShortcutIndicatorState extends State<_ShortcutIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    if (widget.state.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _ShortcutIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isVisible != oldWidget.state.isVisible) {
      if (widget.state.isVisible) {
        _animationController.forward(from: 0);
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isVisible &&
        _animationController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Center(
                  child: _buildIndicatorContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicatorContent() {
    final type = widget.state.type;
    if (type == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(type),
              const SizedBox(height: 16),
              _buildLabel(type),
              if (_shouldShowProgressBar(type)) ...[
                const SizedBox(height: 16),
                _buildProgressBar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ShortcutIndicatorType type) {
    IconData icon = MingCute.check_circle_fill;
    Color color = Colors.white;

    switch (type) {
      case ShortcutIndicatorType.volume:
        final level = widget.state.volumeLevel ?? 0;
        if (level == 0) {
          icon = MingCute.volume_off_fill;
          color = Colors.white.withValues(alpha: 0.5);
        } else {
          icon = MingCute.volume_fill;
          color = Colors.white.withValues(alpha: 0.9);
        }
        break;

      case ShortcutIndicatorType.mute:
        final isMuted = widget.state.isMuted ?? false;
        icon = isMuted ? MingCute.volume_off_fill : MingCute.volume_fill;
        color = isMuted
            ? Colors.white.withValues(alpha: 0.5)
            : Default_Theme.accentColor2;
        break;

      case ShortcutIndicatorType.shuffle:
        icon = MingCute.shuffle_2_line;
        color = (widget.state.isShuffleOn ?? false)
            ? Default_Theme.accentColor2
            : Colors.white.withValues(alpha: 0.5);
        break;

      case ShortcutIndicatorType.loop:
        final mode = widget.state.loopMode ?? LoopMode.off;
        switch (mode) {
          case LoopMode.off:
            icon = MingCute.repeat_line;
            color = Colors.white.withValues(alpha: 0.5);
            break;
          case LoopMode.one:
            icon = MingCute.repeat_one_line;
            color = Default_Theme.accentColor2;
            break;
          case LoopMode.all:
            icon = MingCute.repeat_line;
            color = Default_Theme.accentColor2;
            break;
        }
        break;

      case ShortcutIndicatorType.like:
        final isLiked = widget.state.isLiked ?? false;
        icon = isLiked ? AntDesign.heart_fill : AntDesign.heart_outline;
        color = isLiked
            ? Default_Theme.accentColor2
            : Colors.white.withValues(alpha: 0.9);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        icon,
        key: ValueKey<IconData>(icon),
        size: 52,
        color: color,
      ),
    );
  }

  Widget _buildLabel(ShortcutIndicatorType type) {
    String label = '';
    Color labelColor = Colors.white.withValues(alpha: 0.9);

    switch (type) {
      case ShortcutIndicatorType.volume:
        final level = widget.state.volumeLevel ?? 0;
        label = '${(level * 100).round()}%';
        break;

      case ShortcutIndicatorType.mute:
        final isMuted = widget.state.isMuted ?? false;
        label = isMuted ? 'Muted' : 'Unmuted';
        if (!isMuted) labelColor = Default_Theme.accentColor2;
        break;

      case ShortcutIndicatorType.shuffle:
        final isOn = widget.state.isShuffleOn ?? false;
        label = isOn ? 'Shuffle On' : 'Shuffle Off';
        if (isOn) labelColor = Default_Theme.accentColor2;
        break;

      case ShortcutIndicatorType.loop:
        final mode = widget.state.loopMode ?? LoopMode.off;
        switch (mode) {
          case LoopMode.off:
            label = 'Repeat Off';
            break;
          case LoopMode.one:
            label = 'Repeat One';
            labelColor = Default_Theme.accentColor2;
            break;
          case LoopMode.all:
            label = 'Repeat All';
            labelColor = Default_Theme.accentColor2;
            break;
        }
        break;

      case ShortcutIndicatorType.like:
        final isLiked = widget.state.isLiked ?? false;
        label = isLiked ? 'Liked' : 'Unliked';
        if (isLiked) labelColor = Default_Theme.accentColor2;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: Text(
        label,
        key: ValueKey<String>(label),
        style: Default_Theme.secondoryTextStyleMedium.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: labelColor,
        ),
      ),
    );
  }

  bool _shouldShowProgressBar(ShortcutIndicatorType type) {
    return type == ShortcutIndicatorType.volume ||
        type == ShortcutIndicatorType.mute;
  }

  Widget _buildProgressBar() {
    final level = widget.state.volumeLevel ?? 0;
    const double barWidth = 120.0;

    return Container(
      width: barWidth,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        width: barWidth * level,
        height: 6,
        decoration: BoxDecoration(
          color: level > 0
              ? Default_Theme.accentColor2
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3),
          boxShadow: level > 0
              ? [
                  BoxShadow(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  )
                ]
              : null,
        ),
      ),
    );
  }
}
