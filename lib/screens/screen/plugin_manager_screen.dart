// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class PluginManagerScreen extends StatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  State<PluginManagerScreen> createState() => _PluginManagerScreenState();
}

class _PluginManagerScreenState extends State<PluginManagerScreen> {
  // null means "All"
  PluginType? _selectedFilter;

  // Easily scalable for future plugin types
  final Map<PluginType?, String> _filterOptions = {
    null: "All",
    PluginType.contentResolver: "Content Resolvers",
    PluginType.chartProvider: "Chart Providers",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<PluginBloc, PluginState>(
        listenWhen: (prev, curr) =>
            (prev.error != curr.error && curr.error != null) ||
            (prev.successMessage != curr.successMessage &&
                curr.successMessage != null),
        listener: (context, state) {
          if (state.error != null) {
            SnackbarService.showMessage(state.error!);
          }
          if (state.successMessage != null) {
            SnackbarService.showMessage(state.successMessage!);
          }
        },
        builder: (context, state) {
          if (!state.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: Default_Theme.accentColor2,
                strokeWidth: 3,
              ),
            );
          }

          if (state.availablePlugins.isEmpty) {
            return const SignBoardWidget(
              message: "No plugins installed.\nTap + to add a .bex file.",
              icon: MingCute.plugin_2_line,
            );
          }

          final filteredPlugins = _selectedFilter == null
              ? state.availablePlugins
              : state.availablePlugins
                  .where((p) => p.pluginType == _selectedFilter)
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChipsHeader(),
              Expanded(
                child: _buildPluginGridOrList(context, state, filteredPlugins),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        'Plugins',
        style: const TextStyle(
          color: Default_Theme.primaryColor1,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
      actions: [
        BlocBuilder<PluginBloc, PluginState>(
          builder: (context, state) {
            if (state.hasActiveOperations) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Default_Theme.accentColor2,
                  ),
                ),
              );
            }
            return IconButton(
              tooltip: 'Refresh',
              icon: const Icon(MingCute.refresh_2_line,
                  color: Default_Theme.primaryColor1, size: 22),
              onPressed: () {
                context.read<PluginBloc>().add(const RefreshPlugins());
              },
            );
          },
        ),
        IconButton(
          tooltip: 'Install Plugin',
          icon: const Icon(MingCute.add_circle_line,
              color: Default_Theme.accentColor2, size: 24),
          onPressed: () => _installPlugin(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Scalable Chips Header ────────────────────────────────────────────────

  Widget _buildChipsHeader() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filterOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = _filterOptions.entries.elementAt(index);
          final filterType = entry.key;
          final label = entry.value;
          final isSelected = _selectedFilter == filterType;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filterType;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                      : Default_Theme.primaryColor1.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                        : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor1.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Responsive List/Grid View ─────────────────────────────────────────────

  Widget _buildPluginGridOrList(
      BuildContext context, PluginState state, List<PluginInfo> plugins) {
    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MingCute.ghost_line,
              size: 48,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              "No plugins match this filter",
              style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                fontSize: 15,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 750) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 94,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: plugins.length,
            itemBuilder: (context, index) {
              return AnimatedListItem(
                index: index,
                child: _PluginCard(
                  plugin: plugins[index],
                  isLoaded: state.isPluginLoaded(plugins[index].manifest.id),
                  operation: state.operationFor(plugins[index].manifest.id),
                ),
              );
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: plugins.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return AnimatedListItem(
              index: index,
              child: _PluginCard(
                plugin: plugins[index],
                isLoaded: state.isPluginLoaded(plugins[index].manifest.id),
                operation: state.operationFor(plugins[index].manifest.id),
              ),
            );
          },
        );
      },
    );
  }

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

// ─── Clean, Premium Plugin Card ────────────────────────────────────────────

class _PluginCard extends StatelessWidget {
  final PluginInfo plugin;
  final bool isLoaded;
  final PluginOperation? operation;

  const _PluginCard({
    required this.plugin,
    required this.isLoaded,
    this.operation,
  });

