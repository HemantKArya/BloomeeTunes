import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/first_time_service.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const SplashScreen({super.key, required this.onContinue});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();

    // Auto-redirect after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Default_Theme.themeColor,
              Default_Theme.themeColor.withValues(alpha: 0.8),
              Default_Theme.accentColor1.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo Container with enhanced design
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Default_Theme.accentColor1
                                    .withValues(alpha: 0.2),
                                Default_Theme.accentColor2
                                    .withValues(alpha: 0.2),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Default_Theme.accentColor2
                                    .withValues(alpha: 0.4),
                                blurRadius: 25,
                                spreadRadius: 8,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Default_Theme.accentColor1
                                    .withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 3,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27),
                              child: Image.asset(
                                'assets/icons/bloomee_new_logo_c.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // App Name with enhanced styling
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Default_Theme.accentColor1,
                              Default_Theme.accentColor2,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Bloomee',
                            style: Default_Theme.primaryTextStyle.copyWith(
                              fontSize: 38,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Tagline with better styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.1),
                            border: Border.all(
                              color: Default_Theme.accentColor1
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Your Music, Your Way',
                            style: Default_Theme.secondoryTextStyle.copyWith(
                              fontSize: 18,
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.9),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Version info at bottom
                        Text(
                          'v2.11.6',
                          style: Default_Theme.secondoryTextStyle.copyWith(
                            fontSize: 12,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
