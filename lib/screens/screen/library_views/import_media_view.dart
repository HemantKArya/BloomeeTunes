import 'dart:developer';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';

class ImportMediaFromPlatformsView extends StatelessWidget {
  const ImportMediaFromPlatformsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.importSongsTitle,
          textAlign: TextAlign.start,
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<PluginBloc, PluginState>(
        builder: (context, pluginState) {
          final importerPlugins = pluginState.loadedContentImporters;

          return ListView(
            children: [
              if (importerPlugins.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.importNoPluginsLoaded,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ...importerPlugins.map((plugin) => _ImporterPluginTile(
                    pluginName: plugin.manifest.name,
                    pluginId: plugin.manifest.id,
                    description: plugin.manifest.description,
                  )),
              const Divider(
                color: Default_Theme.primaryColor2,
                indent: 16,
                endIndent: 16,
                height: 32,
              ),
              _ImportFromBtn(
                btnName: AppLocalizations.of(context)!.importBloomeeFiles,
                btnIcon: MingCute.file_import_fill,
                onClickFunc: () => _importBloomeeFile(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _importBloomeeFile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.importNoteTitle,
          style: TextStyle(color: Default_Theme.primaryColor2),
        ),
        content: Text(
          AppLocalizations.of(context)!.importNoteMessage,
          style: TextStyle(color: Default_Theme.primaryColor2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.buttonCancel),
          ),
          TextButton(
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
            child: Text(AppLocalizations.of(context)!.buttonOk),
          ),
        ],
      ),
    );
  }
}

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
    return ListTile(
      onTap: () {
        context.goNamed(
          RoutePaths.importProcess,
          queryParameters: {'pluginId': pluginId},
        );
      },
      leading: const Icon(
        MingCute.download_2_fill,
        color: Default_Theme.primaryColor1,
        size: 25,
      ),
      title: Text(
        pluginName,
        style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 18,
                fontWeight: FontWeight.w500)
            .merge(Default_Theme.secondoryTextStyle),
      ),
      subtitle: description != null
          ? Text(
              description!,
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Default_Theme.primaryColor2,
      ),
    );
  }
}

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
    return ListTile(
      onTap: onClickFunc,
      title: Text(
        btnName,
        style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 18,
                fontWeight: FontWeight.w500)
            .merge(Default_Theme.secondoryTextStyle),
      ),
      leading: Icon(
        btnIcon,
        color: Default_Theme.primaryColor1,
        size: 25,
      ),
    );
  }
}
