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
  static const primaryColor2 = Color.fromARGB(255, 242, 231, 240);
  static const accentColor1 = Color(0xFF0EA5E0);
  static const accentColor1light = Color(0xFF18C9ED);
  static const accentColor2 = Color(0xFFFE385E);
  static const successColor = Color(0xFF5EFF43);

  ThemeData defaultThemeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: themeColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: accentColor2,
      secondary: accentColor1,
      brightness: Brightness.dark,
      surface: themeColor,
    ),
    iconTheme: const IconThemeData(color: primaryColor1),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(accentColor2),
      interactive: true,
      radius: const Radius.circular(10),
      thickness: WidgetStateProperty.all(5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: themeColor,
      // elevation: 0,
      iconTheme: IconThemeData(color: primaryColor1),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: accentColor2),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: accentColor2,
      selectionColor: accentColor2,
      selectionHandleColor: accentColor2,
    ),
    brightness: Brightness.dark,
    switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(primaryColor1),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accentColor1
                : accentColor2),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accentColor1
                : primaryColor2.withOpacity(0))),
    searchBarTheme: const SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(themeColor),
    ),
  );
}
