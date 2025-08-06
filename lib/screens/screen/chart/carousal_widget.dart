import 'dart:async';
import 'dart:developer';
import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
import 'package:Bloomee/screens/screen/chart/chart_widget.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CaraouselWidget extends StatefulWidget {
  CaraouselWidget({
    super.key,
  }) {
    // chartInfoList.shuffle();
  }

  @override
  State<CaraouselWidget> createState() => _CaraouselWidgetState();
}

class _CaraouselWidgetState extends State<CaraouselWidget> {
  bool _visibility = true;
  List<ChartCubit> chartCubitList = List.empty(growable: true);
  List<ChartInfo> selectedCharts = List.empty(growable: true);
  Map<dynamic, dynamic> chartMap = {};
  ValueNotifier<bool> autoSlideCharts = ValueNotifier(true);
  StreamSubscription? ss;

  Future<void> initSettings() async {
    autoSlideCharts.value = await BloomeeDBService.getSettingBool(
            GlobalStrConsts.autoSlideCharts) ??
        true;
  }

  void getSelectedCharts(Map sChartMap) {
    if (!mapEquals(chartMap, sChartMap) || selectedCharts.isEmpty) {
      selectedCharts.clear();
      chartCubitList.clear();
      for (var e in chartInfoList) {
        if (sChartMap[e.title] == null || sChartMap[e.title] == true) {
          selectedCharts.add(e);
          chartCubitList.add(ChartCubit(e, context.read<FetchChartCubit>()));
        }
      }
      if (mounted) {
        setState(() {
          log('selected charts: ${selectedCharts.length.toString()}',
              name: 'ChartCarousel');
        });
      }
    }
    chartMap = sChartMap;
  }

  @override
  void initState() {
    initSettings();
    getSelectedCharts(context.read<SettingsCubit>().state.chartMap);
    ss = context.read<SettingsCubit>().stream.listen((event) {
      if (autoSlideCharts.value != event.autoSlideCharts) {
        autoSlideCharts.value = event.autoSlideCharts;
        if (autoSlideCharts.value) {
          log("Auto Slide Charts Enabled");
        } else {
          log("Auto Slide Charts Disabled");
        }
      }
      getSelectedCharts(event.chartMap);
    });
    super.initState();
  }

  @override
  void dispose() {
    ss?.cancel();
    autoSlideCharts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return selectedCharts.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  children: [
                    Positioned(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 80),
                        opacity: _visibility ? 1.0 : 0.0,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 15, top: 10),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Row(
                              children: [
                                // Text(
                                //   "Featured",
                                //   style: Default_Theme.secondoryTextStyle.merge(
                                //       const TextStyle(
                                //           color: Default_Theme.primaryColor1,
                                //           fontWeight: FontWeight.bold,
                                //           fontSize: 19)),
                                // ),
                                // const Icon(
                                //   FontAwesome.bolt_lightning_solid,
                                //   color: Default_Theme.primaryColor1,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: autoSlideCharts,
                      builder: (context, autoPlay, child) {
                        return CarouselSlider.builder(
                          itemCount: selectedCharts.length,
                          itemBuilder: (context, index, realIndex) {
                            if (index < selectedCharts.length &&
                                (state.chartMap[selectedCharts[index].title] ==
                                        null ||
                                    state.chartMap[
                                            selectedCharts[index].title] ==
                                        true)) {
                              return BlocProvider.value(
                                value: chartCubitList[index],
                                child: GestureDetector(
                                  onTap: () => GoRouter.of(context).pushNamed(
                                      GlobalStrConsts.ChartScreen,
                                      pathParameters: {
                                        "chartName": selectedCharts[index].title
                                      }),
                                  child: ChartWidget(
                                    chartInfo: selectedCharts[index],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                          options: CarouselOptions(
                            onPageChanged: (index, _) {
                              setState(() {
                                _visibility = index == 0;
                              });
                            },
                            height: ResponsiveBreakpoints.of(context)
                                        .isMobile ||
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
                            autoPlayInterval:
                                const Duration(milliseconds: 2500),
                            // aspectRatio: 15 / 16,
                            // enableInfiniteScroll: true,
                            enlargeFactor: 0.2,
                            initialPage: 0,
                            pauseAutoPlayOnTouch: true,
                            padEnds: true,
                            enlargeCenterPage:
                                ResponsiveBreakpoints.of(context).isMobile
                                    ? true
                                    : false,
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
}
