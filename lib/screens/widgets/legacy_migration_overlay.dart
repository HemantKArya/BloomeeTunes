/// Non-closable migration overlay shown when a legacy default.isar database
/// is detected on startup.
///
/// Placed as an opaque full-screen layer above the app.  The user must wait
/// for migration to finish (or fail) and then manually tap "Continue" (or
/// "Retry") to dismiss the overlay.
///
/// To remove this entire feature later, delete:
///   • lib/services/db/legacy/
///   • lib/screens/widgets/legacy_migration_overlay.dart
///   • The call-site in lib/main.dart
library;

import 'dart:math' as math;

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/db/legacy/legacy_migration_service.dart'
    as migration_service;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum _Phase { running, success, failed }

class LegacyMigrationOverlay extends StatefulWidget {
  const LegacyMigrationOverlay({
    required this.appSuppDir,
    required this.appDocDir,
    required this.onComplete,
    super.key,
  });

  final String appSuppDir;
  final String appDocDir;
  final void Function(migration_service.MigrationResult result) onComplete;

  @override
  State<LegacyMigrationOverlay> createState() => _LegacyMigrationOverlayState();
}

class _LegacyMigrationOverlayState extends State<LegacyMigrationOverlay>
    with TickerProviderStateMixin {
  // ── Colors & Styling ───────────────────────────────────────────────────
  static const _maxContentWidth = 500.0;
  static const _bgBase = Color(0xFF060608); // Ultra deep cinematic dark
  static const _surfaceCol = Color(0xFF14141A);
  static const _errorAccent = Color(0xFFFF4C4C);
  static const _successAccent = Color(0xFFFF2A5F); // Bloomee Pink/Red

  // ── State (Isolated for Zero Jank) ─────────────────────────────────────
  final ValueNotifier<_Phase> _phase = ValueNotifier(_Phase.running);
  final ValueNotifier<double> _progress = ValueNotifier(0.0);
  final ValueNotifier<String> _stepLabel = ValueNotifier('Initializing...');
  migration_service.MigrationResult? _result;

  @override
  void initState() {
    super.initState();
    _runMigration();
  }

  @override
  void dispose() {
    _phase.dispose();
    _progress.dispose();
    _stepLabel.dispose();
    super.dispose();
  }

  Future<void> _runMigration() async {
    if (_phase.value == _Phase.running && _result != null) return;

    _phase.value = _Phase.running;
    _result = null;
    _progress.value = 0.0;
    _stepLabel.value = 'Preparing environment...';

    final result = await migration_service.runMigration(
      appSuppDir: widget.appSuppDir,
      appDocDir: widget.appDocDir,
      onProgress: (step, progress) {
        _stepLabel.value = step;
        _progress.value = progress;
      },
    );

    if (!mounted) return;

    _progress.value = result.success ? 1.0 : _progress.value.clamp(0.0, 0.99);
    if (result.statusMessage?.isNotEmpty == true) {
      _stepLabel.value = result.statusMessage!;
    }

    _result = result;
    // Slight delay so the progress ring hits 100% before transitioning
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _phase.value = result.success ? _Phase.success : _Phase.failed;
    }
  }

  void _dismiss() {
    if (_result != null) widget.onComplete(_result!);
  }

  Color get _accent =>
      _phase.value == _Phase.failed ? _errorAccent : _successAccent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bgBase,
      child: Stack(
        children: [
          // 1. Soft Cinematic Dust Background
          const Positioned.fill(
            child: RepaintBoundary(child: _CinematicDustBackground()),
          ),

          // 2. Fluid, Overflow-Proof Layout
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Spacers allow natural centering that glides upwards when HUD appears
                              const Spacer(flex: 3),

                              // Visualizer Orb
                              _buildCosmicOrbiter(),
                              const SizedBox(height: 32),

                              // Text & Headlines
                              _buildHeadlines(),

                              // The Dashboard HUD (Smoothly expands without jumping)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: ValueListenableBuilder<_Phase>(
                                  valueListenable: _phase,
                                  builder: (context, phase, _) {
                                    if (phase == _Phase.running) {
                                      return const SizedBox(
                                          width: double.infinity, height: 40);
                                    }
                                    return _buildCompletionHUD();
                                  },
                                ),
                              ),
                              const Spacer(flex: 4),
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
        ],
      ),
    );
  }

  Widget _buildCosmicOrbiter() {
    return ValueListenableBuilder<_Phase>(
      valueListenable: _phase,
      builder: (context, phase, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 900),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: phase == _Phase.running
              ? _ProgressRing(
                  progressNotifier: _progress, accentColor: _successAccent)
              : _AnimatedSuccessMark(
                  isSuccess: phase == _Phase.success, color: _accent),
        );
      },
    );
  }

  Widget _buildHeadlines() {
    return ValueListenableBuilder<_Phase>(
      valueListenable: _phase,
      builder: (context, phase, _) {
        final title = switch (phase) {
          _Phase.running => 'Upgrading Bloomee',
          _Phase.success => 'Welcome to Bloomee 3.0',
          _Phase.failed => 'Migration Aborted',
        };

        return AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  title,
                  key: ValueKey(title),
                  textAlign: TextAlign.center,
                  style: AppTheme.primaryTextStyle.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: _stepLabel,
                builder: (context, step, _) {
                  final desc = switch (phase) {
                    _Phase.running => step,
                    _Phase.success =>
                      'Your universe is ready. Everything has been seamlessly teleported to the new engine.',
                    _Phase.failed =>
                      'A core error occurred. Your original data remains untouched and safe.',
                  };

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      desc,
                      key: ValueKey(desc),
                      textAlign: TextAlign.center,
                      style: AppTheme.secondoryTextStyle.copyWith(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletionHUD() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          if (_result != null) _buildHUDGrid(_result!),
          const SizedBox(height: 36),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHUDGrid(migration_service.MigrationResult r) {
    if (_phase.value == _Phase.failed) return _errorCard(r);

    return Column(
      children: [
        Text(
          'MIGRATION SUMMARY',
          style: AppTheme.primaryTextStyle.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _StatChip(
                icon: Icons.queue_music_rounded,
                label: 'Playlists',
                value: '${r.playlistsMigrated}'),
            _StatChip(
                icon: Icons.audiotrack_rounded,
                label: 'Tracks',
                value: '${r.tracksMigrated}'),
            _StatChip(
                icon: Icons.favorite_rounded,
                label: 'Liked',
                value: '${r.likedTracksMigrated}'),
            _StatChip(
                icon: Icons.download_done_rounded,
                label: 'Offline',
                value: '${r.downloadsMigrated}'),
            _StatChip(
                icon: Icons.folder_copy_rounded,
                label: 'Collections',
                value: '${r.collectionsMigrated}'),
            _StatChip(
                icon: Icons.tune_rounded,
                label: 'Settings',
                value: '${r.settingsMigrated}'),
            if (r.skippedTracks > 0)
              _StatChip(
                  icon: Icons.warning_rounded,
                  label: 'Skipped',
                  value: '${r.skippedTracks}',
                  isWarning: true),
          ],
        ),
      ],
    );
  }

  Widget _errorCard(migration_service.MigrationResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _errorAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: _errorAccent.withValues(alpha: 0.9), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              r.error ?? 'Unknown sector collision.',
              style: AppTheme.secondoryTextStyle.copyWith(
                fontSize: 13,
                color: _errorAccent.withValues(alpha: 0.95),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isErr = _phase.value == _Phase.failed;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isErr)
            BoxShadow(
              color: _successAccent.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: FilledButton(
        onPressed: isErr ? _runMigration : _dismiss,
        style: FilledButton.styleFrom(
          backgroundColor: isErr ? _surfaceCol : _successAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isErr
                ? BorderSide(color: _errorAccent.withValues(alpha: 0.3))
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          isErr ? 'Retry Migration' : 'Enter Bloomee',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. Cinematic Bokeh Dust (No hard dots, soft focus)
// ═════════════════════════════════════════════════════════════════════════════

class _CinematicDustBackground extends StatefulWidget {
  const _CinematicDustBackground();

  @override
  State<_CinematicDustBackground> createState() =>
      _CinematicDustBackgroundState();
}

class _CinematicDustBackgroundState extends State<_CinematicDustBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _DustEngine _engine = _DustEngine();
  Duration _lastTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
      _lastTime = elapsed;
      _engine.update(dt);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DustPainter(_engine),
      size: Size.infinite,
    );
  }
}

class _Dust {
  double x, y, size, speed, windScale, phaseOffset, opacity;
  _Dust(this.x, this.y, this.size, this.speed, this.windScale, this.phaseOffset,
      this.opacity);
}

class _DustEngine extends ChangeNotifier {
  final List<_Dust> particles = [];
  final math.Random rnd = math.Random();
  double width = 0, height = 0;
  double _time = 0;
  bool _initialized = false;

  void _init(Size size) {
    width = size.width;
    height = size.height;
    // Lower count, larger, blurry particles
    for (int i = 0; i < 40; i++) {
      particles.add(_Dust(
        rnd.nextDouble() * width,
        rnd.nextDouble() * height,
        rnd.nextDouble() * 4.0 + 1.0,
        rnd.nextDouble() * 10 + 5,
        rnd.nextDouble() * 10 + 2,
        rnd.nextDouble() * math.pi * 2,
        rnd.nextDouble() * 0.15 + 0.05, // Very faint
      ));
    }
    _initialized = true;
  }

  void update(double dt) {
    if (!_initialized) return;
    _time += dt;

    for (var p in particles) {
      p.y += p.speed * dt;
      p.x += math.sin(_time * 0.5 + p.phaseOffset) * p.windScale * dt;

      if (p.y > height + 20) {
        p.y = -20;
        p.x = rnd.nextDouble() * width;
      }
    }
    notifyListeners();
  }
}

class _DustPainter extends CustomPainter {
  final _DustEngine engine;
  _DustPainter(this.engine) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    if (!engine._initialized) engine._init(size);

    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in engine.particles) {
      paint.color = Colors.white.withValues(alpha: p.opacity);
      // Softens the particles so they look like cinematic dust
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. The Custom Vector Animated Success Mark & Progress Orb
// ═════════════════════════════════════════════════════════════════════════════

class _ProgressRing extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;
  final Color accentColor;
  const _ProgressRing(
      {required this.progressNotifier, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (context, progress, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    return CustomPaint(
                        painter: _SleekRingPainter(val, accentColor));
                  },
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTheme.primaryTextStyle.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SleekRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _SleekRingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    canvas.drawArc(rect, start, sweep, false, glowPaint);
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_SleekRingPainter old) => old.progress != progress;
}

class _AnimatedSuccessMark extends StatelessWidget {
  final bool isSuccess;
  final Color color;
  const _AnimatedSuccessMark({required this.isSuccess, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 50,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: isSuccess
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return CustomPaint(
                    size: const Size(60, 60),
                    painter: _CheckmarkPainter(val, color),
                  );
                },
              )
            : Icon(Icons.close_rounded, size: 48, color: color),
      ),
    );
  }
}

// ── The Beautiful Custom Drawn Vector Checkmark ──
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CheckmarkPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.0;

    final path = Path();
    // Start left
    path.moveTo(size.width * 0.25, size.height * 0.5);
    // Down to middle
    path.lineTo(size.width * 0.45, size.height * 0.7);
    // Up to right
    path.lineTo(size.width * 0.8, size.height * 0.3);

    // Animates the drawing of the path
    final metrics = path.computeMetrics();
    final extract = Path();
    for (var metric in metrics) {
      extract.addPath(
        metric.extractPath(0.0, metric.length * progress),
        Offset.zero,
      );
    }

    // Glow effect for the checkmark itself
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(extract, glowPaint);
    canvas.drawPath(extract, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. Premium Data Chips
// ═════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isWarning;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isWarning ? const Color(0xFFFF8A65) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A), // Deep surface
        borderRadius: BorderRadius.circular(10), // Sleek, less bubbly
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: baseColor.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.secondoryTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: baseColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color:
                  isWarning ? baseColor : Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
