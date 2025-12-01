import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';

/// Global overlay widget that shows animated shortcut indicators.
/// Place this high in the widget tree to show indicators anywhere in the app.
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
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutQuart,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeOutQuart,
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
    } else if (widget.state.isVisible) {
      // State changed but still visible - show update animation
      _animationController.forward(from: 0.7);
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

    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: Default_Theme.themeColor.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(type),
            const SizedBox(height: 12),
            _buildLabel(type),
            if (_shouldShowProgressBar(type)) ...[
              const SizedBox(height: 12),
              _buildProgressBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ShortcutIndicatorType type) {
    final IconData icon;
    final Color color;

    switch (type) {
      case ShortcutIndicatorType.volume:
        final level = widget.state.volumeLevel ?? 0;
        if (level == 0) {
          icon = MingCute.volume_off_fill;
          color = Default_Theme.primaryColor1.withValues(alpha: 0.6);
        } else if (level < 0.3) {
          icon = MingCute.volume_fill;
          color = Default_Theme.primaryColor1;
        } else if (level < 0.7) {
          icon = MingCute.volume_fill;
          color = Default_Theme.primaryColor1;
        } else {
          icon = MingCute.volume_fill;
          color = Default_Theme.primaryColor1;
        }
        break;

      case ShortcutIndicatorType.mute:
        final isMuted = widget.state.isMuted ?? false;
        icon = isMuted ? MingCute.volume_off_fill : MingCute.volume_fill;
        color = isMuted
            ? Default_Theme.primaryColor1.withValues(alpha: 0.6)
            : Default_Theme.accentColor1;
        break;

      case ShortcutIndicatorType.shuffle:
        icon = MingCute.shuffle_2_line;
        color = (widget.state.isShuffleOn ?? false)
            ? Default_Theme.accentColor1
            : Default_Theme.primaryColor1.withValues(alpha: 0.6);
        break;

      case ShortcutIndicatorType.loop:
        final mode = widget.state.loopMode ?? LoopMode.off;
        switch (mode) {
          case LoopMode.off:
            icon = MingCute.repeat_line;
            color = Default_Theme.primaryColor1.withValues(alpha: 0.6);
            break;
          case LoopMode.one:
            icon = MingCute.repeat_one_line;
            color = Default_Theme.accentColor1;
            break;
          case LoopMode.all:
            icon = MingCute.repeat_line;
            color = Default_Theme.accentColor1;
            break;
        }
        break;

      case ShortcutIndicatorType.like:
        final isLiked = widget.state.isLiked ?? false;
        icon = isLiked ? AntDesign.heart_fill : AntDesign.heart_outline;
        color =
            isLiked ? Default_Theme.accentColor2 : Default_Theme.primaryColor1;
        break;
    }

    return Icon(
      icon,
      size: 48,
      color: color,
    );
  }

  Widget _buildLabel(ShortcutIndicatorType type) {
    final String label;
    final Color? labelColor;

    switch (type) {
      case ShortcutIndicatorType.volume:
        final level = widget.state.volumeLevel ?? 0;
        label = '${(level * 100).round()}%';
        labelColor = null;
        break;

      case ShortcutIndicatorType.mute:
        final isMuted = widget.state.isMuted ?? false;
        label = isMuted ? 'Muted' : 'Unmuted';
        labelColor = null;
        break;

      case ShortcutIndicatorType.shuffle:
        final isOn = widget.state.isShuffleOn ?? false;
        label = isOn ? 'Shuffle On' : 'Shuffle Off';
        labelColor = isOn ? Default_Theme.accentColor1 : null;
        break;

      case ShortcutIndicatorType.loop:
        final mode = widget.state.loopMode ?? LoopMode.off;
        switch (mode) {
          case LoopMode.off:
            label = 'Repeat Off';
            labelColor = null;
            break;
          case LoopMode.one:
            label = 'Repeat One';
            labelColor = Default_Theme.accentColor1;
            break;
          case LoopMode.all:
            label = 'Repeat All';
            labelColor = Default_Theme.accentColor1;
            break;
        }
        break;

      case ShortcutIndicatorType.like:
        final isLiked = widget.state.isLiked ?? false;
        label = isLiked ? 'Liked' : 'Unliked';
        labelColor = isLiked ? Default_Theme.accentColor2 : null;
        break;
    }

    return Text(
      label,
      style: Default_Theme.secondoryTextStyleMedium.copyWith(
        fontSize: 16,
        color: labelColor ?? Default_Theme.primaryColor1,
      ),
    );
  }

  bool _shouldShowProgressBar(ShortcutIndicatorType type) {
    return type == ShortcutIndicatorType.volume ||
        type == ShortcutIndicatorType.mute;
  }

  Widget _buildProgressBar() {
    final level = widget.state.volumeLevel ?? 0;

    return SizedBox(
      width: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: level, end: level),
          duration: const Duration(milliseconds: 100),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 0
                    ? Default_Theme.accentColor1
                    : Default_Theme.primaryColor1.withValues(alpha: 0.4),
              ),
            );
          },
        ),
      ),
    );
  }
}
