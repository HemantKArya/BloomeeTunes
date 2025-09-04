import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/widgets/toogle_btn.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'song_tile.dart';
import 'more_bottom_sheet.dart';

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
  StreamSubscription? _mediaItemSub;

  @override
  void initState() {
    _mediaItemSub = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .mediaItem
        .listen((value) {
      if (value != null && mounted) {}
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
              child: Column(
                children: [
                  Divider(
                    color: Default_Theme.primaryColor2.withOpacity(0.5),
                    thickness: 1.5,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: StreamBuilder<List>(
                            stream: context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .queue,
                            builder: (context, snapshot) {
                              return Text(
                                  "${snapshot.data?.length ?? 0} Items in Queue",
                                  style: Default_Theme.secondoryTextStyleMedium
                                      .merge(TextStyle(
                                          color: Default_Theme.primaryColor2
                                              .withOpacity(0.5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)));
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: BlocBuilder<SettingsCubit, SettingsState>(
                                builder: (context, state) {
                                  return ToggleButton(
                                    label: "Auto Play",
                                    initialState: state.autoPlay,
                                    onChanged: (val) async {
                                      await context
                                          .read<SettingsCubit>()
                                          .setAutoPlay(val);
                                      if (val) {
                                        context
                                            .read<BloomeePlayerCubit>()
                                            .bloomeePlayer
                                            .check4RelatedSongs();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.only(top: 5),
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length ?? 0,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final songModel =
                            mediaItem2MediaItemModel(snapshot.data![index]);
                        return Dismissible(
                          key: ValueKey(snapshot.data?[index].id),
                          onDismissed: (direction) {
                            context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .removeQueueItemAt(index);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: Platform.isAndroid ? 8 : 32,
                            ),
                            child: SongCardWidget(
                              showOptions: true,
                              onTap: () {
                                context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .skipToQueueItem(index);
                              },
                              onOptionsTap: () {
                                // Show the shared bottom sheet used across the app
                                showMoreBottomSheet(context, songModel);
                              },
                              //
                              song: songModel,
                            ),
                          ),
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
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
