import 'dart:ui';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/widgets/gradient_progress_bar.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/screens/widgets/volume_slider.dart';
import 'package:Bloomee/services/bloomeePlayer.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Bloomee/screens/widgets/like_widget.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:Bloomee/utils/pallete_generator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import '../../blocs/mini_player/mini_player_bloc.dart';
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
    // Register the collapse callback with PlayerOverlayCubit
    // This allows GlobalFooter to collapse the panel on back gesture
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
    // Unregister the collapse callback
    context.read<PlayerOverlayCubit>().unregisterUpNextPanelCollapse();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;

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
            // If upnext panel is expanded, collapse it first
            // Otherwise hide the player
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
                  size: 25, color: Default_Theme.primaryColor1))
        ],
        title: Column(
          children: [
            Text(
              'Enjoying From',
              textAlign: TextAlign.center,
              style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)
                  .merge(Default_Theme.secondoryTextStyle),
            ),
            StreamBuilder<String>(
                stream: bloomeePlayerCubit.bloomeePlayer.queueTitle,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Unknown",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Default_Theme.primaryColor2,
                      fontSize: 12,
                    ).merge(Default_Theme.secondoryTextStyle),
                  );
                }),
          ],
        ),
      ),
      body: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        _PlayerUI(
                          musicPlayer: musicPlayer,
                          tabController: _tabController,
                          constraints: constraints,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 400,
                            maxWidth: MediaQuery.of(context).size.width * 0.60),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return _PlayerUI(
                              musicPlayer: musicPlayer,
                              tabController: _tabController,
                              constraints: constraints,
                            );
                          }),
                        )),
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
                                controller: _upNextPanelController)),
                      ),
                    )
                  ],
                )),
    );
  }
}

class _PlayerUI extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  final TabController tabController;
  final BoxConstraints constraints;

  const _PlayerUI({
    required this.musicPlayer,
    required this.tabController,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: constraints.maxHeight * 0.92,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: tabController.animation!,
                    builder: (context, child) {
                      final opacity = (1 - tabController.animation!.value);
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: const AmbientImgShadowWidget(),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.90,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: constraints.maxWidth * 0.90,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(child: SizedBox(height: 5)),
                          Flexible(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: TabBarView(
                                controller: tabController,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  Tab(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: CoverImageVolSlider(
                                          constraints: constraints),
                                    ),
                                  ),
                                  Tab(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 200),
                                      child: LyricsWidget(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PlayerCtrlWidgets(musicPlayer: musicPlayer)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoverImageVolSlider extends StatelessWidget {
  final BoxConstraints constraints;
  const CoverImageVolSlider({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return VolumeDragController(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: StreamBuilder<MediaItem?>(
            stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
            builder: (context, snapshot) {
              final artUri = snapshot.data?.artUri?.toString() ?? "";
              return LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.98,
                      maxHeight: constraints.maxHeight * 0.98),
                  child: LoadImageCached(
                      imageUrl: formatImgURL(artUri, ImageQuality.high),
                      fallbackUrl: formatImgURL(artUri, ImageQuality.medium),
                      fit: BoxFit.fitWidth),
                );
              });
            }),
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  const PlayerCtrlWidgets({super.key, required this.musicPlayer});
  final BloomeeMusicPlayer musicPlayer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.92,
      child: Column(
        children: [
          const _SongInfoRow(),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: _PlayerProgressBar(),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: _PlayerControlsRow(musicPlayer: musicPlayer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongInfoRow extends StatelessWidget {
  const _SongInfoRow();

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: StreamBuilder<MediaItem?>(
              stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.antiAlias,
                      child: SelectableText(
                        mediaItem?.title ?? "Unknown",
                        textAlign: TextAlign.start,
                        style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                fontSize: 22,
                                fontFamily: "NotoSans",
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                color: Default_Theme.primaryColor1)),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        mediaItem?.artist ?? "Unknown",
                        textAlign: TextAlign.start,
                        style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                            fontSize: 15,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.7))),
                      ),
                    )
                  ],
                );
              }),
        ),
        const Spacer(),
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
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return Tooltip(
      message: "Available Offline",
      child: StreamBuilder<MediaItem?>(
        stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
        builder: (context, mediaSnapshot) {
          final currentMedia = mediaSnapshot.data;
          if (currentMedia == null) return const SizedBox.shrink();
          return FutureBuilder(
            future: BloomeeDBService.getDownloadDB(
                mediaItem2MediaItemModel(currentMedia)),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 0.0, bottom: 3),
                  child: IconButton(
                    iconSize: 25,
                    icon: Icon(
                      Icons.offline_pin_rounded,
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      // bloomeePlayerCubit.bloomeePlayer.toggleDownload();
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
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
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return StreamBuilder<ProgressBarStreams>(
        stream: bloomeePlayerCubit.progressStreams,
        builder: (context, progressSnapshot) {
          final isPlaying =
              progressSnapshot.data?.currentPlayerState.playing ?? false;
          return FutureBuilder(
            future: context
                .read<BloomeeDBCubit>()
                .isLiked(bloomeePlayerCubit.bloomeePlayer.currentMedia),
            builder: (context, snapshot) {
              final isLiked = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(left: 0.0, bottom: 3),
                child: LikeBtnWidget(
                  isPlaying: isPlaying,
                  isLiked: isLiked,
                  iconSize: 25,
                  onLiked: () => context.read<BloomeeDBCubit>().setLike(
                      bloomeePlayerCubit.bloomeePlayer.currentMedia,
                      isLiked: true),
                  onDisliked: () => context.read<BloomeeDBCubit>().setLike(
                      bloomeePlayerCubit.bloomeePlayer.currentMedia,
                      isLiked: false),
                ),
              );
            },
          );
        });
  }
}

class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return RepaintBoundary(
      child: StreamBuilder<ProgressBarStreams>(
          stream: bloomeePlayerCubit.progressStreams,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final isPlaying = data?.currentPlayerState.playing ?? false;
            return GradientProgressBar.fromAccentColors(
              progress: data?.currentPos ?? Duration.zero,
              total: data?.currentPlaybackState.duration ?? Duration.zero,
              buffered:
                  data?.currentPlaybackState.bufferedPosition ?? Duration.zero,
              onSeek: (value) {
                bloomeePlayerCubit.bloomeePlayer.seek(value);
              },
              isPlaying: isPlaying,
              // Just pass the accent colors - gradients are auto-generated!
              activeAccentColor: Default_Theme.accentColor1, // Sky Blue
              inactiveAccentColor: Default_Theme.accentColor2, // Pink
              // Use "Light & Breezy" for Sky Blue (keeps it bright/cyan)
              activeGradientStyle: GradientStyle.lightAndBreezy,
              // Use "Warm & Rich" for Pink (makes it vibrant/orange-red, not pastel)
              inactiveGradientStyle: GradientStyle.warmAndRich,
              trackHeight: 6.0,
              thumbRadius: 8.0,
              timeLabelPadding: 5,
              timeLabelStyle: Default_Theme.secondoryTextStyle.merge(TextStyle(
                  fontSize: 15,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.7))),
              timeLabelLocation: TimeLabelLocation.above,
              inactiveTrackColor:
                  Default_Theme.primaryColor2.withValues(alpha: 0.1),
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.easeOutCubic,
            );
          }),
    );
  }
}

