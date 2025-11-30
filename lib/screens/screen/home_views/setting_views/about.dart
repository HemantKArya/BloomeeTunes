import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:math';

// Color palette
// Darken background slightly for higher contrast against foreground elements
const Color kBackgroundColor = Color(0xFF0B0710);
const Color kPrimaryTextColor = Colors.white;
const Color kSecondaryTextColor = Color(0xFFC3B9CF);
// Make the frosted card a bit less translucent so it reads clearer on darkbg
const Color kCardBackgroundColor = Color.fromRGBO(40, 32, 50, 0.18);

// Gradients
const Gradient kTitleGradient = LinearGradient(
  colors: [Color(0xFFFEBD88), Color(0xFFF17C98)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const Gradient kButtonGradient = LinearGradient(
  colors: [Color(0xFFFFB88C), Color(0xFFDE6262)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const Gradient kHandleGradient = LinearGradient(
  colors: [Color(0xFFFFB88C), Color(0xFFF88A6B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const Gradient kWaveformGradient = LinearGradient(
  colors: [Color(0xFFE3729A), Color(0xFFF88A6B)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: kPrimaryTextColor.withValues(alpha: 0.5)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: const Text(
        //   'Glass Blossom',
        //   style: TextStyle(
        //     color: kPrimaryTextColor,
        //     fontWeight: FontWeight.bold,
        //     letterSpacing: 1.1,
        //   ),
        // ),
        // centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const ParticleBackground(),
          const Positioned.fill(child: AnimatedWaveform()),
          Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 480), // Responsive constraint
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildInfoCard(context),
                    const SizedBox(height: 50),
                    _buildSupportSection(),
                    const Spacer(),
                    // Footer moved to bottom of screen
                    const SizedBox(height: 12),
                    _buildFooter(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          decoration: BoxDecoration(
            color: kCardBackgroundColor,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => kTitleGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    // Use Wrap so title + flower can wrap on narrow widths.
                    child: const Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          'BloomeeTunes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        // Small animated flower
                        GentleRotatingFlower(size: 28),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Crafting symphonies in code.',
                style: TextStyle(
                    fontSize: 16,
                    color: kSecondaryTextColor,
                    fontFamily: 'Gilroy'),
              ),
              const SizedBox(height: 35),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: kHandleGradient,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF88A6B).withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                          backgroundColor: Colors.transparent, radius: 10),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '@iamhemantindia',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kPrimaryTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Gilroy',
                          shadows: [
                            Shadow(
                              color: const Color.fromARGB(255, 255, 246, 238)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              // Use Wrap to prevent overflow on small screens; center wrapped items
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12.0, // Spacing when items wrap to the next line
                spacing: 12.0, // Horizontal spacing
                children: [
                  // Maintainer opens GitHub account
                  _InfoPill(
                      icon: Icons.shield_outlined,
                      text: 'Maintainer',
                      tooltip: 'Follow him on GitHub',
                      onTap: () {
                        launchUrl(Uri.parse('https://github.com/HemantKArya'),
                            mode: LaunchMode.externalApplication);
                      }),
                  // Short label 'Email' opens mail composer
                  _InfoPill(
                      icon: FontAwesome.x_twitter_brand,
                      text: 'Contact',
                      tooltip: 'Send a business inquiry',
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://x.com/iamhemantindia'),
                        );
                      }),
                  // Short label 'Linkedin' opens Linkedin profile
                  _InfoPill(
                      icon: FontAwesome.linkedin_brand,
                      text: 'Linkedin',
                      tooltip: 'Updates and creative highlights',
                      onTap: () {
                        launchUrl(
                            Uri.parse('https://linkedin.com/in/iamhemantindia'),
                            mode: LaunchMode.externalApplication);
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            '"Enjoying Bloomee? A small tip keeps it blooming." 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kSecondaryTextColor, fontSize: 14, fontFamily: 'Gilroy'),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: kButtonGradient,
            // slightly larger radius for a more prominent pill
            borderRadius: BorderRadius.circular(34.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDE6262).withValues(alpha: 0.5),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // increase the ink response radius to match the larger pill
              borderRadius: BorderRadius.circular(32.0),
              onTap: () {
                launchUrl(
                  Uri.parse("https://hemantkarya.github.io/BloomeeTunes/"),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Container(
                // increased padding for a larger touch target
                padding:
                    const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: kPrimaryTextColor, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "I'll help",
                      style: TextStyle(
                        color: kPrimaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'I want Bloomee to keep improving.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: kSecondaryTextColor, fontSize: 14, fontFamily: 'Gilroy'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                launchUrl(
                    Uri.parse("https://hemantkarya.github.io/BloomeeTunes/"),
                    mode: LaunchMode.externalApplication);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MingCute.github_fill,
                      color: kSecondaryTextColor, size: 16),
                  SizedBox(width: 8),
                  Text('GitHub',
                      style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                          fontFamily: 'Gilroy')),
                ],
              ),
            ),
            const SizedBox(width: 18),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final ver = snapshot.hasData
                    ? 'v${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                    : 'Not able to retrieve version';
                return Text(ver,
                    style: const TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                        fontFamily: 'Gilroy'));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? tooltip;
  final VoidCallback? onTap;
  const _InfoPill(
      {required this.icon, required this.text, this.onTap, this.tooltip});
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min, // Important for Wrap widget
      children: [
        Icon(icon, color: kSecondaryTextColor, size: 18),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: kSecondaryTextColor,
                fontSize: 13,
                fontFamily: 'Gilroy')),
      ],
    );

    Widget result = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: child,
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(message: tooltip!, child: result);
    }

    if (onTap == null) return child;

    return result;
  }
}

class AnimatedWaveform extends StatefulWidget {
  const AnimatedWaveform({super.key});
  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: WaveformPainter(_controller.value),
          );
        });
  }
}

