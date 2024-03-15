import 'dart:math';

import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';

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
  final Color textColor;
  final Color backgroundColor;

  TextColorPair({
    required this.textColor,
    required this.backgroundColor,
  });
}

// create list of color pair which have some light colors with text color, use proffessinoal colors like pastel colors
final List<TextColorPair> colorPair = [
  TextColorPair(
    textColor: const Color.fromARGB(255, 0, 0, 0),
    backgroundColor: const Color.fromARGB(255, 255, 141, 141),
  ),
  TextColorPair(
    textColor: const Color.fromARGB(255, 0, 0, 0),
    backgroundColor: const Color.fromARGB(255, 132, 255, 253),
  ),
  TextColorPair(
    textColor: const Color.fromARGB(255, 0, 0, 0),
    backgroundColor: const Color.fromARGB(255, 255, 179, 92),
  ),
  TextColorPair(
    textColor: const Color.fromARGB(255, 0, 0, 0),
    backgroundColor: const Color.fromARGB(255, 255, 129, 154),
  ),
  TextColorPair(
    textColor: const Color.fromARGB(255, 0, 0, 0),
    backgroundColor: const Color.fromARGB(255, 76, 255, 163),
  ),
];

class _ChartWidgetState extends State<ChartWidget> {
  final _random = new Random();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: 600,
        width: 270,
        child: Stack(children: [
          SizedBox(
            height: 600,
            width: 270,
            child: loadImageCached(widget.chartInfo.imgUrl),
          ),
          Positioned(
            child: ClipPath(
              clipper: ChartCardClipper(),
              child: Container(
                color: colorPair[_random.nextInt(colorPair.length)]
                    .backgroundColor
                    .withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 10,
            child: SizedBox(
              width: 260,
              child: Text(
                widget.chartInfo.title,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textWidthBasis: TextWidthBasis.parent,
                style: TextStyle(
                  color: colorPair[_random.nextInt(colorPair.length)]
                      .textColor
                      .withOpacity(0.95),
                  fontSize: 27,
                  fontFamily: "Unageo",
                  fontWeight: FontWeight.w900,
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
