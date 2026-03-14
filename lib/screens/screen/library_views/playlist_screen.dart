import 'dart:ui';
import 'dart:math' as math;
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

part 'playlist_info_dialog.dart';

class PlaylistView extends StatefulWidget {
  final String? initialPlaylistName;

  const PlaylistView({super.key, this.initialPlaylistName});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  late final ScrollController _scrollController;
  bool _didTriggerInitialLoad = false;
  String? _targetPlaylistName;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    if (widget.initialPlaylistName != null &&
        widget.initialPlaylistName!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startInitialLoad(widget.initialPlaylistName!);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didTriggerInitialLoad) return;

    final playlistName = _targetPlaylistName ??
        widget.initialPlaylistName ??
        context.read<CurrentPlaylistCubit>().currentPlaylistName;
    if (playlistName == null || playlistName.trim().isEmpty) return;

    _didTriggerInitialLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialLoad(playlistName);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 500) {
      context.read<CurrentPlaylistCubit>().loadMoreTracks();
    }
  }

  Future<void> _startInitialLoad(String playlistName) async {
    if (!mounted) return;
    _targetPlaylistName = playlistName;
    final cubit = context.read<CurrentPlaylistCubit>();

    await cubit.openPlaylist(playlistName, deferFirstPage: true);
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await cubit.loadMoreTracks();
  }

  Future<void> _playFromPlaylist(
      BuildContext context, CurrentPlaylistState state,
      {int? index, bool shuffle = false}) async {
    final fullPlaylist =
        await context.read<CurrentPlaylistCubit>().ensureAllTracksLoaded();
    if (!mounted || fullPlaylist.tracks.isEmpty) return;

    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
          Playlist(tracks: fullPlaylist.tracks, title: fullPlaylist.title),
          idx: index ?? 0,
          doPlay: true,
          shuffling: shuffle,
        );
  }

  List<Color> _getOptimizedPalette(BuildContext context) {
    final pallete =
        context.read<CurrentPlaylistCubit>().getCurrentPlaylistPallete();
    Color fgColor = pallete?.lightVibrantColor?.color ?? Colors.white;
    Color bgColor = pallete?.dominantColor?.color ??
        pallete?.darkMutedColor?.color ??
        Default_Theme.themeColor;

    if (bgColor.computeLuminance() / fgColor.computeLuminance() > 0.05) {
      fgColor = HSLColor.fromColor(fgColor)
          .withLightness(
              (HSLColor.fromColor(fgColor).lightness + 0.1).clamp(0.0, 1.0))
          .toColor();
      bgColor = HSLColor.fromColor(bgColor)
          .withLightness(
              (HSLColor.fromColor(bgColor).lightness - 0.1).clamp(0.0, 1.0))
          .toColor();
    }
    return [fgColor, bgColor];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
        builder: (context, state) {
          final waitingForTarget = _targetPlaylistName != null &&
              state.playlist.title != _targetPlaylistName;

          if (waitingForTarget ||
              state.status == CurrentPlaylistLoadStatus.initial ||
              state.status == CurrentPlaylistLoadStatus.loading) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2));
          }

          if (state.status == CurrentPlaylistLoadStatus.error) {
            return Center(
                child: SignBoardWidget(
                    message: state.errorMessage ?? 'Failed to load playlist',
                    icon: MingCute.alert_line));
          }

          final colors = _getOptimizedPalette(context);
          final fgColor = colors[0];
          final bgColor = colors[1];
          final tracks = state.playlist.tracks;

          final imageUrl = tracks.isNotEmpty
              ? (tracks.first.thumbnail.urlHigh ?? tracks.first.thumbnail.url)
              : '';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 850;
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildAmbientBackground(imageUrl, bgColor, isMobile),
                  if (isMobile)
                    _buildMobileLayout(
                        state, fgColor, bgColor, imageUrl, l10n, constraints)
                  else
                    _buildDesktopLayout(
                        state, fgColor, bgColor, imageUrl, l10n, constraints),
                ],
              );
            },
          );
        },
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
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientBackground(
      String imageUrl, Color dominantColor, bool isMobile) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Default_Theme.themeColor),

            // Core dominant color glow
            Positioned(
              top: isMobile ? -100 : -200,
              left: isMobile ? -50 : -200,
              width: 800,
              height: 800,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      dominantColor.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Base Image Blur (Matches Apple Music / Spotify aesthetics)
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                    child:
                        LoadImageCached(imageUrl: imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),

            // Deep fade to bottom to preserve tracklist readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Default_Theme.themeColor.withValues(alpha: 0.1),
                    Default_Theme.themeColor.withValues(alpha: 0.85),
                    Default_Theme.themeColor,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      CurrentPlaylistState state,
      Color fgColor,
      Color bgColor,
      String imageUrl,
      AppLocalizations l10n,
      BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── LEFT PANEL (Adaptive Fixed Sidebar) ───
        SizedBox(
          width: math.max(340, constraints.maxWidth * 0.35),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(48, 100, 32, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIntelligentCover(imageUrl, bgColor,
                    isMobile: false, constraints: constraints),
                const SizedBox(height: 32),
                _buildInfo(state, l10n, isCentered: false),
                const SizedBox(height: 32),
                _buildActions(state, fgColor, bgColor, isCentered: false),
              ],
            ),
          ),
        ),

        // ─── RIGHT PANEL (Glassmorphic Tracklist) ───
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 100, 48, 48),
            decoration: BoxDecoration(
              color: Default_Theme.themeColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 15)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (state.playlist.tracks.isEmpty && !state.isLoadingMore)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: SignBoardWidget(
                              message: l10n.playlistEmptyState,
                              icon: MingCute.playlist_line)),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      sliver: _buildTrackList(state),
                    ),
                  if (state.isLoadingMore || state.hasMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Default_Theme.accentColor2)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      CurrentPlaylistState state,
      Color fgColor,
      Color bgColor,
      String imageUrl,
      AppLocalizations l10n,
      BoxConstraints constraints) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIntelligentCover(imageUrl, bgColor,
                    isMobile: true, constraints: constraints),
                const SizedBox(height: 32),
                _buildInfo(state, l10n, isCentered: true),
                const SizedBox(height: 28),
                _buildActions(state, fgColor, bgColor, isCentered: true),
              ],
            ),
          ),
        ),
        if (state.playlist.tracks.isEmpty && !state.isLoadingMore)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
                child: SignBoardWidget(
                    message: l10n.playlistEmptyState,
                    icon: MingCute.playlist_line)),
          )
        else
          SliverPadding(
            padding: EdgeInsets.only(bottom: state.isLoadingMore ? 0 : 120),
            sliver: _buildTrackList(state),
          ),
        if (state.isLoadingMore || state.hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2)),
            ),
          ),
      ],
    );
  }

  /// Extremely robust cover renderer. It dynamically sizes itself to prevent off-screen controls.
  /// Uses a flawless Glass-Letterbox effect for wide thumbnails so they are never cropped.
  Widget _buildIntelligentCover(String imageUrl, Color dominantColor,
      {required bool isMobile, required BoxConstraints constraints}) {
    // Dynamically calculate size based on both width AND height to guarantee controls stay on screen.
    final double coverSize = isMobile
        ? (constraints.maxWidth * 0.70).clamp(200.0, 320.0)
        : math
            .min(constraints.maxWidth * 0.35, constraints.maxHeight * 0.45)
            .clamp(200.0, 420.0);

    return RepaintBoundary(
      child: Container(
        width: coverSize,
        height: coverSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.2), // Base fallback
          boxShadow: [
            BoxShadow(
                color: dominantColor.withValues(alpha: 0.35),
                blurRadius: 60,
                offset: const Offset(0, 20)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10)),
            BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, -1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageUrl.isEmpty
              ? Icon(MingCute.music_2_line,
                  size: coverSize * 0.3,
                  color: Colors.white.withValues(alpha: 0.3))
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Glass Background for Wide Thumbnails
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: LoadImageCached(
                          imageUrl: imageUrl, fit: BoxFit.cover),
                    ),
                    Container(
                        color: Colors.black
                            .withValues(alpha: 0.3)), // Darken letterbox

                    // The actual un-cropped Image
                    LoadImageCached(imageUrl: imageUrl, fit: BoxFit.contain),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfo(CurrentPlaylistState state, AppLocalizations l10n,
      {required bool isCentered}) {
    final creatorText = l10n.playlistByCreator(
        state.playlist.artists?.map((a) => a.name).join(', ') ??
            l10n.playlistYou);

    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          state.playlist.title,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.15,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.playlistSongCount(state.totalTracks),
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)
              .merge(Default_Theme.secondoryTextStyle),
        ),
        const SizedBox(height: 6),
        Text(
          creatorText,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 14)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ],
    );
  }

  /// Architected the 5-Button Layout: Symmetrical, Responsive, and Play-Centered.
  Widget _buildActions(CurrentPlaylistState state, Color fgColor, Color bgColor,
      {required bool isCentered}) {
    final isEmpty = state.playlist.tracks.isEmpty;
    final l10n = AppLocalizations.of(context)!;

    return RepaintBoundary(
      child: Wrap(
        alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 16,
        children: [
          // Left actions
          _buildActionIcon(
              MingCute.shuffle_line,
              l10n.playlistShuffle,
              isEmpty
                  ? null
                  : () => _playFromPlaylist(context, state, shuffle: true)),

          Builder(builder: (ctx) {
            final downloaded = ctx.watch<DownloaderCubit>().state.downloaded;
            final allDownloaded = !isEmpty &&
                state.playlist.tracks
                    .every((s) => downloaded.any((d) => d.id == s.id));
            if (allDownloaded) {
              return Tooltip(
                message: l10n.playlistAvailableOffline,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Default_Theme.accentColor2.withValues(alpha: 0.15)),
                  child: const Icon(Icons.offline_pin_rounded,
                      color: Default_Theme.accentColor2, size: 22),
                ),
              );
            }
            return _buildActionIcon(
                MingCute.download_2_fill,
                l10n.buttonDownload,
                isEmpty ? null : () => _handleDownload(context, state, l10n));
          }),

          // Center Big Play Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: StreamBuilder<String>(
                stream: context
                    .watch<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .queueTitle,
                builder: (context, snapshot) {
                  final isCurrent =
                      snapshot.hasData && snapshot.data == state.playlist.title;
                  return StreamBuilder<bool>(
                      stream: context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .engine
                          .playingStream,
                      builder: (context, playingSnapshot) {
                        final isPlaying =
                            isCurrent && (playingSnapshot.data ?? false);
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Default_Theme.accentColor2
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8)),
                            ],
                          ),
                          child: PlayPauseButton(
                            isPlaying: isPlaying,
                            size: 64,
                            onPlay: isEmpty
                                ? () {}
                                : () => isCurrent
                                    ? context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .play()
                                    : _playFromPlaylist(context, state),
                            onPause: () => context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .pause(),
                          ),
                        );
                      });
                }),
          ),

          // Right actions
          _buildActionIcon(
              MingCute.information_line,
              l10n.buttonInfo,
              () => showPlaylistInfo(context, state,
                  fgColor: fgColor, bgColor: bgColor)),
          _buildActionIcon(MingCute.more_2_line, l10n.buttonMore,
              () => showPlaylistOptsInrSheet(context, state.playlist)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String tooltip, VoidCallback? onTap) {
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
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon,
                color: Colors.white.withValues(alpha: 0.8), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackList(CurrentPlaylistState state) {
    final tracks = state.playlist.tracks;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final track = tracks[index];
          return AnimatedListItem(
            index: index,
            child: SongCardWidget(
              key: ValueKey(track.id),
              song: track,
              onTap: () => _playFromPlaylist(context, state, index: index),
              onOptionsTap: () => showMoreBottomSheet(
                context,
                track,
                onDelete: () => _removeTrack(context, track),
                showDelete: true,
                showSinglePlay: true,
              ),
            ),
          );
        },
        childCount: tracks.length,
        addRepaintBoundaries: true,
      ),
    );
  }

  void _removeTrack(BuildContext context, Track track) {
    final cubit = context.read<CurrentPlaylistCubit>();
    final l10n = AppLocalizations.of(context)!;
    cubit.removeTrack(track);
    SnackbarService.showMessage(
        l10n.playlistRemovedTrack(track.title, cubit.state.playlist.title));
  }

  Future<void> _handleDownload(BuildContext context, CurrentPlaylistState state,
      AppLocalizations l10n) async {
    final items =
        (await context.read<CurrentPlaylistCubit>().ensureAllTracksLoaded())
            .tracks;
    if (items.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        title: Text(l10n.dialogDownloadPlaylist,
            style: const TextStyle(color: Colors.white)),
        content: Text(
            l10n.dialogDownloadPlaylistMessage(
                items.length, state.playlist.title),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.buttonCancel,
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.7)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Default_Theme.accentColor2,
              foregroundColor: Default_Theme.primaryColor2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.dialogDownloadAll),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _showAddToDownloadProgress(context, items, l10n);
      SnackbarService.showMessage(l10n.snackbarSongsAddedToQueue(items.length));
    }
  }

  Future<void> _showAddToDownloadProgress(
      BuildContext context, List<Track> items, AppLocalizations l10n) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        int completed = 0;
        String currentTitle = '';
        void Function(void Function()) setStateRef = (_) {};

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          for (final song in items) {
            setStateRef(() => currentTitle = song.title);
            try {
              context
                  .read<DownloaderCubit>()
                  .downloadSong(song, showSnackbar: false);
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 100));
            setStateRef(() => completed++);
          }
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
        });

        return StatefulBuilder(
          builder: (sbCtx, sbSetState) {
            setStateRef = sbSetState;
            return AlertDialog(
              backgroundColor: Default_Theme.themeColor,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dialogAddingToDownloadQueue,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$completed/${items.length} items',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: items.isEmpty
                            ? 0
                            : (completed / items.length).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Default_Theme.accentColor2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(currentTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
