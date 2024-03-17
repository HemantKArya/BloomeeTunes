import 'package:Bloomee/screens/screen/chart/chart_widget.dart';
import 'package:Bloomee/screens/screen/chart/show_charts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 80),
            opacity: _visibility ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  children: [
                    Text(
                      "Featured",
                      style: Default_Theme.secondoryTextStyle.merge(
                          const TextStyle(
                              color: Default_Theme.primaryColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 19)),
                    ),
                    const Icon(
                      FontAwesome.bolt_lightning_solid,
                      color: Default_Theme.primaryColor1,
                    ),
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
              height: 320.0,
              viewportFraction: 0.7,
              autoPlay: true,
              autoPlayInterval: const Duration(milliseconds: 2500),
              // aspectRatio: 15 / 16,
              // enableInfiniteScroll: true,
              enlargeFactor: 0.3,
              initialPage: 0,
              enlargeCenterPage: true),
          items: [
            for (int i = 0; i < chartInfoList.length; i++)
              InkWell(
                onTap: () {
                  GoRouter.of(context).push(
                      "/${GlobalStrConsts.exploreScreen}/${GlobalStrConsts.ChartScreen}",
                      extra: chartInfoList[i]);
                },
                child: ChartWidget(
                  chartInfo: chartInfoList[i],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
