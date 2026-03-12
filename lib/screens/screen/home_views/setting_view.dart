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
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Default_Theme.primaryColor1),
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 640), // Desktop & tablet responsive
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ── Group 1: Core App & Plugins ──
              _SettingsSection(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsPlugins,
                    subtitle:
                        AppLocalizations.of(context)!.settingsPluginsSubtitle,
                    icon: MingCute.plugin_2_fill,
                    iconColor: Default_Theme.accentColor2,
                    isHighlightIcon:
                        true, // Gives the accent color a bit more pop
                    onTap: () =>
                        _navigate(context, const PluginManagerScreen()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsPluginDefaults,
                    subtitle: AppLocalizations.of(context)!
                        .settingsPluginDefaultsSubtitle,
                    icon: MingCute.settings_6_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () =>
                        _navigate(context, const PluginDefaultsSettings()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsUpdates,
                    subtitle:
                        AppLocalizations.of(context)!.settingsUpdatesSubtitle,
                    icon: MingCute.download_3_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const UpdatesSettings()),
                  ),
                ],
              ),

              // ── Group 2: Playback & Media ──
              _SettingsSection(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsPlayer,
                    subtitle:
                        AppLocalizations.of(context)!.settingsPlayerSubtitle,
                    icon: MingCute.airpods_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const PlayerSettings()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsDownloads,
                    subtitle:
                        AppLocalizations.of(context)!.settingsDownloadsSubtitle,
                    icon: MingCute.folder_download_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const DownloadSettings()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsLocalTracks,
                    subtitle: AppLocalizations.of(context)!
                        .settingsLocalTracksSubtitle,
                    icon: MingCute.music_2_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const LocalMusicSettings()),
                  ),
                ],
              ),

              // ── Group 3: Preferences & Integrations ──
              _SettingsSection(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsUIElements,
                    subtitle: AppLocalizations.of(context)!
                        .settingsUIElementsSubtitle,
                    icon: MingCute.display_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const AppUISettings()),
                  ),
                  _SettingsTile(
                    title:
                        AppLocalizations.of(context)!.settingsLanguageCountry,
                    subtitle: AppLocalizations.of(context)!
                        .settingsLanguageCountrySubtitle,
                    icon: MingCute.globe_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const CountrySettings()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsStorage,
                    subtitle:
                        AppLocalizations.of(context)!.settingsStorageSubtitle,
                    icon: MingCute.coin_2_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const BackupSettings()),
                  ),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsLastFM,
                    subtitle:
                        AppLocalizations.of(context)!.settingsLastFMSubtitle,
                    icon: FontAwesome.lastfm_brand,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const LastDotFM()),
                  ),
                ],
              ),

              // ── Group 4: Info ──
              _SettingsSection(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.settingsAbout,
                    subtitle:
                        AppLocalizations.of(context)!.settingsAboutSubtitle,
                    icon: MingCute.github_fill,
                    iconColor: Default_Theme.accentColor2,
                    onTap: () => _navigate(context, const About()),
                  ),
                ],
              ),

              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// ── Custom Widgets for Modern Settings UI ───────────────────────────────────

/// Wraps a list of settings tiles in a beautifully rounded, borderless card.
class _SettingsSection extends StatelessWidget {
  final List<Widget> children;
  const _SettingsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        // Solid, subtle surface color with NO border. Looks much cleaner.
        color: Default_Theme.primaryColor1.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors
              .transparent, // Required to let the InkWell splash render correctly inside
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildrenWithDividers(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      // Add a very subtle divider after every item except the last one
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            color: Default_Theme.primaryColor1
                .withOpacity(0.04), // Very faint line
            indent: 66, // Aligns perfectly with the text start
            endIndent: 16,
          ),
        );
      }
    }
    return result;
  }
}

/// A highly polished, readable individual settings row with custom soft touch effects.
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isHighlightIcon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.isHighlightIcon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Overriding the default harsh white/blue splash with a subtle, cohesive dark tint
      splashColor: Default_Theme.primaryColor1.withOpacity(0.06),
      highlightColor: Default_Theme.primaryColor1.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon wrapped in a soft, rounded square
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isHighlightIcon
                    ? iconColor.withOpacity(0.12)
                    : Default_Theme.primaryColor1.withOpacity(
                        0.06), // Muted background for non-highlight icons
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isHighlightIcon ? iconColor : iconColor.withOpacity(0.85),
              ),
            ),
            const SizedBox(width: 14),
            // Main text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      // Using 0.92 opacity pure white prevents halation (harsh glow) on dark screens
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Default_Theme.primaryColor2.withOpacity(
                          0.65), // Softer, highly readable description
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Dimmed right chevron hint
            Icon(
              Icons.chevron_right_rounded,
              color: Default_Theme.primaryColor2.withOpacity(0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
