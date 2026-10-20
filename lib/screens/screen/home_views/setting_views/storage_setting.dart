import 'package:Bloomee/blocs/backup/backup_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/screens/widgets/backup_import_flow.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Bloomee/core/models/backup/recovery_copy.dart';

class BackupSettings extends StatelessWidget {
  const BackupSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(title: Text(l10n.storageSettingTitle)),
      body: BlocBuilder<BackupCubit, BackupState>(
        builder: (context, operation) =>
            BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) => Column(children: [
            if (operation.resetPending)
              MaterialBanner(
                content: Text(l10n.backupResetPending),
                actions: [
                  TextButton(
                      onPressed: () =>
                          context.read<BackupCubit>().cancelReset(),
                      child: Text(l10n.backupCancelReset))
                ],
              ),
            if (operation.busy) const LinearProgressIndicator(),
            Expanded(
                child: AbsorbPointer(
                    absorbing: operation.busy,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        SettingSectionHeader(label: l10n.settingsHistory),
                        SettingCard(children: [
                          SettingDropdownTile<String>(
                            icon: Icons.history,
                            title: l10n.storageClearHistoryEvery,
                            subtitle: l10n.storageClearHistorySubtitle,
                            value: state.historyClearTime,
                            items: [
                              '3',
                              '7',
                              '14',
                              '30',
                              '60',
                              '90',
                              '180',
                              '365'
                            ]
                                .map((v) => SettingDropdownItem(
                                    value: v,
                                    label: l10n.storageDays(int.parse(v))))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                context
                                    .read<SettingsCubit>()
                                    .setHistoryClearTime(v);
                              }
                            },
                          )
                        ]),
                        const SizedBox(height: 20),
                        SettingSectionHeader(label: l10n.settingsBackupRestore),
                        SettingCard(children: [
                          SettingNavTile(
                              icon: Icons.save_alt,
                              title: l10n.backupSave,
                              subtitle: l10n.backupPortableDetails,
                              onTap: () => BackupImportFlow.export(context)),
                          if (context.read<BackupCubit>().canShareFiles) ...[
                            const SettingDivider(),
                            SettingNavTile(
                                icon: Icons.share_outlined,
                                title: l10n.backupShare,
                                subtitle: l10n.backupLocationDetails,
                                onTap: () => BackupImportFlow.export(context,
                                    share: true)),
                          ],
                          const SettingDivider(),
                          SettingNavTile(
                              icon: Icons.restore,
                              title: l10n.storageRestoreBackup,
                              subtitle: l10n.storageRestoreBackupSubtitle,
                              onTap: () => BackupImportFlow.show(context)),
                          const SettingDivider(),
                          SettingNavTile(
                              icon: Icons.history,
                              title: l10n.backupRecoveryCopies,
                              subtitle: l10n.backupLocationDetails,
                              onTap: () async {
                                try {
                                  final paths = await context
                                      .read<BackupCubit>()
                                      .recoverySnapshots();
                                  if (!context.mounted) return;
                                  final selected = await showDialog<String>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            title:
                                                Text(l10n.backupRecoveryCopies),
                                            content: SizedBox(
                                                width: 480,
                                                child: paths.isEmpty
                                                    ? Text(l10n
                                                        .backupNoRecoveryCopies)
                                                    : SingleChildScrollView(
                                                        child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                            for (final copy
                                                                in paths)
                                                              ListTile(
                                                                  title: Text(
                                                                      switch (copy
                                                                          .reason) {
                                                                    RecoveryReason
                                                                          .automatic =>
                                                                      l10n.backupRecoveryAutomatic,
                                                                    RecoveryReason
                                                                          .beforeImport =>
                                                                      l10n.backupRecoveryBeforeImport,
                                                                    RecoveryReason
                                                                          .beforeReset =>
                                                                      l10n.backupRecoveryBeforeReset,
                                                                  }),
                                                                  subtitle: Text(DateFormat
                                                                          .yMd(l10n
                                                                              .localeName)
                                                                      .add_jm()
                                                                      .format(copy
                                                                          .createdAt
                                                                          .toLocal())),
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          ctx,
                                                                          copy.path)),
                                                          ]))),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child:
                                                      Text(l10n.buttonCancel))
                                            ],
                                          ));
                                  if (selected != null && context.mounted) {
                                    await BackupImportFlow.show(
                                        context, selected);
                                  }
                                } catch (error) {
                                  SnackbarService.showMessage(
                                      l10n.storageBackupShareFailed('$error'));
                                }
                              }),
                        ]),
                        const SizedBox(height: 20),
                        SettingSectionHeader(label: l10n.settingsAutomatic),
                        SettingCard(children: [
                          SettingToggleTile(
                              icon: Icons.backup_outlined,
                              title: l10n.storageAutoBackup,
                              subtitle: l10n.backupAutoDetails,
                              value: state.autoBackup,
                              onChanged: (v) => context
                                  .read<SettingsCubit>()
                                  .setAutoBackup(v)),
                          const SettingDivider(),
                          SettingToggleTile(
                              icon: Icons.lyrics_outlined,
                              title: l10n.storageAutoLyrics,
                              subtitle: l10n.storageAutoLyricsSubtitle,
                              value: state.autoSaveLyrics,
                              onChanged: (v) => context
                                  .read<SettingsCubit>()
                                  .setAutoSaveLyrics(v)),
                        ]),
                        const SizedBox(height: 20),
                        SettingSectionHeader(label: l10n.settingsDangerZone),
                        SettingCard(children: [
                          SettingDestructiveTile(
                            icon: Icons.delete_outline,
                            title: l10n.storageResetApp,
                            subtitle: l10n.backupResetDetails,
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title:
                                            Text(l10n.storageResetConfirmTitle),
                                        content: Text(l10n.backupResetDetails),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(l10n.buttonCancel)),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: Text(
                                                  l10n.storageResetButton)),
                                        ],
                                      ));
                              if (confirmed != true || !context.mounted) return;
                              try {
                                await context
                                    .read<BackupCubit>()
                                    .requestReset();
                                SnackbarService.showMessage(
                                    l10n.backupResetPending);
                              } catch (error) {
                                SnackbarService.showMessage(
                                    l10n.storageBackupShareFailed('$error'));
                              }
                            },
                          )
                        ]),
                      ],
                    ))),
          ]),
        ),
      ),
    );
  }
}
