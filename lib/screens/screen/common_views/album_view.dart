// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/plugins/blocs/content/content_bloc.dart';
import 'package:Bloomee/plugins/blocs/content/content_event.dart';
import 'package:Bloomee/plugins/blocs/content/content_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AlbumView extends StatefulWidget {
  final AlbumSummary album;
  final String pluginId;
  final String? heroTag;

  const AlbumView({
    super.key,
    required this.album,
    required this.pluginId,
    this.heroTag,
  });

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  late final ContentBloc _contentBloc;
  late final ScrollController _scrollController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!context.read<PluginBloc>().state.isPluginLoaded(widget.pluginId)) {
        GlobalEventBus.instance
            .emitError(AppError.pluginNotLoaded(pluginId: widget.pluginId));
        return;
      }
      _contentBloc.add(LoadAlbumDetails(
          pluginId: widget.pluginId, albumId: widget.album.id));
      _checkSavedState();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _contentBloc.close();
    super.dispose();
  }

  String _sourceName(BuildContext context) {
    for (final plugin in context.read<PluginBloc>().state.availablePlugins) {
      if (plugin.manifest.id == widget.pluginId) return plugin.manifest.name;
    }
    return widget.pluginId;
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.album.id, PlaylistType.album);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSaveState() async {
    final cubit = context.read<LibraryItemsCubit>();
    if (_isSaved) {
      await cubit.removeRemoteSaved(widget.album.id, PlaylistType.album);
    } else {
      await cubit.saveRemoteAlbum(
          album: widget.album, sourceName: _sourceName(context));
    }
    await _checkSavedState();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final details = _contentBloc.state.albumDetails;
    final nextPageToken = details?.tracks.nextPageToken;
    final status = _contentBloc.state.albumDetailStatus;

    if (nextPageToken == null ||
        status == DetailStatus.loading ||
        status == DetailStatus.loadingMore) return;

    if (_scrollController.position.maxScrollExtent - _scrollController.offset <=
        320) {
      _contentBloc.add(LoadMoreAlbumTracks(
        pluginId: widget.pluginId,
        albumId: widget.album.id,
        pageToken: nextPageToken,
      ));
    }
  }

  String? _cleanText(String? raw) {
    final clean = raw?.trim();
    return (clean == null || clean.isEmpty || clean == '[]') ? null : clean;
  }

  Future<void> _handlePlayerFirstBack() async {
    final overlayC = context.read<PlayerOverlayCubit>();
    if (overlayC.state) {
      if (!overlayC.collapseUpNextPanel()) {
        overlayC.hidePlayer();
      }
      return;
    }

    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handlePlayerFirstBack();
      },
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildOptimizedBackground(),
            _buildScrollableContent(l10n),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Default_Theme.primaryColor1, size: 20),
            ),
            onPressed: _handlePlayerFirstBack,
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedBackground() {
    return Positioned.fill(
      child: RepaintBoundary(
        child: BlocSelector<ContentBloc, ContentState, String>(
          bloc: _contentBloc,
          selector: (state) {
            final summary = state.albumDetails?.summary;
            return summary?.thumbnail?.urlHigh ??
                summary?.thumbnail?.url ??
                widget.album.thumbnail?.urlHigh ??
                widget.album.thumbnail?.url ??
                '';
          },
          builder: (context, imageUrl) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // ImageFiltered avoids the extreme performance penalty of BackdropFilter
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: LoadImageCached(
                    imageUrl: imageUrl,
                    fallbackUrl: widget.album.thumbnail?.url,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Default_Theme.themeColor.withValues(alpha: 0.4),
                        Default_Theme.themeColor.withValues(alpha: 0.9),
                        Default_Theme.themeColor,
                      ],
                      stops: const [0.0, 0.45, 1.0],
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

  Widget _buildScrollableContent(AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      top: false,
      child: BlocBuilder<ContentBloc, ContentState>(
        bloc: _contentBloc,
        builder: (context, state) {
          final details = state.albumDetails;
          final albumSummary = details?.summary ?? widget.album;
          final tracks = details?.tracks.items ?? [];
          final status = state.albumDetailStatus;

          final imageUrl = albumSummary.thumbnail?.urlHigh ??
              albumSummary.thumbnail?.url ??
              widget.album.thumbnail?.urlHigh ??
              widget.album.thumbnail?.url ??
              '';

          final albumArtists = albumSummary.artists
              .map((a) => a.name.trim())
              .where((name) => name.isNotEmpty)
              .join(', ');

          final metaParts = <String>[];
          final cleanYear = _cleanText(albumSummary.year?.toString());
          final cleanSubtitle = _cleanText(albumSummary.subtitle);

          if (cleanYear != null) metaParts.add(cleanYear);
          if (tracks.isNotEmpty) {
            metaParts.add(l10n.albumViewTrackCount(tracks.length));
          }
          if (cleanSubtitle != null) metaParts.add(cleanSubtitle);

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _AlbumHeaderContent(
                        isMobile: constraints.maxWidth < 750,
                        constraints: constraints,
                        imageUrl: imageUrl,
                        fallbackUrl: albumSummary.thumbnail?.url,
                        title: albumSummary.title,
                        artists: albumArtists,
                        meta: metaParts.join(' • '),
                        pluginId: widget.pluginId,
                        albumId: albumSummary.id,
                        heroTag: widget.heroTag,
                        tracks: tracks,
                        isSaved: _isSaved,
                        url: albumSummary.url,
                        onToggleSave: _toggleSaveState,
                      );
                    },
                  ),
                ),
              ),

              // Tracklist Generation
              if ((status == DetailStatus.loaded ||
                      status == DetailStatus.loadingMore) &&
                  tracks.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 24, bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = tracks[index];
                        return AnimatedListItem(
                          index: index,
                          child: SongCardWidget(
                            index: index + 1,
                            song: song,
                            onOptionsTap: () => showMoreBottomSheet(
                              context,
                              song,
                              showDelete: false,
                              showSinglePlay: true,
                            ),
                            onTap: () => context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .loadPlaylist(
                                  Playlist(
                                      tracks: tracks,
                                      title: albumSummary.title),
                                  doPlay: true,
                                  idx: index,
                                ),
                          ),
                        );
                      },
                      childCount: tracks.length,
                      addRepaintBoundaries:
                          true, // Crucial to prevent jank when scrolling list
                    ),
                  ),
                )
              else if (status == DetailStatus.loaded)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: SignBoardWidget(
                          message: l10n.emptyNoTracks,
                          icon: MingCute.music_2_line)),
                )
              else if (status == DetailStatus.error)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.error ?? l10n.albumViewLoadFailed,
                      style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5))
                          .merge(Default_Theme.secondoryTextStyle),
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2)),
                ),

              if (status == DetailStatus.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Default_Theme.accentColor2)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AlbumHeaderContent extends StatelessWidget {
  final bool isMobile;
  final BoxConstraints constraints;
  final String imageUrl;
  final String? fallbackUrl;
  final String title;
  final String artists;
  final String meta;
  final String pluginId;
  final String albumId;
  final String? heroTag;
  final List<Track> tracks;
  final bool isSaved;
  final String? url;
  final VoidCallback onToggleSave;

  const _AlbumHeaderContent({
    required this.isMobile,
    required this.constraints,
    required this.imageUrl,
    this.fallbackUrl,
    required this.title,
    required this.artists,
    required this.meta,
    required this.pluginId,
    required this.albumId,
    this.heroTag,
    required this.tracks,
    required this.isSaved,
    this.url,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCover(),
            const SizedBox(height: 24),
            _buildInfo(isCentered: true),
            const SizedBox(height: 24),
            _buildActions(context, isCentered: true),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCover(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfo(isCentered: false),
                const SizedBox(height: 24),
                _buildActions(context, isCentered: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    final double widthFactor = isMobile ? 0.7 : 0.35;
    final double availableWidth = constraints.maxWidth * widthFactor;
    final double coverSize = availableWidth.clamp(
      isMobile ? 200.0 : 260.0,
      isMobile ? 260.0 : 320.0,
    );

    // Caching the massive BoxShadow to avoid GPU recalculations during list scroll
    final cover = RepaintBoundary(
      child: Container(
        width: coverSize,
        height: coverSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LoadImageCached(
            imageUrl: imageUrl,
            fallbackUrl: fallbackUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    return heroTag == null ? cover : Hero(tag: heroTag!, child: cover);
  }

  Widget _buildInfo({required bool isCentered}) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        if (artists.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            artists,
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyleMedium),
          ),
        ],
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            meta.toUpperCase(),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, {required bool isCentered}) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        _PremiumPlayButton(
          isEmpty: tracks.isEmpty,
          onTap: () =>
              context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                    Playlist(tracks: tracks, title: title),
                    doPlay: true,
                    idx: 0,
                  ),
        ),
        _PremiumCircularButton(
          icon:
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          isActive: isSaved,
          tooltip: isSaved
              ? l10n.tooltipRemoveFromLibrary
              : l10n.tooltipSaveToLibrary,
          onTap: onToggleSave,
        ),
        if (url != null)
          _PremiumCircularButton(
            icon: MingCute.external_link_line,
            isActive: false,
            tooltip: l10n.tooltipOpenOriginalLink,
            onTap: () {
              SnackbarService.showMessage(l10n.snackbarOpeningAlbumPage);
              launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
            },
          ),
      ],
    );
  }
}

// ─── REUSABLE CONST WIDGETS ────────────────────────────────────────

class _PremiumPlayButton extends StatelessWidget {
  final bool isEmpty;
  final VoidCallback onTap;

  const _PremiumPlayButton({required this.isEmpty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEmpty ? null : onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: Default_Theme.accentColor2.withValues(alpha: 0.2),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Default_Theme.accentColor2.withValues(alpha: 0.1),
            border: Border.all(color: Default_Theme.accentColor2, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(MingCute.play_fill,
                  size: 20, color: Default_Theme.accentColor2),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.chartPlay,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Default_Theme.accentColor2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCircularButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _PremiumCircularButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                  : Default_Theme.primaryColor1.withValues(alpha: 0.05),
              border: Border.all(
                color: isActive
                    ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                    : Default_Theme.primaryColor1.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isActive
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor1,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
