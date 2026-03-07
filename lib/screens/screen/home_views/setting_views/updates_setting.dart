import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class UpdatesSettings extends StatelessWidget {
  const UpdatesSettings({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Updates',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const SettingSectionHeader(label: 'App Updates'),
              SettingCard(
                children: [
                  SettingNavTile(
                    icon: MingCute.download_3_fill,
                    title: 'Check for Updates',
                    subtitle: 'See if a newer version of Bloomee is available.',
                    roundBottom: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckUpdateView(),
                        ),
                      );
                    },
                  ),
                  const SettingDivider(),
                  SettingToggleTile(
                    icon: MingCute.notification_fill,
                    title: 'Auto Update Notify',
                    subtitle:
                        'Get notified when new updates are available on app start.',
                    value: state.autoUpdateNotify,
                    onChanged: (value) {
                      context
                          .read<SettingsCubit>()
                          .setAutoUpdateNotify(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
