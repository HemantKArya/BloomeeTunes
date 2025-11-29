import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Audio Player',
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
              SettingTile(
                title: "Streaming Quality",
                subtitle:
                    "Quality of audio files streamed from online sources.",
                trailing: DropdownButton(
                  value: state.strmQuality,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setStrmQuality(newValue);
                    }
                  },
                  items: <String>['96 kbps', '160 kbps', '320 kbps']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                      ),
                    );
                  }).toList(),
                ),
                onTap: () {},
              ),
              SettingTile(
                title: "Youtube Songs Streaming Quality",
                subtitle:
                    "Quality of Youtube audio files streamed from Youtube.",
                trailing: DropdownButton(
                  value: state.ytStrmQuality,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setYtStrmQuality(newValue);
                    }
                  },
                  items: <String>['High', 'Low']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                      ),
                    );
                  }).toList(),
                ),
                onTap: () {},
              ),
              SwitchListTile(
                  value: state.autoPlay,
                  title: Text(
                    "Auto Play",
                    style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ).merge(Default_Theme.secondoryTextStyle),
                  ),
                  subtitle: Text(
                    "Automatically add similar songs to the queue.",
                    style: TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<SettingsCubit>().setAutoPlay(value);
                  }),
            ],
          );
        },
      ),
    );
  }
}
