// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/appui_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/local_music_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/plugin_defaults_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/storage_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/country_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/download_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/lastfm_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/updates_setting.dart';
import 'package:Bloomee/screens/screen/plugin_manager_screen.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
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
              title: AppLocalizations.of(context)!.settingsPlugins,
              subtitle: AppLocalizations.of(context)!.settingsPluginsSubtitle,
              icon: MingCute.plugin_2_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PluginManagerScreen(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsUpdates,
              subtitle: AppLocalizations.of(context)!.settingsUpdatesSubtitle,
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
              title: AppLocalizations.of(context)!.settingsDownloads,
              subtitle: AppLocalizations.of(context)!.settingsDownloadsSubtitle,
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
              title: AppLocalizations.of(context)!.settingsLocalTracks,
              subtitle:
                  AppLocalizations.of(context)!.settingsLocalTracksSubtitle,
              icon: MingCute.music_2_line,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocalMusicSettings(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsPlayer,
              subtitle: AppLocalizations.of(context)!.settingsPlayerSubtitle,
              icon: MingCute.airpods_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerSettings(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsPluginDefaults,
              subtitle:
                  AppLocalizations.of(context)!.settingsPluginDefaultsSubtitle,
              icon: MingCute.settings_6_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PluginDefaultsSettings(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsUIElements,
              subtitle:
                  AppLocalizations.of(context)!.settingsUIElementsSubtitle,
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
              title: AppLocalizations.of(context)!.settingsLastFM,
              subtitle: AppLocalizations.of(context)!.settingsLastFMSubtitle,
              icon: FontAwesome.lastfm_brand,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LastDotFM(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsStorage,
              subtitle: AppLocalizations.of(context)!.settingsStorageSubtitle,
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
              title: AppLocalizations.of(context)!.settingsLanguageCountry,
              subtitle:
                  AppLocalizations.of(context)!.settingsLanguageCountrySubtitle,
              icon: MingCute.globe_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountrySettings(),
                  ),
                );
              }),
          settingListTile(
              title: AppLocalizations.of(context)!.settingsAbout,
              subtitle: AppLocalizations.of(context)!.settingsAboutSubtitle,
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
        size: 27,
        color: Default_Theme.primaryColor1,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 16)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                fontSize: 12)
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
