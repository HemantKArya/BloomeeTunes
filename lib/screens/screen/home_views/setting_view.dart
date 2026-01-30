// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/appui_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/storage_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/country_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/download_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/lastfm_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/updates_setting.dart';
import 'package:Bloomee/screens/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/generated/l10n/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AutoTranslateText(
          AppLocalizations.of(context)!.settings,
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
              title: AppLocalizations.of(context)!.updates,
              subtitle: AppLocalizations.of(context)!.checkUpdates,
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
              title: AppLocalizations.of(context)!.downloads,
              subtitle: AppLocalizations.of(context)!.downloadsSubtitle,
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
              title: AppLocalizations.of(context)!.playerSettings,
              subtitle: AppLocalizations.of(context)!.playerSettingsSubtitle,
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
              title: AppLocalizations.of(context)!.uiSettings,
              subtitle: AppLocalizations.of(context)!.uiSettingsSubtitle,
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
              title: AppLocalizations.of(context)!.lastFmSettings,
              subtitle: AppLocalizations.of(context)!.lastFmSettingsSubtitle,
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
              title: AppLocalizations.of(context)!.storage,
              subtitle: AppLocalizations.of(context)!.storageSubtitle,
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
              title: AppLocalizations.of(context)!.languageCountry,
              subtitle: AppLocalizations.of(context)!.languageCountrySubtitle,
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
              title: AppLocalizations.of(context)!.about,
              subtitle: AppLocalizations.of(context)!.aboutSubtitle,
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
      title: AutoTranslateText(
        title,
        style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 16)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: AutoTranslateText(
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
