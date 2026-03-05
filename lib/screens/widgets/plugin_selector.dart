import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Horizontal scrolling chip bar for selecting the active plugin.
///
/// Displays loaded plugins of a given [pluginType] as selectable chips.
/// The currently active plugin is highlighted with [Default_Theme.accentColor2].
///
/// Usage:
/// ```dart
/// PluginSelectorBar(
///   pluginType: PluginType.contentResolver,
///   activePluginId: _activeId,
///   onPluginSelected: (info) => setState(() => _activeId = info.manifest.id),
/// )
/// ```
class PluginSelectorBar extends StatelessWidget {
  /// Which plugin type to show (contentResolver or chartProvider).
  final PluginType pluginType;

  /// Currently selected plugin ID (highlighted).
  final String? activePluginId;

  /// Called when user taps a plugin chip.
  final ValueChanged<PluginInfo> onPluginSelected;

  /// Whether to show an "All" chip at the start.
  final bool showAllOption;

  /// Called when user taps the "All" chip.
  final VoidCallback? onAllSelected;

  const PluginSelectorBar({
    super.key,
    required this.pluginType,
    required this.activePluginId,
    required this.onPluginSelected,
    this.showAllOption = false,
    this.onAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PluginBloc, PluginState>(
      buildWhen: (prev, curr) =>
          prev.loadedPluginIds != curr.loadedPluginIds ||
          prev.availablePlugins != curr.availablePlugins,
      builder: (context, state) {
        final plugins = pluginType == PluginType.contentResolver
            ? state.loadedContentResolvers
            : state.loadedChartProviders;

        if (plugins.isEmpty && !showAllOption) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: plugins.length + (showAllOption ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (showAllOption && index == 0) {
                final isActive = activePluginId == null;
                return _PluginChip(
                  label: 'All',
                  isActive: isActive,
                  onTap: onAllSelected ?? () {},
                );
              }

              final plugin = plugins[index - (showAllOption ? 1 : 0)];
              final id = plugin.manifest.id;
              final isActive = id == activePluginId;

              return _PluginChip(
                label: plugin.manifest.name,
                isActive: isActive,
                onTap: () => onPluginSelected(plugin),
              );
            },
          ),
        );
      },
    );
  }
}

class _PluginChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PluginChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive
              ? Default_Theme.accentColor2.withValues(alpha: 0.22)
              : Colors.transparent,
          side: BorderSide(
            color: isActive
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.2),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
    );
  }
}
