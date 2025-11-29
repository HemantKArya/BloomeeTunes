// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/plugins/ext_charts/chart_defines.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ChartWidget extends StatefulWidget {
  final ChartInfo chartInfo;

  const ChartWidget({
    super.key,
    required this.chartInfo,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

// create a class which have 2 color variable for text and background
class TextColorPair {
  final Color color1;
  final Color color2;
  TextColorPair({
    required this.color1,
    required this.color2,
  });
}

// create list of color pair which have some light colors with text color, use proffessinoal colors like pastel colors
final List<TextColorPair> colorPair = [
  TextColorPair(
    color1: const Color.fromARGB(255, 223, 63, 0).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 205, 135, 23).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 255, 173, 50).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 205, 132, 23).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 6, 85, 159).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 28, 105, 220).withValues(alpha: 0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 222, 8, 125).withValues(alpha: 0.9),
    color2: const Color.fromARGB(255, 223, 38, 72).withValues(alpha: 0.7),
  ),
];

class _ChartWidgetState extends State<ChartWidget> {
  late final cachedClipPath;
  final _random = Random();
  TextColorPair _color = colorPair[0];
  @override
  void initState() {
    setState(() {
      _color = colorPair[_random.nextInt(colorPair.length)];
    });

    cachedClipPath = ClipPath(
      clipper: ChartCardClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              _color.color1,
              _color.color2,
            ],
          ),
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: ResponsiveBreakpoints.of(context).isMobile ||
                ResponsiveBreakpoints.of(context).isTablet
            ? MediaQuery.of(context).size.height * 0.35
            : MediaQuery.of(context).size.height * 0.25,
        width: ResponsiveBreakpoints.of(context).isMobile
            ? MediaQuery.of(context).size.height * 0.3
            : ResponsiveBreakpoints.of(context).isTablet
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width * 0.25,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            BlocBuilder<ChartCubit, ChartState>(
              bloc: BlocProvider.of<ChartCubit>(context),
              builder: (context, state) {
                final cachedImage = LoadImageCached(
                    imageUrl: formatImgURL(state.coverImg, ImageQuality.high),
                    fit: BoxFit.cover);
                return AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: state is ChartInitial
                      ? const PlaceholderWidget()
                      : SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: cachedImage),
                );
              },
            ),
            Positioned(
              child: cachedClipPath,
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: SizedBox(
                width: constraints.maxWidth * 0.9,
                height: MediaQuery.of(context).size.height * 0.09,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 10, bottom: 4, top: 4),
                    child: Text(
                      widget.chartInfo.title,
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      textWidthBasis: TextWidthBasis.parent,
                      style: const TextStyle(
                        // color: _color.textColor.withValues(alpha: 0.95),
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 28,
                        fontFamily: "Unageo",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: const Color.fromARGB(255, 52, 0, 147).withValues(alpha: 0.5),
      ),
      const Center(
        child: Icon(MingCute.music_2_fill, size: 80, color: Colors.white),
      ),
    ]);
  }
}

class ChartCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // write the path for writing a text over it, shape should be at bottom only
    path.moveTo(0, size.height * 0.75);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.6, size.height * 0.75, 0, size.height * 0.76);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
