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
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlPlaylistView extends StatefulWidget {
  final PlaylistSummary playlist;
  final String pluginId;

  const OnlPlaylistView({
    super.key,
    required this.playlist,
    required this.pluginId,
  });

  @override
  State<OnlPlaylistView> createState() => _OnlPlaylistViewState();
}

class _OnlPlaylistViewState extends State<OnlPlaylistView> {
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
      _contentBloc.add(LoadPlaylistDetails(
        pluginId: widget.pluginId,
        playlistId: widget.playlist.id,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedState());
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.playlist.id, PlaylistType.remotePlaylist);
    if (mounted) setState(() => _isSaved = saved);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final details = _contentBloc.state.playlistDetails;
    final nextPageToken = details?.tracks.nextPageToken;
    final status = _contentBloc.state.playlistDetailStatus;

    if (nextPageToken == null ||
        status == DetailStatus.loading ||
        status == DetailStatus.loadingMore) {
      return;
    }

    final remaining =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    if (remaining <= 320) {
      _contentBloc.add(LoadMorePlaylistTracks(
        pluginId: widget.pluginId,
        playlistId: widget.playlist.id,
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

  String? _cleanDescription(String? rawDesc) {
    if (rawDesc == null) return null;
    final clean = rawDesc.trim();
    if (clean.isEmpty || clean == '[]') return null;
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final highResImage = formatImgURL(
      widget.playlist.thumbnail.url,
      ImageQuality.high,
    );

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      // This ensures the App Bar completely overlays the stack without affecting scroll physics
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // True transparent forever
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
          final details = state.playlistDetails;
          final tracks = details?.tracks.items ?? [];

          final playlistMeta = <String>[
            if (widget.playlist.owner != null &&
                widget.playlist.owner!.trim().isNotEmpty)
              widget.playlist.owner!.trim(),
            if (tracks.isNotEmpty)
              '${tracks.length} Track${tracks.length == 1 ? '' : 's'}',
          ];

          final cleanDesc = _cleanDescription(details?.description);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ─── GLOBAL AMBIENT BACKGROUND ───
              // Completely decoupled from scrolling components
              Positioned.fill(
                child: LoadImageCached(
                  imageUrl: highResImage,
                  fallbackUrl: widget.playlist.thumbnail.url,
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
                          Default_Theme
                              .themeColor, // Solid bottom for tracklist
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
                top:
                    false, // Managed manually so it slides under appbar perfectly
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ─── 1. AUTO-EXPANDING HEADER ───
                    SliverToBoxAdapter(
                      child: Padding(
                        // Add top padding to account for the transparent AppBar
                        padding: const EdgeInsets.only(top: 100),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // 750px Breakpoint: If width is less than 750, force vertical mobile layout
                            final isMobile = constraints.maxWidth < 750;

                            return _PlaylistHeaderContent(
                              isMobile: isMobile,
                              constraints: constraints,
                              imageUrl: highResImage,
                              fallbackUrl: widget.playlist.thumbnail.url,
                              title: widget.playlist.title,
                              meta: playlistMeta,
                              description: cleanDesc,
                              pluginId: widget.pluginId,
                              playlistId: widget.playlist.id,
                              tracks: tracks,
                              isSaved: _isSaved,
                              onToggleSave: () async {
                                final cubit = context.read<LibraryItemsCubit>();
                                if (_isSaved) {
                                  await cubit.removeRemoteSaved(
                                      widget.playlist.id,
                                      PlaylistType.remotePlaylist);
                                } else {
                                  await cubit.saveRemotePlaylist(
                                    playlist: widget.playlist,
                                    sourceName: _sourceName(context),
                                  );
                                }
                                await _checkSavedState();
                              },
                              url: widget.playlist.url,
                            );
                          },
                        ),
                      ),
                    ),

                    // ─── 2. TRACKLIST ───
                    if ((state.playlistDetailStatus == DetailStatus.loaded ||
                            state.playlistDetailStatus ==
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
                                            title: widget.playlist.title),
                                        doPlay: true,
                                        idx: index,
                                      );
                                },
                              ),
                            );
                          },
                        ),
                      )
                    else if (state.playlistDetailStatus == DetailStatus.loaded)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: SignBoardWidget(
                            message: 'No tracks available',
                            icon: MingCute.music_2_line,
                          ),
                        ),
                      )
                    else if (state.playlistDetailStatus == DetailStatus.error)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            state.error ?? 'Failed to load playlist',
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

                    if (state.playlistDetailStatus == DetailStatus.loadingMore)
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

