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
import 'package:Bloomee/screens/widgets/album_card.dart';
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

class ArtistView extends StatefulWidget {
  final ArtistSummary artist;
  final String pluginId;

  const ArtistView({super.key, required this.artist, required this.pluginId});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late final ContentBloc _contentBloc;
  final ScrollController _albumScrollController = ScrollController();
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
    _albumScrollController.addListener(_onAlbumScroll);

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
      _contentBloc.add(LoadArtistDetails(
        pluginId: widget.pluginId,
        artistId: widget.artist.id,
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedState());
  }

  Future<void> _checkSavedState() async {
    final saved = await context
        .read<LibraryItemsCubit>()
        .isRemoteSaved(widget.artist.id, PlaylistType.artist);
    if (mounted) setState(() => _isSaved = saved);
  }

  void _onAlbumScroll() {
    if (!_albumScrollController.hasClients) return;

    final details = _contentBloc.state.artistDetails;
    final nextPageToken = details?.albums.nextPageToken;
    final status = _contentBloc.state.artistDetailStatus;

    if (nextPageToken == null ||
        status == DetailStatus.loading ||
        status == DetailStatus.loadingMore) {
      return;
    }

    final remaining = _albumScrollController.position.maxScrollExtent -
        _albumScrollController.offset;
    if (remaining <= 320) {
      _contentBloc.add(LoadMoreArtistAlbums(
        pluginId: widget.pluginId,
        artistId: widget.artist.id,
        pageToken: nextPageToken,
      ));
    }
  }