  @override
  Widget build(BuildContext context) {
    final manifest = plugin.manifest;
    final isDeleting = operation == PluginOperation.deleting;
    final isOperating = operation != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDeleting ? null : () => _showPluginDetails(context),
        borderRadius: BorderRadius.circular(16),
        highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLoaded
                  ? Default_Theme.accentColor2.withValues(alpha: 0.2)
                  : Default_Theme.primaryColor1.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Themed Icon Avatar exactly matching your reference aesthetic
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLoaded
                      ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                      : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLoaded
                        ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    plugin.pluginType == PluginType.contentResolver
                        ? MingCute.music_2_fill
                        : MingCute.chart_bar_fill,
                    color: isLoaded
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor1.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      manifest.name,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manifest.publisher.name} • v${manifest.version}',
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ).merge(Default_Theme.secondoryTextStyle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              if (isDeleting)
                const _InlineOperationIndicator(label: 'Deleting')
              else
                _CustomSwitch(
                  value: isLoaded,
                  isLoading: isOperating,
                  onChanged: () {
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

// ─── OPTIMISTIC & SMOOTH Custom Switch Widget ──────────────────────────────
class _CustomSwitch extends StatefulWidget {
  final bool value;
  final bool isLoading;
  final VoidCallback onChanged;

  const _CustomSwitch({
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<_CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<_CustomSwitch> {
  late bool _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync logic: If loading finishes, OR if the bloc force-updates the state externally,
    // sync our local optimistic value with the true bloc state.
    if (oldWidget.isLoading && !widget.isLoading) {
      _localValue = widget.value;
    } else if (!widget.isLoading && oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  void _handleTap() {
    if (widget.isLoading) return; // Prevent double-taps while loading

    // 1. Optimistically update local state for INSTANT fluid animation
    setState(() {
      _localValue = !_localValue;
    });

    // 2. Trigger actual backend event
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        // Dim slightly if a network/load request is actively happening
        duration: const Duration(milliseconds: 200),
        opacity: widget.isLoading ? 0.6 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic, // Snappy, clean curve
          width: 50,
          height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), // Squircle-like design
            color: _localValue
                ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                : Default_Theme.primaryColor1.withValues(alpha: 0.05),
            border: Border.all(
              color: _localValue
                  ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                  : Default_Theme.primaryColor1.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment:
                _localValue ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Inner squircle thumb
                color: _localValue
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor1.withValues(alpha: 0.4),
              ),
              // Optional: Show a tiny spinner inside the thumb while loading
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _localValue
                              ? Default_Theme.themeColor
                              : Default_Theme.primaryColor1,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Professional, Clean Bottom Sheet ──────────────────────────────────────

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
        final operation = state.operationFor(manifest.id);
        final operating = operation != null;
        final deleting = operation == PluginOperation.deleting;

        return Container(
          decoration: BoxDecoration(
            color: Default_Theme.themeColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isLoaded
                          ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                          : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLoaded
                            ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
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
                        size: 28,
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
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ).merge(Default_Theme.secondoryTextStyleMedium),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              manifest.publisher.name,
                              style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ).merge(Default_Theme.secondoryTextStyle),
                            ),
                            const SizedBox(width: 10),
                            _StatusBadge(isLoaded: isLoaded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              if (manifest.description.isNotEmpty) ...[
                Text(
                  manifest.description,
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                    fontSize: 15,
                    height: 1.5,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
                const SizedBox(height: 24),
              ],

              // Clean Meta-data Container
              Container(
                decoration: BoxDecoration(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'Version', value: manifest.version),
                    const _DetailDivider(),
                    _DetailRow(
                        label: 'Type',
                        value: plugin.pluginType == PluginType.contentResolver
                            ? 'Content Resolver'
                            : 'Chart Provider'),
                    const _DetailDivider(),
                    _DetailRow(label: 'License', value: manifest.license),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Actions Layer (Strict Heights for exact Alignment)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54, // Fixed height for exact alignment
                      child: ElevatedButton(
                        onPressed: operating
                            ? null
                            : () {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoaded
                              ? Colors.transparent
                              : Default_Theme.accentColor2
                                  .withValues(alpha: 0.15),
                          foregroundColor: isLoaded
                              ? Default_Theme.primaryColor1
                              : Default_Theme.accentColor2,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isLoaded
                                  ? Default_Theme.primaryColor1
                                      .withValues(alpha: 0.15)
                                  : Default_Theme.accentColor2
                                      .withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: operating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: isLoaded
                                      ? Colors.red
                                      : isLoaded
                                          ? Default_Theme.primaryColor1
                                          : Default_Theme.accentColor2,
                                ),
                              )
                            : Text(
                                deleting
                                    ? 'Deleting...'
                                    : isLoaded
                                        ? 'Unload Plugin'
                                        : 'Enable Plugin',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ).merge(Default_Theme.secondoryTextStyle),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete Button
                  SizedBox(
                    height: 54, // Perfectly matching height
                    width: 54, // Creates a perfect square
                    child: IconButton(
                      onPressed: operating
                          ? null
                          : () => _confirmDelete(
                              context, manifest.id, manifest.name),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.red.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        MingCute.delete_2_line,
                        color: Colors.red,
                        size: 22,
                      ),
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
    final bloc = context.read<PluginBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.1),
          ),
        ),
        title: Text(
          'Delete Plugin?',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        content: Text(
          'Are you sure you want to delete "$pluginName"? This will permanently remove its files.',
          style: TextStyle(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
            height: 1.4,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              bloc.add(DeletePlugin(
                pluginId: pluginId,
                pluginType: plugin.pluginType,
              ));
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineOperationIndicator extends StatelessWidget {
  final String label;

  const _InlineOperationIndicator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Default_Theme.accentColor2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyleMedium),
          ),
        ],
      ),
    );
  }
}

// ─── Shared UI Helpers ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isLoaded;
  const _StatusBadge({required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLoaded
            ? Default_Theme.accentColor2.withValues(alpha: 0.15)
            : Default_Theme.primaryColor1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLoaded
              ? Default_Theme.accentColor2.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(
        isLoaded ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isLoaded
              ? Default_Theme.accentColor2
              : Default_Theme.primaryColor1.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
    );
  }
}
