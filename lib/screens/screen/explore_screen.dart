import 'dart:developer';

import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/screen/home_views/recents_view.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/utils/app_updater.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_view.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import '../widgets/carousal_widget.dart';
import '../widgets/horizontal_card_view.dart';
import '../widgets/tabList_widget.dart';
import 'package:badges/badges.dart' as badges;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isUpdateChecked = false;
  YTMusicCubit yTMusicCubit = YTMusicCubit();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isUpdateChecked) {
        if (await context
                .read<BloomeeDBCubit>()
                .getSettingBool(GlobalStrConsts.autoUpdateNotify) ??
            false) {
          updateDialog(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecentlyCubit>(
          create: (context) => RecentlyCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => yTMusicCubit,
          lazy: false,
        ),
        BlocProvider(
          create: (context) => FetchChartCubit(),
          lazy: false,
        ),
      ],
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await yTMusicCubit.fetchYTMusic();
            log("Refreshed");
          },
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            slivers: [
              customDiscoverBar(context), //AppBar
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    CaraouselWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox(
                        child: BlocBuilder<RecentlyCubit, RecentlyCubitState>(
                          builder: (context, state) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1000),
                              child: state is RecentlyCubitInitial
                                  ? const Center(
                                      child: SizedBox(
                                          height: 60,
                                          width: 60,
                                          child: CircularProgressIndicator(
                                            color: Default_Theme.accentColor2,
                                          )),
                                    )
                                  : ((state.mediaPlaylist.mediaItems.isNotEmpty)
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HistoryView()));
                                          },
                                          child: TabSongListWidget(
                                            list: state.mediaPlaylist.mediaItems
                                                .map((e) {
                                              return SongCardWidget(
                                                song: e,
                                                onTap: () {
                                                  context
                                                      .read<
                                                          BloomeePlayerCubit>()
                                                      .bloomeePlayer
                                                      .addQueueItem(
                                                        e,
                                                        doPlay: true,
                                                      );

                                                  // context
                                                  //     .read<DownloaderCubit>()
                                                  //     .downloadSong(e);
                                                },
                                                onOptionsTap: () =>
                                                    showMoreBottomSheet(
                                                        context, e),
                                              );
                                            }).toList(),
                                            category: "Recently",
                                            columnSize: 3,
                                          ),
                                        )
                                      : const SizedBox()),
                            );
                          },
                        ),
                      ),
                    ),
                    BlocBuilder<YTMusicCubit, YTMusicCubitState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: state is YTMusicCubitInitial
                              ? BlocBuilder<ConnectivityCubit,
                                  ConnectivityState>(
                                  builder: (context, state2) {
                                    if ((state2 ==
                                        ConnectivityState.disconnected)) {
                                      return const SignBoardWidget(
                                        message: "No Internet Connection!",
                                        icon: MingCute.wifi_off_line,
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                )
                              : ytSection(state.ytmData),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        backgroundColor: Default_Theme.themeColor,
      ),
    );
  }

  Widget ytSection(Map<String, List<dynamic>> ytmData) {
    List<Widget> ytList = List.empty(growable: true);
    // log(ytmData.toString());

    for (var value in (ytmData["body"]!)) {
      // log(value.toString());
      ytList.add(HorizontalCardView(data: value));
    }
    return ListView(
      shrinkWrap: true,
      itemExtent: 275,
      padding: const EdgeInsets.only(top: 0),
      physics: const NeverScrollableScrollPhysics(),
      children: ytList,
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Discover",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationInitial || state.notifications.isEmpty) {
                return IconButton(
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
                            builder: (context) => const NotificationView()));
                  },
                  icon: const Icon(MingCute.notification_line,
                      color: Default_Theme.primaryColor1, size: 30.0),
                );
              } else {
                return badges.Badge(
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Text(
                      state.notifications.length.toString(),
                      style: Default_Theme.primaryTextStyle.merge(
                          const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Default_Theme.primaryColor2)),
                    ),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Default_Theme.accentColor2,
                    shape: badges.BadgeShape.circle,
                  ),
                  position: badges.BadgePosition.topEnd(top: -10, end: -5),
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
                              builder: (context) => const NotificationView()));
                    },
                    icon: const Icon(MingCute.notification_line,
                        color: Default_Theme.primaryColor1, size: 30.0),
                  ),
                );
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
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TimerView()));
            },
            icon: const Icon(MingCute.stopwatch_line,
                color: Default_Theme.primaryColor1, size: 30.0),
          ),
          IconButton(
              padding: EdgeInsets.all(5),
              constraints: const BoxConstraints(),
              style: const ButtonStyle(
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // the '2023' part
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsView()));
              },
              icon: const Icon(MingCute.settings_3_line,
                  color: Default_Theme.primaryColor1, size: 30.0)),
        ],
      ),
    );
  }
}
