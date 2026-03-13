// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/plugins/utils/plugin_constants.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';

enum _RemoteInstallPhase {
  idle,
  downloading,
  installing,
  installed,
  failed,
}

class RepositoryDetailScreen extends StatefulWidget {
  final PluginRepositoryModel repository;

  const RepositoryDetailScreen({super.key, required this.repository});

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {
  final Map<String, _RemoteInstallPhase> _phaseByPlugin = {};
  final Set<String> _pendingInstallIds = {};
  final Map<String, String> _errorByPlugin = {};

  int _parseVersionInt(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(trimmed)) return 0;
    return int.tryParse(trimmed) ?? 0;
  }

  int? _parseManifestVersion(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(trimmed);
    if (asDouble == null) return null;
    final floored = asDouble.floor();
    if ((asDouble - floored).abs() < 0.000001) return floored;
    return null;
  }

  Future<void> _downloadAndInstallPlugin(
      BuildContext context, RemotePluginModel plugin) async {
    if (_phaseByPlugin[plugin.id] == _RemoteInstallPhase.downloading ||
        _phaseByPlugin[plugin.id] == _RemoteInstallPhase.installing) {
      return;
    }

    setState(() {
      _phaseByPlugin[plugin.id] = _RemoteInstallPhase.downloading;
      _pendingInstallIds.add(plugin.id);
      _errorByPlugin.remove(plugin.id);
    });

    try {
      final response = await http
          .get(Uri.parse(plugin.downloadUrl))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${plugin.assetName}');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      if (!context.mounted) return;
      setState(
          () => _phaseByPlugin[plugin.id] = _RemoteInstallPhase.installing);

      context
          .read<PluginBloc>()
          .add(InstallPlugin(packedFilePath: file.path, shouldLoad: true));
    } catch (e) {
      log('Error downloading plugin ${plugin.id}: $e',
          name: 'RepositoryDetailScreen');
      if (!mounted) return;
      setState(() {
        _phaseByPlugin[plugin.id] = _RemoteInstallPhase.failed;
        _pendingInstallIds.remove(plugin.id);
        _errorByPlugin[plugin.id] = e.toString();
      });
      SnackbarService.showMessage('Failed to download ${plugin.name}.');
    }
  }

