import 'dart:io';

import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/services/player/stream_quality_selector.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
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
  final DeviceInfoPlugin info = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  debugPrint('releaseVersion : ${androidInfo.version.release}');
  final int androidVersion = int.parse(androidInfo.version.release);
  bool havePermission = false;

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
    ].request();
    havePermission =
        request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    havePermission = status.isGranted;
  }

  if (!havePermission) {
    await openAppSettings();
  }

  return havePermission;
}

class _DownloadSettingsState extends State<DownloadSettings> {
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
          'Downloads',
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
              const SettingSectionHeader(label: 'Quality'),
              SettingCard(
                children: [
                  SettingQualityChipRow(
                    icon: MingCute.folder_download_fill,
                    title: 'Download Quality',
                    subtitle:
                        'Universal audio quality preference for downloaded tracks.',
                    options: AudioStreamQualityPreference.values
                        .map((q) => q.label)
                        .toList(),
                    selected: state.downQuality,
                    onSelected: (v) =>
                        context.read<SettingsCubit>().setDownQuality(v),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const SettingSectionHeader(label: 'Storage'),
              SettingCard(
                children: [
                  SettingNavTile(
                    icon: MingCute.folder_fill,
                    title: 'Download Folder',
                    subtitle: state.downPath,
                    roundBottom: Platform.isAndroid,
                    onTap: Platform.isAndroid
                        ? () {}
                        : () async {
                            FilePicker.platform
                                .getDirectoryPath()
                                .then((value) {
                              if (value != null) {
                                context
                                    .read<SettingsCubit>()
                                    .setDownPath(value);
                              }
                            });
                          },
                  ),
                  if (!Platform.isAndroid) ...[
                    const SettingDivider(),
                    SettingNavTile(
                      icon: MingCute.refresh_1_line,
                      title: 'Reset Download Folder',
                      subtitle: 'Restore the default download path.',
                      roundBottom: true,
                      onTap: () =>
                          context.read<SettingsCubit>().resetDownPath(),
                    ),
                  ],
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
