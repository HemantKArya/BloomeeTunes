// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/bloomee_ui_kit/bloomee_dialog.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/manifest.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/screens/screen/home_views/plugin_repository_view.dart';
import 'package:Bloomee/plugins/blocs/repository/plugin_repository_cubit.dart';
import 'package:Bloomee/plugins/utils/plugin_constants.dart';

class PluginManagerScreen extends StatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  State<PluginManagerScreen> createState() => _PluginManagerScreenState();
}

class _PluginManagerScreenState extends State<PluginManagerScreen> {
  final ValueNotifier<PluginType?> _selectedFilterNotifier =
      ValueNotifier(null);

  Map<PluginType?, String> _filterOptions(AppLocalizations l10n) => {
        null: l10n.pluginManagerFilterAll,
        PluginType.contentResolver: l10n.pluginManagerFilterContent,
        PluginType.chartProvider: l10n.pluginManagerFilterCharts,
        PluginType.lyricsProvider: l10n.pluginManagerFilterLyrics,
        PluginType.searchSuggestionProvider:
            l10n.pluginManagerFilterSuggestions,
        PluginType.contentImporter: l10n.pluginManagerFilterImporters,
      };

  @override
  void dispose() {
    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) =>
          PluginRepositoryCubit(ServiceLocator.pluginRepositoryService),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Default_Theme.themeColor,
          appBar: _buildAppBar(context, l10n),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildInstalledPluginsTab(context, l10n),
              const PluginRepositoryView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstalledPluginsTab(
      BuildContext context, AppLocalizations l10n) {
    return BlocConsumer<PluginBloc, PluginState>(
      listenWhen: (prev, curr) =>
          (prev.error != curr.error && curr.error != null) ||
          (prev.successMessage != curr.successMessage &&
              curr.successMessage != null),
      listener: (context, state) {
        if (state.error != null) SnackbarService.showMessage(state.error!);
        if (state.successMessage != null)
          SnackbarService.showMessage(state.successMessage!);
      },
      builder: (context, state) {
        if (!state.isInitialized) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Default_Theme.accentColor2, strokeWidth: 3));
        }

