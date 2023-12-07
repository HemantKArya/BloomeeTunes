import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
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
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Update",
              style: const TextStyle(
                      color: Default_Theme.primaryColor1, fontSize: 20)
                  .merge(Default_Theme.secondoryTextStyleMedium),
            ),
            subtitle: Text(
              "Check for latest updates",
              style: TextStyle(
                      color: Default_Theme.primaryColor1.withOpacity(0.5),
                      fontSize: 14)
                  .merge(Default_Theme.secondoryTextStyleMedium),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CheckUpdateView()));
            },
          ),
        ],
      ),
    );
  }
}
