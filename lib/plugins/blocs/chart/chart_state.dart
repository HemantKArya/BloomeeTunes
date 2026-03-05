import 'package:equatable/equatable.dart';
import 'package:Bloomee/core/models/exported.dart';

/// State for [ChartBloc].
///
/// Uses Rust-generated types directly.
class ChartState extends Equatable {
  /// Active chart provider plugin ID.
  final String? activePluginId;

  /// Status of chart listing load.
  final ChartStatus chartsStatus;

  /// Available charts from the active provider.
  final List<ChartSummary> charts;

  /// Status of chart detail (items) load.
  final ChartStatus chartDetailStatus;

  /// The currently loaded chart's ID.
  final String? activeChartId;

  /// Items in the currently loaded chart.
  final List<ChartItem> chartItems;

  /// Error message, if any.
  final String? error;

  const ChartState({
    this.activePluginId,
    this.chartsStatus = ChartStatus.initial,
    this.charts = const [],
    this.chartDetailStatus = ChartStatus.initial,
    this.activeChartId,
    this.chartItems = const [],
    this.error,
  });

  const ChartState.initial()
      : activePluginId = null,
        chartsStatus = ChartStatus.initial,
        charts = const [],
        chartDetailStatus = ChartStatus.initial,
        activeChartId = null,
        chartItems = const [],
        error = null;

  ChartState copyWith({
    String? activePluginId,
    ChartStatus? chartsStatus,
    List<ChartSummary>? charts,
    ChartStatus? chartDetailStatus,
    String? activeChartId,
    List<ChartItem>? chartItems,
    String? error,
    bool clearError = false,
    bool clearChartItems = false,
    bool clearActiveChart = false,
  }) {
    return ChartState(
      activePluginId: activePluginId ?? this.activePluginId,
      chartsStatus: chartsStatus ?? this.chartsStatus,
      charts: charts ?? this.charts,
      chartDetailStatus: chartDetailStatus ?? this.chartDetailStatus,
      activeChartId:
          clearActiveChart ? null : (activeChartId ?? this.activeChartId),
      chartItems: clearChartItems ? const [] : (chartItems ?? this.chartItems),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        activePluginId,
        chartsStatus,
        charts,
        chartDetailStatus,
        activeChartId,
        chartItems,
        error,
      ];
}

enum ChartStatus { initial, loading, loaded, error }
