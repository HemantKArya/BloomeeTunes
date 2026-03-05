import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Plugin Manager — install, load, unload and inspect plugins.
///
/// Accessible from Settings → Plugins. Shows all available `.bex` plugins
/// discovered in the plugins directory, with load/unload toggles and an
/// install-from-file button.
class PluginManagerScreen extends StatelessWidget {
  const PluginManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: BlocConsumer<PluginBloc, PluginState>(
          listenWhen: (prev, curr) =>
              prev.error != curr.error && curr.error != null,
          listener: (context, state) {
            if (state.error != null) {
              SnackbarService.showMessage(state.error!);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, state),
                if (!state.isInitialized)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Default_Theme.accentColor2,
                      ),
                    ),
                  )
                else if (state.availablePlugins.isEmpty)
                  const SliverFillRemaining(
                    child: SignBoardWidget(
                      message:
                          "No plugins installed.\nTap + to install a .bex plugin file.",
                      icon: MingCute.plugin_2_line,
                    ),
                  )
                else ...[
                  _buildSectionHeader(
                      'Content Resolvers', state, PluginType.contentResolver),
                  _buildPluginList(context, state, PluginType.contentResolver),
                  _buildSectionHeader(
                      'Chart Providers', state, PluginType.chartProvider),
                  _buildPluginList(context, state, PluginType.chartProvider),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context, PluginState state) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Default_Theme.themeColor,
      surfaceTintColor: Default_Theme.themeColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: Default_Theme.primaryColor1, size: 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Plugins',
        style: const TextStyle(
          color: Default_Theme.primaryColor1,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      actions: [
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Default_Theme.accentColor2,
              ),
            ),
          ),
        IconButton(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(),
          tooltip: 'Refresh',
          icon: const Icon(MingCute.refresh_2_line,
              color: Default_Theme.primaryColor1, size: 24),
          onPressed: () {
            context.read<PluginBloc>().add(const RefreshPlugins());
          },
        ),
        IconButton(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(),
          tooltip: 'Install Plugin',
          icon: const Icon(MingCute.add_circle_line,
              color: Default_Theme.accentColor2, size: 26),
          onPressed: () => _installPlugin(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, PluginState state, PluginType type) {
    final count =
        state.availablePlugins.where((p) => p.pluginType == type).length;
    if (count == 0) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ).merge(Default_Theme.secondoryTextStyleMedium),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plugin List ────────────────────────────────────────────────────────────

  Widget _buildPluginList(
      BuildContext context, PluginState state, PluginType type) {
    final plugins =
        state.availablePlugins.where((p) => p.pluginType == type).toList();

    if (plugins.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList.builder(
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: _PluginTile(
            plugin: plugins[index],
            isLoaded: state.isPluginLoaded(plugins[index].manifest.id),
            isOperating:
                state.operatingPluginId == plugins[index].manifest.id &&
                    state.isLoading,
          ),
        );
      },
    );
  }

  // ── Install From File ────────────────────────────────────────────────────

  Future<void> _installPlugin(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bex'],
        dialogTitle: 'Select Plugin Package (.bex)',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      if (context.mounted) {
        context.read<PluginBloc>().add(InstallPlugin(
              packedFilePath: filePath,
              shouldLoad: true,
            ));
        SnackbarService.showMessage('Installing plugin...', loading: true);
      }
    } catch (e) {
      SnackbarService.showMessage('Failed to pick file: $e');
    }
  }
}

// ─── Plugin Tile ───────────────────────────────────────────────────────────

class _PluginTile extends StatelessWidget {
  final PluginInfo plugin;
  final bool isLoaded;
  final bool isOperating;

  const _PluginTile({
    required this.plugin,
    required this.isLoaded,
    this.isOperating = false,
  });

