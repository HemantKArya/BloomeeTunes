// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:flutter/material.dart';

import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

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
          SettingTile(
            title: "Check for updates",
            subtitle: "Check for new updates",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckUpdateView(),
                ),
              );
            },
          ),
          FutureBuilder(
              future: context
                  .read<BloomeeDBCubit>()
                  .getSettingBool("auto_update_notify"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.decelerate,
                    child: SwitchListTile(
                        value: snapshot.data ?? false,
                        subtitle: Text(
                          "Get notified when new updates are available in app start up.",
                          style: TextStyle(
                                  color: Default_Theme.primaryColor1
                                      .withOpacity(0.5),
                                  fontSize: 14)
                              .merge(Default_Theme.secondoryTextStyleMedium),
                        ),
                        title: Text(
                          "Auto update notify",
                          style: const TextStyle(
                                  color: Default_Theme.primaryColor1,
                                  fontSize: 20)
                              .merge(Default_Theme.secondoryTextStyleMedium),
                        ),
                        onChanged: (value) {
                          context
                              .read<BloomeeDBCubit>()
                              .putSettingBool("auto_update_notify", value);
                        }),
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ],
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onTap;

  const SettingTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        this.title,
        style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 20)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        this.subtitle,
        style: TextStyle(
                color: Default_Theme.primaryColor1.withOpacity(0.5),
                fontSize: 14)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      onTap: () {
        onTap();
      },
    );
  }
}
