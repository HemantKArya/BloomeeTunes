import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/animated_seekbar.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:Bloomee/screens/screen/player_views/lyrics_widget.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';

class MusicReelsScreen extends StatefulWidget {
  final int previousIndex;
  const MusicReelsScreen({super.key, required this.previousIndex});

  @override
  State<MusicReelsScreen> createState() => _MusicReelsScreenState();
}

class _MusicReelsScreenState extends State<MusicReelsScreen> {
  late PageController _pageController;
  bool _isPageAnimating = false;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Optionally, jump to the current playing index on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BloomeePlayerCubit>();
      final idx = cubit.bloomeePlayer.currentPlayingIdx;
      if (idx != 0 && _pageController.hasClients) {
        _pageController.jumpToPage(idx);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Listen to player index changes and auto-scroll PageView
  void _listenToPlayerIndexChanges() {
    // We'll use StreamBuilder in the build method instead
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LyricsCubit(context.read<BloomeePlayerCubit>()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
          builder: (context, state) {
            final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
            final queue = player.queue.value;
            final currentIdx = player.currentPlayingIdx;
            if (queue.isEmpty) {
              return const Center(
                child: Text(
                  'No songs in queue',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return StreamBuilder<int>(
              stream: Stream.periodic(const Duration(milliseconds: 100),
                  (_) => player.currentPlayingIdx),
              builder: (context, snapshot) {
                final newIndex = snapshot.data ?? currentIdx;

                // Auto-scroll PageView when player index changes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      _pageController.hasClients &&
                      !_isPageAnimating) {
                    final currentPage = _pageController.page?.round() ?? 0;
                    if (currentPage != newIndex) {
                      _pageController.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                });

                return Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: queue.length,
                      onPageChanged: (index) async {
                        if (_isPageAnimating) return;
                        setState(() {
                          _isPageAnimating = true;
                        });
                        final player =
                            context.read<BloomeePlayerCubit>().bloomeePlayer;
                        if (index > player.currentPlayingIdx) {
                          await player.skipToNext();
                        } else if (index < player.currentPlayingIdx) {
                          await player.skipToPrevious();
                        }
                        setState(() {
                          _isPageAnimating = false;
                        });
                        HapticFeedback.lightImpact();
                      },
                      itemBuilder: (context, index) {
                        return MusicReelCard(
                          song: queue[index],
                          isActive: index == currentIdx,
                        );
                      },
                    ),
                    // Removed _ReelsLyricsWidget overlay here
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MusicReelCard extends StatefulWidget {
  final MediaItem song;
  final bool isActive;

  const MusicReelCard({
    super.key,
    required this.song,
    required this.isActive,
  });

  @override
  State<MusicReelCard> createState() => _MusicReelCardState();
}

class _MusicReelCardState extends State<MusicReelCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        LoadImageCached(
          imageUrl: formatImgURL(
            widget.song.artUri?.toString() ?? "",
            ImageQuality.high,
          ),
          fit: BoxFit.cover,
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // Content Overlay
        Positioned.fill(
          child: SafeArea(
            child: Column(
              children: [
                // Top Controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Default_Theme.accentColor2,
                          size: 28,
                        ),
                      ),
                      // Playlist icon for queue
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: UpNextPanel(
                                    panelController: PanelController()),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.queue_music,
                          color: Default_Theme.accentColor2,
                          size: 28,
                        ),
                        tooltip: 'Show Queue',
                      ),
                      Text(
                        "Bloomee Reels",
                        style: const TextStyle(
                          color: Default_Theme.accentColor2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showMoreBottomSheet(
                            context, mediaItem2MediaItemModel(widget.song)),
                        icon: const Icon(
                          Icons.more_vert,
                          color: Default_Theme.accentColor2,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Lyrics + Play/Pause + Song Info Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Lyrics (compact, left side, now taller)
                      Expanded(
                        flex: 3,
                        child: _ReelsDoubleLineLyricsWidget(song: widget.song),
                      ),
                      const SizedBox(width: 12),
                      // Play/Pause button (right side)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          StreamBuilder<bool>(
                            stream: context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .audioPlayer
                                .playingStream,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data ?? false;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  if (isPlaying) {
                                    context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .pause();
                                  } else {
                                    context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .play();
                                  }
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Default_Theme.accentColor1
                                        .withValues(alpha: 0.95),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Default_Theme.accentColor1
                                            .withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Song Info below lyrics/play
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.song.artist ?? "Unknown Artist",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Seekbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: StreamBuilder<Duration>(
                    stream: context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .audioPlayer
                        .positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = widget.song.duration ?? Duration.zero;
                      final buffered = Duration.zero;
                      return AnimatedWaveformSeekbar(
                        progress: position,
                        total: duration,
                        buffered: buffered,
                        onSeek: (duration) {
                          context
                              .read<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .seek(duration);
                        },
                        isPlaying: context
                            .watch<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .audioPlayer
                            .playing,
                        activeColor: Default_Theme.accentColor1,
                        inactiveColor: Colors.white.withValues(alpha: 0.3),
                        bufferedColor: Colors.white.withValues(alpha: 0.5),
                        height: 40,
                        waveformBars: 40,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Compact lyrics widget for reels: 3 lines, current highlighted, left aligned
class _ReelsCompactLyricsWidget extends StatelessWidget {
  final MediaItem song;
  const _ReelsCompactLyricsWidget({required this.song});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoading || state is LyricsInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (state is LyricsError ||
            (state.lyrics.lyricsPlain.isEmpty &&
                state.lyrics.parsedLyrics == null)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No Lyrics Found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          );
        }
        // Only show lyrics for the currently playing song
        final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
        final isCurrent =
            song.id == player.queue.value[player.currentPlayingIdx].id;
        if (!isCurrent) return const SizedBox.shrink();
        // Highlight current line (like full player)
        final lyricsList = state.lyrics.parsedLyrics != null
            ? state.lyrics.parsedLyrics!.lyrics
            : null;
        final plainLyrics = state.lyrics.lyricsPlain;
        if (lyricsList != null && lyricsList.isNotEmpty) {
          // Find current line
          final position = player.audioPlayer.position;
          int currentIdx = 0;
          for (int i = 0; i < lyricsList.length; i++) {
            if (lyricsList[i].start <= position) {
              currentIdx = i;
            } else {
              break;
            }
          }
          // Show 3 lines: previous, current, next
          final lines = <Widget>[];
          for (int i = (currentIdx - 1).clamp(0, lyricsList.length - 1);
              i <= (currentIdx + 1).clamp(0, lyricsList.length - 1);
              i++) {
            lines.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  lyricsList[i].text,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: i == currentIdx
                        ? Default_Theme.accentColor2
                        : Colors.white,
                    fontSize: i == currentIdx ? 16 : 14,
                    fontWeight:
                        i == currentIdx ? FontWeight.bold : FontWeight.w400,
                    fontFamily: 'NotoSans',
                    shadows: [
                      Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines,
          );
        } else if (plainLyrics.isNotEmpty) {
          // Show first 3 lines of plain lyrics
          final lines = plainLyrics
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .toList();
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              lines.length > 3 ? 3 : lines.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  lines[i],
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: i == 1 ? Default_Theme.accentColor2 : Colors.white,
                    fontSize: i == 1 ? 16 : 14,
                    fontWeight: i == 1 ? FontWeight.bold : FontWeight.w400,
                    fontFamily: 'NotoSans',
                    shadows: [
                      Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// Add new double-line lyrics widget for reels
class _ReelsDoubleLineLyricsWidget extends StatelessWidget {
  final MediaItem song;
  const _ReelsDoubleLineLyricsWidget({required this.song});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoading || state is LyricsInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (state is LyricsError ||
            (state.lyrics.lyricsPlain.isEmpty &&
                state.lyrics.parsedLyrics == null)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No Lyrics Found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          );
        }
        final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
        final isCurrent =
            song.id == player.queue.value[player.currentPlayingIdx].id;
        if (!isCurrent) return const SizedBox.shrink();
        return StreamBuilder<Duration>(
          stream: player.audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final lyricsList = state.lyrics.parsedLyrics != null
                ? state.lyrics.parsedLyrics!.lyrics.map((l) => l.text).toList()
                : null;
            final plainLyrics = state.lyrics.lyricsPlain;
            List<String> lines = [];
            if (lyricsList != null && lyricsList.isNotEmpty) {
              lines = lyricsList;
            } else if (plainLyrics.isNotEmpty) {
              lines = plainLyrics
                  .split('\n')
                  .where((l) => l.trim().isNotEmpty)
                  .toList();
            }
            // Find current index (for synced lyrics)
            int currentIdx = 0;
            if (lyricsList != null &&
                lyricsList.isNotEmpty &&
                state.lyrics.parsedLyrics != null) {
              final position = snapshot.data ?? Duration.zero;
              for (int i = 0;
                  i < state.lyrics.parsedLyrics!.lyrics.length;
                  i++) {
                if (state.lyrics.parsedLyrics!.lyrics[i].start <= position) {
                  currentIdx = i;
                } else {
                  break;
                }
              }
            }
            // Show 3 slots: previous, current, next (single line each)
            final slots = <Widget>[];
            for (int i = (currentIdx - 1).clamp(0, lines.length - 1);
                i <= (currentIdx + 1).clamp(0, lines.length - 1);
                i++) {
              slots.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    lines[i],
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: i == currentIdx
                          ? Default_Theme.accentColor2
                          : Colors.white,
                      fontSize: i == currentIdx ? 28 : 20,
                      fontWeight:
                          i == currentIdx ? FontWeight.bold : FontWeight.w600,
                      fontFamily: 'NotoSans',
                      height: 1.28,
                      shadows: [
                        Shadow(
                            blurRadius: 8,
                            color: Colors.black38,
                            offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: slots,
              ),
            );
          },
        );
      },
    );
  }
}
