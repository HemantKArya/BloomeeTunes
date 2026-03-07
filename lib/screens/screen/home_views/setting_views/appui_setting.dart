import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/repository/lastfm/lastfmapi.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
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
              const SettingSectionHeader(label: 'Home Screen'),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: MingCute.play_circle_line,
                    title: 'Auto Slide Charts',
                    subtitle: 'Slide charts automatically in home screen.',
                    value: state.autoSlideCharts,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setAutoSlideCharts(v),
                  ),
                  const SettingDivider(),
                  SettingToggleTile(
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
              const SettingSectionHeader(label: 'Discover Source'),
              BlocBuilder<PluginBloc, PluginState>(
                builder: (context, pluginState) {
                  final resolvers = pluginState.loadedContentResolvers;
                  final hasStoredSelection = state.homePluginId.isNotEmpty &&
                      resolvers.any(
                          (plugin) => plugin.manifest.id == state.homePluginId);
                  final selectedPluginId =
                      hasStoredSelection ? state.homePluginId : '';

                  if (resolvers.isEmpty) {
                    return SettingCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const SettingIconBox(
                                  icon: MingCute.plugin_2_line),
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

                  return SettingCard(
                    children: [
                      SettingRadioTile<String>(
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
                  );
                },
              ),
              const SizedBox(height: 28),
              const SettingSectionHeader(label: 'Chart Visibility'),
              BlocBuilder<ChartBloc, ChartState>(
                bloc: _chartBloc,
                builder: (context, chartState) {
                  if (chartState.charts.isEmpty) {
                    return SettingCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              const SettingIconBox(
                                  icon: MingCute.chart_bar_line),
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

                  return SettingCard(
                    children: [
                      for (var i = 0; i < chartState.charts.length; i++) ...[
                        if (i > 0) const SettingDivider(),
                        SettingToggleTile(
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
