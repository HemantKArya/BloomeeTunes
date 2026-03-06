import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/custom_switch.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

// ─── EQ Presets ─────────────────────────────────────────────────────────────

const Map<String, List<double>> _kPresets = {
  'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  'Rock': [4, 3, 1, 0, -1, -1, 0, 2, 3, 4],
  'Pop': [-1, 2, 4, 4, 2, 0, -1, -1, 2, 3],
  'Acoustic': [3, 2, 1, 0, 0, 0, 1, 2, 2, 3],
  'EDM': [4, 3, 1, 0, -1, 1, 0, 1, 3, 4],
  'Metal': [4, 3, 0, -1, 1, 0, 1, 0, 2, 3],
  'Live': [2, 1, 0, 1, 1, 2, 2, 1, 0, 0],
  'Bass Boost': [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
  'Treble': [0, 0, 0, 0, 0, 0, 2, 4, 5, 6],
  'Vocal': [-2, -1, 0, 2, 4, 4, 3, 1, 0, -1],
};

// ─── Main View ──────────────────────────────────────────────────────────────

class EqualizerView extends StatefulWidget {
  const EqualizerView({super.key});

  @override
  State<EqualizerView> createState() => _EqualizerViewState();
}

class _EqualizerViewState extends State<EqualizerView>
    with TickerProviderStateMixin {
  late PlayerEngine _engine;
  late SettingsCubit _settingsCubit;

  late List<double> _currentGains;
  late List<double> _animStartGains;
  String _selectedPreset = 'Flat';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _curveCtrl;
  late Animation<double> _curveAnim;

  static const double _minGain = -15;
  static const double _maxGain = 15;

  static const double _graphHeight = 280.0;
  int? _draggingBandIndex;

  @override
  void initState() {
    super.initState();
    _engine = context.read<BloomeePlayerCubit>().bloomeePlayer.engine;
    _settingsCubit = context.read<SettingsCubit>();

    _currentGains =
        _engine.equalizerBands.map((b) => b.gain).toList(growable: false);
    _animStartGains = List.filled(_currentGains.length, 0.0);

    _selectedPreset = _settingsCubit.state.eqPreset;
    if (_selectedPreset != _matchingPreset()) {
      _selectedPreset = _matchingPreset();
    }

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _curveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _curveAnim =
        CurvedAnimation(parent: _curveCtrl, curve: Curves.easeOutCubic);
    _curveCtrl.forward();
  }

  @override
  void dispose() {
    _settingsCubit.setEqBandGains(List<double>.from(_currentGains));
    _settingsCubit.setEqPreset(_selectedPreset);
    _fadeCtrl.dispose();
    _curveCtrl.dispose();
    super.dispose();
  }

  // ─── Logic ──────────────────────────────────────────────────────────────

  void _onBandChanged(int index, double value) {
    setState(() {
      _currentGains[index] = value;
      _animStartGains[index] = value;
      _selectedPreset = _matchingPreset();
    });
    // Deliberately NOT updating audio engine here.
    // This perfectly prevents audio tearing/stuttering while drawing the curve.
  }

  void _onBandChangeEnd(int index) {
    // Apply audio feedback ONLY when the user releases their finger.
    _engine.setEqualizerBandGain(index, _currentGains[index], immediate: true);
    _settingsCubit.setEqBandGains(List<double>.from(_currentGains));
    _settingsCubit.setEqPreset(_selectedPreset);
  }

  void _applyPreset(String name) {
    final values = _kPresets[name];
    if (values == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedPreset = name;
      _animStartGains = List.from(_currentGains);
      for (var i = 0; i < _currentGains.length && i < values.length; i++) {
        _currentGains[i] = values[i];
      }
    });

    _curveCtrl.forward(from: 0);
    _engine.setEqualizerBandGains(_currentGains, immediate: true);
    _settingsCubit.setEqBandGains(List<double>.from(_currentGains));
    _settingsCubit.setEqPreset(name);
  }

  void _resetEQ() {
    HapticFeedback.mediumImpact();
    _engine.resetEqualizer();
    setState(() {
      _animStartGains = List.from(_currentGains);
      for (var i = 0; i < _currentGains.length; i++) {
        _currentGains[i] = 0;
      }
      _selectedPreset = 'Flat';
    });

    _curveCtrl.forward(from: 0);
    _settingsCubit.setEqBandGains(List<double>.from(_currentGains));
    _settingsCubit.setEqPreset('Flat');
  }

  String _matchingPreset() {
    for (final entry in _kPresets.entries) {
      bool match = true;
      for (var i = 0; i < _currentGains.length && i < entry.value.length; i++) {
        if ((_currentGains[i] - entry.value[i]).abs() > 0.5) {
          match = false;
          break;
        }
      }
      if (match) return entry.key;
    }
    return 'Custom';
  }

  String _freqLabel(double hz) {
    if (hz >= 1000) {
      double k = hz / 1000;
      return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return hz.toInt().toString();
  }

  // ─── Gesture Handling ────────────────────────────────────────────────────

  void _handleGraphPanStart(
      DragDownDetails details, BoxConstraints constraints) {
    if (!_engine.equalizerEnabled) return;
    _updateDragInteraction(details.localPosition, constraints.maxWidth);
  }

  void _handleGraphPanUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    if (!_engine.equalizerEnabled) return;
    _updateDragInteraction(details.localPosition, constraints.maxWidth);
  }

  void _updateDragInteraction(Offset localPosition, double width) {
    final N = _currentGains.length;
    final bandWidth = width / (N > 1 ? N - 1 : 1);

    final index = (localPosition.dx / bandWidth).round().clamp(0, N - 1);

    if (_draggingBandIndex != index) {
      if (_draggingBandIndex != null) _onBandChangeEnd(_draggingBandIndex!);
      setState(() => _draggingBandIndex = index);
    }

    _updateGainFromPan(localPosition.dy);
  }

  void _updateGainFromPan(double localY) {
    const topPad = 30.0;
    const bottomPad = 50.0;
    const availableHeight = _graphHeight - topPad - bottomPad;

    double fraction = 1.0 - ((localY - topPad) / availableHeight);
    fraction = fraction.clamp(0.0, 1.0);

    double newGain = _minGain + fraction * (_maxGain - _minGain);

    if (newGain.abs() < 0.6) {
      if (_currentGains[_draggingBandIndex!] != 0.0) {
        HapticFeedback.selectionClick();
      }
      newGain = 0.0;
    }

    _onBandChanged(_draggingBandIndex!, newGain);
  }

  void _handleGraphPanEnd(DragEndDetails details) {
    if (_draggingBandIndex != null) {
      _onBandChangeEnd(_draggingBandIndex!);
      setState(() => _draggingBandIndex = null);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bands = _engine.equalizerBands;
    final isEnabled = _engine.equalizerEnabled;
    const accent = Default_Theme.accentColor2;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildPresetTabs(accent),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Main Equalizer Card ──
                      _PremiumFlatCard(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Equalizer',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                BloomeeSwitch(
                                  value: isEnabled,
                                  onChanged: () {
                                    _engine.setEqualizerEnabled(!isEnabled);
                                    _settingsCubit.setEqEnabled(!isEnabled);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // ── The Spline Graph ──
                            AnimatedOpacity(
                              opacity: isEnabled ? 1.0 : 0.3,
                              duration: const Duration(milliseconds: 300),
                              child: SizedBox(
                                height: _graphHeight,
                                width: double.infinity,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanDown: (d) =>
                                          _handleGraphPanStart(d, constraints),
                                      onPanUpdate: (d) =>
                                          _handleGraphPanUpdate(d, constraints),
                                      onPanEnd: _handleGraphPanEnd,
                                      onPanCancel: () => setState(
                                          () => _draggingBandIndex = null),
                                      child: AnimatedBuilder(
                                        animation: _curveAnim,
                                        builder: (context, _) {
                                          return CustomPaint(
                                            size: Size(constraints.maxWidth,
                                                constraints.maxHeight),
                                            painter: _InteractiveEQPainter(
                                              startGains: _animStartGains,
                                              targetGains: _currentGains,
                                              minGain: _minGain,
                                              maxGain: _maxGain,
                                              accentColor: accent,
                                              animValue: _curveAnim.value,
                                              frequencies: bands
                                                  .map((b) => _freqLabel(
                                                      b.centerFrequency))
                                                  .toList(),
                                              draggingIndex: _draggingBandIndex,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Equalizer',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          IconButton(
            tooltip: 'Reset to Flat',
            icon: Icon(Icons.refresh_rounded,
                color: Colors.white.withOpacity(0.7), size: 22),
            onPressed: _resetEQ,
          ),
        ],
      ),
    );
  }

  // ─── Preset Tabs ────────────────────────────────────────────────────────

  Widget _buildPresetTabs(Color accent) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _kPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final name = _kPresets.keys.elementAt(index);
          final isActive = name == _selectedPreset;
          return GestureDetector(
            onTap: () => _applyPreset(name),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive ? accent : Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                child: Text(name),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Flat Premium Card (Lower Opacity to remove the ugly grey box)
// ═══════════════════════════════════════════════════════════════════════════════

class _PremiumFlatCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PremiumFlatCard({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        // Extremely low opacity white to barely separate it from the theme background
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Interactive EQ Graph Painter
// ═══════════════════════════════════════════════════════════════════════════════

class _InteractiveEQPainter extends CustomPainter {
  final List<double> startGains;
  final List<double> targetGains;
  final double minGain;
  final double maxGain;
  final Color accentColor;
  final double animValue;
  final List<String> frequencies;
  final int? draggingIndex;

  _InteractiveEQPainter({
    required this.startGains,
    required this.targetGains,
    required this.minGain,
    required this.maxGain,
    required this.accentColor,
    required this.animValue,
    required this.frequencies,
    this.draggingIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final N = targetGains.length;
    if (N == 0) return;

    const topPad = 30.0;
    const bottomPad = 40.0;
    final availableHeight = h - topPad - bottomPad;
    final zeroY = topPad + availableHeight / 2;

    // ── 0 dB Center Line ──
    final zeroPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, zeroY), Offset(w, zeroY), zeroPaint);

    // ── Calculate Points ──
    final points = <Offset>[];
    for (var i = 0; i < N; i++) {
      final x = w * i / (N > 1 ? N - 1 : 1);
      final currentGain =
          ui.lerpDouble(startGains[i], targetGains[i], animValue) ?? 0.0;
      final normalized = 1.0 - ((currentGain - minGain) / (maxGain - minGain));
      final y = topPad + (normalized.clamp(0.0, 1.0) * availableHeight);
      points.add(Offset(x, y));
    }

    // ── Draw Stems (Lines above and below nodes) ──
    for (var i = 0; i < N; i++) {
      // Faint trace line above the node
      canvas.drawLine(
        Offset(points[i].dx, topPad - 15),
        Offset(points[i].dx, points[i].dy),
        Paint()
          ..color = Colors.white.withOpacity(0.04)
          ..strokeWidth = 1.2,
      );

      // Gradient dropping down directly from the node (matches prototype)
      final bottomStemPaint = Paint()
        ..strokeWidth = 1.5
        ..shader = ui.Gradient.linear(
          Offset(points[i].dx, points[i].dy),
          Offset(points[i].dx, h - bottomPad),
          [accentColor.withOpacity(0.5), accentColor.withOpacity(0.0)],
        );

      canvas.drawLine(
        Offset(points[i].dx, points[i].dy),
        Offset(points[i].dx, h - bottomPad),
        bottomStemPaint,
      );
    }

    // ── Smooth Spline Curve ──
    final curvePath = Path();
    curvePath.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      curvePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // ── Very Subtle Gradient Fill Below Curve ──
    final fillPath = Path.from(curvePath);
    fillPath.lineTo(w, h - bottomPad);
    fillPath.lineTo(0, h - bottomPad);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, topPad),
        Offset(0, h - bottomPad),
        [
          accentColor.withOpacity(0.08), // Greatly reduced so it's ultra clean
          accentColor.withOpacity(0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // ── Bright Colored Stroke ──
    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0 // Thicker to match image
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curvePath, strokePaint);

    // ── Nodes (Large with dark outline) ──
    for (var i = 0; i < N; i++) {
      final isDragging = i == draggingIndex;

      // Outer thick dark circle to "cut out" the line
      canvas.drawCircle(
        points[i],
        isDragging ? 9.5 : 8.0, // Larger size
        Paint()..color = const Color(0xFF141416), // Deep dark grey/black
      );

      // Inner thick bright circle
      canvas.drawCircle(
        points[i],
        isDragging ? 5.5 : 4.5,
        Paint()..color = accentColor,
      );
    }

    // ── Frequency Labels ──
    for (var i = 0; i < N; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: frequencies[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(points[i].dx - (textPainter.width / 2), h - bottomPad + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveEQPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.targetGains != targetGains ||
        oldDelegate.draggingIndex != draggingIndex;
  }
}
