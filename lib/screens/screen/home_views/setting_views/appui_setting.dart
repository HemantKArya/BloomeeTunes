import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppUISettings extends StatelessWidget {
  const AppUISettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        surfaceTintColor: Default_Theme.themeColor,
        centerTitle: true,
        title: Text(
          'App UI Settings',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                  value: state.autoSlideCharts,
                  subtitle: Text(
                    "Slide charts automatically in home screen.",
                    style: TextStyle(
                            color: Default_Theme.primaryColor1.withOpacity(0.5),
                            fontSize: 12.5)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  title: Text(
                    "Auto slide charts",
                    style: const TextStyle(
                            color: Default_Theme.primaryColor1, fontSize: 17)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  onChanged: (value) {
                    context.read<SettingsCubit>().setAutoSlideCharts(value);
                  }),
            ],
          );
        },
      ),
    );
  }
}
