import 'dart:async';
import 'dart:ui';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/screens/screen/player_views/lyrics_search.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FullscreenLyricsView extends StatefulWidget {
  const FullscreenLyricsView({super.key});

  @override
  State<FullscreenLyricsView> createState() => _FullscreenLyricsViewState();
}

class _FullscreenLyricsViewState extends State<FullscreenLyricsView> {
  bool _showControls = true;
  Timer? _hideControlsTimer;
  final UpNextPanelController _upNextPanelController = UpNextPanelController();

  Duration _lyricOffset = Duration.zero;
  bool _isSyncMode = false;
  Timer? _holdTimer;

  final ValueNotifier<Duration> _positionNotifier =
      ValueNotifier(Duration.zero);
  StreamSubscription<MediaItem?>? _mediaItemSubscription;
  String? _currentTrackId;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final playerCubit = context.read<BloomeePlayerCubit>();
    _currentTrackId = playerCubit.bloomeePlayer.currentTrackInfo.id;

    _mediaItemSubscription =
        playerCubit.bloomeePlayer.mediaItem.listen((mediaItem) {
      if (mediaItem != null && mediaItem.id != _currentTrackId) {
        if (mounted) {
          setState(() {
            _currentTrackId = mediaItem.id;
            _lyricOffset = Duration.zero;
            _isSyncMode = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _hideControlsTimer?.cancel();
    _mediaItemSubscription?.cancel();
    _positionNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls && !_isSyncMode) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _onInteraction() {
    if (!_showControls) setState(() => _showControls = true);
    _startHideControlsTimer();
  }

  void _startOffsetChange(int ms) {
    setState(() => _lyricOffset += Duration(milliseconds: ms));
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _lyricOffset += Duration(milliseconds: ms));
    });
  }

  void _stopOffsetChange() => _holdTimer?.cancel();

  void _openSettingsMenu(LyricsState state, BloomeePlayerCubit playerCubit) {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LyricsSettingsBottomSheet(
        state: state,
        onSyncTap: () {
          Navigator.pop(context);
          setState(() {
            _isSyncMode = true;
            _showControls = true;
          });
        },
      ),
    ).then((_) => _startHideControlsTimer());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            _buildBackground(bloomeePlayerCubit),
            Container(color: Colors.black.withValues(alpha: 0.4)),
            Positioned.fill(
              child: BlocBuilder<LyricsCubit, LyricsState>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: switch (state) {
                      LyricsInitial() => const Center(
                          child: CircularProgressIndicator(
                              color: Default_Theme.accentColor2)),
                      LyricsLoading() => const Center(
                          child: CircularProgressIndicator(
                              color: Default_Theme.accentColor2)),
                      LyricsLoaded() => state.lyrics.parsedLyrics != null
                          ? FullscreenSyncedLyrics(
                              state: state,
                              positionNotifier: _positionNotifier,
                              lyricOffset: _lyricOffset,
                              onInteraction: _onInteraction,
                              isDesktop: isDesktop,
                            )
                          : state.lyrics.lyricsPlain.isNotEmpty
                              ? _buildPlainLyrics(state, isDesktop)
                              : SignBoardWidget(
                                  icon: MingCute.music_2_line,
                                  message: l10n.playerNoLyricsFound),
                      LyricsError() => SignBoardWidget(
                          icon: MingCute.music_2_line,
                          message: l10n.playerNoLyricsFound),
                      LyricsState() => const SizedBox.shrink(),
                    },
                  );
                },
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              top: _showControls ? 0 : -150,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: _buildTopBar(bloomeePlayerCubit, isDesktop),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              bottom: _showControls ? 0 : -200,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: _buildBottomControls(bloomeePlayerCubit, isDesktop),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              bottom: _isSyncMode
                  ? (_showControls
                      ? (isDesktop ? 220 : 250)
                      : (isDesktop ? 80 : 100))
                  : -100,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: _buildSyncControls(),
              ),
            ),
            UpNextPanel(
              controller: _upNextPanelController,
              peekHeight: 60,
              parentHeight: MediaQuery.of(context).size.height,
              canBeHidden: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BloomeePlayerCubit bloomeePlayerCubit) {
    return StreamBuilder<MediaItem?>(
      stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
      builder: (context, snapshot) {
        final currentTrack = bloomeePlayerCubit.bloomeePlayer.currentTrackInfo;
        final artworkUrl =
            currentTrack.thumbnail.urlLow ?? currentTrack.thumbnail.url;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: Container(
            key: ValueKey(snapshot.data?.id),
            decoration: BoxDecoration(
              image: artworkUrl.isNotEmpty
                  ? DecorationImage(
                      image: getImageProviderSync(artworkUrl,
                          fallbackUrl: currentTrack.thumbnail.url),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BloomeePlayerCubit bloomeePlayerCubit, bool isDesktop) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 16, 16, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<MediaItem?>(
                  stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
                  builder: (context, snapshot) {
                    final currentTrack =
                        bloomeePlayerCubit.bloomeePlayer.currentTrackInfo;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentTrack.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 22 : 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'NotoSans'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        TrackMetadataLinks(
                          track: currentTrack,
                          showAlbum: currentTrack.album != null,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isDesktop ? 15 : 13,
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              BlocBuilder<LyricsCubit, LyricsState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () =>
                        _openSettingsMenu(state, bloomeePlayerCubit),
                    icon: const Icon(MingCute.more_2_fill,
                        color: Colors.white, size: 28),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncControls() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _startOffsetChange(-50),
                    onTapUp: (_) => _stopOffsetChange(),
                    onTapCancel: () => _stopOffsetChange(),
                    child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(MingCute.minus_circle_fill,
                            color: Colors.white, size: 28)),
                  ),
                  InkWell(
                    onTap: () => setState(() => _lyricOffset = Duration.zero),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_lyricOffset.inMilliseconds > 0 ? '+' : ''}${_lyricOffset.inMilliseconds}ms",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(l10n.lyricsSyncTapToReset.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => _startOffsetChange(50),
                    onTapUp: (_) => _stopOffsetChange(),
                    onTapCancel: () => _stopOffsetChange(),
                    child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(MingCute.add_circle_fill,
                            color: Colors.white, size: 28)),
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: Colors.white.withValues(alpha: 0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 12)),
                  IconButton(
                    icon: const Icon(MingCute.close_fill,
                        color: Colors.white, size: 24),
                    onPressed: () {
                      setState(() => _isSyncMode = false);
                      _startHideControlsTimer();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(
      BloomeePlayerCubit bloomeePlayerCubit, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 40, 24, paddingBottom > 0 ? paddingBottom : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => musicPlayer.skipToPrevious(),
                    icon: const Icon(MingCute.skip_previous_fill,
                        color: Colors.white),
                    iconSize: isDesktop ? 40 : 36,
                  ),
                  const SizedBox(width: 32),
                  BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
                    builder: (context, state) {
                      return PlayPauseButton(
                        size: isDesktop ? 80 : 70,
                        onPause: () => musicPlayer.pause(),
                        onPlay: () => musicPlayer.play(),
                        isPlaying: state.isPlaying,
                      );
                    },
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: () => musicPlayer.skipToNext(),
                    icon: const Icon(MingCute.skip_forward_fill,
                        color: Colors.white),
                    iconSize: isDesktop ? 40 : 36,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _upNextPanelController.toggle(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(MingCute.playlist_fill,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.upNextTitle,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlainLyrics(LyricsState state, bool isDesktop) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent
          ],
          stops: [0.0, 0.2, 0.8, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.35,
            horizontal: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              state.lyrics.lyricsPlain,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isDesktop ? 26 : 22,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.8),
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenSyncedLyrics extends StatefulWidget {
  final LyricsState state;
  final ValueNotifier<Duration> positionNotifier;
  final Duration lyricOffset;
  final VoidCallback? onInteraction;
  final bool isDesktop;

  const FullscreenSyncedLyrics({
    required this.state,
    required this.positionNotifier,
    required this.lyricOffset,
    this.onInteraction,
    this.isDesktop = false,
    super.key,
  });

  @override
  State<FullscreenSyncedLyrics> createState() => _FullscreenSyncedLyricsState();
}

class _FullscreenSyncedLyricsState extends State<FullscreenSyncedLyrics> {
  StreamSubscription? _positionSubscription;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int _currentIndex = -1;
  bool _userScrolling = false;
  Timer? _userScrollTimer;

  @override
  void initState() {
    super.initState();
    _setupPositionListener();
  }

  @override
  void didUpdateWidget(FullscreenSyncedLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyricOffset != widget.lyricOffset) _forceSyncRecalculation();
  }

  void _forceSyncRecalculation() {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer.engine;
    final adjustedPosition = player.position + widget.lyricOffset;
    widget.positionNotifier.value = adjustedPosition;

    final newIndex = _findCurrentLyricIndex(adjustedPosition);
    if (newIndex != _currentIndex && newIndex != -1) {
      setState(() => _currentIndex = newIndex);
      _scrollToCurrentLyric();
    }
  }

  void _setupPositionListener() {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    _positionSubscription = bloomeePlayerCubit
        .bloomeePlayer.engine.positionStream
        .listen((rawPosition) {
      if (!mounted) return;
      final adjustedPosition = rawPosition + widget.lyricOffset;
      widget.positionNotifier.value = adjustedPosition;

      final newIndex = _findCurrentLyricIndex(adjustedPosition);
      if (newIndex != _currentIndex && newIndex != -1) {
        setState(() => _currentIndex = newIndex);
        _scrollToCurrentLyric();
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _userScrollTimer?.cancel();
    super.dispose();
  }

  int _findCurrentLyricIndex(Duration currentPosition) {
    final lyrics = widget.state.lyrics.parsedLyrics?.lyrics;
    if (lyrics == null || lyrics.isEmpty) return 0;
    if (currentPosition < lyrics[0].start) return 0;
    if (currentPosition >= lyrics.last.start) return lyrics.length - 1;
    for (int i = 0; i < lyrics.length; i++) {
      final nextStart =
          i + 1 < lyrics.length ? lyrics[i + 1].start : const Duration(days: 1);
      if (currentPosition >= lyrics[i].start && currentPosition < nextStart)
        return i;
    }
    return lyrics.length - 1;
  }

  void _scrollToCurrentLyric() {
    if (_userScrolling) return;
    if (_itemScrollController.isAttached && _currentIndex >= 0) {
      _itemScrollController.scrollTo(
          index: _currentIndex,
          alignment: 0.4,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart);
    }
  }

  void _onUserScroll() {
    widget.onInteraction?.call();
    _userScrolling = true;
    _userScrollTimer?.cancel();
    _userScrollTimer = Timer(const Duration(seconds: 4), () {
      _userScrolling = false;
      _scrollToCurrentLyric();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.state.lyrics.parsedLyrics?.lyrics ?? [];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) _onUserScroll();
        return false;
      },
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent
            ],
            stops: [0.0, 0.25, 0.75, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: lyrics.length,
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.4,
              horizontal: widget.isDesktop ? 64 : 24),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (context, index) {
            final isCurrentLine = index == _currentIndex;
            final isPastLine = index < _currentIndex;
            final lyric = lyrics[index];
            final nextStart = index + 1 < lyrics.length
                ? lyrics[index + 1].start
                : lyric.start + const Duration(seconds: 5);

            return GestureDetector(
              onTap: () {
                widget.onInteraction?.call();
                context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .seek(lyric.start - widget.lyricOffset);
              },
              child: _KaraokeLyricLine(
                text: lyric.text,
                startTime: lyric.start,
                endTime: nextStart,
                isActive: isCurrentLine,
                isPast: isPastLine,
                positionNotifier: widget.positionNotifier,
                isDesktop: widget.isDesktop,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KaraokeLyricLine extends StatelessWidget {
  final String text;
  final Duration startTime;
  final Duration endTime;
  final bool isActive;
  final bool isPast;
  final ValueNotifier<Duration> positionNotifier;
  final bool isDesktop;

  const _KaraokeLyricLine(
      {required this.text,
      required this.startTime,
      required this.endTime,
      required this.isActive,
      required this.isPast,
      required this.positionNotifier,
      required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontSize: isDesktop ? 32 : 28,
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w800,
        height: 1.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1.0 : (isPast ? 0.25 : 0.4),
            child: isActive
                ? ValueListenableBuilder<Duration>(
                    valueListenable: positionNotifier,
                    builder: (context, currentPosition, child) {
                      final elapsed = currentPosition.inMilliseconds -
                          startTime.inMilliseconds;
                      final total =
                          endTime.inMilliseconds - startTime.inMilliseconds;
                      final double progress =
                          total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;

                      return ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.35)
                            ],
                            stops: [progress, progress],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(text,
                            textAlign: TextAlign.center, style: textStyle),
                      );
                    },
                  )
                : Text(text,
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _LyricsSettingsBottomSheet extends StatelessWidget {
  final LyricsState state;
  final VoidCallback onSyncTap;

  const _LyricsSettingsBottomSheet(
      {required this.state, required this.onSyncTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151515).withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 32),
            _buildMenuItem(
              icon: MingCute.search_2_line,
              title: l10n.lyricsSettingsSearchTitle,
              subtitle: l10n.lyricsSettingsSearchSubtitle,
              onTap: () {
                Navigator.pop(context);
                showSearch(
                  context: context,
                  delegate: LyricsSearchDelegate(
                    mediaID: state.track.id,
                    searchFieldLabelText: l10n.lyricsSearchFieldLabel,
                  ),
                  query:
                      "${state.track.title} ${state.track.artists.map((a) => a.name).join(', ')}",
                );
              },
            ),
            _buildMenuItem(
              icon: MingCute.time_line,
              title: l10n.lyricsSettingsSyncTitle,
              subtitle: l10n.lyricsSettingsSyncSubtitle,
              color: Default_Theme.accentColor2,
              onTap: onSyncTap,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white12)),
            _buildMenuItem(
              icon: MingCute.save_2_line,
              title: l10n.lyricsSettingsSaveTitle,
              subtitle: l10n.lyricsSettingsSaveSubtitle,
              onTap: () {
                context
                    .read<LyricsCubit>()
                    .setLyricsToDB(state.lyrics, state.track.id);
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              icon: MingCute.delete_3_line,
              title: l10n.lyricsSettingsDeleteTitle,
              subtitle: l10n.lyricsSettingsDeleteSubtitle,
              color: const Color(0xFFFF5252),
              onTap: () {
                context.read<LyricsCubit>().deleteLyricsFromDB(state.track);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13)),
                ],
              ),
            ),
            Icon(MingCute.right_line,
                color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
