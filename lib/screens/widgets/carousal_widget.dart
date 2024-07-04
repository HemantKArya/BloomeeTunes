import 'dart:developer';
import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/screen/chart/chart_widget.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CaraouselWidget extends StatefulWidget {
  CaraouselWidget({
    super.key,
  }) {
    chartInfoList.shuffle();
  }

  @override
  State<CaraouselWidget> createState() => _CaraouselWidgetState();
}

class _CaraouselWidgetState extends State<CaraouselWidget> {
  bool _visibility = true;
  // final FetchChartCubit fetchChartCubit;
  List<ChartCubit> chartCubitList = List.empty(growable: true);
  bool autoSlideCharts = true;

  Future<void> initSettings() async {
    autoSlideCharts = await BloomeeDBService.getSettingBool(
            GlobalStrConsts.autoSlideCharts) ??
        true;
    setState(() {});
  }

  @override
  void initState() {
    for (var i in chartInfoList) {
      chartCubitList.add(ChartCubit(i, context.read<FetchChartCubit>()));
    }
    initSettings();
    super.initState();
    context.read<SettingsCubit>().stream.listen((event) {
      if (autoSlideCharts != event.autoSlideCharts) {
        autoSlideCharts = event.autoSlideCharts;
        if (autoSlideCharts) {
          log("Auto Slide Charts Enabled");
        } else {
          log("Auto Slide Charts Disabled");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        CarouselSlider(
          options: CarouselOptions(
            onPageChanged: (index, _) {
              setState(() {
                _visibility = index == 0;
              });
            },
            height: ResponsiveBreakpoints.of(context).isMobile ||
                    ResponsiveBreakpoints.of(context).isTablet
                ? MediaQuery.of(context).size.height * 0.38
                : 250,
            viewportFraction: ResponsiveBreakpoints.of(context).isMobile
                ? 0.65
                : ResponsiveBreakpoints.of(context).isTablet
                    ? 0.30
                    : 0.25,
            autoPlay: autoSlideCharts,
            autoPlayInterval: const Duration(milliseconds: 2500),
            // aspectRatio: 15 / 16,
            // enableInfiniteScroll: true,
            enlargeFactor: 0.2,
            initialPage: 0,
            pauseAutoPlayOnTouch: true,
            enlargeCenterPage: true,
          ),
          items: [
            for (int i = 0; i < chartInfoList.length; i++)
              BlocProvider.value(
                value: chartCubitList[i],
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).pushNamed(
                      GlobalStrConsts.ChartScreen,
                      pathParameters: {"chartName": chartInfoList[i].title}),
                  child: ChartWidget(
                    chartInfo: chartInfoList[i],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
