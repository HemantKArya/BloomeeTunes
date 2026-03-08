import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/errors/plugin_exceptions.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/services/cache/plugin_cache_repository.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/plugin_cache_codec.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';

/// Manages chart data: listing available charts and loading chart details.
///
/// Works with chart provider plugins via [PluginService].
/// Uses Rust-generated types directly — no converter layer.
class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final PluginService _pluginService;
  final PluginCacheRepository _cache = ServiceLocator.pluginCache;

  ChartBloc({
    required PluginService pluginService,
    String? initialPluginId,
  })  : _pluginService = pluginService,
        super(ChartState(activePluginId: initialPluginId)) {
    on<LoadCharts>(_onLoadCharts);
    on<LoadChartDetails>(_onLoadChartDetails);
    on<ForceRefreshChartDetails>(_onForceRefreshChartDetails);
    on<PrefetchAllChartDetails>(_onPrefetchAllChartDetails);
    on<SetActiveChartPlugin>(_onSetActivePlugin);
    on<ClearCharts>(_onClearCharts);
  }

  // ── Load Charts (stale-while-revalidate) ──────────────────────────────────

  Future<void> _onLoadCharts(
    LoadCharts event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(
      chartsStatus: ChartStatus.loading,
      activePluginId: event.pluginId,
      clearError: true,
    ));

    final cacheKey = 'chart_list::${event.pluginId}';
    final cached = await _cache.getCachedWithStaleness<List<ChartSummary>>(
      key: cacheKey,
      type: CacheType.chartList,
      decode: decodeChartListCacheAsync,
      stalenessThreshold: const Duration(hours: 8),
    );

    final hasCache = cached.value != null;
    if (hasCache) {
      emit(state.copyWith(
        chartsStatus: ChartStatus.loaded,
        charts: cached.value!,
      ));
      if (!cached.isStale) return;
      // Stale — continue to background network refresh (no re-emit of loading).
    }

    try {
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: const PluginRequest.chartProvider(
          ChartProviderCommand.getCharts(),
        ),
      );

      void unexpectedFn() {
        if (!hasCache) _unexpectedResponse(emit, 'loadCharts');
      }

      response.when(
        charts: (charts) {
          emit(state.copyWith(
            chartsStatus: ChartStatus.loaded,
            charts: charts,
          ));
          _cache.put(
            key: cacheKey,
            value: charts,
            type: CacheType.chartList,
            blob: encodeChartListCache(charts),
          );
        },
        search: (_) => unexpectedFn(),
        albumDetails: (_) => unexpectedFn(),
        artistDetails: (_) => unexpectedFn(),
        playlistDetails: (_) => unexpectedFn(),
        streams: (_) => unexpectedFn(),
        moreTracks: (_) => unexpectedFn(),
        moreAlbums: (_) => unexpectedFn(),
        homeSections: (_) => unexpectedFn(),
        loadMoreItems: (_) => unexpectedFn(),
        chartDetails: (_) => unexpectedFn(),
        ack: () => unexpectedFn(),
      );
    } on PluginException catch (e) {
      if (!hasCache) {
        _handlePluginError(emit, e);
      } else {
        log('Background chart refresh failed: $e', name: 'ChartBloc');
      }
    } catch (e, stack) {
      log('LoadCharts error', error: e, stackTrace: stack, name: 'ChartBloc');
      if (!hasCache) {
        emit(state.copyWith(
          chartsStatus: ChartStatus.error,
          error: 'Failed to load charts: $e',
        ));
      }
    }
  }

  // ── Load Chart Details (stale-while-revalidate) ────────────────────────────

  Future<void> _onLoadChartDetails(
    LoadChartDetails event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(
      chartDetailStatus: ChartStatus.loading,
      activeChartId: event.chartId,
      clearError: true,
    ));

    final cacheKey = 'chart_cache::${event.pluginId}::${event.chartId}';
    final cached = await _cache.getCachedWithStaleness<List<ChartItem>>(
      key: cacheKey,
      type: CacheType.chart,
      decode: decodeChartItemsCacheAsync,
      stalenessThreshold: const Duration(hours: 8),
    );

    final hasCache = cached.value != null;
    if (hasCache) {
      emit(state.copyWith(
        chartDetailStatus: ChartStatus.loaded,
        chartItems: cached.value!,
      ));
      if (!cached.isStale) return;
      // Stale — continue to background network refresh.
    }

    try {
      final localId = localIdOf(event.chartId) ?? event.chartId;
      final response = await _pluginService.execute(
        pluginId: event.pluginId,
        request: PluginRequest.chartProvider(
          ChartProviderCommand.getChartDetails(id: localId),
        ),
      );

      void unexpectedFn() {
        if (!hasCache) _unexpectedResponse(emit, 'loadChartDetails');
      }

      response.when(
        chartDetails: (items) {
          emit(state.copyWith(
            chartDetailStatus: ChartStatus.loaded,
            chartItems: items,
          ));
          _cache.put(
            key: cacheKey,
            value: items,
            type: CacheType.chart,
            blob: encodeChartItemsCache(items),
          );
        },
        search: (_) => unexpectedFn(),
        albumDetails: (_) => unexpectedFn(),
        artistDetails: (_) => unexpectedFn(),
        playlistDetails: (_) => unexpectedFn(),
        streams: (_) => unexpectedFn(),
        moreTracks: (_) => unexpectedFn(),
        moreAlbums: (_) => unexpectedFn(),
        homeSections: (_) => unexpectedFn(),
        loadMoreItems: (_) => unexpectedFn(),
        charts: (_) => unexpectedFn(),
        ack: () => unexpectedFn(),
      );
    } on PluginException catch (e) {
      if (!hasCache) {
        _handlePluginError(emit, e, chartDetail: true);
      } else {
        log('Background chart detail refresh failed: $e', name: 'ChartBloc');
      }
    } catch (e, stack) {
      log('LoadChartDetails error',
          error: e, stackTrace: stack, name: 'ChartBloc');
      if (!hasCache) {
        emit(state.copyWith(
          chartDetailStatus: ChartStatus.error,
          error: 'Failed to load chart details: $e',
        ));
      }
    }
  }

  // ── Force-Refresh Chart Details ────────────────────────────────────────────

  Future<void> _onForceRefreshChartDetails(
    ForceRefreshChartDetails event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(
      chartDetailStatus: ChartStatus.loading,
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
          _cache.put(
            key: 'chart_cache::${event.pluginId}::${event.chartId}',
            value: items,
            type: CacheType.chart,
            blob: encodeChartItemsCache(items),
          );
        },
        search: (_) => _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        albumDetails: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        artistDetails: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        playlistDetails: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        streams: (_) => _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        moreTracks: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        moreAlbums: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        homeSections: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        loadMoreItems: (_) =>
            _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        charts: (_) => _unexpectedResponse(emit, 'forceRefreshChartDetails'),
        ack: () => _unexpectedResponse(emit, 'forceRefreshChartDetails'),
      );
    } on PluginException catch (e) {
      _handlePluginError(emit, e, chartDetail: true);
    } catch (e, stack) {
      log('ForceRefreshChartDetails error',
          error: e, stackTrace: stack, name: 'ChartBloc');
      emit(state.copyWith(
        chartDetailStatus: ChartStatus.error,
        error: 'Failed to refresh chart: $e',
      ));
    }
  }

  // ── Prefetch All Chart Details (silent background) ─────────────────────────

  Future<void> _onPrefetchAllChartDetails(
    PrefetchAllChartDetails event,
    Emitter<ChartState> emit,
  ) async {
    // No state emissions — purely a cache-warming operation.
    for (final chartId in event.chartIds) {
      if (isClosed) break;

      final cacheKey = 'chart_cache::${event.pluginId}::$chartId';
      try {
        final cached = await _cache.getCachedWithStaleness<List<ChartItem>>(
          key: cacheKey,
          type: CacheType.chart,
          decode: decodeChartItemsCacheAsync,
          stalenessThreshold: const Duration(hours: 8),
        );

        // Skip charts that are already fresh in cache.
        if (cached.value != null && !cached.isStale) continue;

        if (isClosed) break;

        final localId = localIdOf(chartId) ?? chartId;
        final response = await _pluginService.execute(
          pluginId: event.pluginId,
          request: PluginRequest.chartProvider(
            ChartProviderCommand.getChartDetails(id: localId),
          ),
        );

        response.when(
          chartDetails: (items) {
            _cache.put(
              key: cacheKey,
              value: items,
              type: CacheType.chart,
              blob: encodeChartItemsCache(items),
            );
          },
          search: (_) {},
          albumDetails: (_) {},
          artistDetails: (_) {},
          playlistDetails: (_) {},
          streams: (_) {},
          moreTracks: (_) {},
          moreAlbums: (_) {},
          homeSections: (_) {},
          loadMoreItems: (_) {},
          charts: (_) {},
          ack: () {},
        );
      } catch (e) {
        log('Prefetch failed for chart $chartId: $e', name: 'ChartBloc');
        // Continue with next chart on failure.
      }
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
