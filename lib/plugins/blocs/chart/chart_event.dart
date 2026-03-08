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

/// Force-refresh chart details, bypassing cache.
class ForceRefreshChartDetails extends ChartEvent {
  final String pluginId;
  final String chartId;
  const ForceRefreshChartDetails({
    required this.pluginId,
    required this.chartId,
  });
}

/// Silently prefetch chart details for a set of visible charts.
///
/// Runs in the background — no state emissions. Only fills the cache.
class PrefetchAllChartDetails extends ChartEvent {
  final String pluginId;
  final Set<String> chartIds;
  const PrefetchAllChartDetails({
    required this.pluginId,
    required this.chartIds,
  });
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
