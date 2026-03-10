// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isSaved = false;

  String _sourceName(BuildContext context) {
    final plugins = context.read<PluginBloc>().state.availablePlugins;
    for (final plugin in plugins) {
      if (plugin.manifest.id == widget.pluginId) {
        return plugin.manifest.name;
      }
    }
    return widget.pluginId;
  }

  @override
  void initState() {
    super.initState();
    _contentBloc = ContentBloc(pluginService: ServiceLocator.pluginService);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isLoaded =
          context.read<PluginBloc>().state.isPluginLoaded(widget.pluginId);
      if (!isLoaded) {
        GlobalEventBus.instance.emitError(
          AppError.pluginNotLoaded(pluginId: widget.pluginId),
        );
        return;
      }
      _contentBloc.add(LoadAlbumDetails(
        pluginId: widget.pluginId,
        albumId: widget.album.id,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedState());
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.album.id, PlaylistType.album);
    if (mounted) setState(() => _isSaved = saved);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final details = _contentBloc.state.albumDetails;
    final nextPageToken = details?.tracks.nextPageToken;
    final status = _contentBloc.state.albumDetailStatus;

    if (nextPageToken == null ||
        status == DetailStatus.loading ||
        status == DetailStatus.loadingMore) {
      return;
    }

    final remaining =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (remaining <= 320) {
      _contentBloc.add(LoadMoreAlbumTracks(
        pluginId: widget.pluginId,
        albumId: widget.album.id,
        pageToken: nextPageToken,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _contentBloc.close();
    super.dispose();
  }

  String? _cleanText(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim();
    if (clean.isEmpty || clean == '[]') return null;
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Default_Theme.primaryColor1,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ContentBloc, ContentState>(
        bloc: _contentBloc,
        builder: (context, state) {
          final details = state.albumDetails;
          final albumSummary = details?.summary ?? widget.album;
          final tracks = details?.tracks.items ?? [];
          final highResImage = albumSummary.thumbnail?.urlHigh ??
              albumSummary.thumbnail?.url ??
              widget.album.thumbnail?.urlHigh ??
              widget.album.thumbnail?.url ??
              '';

          final detailArtists = albumSummary.artists
              .map((a) => a.name.trim())
              .where((name) => name.isNotEmpty)
              .toList();
          final albumArtists = detailArtists.join(', ');

          final metaParts = <String>[];
          final cleanYear = _cleanText(albumSummary.year?.toString());
          final cleanSubtitle = _cleanText(albumSummary.subtitle);

          if (cleanYear != null) metaParts.add(cleanYear);
          if (tracks.isNotEmpty) {
            metaParts.add(l10n.albumViewTrackCount(tracks.length));
          }
          if (cleanSubtitle != null) metaParts.add(cleanSubtitle);

          final albumMeta = metaParts.join(' • ');

          return Stack(
            fit: StackFit.expand,
            children: [
              // ─── AMBIENT BACKGROUND ───
              Positioned.fill(
                child: LoadImageCached(
                  imageUrl: highResImage,
                  fallbackUrl: albumSummary.thumbnail?.url,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
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
                ),
              ),

              // ─── SCROLLABLE CONTENT ───
              SafeArea(
                bottom: false,
                top: false,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ─── AUTO-EXPANDING INTRINSIC HEADER ───
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 750;

                            return _AlbumHeaderContent(
                              isMobile: isMobile,
                              constraints: constraints,
                              imageUrl: highResImage,
                              fallbackUrl: albumSummary.thumbnail?.url,
                              title: albumSummary.title,
                              artists: albumArtists,
                              meta: albumMeta,
                              pluginId: widget.pluginId,
                              albumId: albumSummary.id,
                              heroTag: widget.heroTag,
                              tracks: tracks,
                              isSaved: _isSaved,
                              url: albumSummary.url,
                              onToggleSave: () async {
                                final cubit = context.read<LibraryItemsCubit>();
                                if (_isSaved) {
                                  await cubit.removeRemoteSaved(
                                      widget.album.id, PlaylistType.album);
                                } else {
                                  await cubit.saveRemoteAlbum(
                                    album: widget.album,
                                    sourceName: _sourceName(context),
                                  );
                                }
                                await _checkSavedState();
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // ─── TRACKLIST ───
                    if ((state.albumDetailStatus == DetailStatus.loaded ||
                            state.albumDetailStatus ==
                                DetailStatus.loadingMore) &&
                        tracks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 24, bottom: 120),
                        sliver: SliverList.builder(
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            return AnimatedListItem(
                              index: index,
                              child: SongCardWidget(
                                song: tracks[index],
                                onOptionsTap: () => showMoreBottomSheet(
                                  context,
                                  tracks[index],
                                  showDelete: false,
                                  showSinglePlay: true,
                                ),
                                onTap: () {
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .bloomeePlayer
                                      .loadPlaylist(
                                        Playlist(
                                            tracks: tracks,
                                            title: albumSummary.title),
                                        doPlay: true,
                                        idx: index,
                                      );
                                },
                              ),
                            );
                          },
                        ),
                      )
                    else if (state.albumDetailStatus == DetailStatus.loaded)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: SignBoardWidget(
                            message: l10n.emptyNoTracks,
                            icon: MingCute.music_2_line,
                          ),
                        ),
                      )
                    else if (state.albumDetailStatus == DetailStatus.error)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            state.error ?? l10n.albumViewLoadFailed,
                            style: TextStyle(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.5),
                            ).merge(Default_Theme.secondoryTextStyle),
                          ),
                        ),
                      )
                    else
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Default_Theme.accentColor2,
                          ),
                        ),
                      ),

                    if (state.albumDetailStatus == DetailStatus.loadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Default_Theme.accentColor2,
                            ),
                          ),
                        ),
                      ),
                  ],
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
    } else {
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
  }

  Widget _buildCover() {
    const double mobileTargetSize = 260;
    const double desktopTargetSize = 320;

    final double widthFactor = isMobile ? 0.7 : 0.35;

    final double availableWidth = constraints.maxWidth * widthFactor;

    final double coverSize = availableWidth.clamp(
      isMobile ? 200.0 : 260.0, // min
      isMobile ? mobileTargetSize : desktopTargetSize, // max
    );

    final cover = Container(
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
    );

    if (heroTag == null) {
      return cover;
    }

    return Hero(tag: heroTag!, child: cover);
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
    return Wrap(
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        _PremiumPlayButton(
          isEmpty: tracks.isEmpty,
          onTap: () {
            context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                  Playlist(tracks: tracks, title: title),
                  doPlay: true,
                  idx: 0,
                );
          },
        ),
        _PremiumCircularButton(
          icon:
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          isActive: isSaved,
          tooltip: isSaved ? 'Remove from Library' : 'Save to Library',
          onTap: onToggleSave,
        ),
        if (url != null)
          _PremiumCircularButton(
            icon: MingCute.external_link_line,
            isActive: false,
            tooltip: 'Open Original Link',
            onTap: () {
              SnackbarService.showMessage('Opening original album page.');
              launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
            },
          ),
      ],
    );
  }
}

// ─── REUSABLE ACTION BUTTONS ───────────────────────────────────────────────

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
            border: Border.all(
              color: Default_Theme.accentColor2,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(MingCute.play_fill,
                  size: 20, color: Default_Theme.accentColor2),
              SizedBox(width: 8),
              Text(
                'Play',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Default_Theme.accentColor2,
                ),
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
    final activeColor = Default_Theme.accentColor2;
    final inactiveColor = Default_Theme.primaryColor1;

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
                  ? activeColor.withValues(alpha: 0.15)
                  : inactiveColor.withValues(alpha: 0.05),
              border: Border.all(
                color: isActive
                    ? activeColor.withValues(alpha: 0.5)
                    : inactiveColor.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
