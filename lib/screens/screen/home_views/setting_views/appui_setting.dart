import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/repository/lastfm/lastfmapi.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'UI & Services Settings',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                value: state.autoSlideCharts,
                subtitle: Text(
                  "Slide charts automatically in home screen.",
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                title: Text(
                  "Auto slide charts",
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 16,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                onChanged: (value) {
                  context.read<SettingsCubit>().setAutoSlideCharts(value);
                },
              ),
              SwitchListTile(
                value: state.lFMPicks,
                subtitle: Text(
                  "Suggestions from Last.FM will be shown in the home screen. (Login & Restart required)",
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                title: Text(
                  "Last.FM Suggested Picks",
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 16,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                onChanged: (value) {
                  context.read<SettingsCubit>().setLastFMExpore(value);
                  if (value && LastFmAPI.initialized == false) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      context.read<SettingsCubit>().setLastFMExpore(false);
                    });
                    SnackbarService.showMessage(
                        "Please login to Last.FM first.");
                  }
                },
              ),
              // Dynamic chart visibility toggles from plugin
              BlocBuilder<ChartBloc, ChartState>(
                bloc: _chartBloc,
                builder: (context, chartState) {
                  if (chartState.charts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ExpansionTile(
                    title: Text(
                      "Allowed Chart Sources",
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 16,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    subtitle: Text(
                      "Manage which charts are shown in the home screen.",
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        fontSize: 12,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    collapsedIconColor: Default_Theme.primaryColor1,
                    children: chartState.charts.map((chart) {
                      return SwitchListTile(
                        value: state.chartMap[chart.title] ?? true,
                        title: Text(
                          chart.title,
                          style: const TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontSize: 17,
                          ).merge(Default_Theme.secondoryTextStyleMedium),
                        ),
                        onChanged: (b) {
                          context
                              .read<SettingsCubit>()
                              .setChartShow(chart.title, b);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
