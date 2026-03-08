import 'dart:developer';
import 'dart:async';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/screen/chart/chart_view.dart';
import 'package:Bloomee/screens/screen/chart/chart_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Chart carousel widget that displays charts from loaded chart provider plugins.
class CaraouselWidget extends StatefulWidget {
  const CaraouselWidget({super.key});

  @override
  State<CaraouselWidget> createState() => _CaraouselWidgetState();
}

class _CaraouselWidgetState extends State<CaraouselWidget> {
  late final ChartBloc _chartBloc;
  ValueNotifier<bool> autoSlideCharts = ValueNotifier(true);
  StreamSubscription<SettingsState>? _settingsSub;

  @override
  void initState() {
    super.initState();
    _chartBloc = ChartBloc(pluginService: ServiceLocator.pluginService);
    autoSlideCharts.value = context.read<SettingsCubit>().state.autoSlideCharts;
    _settingsSub = context.read<SettingsCubit>().stream.listen((event) {
      if (autoSlideCharts.value != event.autoSlideCharts) {
        autoSlideCharts.value = event.autoSlideCharts;
      }
    });
    _loadChartsFromPlugin();
  }

  void _loadChartsFromPlugin() {
    final chartProviders =
        context.read<PluginBloc>().state.loadedChartProviders;
    if (chartProviders.isNotEmpty) {
      final pluginId = chartProviders.first.manifest.id;
      log('Loading charts from plugin: $pluginId', name: 'ChartCarousel');
      _chartBloc.add(LoadCharts(pluginId: pluginId));
    } else {
      log('No chart provider plugins loaded — charts unavailable',
          name: 'ChartCarousel');
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _chartBloc.close();
    autoSlideCharts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChartBloc, ChartState>(
      bloc: _chartBloc,
      listenWhen: (previous, current) =>
          previous.chartsStatus != ChartStatus.loaded &&
          current.chartsStatus == ChartStatus.loaded,
      listener: (context, chartState) {
        final pluginId = chartState.activePluginId;
        if (pluginId == null || chartState.charts.isEmpty) return;
        final settingsState = context.read<SettingsCubit>().state;
        final visibleIds = chartState.charts
            .where((c) => settingsState.chartMap[c.title] ?? true)
            .map((c) => c.id)
            .toSet();
        if (visibleIds.isNotEmpty) {
          _chartBloc.add(PrefetchAllChartDetails(
            pluginId: pluginId,
            chartIds: visibleIds,
          ));
        }
      },
      child: BlocBuilder<PluginBloc, PluginState>(
        builder: (context, pluginState) {
          if (pluginState.loadedChartProviders.isEmpty) {
            _chartBloc.add(const ClearCharts());
          } else if (_chartBloc.state.chartsStatus == ChartStatus.initial) {
            _loadChartsFromPlugin();
          }
          return BlocBuilder<ChartBloc, ChartState>(
            bloc: _chartBloc,
            builder: (context, chartState) {
              if (chartState.charts.isEmpty) return const SizedBox.shrink();

              final settingsState = context.watch<SettingsCubit>().state;
              final visibleCharts = chartState.charts
                  .where((c) => settingsState.chartMap[c.title] ?? true)
                  .toList();

              if (visibleCharts.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ValueListenableBuilder<bool>(
                  valueListenable: autoSlideCharts,
                  builder: (context, autoPlay, child) {
                    return CarouselSlider.builder(
                      itemCount: visibleCharts.length,
                      itemBuilder: (context, index, realIndex) {
                        final chart = visibleCharts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChartScreen(
                                  pluginId:
                                      _chartBloc.state.activePluginId ?? '',
                                  chartId: chart.id,
                                  chartTitle: chart.title,
                                ),
                              ),
                            );
                          },
                          child: ChartWidget(
                            chart: chart,
                            pluginId: _chartBloc.state.activePluginId ?? '',
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: ResponsiveBreakpoints.of(context).isMobile ||
                                ResponsiveBreakpoints.of(context).isTablet
                            ? MediaQuery.of(context).size.height * 0.36
                            : 250,
                        viewportFraction:
                            ResponsiveBreakpoints.of(context).isMobile
                                ? 0.65
                                : ResponsiveBreakpoints.of(context).isTablet
                                    ? 0.40
                                    : 0.30,
                        autoPlay: autoPlay,
                        autoPlayInterval: const Duration(milliseconds: 2500),
                        enlargeFactor: 0.2,
                        initialPage: 0,
                        pauseAutoPlayOnTouch: true,
                        padEnds: true,
                        enlargeCenterPage:
                            ResponsiveBreakpoints.of(context).isMobile,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
