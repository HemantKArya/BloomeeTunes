import 'dart:io';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/widgets/setting_tile.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupSettings extends StatelessWidget {
  const BackupSettings({super.key});

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
          'Storage',
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
                title: "Clear History In Every",
                subtitle: "Clear history after every specified Time.",
                trailing: DropdownButton(
                  value: state.historyClearTime,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ).merge(Default_Theme.secondoryTextStyle),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context
                          .read<SettingsCubit>()
                          .setHistoryClearTime(newValue);
                    }
                  },
                  items: <String>[
                    '3',
                    '7',
                    '14',
                    '30',
                    '60',
                    '90',
                    '180',
                    '365'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '${value} Days',
                      ),
                    );
                  }).toList(),
                ),
                onTap: () {},
              ),
              SettingTile(
                title: "Backup location",
                subtitle: state.backupPath,
                onTap: () async {
                  final hasStorageAccess = Platform.isAndroid
                      ? await Permission.storage.isGranted
                      : true;
                  if (!hasStorageAccess) {
                    await Permission.storage.request();
                    if (!await Permission.storage.isGranted) {
                      SnackbarService.showMessage("Storage permission denied!");
                      return;
                    }
                  }
                  FilePicker.platform.getDirectoryPath().then((value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setBackupPath(value);
                    }
                  });
                },
              ),
              SettingTile(
                title: "Create Backup",
                subtitle:
                    "Create a backup of your data and settings in a backup location.",
                onTap: () {
                  BloomeeDBService.createBackUp().then((value) {
                    if (value) {
                      SnackbarService.showMessage("Backup Succes!");
                    } else {
                      SnackbarService.showMessage("Backup Failed!");
                    }
                  });
                },
              ),
              SettingTile(
                title: "Restore Backup",
                subtitle:
                    "Restore your data and settings from a backup location.",
                onTap: () {
                  BloomeeDBService.backupExists().then((value) {
                    if (value) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(255, 24, 24, 24),
                              surfaceTintColor:
                                  const Color.fromARGB(255, 24, 24, 24),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "Yes",
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  onPressed: () {
                                    context.pop();
                                    BloomeeDBService.restoreDB().then((value) {
                                      if (value) {
                                        SnackbarService.showMessage(
                                            "Restore Success.");
                                      } else {
                                        SnackbarService.showMessage(
                                            "Restore failed");
                                      }
                                    });
                                  },
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Default_Theme.accentColor2),
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: Text(
                                      "No",
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ))
                              ],
                              content: Wrap(
                                children: [
                                  Center(
                                    child: Text(
                                      "Your current data will be removed while importing all previous data from backup file.\nDo you want to proceed?",
                                      textAlign: TextAlign.left,
                                      style: Default_Theme.secondoryTextStyle
                                          .merge(
                                        const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    } else {
                      SnackbarService.showMessage(
                          "No backup exists. Create backup first.");
                    }
                  });
                },
              ),
              SwitchListTile(
                title: Text("Auto Backup",
                    style: const TextStyle(
                            color: Default_Theme.primaryColor1, fontSize: 17)
                        .merge(Default_Theme.secondoryTextStyleMedium)),
                subtitle: Text(
                    "Automatically create a backup of your data on regular basis.",
                    style: TextStyle(
                            color: Default_Theme.primaryColor1.withOpacity(0.5),
                            fontSize: 12.5)
                        .merge(Default_Theme.secondoryTextStyleMedium)),
                value: state.autoBackup,
                onChanged: (value) {
                  context.read<SettingsCubit>().setAutoBackup(value);
                },
              ),
              // SettingTile(
              //   title: "Reset Settings",
              //   subtitle: "Reset all settings to default.",
              //   onTap: () {},
              // ),
            ],
          );
        },
      ),
    );
  }
}
