import 'dart:async';
import 'dart:ui';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/screens/widgets/volume_slider.dart';
import 'package:Bloomee/services/bloomeePlayer.dart';
import 'package:Bloomee/services/shortcuts_intents.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import '../../blocs/mini_player/mini_player_bloc.dart';
import 'player_views/lyrics_widget.dart';

class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  State<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  final PanelController _panelController = PanelController();
  late TabController _tabController;
  StreamSubscription? _showLyricsSub;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    // set value switchLyrics if tab is changed
    _tabController.addListener(() {
      final isLyricsTab = _tabController.index == 1;
      final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
      if (bloomeePlayerCubit.state.showLyrics != isLyricsTab) {
        bloomeePlayerCubit.switchShowLyrics(value: isLyricsTab);
      }
    });

    _showLyricsSub =
        BlocProvider.of<BloomeePlayerCubit>(context).stream.listen((state) {
      if (mounted) {
        if (state.showLyrics) {
          _tabController.animateTo(1);
        } else {
          _tabController.animateTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showLyricsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    final musicPlayer = bloomeePlayerCubit.bloomeePlayer;
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyS): const ShuffleIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyL): const LoopPlaylistIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyM): const LoopOffIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyO): const LoopSingleIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyT): const TimerIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const BackIntent(),
      },
      child: Actions(
        actions: {
          ShuffleIntent:
              CallbackAction<ShuffleIntent>(onInvoke: (ShuffleIntent intent) {
            if (musicPlayer.shuffleMode.value) {
              musicPlayer.shuffle(false);
            } else {
              musicPlayer.shuffle(true);
            }
            return null;
          }),
          LoopPlaylistIntent: CallbackAction<LoopPlaylistIntent>(
              onInvoke: (LoopPlaylistIntent intent) {
            musicPlayer.setLoopMode(LoopMode.all);
            return null;
          }),
          LoopOffIntent:
              CallbackAction<LoopOffIntent>(onInvoke: (LoopOffIntent intent) {
            musicPlayer.setLoopMode(LoopMode.off);
            return null;
          }),
          LoopSingleIntent: CallbackAction<LoopSingleIntent>(
              onInvoke: (LoopSingleIntent intent) {
            musicPlayer.setLoopMode(LoopMode.one);
            return null;
          }),
          TimerIntent:
              CallbackAction<TimerIntent>(onInvoke: (TimerIntent intent) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TimerView()));
            return null;
          }),
          BackIntent: CallbackAction<BackIntent>(onInvoke: (BackIntent intent) {
            Navigator.pop(context);
            return null;
          }),
        },
        child: FocusScope(
          // Added this widget to enable keyboard shortcuts
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 12, 4, 9),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Default_Theme.primaryColor1,
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      showMoreBottomSheet(context, musicPlayer.currentMedia);
                    },
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
                child: ResponsiveBreakpoints.of(context)
                        .smallerOrEqualTo(TABLET)
                    ? SlidingUpPanel(
                        controller: _panelController,
                        minHeight: 52,
                        maxHeight: MediaQuery.of(context).size.height * 0.40,
                        // backdropColor: Colors.transparent,
                        color: Colors.transparent,
                        backdropTapClosesPanel: true,
                        panel: UpNextPanel(panelController: _panelController),
                        body: playerUI(context, musicPlayer),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: 400,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.60),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: playerUI(context, musicPlayer),
                              )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: UpNextPanel(
                                      panelController: _panelController)),
                            ),
                          )
                        ],
                      )),
          ),
        ),
      ),
    );
  }

  LayoutBuilder playerUI(BuildContext context, BloomeeMusicPlayer musicPlayer) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: constraints.maxHeight *
                  0.92, // Use constraints instead of MediaQuery
              child: Stack(
                children: [
                  Positioned(
                    // top: (MediaQuery.of(context).size.height * 0.5) -
                    //     (MediaQuery.of(context).size.width * 0.75),
                    // left: MediaQuery.of(context).size.width * 0.08 * 0.5,
                    child: Opacity(
                      opacity: 0.15,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * 0.50,
                        child: StreamBuilder<MediaItem?>(
                            stream: musicPlayer.mediaItem,
                            builder: (context, snapshot) {
                              return AnimatedSwitcher(
                                  duration: const Duration(seconds: 3),
                                  child: AmbientImgShadowWidget(
                                      snapshot: snapshot));
                            }),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight * 0.90,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                      ),
                      child: SizedBox(
                        width: constraints.maxWidth * 0.90,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                height: 5,
                              ),
                            ),
                            Flexible(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 16, left: 16, top: 8, bottom: 8),
                                // child: coverImage(context, constraints),
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    Tab(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: CoverImageVolSlider(
                                          constraints: constraints,
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 200,
                                        ),
                                        child: const LyricsWidget(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const Spacer(),
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
    });
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
              return LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.98,
                      maxHeight: constraints.maxHeight * 0.98),
                  child: LoadImageCached(
                      imageUrl: formatImgURL(
                          (snapshot.data?.artUri ?? "").toString(),
                          ImageQuality.high),
                      fallbackUrl: formatImgURL(
                        (snapshot.data?.artUri ?? "").toString(),
                        ImageQuality.medium,
                      ),
                      fit: BoxFit.fitWidth),
                );
              });
            }),
      ),
    );
  }
}

