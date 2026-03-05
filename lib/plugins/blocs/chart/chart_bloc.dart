import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

/// Manages chart data: listing available charts and loading chart details.
///
/// Works with chart provider plugins via [PluginService].
/// Uses Rust-generated types directly — no converter layer.
class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final PluginService _pluginService;

  ChartBloc({
    required PluginService pluginService,
    String? initialPluginId,
  })  : _pluginService = pluginService,
        super(ChartState(activePluginId: initialPluginId)) {
    on<LoadCharts>(_onLoadCharts);
    on<LoadChartDetails>(_onLoadChartDetails);
    on<SetActiveChartPlugin>(_onSetActivePlugin);
    on<ClearCharts>(_onClearCharts);
  }

  // ── Load Charts ────────────────────────────────────────────────────────────

  Future<void> _onLoadCharts(
    LoadCharts event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(
      chartsStatus: ChartStatus.loading,
      activePluginId: event.pluginId,
      clearError: true,
    ));

    try {
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: const PluginRequest.chartProvider(
          ChartProviderCommand.getCharts(),
        ),
      );

      response.when(
        charts: (charts) {
          emit(state.copyWith(
            chartsStatus: ChartStatus.loaded,
            charts: charts,
          ));
        },
        // All other response types are unexpected.
        search: (_) => _unexpectedResponse(emit, 'loadCharts'),
        albumDetails: (_) => _unexpectedResponse(emit, 'loadCharts'),
        artistDetails: (_) => _unexpectedResponse(emit, 'loadCharts'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'loadCharts'),
        streams: (_) => _unexpectedResponse(emit, 'loadCharts'),
        moreTracks: (_) => _unexpectedResponse(emit, 'loadCharts'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'loadCharts'),
        homeSections: (_) => _unexpectedResponse(emit, 'loadCharts'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'loadCharts'),
        chartDetails: (_) => _unexpectedResponse(emit, 'loadCharts'),
        ack: () => _unexpectedResponse(emit, 'loadCharts'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e);
    } catch (e, stack) {
      log('LoadCharts error', error: e, stackTrace: stack, name: 'ChartBloc');
      emit(state.copyWith(
        chartsStatus: ChartStatus.error,
        error: 'Failed to load charts: $e',
      ));
    }
  }

  // ── Load Chart Details ─────────────────────────────────────────────────────

  Future<void> _onLoadChartDetails(
    LoadChartDetails event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(
      chartDetailStatus: ChartStatus.loading,
      activeChartId: event.chartId,
      clearError: true,
    ));

    try {
      final localId = localIdOf(event.chartId) ?? event.chartId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.chartProvider(
          ChartProviderCommand.getChartDetails(id: localId),
        ),
      );

      response.when(
        chartDetails: (items) {
          emit(state.copyWith(
            chartDetailStatus: ChartStatus.loaded,
            chartItems: items,
          ));
        },
        search: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        albumDetails: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        artistDetails: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        playlistDetails: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        streams: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        moreTracks: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        moreAlbums: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        homeSections: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        loadMoreItems: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        charts: (_) => _unexpectedResponse(emit, 'loadChartDetails'),
        ack: () => _unexpectedResponse(emit, 'loadChartDetails'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, chartDetail: true);
    } catch (e, stack) {
      log('LoadChartDetails error',
          error: e, stackTrace: stack, name: 'ChartBloc');
      emit(state.copyWith(
        chartDetailStatus: ChartStatus.error,
        error: 'Failed to load chart details: $e',
      ));
    }
  }

  // ── Set Active Plugin ──────────────────────────────────────────────────────

  void _onSetActivePlugin(
    SetActiveChartPlugin event,
    Emitter<ChartState> emit,
  ) {
    emit(ChartState(activePluginId: event.pluginId));
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  void _onClearCharts(ClearCharts event, Emitter<ChartState> emit) {
    emit(const ChartState.initial());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _unexpectedResponse(Emitter<ChartState> emit, String context) {
    log('Unexpected response type for $context', name: 'ChartBloc');
    // Transition any currently-loading status to error so the UI
    // never gets stuck in a permanent loading state.
    emit(state.copyWith(
      error: 'Unexpected response from plugin',
      chartsStatus:
          state.chartsStatus == ChartStatus.loading ? ChartStatus.error : null,
      chartDetailStatus: state.chartDetailStatus == ChartStatus.loading
          ? ChartStatus.error
          : null,
    ));
  }

  void _handlePluginError(
    Emitter<ChartState> emit,
    PluginException e, {
    bool chartDetail = false,
  }) {
    if (e is PluginNotLoadedException) {
      GlobalEventBus.instance.emitError(
        AppError.pluginNotLoaded(pluginId: e.pluginId ?? 'unknown'),
      );
    } else if (e is PluginNotFoundException) {
      GlobalEventBus.instance.emitError(
        AppError.pluginError(
          pluginId: e.pluginId ?? 'unknown',
          message: 'Chart plugin not found: ${e.pluginId}',
        ),
      );
    }

    emit(state.copyWith(
      chartsStatus: chartDetail ? null : ChartStatus.error,
      chartDetailStatus: chartDetail ? ChartStatus.error : null,
      error: e.message,
    ));
  }
}
