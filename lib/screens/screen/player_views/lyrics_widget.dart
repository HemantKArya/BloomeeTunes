import 'dart:async';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/screens/screen/player_views/fullscreen_lyrics_view.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                LyricsInitial() => const Center(
                    child: CircularProgressIndicator(),
                  ),

                // return condtional widget
                LyricsLoaded() => LoadedLyricsWidget(state: state),
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
            ),
            Positioned(
              right: 3,
              bottom: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Tooltip(
                  message: 'Fullscreen Lyrics',
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const FullscreenLyricsView(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    icon: const Icon(
                      MingCute.fullscreen_fill,
                      size: 20,
                    ),
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.9),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoadedLyricsWidget extends StatelessWidget {
  final LyricsState state;
  const LoadedLyricsWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.lyrics.parsedLyrics == null &&
        state.lyrics.lyricsPlain.isNotEmpty) {
      return PlainLyricsWidget(state: state);
    } else if (state.lyrics.parsedLyrics != null) {
      return SyncedLyricsWidget(
        state: state,
      );
    }
    return const Center(
      child: SignBoardWidget(
          message: "No Lyrics found!", icon: MingCute.music_2_line),
    );
  }
}

class PlainLyricsWidget extends StatelessWidget {
  final LyricsState state;
  const PlainLyricsWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
          stops: [
            0.0,
            0.1,
            0.9,
            1.0
          ], // Adjust the stops to control the fade position
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        child: SelectableText(
          "\n${state.lyrics.lyricsPlain}\n",
          textAlign: TextAlign.center,
          style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w600,
              color: Colors.white)),
        ),
      ),
    );
  }
}

class SyncedLyricsWidget extends StatefulWidget {
  final LyricsState state;
  const SyncedLyricsWidget({
    required this.state,
    super.key,
  });

  @override
  State<SyncedLyricsWidget> createState() => _SyncedLyricsWidgetState();
}

class _SyncedLyricsWidgetState extends State<SyncedLyricsWidget> {
  StreamSubscription? _streamSubscription;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _streamSubscription = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .audioPlayer
        .positionStream
        .listen((event) {
      setState(() {
        duration = event;
        _scrollToCurrentLyric();
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _scrollToCurrentLyric() {
    final currentIndex = _findCurrentLyricIndex();
    if (isEndVisible()) {
      return;
    }
    if (currentIndex >= 4 || !isIdxVisible(currentIndex)) {
      _itemScrollController.scrollTo(
        index: currentIndex < 4 ? currentIndex : currentIndex - 3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _findCurrentLyricIndex() {
    for (int i = 0; i < widget.state.lyrics.parsedLyrics!.lyrics.length; i++) {
      if (widget.state.lyrics.parsedLyrics!.lyrics[i].start.inSeconds <=
          duration.inSeconds) {
        if (i >= widget.state.lyrics.parsedLyrics!.lyrics.length - 1) {
          return i;
        } else if (widget
                .state.lyrics.parsedLyrics!.lyrics[i + 1].start.inSeconds >
            duration.inSeconds) {
          return i;
        }
      }
    }
    return 0;
  }

  bool isEndVisible() {
    return _itemPositionsListener.itemPositions.value.last.index ==
        widget.state.lyrics.parsedLyrics!.lyrics.length - 1;
  }

  bool isIdxVisible(int index) {
    return _itemPositionsListener.itemPositions.value
        .where((element) => element.index == index)
        .isNotEmpty;
  }

  bool isCurrentLyric(int index) {
    if (widget.state.lyrics.parsedLyrics!.lyrics[index].start.inSeconds <=
        duration.inSeconds) {
      if (index >= widget.state.lyrics.parsedLyrics!.lyrics.length - 1) {
        return true;
      } else if (widget
              .state.lyrics.parsedLyrics!.lyrics[index + 1].start.inSeconds >
          duration.inSeconds) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
          stops: [
            0.0,
            0.1,
            0.9,
            1.0
          ], // Adjust the stops to control the fade position
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ScrollablePositionedList.builder(
        shrinkWrap: true,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        scrollDirection: Axis.vertical,
        scrollOffsetController: _scrollOffsetController,
        scrollOffsetListener: _scrollOffsetListener,
        itemCount: widget.state.lyrics.parsedLyrics!.lyrics.length,
        padding: const EdgeInsets.symmetric(vertical: 30),
        itemBuilder: (context, index) {
          return Text(
            widget.state.lyrics.parsedLyrics!.lyrics[index].text,
            textAlign: TextAlign.center,
            style: Default_Theme.secondoryTextStyle.merge(TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.bold,
              color: isCurrentLyric(index)
                  ? Colors.white
                  : Default_Theme.primaryColor2.withOpacity(0.4),
            )),
          );
        },
      ),
    );
  }
}
