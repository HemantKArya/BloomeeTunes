library;

import 'dart:io' show Platform, exit;
import 'dart:ui';

import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/plugins/services/plugin_repository_service.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/plugin_bootstrap_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

enum _Phase { running, success, failed, noInternet }

class PluginBootstrapOverlay extends StatefulWidget {
  const PluginBootstrapOverlay({
    required this.onComplete,
    super.key,
  });

  final VoidCallback onComplete;

  @override
  State<PluginBootstrapOverlay> createState() => _PluginBootstrapOverlayState();
}

class _PluginBootstrapOverlayState extends State<PluginBootstrapOverlay>
    with TickerProviderStateMixin {
  static const _maxContentWidth = 500.0;
  static const _bgBase = Color(0xFF060608);
  static const _surfaceCol = Color(0xFF14141A);
  static const _errorAccent = Color(0xFFFF4C4C);
  static const _successAccent = Color(0xFFFF2A5F);

  final ValueNotifier<_Phase> _phase = ValueNotifier(_Phase.running);
  final ValueNotifier<int> _progress = ValueNotifier(0);
  int _runToken = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    SchedulerBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _phase.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final token = ++_runToken;
    _phase.value = _Phase.running;
    _progress.value = 0;

    final settingsDao = SettingsDAO(DBProvider.db);
    final repositoryService = PluginRepositoryService(settingsDao: settingsDao);

    final result = await PluginBootstrapService.run(
      pluginService: ServiceLocator.pluginService,
      repositoryService: repositoryService,
      settingsDao: settingsDao,
      onProgress: (progress) {
        if (mounted) {
          _progress.value = progress.percent.clamp(0, 100);
        }
      },
    );

    if (!mounted || token != _runToken) return;

    if (result.success) {
      await PluginBootstrapService.autoSelectPluginDefaults(
        ServiceLocator.pluginService,
        settingsDao,
      );
      _phase.value = _Phase.success;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) widget.onComplete();
    } else if (result.failureReason ==
        PluginBootstrapFailureReason.noInternet) {
      _phase.value = _Phase.noInternet;
    } else {
      _phase.value = _Phase.failed;
    }
  }

  Future<void> _exitApp() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemNavigator.pop();
      return;
    }
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: FadeTransition(
        opacity: _fadeIn,
        child: Container(
          color: _bgBase,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ValueListenableBuilder<_Phase>(
                valueListenable: _phase,
                builder: (context, phase, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: phase == _Phase.noInternet
                        ? _NoInternetBody(
                            onRetry: _run,
                            onExit: _exitApp,
                          )
                        : phase == _Phase.failed
                            ? _ErrorBody(
                                onRetry: _run,
                              )
                            : _SpinnerBody(
                                pulse: _pulse,
                                progress: _progress,
                                isDone: phase == _Phase.success,
                                l10n: l10n,
                              ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerBody extends StatelessWidget {
  const _SpinnerBody({
    required this.pulse,
    required this.progress,
    required this.isDone,
    required this.l10n,
  });

  final Animation<double> pulse;
  final ValueNotifier<int> progress;
  final bool isDone;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) => Opacity(
              opacity: isDone ? 1.0 : pulse.value,
              child: child,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Default_Theme.accentColor2.withValues(alpha: 0.12),
                border: Border.all(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Default_Theme.accentColor2,
                        size: 36,
                      )
                    : const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Default_Theme.accentColor2,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n?.pluginBootstrapTitle ?? 'Setting up Bloomee',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (context, percent, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                l10n?.pluginBootstrapProgress(percent) ??
                    'Setting up new plugin engine... $percent%',
                key: ValueKey(percent),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n?.pluginBootstrapHint ?? 'This only happens once.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _PluginBootstrapOverlayState._surfaceCol,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _PluginBootstrapOverlayState._errorAccent
                .withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: _PluginBootstrapOverlayState._errorAccent,
              size: 48,
            ),
            const SizedBox(height: 20),
            const Text(
              'Setup incomplete',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Some plugins could not be installed right now. Retry to finish setup cleanly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: _PluginBootstrapOverlayState._successAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry setup',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoInternetBody extends StatelessWidget {
  const _NoInternetBody({
    required this.onRetry,
    required this.onExit,
  });

  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _PluginBootstrapOverlayState._surfaceCol,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Internet required',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bloomee needs an internet connection once to detect your country and set up the plugin engine.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          _PluginBootstrapOverlayState._successAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
