import 'package:flutter/material.dart';

import '../../theme_data/default.dart';

class UnicodeIcon extends StatelessWidget {
  final String strCode;
  final TextStyle font;
  final double fontSize;
  final EdgeInsets padding;
  final Color fontColor;
  const UnicodeIcon({
    Key? key,
    this.strCode = "U",
    this.font = Default_Theme.fontAwesomeSolidFont,
    this.fontSize = 25.0,
    this.padding = const EdgeInsets.only(left: 15),
    this.fontColor = Default_Theme.primaryColor1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(strCode,
          style: font.merge(TextStyle(color: fontColor, fontSize: fontSize))),
    );
  }
}
