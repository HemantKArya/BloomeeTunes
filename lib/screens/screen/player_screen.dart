import 'dart:ui';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/screens/widgets/volume_slider.dart';
import 'package:Bloomee/services/bloomeePlayer.dart';
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    // set value switchLyrics if tab is changed
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<BloomeePlayerCubit>().switchShowLyrics(value: true);
      } else {
        context.read<BloomeePlayerCubit>().switchShowLyrics(value: false);
      }
    });

    BlocProvider.of<BloomeePlayerCubit>(context).stream.listen((state) {
      if (state.showLyrics) {
        _tabController.animateTo(1);
      } else {
        _tabController.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BloomeeMusicPlayer musicPlayer =
        context.read<BloomeePlayerCubit>().bloomeePlayer;
    return CallbackShortcuts(
      // Shortcuts keys for controlling actions from key board
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          // play pause -> space
          if (context
              .read<BloomeePlayerCubit>()
              .bloomeePlayer
              .audioPlayer
              .playing) {
            context
                .read<BloomeePlayerCubit>()
                .bloomeePlayer
                .audioPlayer
                .pause();
          } else {
            context.read<BloomeePlayerCubit>().bloomeePlayer.audioPlayer.play();
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          musicPlayer.skipToPrevious();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          musicPlayer.skipToNext();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): () {
          musicPlayer.seekNSecForward(const Duration(seconds: 5));
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () {
          musicPlayer.seekNSecBackward(const Duration(seconds: 5));
        },
        // Temp. solution for volume control, will be replaced by global volume control
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          musicPlayer.audioPlayer.setVolume(
              (musicPlayer.audioPlayer.volume + 0.1).clamp(0.0, 1.0));
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          musicPlayer.audioPlayer.setVolume(
              (musicPlayer.audioPlayer.volume - 0.1).clamp(0.0, 1.0));
        },
        const SingleActivator(LogicalKeyboardKey.keyS): () {
          // shuffle mode on/off
          if (context
              .read<BloomeePlayerCubit>()
              .bloomeePlayer
              .audioPlayer
              .shuffleModeEnabled) {
            context.read<BloomeePlayerCubit>().bloomeePlayer.shuffle(false);
          } else {
            context.read<BloomeePlayerCubit>().bloomeePlayer.shuffle(true);
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyL): () {
          context
              .read<BloomeePlayerCubit>()
              .bloomeePlayer
              .setLoopMode(LoopMode.all);
        },
        const SingleActivator(LogicalKeyboardKey.keyM): () {
          context
              .read<BloomeePlayerCubit>()
              .bloomeePlayer
              .setLoopMode(LoopMode.off);
        },
        const SingleActivator(LogicalKeyboardKey.keyO): () {
          context
              .read<BloomeePlayerCubit>()
              .bloomeePlayer
              .setLoopMode(LoopMode.one);
        },
        const SingleActivator(LogicalKeyboardKey.keyT): () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TimerView()));
        },
        // backspace for back
        const SingleActivator(LogicalKeyboardKey.backspace): () {
          Navigator.pop(context);
        },
      },
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
                  showMoreBottomSheet(
                      context,
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .currentMedia);
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
                  stream: context
                      .watch<BloomeePlayerCubit>()
                      .bloomeePlayer
                      .queueTitle,
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
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: UpNextPanel(
                                  panelController: _panelController)),
                        ),
                      )
                    ],
                  )),
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
              height: MediaQuery.of(context).size.height * 0.92,
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
                                  child: _getAmbientShadowWidget(
                                      context, snapshot));
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
                                        child: coverImage(context, constraints),
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

  VolumeDragController coverImage(
      BuildContext context, BoxConstraints constraints) {
    return VolumeDragController(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: StreamBuilder<MediaItem?>(
            stream: context.watch<BloomeePlayerCubit>().bloomeePlayer.mediaItem,
            builder: (context, snapshot) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200 + constraints.maxWidth * 0.85,
                  minWidth: 200,
                  maxHeight: 200 + constraints.maxHeight * 0.90,
                  minHeight: 200,
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: loadImageCached(
                      (snapshot.data?.artUri ?? "").toString(),
                      fit: BoxFit.fitWidth),
                ),
              );
            }),
      ),
    );
  }
}

class UpNextPanel extends StatelessWidget {
  const UpNextPanel({
    super.key,
    required PanelController panelController,
  }) : _panelController = panelController;

