import 'dart:developer';
import 'dart:io';

import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/services/m3u_processor.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';

class ImportMediaFromPlatformsView extends StatefulWidget {
  const ImportMediaFromPlatformsView({super.key});

  @override
  State<ImportMediaFromPlatformsView> createState() =>
      _ImportMediaFromPlatformsViewState();
}

class _ImportMediaFromPlatformsViewState
    extends State<ImportMediaFromPlatformsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Default_Theme.primaryColor1),
        title: Text(
          AppLocalizations.of(context)!.importSongsTitle,
          style: Default_Theme.secondoryTextStyle.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 640), // Desktop responsiveness
          child: BlocBuilder<PluginBloc, PluginState>(
            builder: (context, pluginState) {
              final importerPlugins = pluginState.loadedContentImporters;

              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  if (importerPlugins.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...importerPlugins.map((plugin) => _ImporterPluginTile(
                          pluginName: plugin.manifest.name,
                          pluginId: plugin.manifest.id,
                          description: plugin.manifest.description,
                        )),
                  const SizedBox(height: 16),
                  Divider(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.1),
                    indent: 16,
                    endIndent: 16,
                    height: 32,
                  ),
                  const SizedBox(height: 8),
                  _ImportFromBtn(
                    btnName: AppLocalizations.of(context)!.importBloomeeFiles,
                    btnIcon: MingCute.file_import_fill,
                    onClickFunc: () => _importBloomeeFile(context),
                  ),
                  const SizedBox(height: 10),
                  _ImportFromBtn(
                    btnName: AppLocalizations.of(context)!.importM3UFiles,
                    btnIcon: MingCute.playlist_2_line,
                    onClickFunc: () => _importM3UFile(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MingCute.plugin_2_line,
              size: 48,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.importNoPluginsLoaded,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Import Bloomee JSON/BLM files ────────────────────────────────────────

  void _importBloomeeFile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text(
          AppLocalizations.of(context)!.importNoteTitle,
          style: Default_Theme.primaryTextStyle.merge(
            const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.importNoteMessage,
          style: TextStyle(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              AppLocalizations.of(context)!.buttonCancel,
              style: TextStyle(
                color: Default_Theme.primaryColor2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              FilePicker.platform.pickFiles().then((value) {
                if (value != null && value.files[0].path != null) {
                  final path = value.files[0].path!;
                  if (path.endsWith('.blm') || path.endsWith('.json')) {
                    SnackbarService.showMessage(
                        AppLocalizations.of(context)!.snackbarImportingMedia);
                    ImportExportService.importJSON(path).then((_) {
                      SnackbarService.showMessage(AppLocalizations.of(context)!
                          .snackbarImportCompleted);
                    });
                  } else {
                    log('Invalid File Format', name: 'Import File');
                    SnackbarService.showMessage(AppLocalizations.of(context)!
                        .snackbarInvalidFileFormat);
                  }
                }
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: Default_Theme.accentColor2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.buttonOk,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Import M3U playlist ──────────────────────────────────────────────────

  Future<void> _importM3UFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['m3u', 'm3u8'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.first.path;
    if (filePath == null) return;

    if (!context.mounted) return;
    SnackbarService.showMessage(
        AppLocalizations.of(context)!.snackbarProcessingFile);

    final Map<String, dynamic> parsed;
    try {
      final content = await File(filePath).readAsString();
      parsed = parseM3UToJson(content);
    } catch (e) {
      log('Failed to parse M3U: $e', name: 'ImportM3U');
      if (context.mounted) {
        SnackbarService.showMessage(
            AppLocalizations.of(context)!.snackbarInvalidFileFormat);
      }
      return;
    }

    // Use embedded playlist name or ask the user.
    final rawName = (parsed['playlistName'] as String?)?.trim() ?? '';
    final String playlistName;
    if (rawName.isNotEmpty) {
      playlistName = rawName;
    } else {
      if (!context.mounted) return;
      final asked = await _askPlaylistName(context);
      if (asked == null) return; // user cancelled
      playlistName = asked;
    }

    // Build ImportTrackItem list from parsed M3U entries.
    final rawItems = parsed['mediaItems'] as List<dynamic>? ?? [];
    final tracks = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final artistStr = item['artist']?.toString() ?? '';
          final artists = artistStr.isNotEmpty ? [artistStr] : <String>[];
          final durationSec = item['duration'] as num?;
          return ImportTrackItem(
            title: item['title']?.toString() ?? '',
            artists: artists,
            albumTitle: item['album']?.toString(),
            thumbnailUrl: item['artURL']?.toString(),
            durationMs: durationSec != null
                ? BigInt.from((durationSec * 1000).toInt())
                : null,
            isExplicit: false,
            url: item['streamingURL']?.toString(),
          );
        })
        .where((t) => t.title.isNotEmpty)
        .toList();

    if (tracks.isEmpty) {
      if (context.mounted) {
        SnackbarService.showMessage(
            AppLocalizations.of(context)!.importM3UNoTracks);
      }
      return;
    }

    final summary = ImportCollectionSummary(
      title: playlistName,
      kind: ImportCollectionType.playlist,
      trackCount: tracks.length,
    );

    if (!context.mounted) return;
    // Start resolution immediately; navigate so the process screen is visible.
    context.read<ContentImportCubit>().loadFromM3U(tracks, summary);
    context.goNamed(
      RoutePaths.importProcess,
      queryParameters: {'pluginId': ''},
    );
  }

  /// Prompts the user to enter a playlist name. Returns null if cancelled.
  Future<String?> _askPlaylistName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text(
          AppLocalizations.of(context)!.importM3UNameDialogTitle,
          style: Default_Theme.primaryTextStyle.merge(
            const TextStyle(color: Default_Theme.primaryColor1, fontSize: 18),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          cursorColor: Default_Theme.accentColor2,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.importM3UNameHint,
            hintStyle: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Default_Theme.accentColor2, width: 2),
            ),
          ),
          onSubmitted: (v) {
            final name = v.trim();
            if (name.isNotEmpty) Navigator.of(dialogCtx).pop(name);
          },
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              AppLocalizations.of(context)!.buttonCancel,
              style: TextStyle(color: Default_Theme.primaryColor2),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => FilledButton(
              onPressed: val.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(dialogCtx).pop(val.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: Default_Theme.accentColor2,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Default_Theme.accentColor2.withValues(alpha: 0.4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.buttonOk,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

// ─── Plugin importer tile ─────────────────────────────────────────────────────

class _ImporterPluginTile extends StatelessWidget {
  final String pluginName;
  final String pluginId;
  final String? description;

  const _ImporterPluginTile({
    required this.pluginName,
    required this.pluginId,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.goNamed(
              RoutePaths.importProcess,
              queryParameters: {'pluginId': pluginId},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    MingCute.download_2_fill,
                    color: Default_Theme.accentColor2,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pluginName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: TextStyle(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generic import button ────────────────────────────────────────────────────

class _ImportFromBtn extends StatelessWidget {
  final String btnName;
  final IconData btnIcon;
  final VoidCallback onClickFunc;

  const _ImportFromBtn({
    required this.btnName,
    required this.btnIcon,
    required this.onClickFunc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onClickFunc,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    btnIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    btnName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
