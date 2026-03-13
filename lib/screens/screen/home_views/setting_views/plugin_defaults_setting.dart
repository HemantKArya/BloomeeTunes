import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class PluginDefaultsSettings extends StatelessWidget {
  const PluginDefaultsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
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
          l10n.pluginDefaultsTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return BlocBuilder<PluginBloc, PluginState>(
            builder: (context, pluginState) {
              final resolvers = pluginState.loadedContentResolvers;
              final lyricsProviders = pluginState.loadedLyricsProviders;
              final suggestionProviders =
                  pluginState.loadedSearchSuggestionProviders;
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildDiscoverSourceSection(
                      context, l10n, settingsState, resolvers),
                  const SizedBox(height: 28),
                  _buildResolverPrioritySection(
                      context, l10n, settingsState, resolvers),
                  const SizedBox(height: 28),
                  _buildLyricsPrioritySection(
                      context, l10n, settingsState, lyricsProviders),
                  const SizedBox(height: 28),
                  _buildSuggestionPluginSection(
                      context, l10n, settingsState, suggestionProviders),
                  const SizedBox(height: 40),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscoverSourceSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState state,
    List<PluginInfo> resolvers,
  ) {
    final hasStoredSelection = state.homePluginId.isNotEmpty &&
        resolvers.any((plugin) => plugin.manifest.id == state.homePluginId);
    final selectedPluginId = hasStoredSelection ? state.homePluginId : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSectionHeader(label: l10n.pluginDefaultsDiscoverHeader),
        if (resolvers.isEmpty)
          SettingCard(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const SettingIconBox(icon: MingCute.plugin_2_line),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.pluginDefaultsNoResolver,
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          SettingCard(
            children: [
              SettingRadioTile<String>(
                title: l10n.settingsAutomatic,
                subtitle: l10n.pluginDefaultsAutomaticSubtitle,
                value: '',
                groupValue: selectedPluginId,
                onChanged: (_) {
                  context.read<SettingsCubit>().setHomePluginId('');
                },
              ),
              ...resolvers.map((plugin) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SettingDivider(),
                    SettingRadioTile<String>(
                      title: plugin.name,
                      subtitle: plugin.manifest.id,
                      value: plugin.manifest.id,
                      groupValue: selectedPluginId,
                      onChanged: (_) {
                        context
                            .read<SettingsCubit>()
                            .setHomePluginId(plugin.manifest.id);
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  Widget _buildResolverPrioritySection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState state,
    List<PluginInfo> resolvers,
  ) {
    if (resolvers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingSectionHeader(label: l10n.pluginDefaultsPriorityHeader),
          SettingCard(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const SettingIconBox(icon: MingCute.sort_ascending_line),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.pluginDefaultsNoPriority,
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Build the ordered list: persisted priority first, then any new ones
    final storedPriority = state.resolverPriority;
    final loadedIds = resolvers.map((r) => r.manifest.id).toSet();
    final ordered = <String>[
      // Keep persisted order for plugins that are still loaded
      ...storedPriority.where(loadedIds.contains),
      // Append any loaded plugins not in the stored priority
      ...loadedIds.where((id) => !storedPriority.contains(id)),
    ];

    final nameMap = {
      for (final r in resolvers) r.manifest.id: r.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSectionHeader(label: l10n.pluginDefaultsPriorityHeader),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.pluginDefaultsPriorityDesc,
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ),
        _ResolverPriorityList(
          ordered: ordered,
          nameMap: nameMap,
          onReorder: (newOrder) {
            context.read<SettingsCubit>().setResolverPriority(newOrder);
          },
        ),
      ],
    );
  }

  Widget _buildLyricsPrioritySection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState state,
    List<PluginInfo> lyricsProviders,
  ) {
    if (lyricsProviders.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingSectionHeader(label: l10n.pluginDefaultsLyricsHeader),
          SettingCard(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const SettingIconBox(icon: MingCute.align_center_fill),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.pluginDefaultsLyricsNone,
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final storedPriority = state.lyricsPriority;
    final loadedIds = lyricsProviders.map((p) => p.manifest.id).toSet();
    final ordered = <String>[
      ...storedPriority.where(loadedIds.contains),
      ...loadedIds.where((id) => !storedPriority.contains(id)),
    ];

    final nameMap = {
      for (final p in lyricsProviders) p.manifest.id: p.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSectionHeader(label: l10n.pluginDefaultsLyricsHeader),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.pluginDefaultsLyricsDesc,
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ),
        _ResolverPriorityList(
          ordered: ordered,
          nameMap: nameMap,
          onReorder: (newOrder) {
            context.read<SettingsCubit>().setLyricsPriority(newOrder);
          },
        ),
      ],
    );
  }

  Widget _buildSuggestionPluginSection(
    BuildContext context,
    AppLocalizations l10n,
    SettingsState state,
    List<PluginInfo> suggestionProviders,
  ) {
    final selectedId = state.suggestionPluginId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSectionHeader(label: l10n.pluginDefaultsSuggestionsHeader),
        if (suggestionProviders.isEmpty)
          SettingCard(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const SettingIconBox(icon: MingCute.search_fill),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.pluginDefaultsSuggestionsNone,
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          SettingCard(
            children: [
              SettingRadioTile<String>(
                title: l10n.pluginDefaultsSuggestionsHistoryOnlyTitle,
                subtitle: l10n.pluginDefaultsSuggestionsHistoryOnlySubtitle,
                value: '',
                groupValue: selectedId,
                onChanged: (_) {
                  context.read<SettingsCubit>().setSuggestionPluginId('');
                },
              ),
              ...suggestionProviders.map((plugin) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SettingDivider(),
                    SettingRadioTile<String>(
                      title: plugin.name,
                      subtitle: plugin.manifest.id,
                      value: plugin.manifest.id,
                      groupValue: selectedId,
                      onChanged: (_) {
                        context
                            .read<SettingsCubit>()
                            .setSuggestionPluginId(plugin.manifest.id);
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }
}

class _ResolverPriorityList extends StatefulWidget {
  final List<String> ordered;
  final Map<String, String> nameMap;
  final ValueChanged<List<String>> onReorder;

  const _ResolverPriorityList({
    required this.ordered,
    required this.nameMap,
    required this.onReorder,
  });

  @override
  State<_ResolverPriorityList> createState() => _ResolverPriorityListState();
}

class _ResolverPriorityListState extends State<_ResolverPriorityList> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.ordered);
  }

  @override
  void didUpdateWidget(covariant _ResolverPriorityList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ordered != oldWidget.ordered) {
      _items = List.of(widget.ordered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Material(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  child: child,
                );
              },
              child: child,
            );
          },
          itemCount: _items.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
            widget.onReorder(List.of(_items));
          },
          itemBuilder: (context, index) {
            final pluginId = _items[index];
            final name = widget.nameMap[pluginId] ?? pluginId;
            return ReorderableDragStartListener(
              key: ValueKey(pluginId),
              index: index,
              child: _PriorityTile(
                rank: index + 1,
                name: name,
                pluginId: pluginId,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  final int rank;
  final String name;
  final String pluginId;

  const _PriorityTile({
    required this.rank,
    required this.name,
    required this.pluginId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Default_Theme.accentColor2.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Default_Theme.accentColor2,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                Text(
                  pluginId,
                  style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ],
            ),
          ),
          Icon(
            MingCute.menu_line,
            size: 20,
            color: Default_Theme.primaryColor2.withValues(alpha: 0.22),
          ),
        ],
      ),
    );
  }
}