  final PanelController _panelController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 28, 17, 24).withOpacity(0.60),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                left: 10,
                right: 10,
                bottom: 5,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _panelController.isPanelOpen
                        ? _panelController.close()
                        : _panelController.open();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: SizedBox(
                          width: 40,
                          child: Divider(
                            color: Default_Theme.primaryColor2.withOpacity(0.8),
                            thickness: 4,
                          ),
                        ),
                      ),
                      Text("Up Next",
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                              const TextStyle(
                                  color: Default_Theme.primaryColor2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: Divider(
                color: Default_Theme.primaryColor2.withOpacity(0.5),
                thickness: 1.5,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream:
                    context.watch<BloomeePlayerCubit>().bloomeePlayer.upNext,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 5),
                      itemCount: snapshot.data?.length ?? 0,
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SongCardWidget(
                            showOptions: false,
                            onTap: () {
                              context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .playOffsetIdx(offset: index);
                            },
                            //
                            song: mediaItem2MediaItemModel(
                                snapshot.data![index]));
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ],
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
                    stream: context
                        .watch<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .mediaItem,
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
                                      fontSize: 24,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
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
              FutureBuilder(
                future: context.read<BloomeeDBCubit>().isLiked(context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .currentMedia),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                      child: LikeBtnWidget(
                        isPlaying: true,
                        isLiked: snapshot.data ?? false,
                        iconSize: 35,
                        onLiked: () => context.read<BloomeeDBCubit>().setLike(
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .currentMedia,
                            isLiked: true),
                        onDisliked: () => context
                            .read<BloomeeDBCubit>()
                            .setLike(
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .currentMedia,
                                isLiked: false),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 3),
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
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StreamBuilder<ProgressBarStreams>(
                stream: context.watch<BloomeePlayerCubit>().progressStreams,
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
                  StreamBuilder(
                      stream: context
                          .watch<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .isLinkProcessing,
                      builder: (context, snapshot2) {
                        return snapshot2.hasData && snapshot2.data == true
                            ? Container(
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
                                ))
                            : StreamBuilder<PlayerState>(
                                stream: context
                                    .watch<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .audioPlayer
                                    .playerStateStream,
                                builder: (context, snapshot) {
                                  return PlayPauseButton(
                                    size: 75,
                                    onPause: () => musicPlayer.pause(),
                                    onPlay: () => musicPlayer.play(),
                                    isPlaying: snapshot.data?.playing ?? false,
                                  );
                                });
                      }),
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
                      stream: context
                          .watch<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .audioPlayer
                          .shuffleModeEnabledStream,
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
                              context
                                  .read<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .shuffle(
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
                      child: PopupMenuButton(
                        color: const Color.fromARGB(255, 17, 17, 17),
                        surfaceTintColor: const Color.fromARGB(255, 19, 19, 19),
                        padding: const EdgeInsets.all(5),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Text(
                              "Off",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Default_Theme.primaryColor1,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text(
                              "Loop One",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Default_Theme.primaryColor1,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text(
                              "Loop All",
                              style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Default_Theme.primaryColor1,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: StreamBuilder<LoopMode>(
                              stream: context
                                  .watch<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .loopMode,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  switch (snapshot.data) {
                                    case LoopMode.off:
                                      return const Icon(
                                        MingCute.repeat_line,
                                        color: Default_Theme.primaryColor1,
                                        size: 30,
                                      );
                                    case LoopMode.one:
                                      return const Icon(
                                        MingCute.repeat_one_line,
                                        color: Default_Theme.accentColor1,
                                        size: 30,
                                      );
                                    case LoopMode.all:
                                      return const Icon(
                                        MingCute.repeat_fill,
                                        color: Default_Theme.accentColor1,
                                        size: 30,
                                      );
                                    case null:
                                      return const Icon(
                                        MingCute.repeat_line,
                                        color: Default_Theme.primaryColor1,
                                        size: 30,
                                      );
                                  }
                                }
                                return const Icon(
                                  MingCute.repeat_line,
                                  color: Default_Theme.primaryColor1,
                                  size: 30,
                                );
                              }),
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
                                  context
                                      .read<BloomeePlayerCubit>()
                                      .switchShowLyrics(
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
                        stream: context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .mediaItem,
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
                    onPressed: () {
                      launchUrlString(context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .currentMedia
                          .extras?['perma_url']);
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

Widget _getAmbientShadowWidget(
    BuildContext context, AsyncSnapshot<MediaItem?> snapshot) {
  if (snapshot.hasData) {
    return FutureBuilder(
      future: getPalleteFromImage(context
          .read<BloomeePlayerCubit>()
          .bloomeePlayer
          .currentMedia
          .artUri
          .toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                  color: snapshot.data?.dominantColor?.color ??
                      const Color.fromARGB(255, 68, 252, 255),
                  blurRadius: 120,
                  spreadRadius: 30)
            ]),
          );
        } else {
          return Container(
            decoration:
                const BoxDecoration(color: Colors.transparent, boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(39, 68, 252, 255),
                  blurRadius: 120,
                  spreadRadius: 30)
            ]),
          );
        }
      },
    );
  } else {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent, boxShadow: [
        BoxShadow(
            color: Color.fromARGB(255, 68, 252, 255),
            blurRadius: 120,
            spreadRadius: 30)
      ]),
    );
  }
}
