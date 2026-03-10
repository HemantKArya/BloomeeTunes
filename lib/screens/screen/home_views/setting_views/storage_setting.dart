import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/storage_backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupSettings extends StatelessWidget {
  const BackupSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Default_Theme.primaryColor1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.storageSettingTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // ── History ──────────────────────────────────────────────
              SettingSectionHeader(label: l10n.settingsHistory),
              SettingCard(
                children: [
                  SettingDropdownTile<String>(
                    icon: MingCute.history_line,
                    title: l10n.storageClearHistoryEvery,
                    subtitle: l10n.storageClearHistorySubtitle,
                    value: state.historyClearTime,
                    items: ['3', '7', '14', '30', '60', '90', '180', '365']
                        .map((v) => SettingDropdownItem<String>(
                              value: v,
                              label: l10n.storageDays(int.parse(v)),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context
                            .read<SettingsCubit>()
                            .setHistoryClearTime(newValue);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Backup & Restore ──────────────────────────────────────
              SettingSectionHeader(label: l10n.settingsBackupRestore),
              SettingCard(
                children: [
                  Column(
                    children: [
                      SettingNavTile(
                        icon: MingCute.folder_info_line,
                        title: l10n.storageBackupLocation,
                        subtitle: Platform.isAndroid
                            ? l10n.storageBackupLocationAndroid
                            : (state.backupPath.isNotEmpty
                                ? state.backupPath
                                : l10n.storageBackupLocationDownloads),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => _BackupLocationDialog(),
                        ),
                      ),
                      const SettingDivider(),
                      SettingNavTile(
                        icon: MingCute.save_2_line,
                        title: l10n.storageCreateBackup,
                        subtitle: l10n.storageCreateBackupSubtitle,
                        onTap: () {
                          StorageBackupService.createBackup().then((value) {
                            if (value != null) {
                              SnackbarService.showMessage(
                                  l10n.storageBackupCreatedAt(value));
                              if (Platform.isAndroid) {
                                try {
                                  SharePlus.instance
                                      .share(ShareParams(
                                    files: [XFile(value)],
                                    text: 'Bloomee backup file',
                                    subject: 'Bloomee Backup',
                                  ))
                                      .catchError((e) {
                                    SnackbarService.showMessage(
                                        l10n.storageBackupShareFailed(
                                            e.toString()));
                                    return ShareResult.unavailable;
                                  });
                                } catch (e) {
                                  SnackbarService.showMessage(l10n
                                      .storageBackupShareFailed(e.toString()));
                                }
                              }
                            } else {
                              SnackbarService.showMessage(
                                  l10n.storageBackupFailed);
                            }
                          });
                        },
                      ),
                      const SettingDivider(),
                      SettingNavTile(
                        icon: MingCute.restore_line,
                        title: l10n.storageRestoreBackup,
                        subtitle: l10n.storageRestoreBackupSubtitle,
                        onTap: () => _onRestoreTap(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Automatic ─────────────────────────────────────────────
              SettingSectionHeader(label: l10n.settingsAutomatic),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: MingCute.time_fill,
                    title: l10n.storageAutoBackup,
                    subtitle: l10n.storageAutoBackupSubtitle,
                    value: state.autoBackup,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().setAutoBackup(value),
                  ),
                  const SettingDivider(),
                  SettingToggleTile(
                    icon: MingCute.music_2_line,
                    title: l10n.storageAutoLyrics,
                    subtitle: l10n.storageAutoLyricsSubtitle,
                    value: state.autoSaveLyrics,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().setAutoSaveLyrics(value),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Danger Zone ───────────────────────────────────────────
              SettingSectionHeader(label: l10n.settingsDangerZone),
              SettingCard(
                children: [
                  SettingDestructiveTile(
                    icon: MingCute.delete_2_fill,
                    title: l10n.storageResetApp,
                    subtitle: l10n.storageResetAppSubtitle,
                    onTap: () async {
                      final proceed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor:
                              const Color.fromARGB(255, 24, 24, 24),
                          surfaceTintColor:
                              const Color.fromARGB(255, 24, 24, 24),
                          title: Text(
                            l10n.storageResetConfirmTitle,
                            style: Default_Theme.secondoryTextStyle.merge(
                              const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          content: Text(
                            l10n.storageResetConfirmMessage,
                            style: Default_Theme.secondoryTextStyle.merge(
                              const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.buttonCancel,
                                  style: Default_Theme.secondoryTextStyle.merge(
                                      const TextStyle(color: Colors.white))),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.storageResetButton,
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (proceed == true) {
                        await StorageBackupService.resetAppData();
                        SnackbarService.showMessage(l10n.storageResetSuccess);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _BackupLocationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
      surfaceTintColor: const Color.fromARGB(255, 24, 24, 24),
      title: Text(
        l10n.storageLocationDialogTitle,
        style: Default_Theme.secondoryTextStyle.merge(
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      content: Text(
        Platform.isAndroid
            ? l10n.storageLocationAndroid
            : l10n.storageLocationOther,
        style: Default_Theme.secondoryTextStyle
            .merge(const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonOk,
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ],
    );
  }
}

Future<void> _onRestoreTap(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    // 1) Ask user to pick a file
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      SnackbarService.showMessage(l10n.storageRestoreNoFile);
      return;
    }

    final picked = result.files.first;

    // 2) Save the picked file to internal documents directory
    final savedPath = await _savePickedFileToInternalDir(picked);
    if (savedPath == null) {
      SnackbarService.showMessage(l10n.storageRestoreSaveFailed);
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
            title: Text(l10n.storageRestoreOptionsTitle,
                style: Default_Theme.secondoryTextStyle
                    .merge(const TextStyle(color: Colors.white))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.storageRestoreOptionsDesc,
                    style: Default_Theme.secondoryTextStyle.merge(
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: selectAll,
                    onChanged: toggleSelectAll,
                    title: Text(l10n.storageRestoreSelectAll,
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
                    title: Text(l10n.storageRestoreMediaItems,
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
                    title: Text(l10n.storageRestoreSearchHistory,
                        style: Default_Theme.secondoryTextStyle
                            .merge(const TextStyle(color: Colors.white))),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Default_Theme.accentColor2,
                    checkColor: Colors.white,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx2).pop(null),
                child: Text(l10n.buttonCancel,
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
                child: Text(l10n.storageRestoreContinue,
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
          title: Text(l10n.storageRestoreConfirmTitle,
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))),
          content: Text(
            "${l10n.storageRestoreConfirmPrefix}\n\n"
            "${options.restoreMediaItems ? "${l10n.storageRestoreMediaBullet}\n" : ""}"
            "${options.restoreSearchHistory ? "${l10n.storageRestoreHistoryBullet}\n" : ""}"
            "\n${l10n.storageRestoreConfirmSuffix}",
            style: Default_Theme.secondoryTextStyle
                .merge(const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.storageRestoreNo,
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Default_Theme.accentColor2),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.storageRestoreYes,
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
                  l10n.storageRestoring,
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
      restoreResult = await StorageBackupService.restoreBackup(
        savedPath,
      );
    } catch (e, st) {
      log("restoreDB threw: $e\n$st", name: "DBProvider");
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
          log("Failed to pop progress dialog: $e", name: "StorageSetting");
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
    log("Unexpected error in restore flow: $e\n$st", name: "StorageSetting");
    SnackbarService.showMessage(l10n.storageUnexpectedError);
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
    log("Failed to save picked file: $e\n$st", name: "StorageSetting");
    return null;
  }
}

/// Show final result dialog. Asks user to restart for best consistency.
Future<void> _showResultDialog(
  BuildContext context, {
  required bool success,
  required List<String> errors,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        title: Text(
          success
              ? l10n.storageRestoreCompleted
              : l10n.storageRestoreFailedTitle,
          style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                success
                    ? l10n.storageRestoreSuccessMessage
                    : l10n.storageRestoreFailedMessage,
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
                  l10n.storageRestoreUnknownError,
                  style: Default_Theme.secondoryTextStyle
                      .merge(const TextStyle(color: Colors.white70)),
                ),
              const SizedBox(height: 8),
              Text(
                l10n.storageRestoreRestartHint,
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
              l10n.buttonOk,
              style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    },
  );
}
