import 'dart:async';
import 'dart:ui';

import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/constants/route_paths.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/meta_resolver/chart_item_resolver.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

/// Displays the details (items) of a specific chart.
///
/// Takes [pluginId] and [chartId] from the route, creates its own
/// [ChartBloc], and dispatches [LoadChartDetails].
class ChartScreen extends StatelessWidget {
  final String pluginId;
  final String chartId;
  final String chartTitle;

  const ChartScreen({
    super.key,
    required this.pluginId,
    required this.chartId,
    required this.chartTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartBloc(pluginService: ServiceLocator.pluginService)
        ..add(LoadChartDetails(pluginId: pluginId, chartId: chartId)),
      child: _ChartScreenBody(
        chartTitle: chartTitle,
        pluginId: pluginId,
        chartId: chartId,
      ),
    );
  }
}

enum ChartResolveActionStatus { idle, resolving, success }

String chartItemActionIdentity(ChartItem chartItem) {
  final itemKey = chartItem.item.when(
    track: (track) => 'track:${track.id}',
    album: (album) => 'album:${album.id}',
    artist: (artist) => 'artist:${artist.id}',
    playlist: (playlist) => 'playlist:${playlist.id}',
  );
  return '$itemKey:${chartItem.rank}';
}

class _ChartScreenBody extends StatefulWidget {
  final String chartTitle;
  final String pluginId;
  final String chartId;

  const _ChartScreenBody({
    required this.chartTitle,
    required this.pluginId,
    required this.chartId,
  });

  @override
  State<_ChartScreenBody> createState() => _ChartScreenBodyState();
}

class _ChartScreenBodyState extends State<_ChartScreenBody> {
  final ChartItemResolver _resolver =
      ChartItemResolver(pluginService: ServiceLocator.pluginService);
  static const double _kResolverConfidenceThreshold = 65.0;
  final Map<String, ChartResolveActionStatus> _actionStatuses = {};
  final Map<String, int> _actionTokens = {};

  ChartResolveActionStatus _statusFor(String actionKey) {
    return _actionStatuses[actionKey] ?? ChartResolveActionStatus.idle;
  }

  String _playActionKey(ChartItem chartItem) {
    return '${chartItemActionIdentity(chartItem)}:play';
  }

  String _addActionKey(ChartItem chartItem) {
    return '${chartItemActionIdentity(chartItem)}:add';
  }

  int? _beginResolveAction(String actionKey) {
    if (_statusFor(actionKey) == ChartResolveActionStatus.resolving) {
      return null;
    }

    final nextToken = (_actionTokens[actionKey] ?? 0) + 1;
    setState(() {
      _actionTokens[actionKey] = nextToken;
      _actionStatuses[actionKey] = ChartResolveActionStatus.resolving;
    });
    return nextToken;
  }

  void _resetResolveAction(String actionKey, int token) {
    if (!mounted || _actionTokens[actionKey] != token) {
      return;
    }

    setState(() {
      _actionStatuses.remove(actionKey);
    });
  }

  Future<void> _completeResolveAction(
    String actionKey,
    int token, {
    Duration hold = const Duration(milliseconds: 1400),
  }) async {
    if (!mounted || _actionTokens[actionKey] != token) {
      return;
    }

    setState(() {
      _actionStatuses[actionKey] = ChartResolveActionStatus.success;
    });

    await Future.delayed(hold);
    if (!mounted || _actionTokens[actionKey] != token) {
      return;
    }

    setState(() {
      _actionStatuses.remove(actionKey);
    });
  }

  /// Resolves a chart item. Returns the resolved track, or null on failure.
  Future<Track?> _resolveChartItem(
    BuildContext context,
    ChartItem chartItem, {
    required String noResolverMessage,
    required String failureMessage,
    bool fallbackOnNoResolver = false,
    bool fallbackOnFailure = true,
  }) async {
    final pluginState = context.read<PluginBloc>().state;
    final priority = context.read<SettingsCubit>().state.resolverPriority;
    final allIds =
        pluginState.loadedContentResolvers.map((p) => p.manifest.id).toList();
    // Priority-listed IDs come first (in user-defined order);
    // any loaded resolver not in the list is appended at the end.
    final resolverIds = [
      ...priority.where(allIds.contains),
      ...allIds.where((id) => !priority.contains(id)),
    ];

    if (resolverIds.isEmpty) {
      SnackbarService.showMessage(noResolverMessage);
      if (fallbackOnNoResolver) {
        _fallbackSearch(context, chartItem);
      }
      return null;
    }

    final result = await _resolver.resolve(
      chartItem: chartItem,
      resolverPluginIds: resolverIds,
    );

    if (!context.mounted) return null;

    if (result == null) {
      SnackbarService.showMessage(failureMessage);
      if (fallbackOnFailure) {
        _fallbackSearch(context, chartItem);
      }
      return null;
    }

    final passByScore = result.confidence >= _kResolverConfidenceThreshold;
    final passByStrongTrackMatch = _resolver.isStrongTrackMatch(
      chartItem: chartItem,
      resolvedTrack: result.resolvedTrack,
    );

    if (!passByScore && !passByStrongTrackMatch) {
      SnackbarService.showMessage(failureMessage);
      if (fallbackOnFailure) {
        _fallbackSearch(context, chartItem);
      }
      return null;
    }

    return result.resolvedTrack;
  }

