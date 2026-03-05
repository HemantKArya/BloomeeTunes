/// Events for [ChartBloc].
sealed class ChartEvent {
  const ChartEvent();
}

/// Load chart listings from a chart provider plugin.
class LoadCharts extends ChartEvent {
  final String pluginId;
  const LoadCharts({required this.pluginId});
}

/// Load details (items) for a specific chart.
class LoadChartDetails extends ChartEvent {
  final String pluginId;
  final String chartId;
  const LoadChartDetails({required this.pluginId, required this.chartId});
}

/// Set the active chart provider plugin.
class SetActiveChartPlugin extends ChartEvent {
  final String pluginId;
  const SetActiveChartPlugin({required this.pluginId});
}

/// Clear chart state.
class ClearCharts extends ChartEvent {
  const ClearCharts();
}