        if (state.availablePlugins.isEmpty) {
          return SignBoardWidget(
              message: l10n.pluginManagerEmpty, icon: MingCute.plugin_2_line);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 900), // Standardized Desktop Alignment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChipsHeader(l10n),
                Expanded(
                  child: ValueListenableBuilder<PluginType?>(
                    valueListenable: _selectedFilterNotifier,
                    builder: (context, selectedFilter, _) {
                      final filteredPlugins = selectedFilter == null
                          ? state.availablePlugins
                          : state.availablePlugins
                              .where((p) => p.pluginType == selectedFilter)
                              .toList();

                      return _buildPluginGridOrList(
                          context, l10n, state, filteredPlugins);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── App Bar with Redesigned Constrained TabBar ─────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Default_Theme.themeColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Default_Theme.primaryColor1, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        l10n.pluginManagerTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      // Sleek, centered, constrained Segmented Control
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 380), // Strict max-width for Desktop perfection
            child: Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
                borderRadius:
                    BorderRadius.circular(14), // Perfect concentric math
                border: Border.all(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
                    width: 1),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                indicator: BoxDecoration(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                      10), // 14 (outer) - 4 (padding) = 10 (inner)
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2), // Subtle lift effect
                    ),
                  ],
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: Colors.white,
                unselectedLabelColor:
                    Default_Theme.primaryColor2.withValues(alpha: 0.65),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -0.2),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: "Installed"),
                  Tab(text: "Plugin Store"),
                ],
              ),
            ),
          ),
        ),
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
                        strokeWidth: 2.5, color: Default_Theme.accentColor2)),
              );
            }
            return IconButton(
              tooltip: l10n.pluginManagerTooltipRefresh,
              icon: const Icon(MingCute.refresh_2_line,
                  color: Default_Theme.primaryColor1, size: 22),
              onPressed: () =>
                  context.read<PluginBloc>().add(const RefreshPlugins()),
            );
          },
        ),
        IconButton(
          tooltip: l10n.pluginManagerTooltipInstall,
          icon: const Icon(MingCute.add_circle_line,
              color: Default_Theme.accentColor2, size: 24),
          onPressed: () => _installPlugin(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Scalable Chips Header ────────────────────────────────────────────────

  Widget _buildChipsHeader(AppLocalizations l10n) {
    final filterOptions = _filterOptions(l10n);
    return SizedBox(
      height: 52,
      child: ValueListenableBuilder<PluginType?>(
        valueListenable: _selectedFilterNotifier,
        builder: (context, selectedFilter, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final entry = filterOptions.entries.elementAt(index);
              final filterType = entry.key;
              final label = entry.value;
              final isSelected = selectedFilter == filterType;

              return InkWell(
                onTap: () => _selectedFilterNotifier.value = filterType,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.transparent,
                highlightColor:
                    Default_Theme.primaryColor1.withValues(alpha: 0.05),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Default_Theme.accentColor2
                          : Default_Theme.primaryColor1.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Responsive List/Grid View ─────────────────────────────────────────────

  Widget _buildPluginGridOrList(BuildContext context, AppLocalizations l10n,
      PluginState state, List<PluginInfo> plugins) {
    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MingCute.ghost_line,
                size: 48,
                color: Default_Theme.primaryColor1.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              l10n.pluginManagerNoMatch,
              style: TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 750) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                key: ValueKey(plugins[index].manifest.id),
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
              key: ValueKey(plugins[index].manifest.id),
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
    final l10n = AppLocalizations.of(context)!;
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
        context
            .read<PluginBloc>()
            .add(InstallPlugin(packedFilePath: filePath, shouldLoad: true));
        SnackbarService.showMessage(l10n.pluginManagerInstalling,
            loading: true);
      }
    } catch (e) {
      SnackbarService.showMessage(l10n.pluginManagerPickFailed(e.toString()));
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
        splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.04),
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
                        ? Default_Theme.accentColor2.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: _pluginAvatar(
                    manifest: manifest,
                    type: plugin.pluginType,
                    isLoaded: isLoaded,
                    iconSize: 20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            manifest.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (manifest.manifestVersion !=
                            CURRENT_MANIFEST_VERSION) ...[
                          const SizedBox(width: 6),
                          const Tooltip(
                            message:
                                "Plugin uses an outdated manifest version. Some features might break. Consider updating.",
                            child: Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 18),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manifest.publisher.name} • v${manifest.version}',
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
                          pluginType: plugin.pluginType));
                    } else {
                      bloc.add(LoadPlugin(
                          pluginId: manifest.id,
                          pluginType: plugin.pluginType));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _pluginTypeIcon(PluginType type) {
    return switch (type) {
      PluginType.contentResolver => MingCute.music_2_fill,
      PluginType.chartProvider => MingCute.chart_bar_fill,
      PluginType.lyricsProvider => MingCute.align_center_fill,
      PluginType.searchSuggestionProvider => MingCute.search_fill,
      PluginType.contentImporter => MingCute.file_import_fill,
    };
  }

  static String _pluginTypeLabel(PluginType type, AppLocalizations l10n) {
    return switch (type) {
      PluginType.contentResolver => l10n.pluginManagerTypeContentResolver,
      PluginType.chartProvider => l10n.pluginManagerTypeChartProvider,
      PluginType.lyricsProvider => l10n.pluginManagerTypeLyricsProvider,
      PluginType.searchSuggestionProvider =>
        l10n.pluginManagerTypeSuggestionProvider,
      PluginType.contentImporter => l10n.pluginManagerTypeContentImporter,
    };
  }

  static Widget _pluginAvatar({
    required Manifest manifest,
    required PluginType type,
    required bool isLoaded,
    required double iconSize,
    BorderRadius? borderRadius,
  }) {
    final imageUrl = manifest.thumbnailUrl ?? manifest.icon;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => _fallbackIcon(type, isLoaded, iconSize),
        errorWidget: (context, url, error) =>
            _fallbackIcon(type, isLoaded, iconSize),
      );
    }
    return _fallbackIcon(type, isLoaded, iconSize);
  }

  static Widget _fallbackIcon(PluginType type, bool isLoaded, double iconSize) {
    return Center(
      child: Icon(
        _pluginTypeIcon(type),
        color: isLoaded
            ? Default_Theme.accentColor2
            : Default_Theme.primaryColor1.withValues(alpha: 0.5),
        size: iconSize,
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
    if (oldWidget.isLoading && !widget.isLoading) {
      _localValue = widget.value;
    } else if (!widget.isLoading && oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  void _handleTap() {
    if (widget.isLoading) return;
    setState(() => _localValue = !_localValue);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isLoading ? 0.6 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 50,
          height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(10),
                color: _localValue
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor1.withValues(alpha: 0.4),
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _localValue
                                  ? Default_Theme.themeColor
                                  : Default_Theme.primaryColor1)))
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

  const _PluginDetailSheet({required this.plugin});

  @override
  Widget build(BuildContext context) {
    final manifest = plugin.manifest;
    final l10n = AppLocalizations.of(context)!;

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
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
                    width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isLoaded
                          ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                          : Default_Theme.primaryColor1.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isLoaded
                            ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: _PluginCard._pluginAvatar(
                        manifest: manifest,
                        type: plugin.pluginType,
                        isLoaded: isLoaded,
                        iconSize: 28,
                        borderRadius: BorderRadius.circular(16),
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
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              manifest.publisher.name,
                              style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
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
              if (manifest.description.isNotEmpty) ...[
                Text(
                  manifest.description,
                  style: TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                decoration: BoxDecoration(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                        label: l10n.pluginManagerDetailVersion,
                        value: manifest.version),
                    const _DetailDivider(),
                    _DetailRow(
                        label: l10n.pluginManagerDetailType,
                        value: _PluginCard._pluginTypeLabel(
                            plugin.pluginType, l10n)),
                    if (manifest.publisher.name.isNotEmpty) ...[
                      const _DetailDivider(),
                      _DetailRow(
                          label: l10n.pluginManagerDetailPublisher,
                          value: manifest.publisher.name),
                    ],
                    if (manifest.lastUpdated != null &&
                        manifest.lastUpdated!.isNotEmpty) ...[
                      const _DetailDivider(),
                      _DetailRow(
                          label: l10n.pluginManagerDetailLastUpdated,
                          value: _formatDate(manifest.lastUpdated!)),
                    ],
                    if (manifest.createdAt != null &&
                        manifest.createdAt!.isNotEmpty) ...[
                      const _DetailDivider(),
                      _DetailRow(
                          label: l10n.pluginManagerDetailCreated,
                          value: _formatDate(manifest.createdAt!)),
                    ],
                    if (manifest.homepage.isNotEmpty) ...[
                      const _DetailDivider(),
                      _DetailRow(
                          label: l10n.pluginManagerDetailHomepage,
                          value: manifest.homepage),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: operating
                            ? null
                            : () {
                                final bloc = context.read<PluginBloc>();
                                if (isLoaded) {
                                  bloc.add(UnloadPlugin(
                                      pluginId: manifest.id,
                                      pluginType: plugin.pluginType));
                                } else {
                                  bloc.add(LoadPlugin(
                                      pluginId: manifest.id,
                                      pluginType: plugin.pluginType));
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
                                      .withValues(alpha: 0.2)
                                  : Default_Theme.accentColor2
                                      .withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: operating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: isLoaded
                                        ? Colors.red
                                        : isLoaded
                                            ? Default_Theme.primaryColor1
                                            : Default_Theme.accentColor2))
                            : Text(
                                deleting
                                    ? l10n.pluginManagerDeleting
                                    : isLoaded
                                        ? l10n.pluginManagerUnloadPlugin
                                        : l10n.pluginManagerEnablePlugin,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (manifest.keysRequired.isNotEmpty) ...[
                    SizedBox(
                      height: 52,
                      width: 52,
                      child: IconButton(
                        onPressed: () => _showKeysDialog(context, manifest),
                        style: IconButton.styleFrom(
                          backgroundColor: Default_Theme.accentColor2
                              .withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: Default_Theme.accentColor2
                                    .withValues(alpha: 0.5),
                                width: 1.5),
                          ),
                        ),
                        icon: const Icon(Icons.key_rounded,
                            color: Default_Theme.accentColor2, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  SizedBox(
                    height: 52,
                    width: 52,
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
                              width: 1.5),
                        ),
                      ),
                      icon: const Icon(MingCute.delete_2_line,
                          color: Colors.red, size: 22),
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
    final l10n = AppLocalizations.of(context)!;

    showBloomeeDialog(
      context: context,
      title: l10n.pluginManagerDeleteTitle,
      subtitle: l10n.pluginManagerDeleteMessage(pluginName),
      icon: Icons.delete_outline_rounded,
      actions: [
        BloomeeDialogAction.text(l10n.pluginManagerCancel),
        BloomeeDialogAction.filled(
          l10n.pluginManagerDeleteAction,
          isDestructive: true,
          onPressed: () {
            if (plugin.manifest.keysRequired.isNotEmpty) {
              _confirmStorageCleanup(context, bloc, pluginId, pluginName);
            } else {
              if (context.mounted) Navigator.of(context).pop();
              bloc.add(DeletePlugin(
                  pluginId: pluginId, pluginType: plugin.pluginType));
            }
          },
        ),
      ],
    );
  }

  void _confirmStorageCleanup(BuildContext context, PluginBloc bloc,
      String pluginId, String pluginName) {
    final l10n = AppLocalizations.of(context)!;
    showBloomeeDialog(
      context: context,
      title: l10n.pluginManagerDeleteStorageTitle,
      subtitle: l10n.pluginManagerDeleteStorageMessage(pluginName),
      icon: Icons.storage_outlined,
      actions: [
        BloomeeDialogAction.text(
          l10n.pluginManagerDeleteStorageKeep,
          onPressed: () {
            if (context.mounted) Navigator.of(context).pop();
            bloc.add(DeletePlugin(
                pluginId: pluginId,
                pluginType: plugin.pluginType,
                cleanStorage: false));
          },
        ),
        BloomeeDialogAction.filled(
          l10n.pluginManagerDeleteStorageRemove,
          isDestructive: true,
          onPressed: () {
            if (context.mounted) Navigator.of(context).pop();
            bloc.add(DeletePlugin(
                pluginId: pluginId,
                pluginType: plugin.pluginType,
                cleanStorage: true));
          },
        ),
      ],
    );
  }

  void _showKeysDialog(BuildContext context, Manifest manifest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Default_Theme.themeColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _ApiKeysDialogContent(manifest: manifest),
    );
  }
}

// ─── Self-Contained API Keys Form State ─────────────────────────────────────

class _ApiKeysDialogContent extends StatefulWidget {
  final Manifest manifest;
  const _ApiKeysDialogContent({required this.manifest});

  @override
  State<_ApiKeysDialogContent> createState() => _ApiKeysDialogContentState();
}

class _ApiKeysDialogContentState extends State<_ApiKeysDialogContent> {
  late Future<Map<String, String>> _future;
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _future = _loadKeys();
  }

  Future<Map<String, String>> _loadKeys() async {
    final dao = ServiceLocator.pluginStorageDao;
    final existing = <String, String>{};
    for (final key in widget.manifest.keysRequired.keys) {
      final entity = await dao.getEntry(pluginId: widget.manifest.id, key: key);
      if (entity != null) existing[key] = entity.value;
    }
    return existing;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<Map<String, String>>(
      future: _future,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
              height: 200,
              child: Center(
                  child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2)));
        }

        final existing = snapshot.data!;
        for (final entry in widget.manifest.keysRequired.entries) {
          _controllers.putIfAbsent(entry.key,
              () => TextEditingController(text: existing[entry.key] ?? ''));
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.pluginManagerApiKeysTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...widget.manifest.keysRequired.entries.map((entry) {
                final req = entry.value;
                final keyLabel = entry.key
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w.isNotEmpty
                        ? '${w[0].toUpperCase()}${w.substring(1)}'
                        : '')
                    .join(' ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controllers[entry.key],
                        obscureText: req.isSecret,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: keyLabel,
                          hintText: req.defaultValue ?? entry.key,
                          filled: true,
                          fillColor: Default_Theme.primaryColor1
                              .withValues(alpha: 0.04),
                          labelStyle: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.6)),
                          hintStyle: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.3)),
                          suffixIcon: req.isSecret
                              ? Icon(MingCute.eye_close_line,
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.4),
                                  size: 20)
                              : null,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Default_Theme.primaryColor1
                                      .withValues(alpha: 0.08))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Default_Theme.accentColor2,
                                  width: 1.5)),
                        ),
                      ),
                      if (req.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            req.description,
                            style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          final dao = ServiceLocator.pluginStorageDao;
                          for (final entry in _controllers.entries) {
                            final val = entry.value.text.trim();
                            if (val.isNotEmpty) {
                              await dao.putEntry(
                                  pluginId: widget.manifest.id,
                                  key: entry.key,
                                  value: val);
                            } else {
                              await dao.deleteEntry(
                                  pluginId: widget.manifest.id, key: entry.key);
                            }
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          SnackbarService.showMessage(
                              l10n.pluginManagerApiKeysSaved);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text(l10n.pluginManagerSave,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
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
              color: Default_Theme.primaryColor1.withValues(alpha: 0.08))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Default_Theme.accentColor2)),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
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
            width: 1),
      ),
      child: Text(
        isLoaded ? 'Active' : 'Inactive',
        style: TextStyle(
            color: isLoaded
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatDate(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return isoDate;
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
          Text(label,
              style: TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
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
        color: Default_Theme.primaryColor1.withValues(alpha: 0.05));
  }
}
