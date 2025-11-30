import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/widgets/setting_tile.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupSettings extends StatelessWidget {
  const BackupSettings({super.key});

  // Future<bool> storagePermission() async {
  //   final DeviceInfoPlugin info =
  //       DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  //   final AndroidDeviceInfo androidInfo = await info.androidInfo;
  //   debugPrint('releaseVersion : ${androidInfo.version.release}');
  //   final int androidVersion = int.parse(androidInfo.version.release);
  //   bool havePermission = false;

  //   if (androidVersion >= 13) {
  //     final request = await [
  //       Permission.videos,
  //       Permission.photos,
  //       //..... as needed
  //     ].request(); //import 'package:permission_handler/permission_handler.dart';

  //     havePermission =
  //         request.values.every((status) => status == PermissionStatus.granted);
  //   } else {
  //     final status = await Permission.storage.request();
  //     havePermission = status.isGranted;
  //   }

  //   if (!havePermission) {
  //     // if no permission then open app-setting
  //     await openAppSettings();
  //   }

  //   return havePermission;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    fontSize: 14,
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
                        '$value Days',
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                        surfaceTintColor: const Color.fromARGB(255, 24, 24, 24),
                        title: Text(
                          "Backup Location",
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        content: Text(
                          Platform.isAndroid
                              ? "Currently, the backup will be stored in:\n\n1. Download directory\n2. Android/data/ls.bloomee.musicplayer/data directory\n\nYou can copy the file from these locations."
                              : "Currently, the backup will be stored in the Downloads directory. You can copy the file from there.",
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "OK",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SettingTile(
                title: "Create Backup",
                subtitle:
                    "Create a backup of your data and settings in a backup location.",
                onTap: () {
                  BloomeeDBService.createBackUp().then((value) {
                    if (value != null) {
                      SnackbarService.showMessage("Backup created at $value");
                      if (Platform.isAndroid) {
                        // Temporary workaround for Android
                        try {
                          final file = XFile(value);
                          SharePlus.instance
                              .share(
                            ShareParams(
                              files: [file],
                              text: 'Bloomee backup file',
                              subject: 'Bloomee Backup',
                            ),
                          )
                              .catchError((e) {
                            SnackbarService.showMessage(
                                'Failed to share backup: $e');
                          });
                        } catch (e) {
                          SnackbarService.showMessage(
                              'Failed to share backup: $e');
                        }
                      }
                    } else {
                      SnackbarService.showMessage("Backup Failed!");
                    }
                  });
                },
              ),
              SettingTile(
                title: "Restore Backup",
                subtitle: "Restore your data and settings from a backup file.",
                onTap: () {
                  _onRestoreTap(context);
                },
              ),
              SettingTile(
                title: "Reset Bloomee App",
                subtitle:
                    "Clear all your data and reset the app to its default state.",
                onTap: () async {
                  final proceed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                        surfaceTintColor: const Color.fromARGB(255, 24, 24, 24),
                        title: Text(
                          "Confirm Reset",
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to reset the Bloomee app? This will delete all your data, including tunes you listened to, and reset the app to its default state. This action cannot be undone.",
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                            child: Text(
                              "No",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Default_Theme.accentColor2),
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                            child: Text(
                              "Yes",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (proceed == true) {
                    // Perform reset logic here
                    await BloomeeDBService.resetDB();
                    SnackbarService.showMessage(
                        "App has been reset to its default state.");
                  }
                },
                trailing: const Icon(
                  Icons.delete,
                  color: Default_Theme.primaryColor1,
                ),
              ),
              SwitchListTile(
                title: Text("Auto Backup",
                    style: const TextStyle(
                            color: Default_Theme.primaryColor1, fontSize: 16)
                        .merge(Default_Theme.secondoryTextStyleMedium)),
                subtitle: Text(
                    "Automatically create a backup of your data on regular basis.",
                    style: TextStyle(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                            fontSize: 12)
                        .merge(Default_Theme.secondoryTextStyleMedium)),
                value: state.autoBackup,
                onChanged: (value) {
                  context.read<SettingsCubit>().setAutoBackup(value);
                },
              ),
              SwitchListTile(
                  title: Text("Auto Save Lyrics",
                      style: const TextStyle(
                              color: Default_Theme.primaryColor1, fontSize: 16)
                          .merge(Default_Theme.secondoryTextStyleMedium)),
                  subtitle: Text(
                      "Automatically save lyrics of the song when played.",
                      style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5),
                              fontSize: 12)
                          .merge(Default_Theme.secondoryTextStyleMedium)),
                  value: state.autoSaveLyrics,
                  onChanged: (value) {
                    context.read<SettingsCubit>().setAutoSaveLyrics(value);
                  }),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _onRestoreTap(BuildContext context) async {
  try {
    // 1) Ask user to pick a file
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      SnackbarService.showMessage("No file selected.");
      return;
    }

    final picked = result.files.first;

    // 2) Save the picked file to internal documents directory
    final savedPath = await _savePickedFileToInternalDir(picked);
    if (savedPath == null) {
      SnackbarService.showMessage("Failed to save the selected file.");
      return;
    }

    // 3) Show options dialog: which parts to restore (defaults all true)
    final options = await showDialog<_RestoreOptions?>(
      context: context,
      builder: (ctx) {
        // initial values (all true)
        bool mediaItems = true;
        bool searchHistory = true;
        bool settingsAndPrefs = true;
        bool selectAll = true;

        return StatefulBuilder(builder: (ctx2, setState) {
          void updateSelectAllFromChildren() {
            final all = mediaItems && searchHistory && settingsAndPrefs;
            if (selectAll != all) setState(() => selectAll = all);
          }

          void toggleSelectAll(bool? v) {
            final value = v == true;
            setState(() {
              selectAll = value;
              mediaItems = value;
              searchHistory = value;
              settingsAndPrefs = value;
            });
          }

          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 24, 24, 24),
            title: Text("Restore Options",
                style: Default_Theme.secondoryTextStyle
                    .merge(const TextStyle(color: Colors.white))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose which data you want to restore from the selected backup file. "
                    "Unselect any items you do NOT want to be imported. By default all are selected.",
                    style: Default_Theme.secondoryTextStyle.merge(
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: selectAll,
                    onChanged: toggleSelectAll,
                    title: Text("Select All",
                        style: Default_Theme.secondoryTextStyle
                            .merge(const TextStyle(color: Colors.white))),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Default_Theme.accentColor2,
                    checkColor: Colors.white,
                  ),
                  const Divider(color: Colors.white12),
                  CheckboxListTile(
                    value: mediaItems,
                    onChanged: (v) {
                      setState(() => mediaItems = v ?? false);
                      updateSelectAllFromChildren();
                    },
                    title: Text("Media items (songs, tracks, library entries)",
                        style: Default_Theme.secondoryTextStyle
                            .merge(const TextStyle(color: Colors.white))),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Default_Theme.accentColor2,
                    checkColor: Colors.white,
                  ),
                  CheckboxListTile(
                    value: searchHistory,
                    onChanged: (v) {
                      setState(() => searchHistory = v ?? false);
                      updateSelectAllFromChildren();
                    },
                    title: Text("Search history",
                        style: Default_Theme.secondoryTextStyle
                            .merge(const TextStyle(color: Colors.white))),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Default_Theme.accentColor2,
                    checkColor: Colors.white,
                  ),
                  // CheckboxListTile(
                  //   value: settingsAndPrefs,
                  //   onChanged: (v) {
                  //     setState(() => settingsAndPrefs = v ?? false);
                  //     updateSelectAllFromChildren();
                  //   },
                  //   title: Text(
                  //       "Settings & preferences (theme, equalizer, tokens)",
                  //       style: Default_Theme.secondoryTextStyle
                  //           .merge(const TextStyle(color: Colors.white))),
                  //   controlAffinity: ListTileControlAffinity.leading,
                  //   activeColor: Default_Theme.accentColor2,
                  //   checkColor: Colors.white,
                  // ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx2).pop(null),
                child: Text("Cancel",
                    style: Default_Theme.secondoryTextStyle
                        .merge(const TextStyle(color: Colors.white))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2),
                onPressed: () {
                  Navigator.of(ctx2).pop(_RestoreOptions(
                    restoreMediaItems: mediaItems,
                    restoreSearchHistory: searchHistory,
                    restoreSettings: settingsAndPrefs,
                  ));
                },
                child: Text("Continue",
                    style: Default_Theme.secondoryTextStyle
                        .merge(const TextStyle(color: Colors.white))),
              ),
            ],
          );
        });
      },
    );

    // If user cancelled options dialog
    if (options == null) return;

    // 4) Show final confirmation with warning (user must confirm)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 24, 24, 24),
          title: Text("Confirm Restore",
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))),
          content: Text(
            "This will overwrite and merge the parts you selected in the app with data from the backup file:\n\n"
            "${options.restoreMediaItems ? "• Media items\n" : ""}"
            "${options.restoreSearchHistory ? "• Search history\n" : ""}"
            // "${options.restoreSettings ? "• Settings & preferences\n" : ""}\n"
            "Your current data will be modified/merged. Are you sure you want to proceed?",
            style: Default_Theme.secondoryTextStyle
                .merge(const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text("No",
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Default_Theme.accentColor2),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text("Yes, restore",
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      // user cancelled final confirmation
      return;
    }

    // 5) Show non-dismissible progress dialog and capture its context
    BuildContext? progressDialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        progressDialogContext = ctx; // capture
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 24, 24, 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  "Restoring selected data...\nPlease wait until the operation completes.",
                  textAlign: TextAlign.center,
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 6) Execute restore (guarantee progress dialog closed in finally)
    Map<String, dynamic> restoreResult = {
      "success": false,
      "errors": ["Restore not executed."]
    };
    try {
      // NOTE: This call must be async and ideally run heavy work inside its own isolates.
      // Signature: restoreDB(path, settings, searchHistory, mediaitems)
      restoreResult = await BloomeeDBService.restoreDB(
        savedPath,
        // settings: options.restoreSettings,
        searchHistory: options.restoreSearchHistory,
        mediaItems: options.restoreMediaItems,
      );
    } catch (e, st) {
      log("restoreDB threw: $e\n$st", name: "BloomeeDBService");
      restoreResult = {
        "success": false,
        "errors": ["Exception during restore: $e"]
      };
    } finally {
      // Always attempt to close the progress dialog using captured context
      if (progressDialogContext != null) {
        try {
          if (Navigator.of(progressDialogContext!).canPop()) {
            Navigator.of(progressDialogContext!).pop();
          }
        } catch (e) {
          log("Failed to pop progress dialog: $e", name: "BloomeeDBService");
        }
      } else {
        // Fallback: try to pop root navigator (best-effort)
        try {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } catch (_) {}
      }
      // allow UI a short moment to settle
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // 7) Show final result dialog and recommend restart
    final success = restoreResult["success"] == true;
    final errors = <String>[];
    if (restoreResult.containsKey("errors")) {
      final raw = restoreResult["errors"];
      if (raw is List) {
        errors.addAll(raw.map((e) => e.toString()));
      } else if (raw != null) {
        errors.add(raw.toString());
      }
    }

    await _showResultDialog(context, success: success, errors: errors);
  } catch (e, st) {
    log("Unexpected error in restore flow: $e\n$st", name: "BloomeeDBService");
    SnackbarService.showMessage(
        "An unexpected error occurred while restoring.");
  }
}

