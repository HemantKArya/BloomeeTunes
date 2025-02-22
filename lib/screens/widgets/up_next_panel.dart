import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'song_tile.dart';

class UpNextPanel extends StatefulWidget {
  const UpNextPanel({
    super.key,
    required PanelController panelController,
  }) : _panelController = panelController;

  final PanelController _panelController;

  @override
  State<UpNextPanel> createState() => _UpNextPanelState();
}

class _UpNextPanelState extends State<UpNextPanel> {
  final ItemScrollController _scrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();

  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();

  StreamSubscription? _mediaItemSub;
  Stream upNext = Rx.defer(
    () => Rx.combineLatest2(BehaviorSubject<List<MediaItem>>.seeded([]),
        BehaviorSubject<List<MediaItem>>.seeded([]), (a, b) => [...a, ...b]),
    reusable: true,
  );

  @override
  void initState() {
    // upNext = Rx.defer(
    //   () => CombineLatestStream.combine2(
    //       context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
    //       context.read<BloomeePlayerCubit>().bloomeePlayer.relatedSongs,
    //       (a, b) => [...a, ...b]),
    //   reusable: true,
    // );
    _mediaItemSub = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .mediaItem
        .listen((value) {
      if (value != null && mounted) {
        // at first the scrollablepositionedlist is not ready
        // try {
        //   _scrollController.scrollTo(
        //       index: context
        //           .read<BloomeePlayerCubit>()
        //           .bloomeePlayer
        //           .currentPlayingIdx,
        //       duration: const Duration(milliseconds: 500),
        //       curve: Curves.easeInOut);
        // } catch (e) {
        //   log(e.toString(), name: "UpNextPanel");
        //   Future.delayed(const Duration(milliseconds: 500), () {
        //     _scrollController.scrollTo(
        //         index: context
        //             .read<BloomeePlayerCubit>()
        //             .bloomeePlayer
        //             .currentPlayingIdx,
        //         duration: const Duration(milliseconds: 500),
        //         curve: Curves.easeInOut);
        //   });
        // }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    super.dispose();
  }

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
                    widget._panelController.isPanelOpen
                        ? widget._panelController.close()
                        : widget._panelController.open();
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
                stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ReorderableListView.builder(
                      // itemScrollController: _scrollController,
                      // itemPositionsListener: _itemPositionsListener,
                      // scrollOffsetController: _scrollOffsetController,
                      // scrollOffsetListener: _scrollOffsetListener,
                      padding: const EdgeInsets.only(top: 5),
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length ?? 0,
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(snapshot.data![index].id),
                          onDismissed: (direction) {
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .removeQueueItemAt(index);
                          },
                          child: SongCardWidget(
                              showOptions: false,
                              onTap: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .skipToQueueItem(index);
                              },
                              //
                              song: mediaItem2MediaItemModel(
                                  snapshot.data![index])),
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .moveQueueItem(oldIndex, newIndex);
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
