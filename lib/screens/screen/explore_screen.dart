import 'dart:developer';

import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/plugins/blocs/content/content_bloc.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/screen/home/chart_carousel.dart';
import 'package:Bloomee/screens/screen/home/home_layout.dart';
import 'package:Bloomee/screens/screen/home/media_shelf.dart';
import 'package:Bloomee/screens/screen/home/track_shelf.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/screen/home_views/recents_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/widgets/feed_card.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Home: news card, chart carousel, recently played, Last.fm picks, then
/// the home sections of the chosen content plugin.
///
/// Everything is a sliver, so only what is on screen is built and only the
/// artwork on screen is loaded.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ContentBloc _home =
      ContentBloc(pluginService: ServiceLocator.pluginService);

  /// Last.fm picks, fetched once and kept until the setting changes.
  Future<List<Track>>? _lastFm;

  @override
  void initState() {
    super.initState();
    _loadHomeSections();
    _loadLastFm();
  }

  @override
  void dispose() {
    _home.close();
    super.dispose();
  }

  /// Loads home sections once settings and the preferred plugin are ready.
  void _loadHomeSections() {
    final settings = context.read<SettingsCubit>().state;
    if (!settings.settingsReady) return;
    final plugins = context.read<PluginBloc>().state;
    final resolvers = plugins.loadedContentResolvers;
    if (resolvers.isEmpty) return;

    // Wait for an installed preferred plugin to finish loading, rather than
    // flashing another plugin's home page first.
    final preferred = settings.homePluginId;
    if (preferred.isNotEmpty &&
        !resolvers.any((p) => p.manifest.id == preferred) &&
        plugins.availablePlugins.any((p) => p.manifest.id == preferred)) {
      return;
    }

    final pluginId = _homePluginId(resolvers);
    if (_home.state.activePluginId == pluginId &&
        _home.state.homeSections != null) {
      return;
    }
    _home.add(GetHomeSections(pluginId: pluginId));
  }

  String _homePluginId(List<dynamic> resolvers) {
    final preferred = context.read<SettingsCubit>().state.homePluginId;
    return preferred.isNotEmpty &&
            resolvers.any((p) => p.manifest.id == preferred)
        ? preferred
        : resolvers.first.manifest.id;
  }

  void _loadLastFm({bool force = false}) {
    final enabled = context.read<SettingsCubit>().state.lFMPicks;
    if (!enabled) {
      if (_lastFm != null) setState(() => _lastFm = null);
      return;
    }
    if (_lastFm != null && !force) return;
    final plugins = context.read<PluginBloc>().state;
    final priority = context.read<SettingsCubit>().state.resolverPriority;
    final ids =
        plugins.loadedContentResolvers.map((p) => p.manifest.id).toList();
    if (ids.isEmpty) return;
    final future = context.read<LastdotfmCubit>().getRecommendedTracks(
      resolverPluginIds: [
        ...priority.where(ids.contains),
        ...ids.where((id) => !priority.contains(id)),
      ],
    ).catchError((Object e) {
      log('Last.fm picks failed: $e', name: 'ExploreScreen');
      return const <Track>[];
    });
    setState(() => _lastFm = future);
  }

  Future<void> _refresh() async {
    final resolvers = context.read<PluginBloc>().state.loadedContentResolvers;
    if (resolvers.isNotEmpty) {
      _home.add(GetHomeSections(
          pluginId: _homePluginId(resolvers), bypassCache: true));
    }
    _loadLastFm(force: true);
    await context.read<NotificationCubit>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (a, b) =>
              a.homePluginId != b.homePluginId ||
              (!a.settingsReady && b.settingsReady),
          listener: (context, _) {
            _home.add(const ClearHomeSections());
            _loadHomeSections();
            _loadLastFm();
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (a, b) => a.lFMPicks != b.lFMPicks,
          listener: (context, _) => _loadLastFm(force: true),
        ),
        BlocListener<PluginBloc, PluginState>(
          listenWhen: (a, b) =>
              a.loadedContentResolvers != b.loadedContentResolvers ||
              a.loadedPluginIds != b.loadedPluginIds,
          listener: (context, plugins) {
            if (plugins.loadedContentResolvers.isEmpty) {
              _home.add(const ClearHomeSections());
              return;
            }
            final active = _home.state.activePluginId;
            if (active != null && !plugins.loadedPluginIds.contains(active)) {
              _home.add(const ClearHomeSections());
            }
            _loadHomeSections();
            _loadLastFm();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final m = HomeMetrics(
                width: constraints.maxWidth,
                screenHeight: MediaQuery.sizeOf(context).height,
              );
              return RefreshIndicator(
                color: Default_Theme.accentColor2,
                backgroundColor: Default_Theme.themeColor,
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics()),
                  slivers: [
                    const CustomDiscoverBar(),
                    const SliverToBoxAdapter(child: HomeFeedCard()),
                    SliverToBoxAdapter(child: ChartCarousel(metrics: m)),
                    SliverToBoxAdapter(child: _RecentlyShelf(metrics: m)),
                    SliverToBoxAdapter(
                      child: _LastFmShelf(future: _lastFm, metrics: m),
                    ),
                    _HomeSections(bloc: _home, metrics: m),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Spacing of the original design.
const _trackShelfSpacing = EdgeInsets.only(top: 15);
const _sectionSpacing = EdgeInsets.only(top: 20);

class _RecentlyShelf extends StatelessWidget {
  final HomeMetrics metrics;
  const _RecentlyShelf({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<RecentlyCubit, RecentlyCubitState>(
      builder: (context, state) {
        if (state.tracks.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: _trackShelfSpacing,
          child: HomeTrackShelf(
            label: l10n.exploreRecently,
            queueTitle: 'Recently',
            tracks: state.tracks,
            metrics: metrics,
            onLabelTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
          ),
        );
      },
    );
  }
}

class _LastFmShelf extends StatelessWidget {
  final Future<List<Track>>? future;
  final HomeMetrics metrics;
  const _LastFmShelf({required this.future, required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (future == null) return const SizedBox.shrink();
    return FutureBuilder<List<Track>>(
      future: future,
      builder: (context, snapshot) {
        final tracks = snapshot.data ?? const <Track>[];
        if (tracks.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: _trackShelfSpacing,
          child: HomeTrackShelf(
            label: AppLocalizations.of(context)!.exploreLastFmPicks,
            queueTitle: 'Last.Fm Picks',
            tracks: tracks,
            metrics: metrics,
          ),
        );
      },
    );
  }
}

/// The content plugin's home sections, built lazily as they scroll in.
class _HomeSections extends StatelessWidget {
  final ContentBloc bloc;
  final HomeMetrics metrics;
  const _HomeSections({required this.bloc, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ContentBloc, ContentState>(
      bloc: bloc,
      builder: (context, state) {
        final plugins = context.read<PluginBloc>().state;
        final sections = state.homeSections ?? const <Section>[];

        if (sections.isNotEmpty) {
          final pluginId = state.activePluginId ?? '';
          return SliverList.builder(
            itemCount: sections.length,
            itemBuilder: (context, i) => Padding(
              padding: _sectionSpacing,
              child: _shelf(sections[i], pluginId, state),
            ),
          );
        }

        if (plugins.loadedContentResolvers.isEmpty) {
          return _message(l10n.emptyNoContentPlugin, MingCute.plugin_2_line);
        }
        final active = state.activePluginId;
        if (active != null && !plugins.loadedPluginIds.contains(active)) {
          return _message(l10n.emptyRefreshingSource, MingCute.warning_line);
        }
        if (state.homeSectionsStatus == DetailStatus.error) {
          return _message(
              state.error ?? l10n.exploreFailedToLoad, MingCute.sweats_line);
        }
        if (state.homeSectionsStatus == DetailStatus.loading) {
          return BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, connection) =>
                connection == ConnectivityState.disconnected
                    ? _message(l10n.emptyNoInternet, MingCute.wifi_off_line)
                    : SliverToBoxAdapter(
                        child: _SectionsSkeleton(metrics: metrics)),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _shelf(Section section, String pluginId, ContentState state) {
    final moreLink = section.moreLink;
    return HomeMediaShelf(
      key: ValueKey(section.id),
      section: section,
      pluginId: pluginId,
      canLoadMore: moreLink != null,
      isLoadingMore: state.isHomeSectionLoading(section.id),
      onLoadMore: moreLink == null
          ? null
          : () => bloc.add(LoadMoreHomeSectionItems(
                pluginId: pluginId,
                sectionId: section.id,
                moreLink: moreLink,
              )),
    );
  }

  Widget _message(String text, IconData icon) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: SignBoardWidget(message: text, icon: icon),
        ),
      );
}

class _SectionsSkeleton extends StatelessWidget {
  final HomeMetrics metrics;
  const _SectionsSkeleton({required this.metrics});

  @override
  Widget build(BuildContext context) {
    Widget shelf() => Padding(
          padding: _sectionSpacing,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 8, bottom: 6),
                child: HomeSkeleton(width: 150, height: 18, radius: 6),
              ),
              SizedBox(
                height: HomeMediaShelf.rowHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemExtent: HomeMetrics.cardSize + 16,
                  itemCount: 8,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: HomeSkeleton(
                          width: HomeMetrics.cardSize,
                          height: HomeMetrics.cardSize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    return Column(children: [shelf(), shelf()]);
  }
}

class CustomDiscoverBar extends StatelessWidget {
  const CustomDiscoverBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        children: [
          Text(
            l10n.exploreDiscover,
            style: Default_Theme.primaryTextStyle.merge(
              const TextStyle(fontSize: 34, color: Default_Theme.primaryColor1),
            ),
          ),
          const Spacer(),
          const NotificationIcon(),
          _BarIcon(
            icon: MingCute.flower_4_fill,
            size: 28,
            tooltip: l10n.settingsAbout,
            page: const About(),
          ),
          _BarIcon(
            icon: MingCute.stopwatch_line,
            tooltip: l10n.timerTitle,
            page: const TimerView(),
          ),
          _BarIcon(
            icon: MingCute.settings_3_line,
            tooltip: l10n.settingsTitle,
            page: const SettingsView(),
          ),
        ],
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Widget page;
  final double size;
  const _BarIcon({
    required this.icon,
    required this.tooltip,
    required this.page,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        padding: const EdgeInsets.all(5),
        constraints: const BoxConstraints(),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        icon: Icon(icon, color: Default_Theme.primaryColor1, size: size),
      );
}

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationCubit, NotificationState, int>(
      selector: (state) => state.unread,
      builder: (context, unread) => IconButton(
        tooltip: AppLocalizations.of(context)!.notificationsTitle,
        padding: const EdgeInsets.all(5),
        constraints: const BoxConstraints(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationView()),
        ),
        icon: badges.Badge(
          showBadge: unread > 0,
          badgeAnimation: const badges.BadgeAnimation.scale(),
          badgeContent: Text(
            unread > 9 ? '9+' : '$unread',
            style: Default_Theme.secondoryTextStyleMedium.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Default_Theme.primaryColor2,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Default_Theme.accentColor2,
            padding: EdgeInsets.all(4.5),
          ),
          position: badges.BadgePosition.topEnd(top: -6, end: -6),
          child: const Icon(
            MingCute.notification_line,
            color: Default_Theme.primaryColor1,
            size: 30,
          ),
        ),
      ),
    );
  }
}
