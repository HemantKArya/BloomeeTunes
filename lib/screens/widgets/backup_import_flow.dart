import 'package:Bloomee/blocs/backup/backup_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/models/backup/backup_document.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/backup/serial_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/current_playlist/cubit/current_playlist_cubit.dart';
import 'dart:async';

/// One presentation flow for Settings, Library, Open With, and Share.
class BackupImportFlow {
  static final _queue = SerialExecutor();

  static Future<void> show(BuildContext context, [String? path]) =>
      _queue.run(() async {
        if (!context.mounted) return;
        final cubit = context.read<BackupCubit>();
        final l10n = AppLocalizations.of(context)!;
        var acquired = false;
        try {
          if (cubit.state.busy) {
            await cubit.stream.firstWhere((state) => !state.busy);
            if (!context.mounted) return;
          }
          acquired = true;
          final document = await _progress(
              context, l10n.snackbarProcessingFile, () => cubit.prepare(path));
          if (document == null || !context.mounted) return;
          final selection = await showDialog<BackupSelection>(
            context: context,
            builder: (_) => _Preview(document: document),
          );
          if (selection == null || !context.mounted) return;
          if (selection.mode == BackupImportMode.replace) {
            final accepted = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text(l10n.storageRestoreConfirmTitle),
                      content: Text(l10n.backupReplaceWarning),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.buttonCancel)),
                        FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n.storageRestoreYes)),
                      ],
                    ));
            if (accepted != true || !context.mounted) return;
          }
          final result = await _progress(context, l10n.storageRestoring,
              () => cubit.apply(document, selection));
          if (context.mounted) {
            try {
              await context.read<SettingsCubit>().reload();
              if (selection.library && context.mounted) {
                await context.read<CurrentPlaylistCubit>().refreshAfterImport();
              }
            } catch (_) {
              result['refreshFailed'] = 1;
            }
            SnackbarService.showMessage(l10n.backupImportResult(
                result['addedPlaylists']!,
                result['addedEntries']!,
                result['addedHistory']! + result['addedSearches']!,
                result['changedSettings']!));
            if (result['refreshFailed'] == 1) {
              SnackbarService.showMessage(l10n.backupRefreshFailed);
            }
          }
        } catch (error) {
          if (context.mounted) {
            await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text(l10n.storageRestoreFailedTitle),
                      content: SelectableText('$error'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.buttonOk))
                      ],
                    ));
          }
        } finally {
          if (acquired) await cubit.finish();
        }
      });

  static Future<void> export(BuildContext context,
      {bool share = false, String? playlistName}) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final render = context.findRenderObject();
      final origin = render is RenderBox && render.hasSize
          ? render.localToGlobal(Offset.zero) & render.size
          : null;
      final cubit = context.read<BackupCubit>();
      final saved = await _progress(
          context,
          l10n.snackbarProcessingFile,
          () => cubit.export(
              share: share, playlistName: playlistName, origin: origin));
      if (!share && saved != null) {
        SnackbarService.showMessage(l10n.storageBackupCreatedAt(saved));
      }
    } catch (error) {
      SnackbarService.showMessage(l10n.storageBackupShareFailed('$error'));
    }
  }

  static Future<T> _progress<T>(
      BuildContext context, String label, Future<T> Function() action) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
            canPop: false,
            child: AlertDialog(
                content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(label)),
            ]))));
    unawaited(navigator.push(route));
    try {
      return await action();
    } finally {
      if (route.isActive) navigator.removeRoute(route);
    }
  }
}

class _Preview extends StatefulWidget {
  final BackupDocument document;
  const _Preview({required this.document});
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late bool library = widget.document.has('playlists');
  late bool history =
      widget.document.has('history') || widget.document.has('searchHistory');
  late bool settings = widget.document.has('settings');
  late BackupImportMode mode = widget.document.kind == 'playlist'
      ? BackupImportMode.newCopy
      : BackupImportMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = widget.document;
    return AlertDialog(
      title: Text(l10n.storageRestoreOptionsTitle),
      content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.backupPreviewCounts(d.playlistCount, d.trackCount)),
              for (final playlist in d.rows('playlists').take(5))
                Text(playlist['name'] as String,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Text(l10n.backupPortableDetails),
              for (final warning in d.warnings)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(warning),
                ),
              if (d.has('playlists'))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.storageRestoreMediaItems),
                  value: library,
                  onChanged: (v) => setState(() => library = v!),
                ),
              if (d.has('history') || d.has('searchHistory'))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.backupHistories),
                  value: history,
                  onChanged: (v) => setState(() => history = v!),
                ),
              if (d.has('settings'))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.backupPreferences),
                  value: settings,
                  onChanged: (v) => setState(() => settings = v!),
                ),
              DropdownButton<BackupImportMode>(
                value: mode,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                      value: BackupImportMode.newCopy,
                      child: Text(l10n.backupNewCopy)),
                  DropdownMenuItem(
                      value: BackupImportMode.merge,
                      child: Text(l10n.backupMerge)),
                  if (d.kind == 'backup' && d.allowsReplacement)
                    DropdownMenuItem(
                        value: BackupImportMode.replace,
                        child: Text(l10n.backupReplace)),
                ],
                onChanged: (v) => setState(() => mode = v!),
              ),
              Text(mode == BackupImportMode.replace
                  ? l10n.backupReplaceWarning
                  : l10n.backupMergeDetails),
            ],
          ))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.buttonCancel)),
        FilledButton(
            onPressed: !(library || history || settings)
                ? null
                : () => Navigator.pop(
                    context,
                    BackupSelection(
                        library: library,
                        history: history,
                        settings: settings,
                        mode: mode)),
            child: Text(l10n.storageRestoreContinue)),
      ],
    );
  }
}