class _PlayerControlsRow extends StatelessWidget {
  final BloomeeMusicPlayer musicPlayer;
  const _PlayerControlsRow({required this.musicPlayer});

  Widget _buildControlColumn(
      {required Widget topWidget, Widget? bottomWidget}) {
    const double primaryRowHeight = 75.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: primaryRowHeight,
          alignment: Alignment.center,
          child: topWidget,
        ),
        if (bottomWidget != null)
          SizedBox(
            height: 40,
            child: bottomWidget,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildControlColumn(
          topWidget: Tooltip(
            message: "Timer",
            child: IconButton(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TimerView()));
              },
              icon: const Icon(MingCute.alarm_1_line,
                  color: Default_Theme.primaryColor1, size: 30),
            ),
          ),
          bottomWidget: const _LoopControl(),
        ),
        _buildControlColumn(
          topWidget: IconButton(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () => musicPlayer.skipToPrevious(),
            icon: const Icon(MingCute.skip_previous_fill,
                color: Default_Theme.primaryColor1, size: 30),
          ),
          bottomWidget: Tooltip(
            message: "Lyrics",
            child: IconButton(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              icon: const Icon(MingCute.music_2_line,
                  color: Default_Theme.primaryColor1, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const FullscreenLyricsView(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          ),
        ),
        const _PlayPauseButton(),
        _buildControlColumn(
          topWidget: IconButton(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () => musicPlayer.skipToNext(),
            icon: const Icon(MingCute.skip_forward_fill,
                color: Default_Theme.primaryColor1, size: 30),
          ),
          bottomWidget: null,
        ),
        _buildControlColumn(
          topWidget: const _ShuffleControl(),
          bottomWidget: const _ExternalLinkControl(),
        ),
      ],
    );
  }
}