  @override
  void dispose() {
    _albumScrollController.dispose();
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
    final highResImage =
        formatImgURL(widget.artist.thumbnail?.url ?? '', ImageQuality.high);

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
          final details = state.artistDetails;
          final topTracks = details?.topTracks ?? [];
          final albums = details?.albums.items ?? [];

          final artistMeta = <String>[
            if (topTracks.isNotEmpty)
              '${topTracks.length} Top Track${topTracks.length == 1 ? '' : 's'}',
            if (albums.isNotEmpty)
              '${albums.length} Album${albums.length == 1 ? '' : 's'}',
          ];

          final cleanSubtitle = _cleanText(widget.artist.subtitle);
          final cleanDesc = _cleanText(details?.description);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ─── AMBIENT BACKGROUND ───
              Positioned.fill(
                child: LoadImageCached(
                  imageUrl: highResImage,
                  fallbackUrl: widget.artist.thumbnail?.url,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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

              // ─── SCROLLABLE TABS CONTENT ───
              SafeArea(
                bottom: false,
                top: false,
                child: DefaultTabController(
                  length: 2,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      // ─── INTRINSIC HEIGHT HEADER ───
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 750;

                              return _ArtistHeaderContent(
                                isMobile: isMobile,
                                imageUrl: highResImage,
                                fallbackUrl: widget.artist.thumbnail?.url,
                                title: widget.artist.name,
                                subtitle: cleanSubtitle,
                                meta: artistMeta,
                                description: cleanDesc,
                                pluginId: widget.pluginId,
                                artistId: widget.artist.id,
                                topTracks: topTracks,
                                isSaved: _isSaved,
                                url: widget.artist.url,
                                onToggleSave: () async {
                                  final cubit =
                                      context.read<LibraryItemsCubit>();
                                  if (_isSaved) {
                                    await cubit.removeRemoteSaved(
                                        widget.artist.id, PlaylistType.artist);
                                  } else {
                                    await cubit.saveRemoteArtist(
                                      artist: widget.artist,
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
                      // ─── MODERN STICKY TAB BAR (FIXED) ───
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            // Modern segmented pill design for the indicator
                            indicator: BoxDecoration(
                              color: Default_Theme.accentColor2
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Default_Theme.accentColor2
                                    .withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            splashBorderRadius: BorderRadius.circular(24),
                            labelColor: Default_Theme.accentColor2,
                            unselectedLabelColor: Default_Theme.primaryColor1
                                .withValues(alpha: 0.6),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ).merge(Default_Theme.secondoryTextStyleMedium),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ).merge(Default_Theme.secondoryTextStyle),
                            tabs: const [
                              Tab(text: 'Top Songs'),
                              Tab(text: 'Albums'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // ─── TAB BODY ───
                    body: state.artistDetailStatus == DetailStatus.loaded ||
                            state.artistDetailStatus == DetailStatus.loadingMore
                        ? TabBarView(
                            children: [
                              // TOP SONGS TAB
                              topTracks.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 100),
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: topTracks.length,
                                      itemBuilder: (context, index) {
                                        return AnimatedListItem(
                                          index: index,
                                          child: SongCardWidget(
                                            song: topTracks[index],
                                            onOptionsTap: () =>
                                                showMoreBottomSheet(
                                              context,
                                              topTracks[index],
                                              showDelete: false,
                                              showSinglePlay: true,
                                            ),
                                            onTap: () {
                                              context
                                                  .read<BloomeePlayerCubit>()
                                                  .bloomeePlayer
                                                  .loadPlaylist(
                                                    Playlist(
                                                      tracks: topTracks,
                                                      title: widget.artist.name,
                                                    ),
                                                    doPlay: true,
                                                    idx: index,
                                                  );
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: SignBoardWidget(
                                        message: 'No top songs available',
                                        icon: MingCute.music_2_line,
                                      ),
                                    ),
                              // ALBUMS TAB
                              albums.isNotEmpty
                                  ? GridView.builder(
                                      controller: _albumScrollController,
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 100),
                                      physics: const BouncingScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 180,
                                        mainAxisExtent: 240,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: albums.length +
                                          (state.artistDetailStatus ==
                                                  DetailStatus.loadingMore
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        if (index == albums.length) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Default_Theme.accentColor2,
                                            ),
                                          );
                                        }
                                        return AnimatedListItem(
                                          index: index,
                                          child: AlbumCard(
                                            album: albums[index],
                                            pluginId: widget.pluginId,
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: SignBoardWidget(
                                        message: 'No albums available',
                                        icon: MingCute.album_line,
                                      ),
                                    ),
                            ],
                          )
                        : state.artistDetailStatus == DetailStatus.error
                            ? Center(
                                child: Text(
                                  state.error ?? 'Failed to load artist',
                                  style: TextStyle(
                                    color: Default_Theme.primaryColor1
                                        .withValues(alpha: 0.5),
                                  ).merge(Default_Theme.secondoryTextStyle),
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Default_Theme.accentColor2,
                                ),
                              ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtistHeaderContent extends StatelessWidget {
  final bool isMobile;
  final String imageUrl;
  final String? fallbackUrl;
  final String title;
  final String? subtitle;
  final List<String> meta;
  final String? description;
  final String pluginId;
  final String artistId;
  final List<Track> topTracks;
  final bool isSaved;
  final String? url;
  final VoidCallback onToggleSave;

  const _ArtistHeaderContent({
    required this.isMobile,
    required this.imageUrl,
    this.fallbackUrl,
    required this.title,
    this.subtitle,
    required this.meta,
    this.description,
    required this.pluginId,
    required this.artistId,
    required this.topTracks,
    required this.isSaved,
    this.url,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(150),
            const SizedBox(height: 24),
            _buildInfo(isCentered: true),
            const SizedBox(height: 24),
            _buildActions(context, isCentered: true),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAvatar(200),
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

  Widget _buildAvatar(double size) {
    return Hero(
      tag: '${pluginId}_artist_$artistId',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: LoadImageCached(
            imageUrl: imageUrl,
            fallbackUrl: fallbackUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo({required bool isCentered}) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle!.toUpperCase(),
            style: TextStyle(
              color: Default_Theme.accentColor2.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          title,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1.1,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        const SizedBox(height: 10),
        if (meta.isNotEmpty)
          Text(
            meta.join(' • '),
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
    return Wrap(
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        // ─── STYLIZED OUTLINED PLAY BUTTON (Consistent 44px Height) ───
        SizedBox(
          height: 44,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: topTracks.isEmpty
                  ? null
                  : () {
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .loadPlaylist(
                            Playlist(
                              tracks: topTracks,
                              title: title,
                            ),
                            doPlay: true,
                            idx: 0,
                          );
                    },
              borderRadius: BorderRadius.circular(30),
              splashColor: Default_Theme.accentColor2.withValues(alpha: 0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // Tinted background
                  color: Default_Theme.accentColor2.withValues(alpha: 0.1),
                  // Defined colored border
                  border: Border.all(
                    color: Default_Theme.accentColor2,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
        ),
        const SizedBox(width: 12),

        // ─── CIRCULAR LIKE BUTTON ───
        _ArtistCircularButton(
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
        if (url != null) ...[
          const SizedBox(width: 12),
          _ArtistCircularButton(
            icon: MingCute.external_link_line,
            color: Default_Theme.primaryColor1,
            isActive: false,
            tooltip: 'Open Original Link',
            onTap: () {
              SnackbarService.showMessage('Opening original artist page.');
              launchUrl(
                Uri.parse(url!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ],
    );
  }
}

// ─── PERFECT CIRCLE ACTION BUTTON ──────────────────────────────────────────

class _ArtistCircularButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _ArtistCircularButton({
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
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GLASSMORPHIC TAB BAR DELEGATE (FIXED) ─────────────────────────────────

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          // THE FIX: Use a very low opacity or transparent color
          // so it acts like frosted glass without the "Black Tape" look
          color: Default_Theme.themeColor.withValues(alpha: 0.2),
          alignment: Alignment.center,
          child: Container(
            height: 44,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: _tabBar,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
