import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWaveformSeekbar extends StatefulWidget {
  final Duration progress;
  final Duration total;
  final Duration buffered;
  final Function(Duration) onSeek;
  final bool isPlaying;
  final Color activeColor;
  final Color inactiveColor;
  final Color bufferedColor;
  final double height;
  final int waveformBars;

  const AnimatedWaveformSeekbar({
    super.key,
    required this.progress,
    required this.total,
    required this.buffered,
    required this.onSeek,
    required this.isPlaying,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.bufferedColor = Colors.blueGrey,
    this.height = 40.0,
    this.waveformBars = 50,
  });

  @override
  State<AnimatedWaveformSeekbar> createState() =>
      _AnimatedWaveformSeekbarState();
}

class _AnimatedWaveformSeekbarState extends State<AnimatedWaveformSeekbar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<double> _waveformHeights;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();

    // Main animation controller for wave effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Generate random waveform heights
    _generateWaveform();

    // Create individual controllers for each bar
    _createBarAnimations();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _generateWaveform() {
    final random = Random();
    _waveformHeights = List.generate(widget.waveformBars, (index) {
      // Create more realistic waveform pattern
      double baseHeight = 0.3 + (sin(index * 0.3) * 0.4).abs();
      double randomVariation = 0.2 + random.nextDouble() * 0.6;
      return (baseHeight + randomVariation).clamp(0.2, 1.0);
    });
  }

  void _createBarAnimations() {
    _barControllers = [];
    _barAnimations = [];

    for (int i = 0; i < widget.waveformBars; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 800 + Random().nextInt(400)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: _waveformHeights[i] * 0.3,
        end: _waveformHeights[i],
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _barControllers.add(controller);
      _barAnimations.add(animation);
    }
  }

  void _startAnimations() {
    _animationController.repeat(reverse: true);

    // Start bar animations with staggered delays
    for (int i = 0; i < _barControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && widget.isPlaying) {
          _barControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    _animationController.stop();
    for (var controller in _barControllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(AnimatedWaveformSeekbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.progress),
                style: TextStyle(
                  fontSize: 12,
                  color: widget.activeColor.withOpacity(0.8),
                ),
              ),
              Text(
                _formatDuration(widget.total),
                style: TextStyle(
                  fontSize: 12,
                  color: widget.inactiveColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Waveform seekbar
        GestureDetector(
          onTapDown: (details) => _handleSeek(details.localPosition),
          onPanUpdate: (details) => _handleSeek(details.localPosition),
          child: Container(
            height: widget.height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomPaint(
              painter: WaveformPainter(
                progress: widget.progress,
                total: widget.total,
                buffered: widget.buffered,
                activeColor: widget.activeColor,
                inactiveColor: widget.inactiveColor,
                bufferedColor: widget.bufferedColor,
                waveformHeights: _waveformHeights,
                barAnimations: _barAnimations,
                isPlaying: widget.isPlaying,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSeek(Offset localPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double seekPosition =
        (localPosition.dx - 8) / (renderBox.size.width - 16);
    final Duration seekTime = Duration(
      milliseconds:
          (widget.total.inMilliseconds * seekPosition.clamp(0.0, 1.0)).round(),
    );
    widget.onSeek(seekTime);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class WaveformPainter extends CustomPainter {
  final Duration progress;
  final Duration total;
  final Duration buffered;
  final Color activeColor;
  final Color inactiveColor;
  final Color bufferedColor;
  final List<double> waveformHeights;
  final List<Animation<double>> barAnimations;
  final bool isPlaying;

  WaveformPainter({
    required this.progress,
    required this.total,
    required this.buffered,
    required this.activeColor,
    required this.inactiveColor,
    required this.bufferedColor,
    required this.waveformHeights,
    required this.barAnimations,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double progressRatio = total.inMilliseconds > 0
        ? progress.inMilliseconds / total.inMilliseconds
        : 0.0;
    final double bufferedRatio = total.inMilliseconds > 0
        ? buffered.inMilliseconds / total.inMilliseconds
        : 0.0;

    final double barWidth = size.width / waveformHeights.length;
    final double centerY = size.height / 2;

    for (int i = 0; i < waveformHeights.length; i++) {
      final double x = i * barWidth;
      final double barProgress = i / waveformHeights.length;

      // Get animated height if playing, otherwise use static height
      double barHeight = isPlaying && i < barAnimations.length
          ? barAnimations[i].value * size.height * 0.8
          : waveformHeights[i] * size.height * 0.4;

      // Determine bar color based on progress
      Color barColor;
      if (barProgress <= progressRatio) {
        barColor = activeColor;
      } else if (barProgress <= bufferedRatio) {
        barColor = bufferedColor;
      } else {
        barColor = inactiveColor;
      }

      // Add glow effect for active bars
      if (barProgress <= progressRatio && isPlaying) {
        final glowPaint = Paint()
          ..color = activeColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + barWidth / 2, centerY),
              width: barWidth * 0.8,
              height: barHeight + 4,
            ),
            const Radius.circular(2),
          ),
          glowPaint,
        );
      }

      // Draw the main bar
      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, centerY),
            width: barWidth * 0.6,
            height: barHeight,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