  /// Resolves a chart item, plays if successful, else falls back to search.
  Future<void> _resolveAndPlay(
      BuildContext context, ChartItem chartItem, String actionKey) async {
    final token = _beginResolveAction(actionKey);
    if (token == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final track = await _resolveChartItem(
      context,
      chartItem,
      noResolverMessage: l10n.chartNoResolver,
      failureMessage: l10n.chartResolveFailed,
      fallbackOnNoResolver: true,
    );
    if (track == null || !context.mounted) {
      _resetResolveAction(actionKey, token);
      return;
    }

    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
          Playlist(tracks: [track], title: widget.chartTitle),
          doPlay: true,
        );

    await _completeResolveAction(actionKey, token);
  }

  /// Resolves and shows add-to-playlist if confident.
  Future<void> _resolveAndAdd(
      BuildContext context, ChartItem chartItem, String actionKey) async {
    final token = _beginResolveAction(actionKey);
    if (token == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final track = await _resolveChartItem(
      context,
      chartItem,
      noResolverMessage: l10n.chartNoResolverAdd,
      failureMessage: l10n.chartNoMatch,
    );
    if (track == null || !context.mounted) {
      _resetResolveAction(actionKey, token);
      return;
    }

    setState(() {
      _actionStatuses[actionKey] = ChartResolveActionStatus.success;
    });
    await Future.delayed(const Duration(milliseconds: 350));
    if (!context.mounted || _actionTokens[actionKey] != token) {
      return;
    }

    context.read<AddToPlaylistCubit>().setTrack(track);
    context.pushNamed(RoutePaths.addToPlaylistScreen);

    unawaited(_completeResolveAction(
      actionKey,
      token,
      hold: const Duration(milliseconds: 1200),
    ));
  }

  void _fallbackSearch(BuildContext context, ChartItem chartItem) {
    final query = _resolver.fallbackQuery(chartItem);
    context.push('/${RoutePaths.searchScreen}?query=$query');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PluginBloc, PluginState>(
      listenWhen: (prev, curr) =>
          prev.loadedPluginIds.contains(widget.pluginId) &&
          !curr.loadedPluginIds.contains(widget.pluginId),
      listener: (context, state) {
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Default_Theme.themeColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Default_Theme.primaryColor1,
                    size: 20,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          actions: [
            BlocBuilder<ChartBloc, ChartState>(
              builder: (context, chartState) {
                final isLoading =
                    chartState.chartDetailStatus == ChartStatus.loading;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<ChartBloc>().add(
                                ForceRefreshChartDetails(
                                  pluginId: widget.pluginId,
                                  chartId: widget.chartId,
                                ),
                              ),
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Default_Theme.themeColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Default_Theme.primaryColor1,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Default_Theme.primaryColor1,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ChartBloc, ChartState>(
          builder: (context, state) {
            if (state.chartDetailStatus == ChartStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2),
              );
            }

            if (state.chartDetailStatus == ChartStatus.error) {
              return Center(
                child: SignBoardWidget(
                  message: state.error ??
                      AppLocalizations.of(context)!.chartLoadFailed,
                  icon: MingCute.warning_line,
                ),
              );
            }

            if (state.chartItems.isEmpty) {
              return Center(
                child: SignBoardWidget(
                  message: AppLocalizations.of(context)!.chartNoItems,
                  icon: MingCute.playlist_line,
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _EditorialHeroMasthead(
                    topItem: state.chartItems.first,
                    chartTitle: widget.chartTitle,
                    playStatus:
                        _statusFor(_playActionKey(state.chartItems.first)),
                    addStatus:
                        _statusFor(_addActionKey(state.chartItems.first)),
                    onPlayTap: () => _resolveAndPlay(
                      context,
                      state.chartItems.first,
                      _playActionKey(state.chartItems.first),
                    ),
                    onAddTap: () => _resolveAndAdd(
                      context,
                      state.chartItems.first,
                      _addActionKey(state.chartItems.first),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ChartControlBarDelegate(
                    chartTitle: widget.chartTitle,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Skip rank 1 item since it's in the hero
                        final chartItem = state.chartItems[index + 1];
                        final playActionKey = _playActionKey(chartItem);
                        final addActionKey = _addActionKey(chartItem);
                        return ChartListTile(
                          chartItem: chartItem,
                          playStatus: _statusFor(playActionKey),
                          addStatus: _statusFor(addActionKey),
                          onTap: _statusFor(playActionKey) ==
                                  ChartResolveActionStatus.resolving
                              ? null
                              : () => _resolveAndPlay(
                                  context, chartItem, playActionKey),
                          onAddTap: _statusFor(addActionKey) ==
                                  ChartResolveActionStatus.resolving
                              ? null
                              : () => _resolveAndAdd(
                                  context, chartItem, addActionKey),
                        );
                      },
                      childCount: state.chartItems.length - 1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Editorial Hero Masthead ──────────────────────────────────────────────────

class _EditorialHeroMasthead extends StatelessWidget {
  final ChartItem topItem;
  final String chartTitle;
  final ChartResolveActionStatus playStatus;
  final ChartResolveActionStatus addStatus;
  final VoidCallback onPlayTap;
  final VoidCallback onAddTap;

  const _EditorialHeroMasthead({
    required this.topItem,
    required this.chartTitle,
    required this.playStatus,
    required this.addStatus,
    required this.onPlayTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      final (title, subtitle, imgUrl) = extractItemInfo(topItem);

      return SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Background image
            if (imgUrl.isNotEmpty)
              Positioned.fill(
                child: LoadImageCached(
                  imageUrl: imgUrl,
                  fallbackUrl: imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            // Heavy blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
            // Gradient fade to theme color
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Default_Theme.themeColor.withValues(alpha: 0.05),
                      Default_Theme.themeColor.withValues(alpha: 0.85),
                      Default_Theme.themeColor,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            // Watermark rank number — bold, visible
            Positioned(
              right: isMobile ? -10 : 30,
              bottom: isMobile ? 0 : -30,
              child: Text(
                '1',
                style: TextStyle(
                  fontFamily: 'Unageo',
                  fontSize: isMobile ? 260 : 420,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20.0 : 48.0,
                isMobile ? 80.0 : 100.0,
                isMobile ? 20.0 : 48.0,
                isMobile ? 28.0 : 44.0,
              ),
              child: isMobile
                  ? _buildMobileLayout(context, title, subtitle, imgUrl)
                  : _buildDesktopLayout(context, title, subtitle, imgUrl),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDesktopLayout(
      BuildContext context, String title, String subtitle, String imgUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildArtwork(imgUrl, imgUrl, 240),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildRankLabel(context),
              const SizedBox(height: 12),
              _buildTitle(title, 48),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildSubtitle(subtitle, 20),
              ],
              const SizedBox(height: 20),
              _buildStatRow(context, topItem),
              const SizedBox(height: 20),
              _buildActions(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, String title, String subtitle, String imgUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Center(child: _buildArtwork(imgUrl, imgUrl, 220)),
        const SizedBox(height: 24),
        _buildRankLabel(context),
        const SizedBox(height: 10),
        _buildTitle(title, 32),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildSubtitle(subtitle, 16),
        ],
        const SizedBox(height: 18),
        _buildStatRow(context, topItem),
        const SizedBox(height: 18),
        _buildActions(context),
      ],
    );
  }

  Widget _buildRankLabel(BuildContext context) {
    return Text(
      '#1 ON CHART',
      style: Default_Theme.secondoryTextStyleMedium.merge(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Default_Theme.accentColor2.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeroPlayButton(
          onPressed: playStatus == ChartResolveActionStatus.resolving
              ? null
              : onPlayTap,
          status: playStatus,
          idleLabel: l10n.chartPlay,
        ),
        const SizedBox(width: 12),
        _HeroIconButton(
          onPressed:
              addStatus == ChartResolveActionStatus.resolving ? null : onAddTap,
          status: addStatus,
          icon: MingCute.add_line,
          tooltip: l10n.chartAddToPlaylist,
        ),
      ],
    );
  }

  Widget _buildArtwork(String url, String fallbackUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? LoadImageCached(
              imageUrl: url,
              fallbackUrl: fallbackUrl,
              fit: BoxFit.cover,
            )
          : const Center(
              child:
                  Icon(MingCute.music_2_line, color: Colors.white24, size: 60)),
    );
  }

  Widget _buildTitle(String title, double size) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Default_Theme.secondoryTextStyleMedium.merge(
        TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          height: 1.15,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  Widget _buildSubtitle(String subtitle, double size) {
    return Text(
      subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Default_Theme.secondoryTextStyle.merge(
        TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, ChartItem item) {
    final l10n = AppLocalizations.of(context)!;
    final stats = <Widget>[];
    if (item.peakRank != null) {
      stats.add(_statChip(l10n.chartStatPeak, '#${item.peakRank}'));
    }
    if (item.weeksOnChart != null) {
      stats.add(_statChip(l10n.chartStatWeeks, '${item.weeksOnChart}'));
    }
    if (item.change != null) {
      stats.add(_statChip(l10n.chartStatChange, '${item.change}'));
    }
    if (stats.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: stats);
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Control bar (pinned header) ──────────────────────────────────────────────

class _ChartControlBarDelegate extends SliverPersistentHeaderDelegate {
  final String chartTitle;
  const _ChartControlBarDelegate({required this.chartTitle});

  @override
  double get minExtent => 80.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Default_Theme.themeColor,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Center(
          child: Text(
            chartTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Default_Theme.secondoryTextStyleMedium.merge(
              const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Default_Theme.primaryColor1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

// ── Utility ──────────────────────────────────────────────────────────────────

/// Extracts (title, subtitle, imageUrl) from a [ChartItem].
(String, String, String) extractItemInfo(ChartItem chartItem) {
  return chartItem.item.when(
    track: (track) => (
      track.title,
      track.artists.map((a) => a.name).join(', '),
      track.thumbnail.urlHigh ?? track.thumbnail.url,
    ),
    album: (album) => (
      album.title,
      album.artists.map((a) => a.name).join(', '),
      album.thumbnail?.urlHigh ?? album.thumbnail?.url ?? '',
    ),
    artist: (artist) => (
      artist.name,
      artist.subtitle ?? '',
      artist.thumbnail?.urlHigh ?? artist.thumbnail?.url ?? '',
    ),
    playlist: (playlist) => (
      playlist.title,
      playlist.owner ?? '',
      playlist.thumbnail.urlHigh ?? playlist.thumbnail.url,
    ),
  );
}

/// Prominent play button for the chart hero.
class _HeroPlayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ChartResolveActionStatus status;

  final String idleLabel;

  const _HeroPlayButton({
    required this.onPressed,
    required this.status,
    required this.idleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        splashColor: Default_Theme.accentColor2.withValues(alpha: 0.15),
        highlightColor: Default_Theme.accentColor2.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Default_Theme.accentColor2.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Default_Theme.accentColor2.withValues(alpha: 0.4),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: _HeroActionContent(
              key: ValueKey(status),
              status: status,
              icon: MingCute.play_fill,
              idleLabel: idleLabel,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroActionContent extends StatelessWidget {
  final ChartResolveActionStatus status;
  final IconData icon;
  final String idleLabel;

  const _HeroActionContent({
    super.key,
    required this.status,
    required this.icon,
    required this.idleLabel,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget leading;
    late final String label;

    switch (status) {
      case ChartResolveActionStatus.resolving:
        leading = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Default_Theme.accentColor2,
          ),
        );
        label = AppLocalizations.of(context)!.chartResolving;
        break;
      case ChartResolveActionStatus.success:
        leading = const Icon(
          Icons.check_rounded,
          size: 18,
          color: Default_Theme.accentColor2,
        );
        label = AppLocalizations.of(context)!.chartReady;
        break;
      case ChartResolveActionStatus.idle:
        leading = Icon(icon, size: 18, color: Default_Theme.accentColor2);
        label = idleLabel;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 8),
        Text(
          label,
          style: Default_Theme.secondoryTextStyleMedium.merge(
            const TextStyle(
              color: Default_Theme.accentColor2,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ChartResolveActionStatus status;
  final IconData icon;
  final String tooltip;
  const _HeroIconButton({
    required this.onPressed,
    required this.status,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: RotationTransition(
                    turns:
                        Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _HeroIconVisual(
                key: ValueKey(status),
                status: status,
                icon: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIconVisual extends StatelessWidget {
  final ChartResolveActionStatus status;
  final IconData icon;
  const _HeroIconVisual({
    super.key,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ChartResolveActionStatus.resolving => const Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 2.1,
            color: Colors.white,
          ),
        ),
      ChartResolveActionStatus.success => Icon(
          Icons.check_rounded,
          size: 20,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ChartResolveActionStatus.idle => Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: 0.75),
        ),
    };
  }
}
