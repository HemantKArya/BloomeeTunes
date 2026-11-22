import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rxdart/rxdart.dart';

import 'package:Bloomee/blocs/current_playlist/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/screens/widgets/animated_list_item.dart';
import 'package:Bloomee/screens/widgets/artwork_ambient_background.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/utils/load_image.dart';

part 'playlist_info_dialog.dart';

/// Height of one track row: [SongCardWidget] is 66 high plus 2 + 2 margin.
/// A fixed extent lets the list skip measuring every row.
const double _kTrackExtent = 70;

/// Width at which the header moves to a fixed side panel.
const double _kDesktopBreakpoint = 850;

/// A library playlist.
///
/// Performance notes:
/// * No live blur: the ambient background is blurred once into a small
///   texture ([ArtworkAmbientBackground]); image filters would otherwise be
///   re-applied on every scrolled frame.
/// * Rows have a fixed extent and learn which song is playing from a single
///   list-level listener, not one stream subscription per row.
/// * Header, background and list each rebuild only for their own data.
class PlaylistView extends StatefulWidget {
  final String? initialPlaylistName;

  const PlaylistView({super.key, this.initialPlaylistName});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final ScrollController _scrollController = ScrollController();
  bool _didTriggerInitialLoad = false;
  String? _targetPlaylistName;

