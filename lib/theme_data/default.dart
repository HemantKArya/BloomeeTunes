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
      background: themeColor,
      brightness: Brightness.dark,
    ),
    iconTheme: const IconThemeData(color: primaryColor1),
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
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(primaryColor1),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? accentColor1
                : accentColor2),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? accentColor1
                : primaryColor2.withOpacity(0))),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: MaterialStateProperty.all(themeColor),
    ),
  );
}
