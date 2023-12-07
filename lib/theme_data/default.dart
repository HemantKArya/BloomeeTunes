import 'package:flutter/material.dart';

class Default_Theme {
  //Text Styles
  static const primaryTextStyle = TextStyle(fontFamily: "Fjalla");
  static const secondoryTextStyle = TextStyle(fontFamily: "Gilroy");
  static const secondoryTextStyleMedium =
      TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w700);
  static const tertiaryTextStyle = TextStyle(fontFamily: "CodePro");
  static const fontAwesomeRegularFont =
      TextStyle(fontFamily: "FontAwesome-Regular");
  static const fontAwesomeSolidFont =
      TextStyle(fontFamily: "FontAwesome-Solids");

//Colors
  static const themeColor = Color(0xFF0A040C);
  static const primaryColor1 = Color(0xFFDAEAF7);
  static const primaryColor2 = Color(0xFFDDCAD9);
  static const accentColor1 = Color(0xFF0EA5E0);
  static const accentColor1light = Color(0xFF18C9ED);
  static const accentColor2 = Color(0xFFFE385E);
  static const successColor = Color(0xFF5EFF43);

  ThemeData defaultThemeData = ThemeData(
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    primaryColor: themeColor,
    hintColor: themeColor,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.circular(50)),
      focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Default_Theme.primaryColor1.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(50)),
    ),
    primaryTextTheme: const TextTheme(
        titleLarge: primaryTextStyle,
        bodyMedium: secondoryTextStyleMedium,
        bodySmall: tertiaryTextStyle,
        titleMedium: secondoryTextStyle),
  );
}