// ============================================================================
// HEADER CONTENT (BULLETPROOF & AUTO-SIZING)
// ============================================================================

class _PlaylistHeaderContent extends StatelessWidget {
  final bool isMobile;
  final BoxConstraints constraints;
  final String imageUrl;
  final String fallbackUrl;
  final String title;
  final List<String> meta;
  final String? description;
  final String pluginId;
  final String playlistId;
  final List<Track> tracks;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final String? url;

  const _PlaylistHeaderContent({
    required this.isMobile,
    required this.constraints,
    required this.imageUrl,
    required this.fallbackUrl,
    required this.title,
    required this.meta,
    required this.description,
    required this.pluginId,
    required this.playlistId,
    required this.tracks,
    required this.isSaved,
    required this.onToggleSave,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIntelligentCover(),
            const SizedBox(height: 24),
            _buildPlaylistInfo(isCentered: true),
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
            _buildIntelligentCover(),
            const SizedBox(width: 40),
            // Expanded forces the text/buttons to stay within bounds, preventing overflow
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaylistInfo(isCentered: false),
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

  /// Bounds the cover gracefully without stretching.
  Widget _buildIntelligentCover() {
    return Hero(
      tag: '${pluginId}_playlist_$playlistId',
      child: Container(
        constraints: BoxConstraints(
          // Capped heights, but responsive widths.
          // Desktop gets exactly 40% of screen width max to ensure text has 60% room.
          maxHeight: isMobile ? 260 : 300,
          maxWidth: isMobile
              ? constraints.maxWidth * 0.85
              : constraints.maxWidth * 0.40,
        ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistInfo({required bool isCentered}) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          // No maxLines! Allows long titles to wrap naturally without breaking
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        const SizedBox(height: 10),
        if (meta.isNotEmpty)
          Text(
            meta.join(' • '),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        if (description != null) ...[
          const SizedBox(height: 14),
          Text(
            description!,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.4,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, {required bool isCentered}) {
    // WRAP prevents overflow if the window is resized aggressively
    return Wrap(
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        // ─── STYLIZED OUTLINED PLAY BUTTON (Consistent 44px Height) ───
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tracks.isEmpty
                ? null
                : () {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .loadPlaylist(
                          Playlist(
                            tracks: tracks,
                            title: title,
                          ),
                          doPlay: true,
                          idx: 0,
                        );
                  },
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
        ),

        // ─── CIRCULAR LIKE BUTTON ───
        _PlaylistCircularButton(
          icon:
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSaved
              ? Default_Theme.accentColor2
              : Default_Theme.primaryColor1,
          isActive: isSaved,
          tooltip: isSaved ? 'Remove from Library' : 'Save to Library',
          onTap: onToggleSave,
        ),

        // ─── CIRCULAR LINK BUTTON ───
        if (url != null)
          _PlaylistCircularButton(
            icon: MingCute.external_link_line,
            color: Default_Theme.primaryColor1,
            isActive: false,
            tooltip: 'Open Original Link',
            onTap: () {
              SnackbarService.showMessage('Opening original playlist page.');
              launchUrl(
                Uri.parse(url!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
      ],
    );
  }
}

// ─── PERFECT CIRCLE ACTION BUTTON ──────────────────────────────────────────

class _PlaylistCircularButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _PlaylistCircularButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    required this.isActive,
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
                color: color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
