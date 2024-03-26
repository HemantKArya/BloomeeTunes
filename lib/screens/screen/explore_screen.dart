import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/song_card_widget.dart';
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
import '../widgets/tabList_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await context
              .read<BloomeeDBCubit>()
              .getSettingBool(GlobalStrConsts.autoUpdateNotify) ??
          false) {
        updateDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrendingCubit>(
          create: (context) => TrendingCubit(),
          lazy: false,
        ),
        BlocProvider<RecentlyCubit>(
          create: (context) => RecentlyCubit(),
          lazy: false,
        ),
      ],
      child: Scaffold(
        body: CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          slivers: [
            customDiscoverBar(context), //AppBar
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CaraouselWidget(),
                  ),
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
                                    ? TabSongListWidget(
                                        list: state.mediaPlaylist.mediaItems
                                            .map((e) {
                                          return SongCardWidget(
                                            song: e,
                                            onTap: () {
                                              context
                                                  .read<BloomeePlayerCubit>()
                                                  .bloomeePlayer
                                                  .loadPlaylist(
                                                    MediaPlaylist(
                                                      mediaItems: [e],
                                                      albumName: "Recently",
                                                    ),
                                                    doPlay: true,
                                                  );
                                            },
                                            onOptionsTap: () =>
                                                showMoreBottomSheet(context, e),
                                          );
                                        }).toList(),
                                        category: "Recently",
                                        columnSize: 3,
                                      )
                                    : const SizedBox()),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: SizedBox(
                      child: BlocBuilder<TrendingCubit, TrendingCubitState>(
                        builder: (context, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1000),
                            child: state is TrendingCubitInitial
                                ? const Center(
                                    child: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: CircularProgressIndicator(
                                          color: Default_Theme.accentColor2,
                                        )),
                                  )
                                : TabSongListWidget(
                                    list:
                                        state.ytCharts![0].chartItems!.map((e) {
                                      return ChartListTile(
                                        title: e.name ?? "",
                                        subtitle: e.subtitle ?? "",
                                        imgUrl: e.imageUrl ?? "",
                                        rectangularImage: true,
                                      );
                                    }).toList(),
                                    category: "Trending",
                                    columnSize: 4,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Default_Theme.themeColor,
      ),
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
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationView()));
              },
              child: const Icon(MingCute.notification_line,
                  color: Default_Theme.primaryColor1, size: 30.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TimerView()));
              },
              child: const Icon(MingCute.stopwatch_line,
                  color: Default_Theme.primaryColor1, size: 30.0),
            ),
          ),
          InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsView()));
              },
              child: const Icon(MingCute.settings_3_line,
                  color: Default_Theme.primaryColor1, size: 30.0)),
        ],
      ),
    );
  }
}
