// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/appui_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/backup_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/download_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/stream_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/updates_setting.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Settings',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: ListView(
        children: [
          settingListTile(
              title: "Updates",
              subtitle: "Check for new updates",
              icon: MingCute.download_3_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdatesSettings(),
                  ),
                );
              }),
          settingListTile(
              title: "Downloads",
              subtitle: "Download Path,Download Quality and more...",
              icon: MingCute.folder_download_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadSettings(),
                  ),
                );
              }),
          settingListTile(
              title: "Stream Quality",
              subtitle: "Select the quality of the stream",
              icon: MingCute.airpods_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StreamingSettings(),
                  ),
                );
              }),
          settingListTile(
              title: "App UI Elements",
              subtitle: "Auto slide, etc.",
              icon: MingCute.display_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppUISettings(),
                  ),
                );
              }),
          settingListTile(
              title: "Backup & Restore",
              subtitle: "Backup, Restore, Reset and more...",
              icon: MingCute.coin_2_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupSettings(),
                  ),
                );
              }),
          settingListTile(
              title: "About",
              subtitle: "About the app, version, developer, etc.",
              icon: MingCute.github_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const About(),
                  ),
                );
              }),
        ],
      ),
    );
  }

  ListTile settingListTile(
      {required String title,
      required String subtitle,
      required IconData icon,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
        color: Default_Theme.primaryColor1,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 17)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
                color: Default_Theme.primaryColor1.withOpacity(0.5),
                fontSize: 12.5)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}