class WaveformPainter extends CustomPainter {
  final double time;
  WaveformPainter(this.time);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final animatedGradient = LinearGradient(
        colors: kWaveformGradient.colors,
        transform: GradientRotation(2 * pi * time));
    paint.shader = animatedGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    for (double x = -5; x <= size.width + 5; x++) {
      final amp = size.height * 0.1;
      final y = size.height / 2 +
          (amp) * sin(x * 0.015 + time * 2 * pi) +
          (amp * 0.5) * sin(x * 0.025 + time * 4 * pi);
      if (x == -5) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) =>
      time != oldDelegate.time;
}

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final int _numberOfParticles = 40; // Reduced for a more subtle effect
  final Random _random = Random();
  // track time between frames for smooth motion (seconds)
  late double _lastTickSeconds;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _lastTickSeconds = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _particles =
        List.generate(_numberOfParticles, (index) => _createParticle());
  }

  Particle _createParticle() {
    return Particle(
      position: Offset(_random.nextDouble(), _random.nextDouble()),
      radius: _random.nextDouble() * 1.5 + 0.5,
      // velocities are in normalized units per second (x: left/right, y: up/down)
      // give a gentle upward bias so particles slowly drift up the screen
      velocity: Offset((_random.nextDouble() - 0.5) * 0.01,
          -(_random.nextDouble() * 0.02 + 0.002)),
      lifespan: _random.nextDouble() * 8 + 4, // 4..12s
      isSharp: _random.nextDouble() > 0.4,
      maxLifespan: 0.0,
    )..maxLifespan = _random.nextDouble() * 8 + 4;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // compute actual delta time (seconds) since last frame for smooth
          final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final dt = (now - _lastTickSeconds).clamp(0.0, 0.05);
          _lastTickSeconds = now;

          for (var p in _particles) {
            // decrease lifespan by real time
            p.lifespan -= dt;
            // move according to velocity (velocity is per-second)
            p.position = Offset(p.position.dx + p.velocity.dx * dt,
                p.position.dy + p.velocity.dy * dt);

            // when particle dies, respawn at bottom with new random life/velocity
            if (p.lifespan <= 0) {
              p.position = Offset(
                  _random.nextDouble(), 1.02 + _random.nextDouble() * 0.06);
              p.lifespan = _random.nextDouble() * 8 + 4;
              p.maxLifespan = p.lifespan;
              // slight variation so new particle isn't identical
              p.velocity = Offset((_random.nextDouble() - 0.5) * 0.01,
                  -(_random.nextDouble() * 0.02 + 0.002));
            }

            // wrap horizontally
            if (p.position.dx < -0.1) p.position = Offset(1.1, p.position.dy);
            if (p.position.dx > 1.1) p.position = Offset(-0.1, p.position.dy);
            // if particle floats too far above, move it back to bottom to keep counts stable
            if (p.position.dy < -0.2) {
              p.position =
                  Offset(p.position.dx, 1.02 + _random.nextDouble() * 0.06);
            }
          }
          return CustomPaint(
              size: Size.infinite, painter: ParticlePainter(_particles));
        });
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: size.width * 0.9);
    final bgPaint = Paint()
      // Use a deeper radial tint with slightly higher opacity so edges stay dark
      ..shader = RadialGradient(colors: [
        const Color(0xFF2A1726).withValues(alpha: 0.6),
        kBackgroundColor.withValues(alpha: 0)
      ]).createShader(rect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final paint = Paint();
    for (var p in particles) {
      final progress = 1.0 - (p.lifespan / p.maxLifespan);
      final opacity = max(0.0, -4 * (progress - 0.5) * (progress - 0.5) + 1);

      // Lower particle brightness so they don't wash out the dark background
      paint.color = Colors.white.withValues(alpha: opacity * 0.35);
      paint.maskFilter =
          p.isSharp ? null : MaskFilter.blur(BlurStyle.normal, p.radius * 2);

      canvas.drawCircle(
          Offset(p.position.dx * size.width, p.position.dy * size.height),
          p.radius,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  Offset position;
  final double radius;
  Offset velocity;
  double lifespan;
  double maxLifespan;
  final bool isSharp;

  Particle(
      {required this.position,
      required this.radius,
      required this.velocity,
      required this.lifespan,
      required this.maxLifespan,
      required this.isSharp});
}

// A calming, natural-looking rotating flower using a sinusoidal motion.
class GentleRotatingFlower extends StatefulWidget {
  final double size;
  const GentleRotatingFlower({this.size = 28, super.key});

  @override
  State<GentleRotatingFlower> createState() => _GentleRotatingFlowerState();
}

class _GentleRotatingFlowerState extends State<GentleRotatingFlower>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slow, calming cycle. Repeats forever.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value; // 0..1
        // Sinusoidal rotation: small angle in radians (~ +/-9 deg)
        final angle = sin(t * 2 * pi) * (pi / 20);
        // Slight 'breathing' scale for softness
        final scale = 1 + 0.03 * sin(t * 2 * pi);
        // Gentle horizontal sway in logical pixels
        final dx = 2.0 * sin(t * 2 * pi);

        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Text(
                "🌸",
                style: TextStyle(fontSize: widget.size),
              ),
            ),
          ),
        );
      },
    );
  }
}
