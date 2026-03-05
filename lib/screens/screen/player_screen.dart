import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/screen/player_views/equalizer_view.dart';
import 'package:Bloomee/screens/widgets/gradient_progress_bar.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/screens/widgets/volume_slider.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/utils/pallete_generator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../blocs/media_player/bloomee_player_cubit.dart';
import '../../blocs/mini_player/mini_player_cubit.dart';
import 'player_views/fullscreen_lyrics_view.dart';
import 'player_views/lyrics_widget.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UpNextPanelController _upNextPanelController = UpNextPanelController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlayerOverlayCubit>().registerUpNextPanelCollapse(
              () => _upNextPanelController.collapse(),
            );
      }
    });
  }

  @override
  void dispose() {
    context.read<PlayerOverlayCubit>().unregisterUpNextPanelCollapse();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 4, 9),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () {
            if (!_upNextPanelController.collapse()) {
              context.read<PlayerOverlayCubit>().hidePlayer();
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () =>
                showMoreBottomSheet(context, musicPlayer.currentMedia),
            icon: const Icon(MingCute.more_2_fill,
                size: 25, color: Default_Theme.primaryColor1),
          )
        ],
        title: Column(
          children: [
            Text(
              'Enjoying From',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ).merge(Default_Theme.secondoryTextStyle),
            ),
            StreamBuilder<String>(
              stream: musicPlayer.queueTitle,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? "Unknown",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyle),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: isMobile
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    alignment: Alignment.bottomCenter, // Strictly ground the UI
                    children: [
                      Positioned.fill(
                        child: _PlayerUI(
                          musicPlayer: musicPlayer,
                          tabController: _tabController,
                        ),
                      ),
                      UpNextPanel(
                        peekHeight: 60.0,
                        parentHeight: constraints.maxHeight,
                        controller: _upNextPanelController,
                      ),
                    ],
                  );
                },
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 400,
                      maxWidth: MediaQuery.of(context).size.width * 0.60,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _PlayerUI(
                        musicPlayer: musicPlayer,
                        tabController: _tabController,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: UpNextPanel(
                          peekHeight: 60,
                          parentHeight:
                              MediaQuery.of(context).size.height * 0.8,
                          isDesktopMode: true,
                          controller: _upNextPanelController,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class _PlayerUI extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  final TabController tabController;

  const _PlayerUI({
    required this.musicPlayer,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: tabController.animation!,
            builder: (context, child) {
              return Opacity(
                opacity: (1 - tabController.animation!.value),
                child: child,
              );
            },
            child: const AmbientImgShadowWidget(),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 60), // Space for AppBar

              // EXPANDED allows artwork to claim 100% of available space securely
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TabBarView(
                    controller: tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const CoverImageVolSlider(),
                      const LyricsWidget(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PlayerCtrlWidgets(musicPlayer: musicPlayer),
              ),

              // Reserve exact space for the grounded UpNextPanel so buttons are never hidden
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class CoverImageVolSlider extends StatelessWidget {
  const CoverImageVolSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();

    return VolumeDragController(
      child: StreamBuilder<MediaItem?>(
        stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
        builder: (context, snapshot) {
          final currentTrack =
              bloomeePlayerCubit.bloomeePlayer.currentTrackInfo;
          final highResUrl =
              currentTrack.thumbnail.urlHigh ?? currentTrack.thumbnail.url;
          final lowResUrl =
              currentTrack.thumbnail.urlLow ?? currentTrack.thumbnail.url;

          // SizedBox.expand forces image to grow perfectly to maximum available bounds
          return SizedBox.expand(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LoadImageCached(
                  imageUrl: highResUrl,
                  fallbackUrl: lowResUrl,
                  // Contain natively formats YouTube Wide (16:9) AND Album Square (1:1) perfectly
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  const PlayerCtrlWidgets({super.key, required this.musicPlayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SongInfoRow(),
        const SizedBox(height: 15),
        const _PlayerProgressBar(),
        const SizedBox(height: 25),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _PlayerControlsRow(musicPlayer: musicPlayer),
        ),
      ],
    );
  }
}

class _SongInfoRow extends StatelessWidget {
  const _SongInfoRow();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<MediaItem?>(
            stream: player.mediaItem,
            builder: (context, snapshot) {
              final mediaItem = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaItem?.title ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Default_Theme.secondoryTextStyle.merge(const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Default_Theme.primaryColor1,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mediaItem?.artist ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const _DownloadButton(),
        const _LikeButton(),
      ],
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return Tooltip(
      message: "Available Offline",
      child: StreamBuilder<MediaItem?>(
        stream: player.mediaItem,
        builder: (context, mediaSnapshot) {
          final currentMedia = mediaSnapshot.data;
          if (currentMedia == null) return const SizedBox.shrink();
          return FutureBuilder(
            future: context
                .read<DownloaderCubit>()
                .getDownloadInfo(mediaItemToTrack(currentMedia)),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  iconSize: 25,
                  icon: Icon(
                    Icons.offline_pin_rounded,
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                  ),
                  onPressed: () {},
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return BlocBuilder<LibraryItemsCubit, LibraryItemsState>(
      builder: (context, _) {
        return StreamBuilder<MediaItem?>(
          stream: player.mediaItem,
          builder: (context, mediaSnapshot) {
            final currentMedia = mediaSnapshot.data;
            if (currentMedia == null) return const SizedBox.shrink();

            return FutureBuilder<bool>(
              future: context
                  .read<LibraryItemsCubit>()
                  .isTrackLiked(mediaItemToTrack(currentMedia)),
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;
                return StreamBuilder<bool>(
                  stream: player.engine.playingStream,
                  builder: (context, playingSnapshot) {
                    final isPlaying = playingSnapshot.data ?? false;
                    return LikeBtnWidget(
                      isPlaying: isPlaying,
                      isLiked: isLiked,
                      iconSize: 25,
                      onLiked: () {
                        context.read<LibraryItemsCubit>().setTrackLiked(
                            mediaItemToTrack(currentMedia), true);
                        SnackbarService.showMessage(
                            "${currentMedia.title} is Liked!!");
                      },
                      onDisliked: () {
                        context.read<LibraryItemsCubit>().setTrackLiked(
                            mediaItemToTrack(currentMedia), false);
                        SnackbarService.showMessage(
                            "${currentMedia.title} is Unliked!!");
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    return RepaintBoundary(
      child: StreamBuilder<ProgressBarStreams>(
        stream: playerCubit.progressStreams,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return GradientProgressBar.fromAccentColors(
            progress: data?.position ?? Duration.zero,
            total: data?.duration ?? Duration.zero,
            buffered: data?.buffered ?? Duration.zero,
            onSeek: playerCubit.bloomeePlayer.seek,
            isPlaying: data?.isPlaying ?? false,
            activeAccentColor: Default_Theme.accentColor1,
            inactiveAccentColor: Default_Theme.accentColor2,
            activeGradientStyle: GradientStyle.lightAndBreezy,
            inactiveGradientStyle: GradientStyle.warmAndRich,
            trackHeight: 6.0,
            thumbRadius: 8.0,
            timeLabelPadding: 5,
            timeLabelStyle: Default_Theme.secondoryTextStyle.merge(TextStyle(
              fontSize: 15,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
            )),
            timeLabelLocation: TimeLabelLocation.above,
            inactiveTrackColor:
                Default_Theme.primaryColor2.withValues(alpha: 0.1),
            animationDuration: const Duration(milliseconds: 200),
            animationCurve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _PlayerControlsRow extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  const _PlayerControlsRow({required this.musicPlayer});

  Widget _buildControlColumn({required Widget top, required Widget bottom}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fixed Top Height ensures perfectly horizontal snapping alignment
        Container(height: 70, alignment: Alignment.center, child: top),
        SizedBox(height: 40, child: bottom),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Ensures flush horizontal grid
      children: [
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.alarm_1_line,
                color: Default_Theme.primaryColor1, size: 28),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimerView())),
          ),
          bottom: const _LoopControl(),
        ),
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.skip_previous_fill,
                color: Default_Theme.primaryColor1, size: 35),
            onPressed: musicPlayer.skipToPrevious,
          ),
          bottom: IconButton(
            icon: const Icon(MingCute.music_2_line,
                color: Default_Theme.primaryColor1, size: 24),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FullscreenLyricsView(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 300),
              ));
            },
          ),
        ),
        _buildControlColumn(
          top:
              const _PlayPauseButton(), // Perfectly integrated into the alignment matrix
          bottom: const SizedBox(height: 40),
        ),
        _buildControlColumn(
          top: IconButton(
            icon: const Icon(MingCute.skip_forward_fill,
                color: Default_Theme.primaryColor1, size: 35),
            onPressed: musicPlayer.skipToNext,
          ),
          bottom: IconButton(
            icon: const Icon(Icons.equalizer_rounded,
                color: Default_Theme.primaryColor1, size: 24),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EqualizerView())),
          ),
        ),
        _buildControlColumn(
          top: const _ShuffleControl(),
          bottom: const _ExternalLinkControl(),
        ),
      ],
    );
  }
}

class _LoopControl extends StatelessWidget {
  const _LoopControl();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoopMode>(
      stream: context.read<BloomeePlayerCubit>().bloomeePlayer.loopMode,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        return PopupMenuButton(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 0, child: Text("Off")),
            PopupMenuItem(value: 1, child: Text("Loop One")),
            PopupMenuItem(value: 2, child: Text("Loop All")),
          ],
          child: Icon(
            loopMode == LoopMode.off
                ? MingCute.repeat_line
                : loopMode == LoopMode.one
                    ? MingCute.repeat_one_line
                    : MingCute.repeat_fill,
            color: loopMode == LoopMode.off
                ? Default_Theme.primaryColor1
                : Default_Theme.accentColor1,
            size: 24,
          ),
          onSelected: (value) {
            final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
            if (value == 0) player.setLoopMode(LoopMode.off);
            if (value == 1) player.setLoopMode(LoopMode.one);
            if (value == 2) player.setLoopMode(LoopMode.all);
          },
        );
      },
    );
  }
}

class _ShuffleControl extends StatelessWidget {
  const _ShuffleControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return StreamBuilder<bool>(
      stream: player.shuffleMode,
      builder: (context, snapshot) {
        final isShuffle = snapshot.data ?? false;
        return IconButton(
          icon: Icon(
            MingCute.shuffle_2_fill,
            color: isShuffle
                ? Default_Theme.accentColor1
                : Default_Theme.primaryColor1,
            size: 28,
          ),
          onPressed: () => player.shuffle(!isShuffle),
        );
      },
    );
  }
}

class _ExternalLinkControl extends StatelessWidget {
  const _ExternalLinkControl();

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return IconButton(
      icon: StreamBuilder<MediaItem?>(
        stream: player.mediaItem,
        builder: (context, snapshot) {
          final extras = snapshot.data?.extras;
          if (extras != null && extras['perma_url'] != null) {
            return extras['source'] == 'youtube'
                ? const Icon(MingCute.youtube_fill,
                    color: Default_Theme.primaryColor1, size: 24)
                : const Text("JS",
                    style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.bold));
          }
          return const Icon(MingCute.external_link_line,
              color: Default_Theme.primaryColor1, size: 24);
        },
      ),
      onPressed: () async {
        final url = player.mediaItem.valueOrNull?.extras?['perma_url'];
        if (url != null && await canLaunchUrlString(url)) {
          await launchUrlString(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to open the link")));
        }
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    final musicPlayer = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        Widget child;
        Color buttonColor = Default_Theme.accentColor2;

        if (state.isLoading) {
          child = const CircularProgressIndicator(
              color: Default_Theme.primaryColor1);
          buttonColor = state.isPlaying
              ? Default_Theme.accentColor1
              : Default_Theme.accentColor2;
        } else if (state.isCompleted) {
          child = const Icon(FontAwesome.rotate_right_solid,
              color: Default_Theme.primaryColor1, size: 32);
          buttonColor = Default_Theme.accentColor1;
        } else if (state.hasError) {
          child = const Icon(MingCute.warning_line,
              color: Default_Theme.primaryColor1, size: 32);
        } else if (state.isVisible) {
          return PlayPauseButton(
            size: 70, // Resized to perfectly match and feel proportional
            onPause: musicPlayer.pause,
            onPlay: musicPlayer.play,
            isPlaying: state.isPlaying,
          );
        } else {
          child = const SizedBox();
        }

        return GestureDetector(
          onTap: () {
            if (state.isCompleted) {
              musicPlayer.seek(Duration.zero);
              musicPlayer.play();
            } else if (state.hasError) {
              musicPlayer.play();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor,
              boxShadow: [
                BoxShadow(color: buttonColor, spreadRadius: 1, blurRadius: 15)
              ],
            ),
            child: Center(child: SizedBox(width: 32, height: 32, child: child)),
          ),
        );
      },
    );
  }
}

class AmbientImgShadowWidget extends StatefulWidget {
  const AmbientImgShadowWidget({super.key});

  @override
  State<AmbientImgShadowWidget> createState() => _AmbientImgShadowWidgetState();
}

class _AmbientImgShadowWidgetState extends State<AmbientImgShadowWidget> {
  Color? cachedColor;
  String? lastArtUri;

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      builder: (context, snapshot) {
        final artUri = snapshot.data?.artUri?.toString();
        if (artUri != lastArtUri) {
          lastArtUri = artUri;
          _fetchPalette(artUri);
        }

        return RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  (cachedColor ?? const Color.fromARGB(255, 163, 44, 115))
                      .withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                center: Alignment.center,
                radius: 0.70,
              ),
            ),
          ),
        );
      },
    );
  }

  void _fetchPalette(String? artUri) async {
    if (artUri == null || artUri.isEmpty) return;
    try {
      final palette = await getPalleteFromImage(artUri);
      if (mounted) {
        setState(() => cachedColor = palette.dominantColor?.color);
      }
    } catch (_) {}
  }
}
