import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';

import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import '../../theme_data/default.dart';

class ScaffholdWithNavbar extends StatelessWidget {
  ScaffholdWithNavbar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  bool showMiniPlayer = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      backgroundColor: Default_Theme.themeColor,
      drawerScrimColor: Default_Theme.themeColor,
      bottomNavigationBar: SafeArea(
          child: Wrap(
        children: [
          StreamBuilder<PlaybackEvent>(
              stream: context
                  .read<BloomeePlayerCubit>()
                  .bloomeePlayer
                  .audioPlayer
                  .playbackEventStream,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data?.processingState == ProcessingState.ready) {
                  showMiniPlayer = true;
                } else {
                  showMiniPlayer = false;
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    const begin = Offset(0.0, 2.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end);
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );
                    final offsetAnimation = curvedAnimation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: showMiniPlayer
                      ? GestureDetector(
                          onTap: () =>
                              context.pushNamed(GlobalStrConsts.playerScreen),
                          child: const MiniPlayerWidget())
                      : Wrap(),
                );
              }),
          Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: GNav(
              gap: 7.0,
              tabBackgroundColor: Default_Theme.accentColor2.withOpacity(0.22),
              color: Default_Theme.primaryColor2,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              activeColor: Default_Theme.accentColor2,
              textStyle: Default_Theme.secondoryTextStyleMedium.merge(
                  const TextStyle(
                      color: Default_Theme.accentColor2, fontSize: 18)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              backgroundColor: Default_Theme.themeColor.withOpacity(0.3),
              tabs: const [
                // GButton(
                //   icon: FluentIcons.bin_full_20_filled,
                //   iconSize: 27,
                //   text: "Test",
                // ),
                GButton(
                  icon: FluentIcons.home_heart_24_filled,
                  iconSize: 27,
                  text: "Home",
                ),
                GButton(
                  icon: FluentIcons.book_add_24_filled,
                  text: "Library",
                ),
                GButton(
                  icon: FluentIcons.search_24_filled,
                  text: "Search",
                ),
                GButton(
                  icon: FluentIcons.arrow_download_24_filled,
                  text: "Offline",
                ),
              ],
              selectedIndex: navigationShell.currentIndex,
              onTabChange: (value) {
                navigationShell.goBranch(value);
              },
            ),
          ),
        ],
      )),
    );
  }
}
