import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/utils/app_distribution.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class UpdatesSettings extends StatelessWidget {
  const UpdatesSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Default_Theme.primaryColor1,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          l10n.settingsNotifications,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: settingsPagePadding(context),
        children: [
          // Store installs are updated by the Store.
          if (!AppDistribution.updatesManagedExternally) ...[
            SettingSectionHeader(label: l10n.updateSettingTitle),
            BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (prev, curr) =>
                  prev.autoUpdateNotify != curr.autoUpdateNotify,
              builder: (context, state) => SettingCard(
                children: [
                  SettingNavTile(
                    icon: MingCute.download_3_fill,
                    title: l10n.updateCheckForUpdates,
                    subtitle: l10n.updateCheckSubtitle,
                    roundBottom: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CheckUpdateView()),
                    ),
                  ),
                  const SettingDivider(),
                  SettingToggleTile(
                    icon: MingCute.notification_fill,
                    title: l10n.updateAutoNotify,
                    subtitle: l10n.updateAutoNotifySubtitle,
                    value: state.autoUpdateNotify,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .setAutoUpdateNotify(value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
          SettingSectionHeader(label: l10n.feedSection),
          BlocSelector<NotificationCubit, NotificationState, bool>(
            selector: (state) => state.showOnHome,
            builder: (context, showOnHome) => SettingCard(
              children: [
                SettingToggleTile(
                  icon: MingCute.news_fill,
                  title: l10n.feedOnHome,
                  subtitle: l10n.feedOnHomeSubtitle,
                  value: showOnHome,
                  onChanged: (value) =>
                      context.read<NotificationCubit>().setShowOnHome(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