class PlayerCtrlWidgets extends StatelessWidget {
  const PlayerCtrlWidgets({
    super.key,
    required this.musicPlayer,
  });

  final BloomeeMusicPlayer musicPlayer;

  @override
  Widget build(BuildContext context) {
    final bloomeePlayerCubit = context.read<BloomeePlayerCubit>();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.92,
      // height: MediaQuery.of(context).size.width * 0.92,
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: StreamBuilder<MediaItem?>(
                    stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
                    builder: (context, snapshot) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.antiAlias,
                            child: SelectableText(
                              snapshot.data?.title ?? "Unknown",
                              textAlign: TextAlign.start,
                              // overflow: TextOverflow.ellipsis,
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
                              snapshot.data?.artist ?? "Unknown",
                              textAlign: TextAlign.start,
                              // overflow: TextOverflow.ellipsis,
                              style: Default_Theme.secondoryTextStyle.merge(
                                  TextStyle(
                                      fontSize: 15,
                                      fontFamily: "NotoSans",
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      color: Default_Theme.primaryColor1
                                          .withOpacity(0.7))),
                            ),
                          )
                        ],
                      );
                    }),
              ),
              const Spacer(),
              StreamBuilder<dynamic>(
                  stream: bloomeePlayerCubit
                      .bloomeePlayer.audioPlayer.playbackEventStream,
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: context.read<BloomeeDBCubit>().isLiked(
                          bloomeePlayerCubit.bloomeePlayer.currentMedia),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 3),
                            child: LikeBtnWidget(
                              isPlaying: true,
                              isLiked: snapshot.data ?? false,
                              iconSize: 35,
                              onLiked: () => context
                                  .read<BloomeeDBCubit>()
                                  .setLike(
                                      bloomeePlayerCubit
                                          .bloomeePlayer.currentMedia,
                                      isLiked: true),
                              onDisliked: () => context
                                  .read<BloomeeDBCubit>()
                                  .setLike(
                                      bloomeePlayerCubit
                                          .bloomeePlayer.currentMedia,
                                      isLiked: false),
                            ),
                          );
                        } else {
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 3),
                            child: LikeBtnWidget(
                              isLiked: false,
                              isPlaying: true,
                              iconSize: 35,
                              onLiked: () {},
                              onDisliked: () {},
                            ),
                          );
                        }
                      },
                    );
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StreamBuilder<ProgressBarStreams>(
                stream: bloomeePlayerCubit.progressStreams,
                builder: (context, snapshot) {
                  return ProgressBar(
                    progress: snapshot.data?.currentPos ?? Duration.zero,
                    total: snapshot.data?.currentPlaybackState.duration ??
                        Duration.zero,
                    buffered:
                        snapshot.data?.currentPlaybackState.bufferedPosition ??
                            Duration.zero,
                    onSeek: (value) {
                      musicPlayer.seek(value);
                    },
                    timeLabelPadding: 5,
                    timeLabelTextStyle: Default_Theme.secondoryTextStyle.merge(
                        TextStyle(
                            fontSize: 15,
                            color:
                                Default_Theme.primaryColor1.withOpacity(0.7))),
                    timeLabelLocation: TimeLabelLocation.above,
                    baseBarColor: Default_Theme.primaryColor2.withOpacity(0.1),
                    progressBarColor:
                        snapshot.data?.currentPlayerState.playing ?? false
                            ? Default_Theme.accentColor1
                            : Default_Theme.accentColor2,
                    thumbRadius: 5,
                    thumbColor:
                        snapshot.data?.currentPlayerState.playing ?? false
                            ? Default_Theme.accentColor1
                            : Default_Theme.accentColor2,
                    bufferedBarColor:
                        snapshot.data?.currentPlayerState.playing ?? false
                            ? Default_Theme.accentColor1.withOpacity(0.2)
                            : Default_Theme.accentColor2.withOpacity(0.2),
                    barHeight: 4,
                  );
                }),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: "Timer",
                    child: IconButton(
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TimerView()));
                      },
                      icon: const Icon(
                        MingCute.alarm_1_line,
                        color: Default_Theme.primaryColor1,
                        size: 30,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // the '2023' part
                    ),
                    onPressed: () => musicPlayer.skipToPrevious(),
                    icon: const Icon(
                      MingCute.skip_previous_fill,
                      color: Default_Theme.primaryColor1,
                      size: 30,
                    ),
                  ),
                  //Play Pause btn
                  BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
                    builder: (context, state) {
                      switch (state) {
                        case MiniPlayerInitial():
                          return Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Default_Theme.accentColor2,
                                      spreadRadius: 1,
                                      blurRadius: 20)
                                ],
                                shape: BoxShape.circle,
                                color: Default_Theme.accentColor2,
                              ),
                              width: 75,
                              height: 75,
                              child: const Center(
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator(
                                    color: Default_Theme.primaryColor1,
                                  ),
                                ),
                              ));
                        case MiniPlayerCompleted():
                          return Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Default_Theme.accentColor2,
                                      spreadRadius: 1,
                                      blurRadius: 20)
                                ],
                                shape: BoxShape.circle,
                                color: Default_Theme.accentColor2,
                              ),
                              width: 75,
                              height: 75,
                              child: const Center(
                                child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Icon(
                                      FontAwesome.rotate_right_solid,
                                      color: Default_Theme.primaryColor1,
                                      size: 35,
                                    )),
                              ));
                        case MiniPlayerWorking():
                          if (state.isBuffering) {
                            return Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Default_Theme.accentColor2,
                                        spreadRadius: 1,
                                        blurRadius: 20)
                                  ],
                                  shape: BoxShape.circle,
                                  color: Default_Theme.accentColor2,
                                ),
                                width: 75,
                                height: 75,
                                child: const Center(
                                  child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: CircularProgressIndicator(
                                      color: Default_Theme.primaryColor1,
                                    ),
                                  ),
                                ));
                          } else {
                            return PlayPauseButton(
                              size: 75,
                              onPause: () => musicPlayer.pause(),
                              onPlay: () => musicPlayer.play(),
                              isPlaying: state.isPlaying,
                            );
                          }
                        case MiniPlayerError():
                          return Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Default_Theme.accentColor2,
                                      spreadRadius: 1,
                                      blurRadius: 20)
                                ],
                                shape: BoxShape.circle,
                                color: Default_Theme.accentColor2,
                              ),
                              width: 75,
                              height: 75,
                              child: const Center(
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(
                                    MingCute.warning_line,
                                    color: Default_Theme.primaryColor1,
                                  ),
                                ),
                              ));
                        case MiniPlayerProcessing():
                          return Container(
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Default_Theme.accentColor2,
                                      spreadRadius: 1,
                                      blurRadius: 20)
                                ],
                                shape: BoxShape.circle,
                                color: Default_Theme.accentColor2,
                              ),
                              width: 75,
                              height: 75,
                              child: const Center(
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator(
                                    color: Default_Theme.primaryColor1,
                                  ),
                                ),
                              ));
                      }
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // the '2023' part
                    ),
                    onPressed: () => musicPlayer.skipToNext(),
                    icon: const Icon(
                      MingCute.skip_forward_fill,
                      color: Default_Theme.primaryColor1,
                      size: 30,
                    ),
                  ),
                  StreamBuilder<bool>(
                      stream: bloomeePlayerCubit.bloomeePlayer.shuffleMode,
                      builder: (context, snapshot) {
                        return Tooltip(
                          message: "Shuffle",
                          child: IconButton(
                            padding: const EdgeInsets.all(5),
                            constraints: const BoxConstraints(),
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, // the '2023' part
                            ),
                            icon: Icon(
                              MingCute.shuffle_2_fill,
                              color: (snapshot.data ?? false)
                                  ? Default_Theme.accentColor1
                                  : Default_Theme.primaryColor1,
                              size: 30,
                            ),
                            onPressed: () {
                              bloomeePlayerCubit.bloomeePlayer.shuffle(
                                  (snapshot.data ?? false) ? false : true);
                            },
                          ),
                        );
                      })
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: "Loop",
                      child: StreamBuilder<LoopMode>(
                        stream: context
                            .watch<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .loopMode,
                        builder: (context, snapshot) {
                          final loopMode = snapshot.data ?? LoopMode.off;
                          return PopupMenuButton(
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(value: 0, child: Text("Off")),
                              const PopupMenuItem(
                                  value: 1, child: Text("Loop One")),
                              const PopupMenuItem(
                                  value: 2, child: Text("Loop All")),
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
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 0:
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .bloomeePlayer
                                      .setLoopMode(LoopMode.off);
                                  break;
                                case 1:
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .bloomeePlayer
                                      .setLoopMode(LoopMode.one);
                                  break;
                                case 2:
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .bloomeePlayer
                                      .setLoopMode(LoopMode.all);
                                  break;
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Tooltip(
                      message: "Lyrics",
                      child:
                          BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              height: 35,
                              child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // the '2023' part
                                ),
                                icon: Text('Lyrics',
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(TextStyle(
                                            color: state.showLyrics
                                                ? Default_Theme.accentColor2
                                                : Default_Theme.primaryColor1,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold))),
                                onPressed: () {
                                  bloomeePlayerCubit.switchShowLyrics(
                                      value: !state.showLyrics);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Tooltip(
                  message: "Open Original Link",
                  child: IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // the '2023' part
                    ),
                    icon: StreamBuilder<MediaItem?>(
                        stream: bloomeePlayerCubit.bloomeePlayer.mediaItem,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data?.extras?['perma_url'] != null) {
                            return snapshot.data?.extras?['source'] == 'youtube'
                                ? const Icon(
                                    MingCute.youtube_fill,
                                    color: Default_Theme.primaryColor1,
                                    size: 30,
                                  )
                                : Text("JioSaavn",
                                    style: const TextStyle(
                                            color: Default_Theme.primaryColor1,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)
                                        .merge(
                                            Default_Theme.secondoryTextStyle));
                          }

                          return const Icon(
                            MingCute.external_link_line,
                            color: Default_Theme.primaryColor1,
                            size: 30,
                          );
                        }),
                    onPressed: () async {
                      final url = context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .currentMedia
                          .extras?['perma_url'];
                      if (url != null && await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Unable to open the link")),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AmbientImgShadowWidget extends StatefulWidget {
  final AsyncSnapshot<MediaItem?> snapshot;
  const AmbientImgShadowWidget({super.key, required this.snapshot});

  @override
  State<AmbientImgShadowWidget> createState() => _AmbientImgShadowWidgetState();
}

class _AmbientImgShadowWidgetState extends State<AmbientImgShadowWidget> {
  Color? cachedColor;

  @override
  void didUpdateWidget(covariant AmbientImgShadowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.snapshot.data?.artUri != oldWidget.snapshot.data?.artUri) {
      _fetchPalette();
    }
  }

  void _fetchPalette() async {
    final palette = await getPalleteFromImage(
        widget.snapshot.data?.artUri?.toString() ?? "");
    if (mounted) {
      setState(() {
        cachedColor = palette.dominantColor?.color ??
            const Color.fromARGB(255, 68, 252, 255);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: cachedColor ?? const Color.fromARGB(39, 68, 252, 255),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