class _LoopControl extends StatelessWidget {
  const _LoopControl();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Loop",
      child: StreamBuilder<LoopMode>(
        stream: context.watch<BloomeePlayerCubit>().bloomeePlayer.loopMode,
        builder: (context, snapshot) {
          final loopMode = snapshot.data ?? LoopMode.off;
          return PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 0, child: Text("Off")),
              const PopupMenuItem(value: 1, child: Text("Loop One")),
              const PopupMenuItem(value: 2, child: Text("Loop All")),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
            ),
            onSelected: (value) {
              final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
              switch (value) {
                case 0:
                  player.setLoopMode(LoopMode.off);
                  break;
                case 1:
                  player.setLoopMode(LoopMode.one);
                  break;
                case 2:
                  player.setLoopMode(LoopMode.all);
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

class _ShuffleControl extends StatelessWidget {
  const _ShuffleControl();

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return StreamBuilder<bool>(
        stream: bloomeePlayerCubit.bloomeePlayer.shuffleMode,
        builder: (context, snapshot) {
          final isShuffle = snapshot.data ?? false;
          return Tooltip(
            message: "Shuffle",
            child: IconButton(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              icon: Icon(
                MingCute.shuffle_2_fill,
                color: isShuffle
                    ? Default_Theme.accentColor1
                    : Default_Theme.primaryColor1,
                size: 30,
              ),
              onPressed: () {
                bloomeePlayerCubit.bloomeePlayer.shuffle(!isShuffle);
              },
            ),
          );
        });
  }
}

class _ExternalLinkControl extends StatelessWidget {
  const _ExternalLinkControl();

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return Tooltip(
      message: "Open Original Link",
      child: IconButton(
        padding: const EdgeInsets.all(5),
        constraints: const BoxConstraints(),
        style:
            const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        icon: StreamBuilder<MediaItem?>(
            stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data?.extras?['perma_url'] != null) {
                return snapshot.data?.extras?['source'] == 'youtube'
                    ? const Icon(MingCute.youtube_fill,
                        color: Default_Theme.primaryColor1, size: 24)
                    : Text("JS",
                        style: const TextStyle(
                                color: Default_Theme.primaryColor1,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)
                            .merge(Default_Theme.secondoryTextStyle));
              }
              return const Icon(MingCute.external_link_line,
                  color: Default_Theme.primaryColor1, size: 24);
            }),
        onPressed: () async {
          final url = bloomeePlayerCubit
              .bloomeePlayer.currentMedia.extras?['perma_url'];
          if (url != null && await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to open the link")),
            );
          }
        },
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    final musicPlayer = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
      builder: (context, state) {
        Widget child;
        // Determine button color based on state
        // - Playing/Working states: accentColor1 (sky blue) handled by PlayPauseButton
        // - Completed (repeat icon): accentColor1 (sky blue)
        // - Initial/Processing/Error: accentColor2 (pink)
        Color buttonColor = Default_Theme.accentColor2;

        if (state is MiniPlayerInitial || state is MiniPlayerProcessing) {
          child = const CircularProgressIndicator(
              color: Default_Theme.primaryColor1);
          buttonColor = Default_Theme.accentColor2;
        } else if (state is MiniPlayerCompleted) {
          child = const Icon(FontAwesome.rotate_right_solid,
              color: Default_Theme.primaryColor1, size: 35);
          buttonColor =
              Default_Theme.accentColor1; // Sky blue for completed/repeat
        } else if (state is MiniPlayerError) {
          child = const Icon(MingCute.warning_line,
              color: Default_Theme.primaryColor1);
          buttonColor = Default_Theme.accentColor2;
        } else if (state is MiniPlayerWorking) {
          if (state.isBuffering) {
            child = const CircularProgressIndicator(
                color: Default_Theme.primaryColor1);
            buttonColor = state.isPlaying
                ? Default_Theme.accentColor1
                : Default_Theme.accentColor2;
          } else {
            return PlayPauseButton(
              size: 75,
              onPause: () => musicPlayer.pause(),
              onPlay: () => musicPlayer.play(),
              isPlaying: state.isPlaying,
            );
          }
        } else {
          child = const SizedBox();
        }

        return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: buttonColor, spreadRadius: 1, blurRadius: 20)
              ],
              shape: BoxShape.circle,
              color: buttonColor,
            ),
            width: 75,
            height: 75,
            child:
                Center(child: SizedBox(width: 35, height: 35, child: child)));
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
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return StreamBuilder<MediaItem?>(
        stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
        builder: (context, snapshot) {
          final artUri = snapshot.data?.artUri?.toString();
          if (artUri != lastArtUri) {
            lastArtUri = artUri;
            _fetchPalette(artUri);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: RepaintBoundary(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      (cachedColor ?? const Color.fromARGB(255, 163, 44, 115))
                          .withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                    center: Alignment.center,
                    radius: 0.65,
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _fetchPalette(String? artUri) async {
    if (artUri == null || artUri.isEmpty) return;
    try {
      final palette = await getPalleteFromImage(artUri);
      if (mounted) {
        setState(() {
          cachedColor = palette.dominantColor?.color ??
              const Color.fromARGB(255, 68, 252, 255);
        });
      }
    } catch (e) {
      // Handle error or ignore
    }
  }
}
