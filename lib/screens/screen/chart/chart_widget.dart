// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:math';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:Bloomee/utils/load_Image.dart';

class ChartWidget extends StatefulWidget {
  final ChartInfo chartInfo;

  const ChartWidget({
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
    color1: Color.fromARGB(255, 223, 63, 0).withOpacity(0.9),
    color2: const Color.fromARGB(255, 205, 135, 23).withOpacity(0.7),
  ),
  TextColorPair(
    color1: const Color.fromARGB(255, 255, 173, 50).withOpacity(0.9),
    color2: const Color.fromARGB(255, 205, 132, 23).withOpacity(0.7),
  ),
  TextColorPair(
    color1: Color.fromARGB(255, 6, 85, 159).withOpacity(0.9),
    color2: Color.fromARGB(255, 28, 105, 220).withOpacity(0.7),
  ),
  TextColorPair(
    color1: Color.fromARGB(255, 222, 8, 125).withOpacity(0.9),
    color2: Color.fromARGB(255, 223, 38, 72).withOpacity(0.7),
  ),
];

class _ChartWidgetState extends State<ChartWidget> {
  final _random = Random();
  TextColorPair _color = colorPair[0];
  @override
  void initState() {
    setState(() {
      _color = colorPair[_random.nextInt(colorPair.length)];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: 600,
        width: 270,
        child: Stack(children: [
          BlocBuilder<ChartCubit, ChartState>(
            bloc: BlocProvider.of<ChartCubit>(context),
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: state is ChartInitial
                    ? Stack(children: [
                        Container(
                          color: const Color.fromARGB(255, 52, 0, 147)
                              .withOpacity(0.5),
                        ),
                        const Center(
                          child: Icon(MingCute.music_2_fill,
                              size: 80, color: Colors.white),
                        ),
                      ])
                    : SizedBox(
                        height: 600,
                        width: 270,
                        child: loadImageCached(state.coverImg),
                      ),
              );
            },
          ),
          Positioned(
            child: ClipPath(
              clipper: ChartCardClipper(),
              child: Container(
                // color: Color.fromARGB(255, 255, 35, 196).withOpacity(0.5),
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
                // color: _color.backgroundColor.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 10,
            child: SizedBox(
              width: 260,
              child: Text(
                widget.chartInfo.title,
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                textWidthBasis: TextWidthBasis.parent,
                style: const TextStyle(
                  // color: _color.textColor.withOpacity(0.95),
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 28,
                  fontFamily: "Unageo",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
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
