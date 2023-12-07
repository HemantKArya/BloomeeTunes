import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Settings',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: Text(
          'Bloomee🌸 is up-to-date!!!',
          style: TextStyle(color: Default_Theme.accentColor2, fontSize: 20)
              .merge(Default_Theme.tertiaryTextStyle),
        ),
      ),
    );
  }
}
