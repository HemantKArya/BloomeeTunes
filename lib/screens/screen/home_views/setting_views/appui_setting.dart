import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/repository/lastfm/lastfmapi.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/custom_switch.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class AppUISettings extends StatefulWidget {
  const AppUISettings({super.key});

  @override
  State<AppUISettings> createState() => _AppUISettingsState();
}

class _AppUISettingsState extends State<AppUISettings> {
  late final ChartBloc _chartBloc;

  @override
  void initState() {
    super.initState();
    _chartBloc = ChartBloc(pluginService: ServiceLocator.pluginService);
    _loadCharts();
  }

  void _loadCharts() {
    final chartProviders =
        context.read<PluginBloc>().state.loadedChartProviders;
    if (chartProviders.isNotEmpty) {
      _chartBloc.add(LoadCharts(pluginId: chartProviders.first.manifest.id));
    }
  }

  @override
  void dispose() {
    _chartBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'UI & Services',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // ─── Home Screen ─────────────────────────────────────────
              const _SectionHeader(label: 'Home Screen'),
              _SettingCard(
                children: [
                  _ToggleTile(
                    icon: MingCute.play_circle_line,
                    title: 'Auto Slide Charts',
                    subtitle: 'Slide charts automatically in home screen.',
                    value: state.autoSlideCharts,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setAutoSlideCharts(v),
                  ),
                  const _Divider(),
                  _ToggleTile(
                    icon: MingCute.music_2_line,
                    title: 'Last.FM Picks',
                    subtitle:
                        'Show suggestions from Last.FM. Login & restart required.',
                    value: state.lFMPicks,
                    onChanged: (v) {
                      context.read<SettingsCubit>().setLastFMExpore(v);
                      if (v && LastFmAPI.initialized == false) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          context.read<SettingsCubit>().setLastFMExpore(false);
                        });
                        SnackbarService.showMessage(
                            "Please login to Last.FM first.");
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── Discover Source ───────────────────────────────────────
              const _SectionHeader(label: 'Discover Source'),
              BlocBuilder<PluginBloc, PluginState>(
                builder: (context, pluginState) {
                  final resolvers = pluginState.loadedContentResolvers;
                  final hasStoredSelection = state.homePluginId.isNotEmpty &&
                      resolvers.any(
                          (plugin) => plugin.manifest.id == state.homePluginId);
                  final selectedPluginId =
                      hasStoredSelection ? state.homePluginId : '';

                  if (resolvers.isEmpty) {
                    return _SettingCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const _SettingIcon(icon: MingCute.plugin_2_line),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'No content resolver loaded. Load a plugin to choose a Discover source.',
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
                    );
                  }

                  return _SettingCard(
                    children: [
                      _RadioTile(
                        title: 'Automatic',
                        subtitle: 'Use the first available content resolver.',
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
                            const _Divider(),
                            _RadioTile(
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
                  );
                },
              ),

              const SizedBox(height: 28),

              // ─── Chart Visibility ──────────────────────────────────────
              const _SectionHeader(label: 'Chart Visibility'),
              BlocBuilder<ChartBloc, ChartState>(
                bloc: _chartBloc,
                builder: (context, chartState) {
                  if (chartState.charts.isEmpty) {
                    return _SettingCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const _SettingIcon(icon: MingCute.chart_bar_line),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'No charts available. Load a chart provider plugin.',
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
                    );
                  }

                  return _SettingCard(
                    children: [
                      for (var i = 0; i < chartState.charts.length; i++) ...[
                        if (i > 0) const _Divider(),
                        _ToggleTile(
                          icon: MingCute.chart_bar_line,
                          title: chartState.charts[i].title,
                          subtitle: 'Show in home carousel.',
                          value: state.chartMap[chartState.charts[i].title] ??
                              true,
                          onChanged: (v) {
                            context
                                .read<SettingsCubit>()
                                .setChartShow(chartState.charts[i].title, v);
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// ─── Shared Setting Widgets ──────────────────────────────────────────────────
// Mirrors the design language from player_setting.dart.

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
      );
}

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  const _SettingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BloomeeSwitch(
            value: value,
            onChanged: () => onChanged(!value),
          ),
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(20),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor2.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Default_Theme.accentColor2,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor2
                                .withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