  /// Id of the song being played; distinct, so metadata-only re-emits of the
  /// same song (duration, artwork) do not rebuild the list.
  late final Stream<String?> _currentTrackId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _currentTrackId = player.mediaItem.map((m) => m?.id).distinct();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didTriggerInitialLoad) return;
    final name = widget.initialPlaylistName?.trim().isNotEmpty == true
        ? widget.initialPlaylistName!
        : context.read<CurrentPlaylistCubit>().currentPlaylistName;
    if (name == null || name.trim().isEmpty) return;
    _didTriggerInitialLoad = true;
    _targetPlaylistName = name;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(name));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Data ────────────────────────────────────────────────────────────────

  Future<void> _load(String playlistName) async {
    if (!mounted) return;
    final cubit = context.read<CurrentPlaylistCubit>();
    // Header first (cheap); rows once the page transition has finished, so
    // building them never competes with the route animation.
    final settled = _routeSettled();
    await cubit.openPlaylist(playlistName, deferFirstPage: true);
    await settled;
    if (!mounted) return;
    await cubit.loadMoreTracks();
  }

  Future<void> _routeSettled() {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) return Future.value();
    final done = Completer<void>();
    void onStatus(AnimationStatus status) {
      if (status != AnimationStatus.completed) return;
      animation.removeStatusListener(onStatus);
      if (!done.isCompleted) done.complete();
    }

    animation.addStatusListener(onStatus);
    return done.future.timeout(const Duration(milliseconds: 600),
        onTimeout: () => animation.removeStatusListener(onStatus));
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.extentAfter < _kTrackExtent * 10) {
      context.read<CurrentPlaylistCubit>().loadMoreTracks();
    }
  }

  Future<Playlist?> _fullPlaylist() async {
    final full =
        await context.read<CurrentPlaylistCubit>().ensureAllTracksLoaded();
    if (!mounted || full.tracks.isEmpty) return null;
    return Playlist(tracks: full.tracks, title: full.title);
  }

  Future<void> _playAt(int index) async {
    final playlist = await _fullPlaylist();
    if (playlist == null || !mounted) return;
    await context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .loadPlaylist(playlist, idx: index, doPlay: true);
  }

  Future<void> _shuffle() async {
    final playlist = await _fullPlaylist();
    if (playlist == null || !mounted) return;
    await context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .loadPlaylist(playlist, doPlay: true, shuffling: true);
  }

  Future<void> _playOrResume() async {
    final playlist = await _fullPlaylist();
    if (playlist == null || !mounted) return;
    await context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .playOrResumePlaylist(playlist);
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

  static String _coverOf(CurrentPlaylistState state) {
    final tracks = state.playlist.tracks;
    if (tracks.isEmpty) return '';
    return tracks.first.thumbnail.urlHigh ?? tracks.first.thumbnail.url;
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          BlocSelector<CurrentPlaylistCubit, CurrentPlaylistState, String>(
            selector: _coverOf,
            builder: (context, cover) => _Backdrop(imageUrl: cover),
          ),
          BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
            buildWhen: (a, b) =>
                a.status != b.status ||
                a.playlist.title != b.playlist.title ||
                (a.playlist.tracks.isEmpty != b.playlist.tracks.isEmpty),
            builder: (context, state) {
              final target = _targetPlaylistName;
              final stale = target != null && state.playlist.title != target;
              if (!stale && state.status == CurrentPlaylistLoadStatus.error) {
                return Center(
                  child: SignBoardWidget(
                    message: state.errorMessage ??
                        AppLocalizations.of(context)!.playlistFailedToLoad,
                    icon: MingCute.alert_line,
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth < _kDesktopBreakpoint
                        ? _buildMobile(constraints)
                        : _buildDesktop(constraints),
              );
            },
          ),
        ],
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
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: math.max(340, constraints.maxWidth * 0.35),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 90, 20, 40),
            child: Center(
              child: _Header(
                targetName: _targetPlaylistName,
                // The cover takes whatever height is left, as a square.
                coverBuilder: (cover) => Flexible(
                  child: AspectRatio(aspectRatio: 1, child: cover),
                ),
                actions: _buildActions(),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 40, 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Default_Theme.themeColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Scrollbar(
                  controller: _scrollController,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      const SliverPadding(padding: EdgeInsets.only(top: 16)),
                      ..._trackSlivers(horizontalPadding: 12),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BoxConstraints constraints) {
    final coverSize = math.min(constraints.maxWidth * 0.62, 300.0);
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 96, 24, 24),
            child: _Header(
              targetName: _targetPlaylistName,
              coverBuilder: (cover) =>
                  SizedBox.square(dimension: coverSize, child: cover),
              actions: _buildActions(),
            ),
          ),
        ),
        ..._trackSlivers(horizontalPadding: 8),
        // Room for the mini player.
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  List<Widget> _trackSlivers({required double horizontalPadding}) {
    return [
      BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
        buildWhen: (a, b) =>
            !identical(a.playlist.tracks, b.playlist.tracks) ||
            a.status != b.status,
        builder: (context, state) {
          final tracks = state.playlist.tracks;
          final loading = state.status == CurrentPlaylistLoadStatus.initial ||
              state.status == CurrentPlaylistLoadStatus.loading ||
              (state.status == CurrentPlaylistLoadStatus.partial &&
                  tracks.isEmpty);
          if (tracks.isEmpty) {
            return SliverToBoxAdapter(
              child: loading
                  ? const _ListLoader()
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: SignBoardWidget(
                        message:
                            AppLocalizations.of(context)!.playlistEmptyState,
                        icon: MingCute.playlist_line,
                      ),
                    ),
            );
          }
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: StreamBuilder<String?>(
              stream: _currentTrackId,
              initialData: context
                  .read<BloomeePlayerCubit>()
                  .bloomeePlayer
                  .mediaItem
                  .valueOrNull
                  ?.id,
              builder: (context, snapshot) => SliverFixedExtentList(
                itemExtent: _kTrackExtent,
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = tracks[index];
                    return AnimatedListItem(
                      key: ValueKey(track.id),
                      index: index,
                      child: SongCardWidget(
                        index: index + 1,
                        song: track,
                        isCurrentTrack: snapshot.data == track.id,
                        onTap: () => _playAt(index),
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
                  findChildIndexCallback: (key) {
                    final id = (key as ValueKey<String>).value;
                    final i = tracks.indexWhere((t) => t.id == id);
                    return i < 0 ? null : i;
                  },
                ),
              ),
            ),
          );
        },
      ),
      BlocSelector<CurrentPlaylistCubit, CurrentPlaylistState, bool>(
        selector: (s) => s.playlist.tracks.isNotEmpty && s.hasMore,
        builder: (context, more) => SliverToBoxAdapter(
          child: more ? const _ListLoader() : const SizedBox.shrink(),
        ),
      ),
    ];
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<CurrentPlaylistCubit, CurrentPlaylistState,
        (String, bool)>(
      selector: (s) => (s.playlist.title, s.playlist.tracks.isEmpty),
      builder: (context, data) {
        final (title, isEmpty) = data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleIconButton(
              icon: MingCute.shuffle_line,
              tooltip: l10n.playlistShuffle,
              onTap: isEmpty ? null : _shuffle,
            ),
            const SizedBox(width: 12),
            _DownloadAction(
              onDownload: isEmpty ? null : () => _handleDownload(context, l10n),
            ),
            const SizedBox(width: 16),
            _PlaylistPlayButton(
              playlistTitle: title,
              enabled: !isEmpty,
              onPlay: _playOrResume,
            ),
            const SizedBox(width: 16),
            _CircleIconButton(
              icon: MingCute.information_line,
              tooltip: l10n.buttonInfo,
              onTap: () {
                final colors = _getOptimizedPalette(context);
                showPlaylistInfo(
                  context,
                  context.read<CurrentPlaylistCubit>().state,
                  fgColor: colors[0],
                  bgColor: colors[1],
                );
              },
            ),
            const SizedBox(width: 12),
            _CircleIconButton(
              icon: MingCute.more_2_line,
              tooltip: l10n.buttonMore,
              onTap: () => showPlaylistOptsInrSheet(
                  context, context.read<CurrentPlaylistCubit>().state.playlist),
            ),
          ],
        );
      },
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _removeTrack(BuildContext context, Track track) {
    final cubit = context.read<CurrentPlaylistCubit>();
    final l10n = AppLocalizations.of(context)!;
    cubit.removeTrack(track);
    SnackbarService.showMessage(
        l10n.playlistRemovedTrack(track.title, cubit.state.playlist.title));
  }

  Future<void> _handleDownload(
      BuildContext context, AppLocalizations l10n) async {
    final playlist =
        await context.read<CurrentPlaylistCubit>().ensureAllTracksLoaded();
    final items = playlist.tracks;
    if (items.isEmpty || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        title: Text(l10n.dialogDownloadPlaylist,
            style: const TextStyle(color: Colors.white)),
        content: Text(
            l10n.dialogDownloadPlaylistMessage(items.length, playlist.title),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.dialogDownloadAll,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _showAddToDownloadProgress(context, items, l10n);
      SnackbarService.showMessage(l10n.snackbarSongsAddedToQueue(items.length));
    }
  }

  Future<void> _showAddToDownloadProgress(
      BuildContext context, List<Track> items, AppLocalizations l10n) {
    final downloader = context.read<DownloaderCubit>();
    final progress = ValueNotifier<(int, String)>((0, ''));
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          for (var i = 0; i < items.length; i++) {
            progress.value = (i, items[i].title);
            try {
              downloader.downloadSong(items[i], showSnackbar: false);
            } catch (_) {}
            // Spread the work so the dialog keeps animating.
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          progress.value = (items.length, '');
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
        });
        return AlertDialog(
          backgroundColor: Default_Theme.themeColor,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          content: SizedBox(
            width: 320,
            child: ValueListenableBuilder<(int, String)>(
              valueListenable: progress,
              builder: (context, value, _) {
                final (done, title) = value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dialogAddingToDownloadQueue,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$done/${items.length} items',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (done / items.length).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Default_Theme.accentColor2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12)),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(progress.dispose);
  }
}

// ─── Pieces ──────────────────────────────────────────────────────────────────

/// Ambient artwork, blurred once into a texture, fading into the page colour
/// so the track list always sits on a calm, readable surface.
class _Backdrop extends StatelessWidget {
  final String imageUrl;
  const _Backdrop({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const ColoredBox(color: Default_Theme.themeColor);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ArtworkAmbientBackground(imageUrl: imageUrl),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Default_Theme.themeColor.withValues(alpha: 0),
                  Default_Theme.themeColor.withValues(alpha: 0.7),
                  Default_Theme.themeColor,
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Cover, title, counts and actions. Rebuilds only when its own data
/// (title, cover, size, creator) changes, never while pages load.
class _Header extends StatelessWidget {
  final String? targetName;
  final Widget Function(Widget cover) coverBuilder;
  final Widget actions;

  const _Header({
    required this.targetName,
    required this.coverBuilder,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocSelector<CurrentPlaylistCubit, CurrentPlaylistState,
        (String, String, int, String?)>(
      selector: (s) {
        final stale = targetName != null && s.playlist.title != targetName;
        return (
          stale ? targetName! : s.playlist.title,
          stale ? '' : _PlaylistViewState._coverOf(s),
          stale ? 0 : s.totalTracks,
          stale ? null : s.playlist.artists?.map((a) => a.name).join(', '),
        );
      },
      builder: (context, data) {
        final (title, cover, count, creators) = data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            coverBuilder(_Cover(imageUrl: cover)),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.96),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.playlistSongCount(count)}  ·  '
              '${l10n.playlistByCreator(creators ?? l10n.playlistYou)}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            FittedBox(fit: BoxFit.scaleDown, child: actions),
          ],
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  final String imageUrl;
  const _Cover({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: imageUrl.isEmpty
              ? Center(
                  child: Icon(MingCute.music_2_line,
                      size: 56, color: Colors.white.withValues(alpha: 0.25)),
                )
              : LoadImageCached(imageUrl: imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// Play/pause locked to this playlist: shows "pause" only while this
/// playlist is the playing queue; pressing play resumes it if it is already
/// queued, otherwise loads it (see BloomeeMusicPlayer.playOrResumePlaylist).
class _PlaylistPlayButton extends StatefulWidget {
  final String playlistTitle;
  final bool enabled;
  final Future<void> Function() onPlay;

  const _PlaylistPlayButton({
    required this.playlistTitle,
    required this.enabled,
    required this.onPlay,
  });

  @override
  State<_PlaylistPlayButton> createState() => _PlaylistPlayButtonState();
}

class _PlaylistPlayButtonState extends State<_PlaylistPlayButton> {
  late final Stream<(String, bool)> _queueState;

  @override
  void initState() {
    super.initState();
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    _queueState = Rx.combineLatest2(
      player.queueTitle,
      player.engine.playingStream,
      (String title, bool playing) => (title, playing),
    ).distinct();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<(String, bool)>(
      stream: _queueState,
      builder: (context, snapshot) {
        final (title, playing) = snapshot.data ?? ('', false);
        final isPlaying = playing && title == widget.playlistTitle;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Default_Theme.accentColor2.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: PlayPauseButton(
            isPlaying: isPlaying,
            size: 60,
            onPlay: widget.enabled ? () => widget.onPlay() : () {},
            onPause: () =>
                context.read<BloomeePlayerCubit>().bloomeePlayer.pause(),
          ),
        );
      },
    );
  }
}

/// Download button, or an "available offline" badge once every song of the
/// playlist is downloaded. Rebuilds only when that answer changes.
class _DownloadAction extends StatelessWidget {
  final VoidCallback? onDownload;
  const _DownloadAction({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tracks = context.select<CurrentPlaylistCubit, List<Track>>(
        (c) => c.state.playlist.tracks);
    return BlocSelector<DownloaderCubit, DownloaderState, bool>(
      selector: (state) {
        if (tracks.isEmpty) return false;
        final downloaded = {for (final d in state.downloaded) d.id};
        return tracks.every((t) => downloaded.contains(t.id));
      },
      builder: (context, allDownloaded) {
        if (!allDownloaded) {
          return _CircleIconButton(
            icon: MingCute.download_2_fill,
            tooltip: l10n.buttonDownload,
            onTap: onDownload,
          );
        }
        return Tooltip(
          message: l10n.playlistAvailableOffline,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Default_Theme.accentColor2.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.offline_pin_rounded,
                color: Default_Theme.accentColor2, size: 20),
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        shape: CircleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon,
                size: 20,
                color: Colors.white.withValues(alpha: enabled ? 0.85 : 0.3)),
          ),
        ),
      ),
    );
  }
}

class _ListLoader extends StatelessWidget {
  const _ListLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Default_Theme.accentColor2),
        ),
      ),
    );
  }
}