  /// Deterministic color from plugin name for the first-letter avatar.
  Color _avatarColor(String name) {
    const palette = [
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFFFDAE61),
      Color(0xFFE17055),
      Color(0xFF0984E3),
      Color(0xFFD63031),
      Color(0xFF00CEC9),
      Color(0xFFE84393),
    ];
    var hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0x7FFFFFFF;
    }
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final manifest = plugin.manifest;
    final color = _avatarColor(manifest.name);

    return InkWell(
      onTap: () => _showPluginDetails(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLoaded
              ? Default_Theme.accentColor2.withValues(alpha: 0.06)
              : Default_Theme.primaryColor1.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLoaded
                ? Default_Theme.accentColor2.withValues(alpha: 0.25)
                : Default_Theme.primaryColor1.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // First-letter colored avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isLoaded
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  manifest.name.isNotEmpty
                      ? manifest.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: isLoaded ? color : color.withValues(alpha: 0.7),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          manifest.name,
                          style: const TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ).merge(Default_Theme.secondoryTextStyle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${manifest.publisher.name} • v${manifest.version}',
                    style: TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      fontSize: 12,
                    ).merge(Default_Theme.secondoryTextStyle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (manifest.hostSite.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: manifest.hostSite
                          .take(3)
                          .map((site) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  site,
                                  style: TextStyle(
                                    color: Default_Theme.primaryColor1
                                        .withValues(alpha: 0.45),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ).merge(Default_Theme.secondoryTextStyle),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Load/Unload toggle
            if (isOperating)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Default_Theme.accentColor2,
                ),
              )
            else
              _LoadToggle(
                isLoaded: isLoaded,
                onToggle: () {
                  final bloc = context.read<PluginBloc>();
                  if (isLoaded) {
                    bloc.add(UnloadPlugin(
                      pluginId: manifest.id,
                      pluginType: plugin.pluginType,
                    ));
                  } else {
                    bloc.add(LoadPlugin(
                      pluginId: manifest.id,
                      pluginType: plugin.pluginType,
                    ));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showPluginDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<PluginBloc>(),
        child: _PluginDetailSheet(plugin: plugin),
      ),
    );
  }
}

// ─── Load Toggle ───────────────────────────────────────────────────────────

class _LoadToggle extends StatelessWidget {
  final bool isLoaded;
  final VoidCallback onToggle;

  const _LoadToggle({required this.isLoaded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 30,
      child: Switch(
        value: isLoaded,
        onChanged: (_) => onToggle(),
        activeThumbColor: Default_Theme.primaryColor1,
        activeTrackColor: Default_Theme.accentColor2,
        inactiveThumbColor: Default_Theme.primaryColor1.withValues(alpha: 0.5),
        inactiveTrackColor: Default_Theme.primaryColor1.withValues(alpha: 0.15),
      ),
    );
  }
}

// ─── Plugin Detail Sheet ──────────────────────────────────────────────────

class _PluginDetailSheet extends StatelessWidget {
  final PluginInfo plugin;

  const _PluginDetailSheet({
    required this.plugin,
  });

  @override
  Widget build(BuildContext context) {
    final manifest = plugin.manifest;

    return BlocBuilder<PluginBloc, PluginState>(
      builder: (context, state) {
        final isLoaded = state.isPluginLoaded(manifest.id);
        final operating =
            state.operatingPluginId == manifest.id && state.isLoading;

        return Container(
          decoration: const BoxDecoration(
            color: Default_Theme.themeColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: icon + name + version
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLoaded
                          ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                          : Default_Theme.primaryColor1.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        plugin.pluginType == PluginType.contentResolver
                            ? MingCute.music_2_fill
                            : MingCute.chart_bar_fill,
                        color: isLoaded
                            ? Default_Theme.accentColor2
                            : Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manifest.name,
                          style: const TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ).merge(Default_Theme.secondoryTextStyleMedium),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _StatusBadge(isLoaded: isLoaded),
                            const SizedBox(width: 8),
                            Text(
                              'v${manifest.version}',
                              style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.5),
                                fontSize: 12,
                              ).merge(Default_Theme.secondoryTextStyle),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              if (manifest.description.isNotEmpty) ...[
                Text(
                  manifest.description,
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
                const SizedBox(height: 16),
              ],

              // Details grid
              _DetailRow(
                  label: 'Type',
                  value: plugin.pluginType == PluginType.contentResolver
                      ? 'Content Resolver'
                      : 'Chart Provider'),
              _DetailRow(label: 'Publisher', value: manifest.publisher.name),
              _DetailRow(label: 'License', value: manifest.license),
              if (manifest.homepage.isNotEmpty)
                _DetailRow(label: 'Homepage', value: manifest.homepage),
              if (manifest.hostSite.isNotEmpty)
                _DetailRow(
                    label: 'Sources', value: manifest.hostSite.join(', ')),
              if (manifest.capabilities.isNotEmpty)
                _DetailRow(
                    label: 'Capabilities',
                    value: manifest.capabilities.join(', ')),
              _DetailRow(label: 'Plugin ID', value: manifest.id),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: isLoaded ? 'Unload' : 'Load',
                      icon:
                          isLoaded ? MingCute.power_line : MingCute.flash_line,
                      color: isLoaded
                          ? Default_Theme.primaryColor1
                          : Default_Theme.accentColor2,
                      isLoading: operating,
                      onPressed: () {
                        final bloc = context.read<PluginBloc>();
                        if (isLoaded) {
                          bloc.add(UnloadPlugin(
                            pluginId: manifest.id,
                            pluginType: plugin.pluginType,
                          ));
                        } else {
                          bloc.add(LoadPlugin(
                            pluginId: manifest.id,
                            pluginType: plugin.pluginType,
                          ));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Delete',
                      icon: MingCute.delete_2_line,
                      color: const Color(0xFFFF5252),
                      isLoading: operating,
                      onPressed: () {
                        _confirmDelete(context, manifest.id, manifest.name);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, String pluginId, String pluginName) {
    // Capture bloc reference while context is still mounted.
    final bloc = context.read<PluginBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.15),
          ),
        ),
        title: Text(
          'Delete Plugin',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        content: Text(
          'Permanently delete "$pluginName"?\n\n'
          'This will unload the plugin and remove all its files from disk.',
          style: TextStyle(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
          ).merge(Default_Theme.secondoryTextStyle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // close bottom sheet
              bloc.add(DeletePlugin(
                pluginId: pluginId,
                pluginType: plugin.pluginType,
              ));
              SnackbarService.showMessage('Deleting $pluginName...',
                  loading: true);
            },
            child: Text(
              'Delete',
              style: const TextStyle(
                color: Color(0xFFFF5252),
                fontWeight: FontWeight.w600,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isLoaded;
  const _StatusBadge({required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isLoaded
            ? const Color(0xFF5EFF43).withValues(alpha: 0.15)
            : Default_Theme.primaryColor1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isLoaded ? 'Loaded' : 'Unloaded',
        style: TextStyle(
          color: isLoaded
              ? const Color(0xFF5EFF43)
              : Default_Theme.primaryColor1.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.4),
                fontSize: 13,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                fontSize: 13,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(
        isLoading ? 'Working...' : label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ).merge(Default_Theme.secondoryTextStyle),
      ),
    );
  }
}
