import 'dart:async';

import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/screen/chart/chart_view.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Charts from the first chart-provider plugin, as a sliding carousel.
class ChartCarousel extends StatefulWidget {
  final HomeMetrics metrics;
  const ChartCarousel({super.key, required this.metrics});

  @override
  State<ChartCarousel> createState() => _ChartCarouselState();
}

class _ChartCarouselState extends State<ChartCarousel> {
  late final ChartBloc _charts =
      ChartBloc(pluginService: ServiceLocator.pluginService);

  @override
  void initState() {
    super.initState();
    _load(context.read<PluginBloc>().state);
  }

  void _load(PluginState plugins) {
    final providers = plugins.loadedChartProviders;
    if (providers.isEmpty) {
      _charts.add(const ClearCharts());
    } else if (_charts.state.activePluginId != providers.first.manifest.id ||
        _charts.state.chartsStatus == ChartStatus.initial) {
      _charts.add(LoadCharts(pluginId: providers.first.manifest.id));
    }
  }

  @override
  void dispose() {
    _charts.close();
    super.dispose();
  }

  void _open(ChartSummary chart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChartScreen(
          pluginId: _charts.state.activePluginId ?? '',
          chartId: chart.id,
          chartTitle: chart.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    return BlocListener<PluginBloc, PluginState>(
      listenWhen: (a, b) =>
          a.loadedChartProviders.map((p) => p.manifest.id).join() !=
          b.loadedChartProviders.map((p) => p.manifest.id).join(),
      listener: (context, plugins) => _load(plugins),
      child: BlocBuilder<ChartBloc, ChartState>(
        bloc: _charts,
        builder: (context, state) {
          if (state.charts.isEmpty) {
            // Keep the space while charts load so the page doesn't jump.
            return state.chartsStatus == ChartStatus.loading
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _CarouselSkeleton(metrics: m),
                  )
                : const SizedBox.shrink();
          }
          return BlocSelector<SettingsCubit, SettingsState, (bool, Map)>(
            selector: (s) => (s.autoSlideCharts, s.chartMap),
            builder: (context, settings) {
              final (autoPlay, shown) = settings;
              final charts = [
                for (final c in state.charts)
                  if (shown[c.title] ?? true) c,
              ];
              if (charts.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ChartCarouselView(
                  charts: charts,
                  height: m.chartHeight,
                  viewportFraction: m.chartFraction,
                  enlargeCenter: m.isMobile,
                  autoPlay: autoPlay,
                  onOpen: _open,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// The carousel itself, independent of where charts come from.
///
/// Slides endlessly every [interval] when [autoPlay] is on, starting
/// [startDelay] after it appears so app startup stays smooth. Sliding
/// pauses only when it would be wasted or in the way: while the user
/// touches or drags it, while Home is covered or in another tab, while the
/// carousel is scrolled off screen, and while the app is minimised, in the
/// tray or in the background.
class ChartCarouselView extends StatefulWidget {
  final List<ChartSummary> charts;
  final double height;
  final double viewportFraction;

  /// Neighbouring cards shrink (phones).
  final bool enlargeCenter;
  final bool autoPlay;
  final ValueChanged<ChartSummary> onOpen;
  final Duration interval;
  final Duration startDelay;

  const ChartCarouselView({
    super.key,
    required this.charts,
    required this.height,
    required this.viewportFraction,
    required this.onOpen,
    this.enlargeCenter = false,
    this.autoPlay = true,
    this.interval = const Duration(seconds: 3),
    this.startDelay = const Duration(seconds: 3),
  });

  @override
  State<ChartCarouselView> createState() => ChartCarouselViewState();
}

@visibleForTesting
class ChartCarouselViewState extends State<ChartCarouselView> {
  late PageController _controller = _newController();
  Timer? _warmup;
  Timer? _timer;
  late final AppLifecycleListener _lifecycle;
  bool _appVisible = true;
  bool _tickersOn = true;
  bool _touching = false;
  bool _warm = false;
  final _hovered = ValueNotifier<bool>(false);

  int get _count => widget.charts.length;
  bool get _loops => _count > 1;

  /// Whether autoplay is running right now (for tests).
  @visibleForTesting
  bool get isAutoPlaying => _timer?.isActive ?? false;

  /// The chart in the middle (for tests).
  @visibleForTesting
  int get activeIndex =>
      _controller.hasClients ? (_controller.page ?? 0).round() % _count : 0;

  PageController _newController() => PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: _loops ? _count * 1000 : 0,
      );

  @override
  void initState() {
    super.initState();
    _appVisible = _isVisible(WidgetsBinding.instance.lifecycleState);
    _lifecycle = AppLifecycleListener(onStateChange: (state) {
      _appVisible = _isVisible(state);
      _sync();
    });
    _warmup = Timer(widget.startDelay, () {
      _warm = true;
      _sync();
    });
  }

  /// Focus does not matter, only whether the window can be seen: an
  /// unfocused window beside another app keeps sliding.
  static bool _isVisible(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickersOn = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  @override
  void didUpdateWidget(covariant ChartCarouselView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportFraction != widget.viewportFraction ||
        oldWidget.charts.length != _count) {
      final old = _controller;
      _controller = _newController();
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.interval != widget.interval ||
        oldWidget.charts.length != _count) {
      _restart();
    }
  }

  @override
  void dispose() {
    _warmup?.cancel();
    _timer?.cancel();
    _lifecycle.dispose();
    _controller.dispose();
    _hovered.dispose();
    super.dispose();
  }

  bool get _shouldPlay =>
      widget.autoPlay &&
      _loops &&
      _warm &&
      _appVisible &&
      _tickersOn &&
      !_touching;

  void _sync() {
    if (!_warm) return;
    final running = _timer?.isActive ?? false;
    if (_shouldPlay && !running) {
      _timer = Timer.periodic(widget.interval, (_) => _advance());
    } else if (!_shouldPlay && running) {
      _timer!.cancel();
      _timer = null;
    }
  }

  /// A fresh full interval, e.g. after the user moved the carousel.
  void _restart() {
    if (!_warm) return;
    _timer?.cancel();
    _timer = null;
    _sync();
  }

  void _advance() {
    if (!_controller.hasClients || !_isOnScreen()) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 650),
      curve: Curves.fastOutSlowIn,
    );
  }

  bool _isOnScreen() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return false;
    final top = box.localToGlobal(Offset.zero).dy;
    final screen = MediaQuery.sizeOf(context).height;
    return top + box.size.height > 0 && top < screen;
  }

  void _step(int direction) {
    _controller.animateToPage(
      (_controller.page ?? 0).round() + direction,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    _restart();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return MouseRegion(
      onEnter: (_) => _hovered.value = true,
      onExit: (_) => _hovered.value = false,
      child: Listener(
        onPointerDown: (_) {
          _touching = true;
          _sync();
        },
        onPointerUp: (_) {
          _touching = false;
          _restart();
        },
        onPointerCancel: (_) {
          _touching = false;
          _restart();
        },
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: _loops ? null : _count,
                itemBuilder: (context, index) {
                  final chart = widget.charts[index % _count];
                  final card = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _ChartCard(
                      chart: chart,
                      onTap: () => widget.onOpen(chart),
                    ),
                  );
                  if (!widget.enlargeCenter) return card;
                  // Paint-only scaling: no relayout while sliding.
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final page = controller.position.haveDimensions
                          ? controller.page ?? index.toDouble()
                          : controller.initialPage.toDouble();
                      final distance = (page - index).abs().clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: 1 - distance * 0.2,
                        child: child,
                      );
                    },
                    child: card,
                  );
                },
              ),
              if (_loops && HomeMetrics.showsScrollButtons)
                ValueListenableBuilder<bool>(
                  valueListenable: _hovered,
                  builder: (context, hovered, _) => hovered
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            _ArrowButton(
                              alignment: Alignment.centerLeft,
                              icon: MingCute.left_line,
                              onTap: () => _step(-1),
                            ),
                            _ArrowButton(
                              alignment: Alignment.centerRight,
                              icon: MingCute.right_line,
                              onTap: () => _step(1),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chart cover with its title over a dark fade (original design).
class _ChartCard extends StatelessWidget {
  final ChartSummary chart;
  final VoidCallback onTap;
  const _ChartCard({required this.chart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final art = chart.thumbnail;
    final url = art?.urlHigh ?? art?.url ?? art?.urlLow ?? '';
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                fit: StackFit.expand,
                children: [
                  if (url.isNotEmpty)
                    LoadImageCached(
                      imageUrl: url,
                      fallbackUrl: art?.url,
                      width: box.maxWidth,
                      height: box.maxHeight,
                    )
                  else
                    ColoredBox(
                      color:
                          Default_Theme.primaryColor2.withValues(alpha: 0.08),
                      child: Icon(MingCute.music_2_fill,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x40000000),
                          Color(0xCC000000),
                        ],
                        stops: [0.3, 0.6, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Text(
                      chart.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
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

class _ArrowButton extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton(
      {required this.alignment, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IconButton.filled(
            onPressed: onTap,
            iconSize: 18,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.55),
              foregroundColor: Colors.white,
              hoverColor: Colors.black.withValues(alpha: 0.7),
            ),
            icon: Icon(icon),
          ),
        ),
      );
}

/// Grey blocks the size of the cards, shown while charts load.
class _CarouselSkeleton extends StatelessWidget {
  final HomeMetrics metrics;
  const _CarouselSkeleton({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final page = metrics.width * metrics.chartFraction;
    return SizedBox(
      height: metrics.chartHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        // Centred like the carousel's first card.
        padding: EdgeInsets.only(left: (metrics.width - page) / 2),
        itemExtent: page,
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: HomeSkeleton(
              width: page, height: metrics.chartHeight, radius: 16),
        ),
      ),
    );
  }
}
