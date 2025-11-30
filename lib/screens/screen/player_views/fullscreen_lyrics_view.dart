import 'dart:async';
import 'dart:ui';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_bloc.dart';
import 'package:Bloomee/screens/screen/player_views/lyrics_menu.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
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

class _FullscreenLyricsViewState extends State<FullscreenLyricsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  final UpNextPanelController _upNextPanelController = UpNextPanelController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _startHideControlsTimer();
    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hideControlsTimer?.cancel();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
        _fadeController.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _fadeController.forward();
      _startHideControlsTimer();
    } else {
      _fadeController.reverse();
      _hideControlsTimer?.cancel();
    }
  }

  void _onInteraction() {
    if (!_showControls) {
      setState(() => _showControls = true);
      _fadeController.forward();
    }
    _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background with album art blur
            _buildBackground(bloomeePlayerCubit),

            // Gradient overlay
            _buildGradientOverlay(),

            // Main content with lyrics
            SafeArea(
              child: Column(
                children: [
                  // Top controls (back button, song info)
                  FadeTransition(
                    opacity: _fadeController,
                    child: _buildTopBar(bloomeePlayerCubit),
                  ),

                  // Lyrics area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BlocBuilder<LyricsCubit, LyricsState>(
                        builder: (context, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: switch (state) {
                              LyricsInitial() => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              LyricsLoaded() =>
                                state.lyrics.parsedLyrics != null
                                    ? FullscreenSyncedLyrics(
                                        state: state,
                                        onInteraction: _onInteraction,
                                      )
                                    : state.lyrics.lyricsPlain.isNotEmpty
                                        ? _buildPlainLyrics(state)
                                        : const SignBoardWidget(
                                            icon: MingCute.music_2_line,
                                            message: "No Lyrics Found",
                                          ),
                              LyricsError() => const SignBoardWidget(
                                  icon: MingCute.music_2_line,
                                  message: "No Lyrics Found",
                                ),
                              LyricsLoading() => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              LyricsState() => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom controls (play/pause, next, up next)
                  FadeTransition(
                    opacity: _fadeController,
                    child: _buildBottomControls(bloomeePlayerCubit),
                  ),
                ],
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
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: Container(
            key: ValueKey(snapshot.data?.artUri),
            decoration: BoxDecoration(
              image: snapshot.data?.artUri != null
                  ? DecorationImage(
                      image: NetworkImage(
                        formatImgURL(
                          snapshot.data!.artUri.toString(),
                          ImageQuality.low,
                        ),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.15, 0.85, 1.0],
        ),
      ),
    );
  }

  Widget _buildTopBar(BloomeePlayerCubit bloomeePlayerCubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          // Song info
          Expanded(
            child: StreamBuilder<MediaItem?>(
              stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.data?.title ?? "Unknown",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.data?.artist ?? "Unknown",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontFamily: 'NotoSans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),

          // Lyrics settings menu
          BlocBuilder<LyricsCubit, LyricsState>(
            builder: (context, state) {
              return LyricsMenu(state: state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlainLyrics(LyricsState state) {
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
          stops: [0.0, 0.08, 0.92, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            state.lyrics.lyricsPlain,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BloomeePlayerCubit bloomeePlayerCubit) {
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous button
              IconButton(
                onPressed: () => musicPlayer.skipToPrevious(),
                icon: const Icon(
                  MingCute.skip_previous_fill,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Play/Pause button
              BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
                builder: (context, state) {
                  bool isPlaying = false;
                  bool isBuffering = false;

                  if (state is MiniPlayerWorking) {
                    isPlaying = state.isPlaying;
                    isBuffering = state.isBuffering;
                  }

                  if (isBuffering) {
                    return Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Default_Theme.accentColor2,
                            spreadRadius: 1,
                            blurRadius: 20,
                          )
                        ],
                        shape: BoxShape.circle,
                        color: Default_Theme.accentColor2,
                      ),
                      width: 70,
                      height: 70,
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Default_Theme.primaryColor1,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    );
                  }

                  return PlayPauseButton(
                    size: 70,
                    onPause: () => musicPlayer.pause(),
                    onPlay: () => musicPlayer.play(),
                    isPlaying: isPlaying,
                  );
                },
              ),

              // Next button
              IconButton(
                onPressed: () => musicPlayer.skipToNext(),
                icon: const Icon(
                  MingCute.skip_forward_fill,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Up Next button
          GestureDetector(
            onTap: () {
              _upNextPanelController.toggle();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    MingCute.playlist_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Up Next",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized synced lyrics widget with smooth auto-scroll
class FullscreenSyncedLyrics extends StatefulWidget {
  final LyricsState state;
  final VoidCallback? onInteraction;

  const FullscreenSyncedLyrics({
    required this.state,
    this.onInteraction,
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
  Duration _currentPosition = Duration.zero;
  int _currentIndex = -1;
  int _lastScrolledIndex = -1;
  bool _userScrolling = false;
  Timer? _userScrollTimer;

  @override
  void initState() {
    super.initState();
    _setupPositionListener();
  }

  void _setupPositionListener() {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    _positionSubscription = bloomeePlayerCubit
        .bloomeePlayer.audioPlayer.positionStream
        .listen((position) {
      if (!mounted) return;

      _currentPosition = position;
      final newIndex = _findCurrentLyricIndex();

      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
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

  int _findCurrentLyricIndex() {
    final lyrics = widget.state.lyrics.parsedLyrics?.lyrics;
    if (lyrics == null || lyrics.isEmpty) return 0;

    // If position is before first lyric, return 0
    if (_currentPosition.inMilliseconds < lyrics[0].start.inMilliseconds) {
      return 0;
    }

    // If position is past the last lyric, return last index
    if (_currentPosition.inMilliseconds >= lyrics.last.start.inMilliseconds) {
      return lyrics.length - 1;
    }

    for (int i = 0; i < lyrics.length; i++) {
      final currentStart = lyrics[i].start.inMilliseconds;
      final nextStart = i + 1 < lyrics.length
          ? lyrics[i + 1].start.inMilliseconds
          : double.infinity;

      if (_currentPosition.inMilliseconds >= currentStart &&
          _currentPosition.inMilliseconds < nextStart) {
        return i;
      }
    }
    return lyrics.length - 1;
  }

  void _scrollToCurrentLyric() {
    if (_userScrolling) return;

    final lyrics = widget.state.lyrics.parsedLyrics?.lyrics;
    if (lyrics == null || lyrics.isEmpty) return;

    // Don't scroll again if we already scrolled to this index
    if (_currentIndex == _lastScrolledIndex) return;

    // Center the current lyric on screen
    if (_itemScrollController.isAttached && _currentIndex >= 0) {
      _lastScrolledIndex = _currentIndex;
      _itemScrollController.scrollTo(
        index: _currentIndex,
        alignment: 0.4, // Center vertically
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onUserScroll() {
    widget.onInteraction?.call();
    _userScrolling = true;
    _userScrollTimer?.cancel();
    _userScrollTimer = Timer(const Duration(seconds: 3), () {
      _userScrolling = false;
      _scrollToCurrentLyric();
    });
  }

  void _onLyricTap(int index) {
    widget.onInteraction?.call();
    // Seek to this lyric
    final lyric = widget.state.lyrics.parsedLyrics?.lyrics[index];
    if (lyric != null) {
      context.read<BloomeePlayerCubit>().bloomeePlayer.seek(lyric.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.state.lyrics.parsedLyrics?.lyrics ?? [];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _onUserScroll();
        }
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
            stops: [0.0, 0.15, 0.85, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: lyrics.length,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.3,
          ),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final isCurrentLine = index == _currentIndex;
            final isPastLine = index < _currentIndex;

            return GestureDetector(
              onTap: () => _onLyricTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  lyrics[index].text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'NotoSans',
                    fontWeight:
                        isCurrentLine ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrentLine
                        ? Colors.white
                        : isPastLine
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