/// Simple holder for options selected in options dialog
class _RestoreOptions {
  final bool restoreMediaItems;
  final bool restoreSearchHistory;
  final bool restoreSettings;

  _RestoreOptions({
    required this.restoreMediaItems,
    required this.restoreSearchHistory,
    required this.restoreSettings,
  });
}

/// Save the picked file to app documents directory so the app retains access.
/// Returns saved file path or null.
Future<String?> _savePickedFileToInternalDir(PlatformFile picked) async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    final safeName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final filename =
        'bloomee_restore_${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final dest = File('${docs.path}/$filename');

    if (picked.bytes != null) {
      await dest.writeAsBytes(picked.bytes!, flush: true);
      return dest.path;
    }

    if (picked.path != null) {
      final source = File(picked.path!);
      await source.copy(dest.path);
      return dest.path;
    }

    return null;
  } catch (e, st) {
    log("Failed to save picked file: $e\n$st", name: "BloomeeDBService");
    return null;
  }
}

/// Show final result dialog. Asks user to restart for best consistency.
Future<void> _showResultDialog(
  BuildContext context, {
  required bool success,
  required List<String> errors,
}) async {
  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        title: Text(
          success ? "Restore Completed" : "Restore Failed",
          style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                success
                    ? "The selected data was restored successfully. For best results, please restart the app now."
                    : "The restore process failed with the following errors:",
                style: Default_Theme.secondoryTextStyle
                    .merge(const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              if (!success && errors.isNotEmpty)
                ...errors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "- $e",
                        style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ),
                    )),
              if (!success && errors.isEmpty)
                Text(
                  "Unknown error occurred during restore.",
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white70)),
                ),
              const SizedBox(height: 8),
              Text(
                "Please restart the app for better consistency.",
                style: Default_Theme.secondoryTextStyle.merge(
                    const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Default_Theme.accentColor2),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    },
  );
}