  void _syncWithPluginBlocFeedback(PluginState state) {
    final success = state.successMessage;
    final error = state.error;
    if (success == null && error == null) return;
    if (_pendingInstallIds.isEmpty) return;

    final ids = _pendingInstallIds.toList();
    var changed = false;
    for (final id in ids) {
      if (success != null && success.contains(id)) {
        _phaseByPlugin[id] = _RemoteInstallPhase.installed;
        _pendingInstallIds.remove(id);
        _errorByPlugin.remove(id);
        changed = true;
      } else if (error != null && error.contains(id)) {
        _phaseByPlugin[id] = _RemoteInstallPhase.failed;
        _pendingInstallIds.remove(id);
        _errorByPlugin[id] = error;
        changed = true;
      }
    }

    if (changed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Default_Theme.primaryColor1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          repo.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  children: [
                    Icon(MingCute.plugin_2_line,
                        size: 18,
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${repo.plugins.length} plugins available',
                        style: TextStyle(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (repo.generatedAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Updated ${repo.generatedAt!.toIso8601String().split('T').first}',
                          style: TextStyle(
                              color: Default_Theme.primaryColor2
                                  .withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<PluginBloc, PluginState>(
                  listenWhen: (prev, curr) =>
                      prev.successMessage != curr.successMessage ||
                      prev.error != curr.error,
                  listener: (context, state) =>
                      _syncWithPluginBlocFeedback(state),
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              mainAxisExtent: 134, // Perfect height for grid
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: repo.plugins.length,
                            itemBuilder: (context, index) => _buildPluginTile(
                                context, repo.plugins[index], state),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: repo.plugins.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildPluginTile(
                              context, repo.plugins[index], state),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPluginTile(
      BuildContext context, RemotePluginModel remotePlugin, PluginState state) {
    final installedPlugin = state.availablePlugins
        .where((p) => p.manifest.id == remotePlugin.id)
        .firstOrNull;

    final remoteVer = _parseVersionInt(remotePlugin.version);
    final localVer = installedPlugin == null
        ? 0
        : _parseVersionInt(installedPlugin.manifest.version);

    final remoteManifestVer =
        _parseManifestVersion(remotePlugin.manifestVersion);
    final remoteManifestCompatible = remoteManifestVer != null &&
        remoteManifestVer == CURRENT_MANIFEST_VERSION;

    final hasInstalled = installedPlugin != null;
    final canUpdate =
        hasInstalled && remoteManifestCompatible && remoteVer > localVer;
    final canInstall = !hasInstalled && remoteManifestCompatible;
    final installedManifestMismatch = hasInstalled &&
        installedPlugin.manifest.manifestVersion != CURRENT_MANIFEST_VERSION;

    final phase = _phaseByPlugin[remotePlugin.id] ?? _RemoteInstallPhase.idle;

    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildThumbnail(remotePlugin.thumbnailUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          remotePlugin.name,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (installedManifestMismatch) ...[
                        const SizedBox(width: 6),
                        const Tooltip(
                            message: 'Outdated manifest. Features may break.',
                            child: Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 16)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remotePlugin.description.isEmpty
                        ? 'No description provided.'
                        : remotePlugin.description,
                    style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaChip(label: 'v${remotePlugin.version}'),
                      _MetaChip(
                          label: remotePlugin.publisherName ??
                              'Unknown publisher'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildActionBtn(
              context,
              plugin: remotePlugin,
              phase: phase,
              canInstall: canInstall,
              canUpdate: canUpdate,
              hasInstalled: hasInstalled,
              remoteManifestCompatible: remoteManifestCompatible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
        ),
        placeholder: (_, __) => _defaultIcon(),
        errorWidget: (_, __, ___) => _defaultIcon(),
      );
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: Default_Theme.accentColor2.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Default_Theme.accentColor2.withValues(alpha: 0.3))),
      child: const Icon(MingCute.plugin_2_line,
          color: Default_Theme.accentColor2, size: 24),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required RemotePluginModel plugin,
    required _RemoteInstallPhase phase,
    required bool canInstall,
    required bool canUpdate,
    required bool hasInstalled,
    required bool remoteManifestCompatible,
  }) {
    if (phase == _RemoteInstallPhase.downloading ||
        phase == _RemoteInstallPhase.installing) {
      return const _AestheticButton(
          text: '', isLoading: true, color: Default_Theme.accentColor2);
    }

    if (phase == _RemoteInstallPhase.failed) {
      return Tooltip(
        message: _errorByPlugin[plugin.id] ?? 'Installation failed.',
        child: _AestheticButton(
          text: 'Retry',
          color: Colors.orange,
          onTap: () => _downloadAndInstallPlugin(context, plugin),
        ),
      );
    }

    if (!remoteManifestCompatible && !hasInstalled) {
      return const _AestheticButton(
          text: 'Outdated', color: Colors.orange, isSubdued: true);
    }

    if (canUpdate) {
      return _AestheticButton(
        text: 'Update',
        color: Default_Theme.accentColor2,
        onTap: () => _downloadAndInstallPlugin(context, plugin),
      );
    }

    if (hasInstalled || phase == _RemoteInstallPhase.installed) {
      return const _AestheticButton(
          text: 'Installed',
          color: Default_Theme.primaryColor2,
          isSubdued: true);
    }

    if (canInstall) {
      return _AestheticButton(
        text: 'Install',
        color: Default_Theme.accentColor2,
        onTap: () => _downloadAndInstallPlugin(context, plugin),
      );
    }

    return const _AestheticButton(
        text: 'Unavailable',
        color: Default_Theme.primaryColor2,
        isSubdued: true);
  }
}

// ── Shared UI Helpers ────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// A perfectly uniform, highly aesthetic button. Solves the "solid blob" and mismatched sizing issues.
class _AestheticButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final bool isSubdued;
  final VoidCallback? onTap;

  const _AestheticButton({
    required this.text,
    required this.color,
    this.isLoading = false,
    this.isSubdued = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If subdued (like "Installed"), we make it look recessed and greyed out
    final bgColor = isSubdued
        ? Default_Theme.primaryColor1.withValues(alpha: 0.04)
        : color.withValues(alpha: 0.15);
    final borderColor = isSubdued
        ? Default_Theme.primaryColor1.withValues(alpha: 0.08)
        : color.withValues(alpha: 0.3);
    final textColor =
        isSubdued ? Default_Theme.primaryColor1.withValues(alpha: 0.5) : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:
              105, // FIXED WIDTH ensures perfect grid alignment regardless of state
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2.5, color: color),
                )
              : Text(
                  text,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}
