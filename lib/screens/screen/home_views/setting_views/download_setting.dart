import 'dart:io';

import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:Bloomee/screens/widgets/setting_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadSettings extends StatefulWidget {
  const DownloadSettings({super.key});

  @override
  State<DownloadSettings> createState() => _DownloadSettingsState();
}

Future<bool> storagePermission() async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  debugPrint('releaseVersion : ${androidInfo.version.release}');
  final int androidVersion = int.parse(androidInfo.version.release);
  bool havePermission = false;

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
      //..... as needed
    ].request(); //import 'package:permission_handler/permission_handler.dart';

    havePermission =
        request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    havePermission = status.isGranted;
  }

  if (!havePermission) {
    // if no permission then open app-setting
    await openAppSettings();
  }

  return havePermission;
}

class _DownloadSettingsState extends State<DownloadSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Download Settings',
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
                title: "Download Quality",
                subtitle:
                    "Universal audio quality preference for downloaded streams.",
                trailing: DropdownButton(
                  value: state.downQuality,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<SettingsCubit>().setDownQuality(newValue);
                    }
                  },
                  items: AudioStreamQualityPreference.values
                      .map((quality) => quality.label)
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
                title: "Download Folder",
                subtitle: state.downPath,
                trailing: Platform.isAndroid
                    ? null
                    : IconButton(
                        icon: const Icon(
                          MingCute.refresh_1_line,
                          color: Default_Theme.primaryColor1,
                        ),
                        onPressed: () {
                          context.read<SettingsCubit>().resetDownPath();
                        },
                      ),
                onTap: Platform.isAndroid
                    ? null
                    : () async {
                        if (Platform.isAndroid) {
                          // Check for storage permission
                          final permission = await storagePermission();
                          debugPrint('permission : $permission');
                        }
                        FilePicker.platform.getDirectoryPath().then((value) {
                          if (value != null) {
                            context.read<SettingsCubit>().setDownPath(value);
                          }
                        });
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}
