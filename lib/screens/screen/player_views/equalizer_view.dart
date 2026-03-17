import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/custom_switch.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

// ─── Extended Pro-Audio EQ Presets ───────────────────────────────────────────

const Map<String, List<double>> _kPresets = {
  'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  'Acoustic': [3, 2, 1, 0, 0, 0, 1, 2, 2, 3],
  'Bass Boost': [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
  'Bass Reducer': [-6, -5, -4, -2, 0, 0, 0, 0, 0, 0],
  'Classical': [0, 0, 0, 0, 0, 0, -1, -2, -3, -4],
  'Dance': [5, 4, 2, 0, 0, -1, -1, 0, 1, 2],
  'Deep': [4, 3, 2, 1, 0, 0, 1, 2, 3, 4],
  'EDM': [4, 3, 1, 0, -1, 1, 0, 1, 3, 4],
  'Electronic': [4, 3, 1, 0, -2, 2, 0, 1, 3, 4],
  'Hip-Hop': [5, 4, 1, 0, -1, -1, 0, 1, 2, 3],
  'Jazz': [2, 1, 0, -1, -1, 0, 1, 2, 3, 3],
  'Latin': [3, 2, 0, 0, -1, -1, -1, 0, 2, 3],
  'Live': [2, 1, 0, 1, 1, 2, 2, 1, 0, 0],
  'Lounge': [2, 1, 0, 0, 0, 0, 0, 0, 1, 2],
  'Metal': [4, 3, 0, -1, 1, 0, 1, 0, 2, 3],
  'Piano': [1, 1, 0, 2, 3, 3, 2, 1, 0, 0],
  'Pop': [-1, 2, 4, 4, 2, 0, -1, -1, 2, 3],
  'R&B': [3, 2, 1, 0, -1, 0, 1, 2, 2, 3],
  'Rock': [4, 3, 1, 0, -1, -1, 0, 2, 3, 4],
  'Small Speakers': [5, 4, 3, 2, 1, 0, -1, -2, -3, -4],
  'Spoken Word': [-3, -2, -1, 2, 4, 4, 2, 0, -1, -2],
  'Treble Boost': [0, 0, 0, 0, 0, 0, 2, 4, 5, 6],
  'Treble Reducer': [0, 0, 0, 0, 0, 0, -2, -4, -5, -6],
  'Vocal Booster': [-2, -1, 0, 2, 4, 4, 3, 1, 0, -1],
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
    // Deliberately NOT updating audio engine here to prevent audio tearing/stuttering while drawing.
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

    // Magnetic snap to exactly 0 dB
    if (newGain.abs() < 0.6) {
      if (_currentGains[_draggingBandIndex!] != 0.0)
        HapticFeedback.selectionClick();
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
    final l10n = AppLocalizations.of(context)!;
    final bands = _engine.equalizerBands;
    final isEnabled = _engine.equalizerEnabled;
    const accent = Default_Theme.accentColor2;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.eqTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.eqResetTooltip,
            icon: Icon(Icons.refresh_rounded,
                color: Colors.white.withValues(alpha: 0.8), size: 22),
            onPressed: _resetEQ,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Presets Section ──
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12),
                    child: Text(
                      'PRESETS',
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildPresetTabs(accent),

                  const SizedBox(height: 32),

                  // ── Main Equalizer Card ──
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12),
                    child: Text(
                      'CUSTOM CURVE',
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.05),
                            width: 1),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.eqTitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
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
                          const SizedBox(height: 24),

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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Compact Preset Tabs ───────────────────────────────────────────────────

  Widget _buildPresetTabs(Color accent) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: 20), // Starts aligned with titles
        itemCount: _kPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = _kPresets.keys.elementAt(index);
          final isActive = name == _selectedPreset;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _applyPreset(name),
              borderRadius: BorderRadius.circular(18),
              splashColor: accent.withValues(alpha: 0.1),
              highlightColor: accent.withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? accent.withValues(alpha: 0.15)
                      : Default_Theme.primaryColor1.withValues(alpha: 0.04),
                  borderRadius:
                      BorderRadius.circular(18), // Perfectly pill shaped
                  border: Border.all(
                    color: isActive
                        ? accent.withValues(alpha: 0.5)
                        : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                    width: 1.0, // Thinner, sharper border
                  ),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: isActive
                        ? accent
                        : Default_Theme.primaryColor1.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Interactive EQ Graph Painter

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
    const bottomPad = 44.0;
    final availableHeight = h - topPad - bottomPad;
    final zeroY = topPad + availableHeight / 2;

    // ── 0 dB Center Line ──
    final zeroPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
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

    // ── Draw Stems ──
    for (var i = 0; i < N; i++) {
      canvas.drawLine(
        Offset(points[i].dx, topPad - 15),
        Offset(points[i].dx, h - bottomPad),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.03)
          ..strokeWidth = 1.5,
      );

      // Gradient drop from the node to the bottom
      final bottomStemPaint = Paint()
        ..strokeWidth = 2.0
        ..shader = ui.Gradient.linear(
          Offset(points[i].dx, points[i].dy),
          Offset(points[i].dx, h - bottomPad),
          [
            accentColor.withValues(alpha: 0.4),
            accentColor.withValues(alpha: 0.0)
          ],
        );

      canvas.drawLine(Offset(points[i].dx, points[i].dy),
          Offset(points[i].dx, h - bottomPad), bottomStemPaint);
    }

    // ── Spline Curve ──
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

    // ── Clean Fill Below Curve ──
    final fillPath = Path.from(curvePath);
    fillPath.lineTo(w, h - bottomPad);
    fillPath.lineTo(0, h - bottomPad);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, topPad),
        Offset(0, h - bottomPad),
        [
          accentColor.withValues(alpha: 0.12),
          accentColor.withValues(alpha: 0.0)
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // ── Thick Neon Stroke ──
    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curvePath, strokePaint);

    // ── Hollow Nodes ──
    for (var i = 0; i < N; i++) {
      final isDragging = i == draggingIndex;

      // Dark background cutout
      canvas.drawCircle(
        points[i],
        isDragging ? 10.0 : 8.5,
        Paint()..color = Default_Theme.themeColor,
      );

      // Bright thick rim
      canvas.drawCircle(
        points[i],
        isDragging ? 8.0 : 6.5,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      // Solid inner core when dragging
      if (isDragging) {
        canvas.drawCircle(points[i], 3.0, Paint()..color = accentColor);
      }
    }

    // ── Frequency Labels ──
    for (var i = 0; i < N; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: frequencies[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(points[i].dx - (textPainter.width / 2), h - bottomPad + 14),
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
